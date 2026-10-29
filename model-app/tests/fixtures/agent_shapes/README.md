# Agent shapes

What a bundled agent notebook leaves behind in `_metamodel` and in `model.json`, for the drift tests of an agent change (`tests/test_app/test_drift_agent_upgrade.py`). Cell numbers count every cell of the notebook, markdown included, from 0.

Nothing here is a guess about what the app expects. `capture.py` lifts the agent's own writers out of the notebook with `ast` and runs them on plain Python: `VibeWriter._build_insert_sql` builds the `business` INSERT, and the install registrar `_metamodel_registry_records` builds the domain, product and attribute rows. `agent_<version>.json` is its output. The test module recaptures the vendored notebook and fails when the committed file differs, so vendoring another agent forces a review of this folder.

Regenerate after a re-vendor (the 4.9.9 notebook is no longer vendored; it is `src/app/vendored/agent/vibe_modelling_agent_v4.9.9.ipynb` in the app releases before 0.9.0, e.g. 0.8.0):

```
python tests/fixtures/agent_shapes/capture.py src/app/vendored/agent/vibe_modelling_agent_v5.3.3.ipynb tests/fixtures/agent_shapes/agent_5_3_3.json
```

## Files

| File | What it is | Source |
|---|---|---|
| `capture.py` | The extractor, and `AgentWriters` (the lifted writers the tests call) | - |
| `agent_5_3_3.json` | Shapes of agent 5.3.3 (release 0.8.0), sha256 `002c2753...` of the vendored notebook | cells below |
| `agent_4_9_9.json` | Shapes of agent 4.9.9 (release 0.8.0), sha256 `90595dda...`, the notebook the app bundled before 5.3.3 | cells below |
| `model_json_4_9_9.json` | A `model.json` as 4.9.9 writes it (a new base model, v1) | 4.9.9 cell 186 |
| `model_json_5_3_3_base.json` | A base-model `model.json` as 5.3.3 writes it: adds `lineage`, a `steward` per product | 5.3.3 cell 192 |
| `model_json_5_3_3_vibe.json` | A vibe-iterate `model.json` as 5.3.3 writes it: adds `input_outcomes` | 5.3.3 cells 192, 123 |
| `model_json_5_3_3_vibe_stale.json` | A vibe-iterate `model.json` whose run found a newer version (`lineage`: `head_at_start` 1, `head_at_write` 2, `stale` true, one intervening version; output v3) | 5.3.3 cell 123 (`_run_lineage_block`, `_run_lineage_intervening`) |
| `model_json_flat.json` | The flat form (`{"domains": [...]}`, no envelope) that Delta-assembled payloads and external tools use; no notebook writer emits it | `import_model.model_payload`, `model_sync._unwrap_model_envelope` |

`tests/fixtures/real_agent_model_sample.json` is the captured real output of agent 0.7.1 (wrapped, `agent_version` is the release); the tests use it as the pre-0.8.0 shape.

## Where each field comes from

| Field | 5.3.3 | 4.9.9 |
|---|---|---|
| `business` columns (23) | `TABLE_BUSINESS_SCHEMA`, cell 86 | cell 84, identical |
| `domain`, `product`, `attribute` table columns | `TABLE_*_SCHEMA`, cell 86 | cell 84, identical |
| `deploy_status` column | `_METAMODEL_BUSINESS_MIGRATION_COLUMNS`, cell 118: added by `ALTER TABLE` the first time 5.3.3 touches a table; NULL on older rows | absent |
| First row of a run | dict passed to `insert_business_row`, cell 124: `completed_percent` 0.0, `processing_status` `pending`, every session column NULL | cell 120, identical keys and values |
| Row after `initialize_session` | `VibeWriter.initialize_session`, cell 116: `session_id`, `session_started_at`, `last_updated_at`, `session_json` and `results_json` `{}`, status `done` | cell 114, identical |
| Row while running | `_update_session_ready`, cell 116: `completed_percent` up to 99.0, status `ready` when the app is the consumer | cell 114, identical |
| Row when finished | `_finalize_session`, cell 116: `completed_percent` 100.0, `completion_date`, `results_json`; `processing_status` is `ready` while the app is the consumer and has not acknowledged, `done` after (the fixtures use `done`; `ready` is built at 99.0 percent, before the completion date) | cell 114, identical |
| Row after an install | dict passed to `insert_deployed_business_row`, cell 118: no session columns, 100.0, `done`; `deploy_status` `installed` (`dry_run` for a Dry Run) set by `_set_metamodel_deploy_status` | cell 204, identical keys; no `deploy_status` |
| `domain` rows of a run | final merge `StructType`, cell 194: eight columns, no `catalog`, no `tags` (both NULL) | cell 188, identical |
| `product` and `attribute` rows of a run | final merge `StructType`, cell 194 | cell 188, identical |
| Rows of an install | `_metamodel_registry_records` and `_METAMODEL_RECORD_COLUMNS`, cell 118: domain rows carry `catalog` and `tags`. The captured rows are the bootstrap registration's shape (`names=None`, cell 124); the real install passes a `names` mapping (cell 210, near line 1676) for each domain's catalog, table and column names, the primary key and column types, so installs with a catalog per domain, a schema prefix or key types differ from them. With the version installed in another catalog too, the install keeps that registration: one business row and one set of domain rows per install catalog (`install-registry-keeps-deployment`) | inline in cell 204 (from the `DELETE` at line 1662): deletes the version's rows in all four tables, whatever the catalog, and inserts its own, so a second install replaces the first registration. Not lifted, so the tests have no 4.9.9 install rows |
| `business` value | `business_name.strip().title()`, cell 124 (`Acme_Co`) | same |
| `version`, `model_scope` | bare number (`1`), short scope (`mvm`) | same |
| `model.json` root | `model_json_root`, cell 192: `agent_version`, `release_version`, `lineage`, `model_requirements`, `vreq_adherence_pct`, `native_quality_pct`, `vov_quality_pct`, `_vibe_session_metadata`, `model`; `_vibe_scope`, `entity_changes`, `input_outcomes` only when present | cell 186: the same without `lineage` and the three optional blocks |
| `model` block, domain, product, attribute keys | `data_model`, `domain_obj`, `product_obj` and `_modeljson_attr_obj`, cell 192: product adds `steward`; attribute adds `steward` when set. `user_removed_fk` (and its flat variants) are spread in from `_user_removed_fk_fields` (cell 66) when a user removed a foreign key; `capture.py` does not see a spread of a call, and the fixtures have none | cell 186 |
| `lineage` | `_run_lineage_block`, cell 123 | absent |
| `input_outcomes` entries (`item_id`, `target`, `status`, `vreq_ids`, `reason`) | `_vibe_input_outcomes`, cell 123 | absent |
| Volume layout | nested `v{N}/{scope}/model.json` (4.9.8 on), legacy flat `{scope}_v{N}/` for older rows: `model_sync._version_root_candidates` | same |

## Sample values

Sample values (business `Acme_Co`, two domains, three products, nine attributes, two foreign keys) are made up. Which keys a row or file has comes from the notebook; the values do not.

## What is not captured

The `UPDATE` statements that move a run's row between states are Spark SQL, so they are not run. The test module applies their effect from this table, and a pin test checks that each `SET` clause is still in the notebook source (`capture.STATE_UPDATES`). The install registrar's `DELETE`, `UPDATE` and `INSERT` sequence is emulated in the test module (`register_install_5_3_3`) from cell 118. `emulated_sources` in each JSON file holds a sha256 of the source of every function that is emulated by hand (the registrar and its helpers, the migration, the three `VibeWriter` UPDATE methods); the pin test fails when one changes, and its message names the function to re-review.
