"""Test doubles for exercising the installer's sample path without a Spark cluster.

`FakeSpark` answers the three information_schema reads the engine issues, serves the
`SELECT * FROM t LIMIT 0` schema probe from the same fixture, and records every write,
so a test can assert on the rows that WOULD land in Unity Catalog.
"""
import functools
import io
import json
import re
import sqlite3
import threading
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
INSTALLER = HERE.parent.parent / "data-model-installer.ipynb"
ENGINE = HERE.parent / "sample_engine.py"
AGENT = HERE.parents[2] / "model-agent" / "agent" / "dbx_vibe_modelling_agent.ipynb"


# ---------------------------------------------------------------- notebook access

def notebook_cells():
    return json.loads(INSTALLER.read_text())["cells"]


def cell_source(cell):
    src = cell.get("source", "")
    return "".join(src) if isinstance(src, list) else src


def find_cell(needle):
    for cell in notebook_cells():
        if cell.get("cell_type") == "code" and needle in cell_source(cell):
            return cell_source(cell)
    raise LookupError("no code cell contains %r" % needle)


def load_engine():
    """Exec the notebook's sample cell, so tests bind to what actually ships."""
    namespace = {"__name__": "installer_sample_cell"}
    exec(compile(find_cell("def generate_sample_data"), "<sample-cell>", "exec"), namespace)
    return namespace


# ---------------------------------------------------------------- fake spark

class FakeField(object):
    def __init__(self, name):
        self.name = name


class FakeSchema(object):
    def __init__(self, names):
        self.fields = [FakeField(n) for n in names]


class FakeResult(object):
    def __init__(self, rows, schema=None):
        self._rows = rows
        self.schema = schema

    def collect(self):
        return list(self._rows)


class FakeWriter(object):
    def __init__(self, frame):
        self._frame = frame

    def mode(self, _mode):
        return self

    def saveAsTable(self, name):
        self._frame.spark.written.setdefault(name, []).extend(self._frame.rows)


class FakeFrame(object):
    def __init__(self, spark, rows, schema):
        self.spark = spark
        self.rows = rows
        self.schema = schema

    @property
    def write(self):
        return FakeWriter(self)


class FakeSpark(object):
    """Serves information_schema from a fixture dict and records writes.

    fixture = {"catalog": str,
               "tables": {(schema, table): {"columns": [(name, type, nullable)],
                                            "pk": [...],
                                            "fks": [{"columns": [...],
                                                     "parent": (schema, table),
                                                     "parent_columns": [...]}]}}}
    """

    def __init__(self, fixture, ai_response=None, ai_error=False, write_error=(),
                 ai_delay=0.0):
        self.fixture = fixture
        self.ai_response = ai_response
        self.ai_error = ai_error
        self.ai_delay = ai_delay
        self.write_error = set(write_error)
        self.written = {}
        self.queries = []

    # -- helpers ---------------------------------------------------------------
    def _columns_rows(self):
        rows = []
        for (schema, table), spec in self.fixture["tables"].items():
            for position, (name, dtype, nullable) in enumerate(spec["columns"], start=1):
                rows.append((schema, table, name, dtype,
                             "YES" if nullable else "NO", position))
        return rows

    def _pk_rows(self):
        rows = []
        for (schema, table), spec in self.fixture["tables"].items():
            for position, column in enumerate(spec.get("pk", []), start=1):
                rows.append((schema, table, column, position))
        return rows

    def _fk_rows(self):
        """One row per (foreign key column, referenced column) pair, ordinals aligned.

        This mirrors referential_constraints joined to key_column_usage on both sides,
        which is what the engine reads. constraint_column_usage is not modelled because
        the engine must not use it: in Unity Catalog its constraint_schema is the
        REFERENCED table's schema, so correlating on it drops cross-schema keys.
        """
        rows, seq = [], 0
        catalog = self.fixture["catalog"]
        for (schema, table), spec in self.fixture["tables"].items():
            for fk in spec.get("fks", []):
                seq += 1
                name = "%s_%s_fk%d" % (table, schema, seq)
                parent_schema, parent_table = fk["parent"]
                pairs = list(zip(fk["columns"], fk["parent_columns"]))
                for position, (column, parent_column) in enumerate(pairs, start=1):
                    rows.append((schema, name, schema, table, column, position,
                                 catalog, parent_schema, parent_table, parent_column))
        return rows

    # -- api -------------------------------------------------------------------
    def sql(self, query):
        self.queries.append(query)
        flat = " ".join(query.split())
        if "ai_query" in flat:
            if self.ai_delay:
                time.sleep(self.ai_delay)
            if self.ai_error:
                raise RuntimeError("endpoint unavailable")
            return FakeResult([(self.ai_response or "",)])
        if "information_schema.columns" in flat:
            return FakeResult(self._columns_rows())
        if "referential_constraints" in flat:
            return FakeResult(self._fk_rows())
        if "constraint_column_usage" in flat:
            raise RuntimeError(
                "constraint_column_usage.constraint_schema is the referenced table's "
                "schema in Unity Catalog; read foreign keys via referential_constraints")
        if "key_column_usage" in flat:
            return FakeResult(self._pk_rows())
        probe = re.match(r"SELECT \* FROM `([^`]+)`\.`([^`]+)`\.`([^`]+)` LIMIT 0", flat)
        if probe:
            _catalog, schema, table = probe.groups()
            if (schema, table) in self.write_error:
                raise RuntimeError("table is not writable")
            spec = self.fixture["tables"][(schema, table)]
            return FakeResult([], FakeSchema([c[0] for c in spec["columns"]]))
        return FakeResult([])

    def createDataFrame(self, rows, schema):
        return FakeFrame(self, list(rows), schema)


# ---------------------------------------------------------------- fixtures

def shop_fixture():
    """A model with every shape the engine has to survive.

    single-column key, string key, composite key, cross-schema FK, composite FK,
    self FK, a two-table FK cycle, a narrow decimal and an ordered date pair.
    """
    return {
        "catalog": "demo",
        "tables": {
            ("sales", "customer"): {
                "columns": [("customer_id", "BIGINT", False),
                            ("customer_name", "STRING", False),
                            ("country_code", "STRING", True),
                            ("email", "STRING", True),
                            ("loyalty_score", "DECIMAL(5,4)", True),
                            ("status", "STRING", False),
                            ("created_date", "DATE", True),
                            ("updated_date", "DATE", True),
                            ("primary_order_id", "BIGINT", True)],
                "pk": ["customer_id"],
                # cycle: customer -> order -> customer
                "fks": [{"columns": ["primary_order_id"], "parent": ("sales", "order"),
                         "parent_columns": ["order_id"]}],
            },
            ("sales", "order"): {
                "columns": [("order_id", "BIGINT", False),
                            ("customer_id", "BIGINT", False),
                            ("order_date", "DATE", True),
                            ("ship_date", "DATE", True),
                            ("total_amount", "DECIMAL(18,2)", True),
                            ("quantity", "INT", True),
                            ("order_status", "STRING", True)],
                "pk": ["order_id"],
                "fks": [{"columns": ["customer_id"], "parent": ("sales", "customer"),
                         "parent_columns": ["customer_id"]}],
            },
            ("sales", "order_line"): {
                "columns": [("order_id", "BIGINT", False),
                            ("line_no", "INT", False),
                            ("unit_price", "DECIMAL(10,2)", True),
                            ("quantity", "INT", True)],
                "pk": ["order_id", "line_no"],
                "fks": [{"columns": ["order_id"], "parent": ("sales", "order"),
                         "parent_columns": ["order_id"]}],
            },
            ("hr", "employee"): {
                "columns": [("employee_id", "BIGINT", False),
                            ("full_name", "STRING", False),
                            ("manager_id", "BIGINT", True),
                            ("hire_date", "DATE", True),
                            ("termination_date", "DATE", True)],
                "pk": ["employee_id"],
                "fks": [{"columns": ["manager_id"], "parent": ("hr", "employee"),
                         "parent_columns": ["employee_id"]}],
            },
            ("ops", "shipment"): {
                "columns": [("shipment_id", "STRING", False),
                            ("order_id", "BIGINT", True),
                            ("carrier_name", "STRING", True),
                            ("dispatch_timestamp", "TIMESTAMP", True)],
                "pk": ["shipment_id"],
                "fks": [{"columns": ["order_id"], "parent": ("sales", "order"),
                         "parent_columns": ["order_id"]}],
            },
            ("ops", "line_event"): {
                "columns": [("event_id", "BIGINT", False),
                            ("order_id", "BIGINT", True),
                            ("line_no", "INT", True),
                            ("event_type", "STRING", True)],
                "pk": ["event_id"],
                "fks": [{"columns": ["order_id", "line_no"],
                         "parent": ("sales", "order_line"),
                         "parent_columns": ["order_id", "line_no"]}],
            },
            ("ops", "reference_country"): {
                "columns": [("country_code", "STRING", False),
                            ("country_name", "STRING", False)],
                "pk": ["country_code"],
                "fks": [],
            },
        },
    }


def sample_config(**overrides):
    cfg = {"enabled": True, "rows": 10, "seed": 20260801, "threads": 2,
           "llm": False, "llm_endpoints": []}
    cfg.update(overrides)
    return cfg


# ---------------------------------------------------------------- uninstall doubles

class FakeMetastore(object):
    """A metastore that remembers its catalogs and schemas and answers the DDL the
    uninstall path issues, so a test can assert on what survived.

    `schemas` maps catalog -> set of schema names. Every catalog implicitly carries
    `information_schema`, which the uninstall must never count as leftover content.
    """

    def __init__(self, schemas, fail_on=()):
        self.schemas = {cat: set(names) for cat, names in schemas.items()}
        self.fail_on = set(fail_on)
        self.statements = []

    def sql(self, query):
        flat = " ".join(query.split())
        self.statements.append(flat)
        for token in self.fail_on:
            if token in flat:
                raise RuntimeError("simulated failure on %s" % token)

        m = re.match(r"SELECT schema_name FROM `([^`]+)`\.information_schema\.schemata",
                     flat, re.I)
        if m:
            catalog = m.group(1)
            if catalog not in self.schemas:
                raise RuntimeError("catalog %s does not exist" % catalog)
            return FakeResult([(n,) for n in
                               sorted(self.schemas[catalog] | {"information_schema"})])

        m = re.match(r"DROP SCHEMA IF EXISTS `([^`]+)`\.`([^`]+)` CASCADE", flat, re.I)
        if m:
            catalog, schema = m.groups()
            self.schemas.get(catalog, set()).discard(schema)
            return FakeResult([])

        m = re.match(r"DROP CATALOG IF EXISTS `([^`]+)`(?: CASCADE)?", flat, re.I)
        if m:
            self.schemas.pop(m.group(1), None)
            return FakeResult([])

        return FakeResult([])


def load_uninstall(spark, manifest=None, plan=None, log_lines=None):
    """Exec the notebook's uninstall cell against stubs, so the test binds to shipped code.

    `manifest` is the dict a prior install would have written (None = no manifest, which
    exercises the plan fallback). `plan` is what build_plan returns in that fallback.
    """
    import datetime as _datetime
    import json as _json
    import os as _os
    import time as _time

    lines = log_lines if log_lines is not None else []
    written = {}

    def _log(msg):
        lines.append(str(msg))

    def _run_phase(_name, statements, _threads, _batch, group=False, serial=False):
        failures = []
        for stmt in statements:
            try:
                spark.sql(stmt)
            except Exception as exc:
                failures.append((stmt, str(exc)))
        return failures

    class _FakeFile(object):
        def __init__(self, path):
            self.path, self.buf = path, []

        def write(self, text):
            self.buf.append(text)

        def flush(self):
            pass

        def fileno(self):
            return 0

        def __enter__(self):
            return self

        def __exit__(self, *_):
            written[self.path] = "".join(self.buf)
            return False

    def _open(path, mode="r"):
        if "w" in mode:
            return _FakeFile(path)
        if manifest is None:
            raise IOError("no such file: %s" % path)
        return _FakeFile2(_json.dumps(manifest))

    class _FakeFile2(object):
        def __init__(self, text):
            self.text = text

        def read(self):
            return self.text

        def __enter__(self):
            return self

        def __exit__(self, *_):
            return False

    namespace = {
        "__name__": "installer_uninstall_cell",
        "spark": spark, "log": _log, "json": _json, "os": _os, "time": _time,
        "datetime": _datetime, "_re": re, "open": _open,
        "run_phase": _run_phase,
        "retry_failed": lambda failures, passes=3: failures,
        "build_plan": lambda cfg: plan or {"schema": []},
        "_flush_log_durable": lambda: None,
        "_SINK": {"path": None},
    }
    exec(compile(find_cell("def uninstall(cfg)"), "<uninstall-cell>", "exec"), namespace)
    namespace["_log_lines"] = lines
    namespace["_written_files"] = written
    return namespace


def run_main_cell(sample_cfg, failures=(), calls=None, catalog_exists=None,
                  on_manifest=None, hooks=None):
    """Exec the installer's main cell against stubs and run main() once.

    `catalog_exists` is the stub behind the pre-install catalog probe; pass a callable
    with side effects to observe WHEN main() probes. `on_manifest` receives
    (cfg, plan, pre_existing, samples) so a test can assert what the install recorded.
    The model.json load, the scoped-install guard, the install and the agent hand-off
    append to calls["order"]; `hooks` replaces any stub by name after the cell is run.
    """
    import datetime as _datetime
    import json as _json
    import os as _os
    import time as _time

    calls = {} if calls is None else calls
    failures = list(failures)
    source = find_cell("def main()")
    assert source.rstrip().endswith("main()")
    body = source.rstrip()[:-len("main()")]

    class _Exit(Exception):
        pass

    def notebook_exit(value):
        calls["exit"] = value
        raise _Exit()

    def _sink_setup(cfg):
        calls.setdefault("order", []).append("setup_log_sink")

    def _step(name, result=None):
        def _record(*args):
            calls.setdefault("order", []).append(name)
            calls.setdefault("args", {})[name] = args
            return result
        return _record

    _install = _step("install", (failures, 12.0, {"table": 12.0}))

    def _manifest(cfg, plan, pre_existing, samples=None):
        calls.setdefault("order", []).append("write_install_manifest")
        if on_manifest:
            on_manifest(cfg, plan, pre_existing, samples)

    namespace = {
        "__name__": "installer_main_cell",
        "time": _time, "datetime": _datetime, "os": _os, "json": _json,
        "log": lambda m: calls.setdefault("log", []).append(m),
        "INDUSTRIES": ["airlines"],
        "INSTALLER_TAG_PREFIX": "t_",
        "_wget": lambda k, d="": {"model": "airlines"}.get(k, d),
        "_running_as_job": lambda: True,
        "resolve_config": lambda: {
            "operation": "install",
            "industry": "airlines", "model_size": "mvm", "catalog": "demo",
            "cataloging_style": "One Catalog", "catalog_prefix": "", "catalog_suffix": "",
            "threads": 8, "batch_size": 20, "include_metrics": False, "mode": "REPO",
            "session_id": "1", "local_install": "", "resolved_version": "v1",
            "target_catalogs": ["demo"], "sample": sample_cfg},
        "_catalog_exists": catalog_exists or (lambda catalog: True),
        "write_install_manifest": _manifest,
        "uninstall": lambda cfg: ([], 1.0),
        "build_plan": lambda cfg: {"table": ["CREATE TABLE t"]},
        "load_model_json": _step("load_model_json"),
        "guard_scoped_install": _step("guard_scoped_install"),
        "register_model_json": _step("register_model_json"),
        "install": _install,
        "generate_sample_data": lambda spark, cfg, catalogs, log: (
            calls.setdefault("samples", []).append((cfg, catalogs))
            or {"written": 42, "tables": 7, "failed": []}),
        "setup_log_sink": _sink_setup,
        "teardown_log_sink": lambda: None,
        "_flush_log_durable": lambda: None,
        "write_failures_manifest": lambda cfg, final: None,
        "_SINK": {"path": "/tmp/log"},
        "spark": None,
        "dbutils": type("D", (), {
            "notebook": type("N", (), {"exit": staticmethod(notebook_exit)})})(),
    }
    exec(compile(body, "<main-cell>", "exec"), namespace)
    # install / setup_log_sink / write_failures_manifest are defined by the cell itself,
    # so they can only be stubbed once it has been executed.
    namespace.update(
        install=_install,
        setup_log_sink=_sink_setup,
        teardown_log_sink=lambda: None,
        write_failures_manifest=lambda cfg, final: None,
        JobLauncher=type("J", (), {
            "update_job_tags": staticmethod(lambda tags: {"success": True})}))
    namespace.update(hooks or {})
    try:
        namespace["main"]()
    except _Exit:
        pass
    return calls


def uninstall_config(**overrides):
    cfg = {"industry": "banking", "model_size": "mvm", "catalog": "bank_cat",
           "cataloging_style": "One Catalog", "include_metrics": True,
           "target_catalogs": ["bank_cat"], "ddl_threads": 4, "batch_size": 20,
           "resolved_version": "v1", "operation": "uninstall"}
    cfg.update(overrides)
    return cfg


# ---------------------------------------------------------------- scoped install / hand-off

REGISTRY_COLUMNS = ("business", "version", "model_scope", "completed_percent", "catalog",
                    "deploy_status")


_SPARK_LITERAL_RUN = re.compile(r"'(?:[^'\\]|\\.)*'(?:\s*'(?:[^'\\]|\\.)*')*")


def spark_literals_to_sqlite(sql):
    """Rewrite Spark SQL string literals as sqlite literals. Spark reads a backslash as the escape
    and concatenates adjacent literals ('a''b' is "ab"); sqlite reads '' as one quote. Translating
    keeps the sqlite-backed fakes faithful to what Spark would have matched."""
    def _one(match):
        value = "".join(re.sub(r"\\(.)", r"\1", part) for part in re.findall(r"'((?:[^'\\]|\\.)*)'", match.group(0)))
        return "'" + value.replace("'", "''") + "'"
    return _SPARK_LITERAL_RUN.sub(_one, sql)


class FakeRegistry(FakeMetastore):
    """A FakeMetastore that also holds the agent's `_metamodel.business` table.

    The registry query is answered by sqlite, so the installer's WHERE clause is judged
    with real SQL NULL and LOWER() semantics instead of a hand-written imitation.
    `tables` and `volumes` are what information_schema reports inside `_metamodel`.
    """

    def __init__(self, schemas, columns=(), rows=(), tables=(), volumes=("vol_root",),
                 fail_on=(), domain_rows=None, domain_columns=None):
        FakeMetastore.__init__(self, schemas, fail_on)
        self.columns = list(columns)
        self.domain_columns = list(("business", "version", "model_scope") if domain_columns is None and columns
                                   else domain_columns or ())
        self.metamodel_tables = list(tables)
        self.metamodel_volumes = list(volumes)
        self.db = sqlite3.connect(":memory:", check_same_thread=False)
        if self.columns:
            self.db.execute("CREATE TABLE business (%s)" % ", ".join(self.columns))
            for row in rows:
                self.db.execute("INSERT INTO business (%s) VALUES (%s)"
                                % (", ".join(row), ", ".join("?" for _ in row)), list(row.values()))
            self.db.execute("CREATE TABLE domain (business, version, model_scope)")
            for row in (rows if domain_rows is None else domain_rows):
                self.db.execute("INSERT INTO domain VALUES (?, ?, ?)",
                                [row.get("business"), row.get("version"), row.get("model_scope")])

    @property
    def queries(self):
        return self.statements

    def _handler(self, flat):
        if "information_schema.columns" in flat and "table_name = 'domain'" in flat:
            return lambda: FakeResult([(c,) for c in self.domain_columns])
        if "information_schema.columns" in flat:
            return lambda: FakeResult([(c,) for c in self.columns])
        if "information_schema.tables" in flat:
            return lambda: FakeResult([(t,) for t in self.metamodel_tables])
        if "information_schema.volumes" in flat:
            return lambda: FakeResult([(v,) for v in self.metamodel_volumes])
        m = re.match(r"SELECT version FROM `[^`]+`\.`_metamodel`\.`(business|domain)` WHERE (.*)$", flat)
        if m:
            return lambda: FakeResult(self.db.execute(
                "SELECT version FROM %s WHERE %s" % (m.group(1), spark_literals_to_sqlite(m.group(2)))).fetchall())
        m = re.match(r"CREATE SCHEMA IF NOT EXISTS `([^`]+)`\.`([^`]+)`$", flat)
        if m:
            return lambda: self.schemas.setdefault(m.group(1), set()).add(m.group(2))
        return None

    def sql(self, query):
        flat = " ".join(query.split())
        handler = self._handler(flat)
        if handler is None:
            return FakeMetastore.sql(self, query)
        self.statements.append(flat)
        for token in self.fail_on:
            if token in flat:
                raise RuntimeError("simulated failure on %s" % token)
        return handler()


class FakeUC(FakeRegistry):
    """A FakeRegistry that also executes model DDL: tables with columns, named FK
    constraints and column tags, raising the error strings the installer reacts to, so a
    test can see what actually survives an install. `log` keeps every statement in order.
    """

    def __init__(self, tables=None, fail=None, schemas=None, **registry):
        FakeRegistry.__init__(self, {"demo": set()} if schemas is None else schemas, **registry)
        self.tables = {k: {"columns": set(v["columns"]), "fks": dict(v.get("fks", {})), "tags": {},
                           "types": dict(v.get("types") or {c: "bigint" for c in v["columns"]})}
                       for k, v in (tables or {}).items()}
        for name in self.tables:
            catalog, schema, _ = name.split(".")
            self.schemas.setdefault(catalog, set()).add(schema)
        self.fail = fail or (lambda stmt: None)
        self.log = []
        self.lock = threading.Lock()

    @staticmethod
    def _name(text):
        return text.replace("`", "").lower()

    def _table(self, name):
        if name not in self.tables:
            raise RuntimeError("[TABLE_OR_VIEW_NOT_FOUND] The table or view `%s` cannot be found."
                               % name)
        return self.tables[name]

    def sql(self, query):
        flat = " ".join(query.split())
        with self.lock:
            self.log.append(flat)
            self.fail(flat)
            handled, result = self._ddl(flat)
            return result if handled else FakeRegistry.sql(self, query)

    def _ddl(self, flat):
        m = re.match(r"DESCRIBE CATALOG `([^`]+)`", flat)
        if m:
            if m.group(1) not in self.schemas:
                raise RuntimeError("[NO_SUCH_CATALOG_EXCEPTION] %s" % m.group(1))
            return True, None
        m = re.match(r"CREATE CATALOG (?:IF NOT EXISTS )?`([^`]+)`", flat)
        if m:
            self.schemas.setdefault(m.group(1), set())
            return True, None
        m = re.match(r"CREATE (?:DATABASE|SCHEMA) (?:IF NOT EXISTS )?`([^`]+)`\.`([^`]+)`", flat)
        if m:
            self.schemas.setdefault(m.group(1), set()).add(m.group(2))
            return True, None
        m = re.match(r"CREATE (OR REPLACE )?TABLE (IF NOT EXISTS )?(\S+) \((.*)\)$", flat)
        if m:
            name = self._name(m.group(3))
            if not (m.group(2) and name in self.tables):
                defs = [part.split() for part in m.group(4).split(",") if part.split()]
                types = dict((self._name(d[0]), d[1].lower() if len(d) > 1 else "string") for d in defs)
                self.tables[name] = {"columns": set(types), "fks": {}, "tags": {}, "types": types}
            return True, None
        m = re.match(r"ALTER TABLE (\S+) DROP CONSTRAINT IF EXISTS (\S+)$", flat)
        if m:
            self._table(self._name(m.group(1)))["fks"].pop(self._name(m.group(2)), None)
            return True, None
        m = re.match(r"ALTER TABLE (\S+) ADD COLUMNS ?\((.*)\);?$", flat)
        if m:
            table = self._table(self._name(m.group(1)))
            defs = [(self._name(c), t.lower()) for c, t in
                    re.findall(r"(`?[A-Za-z_]\w*`?)\s+([A-Za-z_]\w*(?:\([^)]*\))?)(?:\s+COMMENT\s+'[^']*')?", m.group(2))]
            existing = [c for c, _t in defs if c in table["columns"]]
            if existing:
                struct = ", ".join("%s: %s" % (c, table["types"].get(c, "bigint").upper()) for c in sorted(table["columns"]))
                raise RuntimeError("[FIELD_ALREADY_EXISTS] Cannot add column, because `%s` already exists in \"STRUCT<%s>\". "
                                   "SQLSTATE: 42710; line 1 pos 0" % (existing[0], struct))
            for col, ctype in defs:
                table["columns"].add(col)
                table["types"][col] = ctype
            return True, None
        m = re.match(r"SELECT LOWER\(column_name\), LOWER\(full_data_type\) FROM `([^`]+)`\.information_schema\.columns "
                     r"WHERE LOWER\(table_schema\) = '([^']*)' AND LOWER\(table_name\) = '([^']*)'$", flat)
        if m:
            table = self.tables.get("%s.%s.%s" % m.groups()) or {"types": {}}
            return True, FakeResult(sorted(table["types"].items()))
        m = re.match(r"ALTER TABLE (\S+) ADD CONSTRAINT (\S+) FOREIGN KEY \((\S+)\) "
                     r"REFERENCES (\S+) ", flat)
        if m:
            table = self._table(self._name(m.group(1)))
            parent = self._name(m.group(4))
            self._table(parent)
            name = self._name(m.group(2))
            if name in table["fks"]:
                raise RuntimeError("[DELTA_CONSTRAINT_ALREADY_EXISTS] Constraint '%s' already exists. Please delete the old "
                                   "constraint first.\nOld constraint:\n%s FOREIGN KEY (`%s`) REFERENCES %s (`%s`)\n"
                                   % (name, name, self._name(m.group(3)), table["fks"][name], self._name(m.group(3))))
            table["fks"][name] = parent
            return True, None
        m = re.match(r"ALTER TABLE (\S+) ALTER COLUMN (\S+) SET TAGS", flat)
        if m:
            table, col = self._table(self._name(m.group(1))), self._name(m.group(2))
            if col not in table["columns"]:
                raise RuntimeError("[UNRESOLVED_COLUMN] `%s` cannot be resolved" % col)
            table["tags"][col] = flat.split("SET TAGS", 1)[1].strip()
            return True, None
        return False, None

    def position(self, needle):
        return [i for i, s in enumerate(self.log) if needle in s]

    def ddl_count(self):
        return sum(1 for s in self.log if s.startswith(("CREATE TABLE", "CREATE OR REPLACE TABLE",
                                                        "ALTER TABLE")))


SCOPED_SQL = """-- Schema for Domain: sales
CREATE DATABASE IF NOT EXISTS `demo`.`sales`;
CREATE TABLE IF NOT EXISTS `demo`.`sales`.`order` (order_id BIGINT, customer_id BIGINT);
CREATE OR REPLACE TABLE `demo`.`sales`.`customer_v2` (customer_id BIGINT);
ALTER TABLE `demo`.`sales`.`order` DROP CONSTRAINT IF EXISTS `fk_order_customer`;
ALTER TABLE `demo`.`sales`.`order` ADD COLUMNS (`loyalty_id` BIGINT COMMENT 'Loyalty link');
ALTER TABLE `demo`.`sales`.`order` ADD CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `demo`.`sales`.`customer_v2` (`customer_id`);
ALTER TABLE `demo`.`sales`.`order` ALTER COLUMN `loyalty_id` SET TAGS ('dbx_pii' = 'false');
"""

BASE_V1_TABLES = {
    "demo.sales.order": {"columns": ["order_id", "customer_id"],
                         "fks": {"fk_order_customer": "demo.sales.customer"}},
    "demo.sales.customer": {"columns": ["customer_id"]},
}


def scoped_folder(tmp_path, model_json=None):
    """A scoped v2/mvm artifact folder: the agent's scoped deploy plan in schemas/, and
    model.json beside it when one is given."""
    folder = tmp_path / "v2" / "mvm"
    (folder / "schemas").mkdir(parents=True)
    (folder / "schemas" / "demo_catalogs_v2_mvm.sql").write_text(
        "CREATE CATALOG IF NOT EXISTS `demo`;\n")
    (folder / "schemas" / "demo_sales_schema_v2_mvm.sql").write_text(SCOPED_SQL)
    if model_json is not None:
        (folder / "model.json").write_text(json.dumps(model_json))
    return folder


def pipeline_cfg(folder):
    return {"local_install": str(folder), "local_install_raw": str(folder), "model_size": "mvm",
            "include_metrics": False, "catalog": "demo", "cataloging_style": "One Catalog",
            "catalog_prefix": "", "catalog_suffix": "", "github_token": "", "threads": 4,
            "batch_size": 20, "ddl_threads": 4, "industry": "demo"}


def load_pipeline(spark, extra_cells=()):
    """build_plan + install (plus `extra_cells`, by needle) from the shipped notebook,
    wired to `spark`, with the main cell exec'd minus its trailing main() call."""
    import datetime as _datetime
    import os as _os

    lines = []
    namespace = {"__name__": "installer_pipeline", "spark": spark, "log": lines.append,
                 "json": json, "os": _os, "datetime": _datetime}
    for needle in ("def categorize", "def build_plan", "def run_phase") + tuple(extra_cells):
        exec(compile(find_cell(needle), "<%s>" % needle, "exec"), namespace)
    main_src = find_cell("def main()").rstrip()
    assert main_src.endswith("main()")
    exec(compile(main_src[:-len("main()")], "<main-cell>", "exec"), namespace)
    namespace["_log_lines"] = lines
    return namespace


def registry_row(version, **overrides):
    row = {"business": "Airlines", "version": str(version), "model_scope": "mvm",
           "completed_percent": 100.0, "catalog": "demo", "deploy_status": "installed"}
    row.update(overrides)
    return row


class FakeFiles(object):
    """The slice of the SDK Files API the hand-off uses, backed by a dict."""

    def __init__(self, existing=None, reported_size=None):
        self.store = dict(existing or {})
        self.reported_size = reported_size
        self.calls = []

    def download(self, path):
        from databricks.sdk.errors import NotFound
        self.calls.append(("download", path))
        if path not in self.store:
            raise NotFound("File %s does not exist" % path)
        return type("Download", (), {"contents": io.BytesIO(self.store[path])})()

    def create_directory(self, path):
        self.calls.append(("create_directory", path))

    def upload(self, path, contents, overwrite=None):
        self.calls.append(("upload", path, overwrite))
        self.store[path] = contents.read()

    def get_metadata(self, path):
        self.calls.append(("get_metadata", path))
        size = len(self.store[path]) if self.reported_size is None else self.reported_size
        return type("Metadata", (), {"content_length": size})()


def redirect_volumes(monkeypatch, root):
    """Serve `/Volumes/...` globs and walks from a real directory under `root`, so the
    manifest scan and the `_metamodel` content check read files a test placed there.
    Returns a function mapping a `/Volumes/...` path to its real location."""
    import glob as _glob
    import os as _os
    root = str(root)
    real_glob, real_walk = _glob.glob, _os.walk

    def _glob_shim(pattern, *args, **kwargs):
        if pattern.startswith("/Volumes/"):
            return real_glob(root + pattern, *args, **kwargs)
        return real_glob(pattern, *args, **kwargs)

    def _walk_shim(top, *args, **kwargs):
        if str(top).startswith("/Volumes/"):
            for d, dirs, names in real_walk(root + str(top), *args, **kwargs):
                yield d[len(root):], dirs, names
        else:
            for item in real_walk(top, *args, **kwargs):
                yield item

    monkeypatch.setattr(_glob, "glob", _glob_shim)
    monkeypatch.setattr(_os, "walk", _walk_shim)
    return lambda path: Path(root + path)


def load_handoff(spark, catalogs=("demo",), files=None, log_lines=None):
    """Exec the manifest cell and the scoped-install / hand-off cell against stubs.

    `catalogs` are the catalogs `_catalog_exists` reports; `files` stands in for the SDK
    Files API returned by `_files_client`."""
    import datetime as _datetime
    import os as _os
    import time as _time

    lines = log_lines if log_lines is not None else []
    namespace = {
        "__name__": "installer_handoff_cell",
        "spark": spark, "log": lambda m: lines.append(str(m)), "json": json, "os": _os,
        "time": _time, "datetime": _datetime, "_re": re,
        "run_phase": lambda *a, **k: [], "retry_failed": lambda failures, passes=3: failures,
        "build_plan": lambda cfg: {"schema": []}, "_flush_log_durable": lambda: None,
        "_SINK": {"path": None}, "_catalog_exists": lambda catalog: catalog in set(catalogs),
    }
    exec(compile(find_cell("def categorize"), "<core-cell>", "exec"), namespace)
    exec(compile(find_cell("def uninstall(cfg)"), "<uninstall-cell>", "exec"), namespace)
    exec(compile(find_cell("def guard_scoped_install"), "<handoff-cell>", "exec"), namespace)
    if files is not None:
        namespace["_files_client"] = lambda: files
    namespace["_log_lines"] = lines
    return namespace


@functools.lru_cache(maxsize=None)
def agent_sanitize_name():
    """The agent's own `sanitize_name`, exec'd from the agent notebook, so the hand-off
    folder is checked against the function that names the agent's business folders."""
    cells = json.loads(AGENT.read_text())["cells"]
    source = next(cell_source(c) for c in cells
                  if "def sanitize_name(name, strip_stop_words=True):" in cell_source(c))
    start = source.index("def sanitize_name(name, strip_stop_words=True):")
    end = source.index("\ndef ", start + 1)
    namespace = {"re": re}
    exec(compile(source[start:end], "<agent-sanitize-name>", "exec"), namespace)
    return namespace["sanitize_name"]
