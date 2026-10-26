"""Issue #57: the registrar's writes on _metamodel.business retry on concurrent-write errors like its INSERT does.

During an install the progress writer's flush UPDATEs the business row while the registrar DELETEs it. A DELETE that
lost the Delta conflict was recorded as an error, the INSERT still ran, and the registry kept two rows for the version
(the generation's row and the install's row, differing only in case).
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v514_feedback_util as fu  # noqa: E402
from v514_feedback_util import ah  # noqa: E402

BUSINESS_TABLE = "mm_cat._metamodel.business"
CONCURRENT = "[DELTA_CONCURRENT_APPEND] ConcurrentAppendException: Files were added to the root of the table by a concurrent update."


class _ConflictingSpark(fu.FakeSpark):
    """FakeSpark that raises a scripted error for the first N statements starting with a given prefix."""

    def __init__(self):
        super().__init__()
        self.plan = {}

    def conflict(self, prefix, times, message=CONCURRENT):
        self.plan[prefix] = [times, message]

    def sql(self, sql):
        for prefix, entry in self.plan.items():
            if sql.strip().startswith(prefix) and entry[0] > 0:
                entry[0] -= 1
                self.statements.append(sql)
                raise RuntimeError(entry[1])
        return super().sql(sql)

    def count(self, prefix):
        return sum(1 for s in self.statements if s.strip().startswith(prefix))


@pytest.fixture(autouse=True)
def _no_sleep(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    monkeypatch.setattr(ah.time, "sleep", lambda _seconds: None)


def _generation_row_in_other_case(fake):
    fu.register(fake, "mm_cat", model=fu.small_model())
    rows = fake.rows[BUSINESS_TABLE]
    assert len(rows) == 1
    rows[0]["business"] = "AIRLINES"
    rows[0]["processing_status"] = "ready"
    return fake


def test_a_business_delete_that_loses_the_conflict_is_retried_and_leaves_one_row():
    fake = _generation_row_in_other_case(_ConflictingSpark())
    delete_business = "DELETE FROM `mm_cat`.`_metamodel`.`business`"
    fake.conflict(delete_business, 1)
    before = fake.count(delete_business)
    logger = fu.RecordingLogger()

    result = ah._register_model_json_in_metamodel(
        fake, "mm_cat", fu.small_model()["model"], "Airlines", "1", "mvm",
        "/Volumes/mm_cat/_metamodel/vol_root/business/airlines/v1/mvm", catalog="mm_cat", logger=logger)

    assert result["success"] is True, result["errors"]
    assert fake.count(delete_business) - before == 2
    rows = fake.rows[BUSINESS_TABLE]
    assert [r["business"] for r in rows] == ["Airlines"]
    assert rows[0]["deploy_status"] == "installed"
    assert "[registry-concurrent-retry FIRED v5.3.3] delete business" in logger.text("warning")


def test_every_registry_delete_retries_a_concurrent_write():
    fake = fu.register(_ConflictingSpark(), "mm_cat", model=fu.small_model())
    for table in ("attribute", "product", "domain", "business"):
        fake.conflict(f"DELETE FROM `mm_cat`.`_metamodel`.`{table}`", 2)

    result = fu.register(fake, "mm_cat", model=fu.small_model()).last_result

    assert result["success"] is True, result["errors"]
    assert len(fake.rows[BUSINESS_TABLE]) == 1
    assert len(fake.inserted("._metamodel.domain")) == 2
    assert len(fake.inserted("._metamodel.product")) == 3
    assert len(fake.inserted("._metamodel.attribute")) == 6


def test_the_deploy_status_update_retries_a_concurrent_write():
    fake = fu.register(_ConflictingSpark(), "mm_cat", model=fu.small_model())
    update = "UPDATE `mm_cat`.`_metamodel`.`business` SET deploy_status"
    fake.conflict(update, 1)
    before = fake.count(update)

    ah._set_metamodel_deploy_status(fake, "`mm_cat`.`_metamodel`", "Airlines", "1", "mvm", "dry_run")

    assert fake.count(update) - before == 2
    assert fake.rows[BUSINESS_TABLE][0]["deploy_status"] == "dry_run"


def test_the_failed_install_undo_retries_a_concurrent_write():
    fake = fu.register(_ConflictingSpark(), "mm_cat", model=fu.small_model())
    fake.conflict("DELETE FROM `mm_cat`.`_metamodel`.`business`", 1)

    undone = ah._registry_undo_failed_install(fake, "mm_cat", "Airlines", "1", "mvm", None)

    assert undone is True
    assert fake.rows[BUSINESS_TABLE] == []


def test_a_retry_after_exhausted_conflicts_converges_to_one_row():
    fake = _generation_row_in_other_case(_ConflictingSpark())
    fake.conflict("DELETE FROM `mm_cat`.`_metamodel`.`business`", ah.VibeWriter.MAX_PROGRESS_RETRIES)

    failed = fu.register(fake, "mm_cat", model=fu.small_model()).last_result
    assert failed["success"] is False
    assert any(e.startswith("delete business:") for e in failed["errors"])

    retried = fu.register(fake, "mm_cat", model=fu.small_model()).last_result
    assert retried["success"] is True, retried["errors"]
    assert [r["business"] for r in fake.rows[BUSINESS_TABLE]] == ["Airlines"]


def test_a_non_concurrent_error_is_not_retried():
    fake = _ConflictingSpark()
    fake.conflict("DELETE FROM t", 1, message="[TABLE_OR_VIEW_NOT_FOUND] t")
    with pytest.raises(RuntimeError, match="TABLE_OR_VIEW_NOT_FOUND"):
        ah.VibeWriter.run_with_concurrent_retry(fake, "DELETE FROM t WHERE 1 = 1")
    assert fake.count("DELETE FROM t") == 1


def test_the_progress_writer_keeps_its_retry_contract():
    writer = ah.VibeWriter.__new__(ah.VibeWriter)
    writer._spark = _ConflictingSpark()
    writer._logger = fu.RecordingLogger()

    writer._spark.conflict("UPDATE t", ah.VibeWriter.MAX_PROGRESS_RETRIES)
    assert writer._retry_delta_write("UPDATE t SET x = 1", "label") is False
    assert writer._spark.count("UPDATE t") == ah.VibeWriter.MAX_PROGRESS_RETRIES
    assert "label failed after" in writer._logger.text("warning")

    writer._spark.conflict("UPDATE u", 1)
    assert writer._retry_delta_write("UPDATE u SET x = 1") is True

    writer._spark.conflict("UPDATE v", 1, message="[PARSE_SYNTAX_ERROR] v")
    with pytest.raises(RuntimeError, match="PARSE_SYNTAX_ERROR"):
        writer._retry_delta_write("UPDATE v SET x = 1")
