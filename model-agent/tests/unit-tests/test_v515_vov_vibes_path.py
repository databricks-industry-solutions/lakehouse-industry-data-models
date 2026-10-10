"""v5.1.5 decision 8A: an empty '08. Model Vibes' on 'vibe modeling of version' fails preflight and the
error names the parent version's real next_vibes.txt path.

Before this change the preflight (which fires first, in both the launcher and get_widget_values) printed
the template '/Volumes/<metamodel catalog>/.../v<N>/<scope>/vibes/next_vibes.txt'; the concrete path was
only built in step_setup_and_clean, which an empty model_vibes never reaches.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

LIVE_PATH = "/Volumes/vibe_scope_v514_live/_metamodel/vol_root/business/vs514_retail/v1/mvm/vibes/next_vibes.txt"


def _errors(**over):
    kw = dict(operation="vibe modeling of version", business_name="vs514 retail", business_description="retail",
              model_version="1", deployment_catalog="vibe_scope_v514_live", context_file_loaded=False,
              model_folder="", vibe_scope="All Domains", business_domains="", model_vibes="",
              metamodel_catalog="", data_model_scopes="Minimum Viable Model - MVM")
    kw.update(over)
    return ah._validate_required_widget_values(**kw)


def test_empty_vibes_error_names_the_real_parent_next_vibes_path():
    errs = [e for e in _errors() if "08. Model Vibes" in e]
    assert errs and LIVE_PATH in errs[0], errs


def test_the_metamodel_catalog_widget_wins_over_the_installation_catalog():
    errs = [e for e in _errors(metamodel_catalog="mm_cat") if "08. Model Vibes" in e]
    assert "/Volumes/mm_cat/_metamodel/vol_root/business/vs514_retail/v1/mvm/vibes/next_vibes.txt" in errs[0]


def test_an_ecm_scope_and_an_unset_version_are_named_honestly():
    errs = [e for e in _errors(data_model_scopes="Expanded Coverage Model - ECM", model_version="") if "08. Model Vibes" in e]
    assert "/v<latest completed version>/ecm/vibes/next_vibes.txt" in errs[0]


def test_non_empty_vibes_raise_no_vibes_error():
    assert not [e for e in _errors(model_vibes=LIVE_PATH) if "08. Model Vibes" in e]


def test_the_setup_step_builds_the_same_path_through_the_shared_helper():
    assert ah._vov_parent_next_vibes_path("vibe_scope_v514_live", "vs514 retail", "1", "mvm") == LIVE_PATH
