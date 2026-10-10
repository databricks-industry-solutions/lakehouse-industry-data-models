"""tools/patch_uninstall.py must never overwrite the notebook's uninstall cell.

The installer stream changed the uninstall cell (installer-owned _metamodel cleanup). Re-running the
patch script used to replace that cell with the script's stale copy; now it refuses and writes nothing.
"""
import importlib.util
import shutil
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
NOTEBOOK = TOOLS.parent / "data-model-installer.ipynb"


def _load_script():
    spec = importlib.util.spec_from_file_location("patch_uninstall_under_test", TOOLS / "patch_uninstall.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_rerunning_the_patch_on_the_current_notebook_refuses_and_writes_nothing(tmp_path, capsys):
    copy = tmp_path / "data-model-installer.ipynb"
    shutil.copyfile(NOTEBOOK, copy)
    before = copy.read_bytes()
    script = _load_script()
    script.NB = copy
    assert script.main() == 1
    assert copy.read_bytes() == before
    assert "refused" in capsys.readouterr().out


def test_the_current_uninstall_cell_differs_from_the_script_copy():
    import json
    script = _load_script()
    cells = json.loads(NOTEBOOK.read_text())["cells"]
    cell = next(script.cell_source(c) for c in cells if "def uninstall(cfg)" in script.cell_source(c))
    assert cell != script.UNINSTALL_CELL
    assert "_metamodel" in cell
