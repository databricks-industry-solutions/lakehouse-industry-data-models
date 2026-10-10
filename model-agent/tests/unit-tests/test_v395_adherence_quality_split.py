import json, os, re, textwrap, pytest

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _extract_block():
    """Pull the actual shipped 2-B block out of the notebook so the test exercises
    production code, not a re-implementation."""
    nb = json.load(open(NB, encoding="utf-8"))
    cell_src = None
    for c in nb.get("cells", []):
        j = "".join(c.get("source", []))
        if "next-vibes-adherence-quality-split" in j and "def step_generate_next_vibes" in j:
            cell_src = j
            break
    assert cell_src is not None, "2-B alias not present in any step_generate_next_vibes cell (fail-pre signal)"
    lines = cell_src.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if '_vov_res = widgets_values.get("_vov_2_pipeline_result")' in ln:
            anchor = i
            break
    assert anchor is not None, "2-B body not found"
    # walk back to the enclosing `try:` so the extracted fragment is a complete statement
    start = None
    for j in range(anchor, -1, -1):
        if lines[j].strip() == "try:":
            start = j
            break
    end = None
    for i in range(anchor, len(lines)):
        if lines[i].strip() == "pass":
            end = i
            break
    assert start is not None and end is not None, "could not bound the 2-B block"
    block = "\n".join(lines[start:end + 1])
    return textwrap.dedent(block)


class _Logger:
    def __init__(self):
        self.msgs = []
    def info(self, m):
        self.msgs.append(m)
    def warning(self, m):
        self.msgs.append(m)


def _run(lines, vov_res, conf):
    block = _extract_block()
    ns = {
        "lines": list(lines),
        "widgets_values": {"_vov_2_pipeline_result": vov_res} if vov_res is not None else {},
        "next_vibe_response": {"confidence_score": conf},
        "logger": _Logger(),
        "_VIBE_SCOPE_RUNTIME": None,
    }
    exec(block, ns)
    return ns["lines"], ns["logger"]


def test_pass_post_inserts_two_explicit_numbers():
    base = ["**Model Quality Score: 70/100**", "", "some prose"]
    out, log = _run(base, {"coverage_pct": 80.0, "n_extracted_vreqs": 50}, 70)
    adh = [l for l in out if l.startswith("**Vibe adherence:")]
    assert len(adh) == 1, out
    # adherence math: 80% of 50 = 40 applied
    assert "80.0% (40/50 VREQs applied)" in adh[0]
    # structural quality reported as its OWN number (no blend)
    assert "Structural quality: 70/100" in adh[0]
    assert "NOT blended" in adh[0]
    # inserted AFTER the Model Quality Score line, not replacing it
    assert out[0].startswith("**Model Quality Score:")
    assert out[1].startswith("**Vibe adherence:")
    assert any("next-vibes-adherence-quality-split FIRED" in m for m in log.msgs)


def test_absence_guard_no_vov_result():
    base = ["**Model Quality Score: 60/100**", "", "prose"]
    out, _ = _run(base, None, 60)
    assert not any(l.startswith("**Vibe adherence:") for l in out), "must not emit adherence on non-VOV path"


def test_zero_extracted_no_line():
    base = ["prose only"]
    out, _ = _run(base, {"coverage_pct": 0.0, "n_extracted_vreqs": 0}, 50)
    assert not any(l.startswith("**Vibe adherence:") for l in out)


def test_idempotent_no_duplicate():
    base = ["**Model Quality Score: 90/100**"]
    once, _ = _run(base, {"coverage_pct": 100.0, "n_extracted_vreqs": 10}, 90)
    # feed the already-augmented lines back through: must not add a second adherence line
    twice, _ = _run(once, {"coverage_pct": 100.0, "n_extracted_vreqs": 10}, 90)
    assert sum(1 for l in twice if l.startswith("**Vibe adherence:")) == 1


def test_no_blend_distinct_from_structural():
    # adherence 40% and structural 90 must both appear unchanged (proving 2-B = no blend)
    base = ["**Model Quality Score: 90/100**"]
    out, _ = _run(base, {"coverage_pct": 40.0, "n_extracted_vreqs": 100}, 90)
    line = [l for l in out if l.startswith("**Vibe adherence:")][0]
    assert "40.0% (40/100" in line and "Structural quality: 90/100" in line
