# Clinical Trials

Part of **Databricks Industry Data Models**. Two model flavours are available for Clinical Trials, each a Unity-Catalog-ready data model with schemas, foreign keys, sample data, metric views, ontology tags, and DBML diagrams.

| Version | ECM &mdash; Expanded Coverage Model | MVM &mdash; Minimum Viable Model | Notes |
|---|---|---|---|
| **v1** | [`v1/ecm/`](./v1/ecm/)<br>19 domains &middot; 379 tables &middot; 15,530 attributes &middot; 3,128 FKs &middot; 169 metric views | [`v1/mvm/`](./v1/mvm/)<br>13 domains &middot; 193 tables &middot; 8,719 attributes &middot; 1,991 FKs &middot; 126 metric views | [version readme](./v1/readme.md) |
| **v2** | [`v2/ecm/`](./v2/ecm/)<br>20 domains &middot; 456 tables &middot; 16,159 attributes &middot; 3,304 FKs &middot; 166 metric views | &mdash; | [version readme](./v2/ecm/readme.md) &middot; CDISC USDM, Controlled Terminology, SDTM/CDASH/ADaM/Define metadata, ARS, FHIR eSource |

New model generations land as `v2/`, `v3/`, &hellip; sibling folders next to `v1/`.

&larr; Back to the [full catalog](../README.md) &middot; [repository root](../../README.md)
