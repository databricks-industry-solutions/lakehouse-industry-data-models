"""Shared fixtures for the v5.1.4 vibe_scope physical-deploy tests.

A small three-domain airline model (crew in scope; flight and fleet frozen), the
scoped run's facts (P1-P5), a thread-safe fake Spark session that records every
SQL statement and answers the catalog probes from an in-memory physical state, and
a loader that executes the install-model functions nested inside ``main()``.

UCSpark adds the Unity Catalog constraint behaviour the 2026-10-08 probe measured
(fixtures/v514_uc_probe_errors.json): a parent CREATE OR REPLACE keeps child FKs only
while the PK keeps its name and columns, a changed PK or a dropped parent deletes them
silently, a replaced child loses its own FKs and rows, CREATE TABLE IF NOT EXISTS
changes nothing, and errors carry the probe's texts (serverless ones with the
QueryExecution.scala:2504 frame). information_schema is answered by sqlite.
"""
import ast
import copy
import json
import logging
import re
import sqlite3
import sys
import textwrap
import threading
import types
from pathlib import Path

import agent_helpers as ah
from notebook_source_util import notebook_concat_source

CATALOG = "skyline"
_SPARK_TYPE_NAMES = ("StructType", "StructField", "StringType", "LongType", "BooleanType", "IntegerType",
                     "DoubleType", "FloatType", "DateType", "TimestampType", "DecimalType")


class _SparkType:
    def __init__(self, *args, **kwargs):
        self.args = args


def install_fake_pyspark_types():
    types_mod = sys.modules.get("pyspark.sql.types")
    if types_mod is None:
        types_mod = types.ModuleType("pyspark.sql.types")
        for name in _SPARK_TYPE_NAMES:
            setattr(types_mod, name, type(name, (_SparkType,), {}))
        sql_mod = sys.modules.setdefault("pyspark.sql", types.ModuleType("pyspark.sql"))
        sys.modules.setdefault("pyspark", types.ModuleType("pyspark")).sql = sql_mod
        sql_mod.types = types_mod
        sys.modules["pyspark.sql.types"] = types_mod
    for name in _SPARK_TYPE_NAMES:
        ah.__dict__.setdefault(name, getattr(types_mod, name))


install_fake_pyspark_types()
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_deploy")


def _pk(name):
    return {"name": name, "type": "BIGINT", "tags": "primary_key", "description": f"Primary key {name}",
            "is_primary_key": True, "column_name": name, "foreign_key_to": ""}


def _col(name, ctype="STRING", fk="", tags="", glossary="", description=None):
    return {"name": name, "type": ctype, "tags": tags, "description": description or f"Column {name}",
            "business_glossary_term": glossary, "foreign_key_to": fk, "column_name": name}


def _product(name, pk, attrs, subdomain="", description=None, data_type="master_data"):
    return {"name": name, "subdomain": subdomain, "primary_key": pk, "table_name": name, "data_type": data_type,
            "description": description or f"Product {name}", "tags": "", "type": "entity",
            "attributes": [_pk(pk)] + attrs}


def base_model():
    return {
        "agent_version": "5.1.3",
        "model": {
            "name": "Skyline Air",
            "version": "1",
            "model_conventions": {"data_asset_naming_convention": "snake_case", "primary_key_suffix": "_id"},
            "domains": [
                {"name": "crew", "division": "operations", "description": "Crew domain", "database_name": "crew",
                 "products": [
                     _product("member", "member_id", [_col("full_name", tags="pii=true", glossary="Crew Member Name")], subdomain="crew_records"),
                     _product("roster", "roster_id", [_col("member_id", "BIGINT", fk="crew.member.member_id"),
                                                      _col("roster_date", "DATE")], subdomain="crew_scheduling"),
                     _product("base", "base_id", [_col("base_code")], subdomain="crew_records"),
                 ]},
                {"name": "flight", "division": "operations", "description": "Flight domain", "database_name": "flight",
                 "products": [
                     _product("scheduled_flight", "scheduled_flight_id", [
                         _col("duty_member_id", "BIGINT", fk="crew.member.member_id"),
                         _col("aircraft_id", "BIGINT", fk="fleet.aircraft.aircraft_id"),
                         _col("crew_shift_code", "BIGINT"),
                         _col("flight_number", tags="classification=internal", glossary="Flight Number"),
                     ], subdomain="flight_ops"),
                 ]},
                {"name": "fleet", "division": "operations", "description": "Fleet domain", "database_name": "fleet",
                 "products": [
                     _product("aircraft", "aircraft_id", [_col("home_base_id", "BIGINT", fk="crew.base.base_id"),
                                                          _col("tail_number", glossary="Tail Number")], subdomain="fleet_assets"),
                     _product("maintenance", "maintenance_id", [_col("roster_id", "BIGINT", fk="crew.roster.roster_id"),
                                                                _col("work_order", tags="classification=internal")], subdomain="fleet_assets"),
                 ]},
            ],
            "metric_views": [
                metric_view("crew_roster_kpis", "crew", "roster", "crew", "roster"),
                metric_view("flight_crew_coverage", "flight", "scheduled_flight", "crew", "member"),
                metric_view("fleet_utilization", "fleet", "aircraft", "fleet", "aircraft"),
            ],
        },
    }


def metric_view(view_name, owner_domain, owner_product, schema, table, catalog=CATALOG):
    sql = (f"CREATE OR REPLACE VIEW `{catalog}`.`_metrics`.`{view_name}`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n"
           f"version: 1.1\nsource: \"`{catalog}`.`{schema}`.`{table}`\"\ndimensions:\n  - name: \"All Records\"\n    expr: \"1\"\n"
           f"measures:\n  - name: \"Row Count\"\n    expr: COUNT(1)\n$$")
    return {"view_name": view_name, "owner_domain": owner_domain, "owner_product": owner_product, "sql": sql,
            "description": f"{view_name} metrics", "dimensions_count": 1, "measures_count": 1}


def scoped_final_model():
    m = base_model()
    mdl = m["model"]
    crew = mdl["domains"][0]
    crew["description"] = "Crew domain, edited in scope"
    crew["products"] = [
        _product("crew_member", "crew_member_id", [_col("full_name", tags="pii=true", glossary="Crew Member Name")], subdomain="crew_records"),
        _product("roster", "roster_id", [_col("crew_member_id", "BIGINT", fk="crew.crew_member.crew_member_id"),
                                         _col("roster_date", "DATE"), _col("duty_hours", "DOUBLE")], subdomain="crew_scheduling"),
        _product("crew_shift", "crew_shift_id", [_col("shift_label")], subdomain="crew_scheduling"),
    ]
    sched = mdl["domains"][1]["products"][0]
    sched["attributes"][1]["foreign_key_to"] = "crew.crew_member.crew_member_id"
    sched["attributes"][3]["foreign_key_to"] = "crew.crew_shift.crew_shift_id"
    sched["attributes"].append(_col("rostered_roster_id", "BIGINT", fk="crew.roster.roster_id", tags="classification=internal"))
    mdl["domains"][2]["products"][0]["attributes"][1]["foreign_key_to"] = ""
    coverage = mdl["metric_views"][1]
    coverage["sql"] = coverage["sql"].replace("`crew`.`member`", "`crew`.`crew_member`")
    return m


def scoped_facts():
    def delta(kind, domain, product, attribute=None, old="", new="", view=None):
        return {"kind": kind, "domain": domain, "product": product, "attribute": attribute, "old_fk": old, "new_fk": new,
                "view_name": view, "cause": ah._VIBE_SCOPE_PERMIT_CAUSES[kind]}
    return {
        "mode": "domains", "label": "Some Domains", "entries": ["crew"], "operation": VOV,
        "changed_in_scope_products": ["crew.crew_member", "crew.roster", "crew.crew_shift"],
        "preserved_products": ["flight.scheduled_flight", "fleet.aircraft", "fleet.maintenance"],
        "permitted_deltas": [
            delta("P1", "flight", "scheduled_flight", "duty_member_id", "crew.member.member_id", "crew.crew_member.crew_member_id"),
            delta("P2", "fleet", "aircraft", "home_base_id", "crew.base.base_id", ""),
            delta("P3", "flight", "scheduled_flight", "crew_shift_code", "", "crew.crew_shift.crew_shift_id"),
            delta("P4", "flight", "scheduled_flight", "rostered_roster_id", "", "crew.roster.roster_id"),
            delta("P5", "flight", "scheduled_flight", view="flight_crew_coverage"),
        ],
    }


def base_physical_tables():
    tables = {}
    for domain in base_model()["model"]["domains"]:
        for product in domain["products"]:
            tables[f"{CATALOG}.{domain['database_name']}.{product['table_name']}"] = [a["name"] for a in product["attributes"]]
    tables[f"{CATALOG}.crew.team_notes"] = ["note_id"]
    tables[f"{CATALOG}.flight.ops_scratch"] = ["scratch_id"]
    return tables


class Row(tuple):
    def __new__(cls, values, names=()):
        obj = super().__new__(cls, values)
        obj._names = dict(zip(names, values))
        return obj

    def __getattr__(self, item):
        names = object.__getattribute__(self, "_names")
        if item in names:
            return names[item]
        raise AttributeError(item)

    def __getitem__(self, key):
        if isinstance(key, str):
            return object.__getattribute__(self, "_names")[key]
        return super().__getitem__(key)


class _Writer:
    def __init__(self, spark, rows):
        self.spark, self.rows = spark, rows

    def mode(self, *_a, **_k):
        return self

    def option(self, *_a, **_k):
        return self

    def saveAsTable(self, name):
        self.spark.record(f"SAVE AS TABLE {name} rows={len(self.rows)}")
        if str(name).lower().endswith("_metamodel.product"):
            with self.spark._lock:
                self.spark.metamodel_products.update((str(r.get("domain") or "").lower(), str(r.get("product") or "").lower())
                                                     for r in self.rows if isinstance(r, dict))


class _DF:
    def __init__(self, spark, rows):
        self.spark, self.rows = spark, rows
        self.write = _Writer(spark, rows)

    def collect(self):
        return list(self.rows)


class FakeSpark:
    _SHOW_TABLES = re.compile(r"^SHOW\s+(?:TABLES|VIEWS)\s+IN\s+`([^`]+)`\.`([^`]+)`", re.I)
    _INFO_TABLES = re.compile(r"FROM\s+`([^`]+)`\.information_schema\.tables", re.I)
    _INFO_COLUMNS = re.compile(r"FROM\s+`([^`]+)`\.information_schema\.columns", re.I)
    _IN_LIST = re.compile(r"LOWER\(table_schema\)\s+(?:IN\s*\(([^)]*)\)|=\s*'([^']*)')", re.I)
    _TABLE_IN = re.compile(r"LOWER\(table_name\)\s+IN\s*\(([^)]*)\)", re.I)
    _CREATE_VIEW = re.compile(r"CREATE\s+(?:OR\s+REPLACE\s+)?VIEW\s+`([^`]+)`\.`_metrics`\.`([^`]+)`", re.I)
    _CREATE_TABLE = re.compile(r"^CREATE\s+(OR\s+REPLACE\s+TABLE|TABLE\s+IF\s+NOT\s+EXISTS)\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`", re.I)
    _ADD_COLUMNS = re.compile(r"^ALTER\s+TABLE\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s+ADD\s+COLUMNS\s*\((.*)\)\s*;?\s*$", re.I | re.S)
    _DROP_TABLE = re.compile(r"^DROP\s+TABLE\s+IF\s+EXISTS\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`", re.I)
    _COLUMN_LINE = re.compile(r"^\s*`([^`]+)`\s+\S", re.M)

    def __init__(self, tables=None, views=None, catalogs=(CATALOG,), missing_catalogs=()):
        self.tables = {k.lower(): [c.lower() for c in v] for k, v in (tables or {}).items()}
        self.views = {v.lower() for v in (views or [])}
        self.catalogs = [c.lower() for c in catalogs]
        self.missing_catalogs = {c.lower() for c in missing_catalogs}
        self.metamodel_products = set()
        self.statements = []
        self._lock = threading.Lock()

    def _simulate(self, text):
        m = self._CREATE_TABLE.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(2, 3, 4))
            body = text.split("(", 1)[1] if "(" in text else ""
            cols = [c.lower() for c in self._COLUMN_LINE.findall(body)]
            with self._lock:
                if m.group(1).upper().startswith("OR") or fqn not in self.tables:
                    self.tables[fqn] = cols
            return
        m = self._ADD_COLUMNS.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(1, 2, 3))
            with self._lock:
                if fqn not in self.tables:
                    raise RuntimeError(f"[TABLE_OR_VIEW_NOT_FOUND] {fqn}")
                cols = re.findall(r"`([^`]+)`\s+\S", m.group(4))
                existing = [col for col in cols if col.lower() in self.tables[fqn]]
                if existing:
                    raise RuntimeError(field_exists_text(existing[0], [(c, "BIGINT") for c in self.tables[fqn]]))
                self.tables[fqn].extend(col.lower() for col in cols)
            return
        m = self._DROP_TABLE.match(text)
        if m:
            with self._lock:
                self.tables.pop(".".join(x.lower() for x in m.group(1, 2, 3)), None)

    def record(self, stmt):
        with self._lock:
            self.statements.append(stmt)

    def createDataFrame(self, data, schema=None):
        return _DF(self, data)

    @staticmethod
    def _quoted(text):
        return [t.strip().strip("'").lower() for t in (text or "").split(",") if t.strip()]

    def sql(self, stmt):
        text = str(stmt).strip()
        self.record(text)
        upper = text.upper()
        self._simulate(text)
        m = self._CREATE_VIEW.search(text)
        if m:
            with self._lock:
                self.views.add(m.group(2).lower())
            return _DF(self, [])
        if upper.startswith("SHOW CATALOGS"):
            return _DF(self, [Row((c,), ("catalog",)) for c in self.catalogs])
        m = self._SHOW_TABLES.match(text)
        if m:
            cat, schema = m.group(1).lower(), m.group(2).lower()
            if schema == "_metrics":
                return _DF(self, [Row(("_metrics", v, False), ("database", "tableName", "isTemporary")) for v in sorted(self.views)])
            rows = []
            for fqn in sorted(self.tables):
                c, s, t = fqn.split(".")
                if c == cat and s == schema:
                    rows.append(Row((s, t, False), ("database", "tableName", "isTemporary")))
            return _DF(self, rows)
        m = self._INFO_TABLES.search(text) or self._INFO_COLUMNS.search(text)
        if m:
            cat = m.group(1).lower()
            if cat in self.missing_catalogs:
                raise RuntimeError(f"[NO_SUCH_CATALOG_EXCEPTION] Catalog '{cat}' was not found.")
            sm = self._IN_LIST.search(text)
            schemas = set(self._quoted(sm.group(1))) | ({sm.group(2).lower()} if sm and sm.group(2) else set()) if sm else None
            tm = self._TABLE_IN.search(text)
            only_tables = set(self._quoted(tm.group(1))) if tm else None
            rows = []
            is_columns = bool(self._INFO_COLUMNS.search(text))
            for fqn, cols in sorted(self.tables.items()):
                c, s, t = fqn.split(".")
                if c != cat or (schemas is not None and s not in schemas) or (only_tables is not None and t not in only_tables):
                    continue
                if is_columns and "column_name" in text.lower():
                    if "table_schema" in text.lower().split("from")[0]:
                        rows.extend(Row((s, t, col)) for col in cols)
                    else:
                        rows.extend(Row((t, col)) for col in cols)
                else:
                    rows.append(Row((s, t)))
            if not is_columns and schemas is not None and "_metrics" in schemas:
                rows.extend(Row(("_metrics", v)) for v in sorted(self.views))
            return _DF(self, rows)
        if "_metamodel`.`product`" in text and upper.startswith("SELECT"):
            prods = set(self.metamodel_products)
            for fqn in self.tables:
                _c, s, t = fqn.split(".")
                prods.add((s, t))
            return _DF(self, [Row(p) for p in sorted(prods)])
        return _DF(self, [])


PROBE = json.loads((Path(__file__).resolve().parent / "fixtures" / "v514_uc_probe_errors.json").read_text())
RUNCOMMAND_FRAME = "\tat org.apache.spark.sql" + PROBE["serverless_runCommand_context_2504"].split(" | ")[0]
_UC_DATA_TYPE = {"bigint": "LONG", "int": "INT", "string": "STRING", "double": "DOUBLE", "date": "DATE", "timestamp": "TIMESTAMP",
                 "boolean": "BOOLEAN"}


def field_exists_text(column, columns):
    struct = ", ".join(f"{name}: {ctype.upper()}" for name, ctype in columns)
    return (f"[FIELD_ALREADY_EXISTS] Cannot add column, because `{column}` already exists in \"STRUCT<{struct}>\". "
            f"SQLSTATE: 42710; line 1 pos 0")


def constraint_exists_text(name, column, parent, parent_column):
    pc, ps, pt = parent.split(".")
    return (f"[DELTA_CONSTRAINT_ALREADY_EXISTS] Constraint '{name}' already exists. Please delete the old constraint first.\n"
            f"Old constraint:\n{name} FOREIGN KEY (`{column}`) REFERENCES `{pc}`.`{ps}`.`{pt}` (`{parent_column}`)\n")


def table_not_found_text(fqn):
    cat, schema, table = fqn.split(".")
    return PROBE["warehouse"]["D01_fk_parent_missing"].replace("vibe_dryrun_smoke_v1", cat).replace(
        "vs_probe_v514_a", schema).replace("`parent`", f"`{table}`")


def fk_type_mismatch_text(column, child_type, parent_column, parent_type):
    return (f"The foreign key child column type does not match the parent column type. Foreign key child column `{column}` has "
            f"type {_UC_DATA_TYPE.get(child_type.lower(), child_type.upper())} and parent column `{parent_column}` has type "
            f"{_UC_DATA_TYPE.get(parent_type.lower(), parent_type.upper())}.")


class UCError(Exception):
    def __init__(self, message="", condition=None, sqlstate=None):
        super().__init__(message)
        self._condition, self._sqlstate = condition, sqlstate

    def getCondition(self):
        return self._condition

    def getErrorClass(self):
        return self._condition

    def getSqlState(self):
        return self._sqlstate


def serverless_error(head, condition=None, sqlstate=None):
    return UCError(f"{head}\n\nJVM stacktrace:\norg.apache.spark.sql.AnalysisException\n{RUNCOMMAND_FRAME}\n"
                   f"\tat java.base/java.lang.Thread.run(Thread.java:840)", condition, sqlstate)


class UCSpark(FakeSpark):
    _UC_CREATE = re.compile(r"^CREATE\s+(OR\s+REPLACE\s+TABLE|TABLE\s+IF\s+NOT\s+EXISTS|TABLE)\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s*\((.*)\)",
                            re.I | re.S)
    _UC_DEF = re.compile(r"`([^`]+)`\s+([A-Za-z_]\w*(?:\([^)]*\))?)")
    _UC_PK = re.compile(r"CONSTRAINT\s+`?(\w+)`?\s+PRIMARY\s+KEY\s*\(([^)]*)\)", re.I)
    _UC_ADD_FK = re.compile(r"^ALTER\s+TABLE\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s+ADD\s+CONSTRAINT\s+`([^`]+)`\s+FOREIGN\s+KEY\s*\(`([^`]+)`\)\s*"
                            r"REFERENCES\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s*\(`([^`]+)`\)", re.I)
    _UC_DROP_FK = re.compile(r"^ALTER\s+TABLE\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s+DROP\s+CONSTRAINT\s+IF\s+EXISTS\s+`([^`]+)`", re.I)
    _UC_INFO = re.compile(r"`([^`]+)`\.information_schema\.(\w+)", re.I)
    _UC_CATALOG_COLUMN = {"columns": "table_catalog", "tables": "table_catalog"}

    def __init__(self, serverless=True, **kwargs):
        super().__init__(**kwargs)
        self.serverless = serverless
        self.uc = {}

    @classmethod
    def from_model(cls, root, catalog=CATALOG, extra_tables=None, **kwargs):
        spark = cls(**kwargs)
        mdl = root["model"]
        types = {}
        for domain in mdl["domains"]:
            for product in domain["products"]:
                for attr in product["attributes"]:
                    if attr.get("is_primary_key"):
                        types[f"{domain['name']}.{product['name']}.{attr['name']}"] = ah.map_data_type(attr["type"])
        for domain in mdl["domains"]:
            for product in domain["products"]:
                fqn = f"{catalog}.{domain['database_name']}.{product['table_name']}".lower()
                cols = [(a["name"].lower(), (types.get(a.get("foreign_key_to")) or ah.map_data_type(a["type"])).lower())
                        for a in product["attributes"]]
                spark._put(fqn, cols, (f"pk_{product['table_name']}", [product["primary_key"].lower()]))
        for domain in mdl["domains"]:
            for product in domain["products"]:
                fqn = f"{catalog}.{domain['database_name']}.{product['table_name']}".lower()
                for attr in product["attributes"]:
                    fk = attr.get("foreign_key_to") or ""
                    if fk.count(".") == 2:
                        pdom, pprod, pcol = fk.split(".")
                        pdb = next(d["database_name"] for d in mdl["domains"] if d["name"] == pdom)
                        spark.uc[fqn]["fks"][f"fk_{domain['name']}_{product['name']}_{attr['name']}"] = (
                            attr["name"].lower(), f"{catalog}.{pdb}.{pprod}".lower(), pcol.lower())
        for fqn, cols in (extra_tables or {}).items():
            spark._put(fqn.lower(), [(c.lower(), "bigint") for c in cols], None)
        return spark

    def _put(self, fqn, cols, pk, rows=0):
        self.uc[fqn] = {"cols": list(cols), "pk": pk, "fks": {}, "rows": rows}
        self.tables[fqn] = [c for c, _t in cols]

    def _raise(self, head, condition=None, sqlstate=None):
        if self.serverless:
            raise serverless_error(head, condition, sqlstate)
        raise UCError(head, condition, sqlstate)

    def fks(self, fqn):
        return dict(self.uc[fqn.lower()]["fks"])

    def insert_rows(self, fqn, count=1):
        self.uc[fqn.lower()]["rows"] += count

    def _drop_inbound(self, parent, keep=None):
        for fqn, table in self.uc.items():
            if fqn == parent:
                continue
            for name, (_col, target, _pcol) in list(table["fks"].items()):
                if target == parent and not keep:
                    del table["fks"][name]

    def _uc_ddl(self, text):
        m = self._UC_CREATE.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(2, 3, 4))
            body = m.group(5)
            cols = [(c.lower(), t.lower()) for c, t in self._UC_DEF.findall(body)]
            pk_m = self._UC_PK.search(body)
            pk = (pk_m.group(1).lower(), [c.strip(" `").lower() for c in pk_m.group(2).split(",")]) if pk_m else None
            kind = m.group(1).upper().split()[0:2]
            if fqn in self.uc and kind == ["TABLE", "IF"]:
                return True
            if fqn in self.uc and kind == ["TABLE"]:
                self._raise(f"[TABLE_OR_VIEW_ALREADY_EXISTS] Cannot create table or view `{fqn}` because it already exists.",
                            "TABLE_OR_VIEW_ALREADY_EXISTS", "42P07")
            if fqn in self.uc:
                old_pk = self.uc[fqn]["pk"]
                self._drop_inbound(fqn, keep=old_pk is not None and pk is not None and old_pk == pk)
            self._put(fqn, cols, pk)
            return True
        m = self._UC_ADD_FK.match(text)
        if m:
            child, name, col = ".".join(x.lower() for x in m.group(1, 2, 3)), m.group(4).lower(), m.group(5).lower()
            parent, pcol = ".".join(x.lower() for x in m.group(6, 7, 8)), m.group(9).lower()
            if child not in self.uc:
                self._raise(table_not_found_text(child), "TABLE_OR_VIEW_NOT_FOUND", "42P01")
            if parent not in self.uc:
                self._raise(table_not_found_text(parent), "TABLE_OR_VIEW_NOT_FOUND", "42P01")
            if name in self.uc[child]["fks"]:
                old = self.uc[child]["fks"][name]
                self._raise(constraint_exists_text(name, old[0], old[1], old[2]), "DELTA_CONSTRAINT_ALREADY_EXISTS", "42710")
            ctype = dict(self.uc[child]["cols"]).get(col, "")
            ptype = dict(self.uc[parent]["cols"]).get(pcol, "")
            if ctype != ptype:
                self._raise(fk_type_mismatch_text(col, ctype, pcol, ptype), None, "XXKCM")
            self.uc[child]["fks"][name] = (col, parent, pcol)
            return True
        m = self._UC_DROP_FK.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(1, 2, 3))
            if fqn not in self.uc:
                self._raise(table_not_found_text(fqn), "TABLE_OR_VIEW_NOT_FOUND", "42P01")
            self.uc[fqn]["fks"].pop(m.group(4).lower(), None)
            return True
        m = self._ADD_COLUMNS.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(1, 2, 3))
            if fqn not in self.uc:
                self._raise(table_not_found_text(fqn), "TABLE_OR_VIEW_NOT_FOUND", "42P01")
            cols = [(c.lower(), t.lower()) for c, t in self._UC_DEF.findall(m.group(4))]
            present = dict(self.uc[fqn]["cols"])
            existing = [c for c, _t in cols if c in present]
            if existing:
                self._raise(field_exists_text(existing[0], self.uc[fqn]["cols"]), "FIELD_ALREADY_EXISTS", "42710")
            self.uc[fqn]["cols"].extend(cols)
            self.tables[fqn] = [c for c, _t in self.uc[fqn]["cols"]]
            return True
        m = self._DROP_TABLE.match(text)
        if m:
            fqn = ".".join(x.lower() for x in m.group(1, 2, 3))
            if fqn in self.uc:
                del self.uc[fqn]
                self.tables.pop(fqn, None)
                self._drop_inbound(fqn)
            return True
        return False

    def _info_db(self):
        db = sqlite3.connect(":memory:")
        db.execute("CREATE TABLE columns (table_catalog, table_schema, table_name, column_name, data_type, full_data_type, ordinal_position)")
        db.execute("CREATE TABLE tables (table_catalog, table_schema, table_name, table_type)")
        db.execute("CREATE TABLE table_constraints (constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, "
                   "table_name, constraint_type)")
        db.execute("CREATE TABLE key_column_usage (constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, "
                   "table_name, column_name, ordinal_position, position_in_unique_constraint)")
        db.execute("CREATE TABLE referential_constraints (constraint_catalog, constraint_schema, constraint_name, unique_constraint_catalog, "
                   "unique_constraint_schema, unique_constraint_name)")
        db.execute("CREATE TABLE constraint_column_usage (constraint_catalog, constraint_schema, constraint_name, table_catalog, "
                   "table_schema, table_name, column_name)")
        for fqn, table in self.uc.items():
            cat, schema, name = fqn.split(".")
            db.execute("INSERT INTO tables VALUES (?, ?, ?, 'MANAGED')", (cat, schema, name))
            for pos, (col, ctype) in enumerate(table["cols"]):
                db.execute("INSERT INTO columns VALUES (?, ?, ?, ?, ?, ?, ?)",
                           (cat, schema, name, col, _UC_DATA_TYPE.get(ctype, ctype.upper()), ctype, pos))
            if table["pk"]:
                pk_name, pk_cols = table["pk"]
                db.execute("INSERT INTO table_constraints VALUES (?, ?, ?, ?, ?, ?, 'PRIMARY KEY')", (cat, schema, pk_name, cat, schema, name))
                for pos, col in enumerate(pk_cols, start=1):
                    db.execute("INSERT INTO key_column_usage VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)", (cat, schema, pk_name, cat, schema, name, col, pos))
                    db.execute("INSERT INTO constraint_column_usage VALUES (?, ?, ?, ?, ?, ?, ?)", (cat, schema, pk_name, cat, schema, name, col))
            for fk_name, (col, parent, pcol) in table["fks"].items():
                pcat, pschema, ptable = parent.split(".")
                ppk = (self.uc.get(parent) or {}).get("pk")
                db.execute("INSERT INTO table_constraints VALUES (?, ?, ?, ?, ?, ?, 'FOREIGN KEY')", (cat, schema, fk_name, cat, schema, name))
                db.execute("INSERT INTO key_column_usage VALUES (?, ?, ?, ?, ?, ?, ?, 1, 1)", (cat, schema, fk_name, cat, schema, name, col))
                db.execute("INSERT INTO referential_constraints VALUES (?, ?, ?, ?, ?, ?)",
                           (cat, schema, fk_name, pcat, pschema, ppk[0] if ppk else None))
                db.execute("INSERT INTO constraint_column_usage VALUES (?, ?, ?, ?, ?, ?, ?)", (cat, pschema, fk_name, pcat, pschema, ptable, pcol))
        return db

    def _info(self, text):
        for cat in {c.lower() for c, _v in self._UC_INFO.findall(text)}:
            if cat in self.missing_catalogs:
                raise RuntimeError(f"[NO_SUCH_CATALOG_EXCEPTION] Catalog '{cat}' was not found.")

        def _scoped(m):
            view = m.group(2).lower()
            column = self._UC_CATALOG_COLUMN.get(view, "constraint_catalog")
            return f"(SELECT * FROM {view} WHERE {column} = '{m.group(1).lower()}')"

        cursor = self._info_db().execute(self._UC_INFO.sub(_scoped, text).replace("`", ""))
        names = [d[0] for d in cursor.description]
        return _DF(self, [Row(tuple(r), names) for r in cursor.fetchall()])

    def _uc_handles(self, text):
        return any(rx.match(text) for rx in (self._UC_CREATE, self._UC_ADD_FK, self._UC_DROP_FK, self._ADD_COLUMNS, self._DROP_TABLE))

    def sql(self, stmt):
        text = str(stmt).strip()
        if "information_schema" in text and "information_schema.tables" not in text:
            self.record(text)
            return self._info(text)
        if self._uc_handles(text):
            self.record(text)
            with self._lock:
                self._uc_ddl(text)
            return _DF(self, [])
        return super().sql(stmt)


def flat_widgets(model, logger=LOG, spark=None, facts=None, dry_run=False, statement_model=None,
                 volume="/Volumes/skyline/_metamodel/vol_root/business/skyline_air/v2/mvm"):
    d, p, a, mv = ah.model_to_widgets_flat(copy.deepcopy(model))
    stmt_views = (statement_model or model)["model"]["metric_views"]
    config = {
        "TARGET_CATALOG": CATALOG, "TAG_PREFIX": "", "TAG_SUFFIX": "", "SCHEMA_SUFFIX": "", "CATALOG_PREFIX": "",
        "CATALOG_SUFFIX": "", "CATALOGING_STYLE": "one_catalog", "MAX_RETRIES": 1, "AI_QUERY_TIMEOUT_SECONDS": 30,
        "MAX_CONCURRENT_BATCHES": 4, "TARGET_VOLUME": volume, "MODEL_SCOPE": "mvm", "BUSINESS_NAME": "skyline_air",
        "MODEL_CONVENTIONS": {"data_asset_naming_convention": "snake_case", "tag_prefix": ""},
        "PROMPT_VARIABLES": {"business_config": {"business": "skyline_air", "version": "2"},
                             "model_conventions_config": {"table_id_type": "BIGINT"}},
        "MAIN_METAMODEL_TABLES": {"DOMAIN": f"{CATALOG}._metamodel.domain", "PRODUCT": f"{CATALOG}._metamodel.product"},
    }
    wv = {"spark": spark, "logger": logger, "config": config, "business_name": "skyline_air",
          "domains": d, "products": p, "attributes": a, "metric_views": mv,
          "current_version": "2", "base_version_for_review": "1", "model_scope": "mvm", "operation": VOV, "vibe_writer": None,
          "ai_agent": None, "metric_view_count": len(stmt_views), "_dry_run": dry_run, "deployment_catalog": CATALOG,
          "metric_view_statements": [v["sql"] for v in stmt_views],
          "_metric_view_records": [dict(v) for v in stmt_views]}
    if facts is not None:
        wv["_vibe_scope_facts"] = facts
    return wv


def normalize_artifact(text):
    return re.sub(r"Generated on: [0-9:\- ]+", "Generated on: <ts>", text)


class _Upload:
    def __init__(self, store):
        self.store = store

    def upload(self, file_path=None, contents=None, overwrite=True):
        data = contents.read()
        self.store[file_path] = json.loads(data.decode("utf-8") if isinstance(data, bytes) else data)


class FakeWorkspace:
    def __init__(self, store):
        self.files = _Upload(store)


def run_deploy_steps(wv, spark, model_root, patch):
    artifacts, uploads = {}, {}
    files = {f"{wv['config']['TARGET_VOLUME']}/model.json": json.dumps(model_root)}

    def _write(content, path, logger=None):
        artifacts[path] = content

    def _read(path, client=None):
        if path in uploads:
            return json.dumps(uploads[path])
        return files.get(path)

    patch("write_to_dbfs", _write)
    patch("read_file_for_ddl", _read)
    patch("WorkspaceClient", lambda *a, **k: FakeWorkspace(uploads))
    patch("_check_physical_deployment_clash", lambda *a, **k: None)
    wv["spark"] = spark
    marks = {}
    ah.step_create_physical_schema_stage1(wv)
    marks["stage1"] = len(spark.statements)
    if not wv.get("_dry_run"):
        ah.step_apply_foreign_keys(wv)
        marks["fk"] = len(spark.statements)
        track3 = wv.copy()
        ah.step_apply_tags(track3)
        marks["tags"] = len(spark.statements)
        ah.step_apply_metric_views(track3)
        marks["mv"] = len(spark.statements)
        wv["_track3"] = track3
    return {"statements": list(spark.statements), "marks": marks, "artifacts": artifacts, "uploads": uploads}


def ddl_only(statements):
    keep = ("CREATE", "ALTER", "DROP")
    return [s for s in statements if s.upper().startswith(keep)]


def nested_install_functions(source=None):
    source = source or notebook_concat_source()
    tree = ast.parse(source)
    lines = source.splitlines(keepends=True)
    main = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "main")
    deploy = next(n for n in ast.walk(main) if isinstance(n, ast.FunctionDef) and n.name == "_run_deploy_model")
    out = {}
    for name in ("_generate_ddl_from_enriched_json", "_run_physical_model_creation"):
        fn = next(n for n in ast.walk(deploy) if isinstance(n, ast.FunctionDef) and n.name == name)
        out[name] = textwrap.dedent("".join(lines[fn.lineno - 1:fn.end_lineno]))
    return out


def load_install_harness(source=None):
    fns = nested_install_functions(source)
    body = textwrap.indent(fns["_generate_ddl_from_enriched_json"] + "\n" + fns["_run_physical_model_creation"], "    ")
    harness = (
        "def _install_harness(widgets_values, spark, data_model, deployment_catalog, _deploy_all_cats, _parsed_root,\n"
        "                     _vs_install, _thread_safe_print, _deploy_warn, _dlog, execute_ddl_statements,\n"
        "                     execute_metric_views_in_parallel_no_halt, _check_physical_deployment_clash, w):\n"
        "    physical_result = {'success': False, 'domains': 0, 'tables': 0, 'fks': 0, 'tags': 0, 'metrics': 0, 'error': None}\n"
        "    _vw = None\n"
        "    max_concurrent_batches = 4\n"
        "    _resolved_model_json_path = None\n"
        "    model_folder = '/Volumes/skyline/_metamodel/vol_root/business/skyline_air/v2/mvm'\n"
        "    logger = _dlog\n"
        + body +
        "\n    return _generate_ddl_from_enriched_json, _run_physical_model_creation, physical_result\n"
    )
    ns = dict(ah.__dict__)
    exec(compile(harness, "<install-harness>", "exec"), ns)
    return ns["_install_harness"]


class InstallRecorder:
    def __init__(self):
        self.phases = []

    def execute_ddl_statements(self, spark, statements, mode="serial", logger=None, file_label="", max_workers=20, is_fk_file=False,
                               on_failure=None):
        stmts = list(statements)
        self.phases.append((file_label, stmts))
        for stmt in stmts:
            spark.sql(stmt)
        return len(stmts)

    def execute_metric_views(self, spark, statements, logger, max_workers=20, concurrency_manager=None, progress_callback=None, timeout_per_stmt=None):
        stmts = list(statements)
        self.phases.append(("metric_views", stmts))
        for stmt in stmts:
            spark.sql(stmt)
        return {"succeeded": len(stmts), "failed": [], "total": len(stmts)}

    def phase(self, label):
        return next((s for name, s in self.phases if name == label), [])


def run_install(model_root, spark, use_plan=True):
    data_model = copy.deepcopy(model_root["model"])
    data_model["_file_model_conventions"] = dict(data_model.get("model_conventions") or {})
    recorder = InstallRecorder()
    plan = ah._vibe_scope_install_plan(model_root, data_model, False, LOG) if use_plan and hasattr(ah, "_vibe_scope_install_plan") else None
    harness = load_install_harness()
    gen, run_phys, result = harness(
        {"cataloging_style": "one_catalog"}, spark, data_model, CATALOG, [CATALOG], model_root,
        plan, lambda m: LOG.info(m), lambda m: LOG.warning(m), LOG, recorder.execute_ddl_statements,
        recorder.execute_metric_views, lambda *a, **k: None, None)
    run_phys(copy.deepcopy(data_model))
    return recorder, result, plan
