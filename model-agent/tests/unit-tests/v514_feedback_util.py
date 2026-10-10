"""Shared fakes for the v5.1.4 customer-feedback tests (test_v514_feedback_*.py)."""
import ast
import builtins
import copy
import json
import logging
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
AIRLINES = REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json"
RAW = json.loads(AIRLINES.read_text())
AIRLINES_DOMAINS = [d["name"] for d in RAW["model"]["domains"]]
VOV = "vibe modeling of version"
NEW_BASE = "new base model"
SPARK_TYPE_NAMES = ("StringType", "IntegerType", "LongType", "DoubleType", "FloatType", "BooleanType", "DateType", "TimestampType", "DecimalType")


def inject_spark_types(monkeypatch):
    for name in SPARK_TYPE_NAMES:
        if name not in ah.__dict__:
            monkeypatch.setitem(ah.__dict__, name, lambda *a, **k: None)


class Row:
    def __init__(self, values):
        self._values = dict(values)

    def __getattr__(self, name):
        try:
            return self.__dict__["_values"][name]
        except KeyError:
            raise AttributeError(name)

    def __getitem__(self, key):
        if isinstance(key, int):
            return list(self._values.values())[key]
        return self._values[key]

    def asDict(self):
        return dict(self._values)


class _Result:
    def __init__(self, rows):
        self._rows = rows

    def collect(self):
        return list(self._rows)


def _norm_table(name):
    return str(name).replace("`", "").strip().lower()


def _split_top(text, sep=","):
    parts, buf, depth, quote, i = [], [], 0, False, 0
    while i < len(text):
        ch = text[i]
        if quote:
            buf.append(ch)
            if ch == "\\" and i + 1 < len(text):
                buf.append(text[i + 1])
                i += 2
                continue
            if ch == "'":
                if i + 1 < len(text) and text[i + 1] == "'":
                    buf.append("'")
                    i += 2
                    continue
                quote = False
        elif ch == "'":
            quote = True
            buf.append(ch)
        elif ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth -= 1
            buf.append(ch)
        elif ch == sep and depth == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
        i += 1
    if "".join(buf).strip():
        parts.append("".join(buf).strip())
    return parts


def _literal(token):
    token = token.strip()
    if token.upper() == "NULL":
        return None
    if len(token) >= 2 and token.startswith("'") and token.endswith("'"):
        return re.sub(r"\\(.)|''", lambda m: m.group(1) if m.group(1) is not None else "", token[1:-1], flags=re.DOTALL)
    match = re.match(r"TIMESTAMP\('(.*)'\)$", token)
    if match:
        return match.group(1)
    try:
        return float(token)
    except ValueError:
        return token


_VALUES_TOKEN = re.compile(r"'(?:[^'\\]|''|\\.)*'|[(),]|[^'(),]+", re.DOTALL)


def _parse_values(text):
    rows, row, field, depth = [], None, [], 0
    for match in _VALUES_TOKEN.finditer(text):
        token = match.group(0)
        if token == "(":
            depth += 1
            if depth == 1:
                row, field = [], []
                continue
        elif token == ")":
            depth -= 1
            if depth == 0:
                row.append("".join(field).strip())
                rows.append(row)
                continue
        elif token == "," and depth == 1:
            row.append("".join(field).strip())
            field = []
            continue
        if depth >= 1:
            field.append(token)
    return rows


def parse_insert(sql):
    match = re.match(r"\s*INSERT INTO\s+(\S+)\s*\((.*?)\)\s*VALUES\s*(.*)$", sql, re.DOTALL)
    table = _norm_table(match.group(1))
    cols = [c.strip().strip("`").lower() for c in match.group(2).split(",")]
    rows = []
    for raw in _parse_values(match.group(3)):
        values = [_literal(v) for v in raw]
        assert len(values) == len(cols), (table, len(values), len(cols))
        rows.append(dict(zip(cols, values)))
    return table, rows


def _where_matches(row, sql):
    where = sql.split(" WHERE ", 1)[1] if " WHERE " in sql else ""
    biz = re.search(r"LOWER\(business\) = LOWER\('((?:[^'\\]|\\.)*)'\)", where)
    if biz and str(row.get("business") or "").lower() != re.sub(r"\\(.)", r"\1", biz.group(1)).lower():
        return False
    if re.search(r"\bversion IS NULL", where):
        if row.get("version") is not None:
            return False
    ver = re.search(r"\bversion = '([^']*)'", where)
    if ver and str(row.get("version")) != ver.group(1):
        return False
    scope = re.search(r"model_scope = '([^']*)'", where)
    if scope and row.get("model_scope") not in (scope.group(1), None):
        return False
    if "completed_percent = 100" in where and float(row.get("completed_percent") or 0) != 100.0:
        return False
    if re.search(r"deploy_status IS NULL OR (?:LOWER\()?deploy_status\)? = 'installed'", where) and \
            row.get("deploy_status") is not None and str(row.get("deploy_status")).lower() != "installed":
        return False
    cat = re.search(r"LOWER\(catalog\) = LOWER\('([^']*)'\)", where)
    legacy_catalog = "catalog IS NULL OR catalog = '' OR" in where
    if cat and not (legacy_catalog and not row.get("catalog")) and str(row.get("catalog") or "").lower() != cat.group(1).lower():
        return False
    return True


class FakeCatalog:
    def __init__(self, spark):
        self._spark = spark

    def tableExists(self, name):
        return _norm_table(name) in self._spark.tables


class FakeSpark:
    def __init__(self, schemata=None):
        self.statements = []
        self.tables = {}
        self.rows = {}
        self.schemata = {k.lower(): [s.lower() for s in v] for k, v in (schemata or {}).items()}
        self.catalog = FakeCatalog(self)
        self.fail_on = ()

    def add_table(self, name, columns, rows=()):
        key = _norm_table(name)
        self.tables[key] = [c.lower() for c in columns]
        self.rows[key] = [dict(r) for r in rows]

    def sql(self, sql):
        self.statements.append(sql)
        if any(marker in sql for marker in self.fail_on):
            raise RuntimeError(f"injected failure for {self.fail_on}")
        text = sql.strip()
        upper = text.upper()
        if upper.startswith("CREATE TABLE IF NOT EXISTS"):
            match = re.match(r"CREATE TABLE IF NOT EXISTS\s+(\S+)\s*\((.*)\)\s*$", text, re.DOTALL)
            key = _norm_table(match.group(1))
            if key not in self.tables:
                self.add_table(key, [c.strip().split()[0].strip("`") for c in _split_top(match.group(2))])
            return _Result([])
        if upper.startswith("ALTER TABLE"):
            match = re.match(r"ALTER TABLE\s+(\S+)\s+ADD COLUMN\s+`?(\w+)`?", text)
            self.tables[_norm_table(match.group(1))].append(match.group(2).lower())
            return _Result([])
        if upper.startswith("DESCRIBE TABLE"):
            key = _norm_table(text.split()[2])
            if key not in self.tables:
                raise RuntimeError(f"TABLE_OR_VIEW_NOT_FOUND {key}")
            return _Result([Row({"col_name": c}) for c in self.tables[key]])
        if upper.startswith("INSERT INTO"):
            table, rows = parse_insert(text)
            if table not in self.tables:
                raise RuntimeError(f"TABLE_OR_VIEW_NOT_FOUND {table}")
            self.rows[table].extend(rows)
            return _Result([])
        if upper.startswith("DELETE FROM"):
            key = _norm_table(text.split()[2])
            self.rows[key] = [r for r in self.rows.get(key, []) if not _where_matches(r, text)]
            return _Result([])
        if upper.startswith("UPDATE"):
            key = _norm_table(text.split()[1])
            assign = re.search(r"SET (\w+) = '([^']*)'", text)
            if assign:
                for r in self.rows.get(key, []):
                    if _where_matches(r, text):
                        r[assign.group(1).lower()] = assign.group(2)
            return _Result([])
        if "information_schema.schemata" in text:
            cat = re.search(r"FROM\s+`?([^`.\s]+)`?\.information_schema", text).group(1).lower()
            return _Result([Row({"schema_name": s}) for s in self.schemata.get(cat, [])])
        if upper.startswith("SELECT"):
            match = re.search(r"SELECT\s+(.*?)\s+FROM\s+(\S+)", text, re.DOTALL)
            key = _norm_table(match.group(2))
            rows = [r for r in self.rows.get(key, []) if _where_matches(r, text)]
            if "ORDER BY completion_date DESC" in text:
                rows.sort(key=lambda r: (str(r.get("completion_date") or ""), int(float(r.get("version") or 0))), reverse=True)
            if "ORDER BY TRY_CAST(version AS DOUBLE) DESC" in text:
                rows.sort(key=lambda r: (float(r.get("version") or 0), str(r.get("completion_date") or "")), reverse=True)
            limit = re.search(r"\bLIMIT\s+(\d+)", text)
            if limit:
                rows = rows[:int(limit.group(1))]
            projection = match.group(1).strip()
            if projection.upper().startswith("COUNT(*)"):
                return _Result([Row({"cnt": len(rows)})])
            if projection.upper().startswith("MAX(VERSION)"):
                versions = [r.get("version") for r in rows if r.get("version") is not None]
                return _Result([Row({"max_ver": max(versions, key=lambda v: float(v)) if versions else None})])
            cols = [c.strip() for c in projection.split(",")]
            return _Result([Row({c: r.get(c.lower()) for c in cols}) for r in rows])
        return _Result([])

    def inserted(self, table_suffix):
        return [r for key, rows in self.rows.items() if key.endswith(table_suffix) for r in rows]

    def first_index(self, prefix):
        for i, s in enumerate(self.statements):
            if s.strip().upper().startswith(prefix.upper()):
                return i
        return None


def execute_sql_via(fake):
    def _execute_sql(_spark, query, logger=None):
        return fake.sql(query).collect()
    return _execute_sql


class VolumeRedirect:
    def __init__(self, monkeypatch, root):
        self.root = Path(root)
        real_open, real_isdir, real_exists, real_listdir, real_isfile = builtins.open, os.path.isdir, os.path.exists, os.listdir, os.path.isfile

        def _map(path):
            text = os.fspath(path) if isinstance(path, (str, os.PathLike)) else path
            if isinstance(text, str) and text.startswith("/Volumes/"):
                return str(self.root / text[1:])
            return path

        monkeypatch.setattr(builtins, "open", lambda path, *a, **k: real_open(_map(path), *a, **k))
        monkeypatch.setattr(os.path, "isdir", lambda path: real_isdir(_map(path)))
        monkeypatch.setattr(os.path, "isfile", lambda path: real_isfile(_map(path)))
        monkeypatch.setattr(os.path, "exists", lambda path: real_exists(_map(path)))
        monkeypatch.setattr(os, "listdir", lambda path=".": real_listdir(_map(path)))

    def put(self, volume_path, payload):
        target = self.root / volume_path.lstrip("/")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(payload))
        return volume_path


def _attr(name, type_="string", tags="", fk="", description=None):
    return {"name": name, "column_name": name, "type": type_, "tags": tags, "foreign_key_to": fk,
            "description": description if description is not None else f"{name} column"}


def small_model(version="v1_mvm"):
    return {"model": {
        "name": "Airlines", "version": version, "description": "Tiny airline model",
        "model_conventions": {"tag_prefix": "dbx_", "primary_key_suffix": "_id", "data_asset_naming_convention": "snake_case"},
        "domains": [
            {"name": "crm", "division": "business", "description": "Customers", "products": [
                {"name": "customer", "table_name": "customer", "primary_key": "customer_id", "description": "A customer",
                 "attributes": [_attr("customer_id", "bigint", "primary_key"), _attr("name")]},
            ]},
            {"name": "billing", "division": "corporate", "description": "Money", "products": [
                {"name": "invoice", "table_name": "invoice", "primary_key": "invoice_id", "description": "An invoice",
                 "attributes": [_attr("invoice_id", "bigint", "primary_key"), _attr("customer_id", "bigint", fk="crm.customer.customer_id")]},
                {"name": "payment", "table_name": "payment", "primary_key": "payment_id", "description": "A payment",
                 "attributes": [_attr("payment_id", "bigint", "primary_key"), _attr("invoice_id", "bigint", fk="billing.invoice.invoice_id")]},
            ]},
        ],
        "metric_views": [],
    }}


def model_json_path(catalog, business, version, scope):
    return f"/Volumes/{catalog}/_metamodel/vol_root/business/{business}/v{version}/{scope}/model.json"


class StopAfterBranching(Exception):
    pass


def stop(*_a, **_k):
    raise StopAfterBranching()


def setup_widgets(operation, business_domains="", vibe_scope=None, vibes=None, data_domains=None, deployment_catalog="inst_cat",
                  metamodel_catalog="", model_version=None):
    if vibes is None:
        vibes = "Add a loyalty_tier column to crew.member." if operation == VOV else ""
    wv = copy.deepcopy(ah.TECHNICAL_CONTEXT)
    raw_values = {"business_name": "Airlines", "business_domains": business_domains, "operation": operation,
                  "vibe_modelling_instructions": vibes}
    if vibe_scope is not None:
        raw_values["vibe_scope"] = vibe_scope
    wv.update({
        "business_name": "Airlines", "operation": operation,
        "model_version": ("1" if operation == VOV else "") if model_version is None else model_version,
        "data_model_scopes": "Minimum Viable Model - MVM", "deployment_catalog": deployment_catalog, "cataloging_style": "one_catalog",
        "catalog_prefix": "", "catalog_suffix": "", "metamodel_catalog": metamodel_catalog, "vibe_modelling_instructions": vibes,
        "llm_input_context_tokens_count": 200000, "llm_output_context_tokens_count": 64000,
        "_widget_raw_values": raw_values,
        "business_context_data": {
            "business_information": {"business": "Airlines", "description": "An airline.",
                                     "data_domains": business_domains if data_domains is None else data_domains},
            "model_conventions": copy.deepcopy(RAW["model"]["model_conventions"]),
            "vibe_modelling_instructions": vibes,
        },
    })
    wv["business_context_raw"] = copy.deepcopy(wv["business_context_data"])
    return wv


def run_setup(monkeypatch, wv, fake):
    captured = {}
    real_overrides = ah.apply_vibe_authority_overrides

    def _capture(config, widgets_values, logger=None):
        captured["config"] = config
        return real_overrides(config, widgets_values, logger=logger)

    monkeypatch.setitem(ah.__dict__, "execute_sql", execute_sql_via(fake))
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", stop)
    monkeypatch.setitem(ah.__dict__, "apply_vibe_authority_overrides", _capture)
    wv["spark"] = fake
    try:
        ah.step_setup_and_clean(wv)
    except StopAfterBranching:
        pass
    return captured.get("config")


def register(fake, catalog, version="1", scope="mvm", model=None, deploy_status="installed", install_catalog=None):
    blob = model or RAW
    fake.last_result = ah._register_model_json_in_metamodel(
        fake, catalog, blob.get("model", blob), "Airlines", version, scope,
        f"/Volumes/{catalog}/_metamodel/vol_root/business/airlines/v{version}/{scope}",
        catalog=install_catalog or catalog, deploy_status=deploy_status)
    return fake


def nested_main_function(name):
    source = notebook_concat_source()
    tree = ast.parse(source)
    main = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "main"][-1]
    node = next(n for n in ast.walk(main) if isinstance(n, ast.FunctionDef) and n.name == name)
    lines = source.splitlines(keepends=True)[node.lineno - 1:node.end_lineno]
    return "if True:\n" + "".join(lines)


class RecordingLogger(logging.Logger):
    def __init__(self):
        super().__init__("v514-feedback-test", logging.DEBUG)
        self.records = []
        self.propagate = False
        handler = logging.Handler(logging.DEBUG)
        handler.emit = lambda record: self.records.append((record.levelname.lower(), record.getMessage()))
        self.addHandler(handler)

    def text(self, level=None):
        return "\n".join(m for lv, m in self.records if level is None or lv == level)
