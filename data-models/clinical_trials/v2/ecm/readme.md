# Clinical_Trials Lakehouse Data Model

**v2_ecm** generated using Vibe Modelling Agent on November 19, 2026 at 04:30 PM

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
  - [Agreement](#domain-agreement)
  - [Program](#domain-program)
  - [Sponsor](#domain-sponsor)
  - [Terminology](#domain-terminology)
  - [Compliance](#domain-compliance)
  - [Document](#domain-document)
  - [Finance](#domain-finance)
  - [Regulatory](#domain-regulatory)
  - [Workforce](#domain-workforce)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v2_ecm** are organized as follows:

```
v2/ecm/
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
| `schemas/` | `clinical_trials_<domain>_schema_v2_ecm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `clinical_trials_catalogs_v2_ecm.sql` (catalog-level DDL) |
| `metrics/` | `clinical_trials_<domain>_metrics_v2_ecm.sql` (one file per domain) |
| `docs/` | `clinical_trials_model_v2_ecm.xlsx`, `clinical_trials_model_v2_ecm.csv`, `releasenotes.txt` |
| `diagram/` | `clinical_trials_dbml_v2_ecm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `clinical_trials_rdf_v2_ecm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | ECM (Expanded Coverage Model) |
| Total Domains | 20 |
| Total Subdomains | 67 |
| Total Products | 456 |
| Total Attributes | 16159 |
| Primary Keys | 455 |
| Foreign Keys | 3304 |
| Avg Attributes/Product | 35.4 |
| Metric Views | 0 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Clinical_Trials | clinical-research | ECM (Expanded Coverage Model) | Clinical Trials is a specialized industry that designs, manages, and monitors clinical research studies for pharmaceutical and biotech sponsors, providing data analytics, regulatory expertise, and patient recruitment to accelerate drug development. | FDA (U.S. Food and Drug Administration), EMA (European Medicines Agency), ICH (International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use), MHRA (Medicines and Healthcare products Regulatory Agency - UK), PMDA (Pharmaceuticals and Medical Devices Agency - Japan), TGA (Therapeutic Goods Administration - Australia), Health Canada, CDISC (Clinical Data Interchange Standards Consortium), WHO (World Health Organization - International Clinical Trials Registry Platform), OHRP (Office for Human Research Protections - U.S.), ISO 14155 (Clinical Investigation of Medical Devices), 21 CFR Part 11 (Electronic Records and Signatures), EU Clinical Trials Regulation (EU CTR 536/2014), GDPR (General Data Protection Regulation - patient data privacy), HIPAA (Health Insurance Portability and Accountability Act - U.S. patient data), SOX (Sarbanes-Oxley Act - financial reporting controls) | 13 |

## Business Domains & Subdomains

<a id="domain-biostatistics"></a>

### Domain: Biostatistics

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| biostatistics | operations | 4 | Owns the statistical planning and analysis lifecycle for clinical trials. Manages the source system versioning, randomization scheme design, sample size calculations, ADaM dataset specifications, TLF production, interim and final analyses | 21 |

**Subdomains:** analysis_planning, dataset_specification, results_production, safety_oversight


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| analysis_planning | analysis_population | master_data | Defines the analysis populations used in a study (e.g., Intent-to-Treat, Per Protocol, Safety, Modified ITT, Pharmacokinetic). Captures population name, acronym, inclusion/exclusion logic description, CDISC ADSL flag variable name, population size at DBL | 39 |
| analysis_planning | estimand | master_data | Estimand definition record per the ICH E9(R1) framework for a study endpoint. Captures treatment condition, target population, variable (endpoint), intercurrent event handling strategies (treatment policy, hypothetical, composite, while on treatment | 41 |
| analysis_planning | sample_size_calc | transactional_data | Records sample size calculations performed during study design and protocol development. Captures study phase, primary endpoint type, assumed effect size, standard deviation, alpha level, power, dropout rate, allocation ratio, calculated sample size per | 46 |
| analysis_planning | sap | master_data | Statistical Analysis Plan master record for a clinical study. Captures the source system (including amendments with rationale, sections modified, and regulatory impact), authoring status, approval workflow, blinding status, primary/secondary endpoint | 50 |
| analysis_planning | sap_amendment | transactional_data | Versioned amendment record for a Statistical Analysis Plan. Tracks each the source system amendment number, rationale for change, sections modified, pre- or post-database-lock classification, author, approver, approval date, and regulatory impact | 46 |
| analysis_planning | statistical_endpoint | master_data | Master record for each statistical endpoint defined in the the source system study. Captures endpoint name, classification (primary, secondary, exploratory, safety), endpoint type (efficacy, PK, PD, biomarker, PRO), measurement scale, analysis timepoint(s) | 41 |
| dataset_specification | adam_dataset_spec | master_data | Specification record for each ADaM (Analysis Data Model) dataset produced for a study, including variable-level detail. Captures dataset name (e.g., ADSL, ADAE, ADTTE, ADLB), dataset class (ADSL, BDS, OCCDS, OTHER), purpose, key variables with derivation | 43 |
| dataset_specification | adam_variable_spec | master_data | Detailed variable-level specification within an ADaM dataset. Captures variable name, label, type (character/numeric), length, derivation algorithm, controlled terminology reference, CDISC ADaM core designation (Required/Expected/Permissible/Conditionally | 44 |
| dataset_specification | pk_analysis_spec | master_data | Pharmacokinetic (PK) analysis specification record. Captures PK parameters to be estimated (AUC, Cmax, Tmax, t½, CL, Vd), compartmental model type, non-compartmental analysis (NCA) settings, software (Phoenix WinNonlin, SAS), dose normalization approach | 51 |
| dataset_specification | tlf_shell | master_data | Table, Listing, and Figure (TLF) shell specification for a study. Captures output number, title, footnotes, display population, statistical method reference, program name, output type (table/listing/figure), the source system priority tier, and | 44 |
| results_production | analysis |  | CDISC Analysis Results Standard Analysis: a single planned statistical analysis within a reporting event, bound to a method, analysis set, dataset and endpoint. | 21 |
| results_production | analysis_method |  | CDISC Analysis Results Standard AnalysisMethod: a reusable statistical method (operations/programming steps) referenced by analyses. | 20 |
| results_production | analysis_output |  | CDISC Analysis Results Standard Output: a displayable table, listing or figure produced from one or more analyses, tied to the TLF shell and TLF output. | 24 |
| results_production | analysis_set |  | CDISC Analysis Results Standard AnalysisSet: the subject population condition applied in analyses, linked to the governing analysis_population. | 20 |
| results_production | database_lock_event | transactional_data | Database Lock (DBL) event record for a study or study part. Captures lock scope (full study, interim, partial), planned and actual lock date, pre-lock QC checklist completion status, outstanding query count at lock, lock authorization approvers (DM | 42 |
| results_production | grouping_factor |  | CDISC Analysis Results Standard AnalysisGrouping: a factor (treatment, subgroup) used to split analysis results into groups. | 19 |
| results_production | interim_analysis | transactional_data | Records planned and executed interim analyses for a study. Captures interim analysis number, type (efficacy, futility, safety, adaptive), planned information fraction, actual analysis date, DSMB/DMC involvement flag, unblinding scope (full/partial/none) | 54 |
| results_production | reporting_event |  | CDISC Analysis Results Standard ReportingEvent: the top-level container tying a the source system to a planned set of analyses and outputs. | 17 |
| results_production | tlf_output | transactional_data | Produced TLF output instance generated from a TLF shell specification. Captures output file reference, production run date, SAS program name and version, dataset version used, programmer, QC programmer, validation method (double programming, peer review) | 43 |
| safety_oversight | dsmb_charter | master_data | Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) charter record for a study. Captures committee composition, member roles (chair, statistician, clinician), meeting frequency, interim analysis schedule, stopping rules, unblinding | 46 |
| safety_oversight | dsmb_meeting | transactional_data | DSMB/DMC meeting record capturing each scheduled or ad hoc committee meeting. Captures meeting date, type (open/closed session), agenda items, interim analysis data package version, statistical report version, recommendations issued | 45 |

<a id="domain-consent"></a>

### Domain: Consent

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| consent | operations | 4 | Manages the informed consent lifecycle for trial subjects. Owns ICF versions and amendments, eConsent workflows (Clinpal), subject consent status, re-consent triggers, capacity assessments, withdrawal tracking, consent audit trails, and IRB/IEC-approved | 15 |

**Subdomains:** compliance_tracking, document_management, legal_authorization, subject_enrollment


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| compliance_tracking | audit_entry | transactional_data | Immutable audit trail record for every create, update, or status change event on consent domain records (subject consent, ICF version, eConsent session, withdrawal, etc.). | 40 |
| compliance_tracking | consent_delegation_log | master_data | Records the delegation of consent-related responsibilities at a site, capturing which qualified staff members (PI, sub-investigator, CRC) are authorized to conduct the informed consent process for a given study. | 37 |
| compliance_tracking | consent_deviation | transactional_data | Records protocol deviations specifically related to the informed consent process, such as consent obtained after study procedures began, expired ICF version used, missing witness signature, or re-consent not completed within required timeframe. | 43 |
| document_management | consent_icf_version | master_data | Master record for each version of an Informed Consent Form (ICF) used in a clinical trial, including language translations and amendment-derived versions. Tracks ICF document version number, effective date, IRB/IEC approval reference, language (ISO | 45 |
| document_management | icf_amendment | transactional_data | Tracks amendments to an approved ICF version, capturing the amendment number, amendment date, nature of change (safety update, protocol change, administrative correction), regulatory authority requiring the amendment, IRB/IEC submission date and approval | 39 |
| document_management | translation | master_data | Manages translations of ICF documents for multilingual trial sites. Records the source ICF version, target language (ISO 639-1 code), translation vendor or translator identity, translation date, back-translation completion flag, IRB/IEC approval of | 46 |
| legal_authorization | gdpr_data_consent | master_data | Manages GDPR and HIPAA-specific data processing consent and privacy notice records separate from clinical trial participation consent. Captures data processing purpose categories consented to (e.g., primary research, secondary research, biobanking, data | 46 |
| legal_authorization | lar_representative | master_data | Master record for a Legally Authorized Representative (LAR) associated with a trial subject who lacks capacity to consent independently. Stores LAR full name, relationship to subject, contact details, legal authority documentation type and reference | 45 |
| legal_authorization | waiver | master_data | Documents instances where the requirement for informed consent has been formally waived by an IRB/IEC or regulatory authority. Captures waiver type (full waiver, waiver of documentation, waiver of some elements), regulatory basis for waiver (e.g., 21 CFR | 46 |
| subject_enrollment | assent_record | transactional_data | Captures the formal assent obtained from a minor or cognitively limited subject who is capable of providing assent but not full legal consent. Records assent date, subject age at assent, assent form version used, assent method (verbal, written, eAssent) | 46 |
| subject_enrollment | capacity_assessment | transactional_data | Documents the formal assessment of a subject's mental capacity to provide informed consent, as required by GCP and applicable regulations (e.g., ICH E6, 21 CFR 50). | 42 |
| subject_enrollment | consent_subject_consent | transactional_data | Core transactional record capturing the consent event for a trial subject at a specific site and study. Records the date and time of consent, ICF version consented to, consent method (paper, eConsent via Clinpal), consenting staff (PI, CRC), witness | 43 |
| subject_enrollment | econsent_session | transactional_data | Tracks each eConsent workflow session initiated in Clinpal for a subject, including both on-site and remote/decentralized consent sessions. Captures session start and end timestamps, device type, IP address, session modality (in-person, remote via | 42 |
| subject_enrollment | reconsent_trigger | transactional_data | Records events that necessitate re-consent of a subject, such as a protocol amendment, new safety information, ICF version update, or regulatory authority requirement. | 46 |
| subject_enrollment | withdrawal | transactional_data | Records the formal withdrawal of informed consent by a subject or their LAR. Captures withdrawal date and time, withdrawal reason category (voluntary, AE-related, sponsor decision, lost to follow-up), subject-stated reason free text, withdrawal type (full | 35 |

<a id="domain-datamanagement"></a>

### Domain: Datamanagement

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| datamanagement | operations | 3 | Governs clinical data collection, validation, and lock processes. Owns EDC/eCRF design and build (Medidata Rave), data validation rules, query management, discrepancy resolution, medical coding (MedDRA, WHO-DD), database lock (DBL) workflows, DMP, CDISC | 37 |

**Subdomains:** electronic_capture, standards_mapping, terminology_control


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| electronic_capture | alcoa_audit_entry | transactional_data | Transactional record capturing ALCOA+ compliance audit trail entries for every clinical data change in the EDC system. Captures original value, new value, change reason (protocol-specified categories), change timestamp (system-generated, non-editable) | 48 |
| electronic_capture | data_entry_session | master_data | Master reference table for data_entry_session. Referenced by session_id. | 42 |
| electronic_capture | discrepancy_query | transactional_data | Transactional record of ALL data queries (discrepancies) raised against eCRF data entries in Medidata Rave, serving as the single source of truth for data quality issues regardless of origin. | 40 |
| electronic_capture | ecrf_field | master_data | Master definition of individual data fields within eCRF forms in Medidata Rave. Captures field name, label, data type (text, numeric, date, codelist), CDISC variable mapping (SDTM variable, domain), validation rules, required flag, controlled terminology | 46 |
| electronic_capture | ecrf_form | master_data | Master definition of Electronic Case Report Form (eCRF) designs built in Medidata Rave EDC. Captures form name, version, study association, form type (visit-based, unscheduled, log/repeating), completion rules, CDISC SDTM domain mapping, data entry mode | 43 |
| electronic_capture | edc_study_build | master_data | Master record for the EDC study build configuration in Medidata Rave. Captures study build version, build environment (development, UAT, production), build owner, build date, UAT completion status, go-live date, protocol version linked, amendment history | 44 |
| electronic_capture | ehr_data_transfer |  | A single eSource data transfer batch from an EHR source system into the EDC. | 25 |
| electronic_capture | ehr_fhir_crosswalk |  | Crosswalk mapping between EHR source systems and FHIR ResearchStudy and ResearchSubject resources for clinical trial data integration | 10 |
| electronic_capture | ehr_source_system |  | An external EHR / eSource system that supplies clinical data into the EDC via eSource flows. | 14 |
| electronic_capture | external_transfer | transactional_data | Transactional record of external data transfers into or out of the clinical database, including central lab results (LabCorp, Covance), PK/PD concentration data, ePRO/eCOA data, ECG data, medical imaging, and wearable/device data. | 45 |
| electronic_capture | field_entry | transactional_data | Atomic-level transactional record capturing a single field-level data entry in the EDC system (Medidata Rave). Stores the field value, entry timestamp, entered-by user, reason for change, previous value, audit trail reference, and ALCOA+ compliance flags | 48 |
| electronic_capture | reconciliation | transactional_data | Transactional record of reconciliation activities performed between EDC data and external data sources (central lab, safety database, IRT/RTSM, ePRO). Captures reconciliation type, source system, target system, reconciliation date, discrepancy count | 49 |
| electronic_capture | subject_visit_data | transactional_data | Transactional record of all eCRF data collected for a subject at a specific study visit in Medidata Rave. Captures subject identifier, visit name/number, visit date, form completion status (incomplete, complete, frozen, locked), data completeness | 43 |
| electronic_capture | validation_rule | master_data | Master definition of programmatic data validation rules (edit checks) configured in Medidata Rave EDC. Captures rule name, rule expression/logic, trigger condition, associated form and field, severity level (error, warning), rule category (range check | 46 |
| standards_mapping | cdash_variable_spec |  | CDASH variable specification. | 7 |
| standards_mapping | cdisc_standard |  | CDISC standards catalog entry (SDTMIG, CDASHIG, ADaMIG, SENDIG, Define-XML). SENDIG catalogued for completeness only. | 3 |
| standards_mapping | define_document |  | Define-XML document. | 16 |
| standards_mapping | dmp | master_data | Master record for the Data Management Plan (DMP) governing all data management activities for a clinical study. Captures DMP version, effective date, study phase, EDC system configuration, data collection strategy, coding dictionaries and versions | 57 |
| standards_mapping | sdtm_dataset | master_data | Master record for CDISC SDTM (Study Data Tabulation Model) dataset definitions and their submission-ready outputs. Captures dataset name (e.g., AE, CM, DM, LB, VS), SDTM domain class (Events, Interventions, Findings), SDTM IG version, study identifier | 38 |
| standards_mapping | sdtm_domain_spec |  | SDTM domain specification. | 5 |
| standards_mapping | sdtm_mapping | master_data | Detail-level record defining a single source-to-target transformation rule between a raw EDC eCRF field and a CDISC SDTM variable within a parent sdtm_dataset. | 44 |
| standards_mapping | sdtm_variable_spec |  | SDTM variable specification. | 8 |
| standards_mapping | value_level_metadata |  | Define-XML value level metadata. | 21 |
| terminology_control | codelist |  | CDISC Controlled Terminology codelist reference table. Includes UNIT codelist (NCI C71620) for dose and age units, SEX (NCI C66731), RACE (NCI C74457), ETHNIC (NCI C66790), AGEU (NCI C66781), OUT (NCI C66768), ACN (NCI C66767), AESEV (NCI C66769), NCOMPLT | 32 |
| terminology_control | codelist_acn |  | Reference table for CDISC Controlled Terminology ACN codelist | 17 |
| terminology_control | codelist_aesev |  | Reference table for CDISC Controlled Terminology AESEV codelist | 17 |
| terminology_control | codelist_ageu |  | Reference table for CDISC Controlled Terminology AGEU codelist | 18 |
| terminology_control | codelist_ethnic |  | Reference table for CDISC Controlled Terminology ETHNIC codelist | 16 |
| terminology_control | codelist_frm |  | Reference table for CDISC Controlled Terminology FRM codelist | 18 |
| terminology_control | codelist_ncomplt |  | Reference table for CDISC Controlled Terminology NCOMPLT codelist | 19 |
| terminology_control | codelist_out |  | Reference table for CDISC Controlled Terminology OUT codelist | 17 |
| terminology_control | codelist_race |  | Reference table for CDISC Controlled Terminology RACE codelist | 21 |
| terminology_control | codelist_route |  | Reference table for CDISC Controlled Terminology ROUTE codelist | 30 |
| terminology_control | codelist_sex |  | Reference table for CDISC Controlled Terminology SEX codelist | 17 |
| terminology_control | codelist_term |  | CDISC Controlled Terminology codelist term/member. | 7 |
| terminology_control | codelist_unit |  | Reference table for CDISC Controlled Terminology UNIT codelist | 24 |
| terminology_control | coding_assignment | transactional_data | Transactional record of medical coding assignments applied to verbatim terms collected in eCRFs. Captures verbatim term, coding dictionary (MedDRA or WHO-DD), dictionary version, assigned code, preferred term (PT), system organ class (SOC), lowest level | 45 |

<a id="domain-laboratory"></a>

### Domain: Laboratory

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| laboratory | operations | 4 | Manages central and local laboratory operations for clinical trials. Owns lab panel definitions, specimen collection and processing workflows, lab results (including PK/PD and DMPK data), reference ranges, critical values, sample chain of custody | 24 |

**Subdomains:** facility_management, result_reporting, sample_processing, test_definition


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| facility_management | lab_accreditation | master_data | Master record tracking laboratory facility accreditation and certification status. Captures accreditation body (CAP, CLIA, ISO 15189, UKAS, DAkkS), certificate number, accreditation scope (test menu), issue date, expiry date, renewal status, inspection | 44 |
| facility_management | lab_certification | reference_data | Reference master for laboratory regulatory certifications and qualifications required for clinical trial participation. Captures certification type (GLP, GCP lab qualification, CAP proficiency, CLIA specialty, EQA scheme participation), issuing authority | 40 |
| facility_management | lab_facility | master_data | Master record for central and local laboratory facilities performing specimen analysis for clinical trials. Captures facility name, type (central/local/bioanalytical/PK), CLIA/CAP/ISO 15189 accreditation status, accreditation expiry, regulatory | 43 |
| facility_management | lab_qualification | association_data | This association product represents the formal qualification and engagement contract between a lab_facility and a clinical_program. It captures the sponsor-approved, program-specific qualification of a laboratory facility to perform defined specimen | 10 |
| facility_management | lab_service_contract | association_data | This association product represents the Contract between lab_facility and study_budget. It captures the facility-specific financial and operational terms under which a laboratory facility is engaged to perform specimen analysis services for a specific | 11 |
| result_reporting | bioanalytical_result | transactional_data | Transactional record of a bioanalytical or biomarker assay result from a clinical trial PK/PD, DMPK, or exploratory biomarker sample. Captures assay run ID, sample ID, analyte/biomarker measured, concentration or categorical result value, unit/scale | 44 |
| result_reporting | lab_query | transactional_data | Transactional record of a data query raised against a laboratory result in the EDC (Medidata Rave) or LIMS. Captures query ID, query type (missing value/implausible result/unit mismatch/collection time deviation), query text, raised by (data | 42 |
| result_reporting | laboratory_lab_result | transactional_data | Transactional record of a laboratory test result for a specific analyte from a subject specimen. Captures analyte name, LOINC code, result value, result unit, normal range lower/upper bound, reference range source, result status | 57 |
| result_reporting | laboratory_vital_sign |  | Vital signs captured via eSource | 21 |
| sample_processing | lab_kit | master_data | Master record for laboratory collection kits supplied to clinical sites for specimen collection. Captures kit type, kit lot number, components list (tubes, containers, preservatives, requisition forms), storage requirements, expiry date, kit version, and | 43 |
| sample_processing | pk_sample | master_data | Master record for pharmacokinetic (PK) and pharmacodynamic (PD) samples collected per the study PK sampling schedule. Captures nominal and actual collection time relative to dose (pre-dose, post-dose hours), dose number, PK sampling window compliance | 47 |
| sample_processing | shipment_manifest | master_data | Master reference table for shipment_manifest. Referenced by manifest_id. | 42 |
| sample_processing | specimen | master_data | Master record for each biological specimen collected from a trial subject, including collection event details. Captures specimen barcode/ID, subject ID, visit reference, collection date/time, specimen type (blood, urine, CSF, tissue), collection tube | 42 |
| sample_processing | specimen_aliquot | master_data | Master record for aliquots derived from a primary specimen for distribution to multiple testing labs or long-term storage, including storage placement tracking. | 40 |
| sample_processing | specimen_collection | transactional_data | Transactional record of a scheduled or unscheduled specimen collection event at a clinical site or subject visit. Captures collection event date/time, study visit reference, protocol-scheduled vs. | 47 |
| sample_processing | specimen_shipment | transactional_data | Transactional record tracking the shipment of specimens from a clinical site to a central or reference laboratory. Captures shipment manifest ID, origin site, destination lab facility, courier name, tracking number, shipment date/time, expected arrival | 43 |
| test_definition | bioanalytical_assay | master_data | Master definition of a validated bioanalytical assay used to quantify drug concentrations, biomarkers, or immunogenicity in clinical trial samples. Captures assay name, analyte measured, assay type (LC-MS/MS, ELISA, ECL, PCR, flow cytometry), validation | 50 |
| test_definition | critical_value | reference_data | Reference master defining critical (panic) value thresholds for laboratory analytes that require immediate clinical notification. Captures analyte, LOINC code, critical low threshold, critical high threshold, unit, notification SLA (minutes), escalation | 40 |
| test_definition | lab_analyte | reference_data | Reference master for individual laboratory analytes (measurable substances or properties) used across all lab panels and assays. Captures analyte name, LOINC code, MedDRA PT mapping, CDISC LBTESTCD/LBTEST standardized code and label, default unit of | 44 |
| test_definition | lab_panel | master_data | Master definition of a laboratory test panel or battery used in clinical trials. Captures panel code, name, specimen type requirements, analyte list, applicable study phases, CDISC SDTM domain mapping (LB), turnaround time SLA, and whether the panel is | 43 |
| test_definition | panel_composition | association_data | This association product represents the formal composition contract between a lab_panel and its constituent lab_analytes. It captures the version-controlled membership of each analyte within a panel as actively managed by lab directors and protocol teams. | 12 |
| test_definition | protocol_lab_schedule | master_data | Master definition of the protocol-mandated laboratory assessment schedule for a study, mapping each study visit to required lab panels. Captures study ID, visit name/number, visit window (day range), required lab panels, optional panels, fasting | 45 |
| test_definition | reference_range | reference_data | Master definition of laboratory reference ranges (normal ranges) for analytes, with full version history. Captures analyte/LOINC code, lower and upper normal limits, unit of measure, sex, age range, ethnicity applicability, specimen type, lab facility | 45 |
| test_definition | sow_lab_panel_requirement | association_data | This association product represents the Contract between scope_of_work and lab_panel in clinical research operations. It captures the formal contractual inclusion of a specific laboratory test panel within a Scope of Work, recording the negotiated terms | 10 |

<a id="domain-monitoring"></a>

### Domain: Monitoring

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| monitoring | operations | 3 | Manages CRA monitoring activities including risk-based monitoring (RBM) strategies, on-site and remote monitoring visits (initiation, interim, close-out), source data verification (SDV), monitoring visit reports, query management, protocol deviation | 17 |

**Subdomains:** issue_resolution, strategy_planning, visit_execution


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| issue_resolution | central_monitoring_alert | transactional_data | Automated or manually triggered alert generated by the centralized statistical monitoring (CSM) system when a KRI threshold breach or data anomaly is detected at a site. | 49 |
| issue_resolution | escalation_record | transactional_data | Formal escalation record raised when action items, protocol deviations, or CAPAs are not resolved within defined timelines or when critical GCP findings require sponsor or management intervention. | 60 |
| issue_resolution | escalation_record_context |  | Junction table holding additional foreign key relationships for escalation records that exceed the recommended FK limit, supporting regulatory inspection, unblinding request, and visit finding references. | 11 |
| issue_resolution | monitoring_action_item | transactional_data | Formal action item raised as a result of a monitoring finding, protocol deviation, or escalation trigger. Tracks action description, responsible party (site staff, CRA, or sponsor), due date, priority level, current status (open, in-progress, overdue | 42 |
| strategy_planning | monitoring_cra_assignment | master_data | Assignment record linking a CRA to a specific site and study for monitoring responsibilities. Captures assignment dates, type (primary, backup, lead CRA), territory, workload allocation percentage, and status. | 46 |
| strategy_planning | monitoring_plan | master_data | Master entity defining the risk-based monitoring (RBM) strategy for a clinical study. Specifies monitoring approach (on-site, remote, centralized), SDV scope and percentage thresholds, visit frequency rules, critical data/process definitions per ICH | 49 |
| strategy_planning | monitoring_visit_schedule | master_data | Planned monitoring visit schedule for a site within a study, derived from the monitoring plan. Captures planned visit type, planned visit window (earliest and latest acceptable dates), visit frequency interval, basis for scheduling (risk-based trigger | 45 |
| strategy_planning | risk_indicator | master_data | Centralized monitoring risk indicator (also known as Key Risk Indicator or KRI) defined within the RBM monitoring plan. Captures indicator name, category (enrollment, data quality, safety, protocol compliance, IP accountability), calculation method | 47 |
| strategy_planning | site_risk_assessment | transactional_data | Periodic risk assessment of an investigational site within the RBM framework. Captures overall site risk score, individual KRI values and threshold breaches, risk tier classification (low, medium, high), assessment date, assessor, recommended monitoring | 45 |
| visit_execution | checklist_item | master_data | Master reference table for checklist_item. Referenced by checklist_item_id. | 36 |
| visit_execution | ip_accountability_log | transactional_data | Investigational Product (IP) accountability verification record captured during monitoring visits. Records CRA verification of IP receipt, dispensing, return, and destruction records at the site level. | 50 |
| visit_execution | monitoring_visit |  | CRA site monitoring visit, distinct from subject_visit | 20 |
| visit_execution | sdv_record | transactional_data | Source Data Verification (SDV) record capturing the verification of individual eCRF data points against source documents at the site. Tracks subject visit, eCRF field or data point verified, SDV outcome (verified, discrepancy found, not verifiable) | 46 |
| visit_execution | visit_checklist | master_data | Monitoring checklist template and completion record used by CRAs during visits. Defines checklist items (regulatory binder, ICF, IP accountability, eCRF, safety reporting), item categories, mandatory/optional flags, and captures per-item completion status | 42 |
| visit_execution | visit_deviation_finding | transactional_data | Record of each protocol deviation identified at a site during monitoring or data review. Captures deviation category and severity (major, minor, important), description, root cause, affected subject, dates of occurrence and identification, IRB/IEC and | 48 |
| visit_execution | visit_finding | transactional_data | Individual finding or observation recorded by a CRA during a monitoring visit or remote review. Captures finding category (data integrity, consent, IP accountability, safety reporting, regulatory compliance), severity, description, site response | 48 |
| visit_execution | visit_report | transactional_data | Formal monitoring visit report authored by the CRA following each on-site or remote monitoring visit. Captures visit summary narrative, findings, SDV results, protocol deviations identified, outstanding issues, action items raised, and CRA/supervisor | 44 |

<a id="domain-randomization"></a>

### Domain: Randomization

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| randomization | operations | 3 | Manages subject allocation algorithms, stratification factors, randomization codes, blinding integrity, and unblinding procedures. Integrated with eCRF and supply domains for kit assignment and treatment arm allocation via IRT/IVRS/RTSM systems. | 15 |

**Subdomains:** assignment_execution, scheme_design, unblinding_control


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| assignment_execution | irt_transaction | transactional_data | Detailed log of all IRT/IVRS/RTSM system transactions related to randomization and kit dispensing. Captures transaction type (randomization, re-randomization, cancellation, kit assignment, dose change, titration), transaction timestamp, IRT system | 43 |
| assignment_execution | kit_assignment | transactional_data | Records the assignment of an investigational medicinal product (IMP) kit to a subject at a specific visit, as triggered by the IRT/RTSM system following randomization or resupply. | 42 |
| assignment_execution | subject_randomization | transactional_data | Transactional record of a subject's randomization or re-randomization event. Captures the subject identifier, study site, randomization number assigned, treatment arm allocated, stratification cell, randomization timestamp, IRT/IVRS transaction reference | 48 |
| scheme_design | blinding_config | master_data | Defines the blinding configuration for a randomization scheme, including blinding type (open-label, single-blind, double-blind, triple-blind), blinded roles (subject, investigator, sponsor, CRA, statistician), blinding method (identical packaging, dummy | 38 |
| scheme_design | rand_code | master_data | Individual randomization code (slot) within a randomization list. Each code represents a single subject allocation slot with its sequential position number, pre-assigned treatment arm, stratification cell membership, kit code linkage for IMP dispensing | 39 |
| scheme_design | rand_list | master_data | The generated randomization list produced from a randomization scheme. Stores the ordered sequence of treatment assignments, list version, generation timestamp, generation method, blinding level, and approval status. | 41 |
| scheme_design | rand_scheme | master_data | Master definition of a randomization scheme for a clinical study. Captures the allocation algorithm type (simple, block, stratified, minimization, adaptive), block sizes, allocation ratio, seed values, and scheme version. | 42 |
| scheme_design | rand_validation_run | transactional_data | Records the UAT and validation runs performed on a randomization scheme and IRT system prior to study go-live. Captures validation run type (UAT, dry run, parallel test), test scenario coverage, pass/fail status per scenario, tester identity, validation | 48 |
| scheme_design | stratification_cell | master_data | Represents the unique combination of stratification factor levels that defines a single stratum cell within a randomization scheme. Stores the cell identifier, composite cell label, target subject count per arm within the cell, actual enrolled count, and | 36 |
| scheme_design | stratification_factor | master_data | Defines the stratification factors used in a randomization scheme, including factor name, factor code, data source (eCRF field reference), factor type (categorical, continuous-binned), enumerated levels (level code, label, sort order, active status), and | 39 |
| scheme_design | treatment_arm | master_data | Master definition of each treatment arm within a clinical study. Captures arm name, arm code, arm type (experimental, active comparator, placebo, open-label extension), blinding role, target allocation percentage, and arm status. | 38 |
| unblinding_control | dsmb_unblind_package | transactional_data | Manages the preparation and delivery of unblinded data packages to the DSMB (Data Safety Monitoring Board) or DMC (Data Monitoring Committee). Captures package version, meeting date, unblinded statistician identity, data cut-off date, treatment arm labels | 52 |
| unblinding_control | rand_deviation | transactional_data | Documents randomization-related protocol deviations, including wrong treatment dispensed, randomization outside the protocol window, incorrect stratification factor captured, duplicate randomization, and IRT system errors leading to incorrect assignment. | 55 |
| unblinding_control | unblinding_approval | transactional_data | Records the approval or rejection decision for an unblinding request. Captures the approver role (medical monitor, PI, sponsor medical officer), decision (approved, rejected, escalated), decision rationale, decision timestamp, and any conditions attached | 38 |
| unblinding_control | unblinding_request | transactional_data | Transactional record of a request to unblind a subject's treatment assignment, encompassing the full request-through-resolution lifecycle including multi-level approval steps. | 48 |

<a id="domain-safety"></a>

### Domain: Safety

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| safety | operations | 3 | Manages adverse events (AE), serious adverse events (SAE), suspected unexpected serious adverse reactions (SUSAR), and safety signal detection. Owns MedDRA coding (SOC/PT/LLT), CTCAE severity grading, causality assessments, expedited regulatory reporting | 26 |

**Subdomains:** event_reporting, oversight_governance, regulatory_submission


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
|  | meddra_version |  | The meddra version table in the safety domain. | 3 |
| event_reporting | adverse_event | transactional_data | Core master record for every adverse event (AE) reported during a clinical trial, capturing onset date, resolution date, severity grade per CTCAE, seriousness flag, expectedness, relationship to investigational product, action taken, outcome, and | 59 |
| event_reporting | ae_follow_up | transactional_data | Transactional record capturing follow-up information updates for an adverse event after the initial report, including updated severity grade, new causality assessment, additional clinical details, outcome update, and resolution date. | 47 |
| event_reporting | ae_meddra_coding | master_data | Stores the MedDRA coding assignment for each adverse event, capturing the verbatim term reported, the coded Lowest Level Term (LLT), Preferred Term (PT), High Level Term (HLT), High Level Group Term (HLGT), and System Organ Class (SOC). | 44 |
| event_reporting | causality_assessment | transactional_data | Records the investigator and sponsor medical monitor causality assessments for each adverse event relative to the investigational product and concomitant medications. | 43 |
| event_reporting | narrative | transactional_data | Stores the structured clinical narrative for SAEs and SUSARs, including case summary, patient description, event description, treatment details, outcome, and medical monitor commentary. | 48 |
| event_reporting | serious_adverse_event | transactional_data | Transactional record for Serious Adverse Events (SAEs) that meet regulatory seriousness criteria (death, life-threatening, hospitalization, disability, congenital anomaly, or other medically important condition). | 49 |
| event_reporting | susar | transactional_data | Transactional record for Suspected Unexpected Serious Adverse Reactions (SUSARs) — SAEs that are both unexpected (not in the Investigator Brochure) and causally related to the investigational product. | 50 |
| oversight_governance | assessment_dataset_evidence | association_data | This association product represents the Evidence Role relationship between a benefit_risk_assessment and an sdtm_dataset. It captures the formal linkage of a specific SDTM dataset as an evidentiary source for a given benefit-risk assessment, recording the | 8 |
| oversight_governance | benefit_risk_assessment | master_data | Master record for formal benefit-risk assessments conducted at the study or program level, capturing assessment date, trigger (DSMB recommendation, signal validation, regulatory request, periodic review), benefit summary, risk summary, overall | 47 |
| oversight_governance | committee_membership | association_data | This association product represents the Role-based membership between safety_review_committee and employee. It captures the formal appointment of a workforce member to a safety oversight committee (SRC, DSMB, DMC, or IDMC), including their designated | 15 |
| oversight_governance | dsmb_recommendation | transactional_data | Transactional record for formal DSMB/DMC recommendations issued following a safety review meeting. Captures recommendation type (continue unchanged, protocol amendment required, dose modification, study suspension, early termination), rationale, sponsor | 45 |
| oversight_governance | dsmb_review | master_data | Master record for Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) safety governance, covering both committee definition and individual review meetings. | 45 |
| oversight_governance | investigator_brochure_safety | master_data | Master record tracking the safety-relevant sections of the Investigator Brochure (IB) for each investigational product, including the Reference Safety Information (RSI) used to assess expectedness of adverse reactions. | 45 |
| oversight_governance | review_committee | master_data | Master record for internal sponsor Safety Review Committees (SRCs) and external Data Monitoring Committees (DMCs) overseeing study safety. Captures committee name, type (internal SRC, DSMB, DMC, IDMC), charter version, meeting frequency, member roster | 43 |
| oversight_governance | signal | master_data | Master record for identified safety signals and their full evaluation lifecycle. Captures signal description, detection method (disproportionality analysis, PRR, ROR, BCPNN, clinical review, literature), detection date, data source, signal strength | 43 |
| oversight_governance | signal_case_contribution | association_data | This association product represents the Signal Case Contribution event between adverse_event and safety_signal. It captures the formal pharmacovigilance process by which individual adverse event case reports are linked to safety signals as contributing | 9 |
| oversight_governance | signal_evaluation | transactional_data | Transactional record capturing the formal evaluation workflow for a safety signal, including evaluation plan, data reviewed, benefit-risk assessment, regulatory action recommended (label update, DHPC, study suspension, protocol amendment), evaluation | 45 |
| oversight_governance | signal_notification | association_data | This association product represents the regulatory notification Event between a safety_signal and a health_authority. It captures the operational record of a specific safety signal being reported to a specific health authority, including submission | 9 |
| regulatory_submission | dsur | transactional_data | Development Safety Update Report (DSUR) — the annual periodic safety report submitted to health authorities summarizing cumulative safety data for an investigational product across all ongoing studies. | 53 |
| regulatory_submission | dsur_line_listing | association_data | This association product represents the regulatory inclusion of a SUSAR within a specific Development Safety Update Report (DSUR). It captures the ICH E2F-mandated line listing relationship between a periodic safety report and individual SUSAR cases | 9 |
| regulatory_submission | expedited_report_deadline | transactional_data | Transactional record tracking the calculated and actual submission deadlines for each expedited safety report (ICSR/SUSAR). Captures clock start date (date of first awareness), 7-day and 15-day deadline dates, actual submission date, days-to-submission | 44 |
| regulatory_submission | icsr | transactional_data | Individual Case Safety Report (ICSR) — the formal regulatory submission record for expedited safety reporting to health authorities (FDA, EMA, PMDA, MHRA). | 44 |
| regulatory_submission | reporting_obligation | reference_data | Reference master defining regulatory reporting timelines and obligations for each study-country-agency combination. Captures event type (SUSAR fatal, SUSAR non-fatal, SAE, annual DSUR, IND safety report), reporting clock duration (7-day, 15-day, 30-day | 50 |
| regulatory_submission | safety_communication | transactional_data | Transactional record for formal safety communications issued to investigators, IRBs/IECs, and health authorities, including urgent safety measures, Dear Healthcare Professional Communications (DHPCs), and safety letters. | 46 |
| regulatory_submission | susar_submission | association_data | This association product represents the regulatory submission event between a SUSAR case and a specific health authority. It captures the per-authority expedited safety reporting lifecycle — including submission date, authority-specific deadline | 9 |

<a id="domain-site"></a>

### Domain: Site

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| site | operations | 3 | Manages investigational sites including feasibility assessment, site selection, activation, PI qualifications, CRC assignments, IRB/IEC approval records, site performance metrics, monitoring visit scheduling, and close-out. | 25 |

**Subdomains:** facility_management, operational_performance, selection_activation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| facility_management | capacity | master_data | Captures the declared and assessed operational capacity of an investigational site for concurrent trial participation. Tracks maximum concurrent subjects, available examination rooms, dedicated research staff FTE, pharmacy storage capacity, lab processing | 42 |
| facility_management | investigational_site | master_data | Master record for each investigational site participating in clinical trials. Captures site identity, physical address, facility type, therapeutic area specializations, GCP certification status, regulatory registration numbers (e.g., FDA FEI, DUNS), site | 42 |
| facility_management | pi_qualification | association_data | This association product represents the Qualification relationship between a Principal Investigator and a Sponsor Organization. It captures the formal regulatory approval process by which a sponsor certifies a PI as eligible to conduct studies under their | 10 |
| facility_management | principal_investigator | master_data | Master record for Principal Investigators (PIs) conducting clinical trials. Captures PI credentials, medical license numbers, specialty, board certifications, GCP training history, FDA Form 1572 submission status, financial disclosure status, debarment | 44 |
| facility_management | program_site_participation | association_data | This association product represents the Program Site Participation between investigational_site and clinical_program. It captures the operational engagement of an investigational site within a clinical development program — a recognized portfolio strategy | 9 |
| facility_management | site_agreement | master_data | Tracks site-level contractual agreements including Clinical Trial Agreements (CTA), Confidential Disclosure Agreements (CDA), and site-specific budget agreements. | 52 |
| facility_management | site_contact | master_data | Site contact - site owns its own contact; distinct from sponsor_contact and subject_contact. | 44 |
| facility_management | site_selection_committee | master_data | Master reference table for site_selection_committee. Referenced by committee_id. | 41 |
| facility_management | specialization | association_data | This association product represents the Specialization Role between investigational_site and therapeutic_area. It captures the operational qualification profile of an investigational site within a specific therapeutic area, as assessed and maintained by | 10 |
| facility_management | sponsor_site_qualification | association_data | This association product represents the formal qualification and relationship contract between an investigational_site and a sponsor organization. It captures the operational record of a sponsor's qualification, rating, and preferred-network designation | 13 |
| facility_management | staff_roster | association_data | This association product represents the Role-based assignment between investigational_site and employee. It captures the operational record of each staff member assigned to an investigational site, including their functional role, assignment period, GCP | 9 |
| operational_performance | closeout | transactional_data | Records the formal site close-out process for a study-site upon completion or early termination. Captures close-out visit date, last subject last visit (LSLV) date, database lock contribution date, drug accountability reconciliation status, essential | 56 |
| operational_performance | depot_assignment | association_data | This association product represents the supply assignment (role) between an investigational_site and a depot. It captures the formal clinical supply routing decision that designates which depot(s) serve each investigational site, including whether the | 7 |
| operational_performance | enrollment_performance | transactional_data | Tracks actual vs. planned enrollment performance at the study-site level over time. Captures reporting period, planned enrollment target, actual subjects screened, subjects enrolled, screen failure count, screen failure rate, dropout count, and cumulative | 47 |
| operational_performance | ib_site_distribution | association_data | This association product represents the IB Distribution Log event between investigational_site and investigator_brochure_safety. It captures the GCP-mandated record of each Investigator Brochure version distributed to each investigational site, including | 13 |
| operational_performance | signal_review | association_data | This association product represents the Site Signal Review event between study_site and safety_signal. It captures the operational process by which a medical monitor or safety team evaluates a specific safety signal in the context of a specific | 9 |
| operational_performance | site_cra_assignment | master_data | Records the assignment of Clinical Research Associates (CRAs) to study-site combinations for monitoring coverage. Captures CRA identity reference (FK to workforce domain), assignment start/end dates, assignment type (primary, backup, co-monitor) | 47 |
| selection_activation | activation | transactional_data | Tracks the end-to-end site activation workflow milestones from site selection through first patient first visit (FPFV). Captures completion dates and status for each activation task: confidentiality agreement execution, protocol receipt, IRB/IEC | 56 |
| selection_activation | authorization | association_data | This association product represents the Contract between investigational_site and clinical_trial_authorization. It captures the site-level regulatory authorization record that links a specific investigational site to a Clinical Trial Authorization issued | 9 |
| selection_activation | feasibility_assessment | transactional_data | Records the site feasibility evaluation conducted prior to site selection for a specific study. Captures feasibility questionnaire responses, estimated enrollment capacity, patient population availability, competing trial load, infrastructure readiness | 47 |
| selection_activation | initiation_visit | transactional_data | Records the Site Initiation Visit (SIV) event conducted by the CRA prior to first patient enrollment. Captures visit date, CRA assigned, attendees, training topics covered (protocol, EDC, RTSM, safety reporting, ICF process), action items identified | 48 |
| selection_activation | irb_iec_approval | transactional_data | Records IRB (Institutional Review Board) and IEC (Independent Ethics Committee) approvals for a study-site combination. Captures submission date, approval date, approval number, expiration date, continuing review due date, approved protocol version | 44 |
| selection_activation | regulatory_submission_site | transactional_data | Tracks site-level regulatory submissions required for trial conduct, including FDA Form 1572 (Statement of Investigator), financial disclosure forms (FDA Form 3454/3455), local health authority notifications, and country-specific site authorization | 44 |
| selection_activation | selection | transactional_data | Records the formal site selection decision for a study-site pairing, including selection rationale, selection committee approval, selection date, rejection reasons (if applicable), and the transition from feasibility to activation. | 45 |
| selection_activation | study_site | master_data | Association entity representing the full lifecycle relationship between a specific study (protocol) and an investigational site, from selection through activation to closeout. | 47 |

<a id="domain-study"></a>

### Domain: Study

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| study | operations | 4 | Core operational domain managing clinical study protocols, design, phases, objectives, endpoints, inclusion/exclusion criteria, visit schedules, and study lifecycle from protocol development through database lock. | 35 |

**Subdomains:** design_elements, operational_execution, protocol_management, visit_scheduling


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| design_elements | arm | master_data | Defines each treatment arm or cohort within a clinical study. Records arm name, arm code, arm type (experimental, active comparator, placebo comparator, sham comparator, no intervention, other), description of intervention, planned number of subjects per | 42 |
| design_elements | biomedical_concept |  | USDM BiomedicalConcept concept in the study domain. | 12 |
| design_elements | cohort |  | USDM StudyCohort: a subset of the study population defined by shared characteristics. | 11 |
| design_elements | eligibility_criterion | master_data | Defines inclusion and exclusion criteria for subject enrollment in a clinical study. Records criterion number, criterion type (inclusion/exclusion), criterion text, criterion category (demographic, diagnosis, lab value, prior therapy, concomitant | 42 |
| design_elements | endpoint | master_data | Defines the formal objectives and their associated endpoints (primary, secondary, exploratory) for a clinical study. Captures objective text, objective type, endpoint name, endpoint type (primary, secondary, exploratory, safety, PK, PD, biomarker) | 42 |
| design_elements | epoch | master_data | Defines the temporal epochs (periods) of a clinical study such as Screening, Run-in, Treatment Period 1, Washout, Treatment Period 2, Follow-up, and Extension. | 41 |
| design_elements | intercurrent_event |  | USDM/ICH E9(R1) intercurrent event occurring post-treatment that affects interpretation of the estimand. | 11 |
| design_elements | objective | master_data | Formally documents the primary, secondary, and exploratory objectives of a clinical study as stated in the protocol. Captures objective number, objective type (primary, secondary, exploratory), objective text, associated endpoint references, ICH E9(R1) | 38 |
| design_elements | population |  | USDM StudyDesignPopulation: the overall planned study population for a study design. | 12 |
| design_elements | study_cell |  | USDM StudyCell concept in the study domain. | 10 |
| design_elements | study_design |  | USDM StudyDesign concept in the study domain. | 14 |
| design_elements | study_element |  | USDM StudyElement concept in the study domain. | 12 |
| design_elements | study_intervention |  | USDM StudyIntervention: a planned intervention administered to study participants. | 13 |
| operational_execution | country | master_data | Manages the countries in which a clinical study is conducted including country-level enrollment planning. Records country code (ISO 3166), country name, regulatory authority, CTA/IND submission and approval dates, approval status, first site activation | 46 |
| operational_execution | dosing_regimen | master_data | Defines the dosing regimen for each investigational product within a study arm. Records regimen name, dose level, dose unit, dosing frequency, dosing route, dosing duration, dose escalation scheme (for dose-escalation studies), dose modification rules | 41 |
| operational_execution | investigational_product | master_data | Master record for the investigational medicinal product (IMP) or device used in a clinical study. Captures IMP name, INN (International Nonproprietary Name), drug code, formulation, dosage form, route of administration, strength, manufacturer, IND/IMPD | 43 |
| operational_execution | ip_site_accountability | association_data | This association product represents the regulatory and operational contract between an investigational product and an investigational site. It captures the per-site authorization, storage compliance, dispensing status, and drug accountability obligations | 10 |
| operational_execution | pk_sampling_schedule | master_data | Defines the pharmacokinetic (PK) and pharmacodynamic (PD) blood/urine/tissue sampling schedule for a clinical study. Records sample type, nominal sampling timepoint (pre-dose, 0.5h, 1h, 2h, 4h, 8h, 24h post-dose, etc.), sampling window, visit association | 45 |
| operational_execution | product_designation | association_data | This association product represents the regulatory designation grant relationship between an investigational_product and a special_designation. It captures the operational record of which special regulatory designation applies to which investigational | 8 |
| protocol_management | amendment_site_implementation | association_data | This association product represents the Event between study_protocol_amendment and study_site. It captures the formal process by which each protocol amendment is communicated to, acknowledged by, and operationally implemented at a specific investigational | 12 |
| protocol_management | country_submission | association_data | This association product represents the regulatory filing event between a study_country and a regulatory submission. It captures the operational record of a specific submission being filed with or applicable to a specific country's regulatory authority | 9 |
| protocol_management | governance_date |  | USDM GovernanceDate concept in the study domain. | 11 |
| protocol_management | protocol | master_data | Master record for the clinical study protocol including all formal amendments (version history). Captures protocol number, version, title, phase, therapeutic area, indication, investigational product, study design parameters (allocation method | 42 |
| protocol_management | study | master_data | Top-level master entity representing a clinical trial as a business and operational unit. Captures the unique study identifier (sponsor study number, ClinicalTrials.gov NCT number, EudraCT number), study title, acronym, therapeutic area, indication | 39 |
| protocol_management | study_identifier |  | USDM StudyIdentifier concept in the study domain. | 13 |
| protocol_management | study_milestone |  | Records milestones associated with a study, tracking key events and their dates throughout the study lifecycle. | 8 |
| protocol_management | study_protocol_amendment | transactional_data | Tracks all formal amendments to an approved clinical study protocol. Records amendment number, amendment date, amendment type (substantial/non-substantial), description of changes, rationale, regulatory submission status per health authority (FDA, EMA | 42 |
| protocol_management | study_protocol_milestone | transactional_data | Study-level milestone - distinct concept, separate owner from regulatory_milestone and program_milestone. | 45 |
| protocol_management | study_version |  | USDM StudyVersion concept in the study domain. | 10 |
| visit_scheduling | activity |  | USDM Activity concept in the study domain. | 12 |
| visit_scheduling | encounter |  | USDM Encounter concept in the study domain. | 11 |
| visit_scheduling | schedule_timeline |  | USDM ScheduleTimeline concept in the study domain. | 10 |
| visit_scheduling | scheduled_activity_instance |  | USDM ScheduledActivityInstance concept in the study domain. | 13 |
| visit_scheduling | study_visit_schedule | master_data | Defines the planned Schedule of Events (SoE) for a clinical study including all visits and their required procedures. Captures visit name, visit number, visit type (screening, baseline, treatment, follow-up, unscheduled, end-of-study), planned study | 42 |
| visit_scheduling | visit_procedure | master_data | Defines the specific clinical procedures, assessments, and data collection activities required at each scheduled visit. Records procedure name, procedure category (vital signs, lab draw, ECG, imaging, questionnaire, dosing, PK sampling, physical exam | 43 |

<a id="domain-subject"></a>

### Domain: Subject

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| subject | operations | 2 | SSOT for trial participants (subjects/patients) across all studies. Owns subject enrollment, demographics, randomization assignments via IRT/RTSM, treatment arms, visit compliance, protocol deviations, and subject disposition from screening through study | 18 |

**Subdomains:** clinical_data, participant_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| clinical_data | concomitant_medication | Master | Records medications taken by subjects before and during the trial, including drug name, indication, dose, route, start/stop dates, and WHO-DD coding. | 47 |
| clinical_data | demographic | Master | Captures subject demographic data including age, sex, race, ethnicity, height, weight, and other baseline characteristics collected at screening per CDISC DM domain standards. | 42 |
| clinical_data | drug_lab_interaction | association_data | This association product represents the clinical assessment event linking a concomitant medication record to a laboratory result that triggered or informed a medication decision. | 9 |
| clinical_data | medical_history | Master | Records subject medical history and pre-existing conditions collected during screening, coded to MedDRA terms, with onset dates, resolution status, and relevance to study eligibility. | 50 |
| clinical_data | sdv_review | association_data | This association product represents the Source Data Verification (SDV) Review event between a subject_visit and a monitoring_visit. It captures the operational record of a CRA reviewing a specific subject visit during a specific monitoring visit | 11 |
| clinical_data | subject_consent | association_data | This association product represents the Informed Consent Event between a trial_subject and a document_icf_version. It captures the complete regulatory audit trail of every consent and re-consent signing event for each subject across all ICF versions | 12 |
| clinical_data | visit_billing_reconciliation | association_data | This association product represents the billing reconciliation event between a subject_visit and an invoice_line in clinical trials sponsor invoicing. It captures the operational linkage used by finance teams to reconcile per-visit billing charges on | 10 |
| participant_management | disposition | transactional_data | Transactional record capturing each formal disposition milestone of a subject through the study lifecycle (screened, enrolled, randomized, completed, discontinued, withdrawn, lost to follow-up, death). | 50 |
| participant_management | eligibility_assessment | transactional_data | Transactional record of the inclusion/exclusion criteria assessment performed for a subject during screening. Captures each criterion code, criterion text, assessment result (met/not met/not assessed), assessment date, assessor identity, and overall | 44 |
| participant_management | enrollment | transactional_data | Transactional record capturing the formal enrollment event of a subject into a clinical study at a specific investigational site. Tracks screening date, enrollment date, randomization eligibility confirmation, enrollment status (screened, enrolled | 46 |
| participant_management | population_assignment | master_data | Transactional record assigning a trial subject to one or more analysis populations (Intent-to-Treat/ITT, modified ITT/mITT, Per-Protocol/PP, Safety/SAF, Pharmacokinetic/PK) as determined by the biostatistics team during database lock. | 44 |
| participant_management | randomization_assignment | transactional_data | Transactional record of a subject's randomization event, capturing the randomization code, treatment arm assignment, stratification factor values applied at randomization, randomization date and time, IRT/RTSM transaction reference, blinding status, and | 42 |
| participant_management | stipend_payment | transactional_data | Transactional record of subject stipend and reimbursement payments issued to trial participants for visit attendance, travel expenses, and participation costs per IRB/IEC-approved payment schedule. | 44 |
| participant_management | subject_contact | master_data | Canonical contact entity for trial subject emergency contacts, next of kin, and legally authorized representatives. Sponsor organization contacts reference sponsor.sponsor_contact; this entity is reserved for subject-related contacts only. | 42 |
| participant_management | subject_deviation | transactional_data | Transactional record of a protocol deviation identified for a subject, capturing deviation category (major, minor, important), deviation type code, description, date of occurrence, date identified, root cause, impact on subject safety and data integrity | 46 |
| participant_management | subject_status_history | transactional_data | Lifecycle history table tracking every status transition of a trial subject across the enrollment lifecycle (e.g., pre-screened → screened → screen-failed → enrolled → randomized → on-treatment → completed → withdrawn). | 39 |
| participant_management | subject_visit | transactional_data | Single owner of a subject's protocol-scheduled study visit (clinical visit). | 39 |
| participant_management | trial_subject | master_data | Core master entity representing a unique trial participant (subject/patient) screened or enrolled in a clinical study. Serves as the SSOT for subject identity including screening number, subject number, randomization number, demographic profile (age, sex | 37 |

<a id="domain-supply"></a>

### Domain: Supply

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| supply | operations | 4 | Manages investigational medicinal product (IMP) and clinical supply chain operations. Owns drug supply planning, depot and site inventory, randomization kits, dispensing records via RTSM (Medidata Rave), expiry management, returns and destruction | 25 |

**Subdomains:** contract_relationships, distribution_logistics, inventory_operations, product_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_relationships | budget_allocation | association_data | This association product represents the Contract between supply_plan and budget_line. It captures the operational mapping maintained by clinical supply finance teams that links specific supply plan versions to granular budget line items, tracking the | 11 |
| contract_relationships | contracted_supply_item | association_data | This association product represents the Contract between imp_master and study_contract. It captures the specific terms under which a given investigational medicinal product is included in the supply scope of a Clinical Trial Agreement — recording the | 9 |
| contract_relationships | depot_sla_coverage | association_data | This association product represents the Contract/Assignment between a clinical supply depot and a Service Level Agreement. It captures which SLAs are actively governing each depot in the supply network, along with the operational details of that coverage | 8 |
| contract_relationships | imp_authorization | association_data | This association product represents the regulatory authorization contract between an investigational medicinal product (imp_master) and a Clinical Trial Authorization (clinical_trial_authorization). | 10 |
| contract_relationships | imp_indication_track | association_data | This association product represents the Development Track between imp_master and indication. It captures the operational record of a specific investigational medicinal product being developed for a specific therapeutic indication, including the | 10 |
| contract_relationships | imp_sop_applicability | association_data | This association product represents the formal applicability relationship between an investigational medicinal product (IMP) and a Standard Operating Procedure (SOP) within the quality management system. | 8 |
| distribution_logistics | accountability_reconciliation | transactional_data | Periodic drug accountability reconciliation record at the site level, capturing the reconciliation period, opening balance, receipts, dispensed quantities, returned quantities, destroyed quantities, closing balance, discrepancy count and detail | 50 |
| distribution_logistics | destruction_record | transactional_data | Records the destruction of returned, expired, or rejected IMP/kits. Captures destruction authorization number, destruction date, destruction method (incineration, chemical neutralization), facility, quantity and kit numbers destroyed, witness details, and | 52 |
| distribution_logistics | dispensing_record | transactional_data | Captures each IMP dispensing event at an investigational site, recording the subject identifier, visit reference, kit number dispensed, IMP name, dose, quantity dispensed, dispensing date and time, dispensing staff, and RTSM confirmation number. | 47 |
| distribution_logistics | resupply_order | transactional_data | Captures resupply order requests triggered by RTSM resupply algorithms or manual supply manager intervention. Records the requesting site or depot, IMP/kit type requested, quantity requested, urgency level, order date, expected fulfillment date | 44 |
| distribution_logistics | return_record | transactional_data | Documents IMP/kit returns from subjects to sites and from sites to depots. Captures return type (subject return, site-to-depot, expired stock), kit numbers or quantities returned, return date, condition on return (intact, partially used, damaged) | 48 |
| distribution_logistics | shipment | transactional_data | Transactional record of IMP/kit shipments between supply chain nodes (manufacturer to depot, depot to site, site to site, site to depot for returns). Captures shipment number, origin, destination, carrier, tracking number, shipment date, expected delivery | 47 |
| distribution_logistics | shipment_line | transactional_data | Line-level detail for each IMP shipment, capturing individual kit numbers or batch quantities included in a shipment. Each line records the IMP/kit reference, quantity shipped, unit of measure, lot/batch number, expiry date, and line-level receipt | 42 |
| distribution_logistics | temperature_excursion | transactional_data | Records cold-chain temperature excursion events detected during IMP storage or transit. Captures excursion start and end timestamps, affected location (depot, site, in-transit), temperature range breached, duration, affected kit/batch numbers, impact | 45 |
| inventory_operations | depot | master_data | Master record for clinical supply depots (central and regional warehouses) that store and distribute IMPs. Captures depot name, geographic location, GMP certification status, temperature-controlled storage capabilities (ambient, refrigerated, frozen) | 47 |
| inventory_operations | depot_inventory | master_data | Tracks IMP and kit stock levels held at each depot, including quantities by batch, kit type, and storage condition zone. Records receipt date, current quantity on-hand, quantity allocated for pending shipments, quantity quarantined, quantity expired, and | 44 |
| inventory_operations | kit_inventory | master_data | Tracks physical randomization kit instances across the supply chain — from manufacture through depot receipt, site shipment, dispensing, and destruction. Each record represents a unique kit number with current status (available, assigned, dispensed | 44 |
| inventory_operations | site_inventory | master_data | Tracks IMP and kit stock positions at supply chain nodes (investigational sites and depots). Each record represents current inventory levels by IMP/kit type at a specific location, including quantity on-hand, received, dispensed, allocated, quarantined | 45 |
| inventory_operations | supply_plan | master_data | Clinical supply plan - distinct concept, separate owner from monitoring_plan and program_plan. | 48 |
| product_management | ancillary_supply | master_data | Tracks non-IMP clinical supplies required at investigational sites, including syringes, diluents, infusion sets, patient diaries, lab kits, and other protocol-required materials. | 49 |
| product_management | comparator_drug | master_data | Master record for comparator drugs and placebo products used in controlled clinical trials. Captures comparator drug name, manufacturer, regulatory approval status in applicable countries, sourcing strategy (commercial purchase vs. | 47 |
| product_management | imp_master | master_data | Master record for all investigational and comparator products used in clinical trials, including sponsor IMPs, active comparators, and placebos. Captures product identity, product type (IMP/comparator/placebo), formulation details, dosage form, strength | 49 |
| product_management | import_permit | master_data | Manages country-level import permits and licenses required for cross-border IMP shipments. Captures permit number, issuing authority, country, IMP reference, permitted quantity, permit validity dates, application date, approval date, and permit status. | 47 |
| product_management | kit_definition | master_data | Defines randomization kit configurations used in RTSM (Medidata Rave). Captures kit type, treatment arm association, blinding level, component IMPs, pack size, label text, kit number range, and applicable study/protocol version. | 42 |
| product_management | manufacture_batch | master_data | Records IMP manufacturing batch details including batch number, manufacturing date, batch size, manufacturing site, GMP certificate of analysis reference, release status (quarantine, released, rejected), expiry date, and storage conditions. | 41 |

<a id="domain-agreement"></a>

### Domain: Agreement

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| agreement | business | 2 | Stores study contracts, master service agreements, amendments, scope of work documents, change orders, and service-level agreements. Governs the legal and commercial relationship between sponsor and CRO including billing milestones and deliverable | 16 |

**Subdomains:** contract_management, financial_terms


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_management | change_order | transactional_data | Formal Change Order (CO) or Contract Change Notice (CCN) issued to modify the scope, budget, or timeline of an existing SOW or study contract. Captures change order number, change type (scope increase, scope decrease, timeline extension, budget | 45 |
| contract_management | confidentiality_agreement | master_data | Non-Disclosure Agreement (NDA) or Confidentiality Disclosure Agreement (CDA) executed between the CRO and a sponsor or partner prior to or alongside a study contract. | 44 |
| contract_management | contract_amendment | transactional_data | Formal amendment to a master service agreement or study contract that modifies legal terms, commercial conditions, or governing clauses (as distinct from a Change Order which modifies scope/budget). | 49 |
| contract_management | contract_negotiation | transactional_data | Tracks the negotiation lifecycle of a contract or amendment from initial draft through final execution. Captures negotiation round number, negotiation status (draft, under review, redline, legal review, approved, executed), negotiation start date, target | 52 |
| contract_management | contract_obligation | master_data | Specific contractual obligation or commitment extracted from a study contract, MSA, SOW, or subcontract that must be tracked for compliance. Captures obligation type (regulatory, financial, operational, reporting, dispute-related), obligation description | 49 |
| contract_management | master_service_agreement | master_data | SSOT for Master Service Agreements (MSAs) between the CRO and pharmaceutical/biotech sponsors, including standalone NDAs/CDAs modeled as agreement_type='NDA'. | 42 |
| contract_management | preferred_provider_agreement | master_data | Preferred Provider Agreement (PPA) or Framework Agreement establishing pre-negotiated terms, rates, and service standards with a CRO or vendor for a portfolio of studies. | 46 |
| contract_management | scope_of_work | master_data | Formal Scope of Work (SOW) document attached to a study contract or MSA, defining the specific services, deliverables, timelines, and responsibilities the CRO will perform. | 43 |
| contract_management | service_level_agreement | master_data | Service Level Agreement (SLA) defining measurable performance commitments the CRO must meet for specific service categories (e.g., query resolution turnaround, SAE reporting timelines, monitoring visit frequency, data entry lag). | 48 |
| contract_management | study_contract | master_data | Study-level contract (Clinical Trial Agreement / CTA) executed between the sponsor and CRO for a specific clinical study. Captures contract number, study reference, contract type (full-service, functional service, co-development), total contracted value | 44 |
| contract_management | subcontract | master_data | Subcontract or sub-CRO agreement executed by the CRO with a third-party vendor or sub-CRO to delegate specific services defined in the primary study contract. | 47 |
| financial_terms | agreement_billing_milestone | master_data | Contractually defined billing milestone tied to a study contract or SOW, representing a specific deliverable or event that triggers an invoice. Captures milestone name, milestone type (enrollment-based, visit-based, deliverable-based, time-based), planned | 42 |
| financial_terms | deliverable | master_data | Contractually committed deliverable defined within a SOW or study contract, representing a specific output the CRO must produce (e.g., Clinical Study Report, Statistical Analysis Plan, Data Management Plan, Monitoring Plan, Regulatory Submission Package). | 45 |
| financial_terms | investigator_grant | master_data | Contractual grant agreement between the CRO (on behalf of the sponsor) and an investigational site or Principal Investigator (PI) defining per-procedure and per-visit payment rates for conducting the clinical trial. | 48 |
| financial_terms | obligation_fulfillment | association_data | This association product represents the fulfillment event between a contractual deliverable and a contract obligation. It captures the operational record of how and to what degree a specific deliverable satisfies a specific contractual obligation, serving | 8 |
| financial_terms | rate_card | reference_data | Pre-negotiated rate card defining unit prices for specific CRO services, staff categories, and activities applicable to a sponsor relationship or preferred provider agreement. | 45 |

<a id="domain-program"></a>

### Domain: Program

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| program | business | 6 | Manages clinical development programs spanning multiple studies for a therapeutic indication or pipeline asset. Owns program-level planning, portfolio governance, milestone tracking, and cross-study coordination. | 24 |

**Subdomains:** performance_monitoring, portfolio_management, resource_allocation, risk_oversight, stakeholder_intelligence, strategic_planning


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| performance_monitoring | kri | master_data | Master record defining Key Risk Indicators (KRIs) and Key Performance Indicators (KPIs) monitored at the program level for portfolio governance. Captures indicator name, indicator type (KRI or KPI), metric definition, measurement unit, target threshold | 46 |
| performance_monitoring | kri_reading | transactional_data | Transactional record capturing periodic observed readings of program-level KRIs and KPIs against their defined thresholds. Captures the KRI reference, reading date, observed value, threshold status (green/amber/red), trend direction, data source snapshot | 39 |
| portfolio_management | clinical_program | master_data | Top-level master entity representing a clinical development program — a strategic grouping of one or more clinical studies targeting a specific therapeutic indication or pipeline asset. | 36 |
| portfolio_management | indication | reference_data | Reference master for therapeutic indications and disease areas targeted by clinical development programs. Captures indication name, ICD-10/ICD-11 code, MedDRA preferred term mapping, therapeutic area classification, disease category, orphan disease flag | 45 |
| portfolio_management | program_development_milestone | transactional_data | Tracks key program-level milestones and their planned versus actual achievement dates across the clinical development lifecycle. Captures milestone name, milestone type (e.g., IND filing, Phase I start, Phase II start, Phase III start, NDA/BLA submission | 43 |
| portfolio_management | program_study | association_data | Association entity representing the formal relationship between a clinical development program and the individual clinical studies (protocols) that constitute it. | 41 |
| portfolio_management | therapeutic_area | reference_data | Reference master defining the therapeutic area taxonomy used to classify clinical development programs and pipeline assets. Captures therapeutic area name, therapeutic area code, parent therapeutic area (for hierarchy), description, and alignment to | 43 |
| resource_allocation | budget | master_data | Master record for the program-level budget envelope governing total financial investment across all studies and activities within a clinical development program. | 43 |
| resource_allocation | program_resource_plan | master_data | Master record for program-level resource planning, capturing the aggregate workforce and functional resource requirements across all studies in a program. Captures resource plan version, planning period, functional area (clinical operations, data | 44 |
| resource_allocation | program_status_history | transactional_data | Lifecycle history table tracking every formal status transition of a clinical development program from initiation through completion or termination. Captures previous status, new status, transition date, transition reason, triggering event (governance | 39 |
| resource_allocation | team_member | association_data | Association entity capturing the assignment of key personnel to a clinical development program in defined program-level roles. Captures the workforce member reference, program role (Program Director, Medical Director, Regulatory Lead, Biostatistics Lead | 42 |
| risk_oversight | assumption | master_data | Master record for key planning assumptions underlying the clinical development plan and program timeline. Captures assumption description, assumption category (enrollment rate, regulatory timeline, safety profile, competitive landscape, manufacturing | 38 |
| risk_oversight | cross_study_dependency | association_data | Association entity capturing formal dependencies between studies within a program or across programs where one study's outcome, data, or completion gates another study's initiation or design. | 39 |
| risk_oversight | risk | master_data | Master record for program-level risks identified through risk management processes. Captures risk identifier, risk category (scientific, regulatory, operational, competitive, financial, safety), risk description, probability rating, impact rating, risk | 43 |
| risk_oversight | risk_mitigation | transactional_data | Transactional record capturing individual risk mitigation actions and their execution status for program-level risks. Captures mitigation action description, action owner, planned completion date, actual completion date, action status (planned | 42 |
| stakeholder_intelligence | competitive_intelligence | master_data | Master record for competitive intelligence entries tracked at the program level, capturing the competitive landscape for the therapeutic indication being developed. | 44 |
| stakeholder_intelligence | program_communication | transactional_data | Transactional record for formal program-level communications issued to stakeholders including sponsors, health authorities, and internal leadership. Captures communication date, communication type (program update, milestone notification, risk escalation | 43 |
| strategic_planning | amendment | transactional_data | Tracks formal amendments and revisions to the clinical development plan (CDP) for a program. Captures amendment number, amendment date, amendment type (scope change, timeline revision, budget revision, regulatory strategy update), description of changes | 41 |
| strategic_planning | decision | transactional_data | Transactional record capturing formal go/no-go and key strategic decisions made at the program level, including portfolio investment decisions, phase transition approvals, and program termination decisions. | 47 |
| strategic_planning | governance | master_data | Master record for program-level governance bodies and oversight committees established to manage a clinical development program. Captures governance body name, type (Joint Development Committee, Program Review Board, Portfolio Review Committee, Steering | 46 |
| strategic_planning | governance_meeting | transactional_data | Transactional record for each formal program governance meeting held by a program oversight committee. Captures meeting date, meeting type (scheduled, ad hoc, emergency), agenda topics, attendees, quorum achieved flag, key decisions made, action items | 42 |
| strategic_planning | program_strategic_plan | master_data | Strategic development plan for a clinical program, defining objectives, timelines, budget, regulatory pathway, and key assumptions. This is the canonical program-level plan entity; supply.supply_plan references this when a supply plan is linked to a | 43 |
| strategic_planning | timeline | master_data | Master record for the integrated program-level timeline, capturing the overall schedule baseline and current forecast for a clinical development program. Captures timeline version, baseline start date, baseline end date, current forecast start date | 42 |
| strategic_planning | timeline_event | transactional_data | Transactional record for individual scheduled events and deliverables within a program timeline. Captures event name, event type (study start, database lock, regulatory submission, advisory committee meeting, approval decision, program review), planned | 44 |

<a id="domain-sponsor"></a>

### Domain: Sponsor

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| sponsor | business | 4 | SSOT for pharmaceutical and biotech sponsor organizations that fund and own clinical trials. Manages sponsor organization profiles, contracted study portfolios, therapeutic areas, pipeline products, regulatory strategies, commercial relationships, contact | 19 |

**Subdomains:** commercial_operations, enterprise_management, portfolio_development, relationship_governance


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| commercial_operations | account_plan | master_data | Strategic account plan developed by the CRO for key sponsor accounts, capturing the annual or multi-year relationship strategy. Tracks plan period, strategic objectives, revenue targets by service line, pipeline opportunities identified, relationship | 43 |
| commercial_operations | bid_request | transactional_data | Captures sponsor requests for proposal (RFP) and bid requests submitted to the CRO for new study work. Tracks RFP reference number, sponsor name, study description, therapeutic area, indication, study phase, estimated subject count, site count, country | 49 |
| commercial_operations | proposal | transactional_data | Master record for CRO proposals submitted in response to sponsor bid requests, including full line-item cost and scope detail. Captures proposal number, version, type (full-service, FSP, change order), submission date, total proposed budget, proposed | 48 |
| commercial_operations | proposal_line | transactional_data | Line-item detail of a CRO proposal, capturing the granular cost and scope breakdown by service category. Each line captures service category (project management, clinical monitoring, data management, biostatistics, regulatory, medical writing, laboratory | 45 |
| enterprise_management | org_hierarchy | master_data | Defines parent-child corporate hierarchy relationships among sponsor organizations, capturing subsidiary, affiliate, and division structures. Tracks relationship type (parent, subsidiary, affiliate, division, joint-venture), effective dates, ownership | 36 |
| enterprise_management | organization | master_data | Master record for pharmaceutical and biotech sponsor organizations that fund and own clinical trials. Captures the authoritative profile of each sponsor entity including legal name, organization type (pharma, biotech, academic, government), headquarters | 42 |
| enterprise_management | organization_contact | master_data | Canonical contact entity for sponsor organization personnel. Subject-related contacts reference subject.subject_contact; sponsor-related contacts use this entity. | 37 |
| portfolio_development | pipeline_asset | master_data | Master record for investigational drug, biologic, or device assets in a sponsor's development pipeline. Captures compound/molecule name, INN (International Nonproprietary Name), brand name candidate, drug class, mechanism of action, modality (small | 42 |
| portfolio_development | pipeline_asset_phase | transactional_data | Tracks the development phase history and transitions of a pipeline asset across its lifecycle. Captures phase (preclinical, Phase I, Phase Ib, Phase II, Phase IIa, Phase IIb, Phase III, Phase IV, NDA/BLA submission, approved), phase start date, phase end | 44 |
| portfolio_development | regulatory_strategy | master_data | Documents the regulatory strategy and submission pathway planned by a sponsor for a pipeline asset or study program. Captures target health authority (FDA, EMA, PMDA, MHRA, Health Canada), submission pathway (IND, NDA, BLA, MAA, 505(b)(2), biosimilar) | 43 |
| portfolio_development | study_portfolio | master_data | Represents the contracted study portfolio relationship between a sponsor organization and the CRO, linking sponsor organizations to the clinical studies they have commissioned. | 38 |
| relationship_governance | delivery_preference | master_data | Captures sponsor-specific operational preferences, standards, and requirements that govern how the CRO delivers services for that sponsor. Includes EDC system preference (Medidata Rave, the source system other), eTMF platform preference (Veeva Vault | 47 |
| relationship_governance | engagement_contact_assignment | association_data | This association product represents the formal Role assignment between a sponsor_contact and an engagement. It captures the operational record of which sponsor personnel are assigned to a CRO commercial engagement, in what functional capacity, and for | 11 |
| relationship_governance | engagement_scope | association_data | This association product represents the Contract/Scope between a sponsor engagement and a health authority. It captures the formal designation of which health authorities are in scope for a given CRO-sponsor engagement, along with submission volume | 8 |
| relationship_governance | escalation | transactional_data | Tracks formal escalations raised by or to sponsor organizations during study execution. Captures escalation date, escalation type (quality issue, timeline delay, budget overrun, safety concern, resource issue, regulatory risk, relationship issue) | 53 |
| relationship_governance | interaction | transactional_data | Transactional record of all business interactions and touchpoints between CRO personnel and sponsor contacts, encompassing informal touchpoints, formal governance meetings (JSC, JOC, EBR, QBR), business reviews, bid defenses, and regulatory strategy | 48 |
| relationship_governance | master_agreement | master_data | Captures the terms and conditions of preferred provider or master service framework agreements between a sponsor and the CRO at the enterprise level, distinct from individual study contracts (which live in the agreement domain). | 45 |
| relationship_governance | review_meeting | transactional_data | Tracks formal governance meetings between sponsor and CRO organizations including Joint Steering Committee (JSC), Joint Operations Committee (JOC), Executive Business Reviews (EBR), and Quality Business Reviews (QBR). | 49 |
| relationship_governance | sponsor_engagement | master_data | Master record for the commercial engagement relationship between a sponsor and the CRO, representing the overarching business relationship spanning multiple studies and contracts. | 44 |

<a id="domain-terminology"></a>

### Domain: Terminology

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| terminology | business | 6 | The terminology domain. | 33 |

**Subdomains:** clinical_vocabulary, dictionary_registry, laboratory_standards, medical_coding, pharmaceutical_classification, toxicity_grading


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| clinical_vocabulary | snomed |  | Reviewer-directed snomed table. | 7 |
| clinical_vocabulary | snomed_ct |  | SNOMED CT concepts. | 7 |
| clinical_vocabulary | snomed_ct_concept |  | SNOMED CT concept. | 4 |
| dictionary_registry | anything |  | Reviewer-directed anything table. | 5 |
| dictionary_registry | code_system |  | CDISC terminology code system registry entry (MedDRA, WHODrug, LOINC, SNOMED CT, CTCAE, ICD-10). | 7 |
| dictionary_registry | code_system_version |  | Released version of a coding dictionary. | 6 |
| dictionary_registry | plus |  | Reviewer-directed plus table. | 6 |
| dictionary_registry | terminology_codelist |  | CDISC Controlled Terminology codelist | 8 |
| dictionary_registry | terminology_codelist_term |  | CDISC Controlled Terminology codelist term | 11 |
| laboratory_standards | loinc |  | LOINC laboratory and clinical observation codes. | 5 |
| laboratory_standards | loinc_code |  | LOINC code. | 5 |
| medical_coding | icd |  | Reviewer-directed icd table. | 5 |
| medical_coding | icd10_code |  | ICD-10 code. | 7 |
| medical_coding | meddra_hlgt |  | High Level Group Term in the MedDRA hierarchy. | 9 |
| medical_coding | meddra_hlt |  | High Level Term in the MedDRA hierarchy. | 9 |
| medical_coding | meddra_llt |  | Lowest Level Term in the MedDRA hierarchy. | 11 |
| medical_coding | meddra_pt |  | Preferred Term in the MedDRA hierarchy. | 10 |
| medical_coding | meddra_smq |  | Standardised MedDRA Query (SMQ). | 9 |
| medical_coding | meddra_soc |  | System Organ Class - top level of the MedDRA hierarchy. | 8 |
| medical_coding | meddra_term |  | MedDRA term (relocated from safety; terminology is the single owner). | 5 |
| pharmaceutical_classification | whodrug |  | Reviewer-directed whodrug table. | 7 |
| pharmaceutical_classification | whodrug_atc |  | WHODrug ATC classification levels 1-4. | 12 |
| pharmaceutical_classification | whodrug_atc_classification |  | WHODrug ATC classification levels 1 to 4. | 7 |
| pharmaceutical_classification | whodrug_atc_level1 |  | WHODrug ATC classification level 1 | 14 |
| pharmaceutical_classification | whodrug_atc_level2 |  | WHODrug ATC classification level 2 | 17 |
| pharmaceutical_classification | whodrug_atc_level3 |  | WHODrug ATC classification level 3 | 15 |
| pharmaceutical_classification | whodrug_atc_level4 |  | WHODrug ATC classification level 4 | 17 |
| pharmaceutical_classification | whodrug_drug_record |  | WHODrug Global drug record. | 8 |
| pharmaceutical_classification | whodrug_preferred_name |  | WHODrug Global preferred name. | 6 |
| pharmaceutical_classification | whodrug_record |  | WHODrug Global drug record. | 9 |
| toxicity_grading | ctcae |  | CTCAE adverse event terms and grades. | 9 |
| toxicity_grading | ctcae_grade |  | CTCAE grade (relocated from safety; terminology is the single owner). | 4 |
| toxicity_grading | ctcae_term_catalog |  | CTCAE term catalog entry. | 5 |

<a id="domain-compliance"></a>

### Domain: Compliance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| compliance | corporate | 3 | Manages GCP quality assurance (QA), quality control (QC), internal and external audits, regulatory inspections, CAPA lifecycle, protocol deviation classifications, SOP compliance tracking, and audit readiness. | 22 |

**Subdomains:** ethical_review, quality_oversight, training_documentation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| ethical_review | continuing_review | Master | Manages the periodic continuing review process required by IRBs/IECs to ensure ongoing ethical conduct of a study | 44 |
| ethical_review | ethics_approval | Master | Records the formal approval decision issued by an IRB or IEC for a study protocol, ICF, or amendment including approval conditions and expiry dates | 46 |
| ethical_review | ethics_committee | Master | Master record for each IRB or IEC body providing ethical oversight for clinical trials, capturing committee name, type, jurisdiction, and accreditation status | 48 |
| ethical_review | ethics_correspondence | Master | Captures all formal written communications between the sponsor/CRO and ethics committees including queries, clarifications, and notifications | 45 |
| ethical_review | ethics_submission | Master | Tracks each formal submission package sent to an IRB or IEC for a specific study, including initial review, amendments, and continuing review submissions | 42 |
| ethical_review | irb_reliance | Master | Records single-IRB reliance agreements and authorization agreements between reviewing IRBs and relying institutions under the Common Rule | 42 |
| ethical_review | vulnerable_population | Master | Tracks special ethical protections and safeguards applied to studies enrolling vulnerable populations including pediatric, pregnant, and cognitively impaired subjects | 44 |
| quality_oversight | audit | master_data | Master record for all internal and external GCP audits conducted across studies, sites, systems, and vendors. Captures audit type (system, process, vendor, site, TMF), scope, lead auditor, planned and actual dates, audit status, sponsoring organization | 42 |
| quality_oversight | audit_finding | transactional_data | Transactional record of individual findings identified during an internal or sponsor-initiated GCP audit. Captures finding reference number, finding category (critical, major, minor, observation), finding description, ICH GCP clause reference, regulatory | 44 |
| quality_oversight | capa_action_item | transactional_data | Transactional record of individual action items within a CAPA plan. Each CAPA may have multiple discrete action items assigned to different owners with independent due dates and completion statuses. | 40 |
| quality_oversight | compliance_capa | master_data | Master record for Corrective and Preventive Actions (CAPA) initiated in response to audit findings, inspection findings, protocol deviations, QC failures, or self-identified quality issues. | 43 |
| quality_oversight | deviation_classification | reference_data | Reference master defining the standardized classification taxonomy for protocol deviations used across all studies. Captures deviation category (major, minor, important protocol deviation), deviation type code, regulatory reporting threshold, standard | 43 |
| quality_oversight | inspection_finding | transactional_data | Transactional record of individual findings issued by a regulatory authority during a formal inspection. Captures finding number, regulatory citation (e.g., FDA Form 483 observation, EMA GCP non-compliance), finding classification (critical, major | 44 |
| quality_oversight | obligation | reference_data | Reference master defining the regulatory and contractual compliance obligations applicable to the organization across jurisdictions and study types. Captures obligation reference, obligation source (ICH GCP, FDA 21 CFR Part 11, EU CTR 536/2014, GDPR | 44 |
| quality_oversight | protocol_deviation | transactional_data | Transactional record of protocol deviations identified during study conduct. Captures deviation reference number, study and site identifiers, subject identifier (if applicable), deviation category (major, minor, important), deviation type (eligibility | 51 |
| quality_oversight | quality_event | transactional_data | Transactional record capturing quality events identified through QC reviews, self-inspections, routine quality monitoring, or proactive quality surveillance activities. | 49 |
| quality_oversight | regulatory_commitment | master_data | Master record tracking formal commitments made to regulatory authorities (FDA, EMA, PMDA) in response to inspection findings, warning letters, or agency queries. | 45 |
| quality_oversight | risk_assessment | master_data | Master record for quality risk assessments conducted at study, site, process, system, or inspection-readiness level to support risk-based quality management (RBQM). | 51 |
| training_documentation | compliance_sop | master_data | Master record for Standard Operating Procedures (SOPs) managed within the quality management system. Captures SOP number, title, version, effective date, expiry date, SOP owner (department/role), applicable process area, regulatory basis (GCP, GLP, GMP) | 46 |
| training_documentation | sop_training_record | transactional_data | Transactional record capturing individual staff training completions against required SOPs. Captures staff member identifier, SOP version trained on, training method (read-and-understand, classroom, e-learning, OJT), training completion date, assessment | 38 |
| training_documentation | sop_training_requirement | master_data | Master record defining which SOPs are required training for which roles, departments, or study assignments. Captures role or job function, SOP identifier, training frequency (initial, annual, on-change), grace period days, and whether training is | 42 |
| training_documentation | training_plan | master_data | Master reference table for training_plan. Referenced by training_plan_id. | 39 |

<a id="domain-document"></a>

### Domain: Document

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| document | corporate | 3 | SSOT for Trial Master File (TMF/eTMF) essential documents, SOP library, regulatory binders, site files, controlled document versioning, document workflows, DIA TMF Reference Model compliance, inspection readiness, and archival per ICH GCP requirements. | 19 |

**Subdomains:** control_lifecycle, regulatory_submission, trial_master


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| control_lifecycle | access_log | transactional_data | Business compliance audit trail recording access events to controlled documents in Veeva Vault per 21 CFR Part 11 requirements. Each record captures: user identity, user role, access action (view, download, print, edit, delete), document version accessed | 43 |
| control_lifecycle | distribution | transactional_data | Tracks the controlled distribution of approved documents (SOPs, protocols, amendments, ICFs) to recipients. Captures distribution date, document version distributed, recipient name, recipient role, recipient organization (site, sponsor, CRO), distribution | 40 |
| control_lifecycle | document_icf_version | master_data | Master entity for Informed Consent Form (ICF) document versions managed within the TMF and document control system. Captures ICF version number, version date, IRB/IEC approval date, applicable subject population (adult, pediatric, LAR), language | 39 |
| control_lifecycle | document_sop | master_data | Master entity for Standard Operating Procedures (SOPs) in the controlled document library (MasterControl). Each record represents one SOP with: SOP number, title, current version, effective/expiry dates, category (clinical operations, data management | 44 |
| control_lifecycle | signature | transactional_data | Records electronic signatures applied to controlled documents per 21 CFR Part 11 requirements. Captures signer identity, signer role (author, reviewer, approver, sponsor representative), signature date and timestamp, signature meaning (reviewed, approved | 42 |
| control_lifecycle | template | master_data | Master entity for approved document templates used to create standardized clinical trial documents (protocol templates, ICF templates, CSR shells, the source system annotation templates). | 41 |
| control_lifecycle | version | transactional_data | Tracks the full version history of every controlled document in the TMF and SOP library. Each record represents a discrete version of a document, capturing version number, effective date, expiry date, version status (draft, in-review, approved | 41 |
| control_lifecycle | workflow | transactional_data | Tracks the lifecycle workflow state of a document through its review, approval, and distribution process within Veeva Vault. Captures workflow instance ID, workflow template name, current workflow step, step assignee role, step due date, step completion | 44 |
| regulatory_submission | archival_record | master_data | Master entity tracking the archival disposition of TMF documents and study files at study close-out per ICH GCP requirements. Captures archival date, archival location (physical archive, long-term electronic archive), archive reference number, retention | 40 |
| regulatory_submission | binder_document | association_data | Association entity linking individual documents to a regulatory binder or eCTD sequence. Captures the binder, the document version included, the CTD section (e.g., Module 1.2, Module 5.3.5.1), sequence order, inclusion rationale, QC review status, and the | 43 |
| regulatory_submission | inspection_readiness | master_data | Master record tracking the inspection readiness status of a study's TMF for regulatory authority inspections (FDA, EMA, MHRA, PMDA). Captures study reference, inspection type (GCP, TMF, sponsor), target inspection date, readiness status (not-started | 42 |
| regulatory_submission | regulatory_binder | master_data | Master entity representing a regulatory submission binder or eCTD sequence package assembled for health authority submissions (IND, NDA, BLA, MAA, CTA). Captures binder ID, binder type (IND, NDA, BLA, MAA, CTA, annual report), submission sequence number | 40 |
| trial_master | delegation_of_authority | master_data | Master reference table for delegation_of_authority. Referenced by delegation_of_authority_id. | 43 |
| trial_master | etmf_exchange | transactional_data | Tracks eTMF document exchange transactions between CRO and sponsor organizations per the DIA eTMF Exchange Mechanism Standard. Each record represents a discrete transfer event: exchange direction (CRO-to-sponsor, sponsor-to-CRO), document package | 48 |
| trial_master | site_file | master_data | Master entity representing the Investigator Site File (ISF) or Regulatory Binder maintained at each investigational site. Captures site file ID, associated study, associated site, file type (ISF, regulatory binder, pharmacy binder), physical or electronic | 44 |
| trial_master | site_file_document | association_data | Association entity linking specific TMF documents to their corresponding Investigator Site File (ISF). Captures the site file, the document, the ISF section/tab, filing date, filing status (filed, missing, not-applicable), source (original, certified | 37 |
| trial_master | tmf_artifact | reference_data | Reference entity defining the DIA TMF Reference Model artifact taxonomy — the standardized classification of document types by Zone, Section, and Artifact number (e.g., Zone 1 Section 1.1 Artifact 01 - Protocol). | 42 |
| trial_master | tmf_completeness | transactional_data | Transactional record capturing a point-in-time TMF completeness assessment for a study, capturing the assessment date, assessed by (QA or TMF manager), overall completeness percentage, number of expected artifacts, number of filed artifacts, number of | 45 |
| trial_master | tmf_document | master_data | Core master entity representing an essential document within the Trial Master File (TMF/eTMF) as defined by the DIA TMF Reference Model. Captures document identity, TMF zone/section/artifact classification, title, version, lifecycle status (draft | 40 |

<a id="domain-finance"></a>

### Domain: Finance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| finance | corporate | 2 | Manages clinical trial financial operations including study budgets, investigator grants, site payment milestones, patient stipends, pass-through cost tracking, sponsor invoicing, accounts payable/receivable, accruals, financial forecasting, and project | 16 |

**Subdomains:** budget_planning, transaction_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| budget_planning | budget_line | master_data | Granular line-item breakdown of a study budget by WBS element, cost category, and time period. Captures budget line description, cost category (direct labor, pass-through, investigator grants, overhead), planned quantity, unit cost, total planned amount | 94 |
| budget_planning | cost_center | master_data | Master reference for the source system centers used to allocate and track clinical trial expenditures by organizational unit, therapeutic area, or functional department. | 38 |
| budget_planning | finance_billing_milestone | master_data | Master record defining the contractual billing milestones agreed with sponsors for triggering invoice generation. Captures milestone name, milestone type (enrollment-based, visit-based, deliverable-based, time-based), trigger criteria, planned billing | 51 |
| budget_planning | financial_forecast | master_data | Master record for rolling financial forecasts at the study or portfolio level, projecting future revenues, costs, and cash flows based on current enrollment rates, site activation status, and milestone completion projections. | 57 |
| budget_planning | gl_account | master_data | Master reference for General Ledger accounts used in clinical trial financial postings. Captures account number, account type (P&L vs balance sheet), account group, description, currency, and controlling area assignment per the source system of Accounts. | 45 |
| budget_planning | study_budget | master_data | Master record for the total approved financial budget allocated to a clinical study, including versioned amendments and granular line-item breakdown by cost category, WBS element, and fiscal period. | 50 |
| transaction_processing | accrual | transactional_data | Transactional record for financial accruals posted at period-end to recognize clinical trial costs incurred but not yet invoiced. Captures accrual type (site services, CRA monitoring, lab fees, investigator grants), accrual basis (enrollment-based | 90 |
| transaction_processing | invoice_line | transactional_data | Line-item detail for each sponsor invoice, capturing the specific service, milestone, or pass-through cost being billed. Includes line number, service description, billing category (professional fees, pass-through, investigator grant reimbursement, lab | 48 |
| transaction_processing | journal_entry | transactional_data | Transactional record for every financial journal entry posted in the source system clinical trial operations. Captures document number, posting date, fiscal period, document type (original, reversal, accrual), debit/credit line items, cost center, GL | 42 |
| transaction_processing | patient_stipend | transactional_data | Transactional record for stipend and reimbursement payments made to trial subjects (patients) for study participation, travel, and incidental expenses. Captures subject reference, study visit association, stipend type (participation fee, travel | 43 |
| transaction_processing | purchase_order | transactional_data | Master record for purchase orders issued to vendors and service providers supporting clinical trial operations (e.g., central labs, imaging CROs, specialty vendors, courier services). | 45 |
| transaction_processing | revenue_recognition | transactional_data | Transactional record capturing the revenue recognition events for clinical trial services delivered to sponsors, aligned with ASC 606 / IFRS 15 percentage-of-completion methodology. | 49 |
| transaction_processing | site_payment | transactional_data | Transactional record for payments disbursed to investigational sites against completed milestones, per-procedure fees, and per-visit fees as defined in the clinical trial agreement. | 44 |
| transaction_processing | sponsor_invoice | transactional_data | Master record for invoices and credit memos issued to pharmaceutical and biotech sponsors for clinical trial services rendered. Captures document type (invoice, credit memo, debit memo), invoice number, sponsor reference, study association, billing | 46 |
| transaction_processing | vendor | master_data | Master reference table for vendor. Referenced by vendor_id. | 45 |
| transaction_processing | vendor_invoice | transactional_data | Transactional record for invoices received from external vendors and service providers for clinical trial-related goods and services, including pass-through costs billable to sponsors. | 47 |

<a id="domain-regulatory"></a>

### Domain: Regulatory

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| regulatory | corporate | 4 | Manages regulatory submissions, approvals, and agency interactions across global health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Owns IND/NDA/BLA/MAA applications, clinical trial authorizations, protocol amendments, regulatory correspondence | 32 |

**Subdomains:** approval_tracking, authority_relations, protocol_governance, submission_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| approval_tracking | approval | transactional_data | Records regulatory approvals, authorizations, and decisions received from health authorities. Captures approval type (IND allowance, NDA approval, MAA approval, CTA authorization, label approval), approval date, effective date, approved indication | 40 |
| approval_tracking | clinical_trial_authorization | master_data | Master record for Clinical Trial Authorizations (CTAs) issued by national competent authorities under EU CTR 536/2014, national regulations, and equivalent non-US frameworks. | 42 |
| approval_tracking | commitment | master_data | Tracks post-approval regulatory commitments and post-marketing requirements imposed by health authorities as conditions of approval. Captures commitment type (post-marketing study, label update, REMS, risk minimization measure), commitment description | 43 |
| approval_tracking | country_registration | master_data | Tracks product registration status and requirements across individual countries and jurisdictions. Captures country, registration number, registration type (national, mutual recognition, decentralized, centralized), registration date, expiry date, renewal | 44 |
| approval_tracking | label_approval | association_data | This association product represents the formal approval event between a labeling_document version and a country_registration. It captures the regulatory act by which a health authority approves a specific labeling document version as the valid label for a | 11 |
| approval_tracking | regulatory_program_milestone | transactional_data | Canonical regulatory milestone entity. Tracks regulatory submission deadlines, agency action dates, approval milestones, and other regulatory timeline events. | 41 |
| approval_tracking | rems_program | master_data | Manages Risk Evaluation and Mitigation Strategy (REMS) programs required by FDA as a condition of approval for certain high-risk products. Tracks REMS program name, product covered, REMS elements (medication guide, communication plan, ETASU), program | 47 |
| approval_tracking | special_designation | master_data | Tracks special regulatory designations granted to investigational products by health authorities. Includes designation type (Breakthrough Therapy, Fast Track, Accelerated Approval, Priority Review, Orphan Drug, PRIME, Adaptive Pathways, SAKIGAKE) | 40 |
| authority_relations | agency_meeting | master_data | Master record for formal meetings with health authorities (FDA Type A/B/C meetings, EMA scientific advice, PMDA consultations). Tracks meeting type, request date, agency-confirmed date, meeting format (face-to-face, teleconference, written response) | 44 |
| authority_relations | correspondence | transactional_data | Records all formal communications between the sponsor/CRO and health authorities. Includes correspondence type (information request, complete response letter, refuse-to-file, meeting minutes, agency query, label negotiation), direction (inbound/outbound) | 44 |
| authority_relations | health_authority | reference_data | Reference master for global health authority organizations (FDA, EMA, PMDA, MHRA, Health Canada, TGA, ANVISA, NMPA, etc.). Stores agency code, full name, country/region, regulatory framework, submission portal URL, eCTD gateway identifier, contact | 45 |
| authority_relations | intelligence | master_data | Captures regulatory intelligence records tracking changes in health authority guidelines, regulations, and policies that may impact ongoing or planned submissions. | 43 |
| authority_relations | regulatory_action_item | transactional_data | Tracks action items arising from agency meetings, correspondence, inspection findings, and internal regulatory reviews. Captures action item description, source event (meeting, inspection, correspondence), assigned owner, due date, completion date | 46 |
| authority_relations | regulatory_engagement | association_data | This association product represents the Contract/Strategy between a clinical_program and a health_authority. It captures the agency-specific regulatory engagement plan for a given clinical development program — including submission strategy, target dates | 18 |
| authority_relations | regulatory_inspection | master_data | Master reference table for regulatory_inspection. Referenced by regulatory_inspection_id. | 33 |
| protocol_governance | labeling_document | master_data | Manages investigational and approved product labeling documents including Investigator Brochure (IB), Package Insert (PI/SmPC), Patient Information Leaflet (PIL), and Reference Safety Information (RSI). | 43 |
| protocol_governance | procedure | reference_data | Reference data defining regulatory procedures and pathways available across health authorities. Captures procedure type (centralized, decentralized, mutual recognition, national, abbreviated, hybrid), applicable agency, procedure code, standard review | 45 |
| protocol_governance | protocol_ethics_coverage | association_data | This association product represents the regulatory-compliance contract between an IND application and an ethics submission. It captures which specific protocol (by number and version) under a given IND application is covered by a given IRB/IEC ethics | 9 |
| protocol_governance | regulatory_protocol_amendment | transactional_data | Tracks protocol amendments submitted to health authorities and ethics committees. Captures amendment number, amendment type (substantial/non-substantial), amendment rationale, affected study sections, submission date to each agency, agency acknowledgment | 43 |
| protocol_governance | strategy | master_data | Documents the regulatory strategy plan for a development program or individual study. Captures target indication, development phase, global regulatory pathway (standard, accelerated, adaptive), key agency interactions planned, submission sequence | 43 |
| submission_management | application | master_data | Master record for regulatory applications (IND, NDA, BLA, MAA, CTA, IMPD) filed with health authorities. Tracks application number, application type and subtype, therapeutic area, indication, sponsor reference, lead agency, application status (active | 40 |
| submission_management | binder_content_inclusion | association_data | This association product represents the Inclusion relationship between a submission_content_unit and a regulatory_binder. It captures the operational record of a specific eCTD content unit (document, dataset, or study report) being included within a | 9 |
| submission_management | binder_document_inclusion | association_data | This association product represents the inclusion contract between a labeling_document and a regulatory_binder. It captures the operational act of assembling a regulatory submission binder by including specific labeling document versions, recording where | 9 |
| submission_management | ctd_dossier | master_data | Master record for the Common Technical Document (CTD) dossier structure and content inventory associated with a regulatory application. Tracks CTD format (eCTD/NeeS/paper), dossier version, completeness status, module-level readiness (Modules 1-5), last | 45 |
| submission_management | dossier_ethics_reference | association_data | This association product represents the formal inclusion of an ethics approval record within an NDA/BLA (or equivalent) application dossier. It captures the regulatory affairs act of citing a specific IRB/IEC ethics approval as supporting evidence within | 10 |
| submission_management | ind_application | master_data | Specialized master record for Investigational New Drug (IND) applications filed with the FDA (or equivalent CTAs with EMA/MHRA). Tracks IND number, IND type (commercial, research, emergency), sponsor name, investigational product name, phase coverage | 43 |
| submission_management | nda_bla_application | master_data | Specialized master record for New Drug Applications (NDA), Biologics License Applications (BLA), and equivalent marketing authorization applications (MAA). | 45 |
| submission_management | safety_report_submission | transactional_data | Tracks regulatory safety report submissions including IND Annual Reports, Development Safety Update Reports (DSURs), Periodic Safety Update Reports (PSURs/PBRERs), and expedited SUSAR/IND safety reports. | 40 |
| submission_management | submission | master_data | Master record for regulatory submissions and eCTD sequences sent to health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Each record represents a discrete submission event with sequence number, submission type (original, amendment, supplement | 42 |
| submission_management | submission_content_unit | transactional_data | Tracks individual content units (documents, datasets, study reports) included within a CTD/eCTD submission sequence. Captures CTD section reference (e.g., Module 2.7.3, Module 5.3.5.1), document title, document type, document version, file format, file | 47 |
| submission_management | submission_sequence | transactional_data | Tracks individual eCTD submission sequences within a regulatory application. Each sequence has a sequence number, submission type (original, amendment, supplement, response, withdrawal), sequence date, eCTD lifecycle operation (new, replace, append | 35 |
| submission_management | substantial_modification_submission | association_data | This association product represents the regulatory submission event between a protocol_amendment and a clinical_trial_authorization. It captures the per-member-state, per-amendment submission workflow required under EU CTR 536/2014 and equivalent national | 9 |

<a id="domain-workforce"></a>

### Domain: Workforce

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| workforce | corporate | 3 | Manages the clinical research workforce including CRAs, CRCs, biostatisticians, data managers, medical monitors, and regulatory specialists. Owns employee profiles, GCP training and certification records, delegation logs, resource allocation to studies | 17 |

**Subdomains:** learning_development, personnel_management, resource_allocation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| learning_development | gcp_training_record | transactional_data | Transactional record of GCP (Good Clinical Practice) training completions for each workforce member, sourced from MasterControl training management module. | 44 |
| learning_development | protocol_training_record | transactional_data | Transactional record capturing protocol-specific training completions for workforce members assigned to a clinical study. Captures study protocol number, protocol version trained on, employee, training date, training type (protocol overview, amendments | 41 |
| learning_development | training_course | master_data | Master reference table for training_course. Referenced by training_course_id. | 42 |
| learning_development | training_curriculum | master_data | Master record defining structured training curricula assigned to job profiles or roles within the clinical research organization. Captures curriculum name, target job profile or role, list of required training courses (GCP, SOP, protocol-specific | 43 |
| learning_development | training_record | transactional_data | Transactional record tracking the assignment and completion of SOP (Standard Operating Procedure) and controlled document training to workforce members, managed through MasterControl. | 40 |
| personnel_management | certification | master_data | Master record for professional certifications and credentials held by clinical research workforce members. Captures certification type (ACRP CCRC, ACRP CCRA, SOCRA CCRP, RAC, SAS Certified, etc.), issuing body, certification number, issue date, expiry | 39 |
| personnel_management | cra_qualification | master_data | Master record capturing the qualification profile of a Clinical Research Associate (CRA), including therapeutic area experience, monitoring experience (years, visit count), geographic coverage regions, language proficiencies, sponsor-specific | 43 |
| personnel_management | employee | master_data | Master record for every clinical research workforce member employed by or contracted to the CRO, sourced from the source system full employee identity, job profile assignment, organizational unit, employment type (full-time, part-time, contractor) | 42 |
| personnel_management | job_profile | reference_data | Reference master defining standardized job profiles and role classifications used across the clinical research workforce. Captures job family (Clinical Operations, Biostatistics, Data Management, Regulatory Affairs, Medical Affairs), job level (Associate | 45 |
| personnel_management | org_unit | reference_data | Reference master for the organizational hierarchy of the clinical research organization, sourced from the source system organizational unit name, unit type (department, division, cost center, team), parent unit, unit head employee, cost center code | 30 |
| personnel_management | payroll_record | transactional_data | Transactional record of payroll processing events for each employee, sourced from the source system module. Captures pay period start and end dates, gross pay, net pay, pay components (base salary, overtime, bonus, allowances), deductions (tax | 44 |
| personnel_management | position | master_data | Master record for approved headcount positions within the clinical research organization, managed in the source system position title, job profile, org unit, position type (permanent, fixed-term, contractor), budgeted FTE, current incumbency status | 38 |
| resource_allocation | program_team_member | association_data | This association product represents the Role-based assignment between an employee and a clinical_program. It captures the operational team membership record that the CRO actively manages for each employee-program pairing, including the employee's | 12 |
| resource_allocation | study_assignment | transactional_data | Transactional record capturing the formal assignment of a workforce member to a clinical study in a defined role, with FTE allocation percentage. Sourced from CTMS and the source system assignments. | 39 |
| resource_allocation | workforce_capa | transactional_data | Transactional record for Corrective and Preventive Actions (CAPAs) initiated against workforce members for GCP compliance failures, training non-compliance, or performance issues identified during audits or inspections. Managed through MasterControl. | 42 |
| resource_allocation | workforce_delegation_log | transactional_data | Transactional record of the formal delegation of trial-related duties from the Principal Investigator (PI) to site staff and CRO personnel, as required by ICH E6(R2) Section 8.3.25. | 41 |
| resource_allocation | workforce_resource_plan | master_data | Master record for workforce resource planning at the study, program, or organizational unit level. Captures planned FTE demand by role and time period, planned vs. | 47 |

## Metric Views

Total metric views generated: **166**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | biostatistics_analysis | biostatistics | analysis | Core analysis execution metrics tracking analysis completion, cycle time, and output productivity across studies and reporting events. |
| 2 | biostatistics_analysis_population | biostatistics | analysis_population | Analysis population metrics tracking ITT, PP, safety set definitions, subject counts, and population finalization for regulatory submissions |
| 3 | biostatistics_database_lock_event | biostatistics | database_lock_event | Database lock event metrics tracking lock cycle time, query resolution efficiency, and data quality readiness for regulatory submissions. |
| 4 | biostatistics_dsmb_meeting | biostatistics | dsmb_meeting | DSMB meeting metrics tracking meeting frequency, quorum achievement, recommendation outcomes, and stopping boundary decisions. |
| 5 | biostatistics_interim_analysis | biostatistics | interim_analysis | Interim analysis metrics tracking adaptive trial decision-making, stopping rule triggers, and DSMB recommendation outcomes. |
| 6 | biostatistics_sample_size_calc | biostatistics | sample_size_calc | Sample size calculation metrics tracking statistical power, enrollment targets, and design assumptions across studies and amendments. |
| 7 | biostatistics_sap | biostatistics | sap | Statistical Analysis Plan metrics tracking SAP version control, amendment frequency, regulatory alignment, and approval cycle time. |
| 8 | biostatistics_tlf_output | biostatistics | tlf_output | TLF output production metrics tracking programming productivity, QC cycle time, approval rates, and discrepancy resolution efficiency. |
| 9 | consent_capacity_assessment | consent | capacity_assessment | Capacity assessment KPIs tracking assessment outcomes, vulnerable population identification, LAR requirement rates, and reassessment compliance. |
| 10 | consent_deviation | consent | consent_deviation | Consent deviation and protocol compliance KPIs tracking deviation severity, regulatory reportability, IRB notification, and resolution timeliness. |
| 11 | consent_econsent_session | consent | econsent_session | eConsent platform performance and subject engagement KPIs tracking session completion, comprehension pass rates, technical issues, and digital signature capture. |
| 12 | consent_reconsent_trigger | consent | reconsent_trigger | Reconsent trigger and campaign management KPIs tracking trigger types, affected subject populations, reconsent completion rates, and regulatory compliance. |
| 13 | consent_subject_consent | consent | consent_subject_consent | Core consent KPIs tracking consent acquisition, reconsent activity, withdrawal rates, and comprehension assessment outcomes for clinical trial subjects. |
| 14 | consent_withdrawal | consent | withdrawal | Consent withdrawal KPIs tracking withdrawal reasons, methods, timing, and post-withdrawal data handling compliance. |
| 15 | datamanagement_coding_assignment | datamanagement | coding_assignment | Medical coding productivity and quality KPIs tracking coding completion, approval rates, autocoding performance, and recoding frequency across MedDRA and WHODrug dictionaries. |
| 16 | datamanagement_coding_quality | datamanagement | coding_assignment | Medical coding quality and efficiency metrics tracking coding assignment accuracy, approval rates, recoding frequency, and dictionary version compliance for adverse events, medications, and medical history across all clinical trials. |
| 17 | datamanagement_data_entry_productivity | datamanagement | data_entry_session | Data entry session productivity and efficiency metrics tracking session duration, field entry rates, error rates, and data entry quality across all EDC systems and clinical trial sites. |
| 18 | datamanagement_data_entry_session | datamanagement | data_entry_session | Data entry productivity and quality KPIs tracking session duration, field entry rates, error rates, and query generation across EDC operations. |
| 19 | datamanagement_data_quality_alcoa | datamanagement | alcoa_audit_entry | ALCOA+ data integrity compliance metrics tracking attributability, legibility, contemporaneousness, originality, and accuracy of clinical trial data entries across all EDC systems and source data verification activities. |
| 20 | datamanagement_discrepancy_query | datamanagement | discrepancy_query | Data quality and query management KPIs tracking discrepancy resolution performance, cycle times, and escalation rates across clinical data management operations. |

*... and 146 more metric views. See the `metrics/` folder for full details.*