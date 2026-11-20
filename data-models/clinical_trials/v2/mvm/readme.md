# Clinical_Trials Lakehouse Data Model

**v2_mvm** generated using Vibe Modelling Agent on November 20, 2026 at 12:38 PM

This document outlines a vibed Lakehouse data model for the Clinical_Trials business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Biostatistics](#domain-biostatistics)
  - [Consent](#domain-consent)
  - [Datamanagement](#domain-datamanagement)
  - [Laboratory](#domain-laboratory)
  - [Monitoring](#domain-monitoring)
  - [Randomization](#domain-randomization)
  - [Safety](#domain-safety)
  - [Site](#domain-site)
  - [Study](#domain-study)
  - [Subject](#domain-subject)
  - [Supply](#domain-supply)
  - [Compliance](#domain-compliance)
  - [Document](#domain-document)
  - [Regulatory](#domain-regulatory)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v2_mvm** are organized as follows:

```
v2/mvm/
  schemas/          DDL SQL files (one per domain)
  metrics/          Metric view SQL files (one per domain)
  samples/          Sample data CSV files (one per data product)
  docs/             Excel workbook, model CSV, release notes
  diagram/          DBML schema
  vibes/            Current & next vibes context
  ontology/         RDF/Turtle ontology schema
  model.json        Full model with requirements, metadata, and model data
  readme.md         This file
```

| Folder | Contents |
|---|---|
| `schemas/` | `clinical_trials_<domain>_schema_v2_mvm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `clinical_trials_catalogs_v2_mvm.sql` (catalog-level DDL) |
| `metrics/` | `clinical_trials_<domain>_metrics_v2_mvm.sql` (one file per domain) |
| `docs/` | `clinical_trials_model_v2_mvm.xlsx`, `clinical_trials_model_v2_mvm.csv`, `releasenotes.txt` |
| `diagram/` | `clinical_trials_dbml_v2_mvm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `clinical_trials_rdf_v2_mvm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | MVM (Minimum Viable Model) |
| Total Domains | 14 |
| Total Subdomains | 36 |
| Total Products | 172 |
| Total Attributes | 7606 |
| Primary Keys | 172 |
| Foreign Keys | 1888 |
| Avg Attributes/Product | 44.2 |
| Metric Views | 93 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Clinical_Trials | clinical-research | MVM (Minimum Viable Model) | Clinical Trials is a specialized industry that designs, manages, and monitors clinical research studies for pharmaceutical and biotech sponsors, providing data analytics, regulatory expertise, and patient recruitment to accelerate drug development. | FDA (U.S. Food and Drug Administration), EMA (European Medicines Agency), ICH (International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use), MHRA (Medicines and Healthcare products Regulatory Agency - UK), PMDA (Pharmaceuticals and Medical Devices Agency - Japan), TGA (Therapeutic Goods Administration - Australia), Health Canada, CDISC (Clinical Data Interchange Standards Consortium), WHO (World Health Organization - International Clinical Trials Registry Platform), OHRP (Office for Human Research Protections - U.S.), ISO 14155 (Clinical Investigation of Medical Devices), 21 CFR Part 11 (Electronic Records and Signatures), EU Clinical Trials Regulation (EU CTR 536/2014), GDPR (General Data Protection Regulation - patient data privacy), HIPAA (Health Insurance Portability and Accountability Act - U.S. patient data), SOX (Sarbanes-Oxley Act - financial reporting controls) | 19 |

## Business Domains & Subdomains

<a id="domain-biostatistics"></a>

### Domain: Biostatistics

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| biostatistics | operations | 2 | Owns the statistical planning and analysis lifecycle for clinical trials. Manages the source system versioning, randomization scheme design, sample size calculations, ADaM dataset specifications, TLF production, interim and final analyses | 10 |

**Subdomains:** analysis_planning, results_reporting


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| analysis_planning | analysis_population | master_data | Defines the analysis populations used in a study (e.g., Intent-to-Treat, Per Protocol, Safety, Modified ITT, Pharmacokinetic). Captures population name, acronym, inclusion/exclusion logic description, CDISC ADSL flag variable name, population size at DBL | 43 |
| analysis_planning | sample_size_calc | transactional_data | Records sample size calculations performed during study design and protocol development. Captures study phase, primary endpoint type, assumed effect size, standard deviation, alpha level, power, dropout rate, allocation ratio, calculated sample size per | 45 |
| analysis_planning | sap | master_data | Statistical Analysis Plan master record for a clinical study. Captures the source system (including amendments with rationale, sections modified, and regulatory impact), authoring status, approval workflow, blinding status, primary/secondary endpoint | 49 |
| analysis_planning | sap_amendment | transactional_data | Versioned amendment record for a Statistical Analysis Plan. Tracks each the source system amendment number, rationale for change, sections modified, pre- or post-database-lock classification, author, approver, approval date, and regulatory impact | 45 |
| analysis_planning | statistical_endpoint | master_data | Master record for each statistical endpoint defined in the the source system study. Captures endpoint name, classification (primary, secondary, exploratory, safety), endpoint type (efficacy, PK, PD, biomarker, PRO), measurement scale, analysis timepoint(s) | 40 |
| results_reporting | adam_dataset_spec | master_data | Specification record for each ADaM (Analysis Data Model) dataset produced for a study, including variable-level detail. Captures dataset name (e.g., ADSL, ADAE, ADTTE, ADLB), dataset class (ADSL, BDS, OCCDS, OTHER), purpose, key variables with derivation | 47 |
| results_reporting | database_lock_event | transactional_data | Database Lock (DBL) event record for a study or study part. Captures lock scope (full study, interim, partial), planned and actual lock date, pre-lock QC checklist completion status, outstanding query count at lock, lock authorization approvers (DM | 47 |
| results_reporting | interim_analysis | transactional_data | Records planned and executed interim analyses for a study. Captures interim analysis number, type (efficacy, futility, safety, adaptive), planned information fraction, actual analysis date, DSMB/DMC involvement flag, unblinding scope (full/partial/none) | 57 |
| results_reporting | tlf_output | transactional_data | Produced TLF output instance generated from a TLF shell specification. Captures output file reference, production run date, SAS program name and version, dataset version used, programmer, QC programmer, validation method (double programming, peer review) | 41 |
| results_reporting | tlf_shell | master_data | Table, Listing, and Figure (TLF) shell specification for a study. Captures output number, title, footnotes, display population, statistical method reference, program name, output type (table/listing/figure), the source system priority tier, and | 45 |

<a id="domain-consent"></a>

### Domain: Consent

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| consent | operations | 2 | Manages the informed consent lifecycle for trial subjects. Owns ICF versions and amendments, eConsent workflows (Clinpal), subject consent status, re-consent triggers, capacity assessments, withdrawal tracking, consent audit trails, and IRB/IEC-approved | 8 |

**Subdomains:** consent_documentation, subject_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| consent_documentation | consent_subject_consent | transactional_data | Core transactional record capturing the consent event for a trial subject at a specific site and study. Records the date and time of consent, ICF version consented to, consent method (paper, eConsent via Clinpal), consenting staff (PI, CRC), witness | 41 |
| consent_documentation | econsent_session | transactional_data | Tracks each eConsent workflow session initiated in Clinpal for a subject, including both on-site and remote/decentralized consent sessions. Captures session start and end timestamps, device type, IP address, session modality (in-person, remote via | 41 |
| consent_documentation | icf_amendment | transactional_data | Tracks amendments to an approved ICF version, capturing the amendment number, amendment date, nature of change (safety update, protocol change, administrative correction), regulatory authority requiring the amendment, IRB/IEC submission date and approval | 40 |
| consent_documentation | icf_version | master_data | Master record for each version of an Informed Consent Form (ICF) used in a clinical trial, including language translations and amendment-derived versions. Tracks ICF document version number, effective date, IRB/IEC approval reference, language (ISO | 47 |
| subject_management | capacity_assessment | transactional_data | Documents the formal assessment of a subject's mental capacity to provide informed consent, as required by GCP and applicable regulations (e.g., ICH E6, 21 CFR 50). | 41 |
| subject_management | lar_representative | master_data | Master record for a Legally Authorized Representative (LAR) associated with a trial subject who lacks capacity to consent independently. Stores LAR full name, relationship to subject, contact details, legal authority documentation type and reference | 43 |
| subject_management | reconsent_trigger | transactional_data | Records events that necessitate re-consent of a subject, such as a protocol amendment, new safety information, ICF version update, or regulatory authority requirement. | 48 |
| subject_management | withdrawal | transactional_data | Records the formal withdrawal of informed consent by a subject or their LAR. Captures withdrawal date and time, withdrawal reason category (voluntary, AE-related, sponsor decision, lost to follow-up), subject-stated reason free text, withdrawal type (full | 36 |

<a id="domain-datamanagement"></a>

### Domain: Datamanagement

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| datamanagement | operations | 2 | Governs clinical data collection, validation, and lock processes. Owns EDC/eCRF design and build (Medidata Rave), data validation rules, query management, discrepancy resolution, medical coding (MedDRA, WHO-DD), database lock (DBL) workflows, DMP, CDISC | 16 |

**Subdomains:** capture_operations, source_integration


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| capture_operations | codelist_term |  | One row per term of a CDISC codelist (Controlled Terminology). | 8 |
| capture_operations | coding_assignment | transactional_data | Transactional record of medical coding assignments applied to verbatim terms collected in eCRFs. Captures verbatim term, coding dictionary (MedDRA or WHO-DD), dictionary version, assigned code, preferred term (PT), system organ class (SOC), lowest level | 45 |
| capture_operations | discrepancy_query | transactional_data | Transactional record of ALL data queries (discrepancies) raised against eCRF data entries in Medidata Rave, serving as the single source of truth for data quality issues regardless of origin. | 43 |
| capture_operations | ecrf_field | master_data | Master definition of individual data fields within eCRF forms in Medidata Rave. Captures field name, label, data type (text, numeric, date, codelist), CDISC variable mapping (SDTM variable, domain), validation rules, required flag, controlled terminology | 46 |
| capture_operations | ecrf_form | master_data | Master definition of Electronic Case Report Form (eCRF) designs built in Medidata Rave EDC. Captures form name, version, study association, form type (visit-based, unscheduled, log/repeating), completion rules, CDISC SDTM domain mapping, data entry mode | 44 |
| capture_operations | field_entry | transactional_data | Atomic-level transactional record capturing a single field-level data entry in the EDC system (Medidata Rave). Stores the field value, entry timestamp, entered-by user, reason for change, previous value, audit trail reference, and ALCOA+ compliance flags | 49 |
| capture_operations | subject_visit_data | transactional_data | Transactional record of all eCRF data collected for a subject at a specific study visit in Medidata Rave. Captures subject identifier, visit name/number, visit date, form completion status (incomplete, complete, frozen, locked), data completeness | 42 |
| capture_operations | validation_rule | master_data | Master definition of programmatic data validation rules (edit checks) configured in Medidata Rave EDC. Captures rule name, rule expression/logic, trigger condition, associated form and field, severity level (error, warning), rule category (range check | 47 |
| source_integration | codelist | master_data | CDISC Controlled Terminology codelist reference table. Includes UNIT codelist (NCI C71620) for dose and age units, SEX (NCI C66731), RACE (NCI C74457), ETHNIC (NCI C66790), AGEU (NCI C66781), OUT (NCI C66768), ACN (NCI C66767), AESEV (NCI C66769), NCOMPLT | 7 |
| source_integration | define_document | master_data | Define-XML document. | 21 |
| source_integration | dmp | master_data | Master record for the Data Management Plan (DMP) governing all data management activities for a clinical study. Captures DMP version, effective date, study phase, EDC system configuration, data collection strategy, coding dictionaries and versions | 53 |
| source_integration | ehr_data_transfer | master_data | A single eSource data transfer batch from an EHR source system into the EDC. | 27 |
| source_integration | ehr_source_system | master_data | An external EHR / eSource system that supplies clinical data into the EDC via eSource flows. | 15 |
| source_integration | reconciliation | transactional_data | Transactional record of reconciliation activities performed between EDC data and external data sources (central lab, safety database, IRT/RTSM, ePRO). Captures reconciliation type, source system, target system, reconciliation date, discrepancy count | 56 |
| source_integration | sdtm_dataset | master_data | Master record for CDISC SDTM (Study Data Tabulation Model) dataset definitions and their submission-ready outputs. Captures dataset name (e.g., AE, CM, DM, LB, VS), SDTM domain class (Events, Interventions, Findings), SDTM IG version, study identifier | 47 |
| source_integration | sdtm_mapping | master_data | Detail-level record defining a single source-to-target transformation rule between a raw EDC eCRF field and a CDISC SDTM variable within a parent sdtm_dataset. | 49 |

<a id="domain-laboratory"></a>

### Domain: Laboratory

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| laboratory | operations | 3 | Manages central and local laboratory operations for clinical trials. Owns lab panel definitions, specimen collection and processing workflows, lab results (including PK/PD and DMPK data), reference ranges, critical values, sample chain of custody | 15 |

**Subdomains:** bioanalysis_results, lab_operations, specimen_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| bioanalysis_results | bioanalytical_assay | master_data | Master definition of a validated bioanalytical assay used to quantify drug concentrations, biomarkers, or immunogenicity in clinical trial samples. Captures assay name, analyte measured, assay type (LC-MS/MS, ELISA, ECL, PCR, flow cytometry), validation | 51 |
| bioanalysis_results | bioanalytical_result | transactional_data | Transactional record of a bioanalytical or biomarker assay result from a clinical trial PK/PD, DMPK, or exploratory biomarker sample. Captures assay run ID, sample ID, analyte/biomarker measured, concentration or categorical result value, unit/scale | 49 |
| bioanalysis_results | lab_result | transactional_data | Transactional record of a laboratory test result for a specific analyte from a subject specimen. Captures analyte name, LOINC code, result value, result unit, normal range lower/upper bound, reference range source, result status | 56 |
| bioanalysis_results | pk_sample | master_data | Master record for pharmacokinetic (PK) and pharmacodynamic (PD) samples collected per the study PK sampling schedule. Captures nominal and actual collection time relative to dose (pre-dose, post-dose hours), dose number, PK sampling window compliance | 52 |
| bioanalysis_results | reference_range | reference_data | Master definition of laboratory reference ranges (normal ranges) for analytes, with full version history. Captures analyte/LOINC code, lower and upper normal limits, unit of measure, sex, age range, ethnicity applicability, specimen type, lab facility | 46 |
| lab_operations | lab_facility | master_data | Master record for central and local laboratory facilities performing specimen analysis for clinical trials. Captures facility name, type (central/local/bioanalytical/PK), CLIA/CAP/ISO 15189 accreditation status, accreditation expiry, regulatory | 44 |
| lab_operations | lab_kit | master_data | Master record for laboratory collection kits supplied to clinical sites for specimen collection. Captures kit type, kit lot number, components list (tubes, containers, preservatives, requisition forms), storage requirements, expiry date, kit version, and | 44 |
| lab_operations | lab_panel | master_data | Master definition of a laboratory test panel or battery used in clinical trials. Captures panel code, name, specimen type requirements, analyte list, applicable study phases, CDISC SDTM domain mapping (LB), turnaround time SLA, and whether the panel is | 43 |
| lab_operations | lab_query | transactional_data | Transactional record of a data query raised against a laboratory result in the EDC (Medidata Rave) or LIMS. Captures query ID, query type (missing value/implausible result/unit mismatch/collection time deviation), query text, raised by (data | 46 |
| lab_operations | panel_capability | association_data | This association product represents the accreditation and capability relationship between lab_panel and lab_facility. It captures which laboratory facilities are validated, accredited, and operationally capable of performing which test panels. | 17 |
| lab_operations | protocol_lab_schedule | master_data | Master definition of the protocol-mandated laboratory assessment schedule for a study, mapping each study visit to required lab panels. Captures study ID, visit name/number, visit window (day range), required lab panels, optional panels, fasting | 49 |
| specimen_management | specimen | master_data | Master record for each biological specimen collected from a trial subject, including collection event details. Captures specimen barcode/ID, subject ID, visit reference, collection date/time, specimen type (blood, urine, CSF, tissue), collection tube | 44 |
| specimen_management | specimen_aliquot | master_data | Master record for aliquots derived from a primary specimen for distribution to multiple testing labs or long-term storage, including storage placement tracking. | 44 |
| specimen_management | specimen_collection | transactional_data | Transactional record of a scheduled or unscheduled specimen collection event at a clinical site or subject visit. Captures collection event date/time, study visit reference, protocol-scheduled vs. | 52 |
| specimen_management | specimen_shipment | transactional_data | Transactional record tracking the shipment of specimens from a clinical site to a central or reference laboratory. Captures shipment manifest ID, origin site, destination lab facility, courier name, tracking number, shipment date/time, expected arrival | 46 |

<a id="domain-monitoring"></a>

### Domain: Monitoring

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| monitoring | operations | 2 | Manages CRA monitoring activities including risk-based monitoring (RBM) strategies, on-site and remote monitoring visits (initiation, interim, close-out), source data verification (SDV), monitoring visit reports, query management, protocol deviation | 13 |

**Subdomains:** monitoring_planning, visit_execution


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| monitoring_planning | monitoring_cra_assignment | master_data | Assignment record linking a CRA to a specific site and study for monitoring responsibilities. Captures assignment dates, type (primary, backup, lead CRA), territory, workload allocation percentage, and status. | 42 |
| monitoring_planning | monitoring_plan | master_data | Master entity defining the risk-based monitoring (RBM) strategy for a clinical study. Specifies monitoring approach (on-site, remote, centralized), SDV scope and percentage thresholds, visit frequency rules, critical data/process definitions per ICH | 52 |
| monitoring_planning | monitoring_visit_schedule | master_data | Planned monitoring visit schedule for a site within a study, derived from the monitoring plan. Captures planned visit type, planned visit window (earliest and latest acceptable dates), visit frequency interval, basis for scheduling (risk-based trigger | 51 |
| monitoring_planning | risk_indicator | master_data | Centralized monitoring risk indicator (also known as Key Risk Indicator or KRI) defined within the RBM monitoring plan. Captures indicator name, category (enrollment, data quality, safety, protocol compliance, IP accountability), calculation method | 53 |
| monitoring_planning | site_risk_assessment | transactional_data | Periodic risk assessment of an investigational site within the RBM framework. Captures overall site risk score, individual KRI values and threshold breaches, risk tier classification (low, medium, high), assessment date, assessor, recommended monitoring | 51 |
| visit_execution | action_item | transactional_data | Formal action item raised as a result of a monitoring finding, protocol deviation, or escalation trigger. Tracks action description, responsible party (site staff, CRA, or sponsor), due date, priority level, current status (open, in-progress, overdue | 47 |
| visit_execution | escalation_record | transactional_data | Formal escalation record raised when action items, protocol deviations, or CAPAs are not resolved within defined timelines or when critical GCP findings require sponsor or management intervention. | 73 |
| visit_execution | ip_accountability_log | transactional_data | Investigational Product (IP) accountability verification record captured during monitoring visits. Records CRA verification of IP receipt, dispensing, return, and destruction records at the site level. | 57 |
| visit_execution | sdv_record | transactional_data | Source Data Verification (SDV) record capturing the verification of individual eCRF data points against source documents at the site. Tracks subject visit, eCRF field or data point verified, SDV outcome (verified, discrepancy found, not verifiable) | 54 |
| visit_execution | visit_checklist | master_data | Monitoring checklist template and completion record used by CRAs during visits. Defines checklist items (regulatory binder, ICF, IP accountability, eCRF, safety reporting), item categories, mandatory/optional flags, and captures per-item completion status | 47 |
| visit_execution | visit_deviation_finding | transactional_data | Record of each protocol deviation identified at a site during monitoring or data review. Captures deviation category and severity (major, minor, important), description, root cause, affected subject, dates of occurrence and identification, IRB/IEC and | 60 |
| visit_execution | visit_finding | transactional_data | Individual finding or observation recorded by a CRA during a monitoring visit or remote review. Captures finding category (data integrity, consent, IP accountability, safety reporting, regulatory compliance), severity, description, site response | 59 |
| visit_execution | visit_report | transactional_data | Formal monitoring visit report authored by the CRA following each on-site or remote monitoring visit. Captures visit summary narrative, findings, SDV results, protocol deviations identified, outstanding issues, action items raised, and CRA/supervisor | 51 |

<a id="domain-randomization"></a>

### Domain: Randomization

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| randomization | operations | 3 | Manages subject allocation algorithms, stratification factors, randomization codes, blinding integrity, and unblinding procedures. Integrated with eCRF and supply domains for kit assignment and treatment arm allocation via IRT/IVRS/RTSM systems. | 11 |

**Subdomains:** randomization_design, treatment_allocation, unblinding_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| randomization_design | blinding_config | master_data | Defines the blinding configuration for a randomization scheme, including blinding type (open-label, single-blind, double-blind, triple-blind), blinded roles (subject, investigator, sponsor, CRA, statistician), blinding method (identical packaging, dummy | 39 |
| randomization_design | irt_transaction | transactional_data | Detailed log of all IRT/IVRS/RTSM system transactions related to randomization and kit dispensing. Captures transaction type (randomization, re-randomization, cancellation, kit assignment, dose change, titration), transaction timestamp, IRT system | 42 |
| randomization_design | rand_code | master_data | Individual randomization code (slot) within a randomization list. Each code represents a single subject allocation slot with its sequential position number, pre-assigned treatment arm, stratification cell membership, kit code linkage for IMP dispensing | 39 |
| randomization_design | rand_list | master_data | The generated randomization list produced from a randomization scheme. Stores the ordered sequence of treatment assignments, list version, generation timestamp, generation method, blinding level, and approval status. | 42 |
| randomization_design | rand_scheme | master_data | Master definition of a randomization scheme for a clinical study. Captures the allocation algorithm type (simple, block, stratified, minimization, adaptive), block sizes, allocation ratio, seed values, and scheme version. | 42 |
| randomization_design | stratification_factor | master_data | Defines the stratification factors used in a randomization scheme, including factor name, factor code, data source (eCRF field reference), factor type (categorical, continuous-binned), enumerated levels (level code, label, sort order, active status), and | 39 |
| treatment_allocation | kit_assignment | transactional_data | Records the assignment of an investigational medicinal product (IMP) kit to a subject at a specific visit, as triggered by the IRT/RTSM system following randomization or resupply. | 41 |
| treatment_allocation | subject_randomization | transactional_data | Transactional record of a subject's randomization or re-randomization event. Captures the subject identifier, study site, randomization number assigned, treatment arm allocated, stratification cell, randomization timestamp, IRT/IVRS transaction reference | 44 |
| treatment_allocation | treatment_arm | master_data | Master definition of each treatment arm within a clinical study. Captures arm name, arm code, arm type (experimental, active comparator, placebo, open-label extension), blinding role, target allocation percentage, and arm status. | 39 |
| unblinding_management | unblinding_approval | transactional_data | Records the approval or rejection decision for an unblinding request. Captures the approver role (medical monitor, PI, sponsor medical officer), decision (approved, rejected, escalated), decision rationale, decision timestamp, and any conditions attached | 40 |
| unblinding_management | unblinding_request | transactional_data | Transactional record of a request to unblind a subject's treatment assignment, encompassing the full request-through-resolution lifecycle including multi-level approval steps. | 50 |

<a id="domain-safety"></a>

### Domain: Safety

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| safety | operations | 2 | Manages adverse events (AE), serious adverse events (SAE), suspected unexpected serious adverse reactions (SUSAR), and safety signal detection. Owns MedDRA coding (SOC/PT/LLT), CTCAE severity grading, causality assessments, expedited regulatory reporting | 14 |

**Subdomains:** event_management, safety_oversight


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| event_management | adverse_event | transactional_data | Core master record for every adverse event (AE) reported during a clinical trial, capturing onset date, resolution date, severity grade per CTCAE, seriousness flag, expectedness, relationship to investigational product, action taken, outcome, and | 57 |
| event_management | ae_follow_up | transactional_data | Transactional record capturing follow-up information updates for an adverse event after the initial report, including updated severity grade, new causality assessment, additional clinical details, outcome update, and resolution date. | 53 |
| event_management | ae_meddra_coding | master_data | Stores the MedDRA coding assignment for each adverse event, capturing the verbatim term reported, the coded Lowest Level Term (LLT), Preferred Term (PT), High Level Term (HLT), High Level Group Term (HLGT), and System Organ Class (SOC). | 40 |
| event_management | causality_assessment | transactional_data | Records the investigator and sponsor medical monitor causality assessments for each adverse event relative to the investigational product and concomitant medications. | 49 |
| event_management | icsr | transactional_data | Individual Case Safety Report (ICSR) — the formal regulatory submission record for expedited safety reporting to health authorities (FDA, EMA, PMDA, MHRA). | 48 |
| event_management | narrative | transactional_data | Stores the structured clinical narrative for SAEs and SUSARs, including case summary, patient description, event description, treatment details, outcome, and medical monitor commentary. | 49 |
| event_management | serious_adverse_event | transactional_data | Transactional record for Serious Adverse Events (SAEs) that meet regulatory seriousness criteria (death, life-threatening, hospitalization, disability, congenital anomaly, or other medically important condition). | 55 |
| event_management | susar | transactional_data | Transactional record for Suspected Unexpected Serious Adverse Reactions (SUSARs) — SAEs that are both unexpected (not in the Investigator Brochure) and causally related to the investigational product. | 52 |
| safety_oversight | dsmb_recommendation | transactional_data | Transactional record for formal DSMB/DMC recommendations issued following a safety review meeting. Captures recommendation type (continue unchanged, protocol amendment required, dose modification, study suspension, early termination), rationale, sponsor | 42 |
| safety_oversight | dsmb_review | master_data | Master record for Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) safety governance, covering both committee definition and individual review meetings. | 51 |
| safety_oversight | dsur | transactional_data | Development Safety Update Report (DSUR) — the annual periodic safety report submitted to health authorities summarizing cumulative safety data for an investigational product across all ongoing studies. | 55 |
| safety_oversight | dsur_signal_summary | association_data | This association product represents the periodic reporting relationship between a Development Safety Update Report (DSUR) and a safety signal. It captures the signal's status, evaluation progress, and regulatory actions within a specific DSUR reporting | 12 |
| safety_oversight | signal | master_data | Master record for identified safety signals and their full evaluation lifecycle. Captures signal description, detection method (disproportionality analysis, PRR, ROR, BCPNN, clinical review, literature), detection date, data source, signal strength | 43 |
| safety_oversight | signal_evaluation | transactional_data | Transactional record capturing the formal evaluation workflow for a safety signal, including evaluation plan, data reviewed, benefit-risk assessment, regulatory action recommended (label update, DHPC, study suspension, protocol amendment), evaluation | 48 |

<a id="domain-site"></a>

### Domain: Site

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| site | operations | 2 | Manages investigational sites including feasibility assessment, site selection, activation, PI qualifications, CRC assignments, IRB/IEC approval records, site performance metrics, monitoring visit scheduling, and close-out. | 14 |

**Subdomains:** site_management, study_operations


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| site_management | agreement | master_data | Tracks site-level contractual agreements including Clinical Trial Agreements (CTA), Confidential Disclosure Agreements (CDA), and site-specific budget agreements. | 49 |
| site_management | contact | master_data | Site contact - site owns its own contact; distinct from sponsor_contact and subject_contact. | 45 |
| site_management | investigational_site | master_data | Master record for each investigational site participating in clinical trials. Captures site identity, physical address, facility type, therapeutic area specializations, GCP certification status, regulatory registration numbers (e.g., FDA FEI, DUNS), site | 42 |
| site_management | principal_investigator | master_data | Master record for Principal Investigators (PIs) conducting clinical trials. Captures PI credentials, medical license numbers, specialty, board certifications, GCP training history, FDA Form 1572 submission status, financial disclosure status, debarment | 44 |
| site_management | site_cra_assignment | master_data | Records the assignment of Clinical Research Associates (CRAs) to study-site combinations for monitoring coverage. Captures CRA identity reference (FK to workforce domain), assignment start/end dates, assignment type (primary, backup, co-monitor) | 49 |
| site_management | study_site | master_data | Association entity representing the full lifecycle relationship between a specific study (protocol) and an investigational site, from selection through activation to closeout. | 49 |
| study_operations | activation | transactional_data | Tracks the end-to-end site activation workflow milestones from site selection through first patient first visit (FPFV). Captures completion dates and status for each activation task: confidentiality agreement execution, protocol receipt, IRB/IEC | 53 |
| study_operations | closeout | transactional_data | Records the formal site close-out process for a study-site upon completion or early termination. Captures close-out visit date, last subject last visit (LSLV) date, database lock contribution date, drug accountability reconciliation status, essential | 61 |
| study_operations | enrollment_performance | transactional_data | Tracks actual vs. planned enrollment performance at the study-site level over time. Captures reporting period, planned enrollment target, actual subjects screened, subjects enrolled, screen failure count, screen failure rate, dropout count, and cumulative | 54 |
| study_operations | feasibility_assessment | transactional_data | Records the site feasibility evaluation conducted prior to site selection for a specific study. Captures feasibility questionnaire responses, estimated enrollment capacity, patient population availability, competing trial load, infrastructure readiness | 43 |
| study_operations | initiation_visit | transactional_data | Records the Site Initiation Visit (SIV) event conducted by the CRA prior to first patient enrollment. Captures visit date, CRA assigned, attendees, training topics covered (protocol, EDC, RTSM, safety reporting, ICF process), action items identified | 50 |
| study_operations | irb_iec_approval | transactional_data | Records IRB (Institutional Review Board) and IEC (Independent Ethics Committee) approvals for a study-site combination. Captures submission date, approval date, approval number, expiration date, continuing review due date, approved protocol version | 43 |
| study_operations | regulatory_submission_site | transactional_data | Tracks site-level regulatory submissions required for trial conduct, including FDA Form 1572 (Statement of Investigator), financial disclosure forms (FDA Form 3454/3455), local health authority notifications, and country-specific site authorization | 45 |
| study_operations | selection | transactional_data | Records the formal site selection decision for a study-site pairing, including selection rationale, selection committee approval, selection date, rejection reasons (if applicable), and the transition from feasibility to activation. | 45 |

<a id="domain-study"></a>

### Domain: Study

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| study | operations | 2 | Core operational domain managing clinical study protocols, design, phases, objectives, endpoints, inclusion/exclusion criteria, visit schedules, and study lifecycle from protocol development through database lock. | 12 |

**Subdomains:** study_design, trial_operations


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| study_design | arm | master_data | Defines each treatment arm or cohort within a clinical study. Records arm name, arm code, arm type (experimental, active comparator, placebo comparator, sham comparator, no intervention, other), description of intervention, planned number of subjects per | 40 |
| study_design | eligibility_criterion | master_data | Defines inclusion and exclusion criteria for subject enrollment in a clinical study. Records criterion number, criterion type (inclusion/exclusion), criterion text, criterion category (demographic, diagnosis, lab value, prior therapy, concomitant | 40 |
| study_design | endpoint | master_data | Defines the formal objectives and their associated endpoints (primary, secondary, exploratory) for a clinical study. Captures objective text, objective type, endpoint name, endpoint type (primary, secondary, exploratory, safety, PK, PD, biomarker) | 40 |
| study_design | epoch | master_data | Defines the temporal epochs (periods) of a clinical study such as Screening, Run-in, Treatment Period 1, Washout, Treatment Period 2, Follow-up, and Extension. | 39 |
| study_design | objective | master_data | Formally documents the primary, secondary, and exploratory objectives of a clinical study as stated in the protocol. Captures objective number, objective type (primary, secondary, exploratory), objective text, associated endpoint references, ICH E9(R1) | 37 |
| study_design | protocol | master_data | Master record for the clinical study protocol including all formal amendments (version history). Captures protocol number, version, title, phase, therapeutic area, indication, investigational product, study design parameters (allocation method | 43 |
| study_design | study | master_data | Top-level master entity representing a clinical trial as a business and operational unit. Captures the unique study identifier (sponsor study number, ClinicalTrials.gov NCT number, EudraCT number), study title, acronym, therapeutic area, indication | 35 |
| study_design | study_protocol_amendment | transactional_data | Tracks all formal amendments to an approved clinical study protocol. Records amendment number, amendment date, amendment type (substantial/non-substantial), description of changes, rationale, regulatory submission status per health authority (FDA, EMA | 41 |
| study_design | study_visit_schedule | master_data | Defines the planned Schedule of Events (SoE) for a clinical study including all visits and their required procedures. Captures visit name, visit number, visit type (screening, baseline, treatment, follow-up, unscheduled, end-of-study), planned study | 41 |
| trial_operations | country | master_data | Manages the countries in which a clinical study is conducted including country-level enrollment planning. Records country code (ISO 3166), country name, regulatory authority, CTA/IND submission and approval dates, approval status, first site activation | 43 |
| trial_operations | dosing_regimen | master_data | Defines the dosing regimen for each investigational product within a study arm. Records regimen name, dose level, dose unit, dosing frequency, dosing route, dosing duration, dose escalation scheme (for dose-escalation studies), dose modification rules | 41 |
| trial_operations | investigational_product | master_data | Master record for the investigational medicinal product (IMP) or device used in a clinical study. Captures IMP name, INN (International Nonproprietary Name), drug code, formulation, dosage form, route of administration, strength, manufacturer, IND/IMPD | 42 |

<a id="domain-subject"></a>

### Domain: Subject

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| subject | operations | 3 | SSOT for trial participants (subjects/patients) across all studies. Owns subject enrollment, demographics, randomization assignments via IRT/RTSM, treatment arms, visit compliance, protocol deviations, and subject disposition from screening through study | 13 |

**Subdomains:** participant_data, subject_management, visit_oversight


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| participant_data | concomitant_medication | Master | Records medications taken by subjects before and during the trial, including drug name, indication, dose, route, start/stop dates, and WHO-DD coding. | 40 |
| participant_data | demographic | Master | Captures subject demographic data including age, sex, race, ethnicity, height, weight, and other baseline characteristics collected at screening per CDISC DM domain standards. | 41 |
| participant_data | eligibility_assessment | transactional_data | Transactional record of the inclusion/exclusion criteria assessment performed for a subject during screening. Captures each criterion code, criterion text, assessment result (met/not met/not assessed), assessment date, assessor identity, and overall | 45 |
| participant_data | medical_history | Master | Records subject medical history and pre-existing conditions collected during screening, coded to MedDRA terms, with onset dates, resolution status, and relevance to study eligibility. | 41 |
| subject_management | disposition | transactional_data | Transactional record capturing each formal disposition milestone of a subject through the study lifecycle (screened, enrolled, randomized, completed, discontinued, withdrawn, lost to follow-up, death). | 55 |
| subject_management | enrollment | transactional_data | Transactional record capturing the formal enrollment event of a subject into a clinical study at a specific investigational site. Tracks screening date, enrollment date, randomization eligibility confirmation, enrollment status (screened, enrolled | 53 |
| subject_management | randomization_assignment | transactional_data | Transactional record of a subject's randomization event, capturing the randomization code, treatment arm assignment, stratification factor values applied at randomization, randomization date and time, IRT/RTSM transaction reference, blinding status, and | 47 |
| subject_management | status_history | transactional_data | Lifecycle history table tracking every status transition of a trial subject across the enrollment lifecycle (e.g., pre-screened → screened → screen-failed → enrolled → randomized → on-treatment → completed → withdrawn). | 45 |
| subject_management | subject_consent | association_data | This association product represents the Informed Consent Event between a trial_subject and a document_icf_version. It captures the complete regulatory audit trail of every consent and re-consent signing event for each subject across all ICF versions | 19 |
| subject_management | trial_subject | master_data | Core master entity representing a unique trial participant (subject/patient) screened or enrolled in a clinical study. Serves as the SSOT for subject identity including screening number, subject number, randomization number, demographic profile (age, sex | 37 |
| visit_oversight | deviation | transactional_data | Transactional record of a protocol deviation identified for a subject, capturing deviation category (major, minor, important), deviation type code, description, date of occurrence, date identified, root cause, impact on subject safety and data integrity | 55 |
| visit_oversight | sdv_review | association_data | This association product represents the Source Data Verification (SDV) Review event between a subject_visit and a monitoring_visit. It captures the operational record of a CRA reviewing a specific subject visit during a specific monitoring visit | 19 |
| visit_oversight | visit | transactional_data | Single owner of a subject's protocol-scheduled study visit (clinical visit). | 39 |

<a id="domain-supply"></a>

### Domain: Supply

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| supply | operations | 4 | Manages investigational medicinal product (IMP) and clinical supply chain operations. Owns drug supply planning, depot and site inventory, randomization kits, dispensing records via RTSM (Medidata Rave), expiry management, returns and destruction | 15 |

**Subdomains:** inventory_control, product_management, site_operations, supply_logistics


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| inventory_control | depot | master_data | Master record for clinical supply depots (central and regional warehouses) that store and distribute IMPs. Captures depot name, geographic location, GMP certification status, temperature-controlled storage capabilities (ambient, refrigerated, frozen) | 46 |
| inventory_control | kit_inventory | master_data | Tracks physical randomization kit instances across the supply chain — from manufacture through depot receipt, site shipment, dispensing, and destruction. Each record represents a unique kit number with current status (available, assigned, dispensed | 45 |
| inventory_control | site_inventory | master_data | Tracks IMP and kit stock positions at supply chain nodes (investigational sites and depots). Each record represents current inventory levels by IMP/kit type at a specific location, including quantity on-hand, received, dispensed, allocated, quarantined | 50 |
| product_management | imp_master | master_data | Master record for all investigational and comparator products used in clinical trials, including sponsor IMPs, active comparators, and placebos. Captures product identity, product type (IMP/comparator/placebo), formulation details, dosage form, strength | 48 |
| product_management | kit_definition | master_data | Defines randomization kit configurations used in RTSM (Medidata Rave). Captures kit type, treatment arm association, blinding level, component IMPs, pack size, label text, kit number range, and applicable study/protocol version. | 42 |
| product_management | manufacture_batch | master_data | Records IMP manufacturing batch details including batch number, manufacturing date, batch size, manufacturing site, GMP certificate of analysis reference, release status (quarantine, released, rejected), expiry date, and storage conditions. | 47 |
| site_operations | accountability_reconciliation | transactional_data | Periodic drug accountability reconciliation record at the site level, capturing the reconciliation period, opening balance, receipts, dispensed quantities, returned quantities, destroyed quantities, closing balance, discrepancy count and detail | 56 |
| site_operations | destruction_record | transactional_data | Records the destruction of returned, expired, or rejected IMP/kits. Captures destruction authorization number, destruction date, destruction method (incineration, chemical neutralization), facility, quantity and kit numbers destroyed, witness details, and | 52 |
| site_operations | dispensing_record | transactional_data | Captures each IMP dispensing event at an investigational site, recording the subject identifier, visit reference, kit number dispensed, IMP name, dose, quantity dispensed, dispensing date and time, dispensing staff, and RTSM confirmation number. | 52 |
| site_operations | return_record | transactional_data | Documents IMP/kit returns from subjects to sites and from sites to depots. Captures return type (subject return, site-to-depot, expired stock), kit numbers or quantities returned, return date, condition on return (intact, partially used, damaged) | 54 |
| site_operations | supply_plan | master_data | Clinical supply plan - distinct concept, separate owner from monitoring_plan and program_plan. | 49 |
| site_operations | temperature_excursion | transactional_data | Records cold-chain temperature excursion events detected during IMP storage or transit. Captures excursion start and end timestamps, affected location (depot, site, in-transit), temperature range breached, duration, affected kit/batch numbers, impact | 49 |
| supply_logistics | resupply_order | transactional_data | Captures resupply order requests triggered by RTSM resupply algorithms or manual supply manager intervention. Records the requesting site or depot, IMP/kit type requested, quantity requested, urgency level, order date, expected fulfillment date | 45 |
| supply_logistics | shipment | transactional_data | Transactional record of IMP/kit shipments between supply chain nodes (manufacturer to depot, depot to site, site to site, site to depot for returns). Captures shipment number, origin, destination, carrier, tracking number, shipment date, expected delivery | 46 |
| supply_logistics | shipment_line | transactional_data | Line-level detail for each IMP shipment, capturing individual kit numbers or batch quantities included in a shipment. Each line records the IMP/kit reference, quantity shipped, unit of measure, lot/batch number, expiry date, and line-level receipt | 41 |

<a id="domain-compliance"></a>

### Domain: Compliance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| compliance | corporate | 4 | Manages GCP quality assurance (QA), quality control (QC), internal and external audits, regulatory inspections, CAPA lifecycle, protocol deviation classifications, SOP compliance tracking, and audit readiness. | 11 |

**Subdomains:** audit_control, ethics_oversight, quality_management, study_deviations


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| audit_control | audit | master_data | Master record for all internal and external GCP audits conducted across studies, sites, systems, and vendors. Captures audit type (system, process, vendor, site, TMF), scope, lead auditor, planned and actual dates, audit status, sponsoring organization | 40 |
| audit_control | audit_finding | transactional_data | Transactional record of individual findings identified during an internal or sponsor-initiated GCP audit. Captures finding reference number, finding category (critical, major, minor, observation), finding description, ICH GCP clause reference, regulatory | 46 |
| audit_control | capa | master_data | Master record for Corrective and Preventive Actions (CAPA) initiated in response to audit findings, inspection findings, protocol deviations, QC failures, or self-identified quality issues. | 43 |
| audit_control | inspection_finding | transactional_data | Transactional record of individual findings issued by a regulatory authority during a formal inspection. Captures finding number, regulatory citation (e.g., FDA Form 483 observation, EMA GCP non-compliance), finding classification (critical, major | 53 |
| ethics_oversight | ethics_approval | Master | Records the formal approval decision issued by an IRB or IEC for a study protocol, ICF, or amendment including approval conditions and expiry dates | 44 |
| ethics_oversight | ethics_committee | Master | Master record for each IRB or IEC body providing ethical oversight for clinical trials, capturing committee name, type, jurisdiction, and accreditation status | 47 |
| ethics_oversight | ethics_submission | Master | Tracks each formal submission package sent to an IRB or IEC for a specific study, including initial review, amendments, and continuing review submissions | 41 |
| quality_management | compliance_sop | master_data | Master record for Standard Operating Procedures (SOPs) managed within the quality management system. Captures SOP number, title, version, effective date, expiry date, SOP owner (department/role), applicable process area, regulatory basis (GCP, GLP, GMP) | 42 |
| quality_management | quality_event | transactional_data | Transactional record capturing quality events identified through QC reviews, self-inspections, routine quality monitoring, or proactive quality surveillance activities. | 61 |
| study_deviations | protocol_deviation | transactional_data | Transactional record of protocol deviations identified during study conduct. Captures deviation reference number, study and site identifiers, subject identifier (if applicable), deviation category (major, minor, important), deviation type (eligibility | 50 |
| study_deviations | risk_assessment | master_data | Master record for quality risk assessments conducted at study, site, process, system, or inspection-readiness level to support risk-based quality management (RBQM). | 52 |

<a id="domain-document"></a>

### Domain: Document

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| document | corporate | 3 | SSOT for Trial Master File (TMF/eTMF) essential documents, SOP library, regulatory binders, site files, controlled document versioning, document workflows, DIA TMF Reference Model compliance, inspection readiness, and archival per ICH GCP requirements. | 9 |

**Subdomains:** document_lifecycle, operating_procedures, regulatory_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| document_lifecycle | signature | transactional_data | Records electronic signatures applied to controlled documents per 21 CFR Part 11 requirements. Captures signer identity, signer role (author, reviewer, approver, sponsor representative), signature date and timestamp, signature meaning (reviewed, approved | 40 |
| document_lifecycle | tmf_document | master_data | Core master entity representing an essential document within the Trial Master File (TMF/eTMF) as defined by the DIA TMF Reference Model. Captures document identity, TMF zone/section/artifact classification, title, version, lifecycle status (draft | 40 |
| document_lifecycle | version | transactional_data | Tracks the full version history of every controlled document in the TMF and SOP library. Each record represents a discrete version of a document, capturing version number, effective date, expiry date, version status (draft, in-review, approved | 40 |
| document_lifecycle | workflow | transactional_data | Tracks the lifecycle workflow state of a document through its review, approval, and distribution process within Veeva Vault. Captures workflow instance ID, workflow template name, current workflow step, step assignee role, step due date, step completion | 47 |
| operating_procedures | document_sop | master_data | Master entity for Standard Operating Procedures (SOPs) in the controlled document library (MasterControl). Each record represents one SOP with: SOP number, title, current version, effective/expiry dates, category (clinical operations, data management | 40 |
| operating_procedures | tmf_artifact | reference_data | Reference entity defining the DIA TMF Reference Model artifact taxonomy — the standardized classification of document types by Zone, Section, and Artifact number (e.g., Zone 1 Section 1.1 Artifact 01 - Protocol). | 43 |
| regulatory_management | regulatory_binder | master_data | Master entity representing a regulatory submission binder or eCTD sequence package assembled for health authority submissions (IND, NDA, BLA, MAA, CTA). Captures binder ID, binder type (IND, NDA, BLA, MAA, CTA, annual report), submission sequence number | 36 |
| regulatory_management | regulatory_filing | association_data | This association product represents the filing relationship between a regulatory submission binder and a TMF document. It captures the regulatory context in which a specific TMF document is included in a specific regulatory submission package. | 12 |
| regulatory_management | site_file | master_data | Master entity representing the Investigator Site File (ISF) or Regulatory Binder maintained at each investigational site. Captures site file ID, associated study, associated site, file type (ISF, regulatory binder, pharmacy binder), physical or electronic | 43 |

<a id="domain-regulatory"></a>

### Domain: Regulatory

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| regulatory | corporate | 3 | Manages regulatory submissions, approvals, and agency interactions across global health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Owns IND/NDA/BLA/MAA applications, clinical trial authorizations, protocol amendments, regulatory correspondence | 11 |

**Subdomains:** application_tracking, authority_registry, regulatory_submissions


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| application_tracking | application | master_data | Master record for regulatory applications (IND, NDA, BLA, MAA, CTA, IMPD) filed with health authorities. Tracks application number, application type and subtype, therapeutic area, indication, sponsor reference, lead agency, application status (active | 39 |
| application_tracking | clinical_trial_authorization | master_data | Master record for Clinical Trial Authorizations (CTAs) issued by national competent authorities under EU CTR 536/2014, national regulations, and equivalent non-US frameworks. | 43 |
| application_tracking | ind_application | master_data | Specialized master record for Investigational New Drug (IND) applications filed with the FDA (or equivalent CTAs with EMA/MHRA). Tracks IND number, IND type (commercial, research, emergency), sponsor name, investigational product name, phase coverage | 43 |
| application_tracking | nda_bla_application | master_data | Specialized master record for New Drug Applications (NDA), Biologics License Applications (BLA), and equivalent marketing authorization applications (MAA). | 43 |
| authority_registry | approval | transactional_data | Records regulatory approvals, authorizations, and decisions received from health authorities. Captures approval type (IND allowance, NDA approval, MAA approval, CTA authorization, label approval), approval date, effective date, approved indication | 41 |
| authority_registry | country_registration | master_data | Tracks product registration status and requirements across individual countries and jurisdictions. Captures country, registration number, registration type (national, mutual recognition, decentralized, centralized), registration date, expiry date, renewal | 43 |
| authority_registry | health_authority | reference_data | Reference master for global health authority organizations (FDA, EMA, PMDA, MHRA, Health Canada, TGA, ANVISA, NMPA, etc.). Stores agency code, full name, country/region, regulatory framework, submission portal URL, eCTD gateway identifier, contact | 44 |
| regulatory_submissions | regulatory_protocol_amendment | transactional_data | Tracks protocol amendments submitted to health authorities and ethics committees. Captures amendment number, amendment type (substantial/non-substantial), amendment rationale, affected study sections, submission date to each agency, agency acknowledgment | 42 |
| regulatory_submissions | safety_report_submission | transactional_data | Tracks regulatory safety report submissions including IND Annual Reports, Development Safety Update Reports (DSURs), Periodic Safety Update Reports (PSURs/PBRERs), and expedited SUSAR/IND safety reports. | 38 |
| regulatory_submissions | submission | master_data | Master record for regulatory submissions and eCTD sequences sent to health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Each record represents a discrete submission event with sequence number, submission type (original, amendment, supplement | 40 |
| regulatory_submissions | submission_sequence | transactional_data | Tracks individual eCTD submission sequences within a regulatory application. Each sequence has a sequence number, submission type (original, amendment, supplement, response, withdrawal), sequence date, eCTD lifecycle operation (new, replace, append | 32 |

## Metric Views

Total metric views generated: **93**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | biostatistics_analysis_population | biostatistics | analysis_population | Strategic view of analysis populations, supporting enrollment monitoring and primary cohort definition. |
| 2 | biostatistics_database_lock_event | biostatistics | database_lock_event | Database lock event metrics tracking lock cycle time, query resolution efficiency, and data quality readiness for regulatory submissions. |
| 3 | biostatistics_interim_analysis | biostatistics | interim_analysis | Key performance indicators for interim analyses, supporting monitoring of statistical thresholds and stopping decisions. |
| 4 | biostatistics_sample_size_calc | biostatistics | sample_size_calc | Metrics that evaluate the design assumptions and scale of planned clinical studies. |
| 5 | biostatistics_sap | biostatistics | sap | Statistical Analysis Plan metrics tracking SAP version control, amendment frequency, regulatory alignment, and approval cycle time. |
| 6 | biostatistics_tlf_output | biostatistics | tlf_output | TLF output production metrics tracking programming productivity, QC cycle time, approval rates, and discrepancy resolution efficiency. |
| 7 | consent_capacity_assessment | consent | capacity_assessment | Capacity assessment KPIs tracking assessment outcomes, vulnerable population identification, LAR requirement rates, and reassessment compliance. |
| 8 | consent_econsent_session | consent | econsent_session | eConsent platform performance and subject engagement KPIs tracking session completion, comprehension pass rates, technical issues, and digital signature capture. |
| 9 | consent_reconsent_trigger | consent | reconsent_trigger | Reconsent trigger and campaign management KPIs tracking trigger types, affected subject populations, reconsent completion rates, and regulatory compliance. |
| 10 | consent_subject | consent | consent_subject_consent | Core consent KPI view – tracks consent volume, grant outcomes, comprehension quality and re‑consent activity |
| 11 | consent_subject_consent | consent | consent_subject_consent | Core consent KPIs tracking consent acquisition, reconsent activity, withdrawal rates, and comprehension assessment outcomes for clinical trial subjects. |
| 12 | consent_withdrawal | consent | withdrawal | Withdrawal KPI view – monitors withdrawal volume, timeliness relative to consent, and regulatory notification requirements |
| 13 | datamanagement_codelist_term_coverage | datamanagement | codelist_term | Measures the completeness of CDISC controlled terminology implementation by codelist, tracking how many terms have NCI concept codes, submission values, and definitions populated. |
| 14 | datamanagement_coding_assignment | datamanagement | coding_assignment | Key coding assignment KPIs for monitoring coding quality and throughput |
| 15 | datamanagement_discrepancy_query | datamanagement | discrepancy_query | Operational KPI view for discrepancy query management and safety monitoring |
| 16 | datamanagement_subject_visit_data | datamanagement | subject_visit_data | Visit‑level KPIs to assess data capture quality and query load |
| 17 | laboratory_assay_performance | laboratory | bioanalytical_assay | Key performance indicators for bioanalytical assay quality and throughput |
| 18 | laboratory_bioanalytical_result | laboratory | bioanalytical_result | Bioanalytical PK/PD assay results with concentration measurements, quality control flags, and time-point deviations for pharmacokinetic analysis |
| 19 | laboratory_lab_facility | laboratory | lab_facility | Laboratory facility capabilities, certifications, and operational capacity for vendor qualification and site selection |
| 20 | laboratory_lab_query | laboratory | lab_query | Laboratory data queries with resolution tracking, SLA compliance, and escalation monitoring for data quality management |

*... and 73 more metric views. See the `metrics/` folder for full details.*