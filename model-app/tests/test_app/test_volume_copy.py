"""``services/volume_copy.copy_volume_folder``: relative paths kept, only the
top-level ``model.json`` rewritten, failures and a passed deadline reported."""
from __future__ import annotations

import threading
import time
from unittest.mock import MagicMock

from vibe_modeling.backend.services.volume_copy import copy_volume_folder

from ._fake_volume import FakeVolume

SRC = "/Volumes/c/s/src"
DEST = "/Volumes/m/_metamodel/vol_root/business/acme/v1/ecm"


def _volume():
    ws = MagicMock()
    volume = FakeVolume(ws)
    volume.put(f"{SRC}/model.json", {"model": {"version": "v3_ecm"}})
    volume.put(f"{SRC}/docs/model.json", "nested, not the model")
    volume.put(f"{SRC}/schemas/crop.sql", "CREATE SCHEMA crop")
    return ws, volume


def test_copies_every_file_and_rewrites_only_the_top_model_json():
    ws, volume = _volume()
    files = sorted(volume.under(SRC))
    result = copy_volume_folder(ws, files, SRC, DEST, model_json_transform=lambda _b: b'{"rewritten": true}')
    assert result.complete and (result.copied, result.total) == (3, 3)
    assert volume.json(f"{DEST}/model.json") == {"rewritten": True}
    assert volume.files[f"{DEST}/docs/model.json"] == b"nested, not the model"
    assert volume.files[f"{DEST}/schemas/crop.sql"] == b"CREATE SCHEMA crop"


def test_the_apps_backup_is_not_copied():
    """``model.json.pre090`` (the industry prefix fix's backup) stays behind:
    a kickstart of a fixed industry does not carry it."""
    ws, volume = _volume()
    volume.put(f"{SRC}/model.json.pre090", {"model": {}})
    files = sorted(volume.under(SRC))
    result = copy_volume_folder(ws, files, SRC, DEST)
    assert result.complete and (result.copied, result.total) == (3, 3)
    assert f"{DEST}/model.json.pre090" not in volume.files


def test_a_failed_file_is_reported():
    ws, volume = _volume()
    del volume.files[f"{SRC}/schemas/crop.sql"]
    files = sorted(volume.under(SRC)) + [f"{SRC}/schemas/crop.sql"]
    result = copy_volume_folder(ws, files, SRC, DEST)
    assert not result.complete
    assert result.failed == (f"{SRC}/schemas/crop.sql",) and result.copied == 2


def test_a_passed_deadline_stops_the_copy_after_the_files_in_flight():
    ws, volume = _volume()
    release = threading.Event()
    real = ws.files.download.side_effect

    def _slow(path):
        release.wait(2)
        return real(path)

    ws.files.download.side_effect = _slow
    threading.Timer(0.2, release.set).start()
    started = time.monotonic()
    result = copy_volume_folder(ws, sorted(volume.under(SRC)), SRC, DEST, deadline=time.monotonic() + 0.05)
    assert result.timed_out and not result.complete
    assert time.monotonic() - started < 1.5
