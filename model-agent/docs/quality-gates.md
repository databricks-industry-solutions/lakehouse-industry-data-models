# Quality Gates — Vibe Modelling Agent

This document enumerates every quality gate that runs between the first LLM call and the final `Session Ended` event. Gates are ordered by pipeline stage so you can trace exactly what a model has passed before any row of sample data touches disk.

Unless noted, gates are **blocking at the gate's scope** — e.g. a failed FK type-compatibility check rejects that FK, a failed architect gate forces another iteration. Gates that emit `WARNING` / `INFO` record findings into one of two sinks:

- **Hard rejection** — the current LLM response is discarded and a retry fires (`smart_worker_loop`).
- **Next-Vibes queue** — `NextVibesIssueCollector` (`/agent/.../NEXT_VIBES_*.md`) captures the issue with severity `BLOCKING` / `SAFE_IGNORE` / `INFO` so the model's next iteration can address it.

Every rule carries a stable ID (`GEN-RUL-*`, `FK-RUL-*`, `ATT-RUL-*`, `REL-RUL-*`, `TAG-RUL-*`, `NAME-RUL-*`, `PRD-RUL-*`, `G##-R###`). Searching the codebase for a rule ID returns both the enforcement site and the rule description.

---

## 0. Pre-flight — Prompt & Sanity Audits

Before any model-generation LLM call, the agent self-audits its own prompt library.

| Gate | Function | What it asserts | Failure mode |
|---|---|---|---|
| **Prompt placeholder audit** | `audit_prompt_templates(PROMPT_TEMPLATES)` | Every `{placeholder}` in every prompt template is either filled at render time or in the known-safe whitelist. Catches stale placeholders left behind after prompt refactors. | Prints `[Sanity] audit_prompt_templates: WARN — <msg>`. Non-blocking (run continues); surfaces as stdout for operator triage. |
| **Prompt smoke-render** | `smoke_render_all_prompts(PROMPT_TEMPLATES)` | Every prompt renders to a non-empty string with the default test payload. Catches format-string errors, KeyError on missing keys, `.format()` escape bugs (`{{…}}`). | Same WARN pattern. Non-blocking. |
| **Signoff checks** | `run_signoff_checks(widgets_values)` | Calls 3 sub-validators: industry-vocabulary alignment, org-chart alignment, division-ratio sanity. Reports issues grouped by category. | Issues are *reported*, not blocking. Operator decides whether to proceed. |

**Questions these gates answer:**
1. Will any LLM call fail at render time with a cryptic `KeyError`? → No, smoke-rendered.
2. Is the business-context widget input wildly misaligned with the chosen industry vocabulary? → Flagged up-front, not discovered mid-pipeline.
3. Does the user's claimed division breakdown (Operations/Business/Corporate) make ratio sense for the declared scope? → Flagged.

---

## 1. Business Context Generation (Step 1)

| Gate | Function | What it asserts | Failure mode |
|---|---|---|---|
| **BUSINESS_CONTEXT_PROMPT honesty** | `smart_worker_loop` around `BUSINESS_CONTEXT_PROMPT` | LLM returns the required 12 fields (industry_alignment, core_business_processes, data_domains, operational_systems_of_records, …); honesty score ≥ `min_honesty_score_threshold` (MVM default 40-65, ECM 50-80). | Retries up to `MAX_RETRIES` (default 3). On exhaust, falls back to widget-only extended context and emits `stage_warning`. |
| **Extended context completeness** | Internal invariant check | 12/12 extended-context fields populated. Phase F log line: `Extended context: 12/12 fields populated`. | 0 empty fields is expected; any empty field is logged with its name. |

**Questions answered:**
1. Did the LLM hallucinate or did it return a structurally valid business context? → Schema-validated.
2. Did the LLM admit what it doesn't know? → Honesty score compared against scope-specific threshold.
3. Are we missing any required framing field before we start generating domains? → Phase F logs exactly which fields are empty.

---

## 2. Domain Generation (Step 2) — Ensemble + Judge

The agent runs **3 parallel LLM calls** with distinct model + temperature pairs (gpt-oss-120b @ 0.0 / sonnet-4-5 @ 0.3 / sonnet-4-6 @ 0.5), then a 4th LLM call (the **judge**) synthesizes the winner.

| Gate | What it asserts | Failure mode |
|---|---|---|
| **Ensemble survival** | ≥ 1 of 3 variants succeeds. Each variant is independently validated against the domains JSON schema. | If all 3 fail, `smart_worker_loop` retries the whole ensemble up to 3 times. |
| **Domain count within tier bounds** | Final domain count ∈ [`min_business_domains`, `max_business_domains`] after judge. | Judge is re-prompted if out-of-bounds. |
| **Division allocation** | Every domain maps to exactly one division (Operations / Business / Corporate) from the user's `org_divisions` widget. | Unmappable domains forced to `business` with a WARN. |
| **Model-params guardrails** | `_clamp_and_validate_model_params` — min/max attribute-per-product, product-per-domain, subdomain-per-domain fall within tier-specific guardrails. | Out-of-bound values clamped to tier midpoint, logged as `[MODEL-PARAMS]` WARNING. |

**Questions answered:**
1. Did any single LLM variant hallucinate domain structure? → Ensemble-validated; judge sees all 3 outputs and picks the most coherent.
2. Is the chosen domain count sized correctly for the declared scope (MVM vs ECM)? → Tier guardrails clamp.
3. Do all domains fit the stated org chart? → Division-allocation gate.

---

## 3. Product Generation per Domain (Step 3)

For each domain in parallel (bounded by `MAX_CONCURRENT_BATCHES`), a per-domain LLM call emits products.

| Gate | Rule IDs | What it asserts | Failure mode |
|---|---|---|---|
| **Schema validation** | G10-R001 | Response matches product-list JSON schema; every product has `domain`, `product`, `description`, `type`, `primary_key`. | Retries up to 3. |
| **Product count per domain** | PRD-RUL-006 | `min_data_products_per_domain ≤ count ≤ max_data_products_per_domain`. | Warn and truncate/expand via follow-up judge call. |
| **Name format** | PRD-RUL-014, REL-RUL-001 | Product name matches `^[a-z0-9][a-z0-9_]*$`, length ≤ 30, max 2 underscores. | Hard reject, retry. |
| **FK validation** | REL-RUL-001, REL-RUL-004, REL-RUL-005, REL-RUL-007, REL-RUL-008 | Every `foreign_key_to` resolves to a real `{domain}.{product}.{pk}`; self-refs allowed only with role prefix; no bidirectional pairs (see §5). | `validate_and_correct_fk_target` attempts repair; unrepairable FK dropped with WARN. |
| **PK-CE contradiction gate** | `_check_postprocess_gate` | If LLM's post-response "removed contradictions" count exceeds `hard_removed_threshold`, survival rate < `hard_ratio_threshold` → hard reject. | Discard response, retry. |
| **Honesty contradiction penalty** | `_apply_contradiction_penalty` | Honesty score drops proportionally to `removed/orig_count`. If dropped score < threshold → reject. | Discard response, retry. |

**Questions answered:**
1. Did the LLM invent a product whose FK points to a non-existent parent? → FK validation catches.
2. Did the LLM lie about its confidence, then silently drop half the output when asked for contradictions? → Honesty-contradiction gate penalizes.
3. Does every product name conform to SQL-safe naming? → Regex-enforced.
4. Is the domain's product count within guardrails? → Count gate.

---

## 3.6 Domain Architect Review — Per-Domain Deep Dive (v0.6.4+)

Each domain gets an independent LLM call with **dual persona**: Principal Data Architect + Senior Business SME for that domain's `{industry_alignment}`. The review loops up to `MAX_ARCHITECT_REVIEW_ITERATIONS` (default 3) times per domain; previous-iteration verdicts feed the next prompt via `{previous_reviews_context}`.

### The 4 production-readiness gates (per domain)

Each asks a yes/no question with a written justification. All 4 must pass for the domain to exit the iterative loop early.

| # | Gate | Question asked of the LLM |
|---|---|---|
| 1 | **`trust_in_production`** | "Would you personally trust putting this model into production at `{business}` TODAY? Would you stake your professional reputation on it? If it breaks in prod at 3 AM and your CEO calls you, can you defend every design decision in this model?" |
| 2 | **`support_in_production`** | "If you were on-call for this model in production, would you be willing to support it? Would you write the runbooks, take the pages, answer the stakeholder questions, and own the outcomes — or are there parts of this model you would refuse to support because they are unsafe, incomplete, or wrong?" |
| 3 | **`recommend_to_industry_peers`** | "Would you recommend this model as-is to OTHER businesses in the `{industry_alignment}` industry? Would you present it at an industry conference as a reference implementation, knowing your peers will scrutinize every FK, every domain boundary, every tag?" |
| 4 | **`propose_for_global_standard`** | "Would you propose this model to the supreme governing committee / standards body of the `{industry_alignment}` industry as a candidate for global adoption as THE canonical reference data model for the entire industry? Would you defend it line-by-line to a panel of the world's top 20 principal architects in this industry?" |

### Actionable outputs

For each failing gate, the architect must emit concrete `required_actions`: products to add / rename / remove / merge / split within this domain, in-domain FK suggestions, description improvements. These are applied immediately via the **P0.11 mutation engine (topological sort)** so the next iteration sees the mutated state.

### Iteration telemetry

Each iteration emits a progress event (`stage_in_progress`, `step_name = "Domain Architect Review — Iteration N/M"`). Early-exit fires when every domain in an iteration reports all 4 gates "Yes".

### Unrepairable items → next_vibes

Gate failures that the architect could not fix within the iteration budget are queued into `widgets_values["_architect_gate_failures"]` for the `next_vibes` report — the user sees them in the final `NEXT_VIBES_*.md`.

**Questions answered at this stage:**
1. Does each domain, considered on its own, look like a real-world data architect would accept it? → 4 gates.
2. Is the domain cohesive (SSOT within-domain, no orphan products)? → Architect enumerates issues.
3. Did the architect's fixes actually land, or did the mutation engine silently drop them? → P0.11 topo-sorted apply guarantees apply order; unfixable items surface as `gate_failures` count in the final stage_succeeded event.

---

## 3.7 Principal Data Architect Review — Global/Holistic

Single LLM call over the entire model. Same 4 gates as §3.6 **plus 15 scorecard dimensions** (0-100 each), iterative up to 3 passes.

### The 15 scorecards

| Dimension | What it scores |
|---|---|
| `completeness_score` | Does the model cover all the business processes implied by the business context? |
| `coverage_score` | Are all major entities implied by the industry vocabulary represented? |
| `duplication_score` | Inverse of cross-domain duplicated products (lower is worse). |
| `usefulness_score` | Will downstream consumers (BI, ML, ops) find this model usable? |
| `uselessness_score` | Are there products with no clear consumer or business purpose? |
| `goal_alignment_score` | Does the model serve the stated `{business_description}`? |
| `division_balance_score` | Products spread sensibly across Operations / Business / Corporate? |
| `domain_granularity_score` | Domains neither too fat nor too narrow? |
| `product_granularity_score` | Products at an appropriate noun-level (not "*_event" catch-alls)? |
| `industry_conformance_score` | Matches industry canonical models (NDC, IATA, S/4HANA, etc. for airlines; FHIR for healthcare; FIX for trading; etc.)? |
| `scope_appropriateness_score` | MVM stays lean; ECM stays complete — no scope creep in either direction. |
| `connectivity_score` | FK graph is connected; no siloed tables. |
| `naming_consistency_score` | snake_case/camelCase/etc. consistent per user widget. |
| `ssot_compliance_score` | Each business concept has exactly one authoritative owner. |
| `process_coverage_score` | Every core business process has enough products to represent it end-to-end. |

### Validation layer

Before mutations apply, `validate_architect_review(response_data, protected_items, …)` runs a structural check:

| Check | Blocks on |
|---|---|
| Immutable violations | Architect tries to remove/rename a product the user marked as `must_have_data_products` or the architect itself flagged as CORE |
| Name format | New domain/product names violate regex or length limits |
| Merge sanity | `domains_to_merge` / `products_to_merge` has ≥2 source items |
| Cap limits | ≤3 new domains, ≤10 new products per iteration (prevents runaway expansion) |

Failure → response rejected, retry.

### Protected set building

Before the architect runs, `step_architect_review` builds 2 protected sets:

1. **User-declared must-haves** — anything in widget `must_have_data_products` or matched by substring.
2. **LLM-identified CORE products** — a separate lightweight LLM call identifies business-critical products (e.g. for airlines: `flight.schedule`, `passenger.pnr`, `revenue.fare`). Protection prevents the main review from dropping them.

**Questions answered:**
1. Does the full cross-domain model hang together as a coherent system? → 4 gates global.
2. Can any single-word deficiency (e.g. connectivity, SSOT, industry-conformance) be objectively scored and surfaced? → 15 scorecards.
3. Can a rogue architect iteration destroy the CORE products without tripping? → Protected-set immutable check.
4. Does the model hit scope appropriateness for MVM vs ECM? → `scope_appropriateness_score` + deterministic product-count guardrails.

---

## 4. Attribute Generation per Product (Step 4)

For each product (up to 151 for Airlines MVM), a per-product LLM call emits attributes. Parallelised by `MAX_CONCURRENT_BATCHES`.

| Gate | Rule IDs | What it asserts | Failure mode |
|---|---|---|---|
| **Attribute count buffer** | G15-R010, ATT-RUL-049 | Attribute count within `[min_attrs, max_attrs + buffer]` where buffer ≈ 20% of max. | Over-target within buffer → WARN "using buffer allowance" (accepted). Over buffer → truncated. |
| **Name format + PK suffix** | ATT-RUL-049, ATT-RUL-048, NAME-RUL-* | Attribute names match naming-convention regex; PK attribute ends with configured `primary_key_suffix` (`_id`, `_key`, etc.). | Hard reject, retry. |
| **Type validity** | ATT-RUL-004, ATT-RUL-005 | Type ∈ {BIGINT, INT, LONG, STRING, DATE, TIMESTAMP, DECIMAL, DOUBLE, FLOAT, BOOLEAN} or a recognised alias; decimals carry precision/scale. | Retry. |
| **Redundant prefix autofix** | G15-R011, ATT-RUL-017 | `[AUTOFIX]` strips `{product}_` prefix from attribute names (e.g. `leg_status → status`). | Auto-applied, no reject. Logged as INFO. |
| **Value regex sanity** | ATT-RUL-013 | `value_regex` if present is a valid regex and (for typed columns) not redundant with the data type (e.g. `^\d+$` on BIGINT is flagged). | WARN → next_vibes for consolidation suggestion. |
| **PII classification** | TAG-RUL-* | Columns with PII-candidate names (email, phone, ssn, tax_id, passport, lat/long, …) must carry `classification` + `pii` tags. | WARN if missing, auto-inserted when possible. |
| **Honesty contradiction gate** | `_check_postprocess_gate` | Same as §3 — rejects responses with too many "removed" contradictions and low survival. | Retry. |

**Questions answered:**
1. Did the LLM cram 80 attributes into a product when the target was 45? → Buffer gate enforces cap.
2. Did column names inherit redundant product prefixes? → AUTOFIX strips them.
3. Are PII columns properly classified? → Tag gate enforces.
4. Is a value_regex actually useful or redundant with the type? → Regex sanity gate.

---

## 5. Cross-Domain Linking (Step 7) — FK Integrity

After attributes are generated, the FK linking stage runs 3 sub-phases: in-domain → global cross-domain → pairwise. Each emits its own progress event.

| Gate | Rule IDs | What it asserts | Failure mode |
|---|---|---|---|
| **FK target resolution** | REL-RUL-001, REL-RUL-004 | Every `foreign_key_to` points at an existing `{domain}.{product}.{pk}`. | `validate_and_correct_fk_target` attempts similarity-repair; unrepairable → drop + WARN. |
| **FK type compatibility** | REL-RUL-003, ATT-RUL-005 | FK column type is cast-compatible with target PK type (BIGINT↔LONG↔INT OK; STRING↔BIGINT not OK). | Unresolved FK is dropped, WARN. |
| **No bidirectional FKs** | REL-RUL-017, REL-RUL-018 | A→B may not coexist with B→A in the schema. Detects and keeps only the business-logical direction. | Reverse FK dropped automatically. |
| **Self-ref role labeling** | `_is_role_labeled_self_ref` | Self-referencing FKs (product → same product) must have role-labeled FK column name (`parent_`, `previous_`, `original_`, `source_`, `target_`, …) AND integer-compatible type. | Unlabeled self-ref dropped. P0.15 fix. |
| **Ambiguous FK auto-rename** | P0.16 | If two FK columns point at the same target and one is generic (e.g. `profile_id`), it's renamed with a product-hint or ordinal fallback (`customer_profile_id`, `profile_id_2`). | Auto-applied. |
| **Protected parent-child FK** | REL-RUL-012, REL-RUL-020 | Certain parent-child FKs (e.g. `order_line → order_header`) are structurally protected and cannot be dropped by cleanup. | Hard-protected. |
| **Cycle detection** | `qa_results["cycles_detected"]` | FK graph must be a DAG (except self-refs and cleared cycles). | Cycle-breaker picks the weakest edge and drops it, logs cycle path. |
| **Siloed table detection** | `qa_results["siloed_tables"]` | Every non-reference product must have at least one inbound or outbound FK. | Siloed tables listed in QA result_json for operator review. |

**Questions answered:**
1. Will any FK actually be creatable at physical-schema time? → Type-compat gate catches it here, not at SQL failure time.
2. Does the FK graph have cycles? → Detected + broken.
3. Are there 2 generic FKs both pointing at the same parent from one product? → Auto-renamed.
4. Is there a table nobody references and that references nobody? → Flagged in silos list.

---

## 6. Quality Assurance Sub-Gates (Step 8)

`step_qa_checks` runs 7 sub-gates sequentially, each emitting its own `stage_in_progress` event.

| # | Sub-gate | What it does |
|---|---|---|
| 1 | **Core Product Identification** | LLM lists business-critical products (protected from removal). |
| 2 | **Empty Domain Removal** | Domains with 0 products are removed. |
| 3 | **Naming & Schema Validation** | Validates naming conventions, DB names, table names, PK names. Merges small domains. |
| 4 | **PK & Data Type Validation** | Auto-inserts missing PKs (one per product), fixes missing `data_type` defaults. |
| 5 | **Name Overlap Detection** | Finds duplicate product names across domains, small tables. Renames duplicates using `{domain}_{product}` pattern. |
| 6 | **Graph Topology Analysis** | Cycles, siloed tables, topology issues. Breaks weakest cycle edges. |
| 7 | **Auto-Remediation** | Applies all fixes from 1-6. Counts `issues_fixed`, `cycles_broken`, `products_consolidated`, `products_renamed`, `fk_refs_updated`. |

### Deterministic checks (non-LLM)

Beyond sub-gates, `pre_static_analysis_autofix` at stage end runs **deterministic** structural fixes:

- PK type normalization (all BIGINT recommended; mixed types WARN)
- FK type coercion (match parent PK exactly)
- Redundant `value_regex` on typed columns → removed
- Pipe-enum `value_regex` with > 8 values → consolidated into a reference product (next_vibes suggestion)
- Missing classification tags on PII-candidate columns → auto-added

**Questions answered:**
1. Did we end up with duplicate product names across domains? → Name-overlap gate fixes.
2. Is every product a PK-holding table? → Auto-PK insertion.
3. Are FK graph cycles breaking deployability? → Cycle-breaker.
4. Did we miss tagging any PII? → Deterministic tag sweep.

---

## 7. Fidelity Gates (user vibes provided)

When the user supplied a VibeContract (`model_vibes` widget), `evaluate_fidelity_gates` runs after model finalisation to measure **contract adherence** (did the final model actually implement what the vibes asked for?).

| Gate | What it measures | Report |
|---|---|---|
| `requirements_addressed` | % of vibe requirements with evidence in the final model | Score 0-100. |
| `requirement_coverage` | Per-requirement status: `fulfilled` / `partial` / `unfulfilled`. | Listed in scorecard. |
| `requirement_drift` | Did previously-fulfilled requirements break during a later pass? | Listed with before/after diff. |
| `compliance_score` | Overall fidelity. Must exceed `fidelity_gates.min_compliance_score`. | Score 0-100. |

**When no VibeContract is provided** (P0.17 fix): these gates demote to INFO — they don't clutter the error log with irrelevant WARNINGs. When a contract IS provided, failures emit WARNING with specific gate + up-to-3 unmet requirements.

---

## 8. Sample Data Generation (Step 14, v0.6.8+)

Agent 4.8.0 and later skip this stage: the standalone model installer (`model-installer/data-model-installer.ipynb`) generates sample data. The gates below describe the agent's engine before 4.8.0.

The pool-based engine (P0.20) replaces the prior CSV row-generator. Its gates:

| Gate | What it asserts | Failure mode |
|---|---|---|
| **Pool-spec JSON parse** | LLM returns a parseable JSON pool-spec. Tolerant to markdown fences. | 1 retry, then stdlib-random fallback. |
| **Row count threshold** | Assembled DataFrame ≥ `max(2, total_needed // 5)` rows. | Falls back to stdlib-random. |
| **Type coercion** | Each local sampler produces a value of the declared column type (BIGINT/INT/LONG/DECIMAL/DATE/TIMESTAMP/BOOLEAN/STRING). | Decimal/integer conversion errors → row value set `None` and logged. |
| **FK integrity** | FK columns left `None` in Phase 1; Phase 2 patcher populates from actual parent PK pool. | Phase 2 is mandatory before tables are queryable for analytics. |
| **Boolean format conformance** | Output matches widget `boolean_format`: `True`/`False`, `0`/`1`, or `Y`/`N`. | Default fallback formats per widget; never emits mixed. |
| **Correlated-group atomicity** | If LLM declared `[country, city, postal_code]` as correlated, rows draw the tuple atomically (not independently). | Overlay step runs after independent sampling; correlated columns overwrite. |
| **Per-product timeout** | 180s pool timeout per product; 90s LLM timeout with 1 retry. | Timeout → stdlib-random fallback for that product. |
| **Volume enforcement** | User-requested N rows always achieved deterministically (vs prior LLM-row approach where "N" was aspirational). | Guaranteed by local assembly. |

**Questions answered:**
1. Will every product actually receive exactly the requested row count? → Yes, deterministic.
2. Will a BIGINT FK column ever contain a string? → Type-coerced at sample-time; impossible.
3. Will correlated columns produce plausible tuples (country/city/postal)? → Joint-pool sampling.
4. What happens if the LLM times out? → 2-tier fallback: pool-LLM → stdlib-random.

---

## 9. Post-Pipeline Invariant Drift Check

After all artifacts are generated, a final gate compares `_baseline_invariants` (captured pre-artifact) with `_post_invariants`:

| Invariant | Checked |
|---|---|
| Domain count | Must match baseline exactly. |
| Product count | Must match baseline exactly. |
| Attribute total count | Must match baseline exactly. |
| FK edge count | Must match baseline exactly. |

If drift detected → `stage_warning` on `Quality Assurance / Invariant Drift Detected` with baseline vs current diff. Informs operator that a post-finalisation step mutated state (usually a bug).

---

## 10. Next Vibes Collection (Step 16)

Issues that didn't block the run but the architect / gates surfaced are captured into `NextVibesIssueCollector` with three severities:

| Severity | Policy |
|---|---|
| **BLOCKING** | Must address in next run. E.g. product granularity gate fail, SSOT violation architect couldn't resolve. |
| **SAFE_IGNORE** | Acknowledged but acceptable. E.g. scope-appropriate over-allocation. |
| **INFO** | Observation. E.g. value_regex consolidation candidates. |

Written to the version's `vibes/next_vibes.txt` on the volume. The **next** run never applies them on its own: an `operation="vibe modeling of version"` run takes its instructions only from widget `08. Model Vibes`, which may hold the path of that `next_vibes.txt`. An empty `08. Model Vibes` fails preflight.

**Questions answered:**
1. What did this run choose not to fix, and why? → BLOCKING vs SAFE_IGNORE.
2. Is there a sensible next-version scope? → BLOCKING items define it.

---

## 11. Scope Fence and Rename Gates

Agent 5.1.4 adds six categories to `run_metamodel_static_analysis`. Five belong to the `vibe_scope` fence and run only in scoped runs (widget 06a set to `Some Domains` or `Some Subdomains`). The sixth catches a rename that left its original behind, on every run.

| Category | Severity | Runs on | What it asserts | Repair | Rule |
|---|---|---|---|---|---|
| `vibe_scope_out_of_scope_change` | error | Scoped runs | Every out-of-scope domain, product, attribute and metric view, and the model-level metadata, equals the base model, apart from the permitted deltas P1 to P5. Only fields that model.json stores count: working fields such as `is_primary_key`, `nullable` or `classification` are ignored | Checkpoints restore the base record; the serialize gate splices the out-of-scope sections from the base model.json | QGATE-RUL-013 |
| `vibe_scope_dependency_conflict` | warning | Scoped runs | No in-scope change breaks an out-of-scope artifact in a way P1 to P5 cannot repair, and no referenced in-scope table disappears without an explicit drop | The change is rejected or rolled back; an unrequested drop is restored from the base model | QGATE-RUL-014 |
| `vibe_scope_dangling_boundary_fk` | info | Scoped runs | No out-of-scope FK still points at an in-scope target that an explicit rename, move or drop removed | The boundary reconciler re-points the FK (P1) or clears it (P2) | QGATE-RUL-015 |
| `vibe_scope_subdomain_violation` | error | `Some Subdomains` runs | Every new product in a listed domain uses a listed subdomain | The product is removed with its references | QGATE-RUL-016 |
| `vibe_scope_extra_domain` | error | Scoped runs | The model gains no domain that is neither in the base model nor in the scope list | The domain and its products are dropped | QGATE-RUL-017 |
| `rename_leftover_original` | error | Every run | No product survives next to a renamed copy of itself in the same domain | A rule-based autofix merges error-level pairs: it keeps the new name, moves the leftover's extra columns and FKs onto it, drops the leftover and records the merge in the change and rename ledgers. In a scoped run it merges only pairs whose both sides are in scope and reports the rest (`rename-leftover-fence-report`). The category is in SelfFixer's `_fixable` list and in the requeue `_ACTIONABLE_CATEGORIES` for any residual | QGATE-RUL-018 |
| `domain_database_name_mismatch` | warning | Every run | A domain's `database_name` carries the domain's own name under the naming convention (a schema prefix or suffix is allowed), so its tables deploy into its own schema | The finding goes to the SelfFixer (`_fixable`). A deterministic domain rename replaces the old name inside `database_name`, keeping any prefix or suffix | QGATE-RUL-021 |
| `invalid_table_name` | error | Every run | Every product's `table_name` is a plain SQL identifier, so its DDL can create the table | The finding goes to the SelfFixer (`_fixable`). The LLM fallback mutation gate rejects a `table_name` or `primary_key` value that is not an identifier | QGATE-RUL-022 |

**How `rename_leftover_original` pairs products.** Two products in the same domain form a pair in one of two ways. A ledger pair is one the rename ledger records as renamed, followed through any later domain rename. A name-extension pair is one where one name extends the other at a word boundary (`x` next to `x_y` or `y_x`); the product with fewer business columns is taken as the old one, and a pair whose longer name is just the domain name plus the shorter one is left to `duplicate_product_pair`. The overlap is the Jaccard index of the two products' business columns, so the primary key, history and housekeeping columns do not count. A name-extension pair is flagged as an error when the overlap is at least 70%. A ledger pair is always flagged: as an error at 70% or more, and as a warning below that (for example a stub recreated under the old name). The autofix merges only error-level pairs and never merges a name-extension pair whose old name the user named. So `livestock_procurement` next to `livestock_procurement_allocation` with almost the same columns is flagged and merged, while `purchase_order` next to `purchase_order_line` is not flagged.

**The fence repairs its own findings.** The five `vibe_scope_*` categories are deliberately left out of SelfFixer's `_fixable` list, because an LLM repair could edit frozen tables. This is the documented exception to QGATE-RUL-011 (Gates Wired Into Agentic Repair Loop). Other categories still requeue in a scoped run, with two limits: a finding that touches only out-of-scope entities is dropped (`vibe-scope-requeue`), and a finding that touches both sides is requeued with an instruction to repair only the in-scope part.

**Fail closed.** Before `model.json` is written, the serialize gate re-checks the fence. If a problem remains, `model.json` is not written and the run halts (`vibe-scope-serialize-gate`, `vibe-scope-serialize-halt`).

**Questions answered:**
1. Did a scoped run change anything outside its scope? → `vibe_scope_out_of_scope_change`, then the fail-closed write.
2. Did an in-scope change break an out-of-scope table, FK or metric view? → `vibe_scope_dependency_conflict` and `vibe_scope_dangling_boundary_fk`.
3. Did a rename leave the old product behind? → `rename_leftover_original`.

---

## Gate Summary Table — At-a-Glance Confidence

| Stage | # Gates | Hard-reject? | Next-vibes? | Blocking user flag? |
|---|---|---|---|---|
| Pre-flight (prompt audits) | 3 | No | No | No — WARN only |
| Business Context | 2 | Yes | No | Yes if no fallback |
| Domain Gen (ensemble + judge) | 4 | Yes | No | Yes if all 3 variants fail |
| Product Gen | 6 | Yes | Yes | Yes on schema fail |
| Domain Architect (3.6) | 4 (per domain × 3 iters) + validation | Yes on immutable violation | Yes for gate failures | No — soft, loop retries |
| Principal Architect (3.7) | 4 + 15 scorecards + 4 structural | Yes on immutable violation | Yes for gate failures | No |
| Attribute Gen | 7 | Yes on schema fail | Yes on regex/tag gaps | No |
| Cross-Domain Linking | 8 | No (auto-repair) | Yes on drop | No |
| Quality Assurance | 7 sub-gates + deterministic | No (auto-repair) | Yes | No |
| Fidelity Gates (if vibes) | 4 | No | Yes | WARNING level |
| Sample Gen | 8 | No (fallback tiers) | No | No |
| Invariant Drift | 4 invariants | No | No | WARNING if drift |
| Next Vibes Collection | — | No | Itself is the sink | — |
| Scope fence + rename gates (§11) | 6 (5 only in scoped runs) | Scoped run: the model.json write fails closed | No | Yes, a failed scoped write halts the run |

### What a fully passing model looks like

A model that reaches `Pipeline Finalization / stage_succeeded` with `result_json.warning_count == 0` has cleared:

- 3 pre-flight audits
- 2 business-context gates
- 4 domain-gen gates
- 6 product-gen gates (per domain × all domains)
- 4+1 architect gates × 2 levels × up to 3 iterations each (so up to 24+ architect gate checks per run)
- 7 attribute-gen gates (per product)
- 8 FK-integrity gates (per edge)
- 7 QA sub-gates + all deterministic static-analysis fixes
- 4 fidelity gates (if vibes provided)
- 8 sample-gen gates (per product)
- 4 invariant-drift checks

**Total enforced checks for a 12-domain × 151-product Airlines MVM** ≈ **3 + 2 + 4 + (6 × 12) + (5 × 12 × 3) + (5 + 19) + (7 × 151) + (8 × avg-5-FKs × 151) + 7 + 4 + (8 × 151) + 4 ≈ 10,500+ gated checks per run**.

Each check is logged; errors/warnings surface in `/Volumes/<catalog>/_metamodel/vol_root/logs/<biz>/<scope>_v<N>/<biz>_{info,error}_<scope>_v<N>.log`.

---

## How to use this document

1. **Debugging** — When a field in `_metamodel.business.result_json` looks wrong, find the stage in the table above and search the code for the gate function to understand why it passed/failed.
2. **Adding new gates** — Append under the correct pipeline stage. Every gate MUST:
   - Have a stable rule ID (for grep-ability).
   - Declare its failure mode (hard-reject / next-vibes / WARN).
   - Emit a `stage_in_progress` or `stage_warning` event if it's user-observable.
   - Be documented here before merge.
3. **Integration with the progress table** — See `integration-guide.md` §5.6 for the Architect Review events specifically; other stages follow the same lifecycle conventions (`stage_started` → `stage_in_progress`* → `stage_succeeded`|`stage_failed`|`stage_warning`).

---

## Rule-ID namespace glossary

Every deterministic check carries a rule ID. Grep the codebase for the ID to find both enforcement and description. IDs group by concern:

| Namespace | Concern |
|---|---|
| `G01-R###` .. `G15-R###` | Global pipeline governance (one rule per cross-cutting policy). |
| `GEN-RUL-###` | Cross-domain generation rules (schema shapes, emit formats). |
| `PRD-RUL-###` | Product-level rules (naming, count, type, SSOT ownership). |
| `ATT-RUL-###` | Attribute-level rules (naming, types, regex sanity, PK/FK suffix). |
| `REL-RUL-###` | Relationship/FK rules (target resolution, type compat, bidirectional, self-ref role, cycle protection). |
| `NAME-RUL-###` | Naming-convention rules (case, prefixes, suffixes, collision handling). |
| `TAG-RUL-###` | Tagging rules (PII classification, sensitivity levels, domain/division tags). |
| `FK-RUL-###` | Foreign-key-specific structural rules (distinct from REL-RUL which covers semantic/relational). |
| `SUB-R###` | Subdomain allocation rules. |
| `G##-R###` | Legacy numbered rules — still enforced, documented in whitepaper Appendix. |

**Where the rules live:**
- Full rule text: [`whitepaper.md § Appendix`](whitepaper.md#appendix-data-modeling-rules-catalog).
- Enforcement sites: grep `/agent/dbx_vibe_modelling_agent.ipynb` (or the flattened source `/tmp/agent_source.py`) for the rule ID.

---

## Operator's playbook — how to read a gate outcome

When triaging a run, walk the log top-to-bottom through these markers in order:

### 1. Did pre-flight pass?
Grep for `[Sanity] audit_prompt_templates` and `[Sanity] smoke_render_all_prompts`. Both should be `PASS`. WARN is survivable; abort-level isn't emitted here — if you see a hard exit before any `Logger initialized` line, suspect a widget-missing hard error in `step_setup_and_clean`.

### 2. Are the warning counts trending down across iterations?
Architect review should tighten gates across iter 1 → iter 2 → iter 3. Search for `failed gates:` and count the listed gates per domain in each iteration. If a domain is stuck at all-4 across all 3 iterations, that domain has a structural issue the architect cannot resolve — it will surface in `next_vibes` as BLOCKING.

### 3. Did honesty penalty ever drop below threshold?
Grep for `[*-POSTPROCESS] Honesty penalized: NN% -> MM%`. If MM% < threshold (55% in MVM, 65% in ECM), the response was hard-rejected and retried. Look for the retry's outcome. Three consecutive rejections → the stage's `stage_warning` event emits.

### 4. Did FK integrity survive linking?
Grep for `BLOCKED semantic mismatch`, `BLOCKED unlabeled self-referencing`, `BLOCKED bidirectional`, `REJECTED self-referencing`, and `INVALID FK removed`. These are **good**: the gates worked. Compare against the final `Cross-domain FKs: N valid, M suspect, K invalid (removed)` line. Suspect count > 20% of total FKs signals weak model coherence.

### 5. Did QA remediate duplicates + cycles?
Grep `CRITICAL: DUPLICATE TABLE NAMES` and `[CYCLE DETECTION] Found N cycle(s)`. Follow with `auto-remediation` lines — every duplicate should be renamed, every cycle broken. If final stage_succeeded still carries a `cycles_broken=0` but earlier `Found 1 cycle(s)` existed, something didn't remediate.

### 6. Did invariant drift catch anything?
Grep `[Invariant Drift Detected]`. Anything here means a post-artifact step mutated domain/product/attribute/FK counts — usually a bug. Snapshot the delta from the `result_json` for reproduction.

### 7. Did sample gen hit target row count?
Grep `[Sample Gen] Progress:` and `[Sample Gen] ✅ LLM SUCCESS for` vs `falling back to stdlib random`. Pool-engine success (v0.6.8+) is the goal; stdlib-random fallback rate > 10% signals LLM pool-spec fragility.

### 8. What's in next_vibes?
Grep `NEXT-VIBES FEEDBACK` at the tail. BLOCKING items are the prioritised backlog for the next `operation="vibe modeling of version"`; pass the file's path in `08. Model Vibes` to apply them. INFO items are observations. If BLOCKING count > 10, the model needs more iteration budget next run (raise `MAX_ARCHITECT_REVIEW_ITERATIONS`).

### 9. Did the scope fence hold? (scoped runs only)
Grep `[vibe-scope-sa-gates FIRED` for the count of each scope category, and `[vibe-scope-serialize-gate FIRED` for the write verdict (`passed` or `FAIL-CLOSED`). A clean scoped run has no `[vibe-scope-fence-restore FIRED` line: every restore means a pass tried to change a frozen artifact. `[vibe-scope-unrequested-drop` marks a referenced in-scope table that was restored.

---

## Known gaps (honest)

- **Architect gate 4 (`propose_for_global_standard`) is effectively unattainable for any single-industry model.** Across every tested run it's the only persistent failure at iter 3. Candidate v0.7.x: demote this gate from "all must pass" to "ambition score", or make it an opt-in strict mode.
- **`passenger` domain has been observed stuck at all-4-gates-fail across iterations** in Airlines MVM runs. Root cause not fully understood — likely interacts with the PNR / ticket / itinerary SSOT tension (shared with distribution). Logged for next investigation.
- **Sample-realism gate is missing.** Nothing currently asserts "does the generated data LOOK like real airline data?" — only that types coerce and FK integrity holds. A post-gen semantic-realism LLM check is queued for a future version.
- ~~**No unit tests** in the repo for gate functions themselves.~~ **Partial coverage added in v0.7.x** — `tests/unit-tests/` now pytest-covers the pure helpers most prone to regression (`_parse_ce_counts`, `sanitize_name`, the tag-merge regex). Gate functions themselves (`_check_*`, `validate_*`) remain end-to-end-only; candidate work is extending the pytest harness to exercise them directly with synthetic model fixtures.

## v0.6.x → v0.8.x fix roll-up affecting gates

The fixes below changed gate behaviour directly. For the full P-number catalog see the repo-root [`readme.md` → Recent fixes](../readme.md#recent-fixes-v06x--v07x).

| P-number | Version | Gate impact |
|---|---|---|
| P0.11 | v0.6.7 | Mutation engine is now topo-sorted — architect actions no longer silently drop because of in-batch ordering; visible as `[Gate Hierarchy] normalize` + autofix summary logs. |
| P0.15, P0.16 | v0.6.7 | Self-ref FK role-label + ambiguous FK auto-rename upgraded from warnings to auto-applied fixes. |
| P0.17 | v0.6.7 | Fidelity gates demote to INFO when no VibeContract is supplied — no more spurious WARNINGs in `new base model` runs. |
| P0.20 | v0.6.9 | Sample generation now pool-based (Faker removed); gates in §8 apply. |
| P0.43, P0.48 | v0.7.2 | Gate hierarchy is INCLUSIVE — if a harder gate passes, easier gates are force-promoted. Early-exit is keyed strictly on `_REQUIRED_GATES_FOR_EARLY_EXIT`. |
| P0.44 | v0.7.2 | Architect self-grades its previous iteration's `priority_now`; schema now carries `prior_iteration_self_review`. Iter 1 is empty; iter 2+ is required. |
| P0.52, P0.53 | v0.7.3 | User-specified `business_domains` is IMMUTABLE end-to-end — Step 3.6 Domain Architect, Step 3.7 Principal Architect, QA all treat it as protected. |
| P0.55 | v0.7.3 | Pre-static-analysis autofix now re-runs AFTER Step 3.7 architect AND AFTER Step 7 QA, catching late mutations. |
| P0.56 | v0.7.3 | Replaces fragile orphan heuristic with deterministic isolated-product detection. |
| P0.58 | v0.7.3 | Gate dicts are deepcopied before normalisation — no more cross-iteration state leakage. |
| P0.60 | v0.7.4 | FORBIDDEN GENERIC domain-name rule DISABLED — was overriding valid user vibes. |
| P0.65 | v0.7.5 | USER-KING `sizing_directives` parsed from free-text user vibes and enforced as a HARD post-gen gate; overrides all heuristic min/max. |
| P0.67 | v0.7.5 | `NamingConvention` is the single source of truth for PK + FK + suffix + case. All enforcement paths delegate to it. |
| P0.70 **REVERTED** | v0.7.5 → v0.7.10 | Count-based in-domain chunking removed. Full domain is always sent to the LLM linker — chunking lobotomized context. |
| P0.72 | v0.7.5 | Metric-view ownership records captured AT CREATION TIME — no `_unassigned` fallback; validator fails loud if any view lacks an owner. |
| P0.73 | v0.7.5 | Word-boundary PII match — `order_id` no longer fires on the 2-letter `or` substring. |
| P0.74 | v0.7.5 | Product-name collision guard runs BEFORE architect review. |
| P0.75 | v0.7.5 | FK column names MUST end with the target PK column name (exact match). |
| P0.89, P0.91 | v0.7.6 | VREQ-bleed product-name validator + column/product prose-name validator — rejects LLM responses where `<new_name>` is a sentence. |
| P0.96 | v0.7.10 | Post-install integrity check uses `_metamodel.domain` COUNT instead of `SHOW SCHEMAS` row parsing (which returned 0 on serverless). |
| P0.99+PE12 | v0.7.13 | `ALTER … SET TAGS` statements merged per target — ~20× faster install; regex tolerates quoted tag values containing commas. |
| P0.105+M6 | v0.7.13 | `_ensure_catalog_exists` discovers a managed location from metastore or borrowed catalog on Default-Storage metastores. |
| D1, §3b EXHAUSTIVE | v0.8.0 | User vibes (widgets, `model_vibes`, `business_description`) are the SUPREME authority across every gate; `business_domains` is treated as an EXHAUSTIVE list — judge/architect/QA may neither rename nor substitute (sentinel: `[VALIDATOR] User vibes detected (N chars)`). |
| HeartbeatWatchdog, MV pre-filter, MAX_CONCURRENT_BATCHES=20 | v0.8.0 | Long-running stages emit a heartbeat (no more silent stalls); metric-view candidates are pre-filtered before LLM call; concurrency is unified at 20 to bound LLM rate-limits deterministically. |
| G1-FIX | v0.8.1 | IDL chunking gracefully falls back when batches exceed token limits — no more `[Gate] IDL FAILED` cascades on large domains. |
| G8-FIX | v0.8.1 | `run_with_context_ladder` is now wired into the call sites that were silently bypassing it; the ladder fires on any `model demoted` or rate-limit error. |
| G9 | v0.8.1 | Non-rate-limit errors and heartbeat coverage are now surfaced — `_unhandled_llm_error` no longer hides under "rate limit". |
| G10-FIX | v0.8.1 | Per-model token + cost telemetry surfaced in run summary (`[TOKEN-TELEMETRY] model=… in=… out=… cost=…`). |
| G11-FIX, MV-FILTER | v0.8.1 | Metric-view filter is no longer a tautology (`return True # conservative keep-on-ambiguity`) — semantic predicate now actually excludes mismatched candidates. |
| C2-FIX MV15 | v0.8.1 | Halving on `[Metrics][LLM]` re-run merges sub-batches back together — no more lost half on the second batch. |
| C6-FIX | v0.8.1 | `vibe-prune` `NameError` fixed — the prune step no longer silently aborts on referencing the wrong variable. |
| Config-guard sweep | v0.8.1 follow-up | 10 functions accepting `config=None` now `config = config or {}` defensively — eliminates `AttributeError: 'NoneType'` on the architect/judge paths. |
| `VALIDATOR_REGISTRY` populated | v0.8.1 follow-up | The validator registry is now actually populated and used (was a dead dict before); audit can `grep VALIDATOR_REGISTRY` to enumerate active validators. |
| P1 (scratch path) | v0.8.2 | `_resolve_business_scratch_path` uses `tempfile.mkdtemp()` — `/tmp` foreign-UID reuse no longer permission-denies on Serverless. |
| P2 (domain-name mismatch CRITICAL) | v0.8.2 | `domain name mismatch` added to `critical_error_patterns` — parallel domain-enrich no longer soft-accepts a payload describing a different domain (alias=`domain-name-mismatch-critical`). |
| P3 (decimal coercion) | v0.8.2 | `_coerce_decimal_to_float()` runs before `spark.createDataFrame` so `decimal.Decimal` values no longer get rejected by `DOUBLE`/`FLOAT` columns in the pool engine. |
| P4 (no siloed after shrink) | v0.8.2 | `RESIZE_SHRINK_DOMAIN_PROMPT` carries `CRITICAL — NO SILOED TABLES`; `_detect_post_shrink_silos()` validates and rejects shrink output that leaves disconnected products. |
| P6 (prompt brace-escape) | v0.8.2 | The `KeyError '0,62'` class of bugs killed — prompt templates now properly escape `{...}` literals not meant for `.format()`. |
| P7 (Job Launch Gate) | v0.8.2 | `JobLauncher.wait_for_run_terminal()` polls until the child run reaches a terminal state and propagates `FAILED`/`TIMEDOUT` to the parent — no more parent-SUCCESS over child-FAIL. |
| P8 (managed-location accessibility) | v0.8.2 | `_validate_storage_accessible()` probes candidates with `dbutils.fs.ls`; `_resolve_managed_location` only returns reachable URLs; `_ensure_catalog_exists` retries with bare `CREATE CATALOG` on `PERMISSION_DENIED`. |
| P10 (MV install count validation) | v0.8.2 | After install, declared `metric_views` count is compared to physical `_metrics` table count; mismatch fails the install gate. |
| R1 (vibe-version-must-advance) | v0.8.3 / v0.8.4 | `_assert_vibe_version_advances` is invoked at FOUR write barriers; in-place overwrite of `v=base` during `vibe modeling of version` is now impossible (alias=`vibe-version-must-advance`). |
| F2-regression (immutable violation CRITICAL) | v0.8.3 | `immutable violation` added to `critical_error_patterns`; `model_architect_review` no longer soft-accepts payloads that touch user-protected products (alias=`immutable-violation-critical`). |
| R3 (log-no-truncate-on-success) | v0.8.3 / v0.8.4 / v0.8.6 | `_safe_volume_flush` skips copy if local `info.log` shrunk; emits sentinels `SHRUNK` / `SAFE-FLUSH` / `FINAL-FLUSH`. v0.8.6 N5-FIX appends those sentinels to `_vl_local_info` so they reach the UC volume `info.log` (alias=`r3-sentinels-to-volume`). |
| R6 (metric-view bare-name resolve) | v0.8.3 | Metric-view bare-name references resolved via `DESCRIBE METRIC VIEW` candidate scan instead of free-text guessing — eliminates `UNRESOLVED_COLUMN` class of metric-view install failures (alias=`metric-view-bare-via-describe`). |
| R7 (subdomain mandatory) | v0.8.3 | `subdomain_required` is now mandatory in LLM `model_params` JSON output; if absent the response is rejected (alias=`model-params-subdomain-required`). |
| R8 (deterministic Pass-2 cycle breaker) | v0.8.3 | Residual cycles after Pass-1 normalisation get a deterministic Pass-2 heuristic; logs `[CYCLE-BREAKER-PASS2][TRIGGERED]` / `[RESOLVED]` / `[NO-PROGRESS]` (alias=`cycle-breaker-deterministic-pass2`). |
| M1 (FK `IdId` double-suffix) | v0.8.5 | `normalize_fk_column_name` now reads from `attribute|column_name|name`; `FK_EDGE_SYNTHESIS_PROMPT` rule #1 rewritten with VERBATIM-match + explicit `IdId` ban. |
| M2 (PK casing collapse) | v0.8.5 | `NamingConvention._compose()` pre-runs `apply_convention(snake_case, dedup=False)` so PascalCase boundaries survive the lowercase round-trip (`CatalogItem` → `CatalogItemId`, not `CatalogitemId`). |
| M3+M4+N1 (FK semantic gate) | v0.8.5 | `user_sizing_directives` passed to every `.format()` call in `run_fk_semantic_correctness_gate` (no more silent `KeyError` bypass); four new classification rules added: TEMPORAL PRECEDENCE (rule 6), CARDINALITY CORRECTNESS (rule 7), HEADER↔LINE INTEGRITY (rule 8), JUNCTION TABLE PURITY (rule 9). Sentinel: `[MV15] [N1-FIX] semantic gate prompt rendered alias=fk-semantic-gate-no-keyerror`. |
| M5 (canonical attrs HARD) | v0.8.5 | `ATTRIBUTE_GENERATE_PROMPT` "FUNDAMENTAL ATTRIBUTES BY ENTITY ROLE" is now HARD MINIMUMS (alias=`canonical-attrs-enforced`); explicit enforcement block prioritises canonical fields over marketing/source-system flags during truncation. |
| N6 (metric_views char-iter) | v0.8.5 | `metric_views` JSON-string-blob is parsed at top-level + per-domain; no more `len(blob)`-many `[Metrics][LLM] skipping non-dict` warnings (alias=`metric-views-no-char-iter`). |
| Industry-agnostic prompt rewrite | v0.8.6 | M1/M3+M4/M5 rule text rewritten in abstract semantic vocabulary (`<EntityEarlier>`, `<Container>`, `<Owner>` patterns); explicit anti-industry-bias warning block in M5; 7 new bias-guard tests fail on retail-specific tokens (`product`, `order`, `cart`, `inventory`, etc.) appearing in rule text. |

Every P-number above is anchored in a `# v0.X.Y P0.NN` comment in `agent/dbx_vibe_modelling_agent.ipynb` cell[1] / `/tmp/agent_source.py`.
