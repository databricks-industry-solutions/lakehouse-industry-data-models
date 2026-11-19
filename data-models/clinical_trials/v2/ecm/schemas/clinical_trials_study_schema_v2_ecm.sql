-- Schema for Domain: study | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:35

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`study` COMMENT 'Core operational domain managing clinical study protocols, design, phases, objectives, endpoints, inclusion/exclusion criteria, visit schedules, and study lifecycle from protocol development through database lock.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`protocol` (
    `protocol_id` BIGINT COMMENT 'Unique surrogate identifier for the clinical study protocol record in the lakehouse. Primary key for the protocol data product.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Protocol has indication as free text. Linking to the canonical indication product ensures MedDRA coding consistency, supports regulatory dossier assembly by indication, and enables',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns and funds the clinical study. Links to the sponsor master record.',
    `sponsor_regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to sponsor.regulatory_strategy. Business justification: Protocols are developed in alignment with the sponsors regulatory strategy (submission pathway, health authority requirements, special designations).',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Protocol has therapeutic_area as a free-text denormalized column. Linking to the canonical therapeutic_area product enforces MedDRA/CDISC TA coding consistency, enables portfolio',
    `allocation_method` STRING COMMENT 'Method by which participants are assigned to study arms. Randomized indicates use of RTSM/IRT for random assignment; non-randomized indicates assignment by investigator or other non-random method.. Valid values are `randomized|non-randomized|not_applicable`',
    `amendment_date` DATE COMMENT 'Date on which the protocol amendment was formally issued or approved. Null for the original protocol version. Used to establish the amendment timeline and regulatory notification deadlines.',
    `amendment_number` STRING COMMENT 'Sequential identifier for the protocol amendment (e.g., Amendment 1, Amendment 2). Null for the original protocol version. Used to track the amendment history and link to regulatory submission records in Veeva Vault.',
    `amendment_rationale` STRING COMMENT 'Formal justification for the protocol amendment describing the scientific, safety, or operational reasons for the change. Required for regulatory submissions and IRB/IEC notifications. Stored in Veeva Vault eTMF.',
    `amendment_type` STRING COMMENT 'Classification of the protocol amendment per regulatory definitions. Substantial amendments require prior regulatory authority and IRB/IEC approval before implementation; non-substantial require notification only; administrative are clerical. Valid values are `substantial|non-substantial|administrative`',
    `approval_date` DATE COMMENT 'Date on which the protocol version received final sponsor and/or regulatory/IRB/IEC approval, making it the operative protocol for study conduct. Tracked in Veeva Vault quality management workflow. Establishes the effective date for GCP compliance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this protocol record was first created in the source system or ingested into the lakehouse. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `dsmb_required` BOOLEAN COMMENT 'Indicates whether the protocol mandates the establishment of a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for independent safety oversight and interim analysis review.',
    `eudract_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) number or Clinical Trials Information System (CTIS) number assigned under EU CTR 536/2014. Required for all clinical trials conducted in the EU/EEA.',
    `gcp_compliance_declaration` BOOLEAN COMMENT 'Indicates whether the protocol includes a formal declaration of compliance with ICH E6(R2) Good Clinical Practice (GCP) guidelines and applicable regulatory requirements. Required for all interventional clinical trials. Tracked in Veeva Vault.',
    `ich_compliance_declaration` BOOLEAN COMMENT 'Indicates whether the protocol formally declares compliance with applicable ICH guidelines (E6, E8, E9, E10, etc.). Distinct from GCP declaration; covers the broader ICH guideline framework including statistical and design standards.',
    `intervention_model` STRING COMMENT 'Describes the strategy for assigning interventions to participants. Determines the statistical analysis plan (the source system) structure, number of arms, and eCRF design in Medidata Rave. Aligns with CDISC SDTM ARM domain.. Valid values are `single_group|parallel|crossover|factorial|sequential`',
    `irb_iec_notification_status` STRING COMMENT 'Status of the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) notification or approval for this protocol version or amendment. Tracks compliance with ethics review requirements across jurisdictions.. Valid values are `not_required|pending|submitted|approved|waived`',
    `is_adaptive_design` BOOLEAN COMMENT 'Indicates whether the study employs an adaptive design allowing pre-specified modifications to the trial or statistical procedures based on interim data analysis. Triggers additional regulatory review requirements and DSMB/DMC oversight obligations.',
    `is_pediatric` BOOLEAN COMMENT 'Indicates whether the study includes a pediatric population (subjects under 18 years). Triggers Pediatric Investigation Plan (PIP) requirements under EMA and Pediatric Study Plan (PSP) under FDA PREA/BPCA, and specific ICF/assent requirements.',
    `masking_type` STRING COMMENT 'Level of blinding applied to the study to minimize bias. Specifies which parties (participant, investigator, outcomes assessor, data analyst) are blinded to treatment assignment. Critical for RTSM/IRT configuration and unblinding procedures.. Valid values are `open_label|single_blind|double_blind|triple_blind|quadruple_blind`',
    `number` STRING COMMENT 'Externally-known, sponsor-assigned unique alphanumeric identifier for the clinical study protocol (e.g., ABC-2024-001). Used across all regulatory submissions, site documents, and operational systems as the primary business key.',
    `number_of_arms` BIGINT COMMENT 'Total count of treatment arms (groups) defined in the protocol. Drives RTSM randomization configuration, eCRF arm assignment, and statistical analysis plan (the source system) structure. Must be consistent with the intervention model.',
    `planned_duration_months` BIGINT COMMENT 'Total planned duration of the study in months from first subject first visit (FSFV) to last subject last visit (LSLV) or database lock (DBL), as specified in the protocol.',
    `planned_end_date` DATE COMMENT 'Anticipated date of last subject last visit (LSLV) or database lock (DBL) as defined in the protocol and project plan. Used for resource planning, regulatory submission timelines, and study close-out activities.',
    `planned_sample_size` BIGINT COMMENT 'Total number of subjects planned for enrollment across all study sites and arms as specified in the protocol. Derived from the statistical power calculation in the the source system.',
    `planned_start_date` DATE COMMENT 'Anticipated date of first subject first visit (FSFV) or study initiation as defined in the protocol and project plan. Used for milestone tracking, site activation planning, and regulatory submission timelines in the source system',
    `primary_endpoint` STRING COMMENT 'The principal outcome measure used to evaluate the primary objective of the study. Defines the variable, measurement method, timepoint, and population. Drives eCRF design in Medidata Rave and the Statistical Analysis Plan (the source system).',
    `primary_objective` STRING COMMENT 'Formal statement of the primary scientific objective of the study as defined in the protocol. Describes the main question the study is designed to answer. Directly linked to the primary endpoint and powers the sample size calculation.',
    `primary_purpose` STRING COMMENT 'The primary reason for conducting the clinical study. Determines regulatory pathway, endpoint requirements, and IRB/IEC review criteria. [ENUM-REF-CANDIDATE',
    `registry_identifier` STRING COMMENT 'Public clinical trial registry identifier such as ClinicalTrials.gov NCT number (e.g., NCT12345678) or WHO ICTRP identifier. Required by ICMJE for publication eligibility and by FDA/EMA for transparency. Sourced from the source system',
    `regulatory_submission_status` STRING COMMENT 'Status of the regulatory authority submission for this protocol version or amendment (e.g., IND amendment to FDA, CTA variation to EMA/MHRA). Tracks compliance with regulatory notification and approval requirements.. Valid values are `not_required|pending|submitted|approved|rejected`',
    `secondary_objectives` STRING COMMENT 'Summary of secondary scientific objectives of the study as defined in the protocol. Describes additional questions the study is designed to address beyond the primary objective. Linked to secondary endpoints in the the source system.',
    `short_title` STRING COMMENT 'Abbreviated or lay-language title of the clinical study used in operational communications, CTMS displays, patient-facing materials, and internal reporting. Distinct from the full regulatory title.',
    `source_system_identifier` STRING COMMENT 'Native record identifier from the originating operational system (the source system study ID or Veeva Vault document ID). Enables bidirectional traceability between the lakehouse silver layer and the system of record for audit and reconciliation',
    `protocol_status` STRING COMMENT 'Current lifecycle state of the protocol version. draft indicates under development; approved indicates IRB/IEC and sponsor approval obtained; amended indicates a formal amendment is in effect; superseded indicates replaced by a newer version. Valid values are `draft|approved|amended|superseded|final|retired`',
    `study_phase` STRING COMMENT 'ICH-defined phase of clinical development for the investigational product. Determines regulatory requirements, sample size expectations, and study design complexity. Not Applicable used for non-IND studies such as device or observational studies.',
    `study_population_description` STRING COMMENT 'Narrative description of the target patient population for the study, including disease characteristics, demographic parameters, and key eligibility criteria summary. Used in IRB/IEC submissions, regulatory filings, and patient recruitment materials.',
    `study_type` STRING COMMENT 'Broad classification of the study design indicating whether participants receive an intervention or are observed. Determines applicable regulatory framework, IRB review requirements, and reporting obligations.. Valid values are `interventional|observational|expanded_access|compassionate_use`',
    `title` STRING COMMENT 'Full official title of the clinical study protocol as it appears on the protocol document and regulatory submissions. Used in IRB/IEC submissions, clinical trial registries, and the Clinical Study Report (CSR).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this protocol record in the source system or lakehouse. Supports change tracking, audit trail requirements, and incremental data pipeline processing.',
    `version_number` STRING COMMENT 'Version identifier of the protocol document (e.g., 1.0, 2.0, 3.1). Combined with protocol_number, uniquely identifies a specific iteration of the protocol. Incremented with each formal amendment. Sourced from Veeva Vault.',
    CONSTRAINT pk_protocol PRIMARY KEY(`protocol_id`)
) COMMENT 'Master record for the clinical study protocol including all formal amendments (version history). Captures protocol number, version, title, phase, therapeutic area, indication, investigational product, study design parameters (allocation method';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` (
    `study_protocol_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol amendment record in the lakehouse silver layer. Primary key for this entity.',
    `amendment_regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Protocol amendments are submitted as IND amendments or CTA variations filed in regulatory binders.',
    `amendment_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Each protocol amendment generates a TMF essential document (DIA TMF Zone 4). Amendment tracking and TMF completeness assessments require linking the amendment record to its filed TMF',
    `authored_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: 21 CFR Part 11 and ICH E6 R2 require electronic records to identify the author of protocol amendments by authenticated identity.',
    `clinical_one_amendment_id` BIGINT COMMENT 'The native amendment identifier from the source system study design system. Used for data lineage and reconciliation between the lakehouse silver layer and the operational source system.',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: GCP requires that when an amendment triggers ICF updates (icf_version_updated_flag, reconsent_required_flag), the specific new ICF version is traceable to the amendment.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Protocol amendments require formal sponsor approval from a specific sponsor contact.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Regulatory affairs teams must link each internal study amendment record to its corresponding regulatory submission record in the regulatory domain.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this protocol amendment belongs. Links the amendment to the study master record.',
    `affected_sections` STRING COMMENT 'Comma-delimited list or free-text enumeration of protocol section numbers and titles modified by this amendment (e.g., 5.1 Inclusion Criteria, 8.3 Visit Schedule, 10.2 Safety Monitoring). Enables targeted review by site staff.',
    `amendment_date` DATE COMMENT 'The date on which the amendment was formally authored or finalized by the sponsor. This is the document date, distinct from submission or approval dates.',
    `amendment_description` STRING COMMENT 'Detailed narrative describing all changes introduced by this amendment, including modified sections, added or removed procedures, and updated criteria. Serves as the primary change log for regulatory and audit purposes.',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the protocol amendment. Tracks progression from internal drafting through regulatory approval and implementation. Superseded indicates a later amendment has replaced this one.. Valid values are `draft|submitted|approved|rejected|withdrawn|superseded`',
    `amendment_title` STRING COMMENT 'Short descriptive title summarizing the primary purpose or scope of the amendment (e.g., Addition of New Safety Monitoring Criteria). Used in regulatory submissions and internal tracking.',
    `amendment_type` STRING COMMENT 'Classification of the amendment per regulatory definitions. Substantial amendments require prior health authority and ethics committee approval before implementation. Non-substantial amendments may be implemented with notification only.. Valid values are `substantial|non_substantial|administrative`',
    `approved_by` STRING COMMENT 'Name or identifier of the sponsor representative (e.g., Chief Medical Officer, Head of Regulatory Affairs) who provided final internal approval for the amendment.',
    `change_category` STRING COMMENT 'Primary category of change introduced by the amendment. Used for analytics, regulatory reporting, and impact triage. [ENUM-REF-CANDIDATE: eligibility_criteria|dosing_regimen|visit_schedule|safety_monitoring|endpoint|statistical|icf|administrative|other —',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this amendment record was first created in the lakehouse silver layer. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `dsmb_dmc_recommendation_flag` BOOLEAN COMMENT 'Indicates whether this amendment was triggered by a formal recommendation from the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC). Requires documentation of the DSMB/DMC meeting minutes.',
    `edc_configuration_updated_flag` BOOLEAN COMMENT 'Indicates whether the Electronic Data Capture (EDC) system (Medidata Rave) has been updated to reflect the protocol changes introduced by this amendment. Critical for data integrity and eCRF alignment.',
    `effective_date` DATE COMMENT 'The date from which the amended protocol becomes operative at clinical sites. Sites must implement protocol changes on or after this date. May differ from approval date if a transition period is granted.',
    `ema_submission_date` DATE COMMENT 'Date the amendment was submitted to the European Medicines Agency (EMA) or relevant national competent authority under EU CTR 536/2014. Null if no EU sites are involved.',
    `ema_submission_status` STRING COMMENT 'Current regulatory submission status with the European Medicines Agency (EMA) or relevant EU national competent authority for this amendment.. Valid values are `not_required|pending|submitted|validated|approved|rejected`',
    `fda_submission_date` DATE COMMENT 'Date the amendment was submitted to the U.S. Food and Drug Administration (FDA) as an IND amendment. Null if the study is not conducted under a U.S. IND.',
    `fda_submission_status` STRING COMMENT 'Current regulatory submission status with the U.S. Food and Drug Administration (FDA). On_clinical_hold indicates FDA has placed a hold pending resolution of safety concerns.. Valid values are `not_required|pending|submitted|acknowledged|approved|on_clinical_hold`',
    `icf_version_updated_flag` BOOLEAN COMMENT 'Indicates whether this amendment necessitates a new version of the Informed Consent Form (ICF). When true, a new ICF document version must be created and approved before re-consent activities begin.',
    `impact_assessment_summary` STRING COMMENT 'Structured narrative summarizing the assessed impact of the amendment on study operations, subject safety, data integrity, site procedures, and timelines. Produced during the amendment review process.',
    `implementation_deadline` DATE COMMENT 'The date by which all active clinical sites must have fully implemented the amendment. Used for monitoring follow-up and escalation planning in the source system',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the lead or central IRB/IEC granted approval for the amendment. For substantial amendments, implementation cannot proceed until this approval is received.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was formally notified of this amendment. Required for GCP compliance at all participating sites.',
    `irb_iec_status` STRING COMMENT 'Current review and approval status from the Institutional Review Board (IRB) or Independent Ethics Committee (IEC). Approved_with_conditions requires sponsor response before full approval.. Valid values are `not_required|pending|submitted|approved|approved_with_conditions|rejected`',
    `pmda_submission_date` DATE COMMENT 'Date the amendment was submitted to Japans Pharmaceuticals and Medical Devices Agency (PMDA). Null if no Japan sites are involved.',
    `pmda_submission_status` STRING COMMENT 'Current regulatory submission status with Japans Pharmaceuticals and Medical Devices Agency (PMDA) for this amendment.. Valid values are `not_required|pending|submitted|acknowledged|approved|rejected`',
    `previous_protocol_version` STRING COMMENT 'The protocol version number that was in effect immediately before this amendment was applied. Enables version chain traceability for audit and regulatory inspection purposes.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `rationale` STRING COMMENT 'Scientific, safety, or operational justification for the amendment. Required by health authorities to assess the necessity and appropriateness of protocol changes. Sourced from the source system and Veeva Vault.',
    `reconsent_required_flag` BOOLEAN COMMENT 'Indicates whether enrolled subjects must provide updated Informed Consent Form (ICF) signatures due to material changes introduced by this amendment. Drives re-consent workflow in Clinpal eConsent.',
    `safety_driven_flag` BOOLEAN COMMENT 'Indicates whether this amendment was initiated primarily due to a safety signal, Serious Adverse Event (SAE), SUSAR, or DSMB/DMC recommendation. Safety-driven amendments may require expedited regulatory review.',
    `sap_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment requires an update to the Statistical Analysis Plan (the source system). Changes to primary/secondary endpoints, analysis populations (ITT, PP), or statistical methods trigger the source system',
    `sponsor_approval_date` DATE COMMENT 'Date on which the sponsors internal governance (e.g., medical, regulatory, and legal sign-off) formally approved the amendment prior to external submission.',
    `subject_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment has a direct impact on currently enrolled subjects (e.g., changes to dosing, visit schedule, eligibility criteria, or safety monitoring). True triggers mandatory re-consent assessment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this amendment record in the lakehouse silver layer. Required for change data capture, audit trail, and regulatory inspection readiness.',
    `veeva_vault_document_code` STRING COMMENT 'The document identifier assigned by Veeva Vault eTMF to the amendment document. Enables direct cross-reference to the source document management system for audit trail and TMF completeness tracking.',
    CONSTRAINT pk_study_protocol_amendment PRIMARY KEY(`study_protocol_amendment_id`)
) COMMENT 'Tracks all formal amendments to an approved clinical study protocol. Records amendment number, amendment date, amendment type (substantial/non-substantial), description of changes, rationale, regulatory submission status per health authority (FDA, EMA';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study` (
    `study_id` BIGINT COMMENT 'Unique surrogate identifier for the clinical study record in the lakehouse Silver layer. Primary key for the study_study entity. Sourced from the source system',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: study_study carries indication as free text. The canonical indication product provides MedDRA-coded reference data required for regulatory submission grouping, competitive intelligence',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Each study has a designated sponsor primary contact (medical monitor, project lead).',
    `primary_study_cro_org_organization_id` BIGINT COMMENT 'Reference identifier for the Contract Research Organization (CRO) assigned to manage or support the clinical study on behalf of the sponsor. Nullable when the sponsor conducts the study internally. Sourced from the source system',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: study_study carries therapeutic_area as free text. The canonical therapeutic_area product is the authoritative reference for CTMS portfolio dashboards, regulatory strategy grouping',
    `acronym` STRING COMMENT 'The short alphanumeric acronym or abbreviated name assigned to the clinical study for operational use across CTMS, EDC, and internal communications (e.g., APEX-HF, BRIGHT-2).',
    `actual_end_date` DATE COMMENT 'The actual date on which the last patient completed the last study visit (Last Patient Last Visit - LPLV). Recorded upon confirmation in the source system Triggers database lock preparation, CSR authoring, and TMF archival workflows.',
    `actual_enrollment` BIGINT COMMENT 'The actual cumulative number of subjects enrolled (consented and randomized or assigned to treatment) across all study sites at the current point in time. Updated from Medidata Rave EDC enrollment data.',
    `actual_start_date` DATE COMMENT 'The actual date on which the first patient was enrolled or the first study procedure was performed (First Patient First Visit - FPFV). Recorded upon confirmation in the source system',
    `amendment_number` BIGINT COMMENT 'The sequential count of protocol amendments issued since the original protocol approval. A value of 0 indicates the original protocol with no amendments. Increments with each approved protocol amendment.',
    `blinding_type` STRING COMMENT 'The blinding (masking) classification applied to the clinical study indicating which parties are unaware of treatment assignment. Drives operational procedures for unblinding, DSMB/DMC oversight, and safety reporting.. Valid values are `Open Label|Single Blind|Double Blind|Triple Blind`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when the study record was first created in the source system (the source system Supports audit trail requirements, data lineage tracking, and compliance with 21 CFR Part 11 electronic records requirements.',
    `csr_submission_date` DATE COMMENT 'The date on which the Clinical Study Report (CSR) was submitted to the regulatory authority or sponsor. The CSR is the comprehensive document summarizing study methods, results, and conclusions per ICH E3 guidelines.',
    `ctms_study_code` STRING COMMENT 'The native study identifier assigned by the source system the system of record for this entity. Enables direct traceability back to the source system record for audit, reconciliation, and data lineage purposes per ALCOA+ principles.',
    `data_cutoff_date` DATE COMMENT 'The date used as the data cutoff for interim or final analyses, defining the observation window for subject data included in the analysis dataset. Specified in the Statistical Analysis Plan (the source system) and used to generate SDTM/ADaM datasets in',
    `dbl_date` DATE COMMENT 'The date on which the clinical database was formally locked following completion of all data cleaning, query resolution, and medical coding activities. Database Lock (DBL) is a critical regulatory milestone that freezes the dataset for statistical',
    `design_type` STRING COMMENT 'The methodological design classification of the clinical study (e.g., Parallel Group, Crossover, Single Arm, Factorial, Adaptive). Informs statistical analysis plan design, randomization schema, and protocol complexity.',
    `development_phase` STRING COMMENT 'The regulatory development phase of the clinical study per ICH and FDA/EMA classification (Phase I through Phase IV). Drives regulatory requirements, statistical analysis plan complexity, safety reporting obligations, and resource planning.. Valid values are `Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV`',
    `dummy_touch` STRING COMMENT 'Dummy touch attribute for the study product.',
    `edc_study_code` STRING COMMENT 'The study identifier assigned within the Electronic Data Capture (EDC) system (Medidata Rave) used for clinical data collection. Enables cross-system traceability between the CTMS master record and the EDC operational system.',
    `eudract_number` STRING COMMENT 'The European Union Drug Regulating Authorities Clinical Trials (EudraCT) registration number assigned by the EMA for clinical trials conducted in the EU/EEA (e.g., 2023-001234-56).. Valid values are `^[0-9]{4}-[0-9]{6}-[0-9]{2}$`',
    `first_site_initiation_date` DATE COMMENT 'The date on which the first investigational site was formally initiated (Site Initiation Visit completed) and authorized to enroll subjects. A key operational milestone tracked in the source system for timeline KPI reporting.',
    `irb_iec_approval_date` DATE COMMENT 'The date of initial approval granted by the lead Institutional Review Board (IRB) or Independent Ethics Committee (IEC) for the study protocol. This is a prerequisite for study initiation and subject enrollment.',
    `is_randomized` BOOLEAN COMMENT 'Indicates whether the clinical study employs randomization to assign participants to treatment arms (True) or uses a non-randomized assignment method (False). Determines RTSM/IRT configuration requirements in Medidata Rave and the source system',
    `nct_number` STRING COMMENT 'The ClinicalTrials.gov registry identifier assigned by the U.S. National Library of Medicine upon study registration (e.g., NCT12345678). Mandatory for studies subject to FDAAA 801 and ICMJE registration requirements.. Valid values are `^NCT[0-9]{8}$`',
    `number_of_arms` BIGINT COMMENT 'The total number of treatment arms or groups defined in the study protocol (e.g., 2 for a two-arm parallel study, 1 for a single-arm study). Drives RTSM/IRT configuration in Medidata Rave and the source system randomization setup.',
    `planned_country_count` BIGINT COMMENT 'The planned number of countries in which the clinical study will be conducted. Drives regulatory strategy (multi-national submissions), country-level feasibility, and operational complexity assessment.',
    `planned_end_date` DATE COMMENT 'The originally planned date for last patient last visit (LPLV) or study completion as defined in the protocol and project plan. Used for resource planning, site contract management, and regulatory timeline commitments.',
    `planned_site_count` BIGINT COMMENT 'The planned number of investigational sites to be activated for the clinical study as defined in the feasibility assessment and study protocol. Used for site selection planning, budget forecasting, and resource allocation in the source system',
    `planned_start_date` DATE COMMENT 'The originally planned date for first patient first visit (FPFV) or study initiation as defined in the study protocol and project plan. Used for timeline tracking, milestone management, and KPI reporting in the source system',
    `primary_regulatory_region` STRING COMMENT 'The primary regulatory jurisdiction governing the clinical study, determining the lead regulatory authority (e.g., US for FDA, EU for EMA, JP for PMDA). Drives applicable GCP guidelines, submission requirements, and safety reporting timelines.. Valid values are `US|EU|JP|AU|CA|GLOBAL`',
    `sponsor_study_number` STRING COMMENT 'The sponsor-assigned unique alphanumeric identifier for the clinical study (e.g., ABC-1234-001). This is the primary business identifier used across all sponsor systems, regulatory submissions, and inter-organizational communications.',
    `study_status` STRING COMMENT 'The current operational lifecycle status of the clinical study. Drives workflow gating, resource allocation, regulatory reporting obligations, and system access controls across CTMS, EDC, and eTMF.. Valid values are `Planned|Startup|Active|On Hold|Completed|Terminated`',
    `target_enrollment` BIGINT COMMENT 'The planned total number of subjects to be enrolled across all study sites as specified in the approved protocol and statistical analysis plan (the source system). Drives site allocation, recruitment planning, and power calculations.',
    `termination_reason` STRING COMMENT 'The documented reason for early termination of the clinical study when study_status is Terminated. Captures the primary rationale (e.g., Safety Concerns, Lack of Efficacy, Business Decision, Regulatory Hold, Enrollment Failure).',
    `title` STRING COMMENT 'The complete official title of the clinical study as stated in the approved protocol document. Used in regulatory submissions, IRB/IEC applications, informed consent forms, and the Trial Master File.',
    `tmf_archival_date` DATE COMMENT 'The date on which the Trial Master File (TMF) was formally archived following study close-out. The TMF must be retained for a minimum of 15 years (or longer per regional requirements) after study completion. Tracked in Veeva Vault eTMF.',
    `study_type` STRING COMMENT 'The fundamental classification of the clinical study design indicating whether participants receive an investigational intervention (Interventional), are observed without intervention (Observational), or receive investigational product outside a trial. Valid values are `Interventional|Observational|Expanded Access`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when the study record was most recently modified in the source system (the source system Supports incremental data loading, change detection, and audit trail requirements per 21 CFR Part 11.',
    CONSTRAINT pk_study PRIMARY KEY(`study_id`)
) COMMENT 'Top-level master entity representing a clinical trial as a business and operational unit. Captures the unique study identifier (sponsor study number, ClinicalTrials.gov NCT number, EudraCT number), study title, acronym, therapeutic area, indication';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`arm` (
    `arm_id` BIGINT COMMENT 'Unique surrogate identifier for each study arm record in the lakehouse Silver layer. Primary key for the study_arm data product.',
    `investigational_product_id` BIGINT COMMENT 'FK to study.investigational_product',
    `primary_planned_arm_codelist_id` BIGINT COMMENT 'Foreign key to the ARMTYP codelist for the planned arm type (e.g., Experimental, Active Comparator, Placebo Comparator, Sham Comparator)',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, arms belong to study_design',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this arm belongs. Links the arm to its governing study protocol.',
    `type_codelist_term_id` BIGINT COMMENT 'BIGINT',
    `adaptive_design_flag` BOOLEAN COMMENT 'Indicates whether this arm is part of an adaptive trial design where arm allocation, sample size, or continuation may be modified based on interim analysis results per a pre-specified adaptation rule.',
    `allocation_ratio` DECIMAL(10,4) COMMENT 'The ratio used to allocate subjects to this arm relative to other arms in the study design.',
    `blinding_type` STRING COMMENT 'Specifies the level of blinding applied to this arm: Open Label (no blinding), Single Blind (subject blinded), Double Blind (subject and investigator blinded), or Triple Blind (subject, investigator, and sponsor blinded).. Valid values are `Open Label|Single Blind|Double Blind|Triple Blind`',
    `clinical_one_arm_code` STRING COMMENT 'The native arm identifier assigned by the source system (the source system of record for study design and patient randomization). Used for system-of-record traceability and data lineage from source to lakehouse.',
    `arm_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the arm within the study. Maps directly to the ARMCD variable in the CDISC SDTM ARM domain and is used in randomization and data tabulation.. Valid values are `^[A-Z0-9_]{1,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this study arm record was first created in the system, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_arm_reference` STRING COMMENT 'The arm reference identifier as recorded in the source system for site monitoring, visit tracking, and enrollment management. Supports cross-system reconciliation.',
    `discontinuation_reason` STRING COMMENT 'Reason for early discontinuation of the study arm, if applicable (e.g., safety signal, futility, sponsor decision, regulatory hold). Required for regulatory reporting when an arm is terminated prior to planned completion.',
    `dose_description` STRING COMMENT 'Textual description of the dose level and regimen for the investigational product in this arm (e.g., 10 mg once daily, 200 mg BID). Supports dose-response analysis and protocol compliance monitoring.',
    `dosing_frequency` STRING COMMENT 'Frequency of investigational product administration for subjects in this arm (e.g., QD - once daily, BID - twice daily, QW - once weekly). Aligns with CDISC SDTM EX domain EXDOSFRQ variable.',
    `end_date` DATE COMMENT 'The date on which the study arm was closed to enrollment or treatment, either per protocol schedule or due to early termination. Null if the arm is still active.',
    `interim_analysis_flag` BOOLEAN COMMENT 'Indicates whether this arm is subject to one or more pre-specified interim analyses by the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) during the study.',
    `intervention_description` STRING COMMENT 'Detailed narrative description of the intervention assigned to subjects in this arm, including drug name, dose, route of administration, and dosing schedule as specified in the study protocol.',
    `intervention_type` STRING COMMENT 'Category of the therapeutic intervention assigned to subjects in this arm. Aligns with ClinicalTrials.gov intervention type classifications and supports regulatory submission categorization.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether the treatment assignment for this arm is blinded to subjects, investigators, or both (double-blind). Supports blinding integrity tracking and unblinding event management.',
    `is_control_arm` BOOLEAN COMMENT 'Indicates whether this arm serves as the control arm (comparator) in the study design. True for placebo, active comparator, or sham comparator arms used as the reference group in statistical analyses.',
    `itt_population_flag` BOOLEAN COMMENT 'Indicates whether subjects enrolled in this arm are included in the Intent-to-Treat (ITT) analysis population as defined in the Statistical Analysis Plan (the source system).',
    `max_subjects_count` BIGINT COMMENT 'The maximum allowable number of subjects that may be enrolled in this arm, including any over-enrollment buffer defined in the protocol. Distinct from planned_subjects_count which reflects the statistical target.',
    `min_subjects_count` BIGINT COMMENT 'The minimum number of subjects required in this arm to maintain statistical validity of the study, as defined in the the source system. Used for futility analysis and early stopping rule evaluation.',
    `arm_name` STRING COMMENT 'Full descriptive name of the study arm as defined in the protocol (e.g., Drug A 10mg QD, Placebo). Maps to the ARM variable in the CDISC SDTM ARM domain.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, clarifications, or protocol-specific instructions related to this arm that are not captured in structured fields. For internal use by study team.',
    `planned_subjects_count` BIGINT COMMENT 'The planned (target) number of subjects to be enrolled and randomized into this arm as specified in the study protocol and statistical analysis plan (the source system).',
    `pp_population_flag` BOOLEAN COMMENT 'Indicates whether subjects enrolled in this arm are included in the Per Protocol (PP) analysis population as defined in the Statistical Analysis Plan (the source system). Subjects with major protocol deviations may be excluded.',
    `protocol_version_ref` STRING COMMENT 'The version identifier of the study protocol or protocol amendment under which this arm was defined or last modified. Ensures traceability of arm design to the governing protocol document.',
    `randomization_ratio` DECIMAL(18,2) COMMENT 'The allocation ratio for randomization of subjects into this arm relative to other arms (e.g., 1:1, 2:1:1). Used by the RTSM/IRT system (Medidata Rave RTSM) to control subject assignment.',
    `randomization_ratio_numeric` DECIMAL(5,2) COMMENT 'Numeric representation of the allocation weight for this arm relative to total allocation (e.g., 0.50 for a 1:1 ratio arm). Supports quantitative analysis and reporting of enrollment balance.',
    `safety_population_flag` BOOLEAN COMMENT 'Indicates whether subjects enrolled in this arm are included in the safety analysis population (all subjects who received at least one dose of study treatment), as defined in the the source system.',
    `sdtm_arm_domain` STRING COMMENT 'CDISC SDTM domain identifier confirming this arm maps to the ARM domain in the SDTM submission dataset. Always ARM per CDISC standard; included for regulatory submission traceability.. Valid values are `^ARM$`',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number defining the display and processing order of arms within the study. Used for consistent ordering in reports, eCRFs, and SDTM datasets.',
    `start_date` DATE COMMENT 'The date on which the study arm became active and eligible for subject enrollment, as defined in the approved protocol or protocol amendment. Supports enrollment timeline tracking.',
    `arm_status` STRING COMMENT 'Current lifecycle status of the study arm, reflecting whether the arm is planned, actively enrolling, suspended, closed to enrollment, or discontinued per protocol amendment.. Valid values are `Planned|Active|Suspended|Closed|Discontinued`',
    `treatment_duration_days` BIGINT COMMENT 'Planned duration of treatment for subjects in this arm, expressed in days. Used for supply planning, visit schedule design, and protocol compliance monitoring.',
    `arm_type` STRING COMMENT 'The arm type of the arm.',
    `updated_by` STRING COMMENT 'The username or system identifier of the user or process that last modified this study arm record. Required for audit trail compliance under FDA 21 CFR Part 11 and ALCOA+ (Attributable) principle.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this study arm record was last modified, in ISO 8601 format with timezone offset. Supports audit trail requirements and change tracking under 21 CFR Part 11.',
    `created_by` STRING COMMENT 'The username or system identifier of the user or process that created this study arm record. Required for audit trail compliance under FDA 21 CFR Part 11 and ALCOA+ (Attributable) principle.',
    CONSTRAINT pk_arm PRIMARY KEY(`arm_id`)
) COMMENT 'Defines each treatment arm or cohort within a clinical study. Records arm name, arm code, arm type (experimental, active comparator, placebo comparator, sham comparator, no intervention, other), description of intervention, planned number of subjects per';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`endpoint` (
    `endpoint_id` BIGINT COMMENT 'Unique surrogate identifier for a study endpoint record in the lakehouse silver layer. Primary key for the study_endpoint data product.',
    `ctcae_grade_id` BIGINT COMMENT 'Foreign key linking to terminology.ctcae_grade. Business justification: Safety endpoints reference specific CTCAE grade thresholds (study_endpoint has ctcae_version and ctcae_grade as plain attributes).',
    `meddra_term_id` BIGINT COMMENT 'Foreign key linking to terminology.meddra_term. Business justification: study_endpoint has meddra_soc_code as a plain attribute — safety endpoints are defined using MedDRA terminology.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, endpoints belong to study_design',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this endpoint belongs. Links the endpoint to its governing protocol.',
    `adam_parameter_code` STRING COMMENT 'The CDISC ADaM PARAMCD value (≤8 characters, uppercase) that uniquely identifies the analysis parameter corresponding to this endpoint within the ADaM dataset. Required for CDISC-compliant regulatory submissions to FDA and EMA.. Valid values are `^[A-Z0-9_]{1,8}$`',
    `adam_parameter_name` STRING COMMENT 'The CDISC ADaM PARAM value — the full descriptive label for the analysis parameter corresponding to this endpoint (e.g., Overall Survival Time (Days)). Displayed in analysis output tables and listings.',
    `alpha_level` DECIMAL(10,6) COMMENT 'The pre-specified Type I error rate (significance level) for this endpoint (e.g., 0.05 for two-sided, 0.025 for one-sided). Defined in the the source system in the protocol.',
    `analysis_population` STRING COMMENT 'The analysis population to which this endpoint applies: Intent-to-Treat (ITT), modified ITT (mITT), Per Protocol (PP), safety, Pharmacokinetic (PK), or biomarker population. Defined in the the source system in the Clinical Study Report (CSR).. Valid values are `ITT|mITT|PP|safety|PK|biomarker`',
    `assessment_timepoint` STRING COMMENT 'The protocol-defined timepoint or window at which the endpoint is assessed (e.g., Week 24, End of Treatment, Month 6 ± 7 days). Directly maps to the visit schedule and SDTM VISITNUM.',
    `endpoint_category` STRING COMMENT 'Scientific domain category of the endpoint: efficacy (treatment effect), safety (harm characterisation), tolerability, Pharmacokinetics/Pharmacodynamics (PK/PD), quality of life (patient-reported outcomes), or biomarker.. Valid values are `efficacy|safety|tolerability|PK_PD|quality_of_life|biomarker`',
    `endpoint_code` STRING COMMENT 'Sponsor-assigned alphanumeric code uniquely identifying this endpoint within the study (e.g., EP-PRI01, EP-SEC03). Used as the externally-known business identifier in the source system regulatory submissions.. Valid values are `^EP-[A-Z0-9]{2,10}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this endpoint record was first created in the system, in ISO 8601 format with timezone offset. Supports ALCOA+ audit trail requirements.',
    `ctcae_version` STRING COMMENT 'The version of the NCI Common Terminology Criteria for Adverse Events (CTCAE) used to grade safety endpoints (e.g., 5.0, 4.03). Applicable for oncology and safety-focused endpoints.',
    `endpoint_description` STRING COMMENT 'Full narrative description of the endpoint as defined in the study protocol, including the precise measurement, population, and timeframe. Directly referenced in regulatory submissions.',
    `directionality` STRING COMMENT 'Specifies whether the statistical test for this endpoint is one-sided or two-sided. Determines the alpha allocation and critical value used in hypothesis testing.. Valid values are `one_sided|two_sided`',
    `effective_from_date` DATE COMMENT 'The date from which this endpoint definition became effective, typically aligned with the protocol version approval date. Supports temporal versioning across protocol amendments.',
    `effective_until_date` DATE COMMENT 'The date on which this endpoint definition was superseded or retired, typically aligned with a subsequent protocol amendment. Null for currently active endpoints. Supports temporal versioning.',
    `estimand_intercurrent_event_strategy` STRING COMMENT 'The strategy for handling intercurrent events per ICH E9(R1): treatment_policy (ignore occurrence), hypothetical (counterfactual), composite (incorporate into outcome), while_on_treatment (restrict to on-treatment period), or principal_stratum (condition. Valid values are `treatment_policy|hypothetical|composite|while_on_treatment|principal_stratum`',
    `estimand_population` STRING COMMENT 'The target population component of the ICH E9(R1) estimand, specifying the patient population to which the treatment effect applies (e.g., all randomised patients with baseline HbA1c ≥ 7.5%).',
    `estimand_population_level_summary` STRING COMMENT 'The population-level summary measure component of the ICH E9(R1) estimand (e.g., difference in means, hazard ratio, odds ratio). Specifies how individual outcomes are aggregated to a treatment effect estimate.',
    `estimand_treatment_condition` STRING COMMENT 'The treatment condition component of the ICH E9(R1) estimand framework, describing the treatment regimen of interest (e.g., randomised treatment regardless of adherence, treatment as prescribed).',
    `estimand_variable` STRING COMMENT 'The variable component of the ICH E9(R1) estimand, defining the outcome measure for each patient (e.g., change from baseline in HbA1c at Week 24). Directly corresponds to the ADaM analysis variable.',
    `measurement_instrument` STRING COMMENT 'The validated instrument, scale, or tool used to measure the endpoint (e.g., RECIST 1.1, HAMD-17, SF-36, CTCAE v5.0, EORTC QLQ-C30). Required for regulatory submission and biostatistical analysis planning.',
    `meddra_soc_code` STRING COMMENT 'The MedDRA System Organ Class (SOC) code associated with this endpoint when the endpoint relates to an adverse event or safety outcome. Enables standardised safety reporting per ICH M1.',
    `missing_data_strategy` STRING COMMENT 'The pre-specified strategy for handling missing data for this endpoint per the the source system: Last Observation Carried Forward (LOCF), Baseline Observation Carried Forward (BOCF), Multiple Imputation (MI), Mixed Model for Repeated Measures (MMRM)',
    `multiplicity_adjustment_flag` BOOLEAN COMMENT 'Indicates whether a multiplicity adjustment (e.g., Bonferroni, Holm, Hochberg, gatekeeping procedure) is applied to this endpoint to control the family-wise error rate. Critical for confirmatory trial design and regulatory acceptance.',
    `multiplicity_procedure` STRING COMMENT 'The specific statistical procedure used for multiplicity adjustment for this endpoint (e.g., Hochberg step-up, Bonferroni, Fixed-sequence testing, Graphical gatekeeping). Populated only when multiplicity_adjustment_flag is True.',
    `endpoint_name` STRING COMMENT 'Short, human-readable name of the endpoint as it appears in the protocol and Statistical Analysis Plan (the source system) (e.g., Overall Survival, Change from Baseline in HbA1c at Week 24).',
    `non_inferiority_margin` DECIMAL(18,6) COMMENT 'The pre-specified non-inferiority or equivalence margin (delta) for the endpoint, expressed in the unit of the primary outcome measure. Applicable only when statistical_hypothesis is non_inferiority or equivalence. Regulatory-critical value.',
    `objective_type` STRING COMMENT 'Classification of the study objective associated with this endpoint: primary (confirmatory), secondary (supportive), exploratory (hypothesis-generating), or safety (adverse event characterisation).. Valid values are `primary|secondary|exploratory|safety`',
    `protocol_section_reference` STRING COMMENT 'The section number or heading in the study protocol document where this endpoint is formally defined (e.g., Section 3.2.1 Primary Endpoint). Enables direct cross-reference to the Trial Master File (TMF).',
    `sap_section_reference` STRING COMMENT 'The section number or heading in the Statistical Analysis Plan (the source system) where the analysis method for this endpoint is specified. Provides the scientific rationale chain from objective through endpoint to the source system.',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain from which the source data for this endpoint is collected (e.g., AE, LB, EX, RS, TU, TR). Establishes the SDTM-to-ADaM data lineage chain required for regulatory submission.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this endpoint within its objective type group (e.g., 1st primary, 2nd secondary). Used for hierarchical ordering in the the source system submission tables.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this endpoint definition originates: Medidata Rave (EDC), the source system (study design), SAS Drug Development (biostatistical analysis), or manual entry. Supports data lineage and audit.. Valid values are `Medidata_Rave|Oracle_Clinical_One|SAS_Drug_Development|manual`',
    `source_system_endpoint_code` STRING COMMENT 'The native identifier of this endpoint record in the originating operational system (e.g., the source system endpoint object ID, SAS Drug Development analysis parameter ID). Enables cross-system reconciliation and ETL lineage.',
    `statistical_hypothesis` STRING COMMENT 'The formal statistical hypothesis framework applied to this endpoint: superiority (treatment better than control), non-inferiority (treatment not worse by a defined margin), equivalence (treatment within a symmetric margin), or descriptive (no formal. Valid values are `superiority|non_inferiority|equivalence|descriptive`',
    `endpoint_status` STRING COMMENT 'Current lifecycle state of the endpoint definition: draft (under authoring), active (protocol-approved), amended (modified via protocol amendment), retired (removed from protocol), locked (post-Database Lock). Drives the source system. Valid values are `draft|active|amended|retired|locked`',
    `endpoint_type` STRING COMMENT 'Classification of the endpoint role within the study hierarchy: primary (confirmatory, drives sample size), secondary (supportive), exploratory, safety, Pharmacokinetic (PK), Pharmacodynamic (PD), or biomarker.',
    `unit_of_measure` STRING COMMENT 'The unit in which the endpoint outcome is expressed (e.g., months, mg/dL, mmHg, score, %, events/patient-year). Required for ADaM AVALU mapping and regulatory submission.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this endpoint record was most recently modified, in ISO 8601 format with timezone offset. Supports ALCOA+ audit trail and change control requirements.',
    CONSTRAINT pk_endpoint PRIMARY KEY(`endpoint_id`)
) COMMENT 'Defines the formal objectives and their associated endpoints (primary, secondary, exploratory) for a clinical study. Captures objective text, objective type, endpoint name, endpoint type (primary, secondary, exploratory, safety, PK, PD, biomarker)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` (
    `eligibility_criterion_id` BIGINT COMMENT 'Unique surrogate identifier for each eligibility criterion record in the clinical study. Primary key for the eligibility_criterion data product.',
    `meddra_term_id` BIGINT COMMENT 'Foreign key linking to terminology.meddra_term. Business justification: eligibility_criterion has meddra_pt_code and meddra_pt_name as plain attributes — inclusion/exclusion criteria referencing medical conditions are MedDRA-coded for SDTM IE domain',
    `previous_criterion_eligibility_criterion_id` BIGINT COMMENT 'Reference to the prior version of this criterion that was superseded by the current record. Enables full version history chain for audit trail and regulatory traceability of criterion evolution across protocol amendments.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version under which this criterion was introduced or last modified. Supports amendment-driven criterion tracking.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, eligibility criteria belong to study_design',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this eligibility criterion is defined. Links the criterion to its parent study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: eligibility_criterion has amendment_number as a STRING and is_amendment_driven BOOLEAN flag but no FK to study_protocol_amendment.',
    `applicable_population` STRING COMMENT 'Specifies the sub-population to which this criterion applies when it is not universally applicable to all subjects (e.g., reproductive status criteria apply to FEMALE_ONLY, pediatric dosing criteria apply to PEDIATRIC).. Valid values are `ALL|FEMALE_ONLY|MALE_ONLY|PEDIATRIC|ADULT|ELDERLY`',
    `change_rationale` STRING COMMENT 'The documented scientific or operational rationale for introducing or modifying this criterion, particularly when driven by a protocol amendment. Required for regulatory submissions and IRB/IEC amendment packages.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this eligibility criterion record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `crf_page_reference` STRING COMMENT 'The page or section reference in the electronic Case Report Form (eCRF) where this eligibility criterion is assessed and documented. Used for site training, monitoring, and Source Data Verification (SDV) activities.',
    `criterion_category` STRING COMMENT 'Clinical or operational category classifying the nature of the criterion. Supports structured analysis and site training. [ENUM-REF-CANDIDATE',
    `criterion_number` BIGINT COMMENT 'Sequential number assigned to the criterion within its type (inclusion or exclusion) as it appears in the study protocol. Used for ordering and referencing in site screening checklists and EDC eligibility modules.',
    `criterion_short_name` STRING COMMENT 'Abbreviated or condensed label for the criterion used in EDC display, site training materials, and operational screening tools where full text is impractical. Maps to CDISC SDTM IE domain variable IETESTCD.',
    `criterion_status` STRING COMMENT 'Current lifecycle status of the eligibility criterion. DRAFT indicates under review; ACTIVE indicates approved and in use; SUPERSEDED indicates replaced by an amended version; RETIRED indicates removed from the protocol.. Valid values are `DRAFT|ACTIVE|SUPERSEDED|RETIRED`',
    `criterion_text` STRING COMMENT 'Full verbatim text of the eligibility criterion as written in the approved study protocol. This is the authoritative, protocol-exact wording used in site screening checklists, EDC eligibility modules, and regulatory submissions.',
    `criterion_type` STRING COMMENT 'Indicates whether the criterion is an inclusion criterion (subject must meet) or an exclusion criterion (subject must not meet) for enrollment eligibility. Maps to CDISC SDTM IE domain variable IECAT.. Valid values are `INCLUSION|EXCLUSION`',
    `display_order` BIGINT COMMENT 'The display sequence order for this criterion within its type group (inclusion or exclusion) as it should appear in site screening checklists, EDC eligibility modules, and protocol documents.',
    `edc_field_oid` STRING COMMENT 'The Object Identifier (OID) of the corresponding field in the Electronic Data Capture (EDC) system (e.g., Medidata Rave) eligibility module. Enables direct mapping between the protocol criterion and the EDC data collection form for data lineage and',
    `effective_date` DATE COMMENT 'The date from which this criterion version became operationally effective for subject screening. Aligns with the IRB/IEC approval date of the applicable protocol version.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether a change to this criterion requires formal IRB/IEC approval before implementation at sites. Typically True for all criteria changes driven by protocol amendments.',
    `is_amendment_driven` BOOLEAN COMMENT 'Indicates whether this criterion was introduced or modified as a result of a protocol amendment. True when the criterion originated from or was changed by a formal protocol amendment. Critical for regulatory audit trails and amendment impact analysis.',
    `is_critical_criterion` BOOLEAN COMMENT 'Indicates whether this criterion is designated as critical, meaning a violation would constitute a major protocol deviation requiring immediate reporting to the sponsor and potentially the IRB/IEC.',
    `lab_test_code` STRING COMMENT 'The standardized laboratory test code (e.g., LOINC code or sponsor-defined code) for the lab parameter referenced in this criterion. Applicable for lab value criteria such as eGFR, hemoglobin, or platelet count thresholds.',
    `meddra_pt_code` STRING COMMENT 'The MedDRA Preferred Term (PT) code associated with the diagnosis, condition, or medical history referenced in this criterion. Enables standardized medical coding for regulatory submissions and cross-study analysis.. Valid values are `^[0-9]{8}$`',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when this eligibility criterion record was last modified. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `numeric_threshold_comparator` STRING COMMENT 'The logical comparator defining the relationship between the subjects measured value and the numeric threshold (EQ=equal, NE=not equal, LT=less than, LE=less than or equal, GT=greater than, GE=greater than or equal).. Valid values are `EQ|NE|LT|LE|GT|GE`',
    `numeric_threshold_unit` STRING COMMENT 'The unit of measure for the numeric threshold value (e.g., years, mL/min/1.73m², kg/m², mg/dL). Follows CDISC controlled terminology for units.',
    `numeric_threshold_value` DECIMAL(18,6) COMMENT 'The quantitative threshold value associated with the criterion where applicable (e.g., age ≥ 18, eGFR ≥ 60, BMI ≤ 35). Used for lab value, vital sign, and demographic criteria that have a numeric boundary.',
    `protocol_version_first_applicable` STRING COMMENT 'The protocol version number (e.g., v1.0, v2.1) in which this criterion first became applicable. Used to determine which subjects enrolled under which protocol version were subject to this criterion.',
    `protocol_version_last_applicable` STRING COMMENT 'The protocol version number in which this criterion was last applicable before being superseded or retired. Null if the criterion is still active in the current protocol version.',
    `requires_source_doc_verification` BOOLEAN COMMENT 'Indicates whether Source Data Verification (SDV) is required for this criterion during monitoring visits. When True, the Clinical Research Associate (CRA) must verify the criterion assessment against source documents at the site.',
    `retirement_date` DATE COMMENT 'The date on which this criterion was retired or superseded. Null if the criterion remains active. Used to determine the applicable criterion set for subjects screened on a given date.',
    `screening_guidance_notes` STRING COMMENT 'Operational guidance notes for site staff on how to assess and document this criterion during subject screening. May include clarifications, assessment methods, source document requirements, and common pitfalls.',
    `sdtm_ie_testcd` STRING COMMENT 'CDISC SDTM-compliant short code for the criterion, conforming to the IE domain IETESTCD variable. Maximum 8 uppercase alphanumeric characters. Used for regulatory submission datasets and CDISC compliance validation.. Valid values are `^[A-Z0-9]{1,8}$`',
    `source_document_type` STRING COMMENT 'The type of source document required to verify this criterion (e.g., medical records, laboratory report, imaging report, physician attestation, birth certificate). Used to guide site staff and CRAs during screening and monitoring.',
    `source_system_criterion_code` STRING COMMENT 'The native identifier of this criterion record in the originating operational system (e.g., the source system criterion object ID, Medidata Rave field OID). Enables reconciliation between the lakehouse Silver Layer and the source system.',
    `time_window_unit` STRING COMMENT 'The unit of time for the time window associated with the criterion (e.g., DAYS, WEEKS, MONTHS, YEARS). Used for washout periods, prior therapy windows, and diagnosis recency requirements.. Valid values are `DAYS|WEEKS|MONTHS|YEARS`',
    `time_window_value` DECIMAL(10,2) COMMENT 'The numeric duration of the time window associated with the criterion (e.g., prior therapy washout period of 4 weeks, prior diagnosis within 6 months). Used in conjunction with time_window_unit.',
    `waiver_allowed` BOOLEAN COMMENT 'Indicates whether a protocol deviation waiver or exception can be granted for this criterion on a per-subject basis. When True, a formal waiver request process is required and must be documented in the Trial Master File (TMF).',
    `waiver_authority` STRING COMMENT 'The body or role authorized to grant a waiver for this criterion (e.g., Medical Monitor, Sponsor Medical Director, IRB/IEC). Applicable only when waiver_allowed is True.',
    `who_dd_drug_code` STRING COMMENT 'The WHO Drug Dictionary (WHO-DD) code for the medication referenced in this criterion, applicable for prior therapy or concomitant medication criteria. Enables standardized drug coding for regulatory submissions.',
    CONSTRAINT pk_eligibility_criterion PRIMARY KEY(`eligibility_criterion_id`)
) COMMENT 'Defines inclusion and exclusion criteria for subject enrollment in a clinical study. Records criterion number, criterion type (inclusion/exclusion), criterion text, criterion category (demographic, diagnosis, lab value, prior therapy, concomitant';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` (
    `study_visit_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for each study visit schedule record in the lakehouse. Primary key for the study_visit_schedule data product.',
    `codelist_id` BIGINT COMMENT 'Classification of the visit by its functional role in the study timeline. Drives site operational planning, subject visit tracking in CTMS, and CDISC SDTM epoch mapping.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: study_visit_schedule has epoch_name as a STRING but no FK to study_epoch. Visits in the Schedule of Events belong to specific study epochs (Screening, Treatment, Follow-up) — this FK',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version or amendment under which this visit schedule was defined. Enables tracking of schedule changes across protocol amendments.',
    `schedule_timeline_id` BIGINT COMMENT 'add column schedule_timeline_id (BIGINT) with FK to study.schedule_timeline.schedule_timeline_id — per USDM, visits are on schedule_timeline',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this visit schedule is defined. Links the Schedule of Events (SoE) to its governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: study_visit_schedule has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `visit_type_codelist_term_id` BIGINT COMMENT 'BIGINT',
    `cdisc_visit_reference` STRING COMMENT 'Standardized CDISC controlled terminology code or reference for the visit type, used to align the visit schedule with CDISC SDTM submission datasets and regulatory data packages (e.g., CDISC CT VISIT term).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit schedule record was first created in the lakehouse, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `effective_end_date` DATE COMMENT 'Date on which this version of the visit schedule was superseded or retired, typically when a protocol amendment introduced a new schedule version. Null for the currently active schedule version.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the visit schedule became effective for the study, typically aligned with protocol approval or amendment effective date. Supports temporal versioning of the Schedule of Events.',
    `fasting_duration_hours` BIGINT COMMENT 'Minimum number of hours the subject must fast prior to the visit, when fasting_required is True. Specified in the protocol and communicated to sites and subjects.',
    `fasting_required` BOOLEAN COMMENT 'Indicates whether the subject must be fasting prior to this visit (e.g., for fasting lipid panels, glucose measurements, or PK sampling). Communicated to subjects via informed consent and visit reminder materials.',
    `is_dosing_visit` BOOLEAN COMMENT 'Indicates whether investigational product (IP) administration or dosing occurs at this visit. Used by RTSM/IRT systems for drug supply planning, IP accountability tracking, and site operational scheduling.',
    `is_in_itt_population` BOOLEAN COMMENT 'Indicates whether data collected at this visit contributes to the Intent-to-Treat (ITT) analysis population as defined in the Statistical Analysis Plan (the source system). Used by biostatisticians to configure ADaM datasets and analysis flags.',
    `is_in_pp_population` BOOLEAN COMMENT 'Indicates whether data collected at this visit contributes to the Per Protocol (PP) analysis population as defined in the Statistical Analysis Plan (the source system). Supports biostatistical analysis dataset configuration.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether the procedure is mandatory (True) or optional (False) at this visit per the protocol Schedule of Events. Mandatory procedures are required for protocol compliance; optional procedures may be performed at investigator discretion.',
    `is_pk_sampling_visit` BOOLEAN COMMENT 'Indicates whether Pharmacokinetics (PK) blood or urine sampling is required at this visit. Used by DMPK teams, central labs, and RTSM/IRT systems to plan sample collection kits and logistics.',
    `is_primary_endpoint_visit` BOOLEAN COMMENT 'Indicates whether this visit is a primary endpoint assessment visit as defined in the study protocol. Flags visits where the primary efficacy or safety endpoint data is collected, critical for data completeness monitoring and regulatory submission.',
    `is_randomization_visit` BOOLEAN COMMENT 'Indicates whether subject randomization occurs at this visit via the RTSM/IRT system (e.g., the source system Medidata Rave RTSM). Critical for enrollment tracking, DSMB reporting, and regulatory milestone monitoring.',
    `is_unscheduled` BOOLEAN COMMENT 'Indicates whether this visit is an unscheduled visit (True) that occurs outside the planned Schedule of Events, typically triggered by a safety event, adverse event follow-up, or investigator decision.',
    `notes` STRING COMMENT 'Free-text notes or footnotes associated with this visit or procedure as specified in the protocol Schedule of Events (e.g., Perform only if subject is female of childbearing potential, Collect within 30 minutes of dosing).',
    `planned_study_day` BIGINT COMMENT 'The planned study day on which this visit is scheduled to occur, relative to the study reference start date (Day 1 = first dose or randomization). Negative values indicate pre-treatment visits (e.g., Day -14 for screening).',
    `planned_study_week` BIGINT COMMENT 'The planned study week on which this visit is scheduled, derived from planned_study_day for reporting convenience. Used in study timelines, subject visit planning, and site management dashboards.',
    `procedure_category` STRING COMMENT 'High-level category of the clinical procedure or assessment. Drives CDISC SDTM domain mapping, EDC form routing, and operational planning for site staff. [ENUM-REF-CANDIDATE',
    `procedure_name` STRING COMMENT 'Name of the specific clinical procedure or assessment required at this visit (e.g., Vital Signs, 12-Lead ECG, Hematology Lab Panel, PK Blood Draw, Physical Examination, Patient-Reported Outcome Questionnaire, Study Drug Dosing).',
    `procedure_sequence` BIGINT COMMENT 'Ordering sequence of the procedure within a visit, defining the recommended order of assessments (e.g., vital signs before blood draw, ECG before dosing). Used for site operational workflow and EDC form ordering.',
    `requires_central_lab` BOOLEAN COMMENT 'Indicates whether samples collected at this visit-procedure must be processed by the central laboratory (True) rather than a local laboratory. Drives sample kit logistics, central lab requisition, and supply chain planning.',
    `requires_local_lab` BOOLEAN COMMENT 'Indicates whether samples collected at this visit-procedure are to be processed by the site local laboratory. Used for safety lab monitoring where rapid turnaround is required (e.g., pre-dose safety labs).',
    `schedule_version` STRING COMMENT 'Version identifier for this Schedule of Events (SoE), aligned with the protocol amendment version (e.g., v1.0, v2.0, Amendment 1). Tracks iterative changes to the visit schedule over the study lifecycle.. Valid values are `^[A-Z0-9]{1,10}$`',
    `sdtm_domain` STRING COMMENT 'The two-letter CDISC Study Data Tabulation Model (SDTM) domain code to which data collected at this visit-procedure maps (e.g., VS for Vital Signs, LB for Laboratory, EG for ECG, EX for Exposure/Dosing, PC for Pharmacokinetics, QS for Questionnaires, PE. Valid values are `^[A-Z]{2}$`',
    `source_system_visit_code` STRING COMMENT 'Native identifier of this visit record in the originating operational system (Medidata Rave or the source system Used for data lineage, reconciliation, and cross-system traceability per ALCOA+ principles.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit schedule record was last modified in the lakehouse, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking and audit trail requirements under 21 CFR Part 11.',
    `visit_duration_minutes` BIGINT COMMENT 'Estimated duration of the visit in minutes as defined in the protocol or site operational plan. Used for site scheduling, resource planning, and subject burden assessment.',
    `visit_name` STRING COMMENT 'Human-readable name of the clinical visit as defined in the protocol Schedule of Events (e.g., Screening, Baseline, Week 4, End of Treatment, Follow-Up 1). Aligns with CDISC SDTM VISIT variable.',
    `visit_number` BIGINT COMMENT 'Sequential numeric identifier for the visit within the study schedule (e.g., 1, 2, 3). Used for ordering visits and aligns with CDISC SDTM VISITNUM variable. Unscheduled visits may use decimal values represented as separate records.',
    `visit_short_label` STRING COMMENT 'Abbreviated label for the visit used in EDC (Electronic Data Capture) systems, reports, and data listings (e.g., SCR, BL, W04, EOT, FU1). Configured in Medidata Rave and the source system for eCRF navigation.. Valid values are `^[A-Za-z0-9_-]{1,20}$`',
    `visit_status` STRING COMMENT 'Current lifecycle status of this visit schedule record. Draft indicates under development; active indicates approved and in use; amended indicates modified by a protocol amendment; superseded indicates replaced by a newer version; retired indicates no. Valid values are `draft|active|amended|superseded|retired`',
    `visit_type` STRING COMMENT 'The visit type of the study visit schedule.',
    `window_after_days` BIGINT COMMENT 'Number of days after the planned study day that the visit may occur and still be considered protocol-compliant (late visit tolerance). Used by sites and CTMS to flag out-of-window visits. Aligns with CDISC SDTM TVENRL variable.',
    `window_before_days` BIGINT COMMENT 'Number of days before the planned study day that the visit may occur and still be considered protocol-compliant (early visit tolerance). Used by sites and CTMS to flag out-of-window visits. Aligns with CDISC SDTM TVSTRL variable.',
    CONSTRAINT pk_study_visit_schedule PRIMARY KEY(`study_visit_schedule_id`)
) COMMENT 'Defines the planned Schedule of Events (SoE) for a clinical study including all visits and their required procedures. Captures visit name, visit number, visit type (screening, baseline, treatment, follow-up, unscheduled, end-of-study), planned study';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`visit_procedure` (
    `visit_procedure_id` BIGINT COMMENT 'Unique surrogate identifier for each visit procedure record in the Schedule of Events matrix. Primary key for the visit_procedure data product.',
    `activity_id` BIGINT COMMENT 'add column activity_id (BIGINT) with FK to study.activity.activity_id — per USDM, visit_procedure should link to activity',
    `ctcae_grade_id` BIGINT COMMENT 'Foreign key linking to terminology.ctcae_grade. Business justification: visit_procedure.ctcae_grading_applicable indicates safety assessments requiring CTCAE grading.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: EDC build validation and SDV planning: each protocol-defined procedure specifies the eCRF form used to collect its data.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Visit procedures that require laboratory work reference a specific lab panel. Linking visit_procedure to lab_panel enables automated lab kit assignment, SDTM LB domain mapping from the',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version or amendment under which this visit procedure was defined. Enables tracking of procedure changes across protocol amendments.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) to which this visit procedure belongs. Links the procedure to its parent study context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: visit_procedure has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `study_visit_schedule_id` BIGINT COMMENT 'Reference to the scheduled visit (study visit) at which this procedure is to be performed. Establishes the visit-procedure association in the Schedule of Events.',
    `adam_dataset` STRING COMMENT 'CDISC ADaM dataset name to which this procedures data contributes for statistical analysis (e.g., ADLB, ADVS, ADEG, ADPC). Used by SAS Drug Development for biostatistical analysis and CSR generation.',
    `cdash_domain` STRING COMMENT 'CDISC CDASH domain code that defines the data collection standard for this procedures eCRF (e.g., VS, LB, EG, PE). Ensures the eCRF design in Medidata Rave aligns with CDASH standards for downstream SDTM mapping.',
    `central_lab_required` BOOLEAN COMMENT 'Indicates whether specimens collected by this procedure must be processed by the sponsor-designated central laboratory (as opposed to a local site laboratory). Drives sample kit supply chain and central lab requisition workflows.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit procedure record was first created in the system. Supports audit trail requirements and data lineage tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `ctcae_grading_applicable` BOOLEAN COMMENT 'Indicates whether CTCAE grading criteria apply to results collected by this procedure (e.g., laboratory abnormalities graded per CTCAE v5.0). Drives safety data review workflows and adverse event reporting linkage.',
    `effective_end_date` DATE COMMENT 'Date on which this procedure definition was retired or superseded by a protocol amendment. Null for currently active procedures. Used to determine which procedure version applies to a given subject visit date.',
    `effective_start_date` DATE COMMENT 'Date from which this procedure definition became effective in the study protocol. For amended procedures, reflects the date the amendment was approved and implemented at sites.',
    `equipment_type` STRING COMMENT 'Type of clinical equipment or device required to perform this procedure at the site (e.g., Holter Monitor, Spirometer, Dual-Energy X-ray Absorptiometry (DXA) Scanner, Electrocardiograph).',
    `estimated_duration_minutes` BIGINT COMMENT 'Estimated time in minutes required to complete this procedure at the site. Used for visit duration planning, site burden assessment, and subject scheduling optimization.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this procedure is required (mandatory) or optional at the associated visit per the study protocol. Mandatory procedures must be completed for the visit to be considered evaluable; optional procedures may be performed at investigator',
    `is_pk_assessment` BOOLEAN COMMENT 'Indicates whether this procedure involves pharmacokinetic (PK) sample collection or assessment. PK procedures require precise timing relative to dosing and specialized sample handling per the bioanalytical plan.',
    `is_primary_endpoint` BOOLEAN COMMENT 'Indicates whether this procedure collects data that directly contributes to the studys primary efficacy or safety endpoint. Used to prioritize monitoring, SDV, and data cleaning activities.',
    `is_safety_assessment` BOOLEAN COMMENT 'Indicates whether this procedure is designated as a safety assessment per the protocol (e.g., safety labs, ECG for QTc monitoring, vital signs for blood pressure monitoring). Drives safety data review workflows and DSMB/DMC reporting.',
    `local_lab_allowed` BOOLEAN COMMENT 'Indicates whether local site laboratory processing is permitted for this procedure (e.g., for safety monitoring labs that require rapid turnaround). May coexist with central_lab_required for procedures requiring both central and local processing.',
    `notes` STRING COMMENT 'Free-text field for protocol-specific instructions, special handling requirements, or clarifications related to this procedure that are not captured in structured fields (e.g., Collect sample within 2 hours of dosing, Perform in triplicate).',
    `oracle_clinical_one_task_code` STRING COMMENT 'Identifier of the corresponding task or activity in the source system study design module. Enables cross-system traceability between the lakehouse visit procedure record and the the source system study build configuration.',
    `procedure_category` STRING COMMENT 'Categorical classification of the clinical procedure type used to group procedures in the Schedule of Events matrix and CDISC SDTM domain mapping. [ENUM-REF-CANDIDATE',
    `procedure_code` STRING COMMENT 'Sponsor-assigned alphanumeric code uniquely identifying the procedure within the study protocol (e.g., VITALS-01, LBDRAW-02, ECG-01). Used as the business identifier for the procedure in the Schedule of Events matrix and eCRF mapping.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `procedure_description` STRING COMMENT 'Detailed narrative description of the clinical procedure, including instructions, conditions, and any protocol-specific requirements (e.g., fasting requirements, timing relative to dosing, specimen handling instructions).',
    `procedure_name` STRING COMMENT 'Human-readable name of the clinical procedure or assessment (e.g., Vital Signs, 12-Lead ECG, Fasting Blood Draw, ECOG Performance Status Assessment). Used in Schedule of Events displays and site training materials.',
    `procedure_status` STRING COMMENT 'Current lifecycle status of the visit procedure definition within the study protocol. Draft procedures are under development; active procedures are in use; amended procedures have been modified by protocol amendment; retired procedures are no longer. Valid values are `draft|active|amended|retired|superseded`',
    `qualified_personnel_required` STRING COMMENT 'Specifies the qualification or role required to perform this procedure (e.g., Phlebotomist, Radiologist, Cardiologist, Trained Study Nurse). Used for site staff delegation log and training requirement planning.',
    `rave_form_version` STRING COMMENT 'Version identifier of the Medidata Rave eCRF form associated with this procedure (e.g., 1.0, 2.1). Tracks form versioning to ensure data collected aligns with the correct protocol version and supports audit trail requirements under 21 CFR Part 11.',
    `requires_fasting` BOOLEAN COMMENT 'Indicates whether the subject must be in a fasting state prior to this procedure (e.g., fasting lipid panel, fasting glucose). Drives subject instruction materials and visit scheduling constraints.',
    `requires_unscheduled_flag` BOOLEAN COMMENT 'Indicates whether this procedure definition applies to unscheduled visits (e.g., safety follow-up, early termination). Distinguishes procedures that are only applicable at unscheduled visits from those in the planned Schedule of Events.',
    `sdtm_domain` STRING COMMENT 'CDISC SDTM domain code to which this procedures collected data maps (e.g., VS=Vital Signs, LB=Laboratory Test Results, EG=ECG Test Results, EX=Exposure, PE=Physical Examination). Drives SDTM dataset construction for regulatory submission.',
    `sdv_requirement` STRING COMMENT 'Specifies the Source Data Verification (SDV) requirement level for data collected by this procedure. Drives risk-based monitoring plans and CRA visit scope.. Valid values are `100_percent|risk_based|critical_only|not_required`',
    `sequence_number` BIGINT COMMENT 'Numeric ordering of the procedure within the visit, defining the recommended execution sequence (e.g., 1=vital signs, 2=blood draw, 3=ECG). Used to generate the ordered Schedule of Events and site procedure checklists.',
    `specimen_type` STRING COMMENT 'Type of biological specimen collected during this procedure, if applicable (e.g., blood, urine, tissue biopsy, CSF). Drives laboratory supply chain planning, sample handling instructions, and CDISC SDTM LBSPEC mapping.',
    `specimen_volume_ml` DECIMAL(10,3) COMMENT 'Volume of biological specimen required for this procedure in millilitres (mL). Used for blood volume tracking per subject visit, laboratory supply planning, and protocol feasibility assessment (total blood volume per subject).',
    `timing_reference` STRING COMMENT 'Specifies the timing reference point for procedure execution relative to a clinical anchor event (e.g., pre_dose, post_dose, fasting). Critical for PK sampling, vital signs, and lab draws where timing relative to dosing affects data interpretation.',
    `timing_window_post_minutes` BIGINT COMMENT 'Allowable time window in minutes after the nominal procedure time point (positive offset). Defines the acceptable late execution window for protocol compliance assessment (e.g., +30 minutes for a post-dose PK sample).',
    `timing_window_pre_minutes` BIGINT COMMENT 'Allowable time window in minutes before the nominal procedure time point (negative offset). Defines the acceptable early execution window for protocol compliance assessment (e.g., -30 minutes for a pre-dose PK sample).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit procedure record was last modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_visit_procedure PRIMARY KEY(`visit_procedure_id`)
) COMMENT 'Defines the specific clinical procedures, assessments, and data collection activities required at each scheduled visit. Records procedure name, procedure category (vital signs, lab draw, ECG, imaging, questionnaire, dosing, PK sampling, physical exam';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`epoch` (
    `epoch_id` BIGINT COMMENT 'Unique surrogate identifier for a study epoch record in the lakehouse Silver layer. Primary key for the study_epoch data product.',
    `codelist_id` BIGINT COMMENT 'Controlled vocabulary classification of the epochs functional purpose within the study design. Drives SDTM dataset construction and subject disposition analysis.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version that defines this epoch. Epochs may be added, removed, or modified across protocol amendments.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, epochs belong to study_design',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this epoch belongs. Links the epoch to its governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: study_epoch has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `type_codelist_term_id` BIGINT COMMENT 'BIGINT',
    `ae_reporting_applicable` BOOLEAN COMMENT 'Indicates whether adverse event (AE) and serious adverse event (SAE) collection and reporting obligations are active during this epoch. Drives safety data collection rules in the EDC and the source system',
    `blinding_type` STRING COMMENT 'Blinding methodology applied during this epoch as specified in the protocol. Determines data access controls and unblinding procedures applicable to the epoch period.. Valid values are `OPEN-LABEL|SINGLE-BLIND|DOUBLE-BLIND|TRIPLE-BLIND|NOT-APPLICABLE`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this epoch record was first created in the lakehouse Silver layer. Supports audit trail requirements under FDA 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `epoch_description` STRING COMMENT 'Textual description of the study epoch, including its purpose and duration.',
    `effective_end_date` DATE COMMENT 'Date on which this epoch definition version ceased to be effective, typically due to a protocol amendment superseding it. Null for the currently active epoch definition version.',
    `effective_start_date` DATE COMMENT 'Date from which this epoch definition version became effective in the study protocol. Used for amendment tracking and determining which epoch definition applies to a given subject enrollment date.',
    `extension_epoch` BOOLEAN COMMENT 'Indicates whether this epoch is an optional or mandatory study extension period beyond the core treatment phase. Extension epochs may have separate regulatory approval requirements.',
    `follow_up_epoch` BOOLEAN COMMENT 'Indicates whether this epoch is a post-treatment follow-up period for safety monitoring and long-term outcome assessment. Drives safety reporting timelines and subject disposition coding.',
    `ip_administered` BOOLEAN COMMENT 'Indicates whether investigational product (IP) is administered to subjects during this epoch. Drives IP accountability tracking, supply chain planning, and SDTM exposure domain (EX) linkage.',
    `is_deleted` BOOLEAN COMMENT 'Indicates whether this epoch record has been logically deleted (soft delete). True = record is logically deleted and should be excluded from active queries; False = record is active. Supports data retention compliance without physical deletion.',
    `itt_population_epoch` BOOLEAN COMMENT 'Indicates whether subject participation in this epoch contributes to Intent-to-Treat (ITT) population eligibility determination. Used in biostatistical analysis and the source system',
    `maximum_duration_days` BIGINT COMMENT 'Protocol-specified maximum number of days a subject may remain in this epoch before mandatory transition or discontinuation. Enforced by CTMS and EDC visit scheduling logic.',
    `minimum_duration_days` BIGINT COMMENT 'Protocol-specified minimum number of days a subject must remain in this epoch to be considered evaluable. Used for per-protocol (PP) population eligibility determination.',
    `epoch_name` STRING COMMENT 'Full descriptive name of the study epoch as defined in the protocol (e.g., Screening, Run-in, Treatment Period 1, Washout, Follow-up, Extension). Maps to CDISC SDTM TE.EPOCH variable.',
    `planned_duration_days` BIGINT COMMENT 'Protocol-specified planned duration of the epoch expressed in days. Used for visit scheduling, subject timeline calculations, and study feasibility planning. Maps to CDISC SDTM TE.TEDUR (ISO 8601 duration converted to days for analytics).',
    `planned_duration_iso` STRING COMMENT 'Protocol-specified planned duration of the epoch expressed in ISO 8601 duration format (e.g., P28D, P4W, P6M). This is the authoritative CDISC SDTM TE.TEDUR value used for regulatory submissions.. Valid values are `^P(d+Y)?(d+M)?(d+W)?(d+D)?(T(d+H)?(d+M)?(d+S)?)?$`',
    `planned_end_day` BIGINT COMMENT 'Protocol-defined study day on which this epoch is planned to end, relative to the study reference start date. Used for visit schedule construction and subject timeline alignment.',
    `planned_start_day` BIGINT COMMENT 'Protocol-defined study day on which this epoch is planned to begin, relative to the study reference start date (Day 1). Used for visit schedule construction and subject timeline alignment.',
    `primary_endpoint_epoch` BOOLEAN COMMENT 'Indicates whether the primary efficacy endpoint assessments are collected during this epoch. Used in statistical analysis plan (the source system) to define the primary analysis window.',
    `protocol_section_reference` STRING COMMENT 'Reference to the specific section number or identifier within the study protocol document that defines this epoch (e.g., Section 6.2.1). Enables traceability between the data model and the source protocol document.',
    `randomization_applicable` BOOLEAN COMMENT 'Indicates whether subject randomization occurs during this epoch. True = randomization event occurs within this epoch (e.g., Treatment Period 1 start); False = no randomization in this epoch.',
    `sdtm_epoch_code` STRING COMMENT 'CDISC SDTM controlled terminology code for the epoch as submitted in the Trial Elements (TE) domain ETCD variable. Must conform to CDISC CT epoch codelist (C99079). Used for regulatory submission dataset construction.. Valid values are `^[A-Z0-9_]{1,8}$`',
    `sdtm_te_domain_flag` BOOLEAN COMMENT 'Indicates whether this epoch record is mapped and included in the CDISC SDTM Trial Elements (TE) domain for regulatory submission. True = included in TE domain; False = excluded (e.g., internal planning epoch not submitted).',
    `sequence_number` BIGINT COMMENT 'Numeric ordering of the epoch within the study timeline. Determines the chronological position of the epoch relative to other epochs. Maps to CDISC SDTM TE.TEPRNM variable.',
    `short_name` STRING COMMENT 'Abbreviated or short label for the epoch used in data displays, visit schedules, and SDTM dataset headers (e.g., SCR, RUN, TRT1, WASH, FU). Maps to CDISC SDTM TE.ETCD variable.',
    `source_system_epoch_code` STRING COMMENT 'Native identifier for this epoch as recorded in the originating operational system (e.g., the source system study design module or Medidata Rave EDC). Enables lineage tracing and reconciliation between the lakehouse and source systems.',
    `source_system_name` STRING COMMENT 'Name of the operational system of record from which this epoch definition was sourced (e.g., the source system Medidata Rave). Supports data lineage and audit trail requirements under 21 CFR Part 11.. Valid values are `ORACLE_CLINICAL_ONE|MEDIDATA_RAVE|MANUAL|OTHER`',
    `epoch_status` STRING COMMENT 'Current lifecycle status of the epoch definition within the study protocol. DRAFT indicates under development; ACTIVE indicates approved and in use; AMENDED indicates modified by protocol amendment; SUPERSEDED indicates replaced by a newer version. Valid values are `DRAFT|ACTIVE|AMENDED|SUPERSEDED|RETIRED`',
    `treatment_arm_specific` BOOLEAN COMMENT 'Indicates whether this epoch applies to a specific treatment arm only (True) or is common across all arms of the study (False). Relevant for crossover and multi-arm study designs.',
    `epoch_type` STRING COMMENT 'The epoch type of the epoch.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this epoch record was last modified in the lakehouse Silver layer. Supports change tracking, audit trail requirements, and incremental data pipeline processing.',
    `washout_epoch` BOOLEAN COMMENT 'Indicates whether this epoch is a washout period during which prior treatment effects are expected to dissipate before the next treatment period. Used in crossover study design analysis.',
    `window_after_days` BIGINT COMMENT 'Allowable number of days after the planned epoch start date within which the epoch transition is considered protocol-compliant. Used for protocol deviation assessment.',
    `window_before_days` BIGINT COMMENT 'Allowable number of days before the planned epoch start date within which the epoch transition is considered protocol-compliant. Used for protocol deviation assessment.',
    CONSTRAINT pk_epoch PRIMARY KEY(`epoch_id`)
) COMMENT 'Defines the temporal epochs (periods) of a clinical study such as Screening, Run-in, Treatment Period 1, Washout, Treatment Period 2, Follow-up, and Extension.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` (
    `study_protocol_milestone_id` BIGINT COMMENT 'Unique surrogate identifier for each study milestone record in the Clinical Trial Management System (CTMS). Primary key for the study_milestone data product.',
    `employee_id` BIGINT COMMENT 'Reference to the individual (e.g., Project Manager, CRA, Regulatory Affairs Lead) who is personally accountable for driving this milestone to completion. Links to the workforce/employee master.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Contractual milestones require sponsor contact accountability for achievement confirmation and payment authorization.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization associated with this milestone. Enables sponsor-level milestone reporting and portfolio analytics.',
    `predecessor_study_protocol_milestone_id` BIGINT COMMENT 'Self-referencing identifier of the milestone that must be achieved before this milestone can begin. Enables dependency chain modeling for critical path analysis and schedule impact assessment.',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: Study-level milestones (e.g., FPI, DBL) are governed by and contribute to program-level milestones in critical path analysis and integrated program timelines.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: study_milestone has protocol_version as a STRING but no FK to protocol. Study milestones (e.g., Protocol Final, First Patient In, Database Lock) are associated with specific protocol versions',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Study milestones are contractual commitments tracked within the CRO-sponsor engagement. Milestone achievement drives payment triggers and governance reporting at the engagement level.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this milestone belongs. Links the milestone to the study protocol and overall study lifecycle.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Reference to the protocol amendment that introduced or modified this milestone. Null if the milestone was defined in the original protocol. Supports change impact traceability per GCP requirements.',
    `achievement_confirmed_by` STRING COMMENT 'Name or role of the individual who formally confirmed and recorded the milestone as achieved in the CTMS. Supports ALCOA+ data integrity requirements and audit trail documentation.',
    `achievement_confirmed_timestamp` TIMESTAMP COMMENT 'Date and time when the milestone achievement was formally confirmed and recorded in the CTMS. Distinct from actual_date (the business event date) — this is the system confirmation timestamp per ALCOA+ requirements.',
    `actual_date` DATE COMMENT 'The calendar date on which the milestone was actually achieved. Null if the milestone has not yet been reached. Compared against planned_date to compute schedule variance for sponsor reporting and KPI tracking.',
    `actual_enrollment_count` BIGINT COMMENT 'For enrollment-type milestones, the actual number of subjects enrolled at the time of milestone achievement. Compared against target_enrollment_count to assess enrollment performance at key study milestones.',
    `baseline_date` DATE COMMENT 'The approved baseline date for the milestone, set at study kick-off or after a formal re-baseline event. Preserved as an immutable reference point even when planned_date is revised, enabling true baseline vs. current schedule variance analysis.',
    `comments` STRING COMMENT 'Free-text field for additional operational notes, sponsor communications, or contextual information related to the milestone. Supports collaborative tracking and audit documentation in CTMS.',
    `completion_criteria` STRING COMMENT 'Formal, measurable criteria that must be satisfied for the milestone to be considered achieved (e.g., 100% of target sites activated, All CRFs locked and queries resolved). Supports objective milestone verification.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this milestone record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_milestone_ref` STRING COMMENT 'Native milestone identifier from the the source system source system. Preserved for cross-system traceability, data lineage, and reconciliation between the lakehouse silver layer and the operational CTMS.',
    `data_source` STRING COMMENT 'Identifies the operational system of record from which this milestone record originated (e.g., the source system the source system manual entry). Supports data lineage tracking and reconciliation in the silver layer.. Valid values are `siebel_ctms|oracle_clinical_one|manual|sponsor_feed|other`',
    `dependency_type` STRING COMMENT 'Type of scheduling dependency between this milestone and its predecessor (e.g., Finish-to-Start means the predecessor must finish before this milestone can start). Supports critical path method (CPM) scheduling in CTMS.. Valid values are `finish_to_start|start_to_start|finish_to_finish|start_to_finish`',
    `forecast_date` DATE COMMENT 'The current best-estimate date for milestone achievement, updated dynamically as study conditions evolve. Distinct from planned_date (baseline) and actual_date (confirmed). Supports rolling forecast reporting to sponsors.',
    `is_contractual` BOOLEAN COMMENT 'Indicates whether this milestone is tied to a contractual obligation with the sponsor (e.g., payment trigger, deliverable deadline). Contractual milestones are tracked for financial and legal compliance purposes.',
    `is_critical_path` BOOLEAN COMMENT 'Indicates whether this milestone lies on the critical path of the study schedule. Critical path milestones directly impact the overall study completion date and receive heightened monitoring attention from the sponsor and CRO.',
    `is_regulatory_milestone` BOOLEAN COMMENT 'Indicates whether this milestone has a direct regulatory reporting obligation (e.g., IND submission, first patient enrolled notification, DBL, NDA/BLA submission). Regulatory milestones trigger compliance tracking and health authority notifications.',
    `lead_lag_days` BIGINT COMMENT 'Number of days of lead (negative) or lag (positive) applied to the dependency relationship with the predecessor milestone. Allows scheduling flexibility where a milestone can start before or must wait after its predecessor.',
    `milestone_category` STRING COMMENT 'High-level grouping of the milestone for portfolio-level reporting and sponsor dashboards. Distinguishes operational milestones (site activation, monitoring) from regulatory (IND, NDA/BLA submissions) and data management (DBL, CSR) milestones.. Valid values are `operational|regulatory|enrollment|safety|financial|data_management`',
    `milestone_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying the milestone within the study (e.g., FPFV, LPLV, DBL, CSR_SUBMIT). Used as the business identifier in CTMS and sponsor reporting.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `milestone_description` STRING COMMENT 'Detailed narrative description of the milestone, including entry/exit criteria, acceptance conditions, and any special instructions. Provides context beyond the milestone_name for operational teams and auditors.',
    `milestone_name` STRING COMMENT 'Human-readable name of the milestone (e.g., First Patient First Visit, Last Patient Last Visit, Database Lock, Clinical Study Report Submission). Used in sponsor dashboards and CTMS timeline views.',
    `milestone_status` STRING COMMENT 'Current lifecycle state of the milestone indicating whether it has been achieved, is pending, is delayed relative to plan, has been waived, or cancelled. Core field for CTMS timeline tracking and sponsor reporting.. Valid values are `pending|in_progress|achieved|delayed|waived|cancelled`',
    `milestone_type` STRING COMMENT 'Categorical classification of the milestone by its operational or regulatory function. Drives reporting groupings and critical path analysis. [ENUM-REF-CANDIDATE',
    `notification_required` BOOLEAN COMMENT 'Indicates whether achievement of this milestone triggers a formal notification to the sponsor, health authority, IRB/IEC, or other stakeholder. Drives automated alert workflows in CTMS.',
    `notification_sent_timestamp` TIMESTAMP COMMENT 'Date and time when the milestone achievement notification was dispatched to the relevant stakeholders. Null if notification has not yet been sent. Supports compliance audit trails for regulatory reporting obligations.',
    `planned_date` DATE COMMENT 'The originally scheduled calendar date by which this milestone was expected to be achieved, as defined in the study protocol or project plan. Used as the baseline for variance calculations and critical path analysis.',
    `responsible_party` STRING COMMENT 'The organizational unit or role accountable for achieving this milestone (e.g., Sponsor, CRO, Site, Data Management, Regulatory Affairs). Used for accountability tracking and escalation routing in CTMS.',
    `sequence` BIGINT COMMENT 'Ordinal position of this milestone within the studys overall milestone schedule. Defines the logical ordering of milestones for timeline visualization and Gantt chart rendering in CTMS.',
    `study_phase` STRING COMMENT 'Clinical development phase of the study at the time this milestone is defined (Phase 1, 2, 3, 4). Contextualizes the milestone within the drug development lifecycle for portfolio analytics.',
    `target_enrollment_count` BIGINT COMMENT 'For enrollment-type milestones (e.g., FPFV, 50% enrollment, LPLV), the target number of subjects to be enrolled at the time of milestone achievement. Provides quantitative context for enrollment milestone tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this milestone record was most recently modified. Supports change tracking, audit trail requirements per 21 CFR Part 11, and incremental data pipeline processing in the Databricks lakehouse.',
    `variance_days` BIGINT COMMENT 'Number of calendar days between the planned_date and the actual_date (or forecast_date if not yet achieved). Positive values indicate delay; negative values indicate early completion. Used for sponsor KPI reporting and study performance analytics.',
    `variance_reason` STRING COMMENT 'Free-text or coded explanation for any deviation between the planned and actual/forecast milestone date. Required when variance_days is non-zero. Supports root cause analysis and CAPA tracking per GCP requirements.',
    `variance_reason_code` STRING COMMENT 'Standardized coded classification of the variance reason to enable aggregate analysis across studies and portfolios. Complements the free-text variance_reason field.',
    `waiver_approved_by` STRING COMMENT 'Name or role of the authorized individual who approved the milestone waiver. Required when milestone_status is waived. Supports GCP compliance and sponsor governance documentation.',
    `waiver_justification` STRING COMMENT 'Documented rationale for waiving a milestone when milestone_status is waived. Required for regulatory audit trail and sponsor approval. Captures the business or scientific justification for the waiver decision.',
    CONSTRAINT pk_study_protocol_milestone PRIMARY KEY(`study_protocol_milestone_id`)
) COMMENT 'Study-level milestone - distinct concept, separate owner from regulatory_milestone and program_milestone.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`country` (
    `country_id` BIGINT COMMENT 'Unique surrogate identifier for the study-country record. Primary key for the study_country data product in the Databricks Silver Layer.',
    `cta_regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Each countrys CTA submission (tracked via cta_submission_date, cta_approval_date on study_country) is filed in a country-specific regulatory binder.',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: Each country requires a country-specific ICF version (language, local regulatory requirements). study_country.icf_version_required tracks this need.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) or Country Manager designated as the primary point of contact for all sites and regulatory activities in this country. Sourced from the source system and the source system',
    `health_authority_id` BIGINT COMMENT 'Reference to the governing regulatory authority responsible for clinical trial oversight in this country (e.g., FDA for US, EMA/national competent authority for EU member states, PMDA for Japan). Links to the health_authority reference product.',
    `sponsor_regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to sponsor.regulatory_strategy. Business justification: Country-level CTA submissions and regulatory approvals are governed by the sponsors regional regulatory strategy.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this country-level record is maintained. Links the country configuration to the study protocol.',
    `activated_site_count` BIGINT COMMENT 'Actual number of investigative sites that have been activated and authorized to enroll subjects in this country. Compared against planned_site_count for country-level site activation KPI reporting.',
    `activation_status` STRING COMMENT 'Overall operational activation status of the country within the study lifecycle, distinct from enrollment_status. Reflects the countrys readiness and operational state as tracked in the source system and the source system. Valid values are `not_started|in_startup|activated|suspended|closed`',
    `actual_enrolled_count` BIGINT COMMENT 'Actual number of subjects enrolled (consented and randomized or screened) in this country to date. Compared against planned_enrollment_target for enrollment performance reporting in Medidata Rave and the source system',
    `actual_screened_count` BIGINT COMMENT 'Actual number of subjects screened at sites in this country to date. Used to calculate the realized screen failure rate and to assess enrollment efficiency.',
    `budget_amount` DECIMAL(18,2) COMMENT 'Total approved budget allocated for all study activities in this country, expressed in the countrys local currency (see currency_code). Sourced from the source system accounting and used for country-level financial performance tracking.',
    `country_code` STRING COMMENT 'Two-letter ISO 3166-1 alpha-2 country code identifying the country where the clinical study is conducted (e.g., US, DE, JP). Used as the primary geographic identifier for regulatory and enrollment reporting.. Valid values are `^[A-Z]{2}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this study-country record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ data integrity principles and audit trail requirements.',
    `cta_approval_date` DATE COMMENT 'Date on which the regulatory authority granted approval for the clinical trial to proceed in this country. Milestone used for site activation planning and regulatory timeline KPI reporting.',
    `cta_approval_status` STRING COMMENT 'Current approval status of the CTA or IND application with the national regulatory authority. Drives regulatory hold flags and country activation readiness assessments.. Valid values are `not_submitted|submitted|approved|rejected|withdrawn|pending_response`',
    `cta_submission_date` DATE COMMENT 'Date on which the Clinical Trial Authorization (CTA) or Investigational New Drug (IND) application was submitted to the national regulatory authority for this country. Tracked in Veeva Vault for regulatory timeline management.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the country (e.g., USD, EUR, JPY). Used for country-level budget planning, site payment processing, and financial reporting in the source system. Valid values are `^[A-Z]{3}$`',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework applicable to subject data collected in this country (e.g., GDPR for EU, HIPAA for US, PIPEDA for Canada, APPI for Japan). Drives data handling, consent, and transfer requirements.',
    `dropout_rate_assumption` DECIMAL(5,4) COMMENT 'Assumed proportion of enrolled subjects expected to withdraw or be lost to follow-up in this country, expressed as a decimal (e.g., 0.1000 = 10%). Used in sample size and enrollment buffer calculations.',
    `enrollment_closure_date` DATE COMMENT 'Date on which enrollment was formally closed in this country, either due to target achievement, regulatory hold, or study termination. Distinct from last_subject_enrolled_date as it reflects the administrative closure decision.',
    `enrollment_rate_assumption` DECIMAL(7,4) COMMENT 'Assumed average number of subjects enrolled per active site per month in this country, used in enrollment forecasting and timeline modeling. Expressed as a decimal (e.g., 1.5000 subjects/site/month).',
    `enrollment_status` STRING COMMENT 'Current enrollment lifecycle status for this country within the study. Drives enrollment forecasting, site activation planning, and country-level feasibility reporting in the source system and Medidata Rave.. Valid values are `planned|active|enrollment_complete|on_hold|terminated|closed`',
    `eudract_number` STRING COMMENT 'EudraCT number assigned by the European Medicines Agency (EMA) for clinical trials conducted in EU/EEA member states. Required for EU CTR compliance and EudraCT/CTIS registration. Applicable only for EU countries.. Valid values are `^d{4}-d{6}-d{2}$`',
    `feasibility_assessment_date` DATE COMMENT 'Date on which the country-level feasibility assessment was completed and the feasibility_score was assigned. Used to track the currency of feasibility data for enrollment planning.',
    `feasibility_score` DECIMAL(5,2) COMMENT 'Composite numeric score (typically 0–100) representing the overall feasibility assessment rating for conducting the study in this country, based on site availability, patient population, regulatory environment, and infrastructure.',
    `first_site_activation_date` DATE COMMENT 'Date on which the first investigative site in this country was activated and authorized to enroll subjects. Key milestone for country-level startup timeline KPI reporting in the source system',
    `first_subject_enrolled_date` DATE COMMENT 'Date on which the first subject was enrolled (consented and randomized or screened) at any site within this country. Marks the start of active enrollment for country-level timeline tracking.',
    `icf_version_required` STRING COMMENT 'Version identifier of the Informed Consent Form (ICF) approved by the national IRB/IEC and regulatory authority for use in this country. Ensures sites use the correct country-specific ICF version as tracked in Clinpal and Veeva Vault.',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the national or central IRB/IEC granted ethical approval for the study to proceed in this country. Required before any subject enrollment can commence.',
    `irb_iec_submission_date` DATE COMMENT 'Date on which the study protocol and informed consent materials were submitted to the national or central Institutional Review Board (IRB) or Independent Ethics Committee (IEC) for ethical review in this country.',
    `last_subject_enrolled_date` DATE COMMENT 'Date on which the last subject was enrolled in this country. Used to calculate country-level enrollment duration and to trigger enrollment completion milestones.',
    `local_language_code` STRING COMMENT 'Primary local language code for the country using IETF BCP 47 format (e.g., de-DE, ja-JP, fr-FR). Drives Informed Consent Form (ICF) translation requirements and eCRF localization in Clinpal and Medidata Rave.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `local_regulatory_reference_number` STRING COMMENT 'Country-specific regulatory reference or dossier number assigned by the national competent authority upon CTA/IND submission or approval (e.g., EudraCT number for EU, IND number for US, CTN for Australia). Stored in Veeva Vault.',
    `country_name` STRING COMMENT 'Full English name of the country as defined by ISO 3166-1 (e.g., United States, Germany, Japan). Used for display in regulatory submissions, reports, and dashboards.',
    `national_registry_number` STRING COMMENT 'Country-specific clinical trial registry number assigned by the national registry (e.g., ISRCTN, UMIN for Japan, CTRI for India). Distinct from EudraCT and ClinicalTrials.gov identifiers. Required for WHO ICTRP compliance.',
    `planned_enrollment_target` BIGINT COMMENT 'Target number of subjects planned to be enrolled in this country as defined in the study protocol and country feasibility assessment. Drives enrollment forecasting and country-level resource allocation.',
    `planned_screen_count` BIGINT COMMENT 'Planned number of subjects to be screened in this country, derived from the planned enrollment target and the assumed screen failure rate. Used for site capacity planning and patient recruitment forecasting.',
    `planned_site_count` BIGINT COMMENT 'Number of investigative sites planned to be activated in this country as defined in the study feasibility assessment and country-level enrollment plan. Used for resource planning and site activation tracking.',
    `regulatory_hold_flag` BOOLEAN COMMENT 'Indicates whether a regulatory hold (e.g., FDA Clinical Hold under 21 CFR 312.42, or equivalent national authority hold) is currently in effect for this country, preventing or suspending subject enrollment.',
    `regulatory_hold_lift_date` DATE COMMENT 'Date on which the regulatory hold was lifted by the national authority, allowing enrollment to resume. Null if the hold is still in effect.',
    `regulatory_hold_reason` STRING COMMENT 'Narrative description of the reason for the regulatory hold in this country, as communicated by the national regulatory authority. Populated only when regulatory_hold_flag is True.',
    `regulatory_hold_start_date` DATE COMMENT 'Date on which the regulatory hold was imposed by the national authority in this country. Used for regulatory timeline impact analysis and sponsor reporting.',
    `screen_failure_rate_assumption` DECIMAL(5,4) COMMENT 'Assumed proportion of screened subjects expected to fail screening criteria in this country, expressed as a decimal (e.g., 0.3000 = 30%). Used in enrollment forecasting models to derive planned_screen_count from planned_enrollment_target.',
    `subject_data_transfer_allowed` BOOLEAN COMMENT 'Indicates whether subject-level clinical data collected in this country may be transferred cross-border to the sponsor or CRO data systems under applicable data privacy regulations (e.g., GDPR Chapter V adequacy decisions, SCCs).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this study-country record was most recently modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ data integrity principles and change audit trail requirements per 21 CFR Part 11.',
    CONSTRAINT pk_country PRIMARY KEY(`country_id`)
) COMMENT 'Manages the countries in which a clinical study is conducted including country-level enrollment planning. Records country code (ISO 3166), country name, regulatory authority, CTA/IND submission and approval dates, approval status, first site activation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`investigational_product` (
    `investigational_product_id` BIGINT COMMENT 'Unique surrogate identifier for the investigational medicinal product (IMP) or investigational device record in the lakehouse silver layer. Primary key for this master resource entity.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: An investigational product is developed within a clinical program. Program-level IND/IMPD lifecycle management, clinical supply planning, and regulatory strategy (e.g., IND annual',
    `imp_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The Investigational Medicinal Product Dossier (IMPD) / Investigators Brochure is a DIA TMF Zone 4 essential document.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: An investigational product is authorized for clinical use under a specific IND/IMPD.',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.nda_bla_application. Business justification: For late-phase trials, the investigational product is the subject of an NDA/BLA.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: The IND/IMPD submission for an investigational product is filed in a regulatory binder.',
    `active_substance` STRING COMMENT 'Name of the active pharmaceutical ingredient (API) or active substance in the investigational product. May differ from the INN for novel compounds. Used in IMPD/IND CMC sections, pharmacovigilance, and SDTM datasets.',
    `cas_number` STRING COMMENT 'Chemical Abstracts Service (CAS) Registry Number uniquely identifying the active substance chemical structure. Used in regulatory submissions, safety data sheets, and cross-referencing with pharmacological databases.. Valid values are `^[0-9]{2,7}-[0-9]{2}-[0-9]$`',
    `controlled_substance_schedule` STRING COMMENT 'DEA controlled substance schedule classification for the investigational product (e.g., Schedule II, Schedule IV) or not_controlled if not a controlled substance.. Valid values are `schedule_I|schedule_II|schedule_III|schedule_IV|schedule_V|not_controlled`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the investigational product master record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11, ALCOA+ principles, and GCP compliance.',
    `investigational_product_description` STRING COMMENT 'Free-text narrative description of the investigational product including its therapeutic purpose, background, and any additional context not captured in structured fields. Used in protocol background sections and regulatory submissions.',
    `development_phase` STRING COMMENT 'Current clinical development phase of the investigational product at the time of record creation or last update (e.g., Phase 1, Phase 2, Phase 3). Informs regulatory strategy, risk classification, and portfolio management.',
    `dosage_form` STRING COMMENT 'Physical form of the investigational product as administered to subjects (e.g., tablet, capsule, solution for injection, lyophilized powder). Captured per CDISC SDTM EX domain and referenced in supply chain and pharmacy management.',
    `ema_product_number` STRING COMMENT 'EMA-assigned product number for the investigational product as registered in the EU Clinical Trials Information System (CTIS) or EudraCT. Required for EU regulatory submissions and EU CTR 536/2014 compliance.',
    `first_in_human_date` DATE COMMENT 'Date on which the investigational product was first administered to a human subject in any clinical study. Key milestone for regulatory timelines, development history, and portfolio analytics.',
    `formulation` STRING COMMENT 'Qualitative description of the investigational product formulation including excipients, vehicle, and any special formulation characteristics (e.g., immediate-release tablet with microcrystalline cellulose, sterile aqueous solution pH 7.4).',
    `imp_code` STRING COMMENT 'Sponsor-assigned internal drug or device code uniquely identifying the investigational product across all studies (e.g., ABC-1234). Serves as the externally-known business identifier referenced in protocols, supply chain, and regulatory submissions.. Valid values are `^[A-Z0-9-]{2,30}$`',
    `impd_version` STRING COMMENT 'Version number of the current Investigational Medicinal Product Dossier (IMPD) or IND on file with the regulatory authority for this product. Tracked in Veeva Vault for regulatory submission management and amendment history.',
    `ind_submission_date` DATE COMMENT 'Date on which the IND application (FDA) or equivalent regulatory authorization application was first submitted for this investigational product. Tracked in Veeva Vault for regulatory milestone reporting.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether the investigational product is used in a blinded (masked) study design (True) or open-label (False). Drives blinding and unblinding procedures in Medidata Rave RTSM and the source system randomization configuration.',
    `is_comparator` BOOLEAN COMMENT 'Indicates whether this product record represents a comparator (active control or placebo) rather than the primary investigational product (True = comparator). Enables differentiation of IMP vs. comparator in supply chain, SDTM, and safety reporting.',
    `is_placebo` BOOLEAN COMMENT 'Indicates whether this product record represents a placebo (True) rather than an active investigational product or comparator. Used in RTSM randomization configuration, supply chain, and SDTM EX domain coding.',
    `manufacturer_name` STRING COMMENT 'Name of the pharmaceutical manufacturer or contract manufacturing organization (CMO) responsible for producing the investigational product. Referenced in the IMPD/IND CMC section and supply chain records in the source system',
    `manufacturer_site` STRING COMMENT 'Physical site or facility name and location where the investigational product is manufactured. Required for regulatory submissions (IND/IMPD) and GMP compliance tracking. Distinct from the manufacturer legal entity name.',
    `mechanism_of_action` STRING COMMENT 'Pharmacological mechanism by which the investigational product exerts its therapeutic effect (e.g., selective serotonin reuptake inhibitor, PD-1 checkpoint inhibitor). Captured in the IND/IMPD and referenced in the protocol background section.',
    `ndc_number` STRING COMMENT 'FDA-assigned National Drug Code (NDC) number for the investigational product, if applicable. Used for US regulatory submissions, pharmacy dispensing records, and drug accountability tracking. May be absent for novel compounds not yet assigned an NDC.. Valid values are `^[0-9]{4,5}-[0-9]{3,4}-[0-9]{1,2}$`',
    `notes` STRING COMMENT 'Free-text operational notes or comments regarding the investigational product record, such as special handling instructions, known stability issues, or interim regulatory communications. Captured by data management or regulatory affairs teams.',
    `packaging_description` STRING COMMENT 'Description of the primary and secondary packaging configuration for the investigational product (e.g., blister pack of 10 tablets in a carton, single-use vial 10 mL in a kit). Referenced in supply chain, pharmacy, and RTSM kit configuration.',
    `product_type` STRING COMMENT 'Classification of the investigational product by modality type (e.g., small molecule, biologic, gene therapy, medical device). Drives regulatory pathway selection, storage requirements, and supply chain handling.',
    `regulatory_approval_status` STRING COMMENT 'Current regulatory approval status of the investigational product (e.g., approved for a different indication, purely investigational, withdrawn from market). Informs regulatory strategy, labeling requirements, and comparator sourcing decisions.. Valid values are `approved|investigational|withdrawn|not_approved`',
    `retest_period_months` BIGINT COMMENT 'Period in months after which the investigational product must be retested before continued use, applicable to active pharmaceutical ingredients (APIs) and certain formulations. Distinct from shelf life; used in supply chain and QC planning.',
    `shelf_life_months` BIGINT COMMENT 'Approved shelf life of the investigational product in months from the date of manufacture, as established by stability studies and documented in the IMPD/IND. Drives expiry date calculation, supply planning, and resupply triggers in Medidata Rave RTSM.',
    `sponsor_product_code` STRING COMMENT 'Sponsors internal product or compound code used in portfolio management systems, distinct from the IMP code used in clinical operations. Enables cross-referencing between clinical development and commercial product pipelines.',
    `investigational_product_status` STRING COMMENT 'Current lifecycle status of the investigational product master record (e.g., active for ongoing studies, discontinued if development halted, superseded if replaced by a new formulation). Drives supply chain and regulatory workflow decisions.. Valid values are `active|inactive|discontinued|on_hold|superseded`',
    `storage_condition` STRING COMMENT 'Required storage conditions for the investigational product as specified in the IMPD/IND and product label (e.g., Store at 2–8°C, protected from light, Store below 25°C). Critical for supply chain cold chain management and site pharmacy compliance.',
    `storage_temperature_max_c` DECIMAL(5,2) COMMENT 'Maximum acceptable storage temperature in degrees Celsius for the investigational product. Used by supply chain and site pharmacy to configure cold chain monitoring alerts and validate storage compliance.',
    `storage_temperature_min_c` DECIMAL(5,2) COMMENT 'Minimum acceptable storage temperature in degrees Celsius for the investigational product. Used by supply chain and site pharmacy to configure cold chain monitoring alerts and validate storage compliance.',
    `strength` STRING COMMENT 'Nominal strength or concentration of the active substance in the investigational product as labeled (e.g., 10 mg, 100 mg/mL, 5 mg/kg). Captured in the IMPD/IND and referenced in supply chain, pharmacy, and SDTM EX domain.',
    `strength_unit` STRING COMMENT 'Unit of measure for the investigational product strength (e.g., mg, mg/mL, IU). Standardized per CDISC controlled terminology to enable cross-study comparisons and SDTM dataset generation.',
    `therapeutic_class` STRING COMMENT 'Therapeutic or pharmacological class of the investigational product (e.g., oncology, cardiovascular, CNS, anti-infective). Used for portfolio analytics, regulatory strategy, and study feasibility assessments.',
    `unit_of_dispensing` STRING COMMENT 'The unit in which the investigational product is dispensed to subjects at the investigational site (e.g., tablet, vial, kit, syringe). Used in RTSM dispensing records, drug accountability logs, and SDTM EX domain.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the investigational product master record was last modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11, ALCOA+ principles, and change management tracking.',
    `who_dd_code` STRING COMMENT 'WHO Drug Dictionary (WHO-DD) drug code assigned to the investigational product for standardized drug coding in adverse event reporting, SDTM datasets, and regulatory submissions. Enables cross-study signal detection in the source system',
    CONSTRAINT pk_investigational_product PRIMARY KEY(`investigational_product_id`)
) COMMENT 'Master record for the investigational medicinal product (IMP) or device used in a clinical study. Captures IMP name, INN (International Nonproprietary Name), drug code, formulation, dosage form, route of administration, strength, manufacturer, IND/IMPD';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` (
    `dosing_regimen_id` BIGINT COMMENT 'Unique surrogate identifier for the dosing regimen record within the Clinical Trials data platform. Primary key for the dosing_regimen product in the study domain.',
    `arm_id` BIGINT COMMENT 'Reference to the study arm (treatment group) to which this dosing regimen applies. A study may have multiple arms each with distinct regimens (e.g., active drug arm vs. placebo arm).',
    `investigational_product_id` BIGINT COMMENT 'Reference to the investigational product (IP) being administered under this dosing regimen. Supports traceability from regimen to supply chain and accountability logs.',
    `dose_form_codelist_term_id` BIGINT COMMENT 'the pharmaceutical dose form from CDISC CT codelist FRM (C66726)',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this dosing regimen is defined. Links the regimen to the study protocol and all associated study-level metadata.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: dosing_regimen has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `dose_unit_codelist_term_id` BIGINT COMMENT 'the dose unit from CDISC CT codelist UNIT (C71620)',
    `route_codelist_term_id` BIGINT COMMENT 'the route of administration from CDISC CT codelist ROUTE (C66729)',
    `adam_adex_mapping_notes` STRING COMMENT 'Notes describing how this dosing regimen maps to the CDISC ADaM ADEX (Analysis Dataset for Exposure) domain, including derivation rules for cumulative dose, dose intensity, and relative dose intensity calculations used in biostatistical analysis.',
    `allocation_ratio` DECIMAL(10,4) COMMENT 'The allocation ratio of the dosing regimen.',
    `blinding_type` STRING COMMENT 'Blinding level applied to this dosing regimen as defined in the study protocol (e.g., double-blind where neither subject nor investigator knows the treatment assignment). Impacts RTSM/IRT dispensing logic and unblinding procedures.. Valid values are `open-label|single-blind|double-blind|triple-blind`',
    `comparator_type` STRING COMMENT 'Indicates whether this regimen represents an active investigational product, placebo, vehicle control, sham procedure, or no-treatment arm. Critical for ITT and PP population definitions and regulatory benefit-risk assessment.. Valid values are `active|placebo|vehicle|sham|no-treatment`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this dosing regimen record was first created in the data platform, conforming to ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `dose_escalation_step` BIGINT COMMENT 'Sequential step number within the dose escalation scheme (e.g., 1, 2, 3). Enables ordering of dose cohorts in escalation studies and supports dose-response curve construction in PK/PD modeling.',
    `dose_level` DECIMAL(18,6) COMMENT 'Numeric dose amount to be administered per dosing event as specified in the protocol (e.g., 10.0, 50.5, 100.0). Represents the planned dose per administration. Used in PK/PD modeling and dose-response analysis.',
    `dose_modification_rules` STRING COMMENT 'Narrative description of protocol-defined rules for dose modifications, reductions, interruptions, or discontinuations based on toxicity or adverse events (e.g., Reduce by 25% for Grade 2 AE; discontinue for Grade 3 SAE).',
    `dose_reduction_levels` BIGINT COMMENT 'Number of permitted dose reduction levels defined in the protocol (e.g., 2 levels: Level -1 and Level -2). Used in oncology studies to manage toxicity while maintaining therapeutic benefit. Supports safety dose-response analysis.',
    `dosing_frequency` STRING COMMENT 'Frequency of dose administration using standard clinical abbreviations (e.g., QD = once daily, BID = twice daily, QW = once weekly, Q2W = every two weeks). Conforms to CDISC SDTM EX.EXDOSFRQ controlled terminology.',
    `dosing_interval_days` DECIMAL(10,2) COMMENT 'Numeric interval between doses expressed in days (e.g., 1.0 for QD, 0.5 for BID, 7.0 for QW). Provides machine-readable precision for automated scheduling in RTSM/IRT systems and PK modeling when frequency alone is insufficient.',
    `effective_end_date` DATE COMMENT 'Date on which this dosing regimen version ceased to be effective (e.g., superseded by an amendment). Null for currently active regimens. Supports temporal versioning and historical audit of regimen changes.',
    `effective_start_date` DATE COMMENT 'Date from which this dosing regimen version became effective in the study, typically aligned with protocol approval or amendment approval date. Supports temporal versioning of regimen changes across the study lifecycle.',
    `escalation_scheme_description` STRING COMMENT 'Narrative description of the dose escalation scheme applied in this regimen (e.g., 3+3 design, Accelerated Titration, BOIN design, mTPI-2). Populated only when is_dose_escalation = True. Supports Phase I safety and PK/PD analysis.',
    `infusion_duration_minutes` DECIMAL(10,2) COMMENT 'Duration of intravenous or subcutaneous infusion in minutes, applicable when dosing_route is INTRAVENOUS or similar. Null for non-infusion routes. Critical for PK modeling of IV drug exposure and site nursing procedure planning.',
    `is_dose_escalation` BOOLEAN COMMENT 'Indicates whether this regimen is part of a dose-escalation scheme (True) or a fixed-dose regimen (False). When True, the escalation_scheme_description and mtd_flag fields become operationally relevant. Common in Phase I oncology studies.',
    `is_mtd` BOOLEAN COMMENT 'Indicates whether this dose level has been designated as the Maximum Tolerated Dose (MTD) by the Data Safety Monitoring Board (DSMB) or study team (True = MTD confirmed). Critical for Phase I dose-finding studies and regulatory submissions.',
    `loading_dose_duration_days` BIGINT COMMENT 'Number of days the loading dose is administered before transitioning to the maintenance dose. Null if no loading dose is defined. Supports PK/PD modeling of drug accumulation and steady-state calculations.',
    `loading_dose_level` DECIMAL(18,6) COMMENT 'Initial higher dose administered to rapidly achieve therapeutic drug concentrations before transitioning to the maintenance dose level. Expressed in the same unit as dose_unit. Null if no loading dose is specified in the protocol.',
    `maximum_dose_level` DECIMAL(18,6) COMMENT 'Maximum allowable dose level for this regimen as defined in the protocol (e.g., dose cap for safety). Expressed in the same unit as dose_unit. Used in dose modification rules and safety monitoring.',
    `pd_assessment_required` BOOLEAN COMMENT 'Indicates whether pharmacodynamic (PD) biomarker assessments are required for subjects on this dosing regimen (True = PD assessments mandated per protocol). Supports PK/PD modeling and dose-response analysis.',
    `pk_sampling_required` BOOLEAN COMMENT 'Indicates whether pharmacokinetic (PK) blood sampling is required for subjects on this dosing regimen (True = PK sampling mandated per protocol). Drives PK visit scheduling, sample collection logistics, and DMPK analysis planning.',
    `planned_duration_days` BIGINT COMMENT 'Total planned duration of the dosing regimen expressed in days as specified in the study protocol (e.g., 84 days for a 12-week treatment period). Used for treatment period planning, supply forecasting, and CDISC SDTM EX.EXENDY derivation.',
    `protocol_version` STRING COMMENT 'Version of the study protocol under which this dosing regimen was defined or last amended (e.g., v1.0, v2.1). Enables traceability of regimen changes across protocol amendments. Supports TMF/eTMF document management and regulatory audit trails.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `randomization_ratio` DECIMAL(18,2) COMMENT 'Allocation ratio for randomization to this arm/regimen expressed as a colon-separated ratio (e.g., 1:1, 2:1, 1:1:1). Used in RTSM/IRT configuration and statistical analysis plan (the source system) for sample size and power calculations.',
    `regimen_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this dosing regimen within the study protocol (e.g., REG-001, ARM-A-DOSE-1). Used in protocol documents, eCRFs, and CDISC SDTM EX submissions.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `regimen_name` STRING COMMENT 'Human-readable name of the dosing regimen as defined in the study protocol (e.g., Low Dose QD, High Dose BID, Placebo TIW). Used in protocol documents, the source system, and CSR narratives.',
    `regimen_status` STRING COMMENT 'Current lifecycle status of the dosing regimen within the study. draft indicates protocol development; active indicates currently administered; suspended indicates temporarily halted (e.g., pending safety review); discontinued indicates. Valid values are `draft|active|suspended|discontinued|completed`',
    `sdtm_ex_mapping_notes` STRING COMMENT 'Notes describing how this dosing regimen maps to the CDISC SDTM EX (Exposure) domain variables, including any derivation logic, controlled terminology mappings, or special handling required for regulatory submission datasets.',
    `starting_dose_level` DECIMAL(18,6) COMMENT 'Initial dose amount at the start of the regimen, particularly relevant for titration or escalation regimens where the dose changes over time. Expressed in the same unit as dose_unit. Supports PK/PD baseline modeling.',
    `treatment_period_label` STRING COMMENT 'Label identifying the treatment period within the study to which this regimen applies (e.g., Period 1, Run-In, Maintenance, Extension). Supports crossover and multi-period study designs. Maps to CDISC SDTM EX.EPOCH.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this dosing regimen record was last modified in the data platform, conforming to ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking, audit trail requirements under 21 CFR Part 11, and ALCOA+ data integrity principles.',
    `washout_period_days` BIGINT COMMENT 'Duration of the washout period in days required between treatment periods in crossover studies, or between prior therapy and study treatment. Null for parallel-group designs. Supports PK carryover analysis and crossover study scheduling.',
    CONSTRAINT pk_dosing_regimen PRIMARY KEY(`dosing_regimen_id`)
) COMMENT 'Defines the dosing regimen for each investigational product within a study arm. Records regimen name, dose level, dose unit, dosing frequency, dosing route, dosing duration, dose escalation scheme (for dose-escalation studies), dose modification rules';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`objective` (
    `objective_id` BIGINT COMMENT 'Unique surrogate identifier for a study objective record in the clinical trial data platform. Primary key for the study_objective entity.',
    `primary_endpoint_id` BIGINT COMMENT 'Reference to the primary endpoint directly associated with this objective. Establishes the objective-to-endpoint traceability chain required by the the source system submissions. Nullable for objectives that map to multiple endpoints.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, objectives belong to study_design',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this objective belongs. Links the objective to its governing protocol and study master record.',
    `adam_dataset_reference` STRING COMMENT 'CDISC ADaM dataset name(s) used for the primary analysis supporting this objective (e.g., ADEFF, ADTTE, ADAE). Provides direct linkage from objective to analysis-ready datasets in SAS Drug Development.',
    `alpha_level` DECIMAL(6,4) COMMENT 'Pre-specified Type I error rate (significance level) allocated to this objective in the the source system. Typically 0.05 for primary objectives or a fraction thereof when multiplicity adjustments are applied.',
    `approved_date` DATE COMMENT 'Date on which this objective (as part of the protocol or amendment) received formal approval from the sponsor and/or IRB/IEC. Marks the transition from draft to active status and is required for regulatory audit trails.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this study objective record was first created in the data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `csr_section_reference` STRING COMMENT 'Section number within the Clinical Study Report (CSR) where results for this objective are reported. Provides traceability from protocol objective through analysis to regulatory submission document per ICH E3 CSR structure.',
    `ctd_section_reference` STRING COMMENT 'Module and section reference within the Common Technical Document (CTD) / electronic CTD (eCTD) where this objectives results contribute to the regulatory dossier (e.g., Module 5.3.5.1). Supports regulatory submission traceability.',
    `dsmb_reportable_flag` BOOLEAN COMMENT 'Indicates whether interim results for this objective are to be reviewed by the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) during planned interim analyses. Drives interim analysis planning and unblinding procedures.',
    `effective_end_date` DATE COMMENT 'Date on which this version of the objective ceased to be effective, typically due to a protocol amendment superseding it. Null for currently active objectives. Supports temporal versioning of protocol objectives.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the objective became effective in the approved protocol. For original protocol objectives, this is the initial protocol approval date. For amended objectives, this is the amendment approval date.',
    `hypothesis_type` STRING COMMENT 'Statistical hypothesis framework associated with this objective. Superiority objectives aim to demonstrate a treatment effect greater than control; non-inferiority objectives aim to show the treatment is not worse by a defined margin; equivalence. Valid values are `superiority|non-inferiority|equivalence|descriptive`',
    `intercurrent_event_strategy` STRING COMMENT 'ICH E9(R1) estimand attribute specifying the strategy for handling intercurrent events (post-randomization events that affect interpretation of the outcome) for this objective.. Valid values are `while_on_treatment|hypothetical|composite|principal_stratum|treatment_policy`',
    `irb_iec_review_required` BOOLEAN COMMENT 'Indicates whether a change to this objective requires IRB/IEC review and approval (e.g., substantial protocol amendment). Drives the amendment workflow and site notification process.',
    `last_amended_in_amendment_number` STRING COMMENT 'Protocol amendment number in which this objective was most recently modified. Null if the objective has never been amended. Used to track the amendment history of each objective for regulatory submissions.',
    `multiplicity_adjustment_required` BOOLEAN COMMENT 'Indicates whether statistical multiplicity adjustment (e.g., Bonferroni, Hochberg, hierarchical testing) is required for this objective due to multiple comparisons. Informs the the source system strategy.',
    `notes` STRING COMMENT 'Free-text field for additional context, clarifications, or internal commentary related to this objective that does not fit structured fields. Used by data managers and biostatisticians during protocol development and the source system',
    `number` STRING COMMENT 'Structured alphanumeric identifier for the objective within the protocol (e.g., P-1 for Primary Objective 1, S-2 for Secondary Objective 2). Used for cross-referencing in the Statistical Analysis Plan (the source system) and Clinical Study Report (CSR).. Valid values are `^[A-Z0-9]{1,2}-[0-9]{1,3}$`',
    `population_description` STRING COMMENT 'Description of the analysis population to which this objective applies (e.g., Intent-to-Treat (ITT), Per Protocol (PP), Safety Population). Aligns with the estimand population attribute per ICH E9(R1).',
    `population_type` STRING COMMENT 'Standardized code for the analysis population associated with this objective. Intent-to-Treat (ITT), modified ITT (mITT), Per Protocol (PP), Safety, Pharmacokinetic (PK), or Pharmacodynamic (PD) population.. Valid values are `ITT|mITT|PP|safety|PK|PD`',
    `protocol_section_reference` STRING COMMENT 'Section number within the study protocol document where this objective is formally stated (e.g., Section 2.1, Section 3.2). Enables direct navigation to the source text in the protocol and eTMF.',
    `regulatory_commitment_flag` BOOLEAN COMMENT 'Indicates whether this objective is a formal regulatory commitment (e.g., a post-marketing commitment to FDA or EMA, or a condition of approval). Regulatory commitment objectives require heightened change control and reporting.',
    `sap_section_reference` STRING COMMENT 'Section number or identifier within the Statistical Analysis Plan (the source system) that addresses the analysis corresponding to this objective. Provides direct traceability from protocol objective to statistical methodology, as required for regulatory',
    `scientific_rationale` STRING COMMENT 'Narrative justification for why this objective is scientifically important and how it contributes to the overall study goals. Supports regulatory review, protocol synopsis, and investigator brochure alignment.',
    `sdtm_domain_reference` STRING COMMENT 'CDISC SDTM domain(s) that contain the data supporting this objective (e.g., ADAE, ADEFF, ADTTE). Enables automated linkage between protocol objectives and SDTM/ADaM datasets in SAS Drug Development.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this objective within its objective type group (e.g., first primary objective = 1, second primary objective = 2). Governs display order in the protocol, the source system, and CSR sections.',
    `short_title` STRING COMMENT 'Concise human-readable label for the objective used in dashboards, reports, and CTMS displays where the full objective text is too lengthy. Typically 10–15 words summarizing the scientific intent.',
    `source_system_record_code` STRING COMMENT 'Native identifier of this objective record in the originating operational system (e.g., the source system objective GUID, Veeva Vault document section ID). Enables back-referencing and reconciliation with the system of record.',
    `objective_status` STRING COMMENT 'Current lifecycle state of the study objective. Draft objectives are under authoring review; active objectives are in the approved protocol; amended objectives have been modified by a protocol amendment; superseded objectives have been replaced; retired. Valid values are `draft|active|amended|superseded|retired`',
    `summary_measure` STRING COMMENT 'Statistical summary measure used to quantify the treatment effect for this objective (e.g., difference in means, odds ratio, hazard ratio, response rate difference). Corresponds to the population-level summary attribute of the ICH E9(R1) estimand.',
    `testing_hierarchy_level` BIGINT COMMENT 'Numeric level in the hierarchical testing procedure for this objective. Level 1 is tested first; subsequent levels are tested only if the preceding level achieves statistical significance.',
    `text` STRING COMMENT 'Full verbatim text of the study objective as stated in the approved protocol. This is the authoritative scientific statement of what the study aims to demonstrate or evaluate, used verbatim in regulatory submissions and the CSR.',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication to which this objective is aligned (e.g., Oncology, Cardiology, Neurology). Supports cross-study analytics and portfolio-level objective benchmarking.',
    `objective_type` STRING COMMENT 'Classification of the study objective by its scientific hierarchy and regulatory weight. Primary objectives drive the primary endpoint and sample size calculation; secondary objectives provide supportive evidence; exploratory objectives generate. Valid values are `primary|secondary|exploratory|safety|pharmacokinetic|pharmacodynamic`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this study objective record in the data platform. Required for change tracking, data lineage, and compliance with 21 CFR Part 11 audit trail requirements.',
    `variable_description` STRING COMMENT 'Description of the variable (outcome measure) used to address this objective, as defined in the ICH E9(R1) estimand framework. Specifies what is measured on each subject to evaluate the treatment effect.',
    CONSTRAINT pk_objective PRIMARY KEY(`objective_id`)
) COMMENT 'Formally documents the primary, secondary, and exploratory objectives of a clinical study as stated in the protocol. Captures objective number, objective type (primary, secondary, exploratory), objective text, associated endpoint references, ICH E9(R1)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` (
    `pk_sampling_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for each PK/PD sampling schedule record in the clinical study. Primary key for the pk_sampling_schedule data product.',
    `arm_id` BIGINT COMMENT 'Reference to the study arm or treatment group for which this sampling schedule applies. Enables arm-specific PK sampling designs.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Reference identifier for the validated bioanalytical method used to quantify the analyte in the collected sample. Links to the bioanalytical method validation report per FDA/EMA guidance.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: pk_sampling_schedule has epoch as a STRING but no FK to study_epoch. PK/PD sampling timepoints are associated with specific study epochs — this FK formalizes that structural relationship.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this PK/PD sampling schedule is defined. Links the sampling schedule to the parent study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Reference to the protocol amendment that introduced or last modified this sampling schedule entry. Supports audit trail and regulatory submission traceability.',
    `study_visit_schedule_id` BIGINT COMMENT 'Reference to the scheduled study visit during which this PK/PD sample is to be collected. Associates the sampling timepoint with the visit schedule.',
    `analyte_code` STRING COMMENT 'Standardized code for the analyte to be measured, aligned with WHO Drug Dictionary (WHO-DD) or internal compound coding. Maps to CDISC SDTM PC.PCTESTCD.. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `analyte_name` STRING COMMENT 'Name of the drug compound, metabolite, or biomarker to be measured in the collected sample (e.g., parent drug, active metabolite, total drug). Maps to CDISC SDTM PC.PCTEST.',
    `backup_sample_volume_ml` DECIMAL(8,3) COMMENT 'Additional volume of biological sample to be collected as a backup or reserve aliquot, expressed in millilitres (mL). Supports re-analysis and incurred sample reanalysis (ISR) requirements.',
    `collection_tube_type` STRING COMMENT 'Type of collection tube or container required for sample collection (e.g., K2-EDTA, Li-Heparin, SST, urine cup). Critical for sample integrity and bioanalytical method compatibility.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this PK/PD sampling schedule record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `cycle_number` BIGINT COMMENT 'Treatment cycle number during which this PK/PD sample is collected, applicable for oncology and multi-cycle dosing studies. Null for single-dose or non-cyclic studies.',
    `day_in_cycle` BIGINT COMMENT 'Study day within the treatment cycle on which this PK/PD sample is to be collected. Used in conjunction with cycle_number for multi-cycle dosing regimens.',
    `dose_number` BIGINT COMMENT 'Sequential dose number relative to which this PK sample is collected (e.g., Dose 1, Dose 7 for steady-state). Supports single-dose vs. multiple-dose PK profiling.',
    `edc_field_oid` STRING COMMENT 'Object Identifier (OID) of the corresponding field in the EDC system (Medidata Rave eCRF) for this PK sampling timepoint. Enables direct mapping between protocol schedule and EDC data collection form.',
    `effective_end_date` DATE COMMENT 'Date on which this PK/PD sampling schedule entry ceases to be applicable (e.g., superseded by protocol amendment). Null if currently active.',
    `effective_start_date` DATE COMMENT 'Date from which this PK/PD sampling schedule entry is effective and applicable for subject data collection. Supports protocol amendment versioning and schedule lifecycle management.',
    `fasting_required` BOOLEAN COMMENT 'Indicates whether the subject must be in a fasted state prior to sample collection at this timepoint. Relevant for food-effect PK studies and protocol compliance.',
    `max_storage_duration_hours` BIGINT COMMENT 'Maximum allowable duration in hours that the sample may be stored at the specified storage temperature before shipment to the bioanalytical laboratory. Derived from bench-top and freeze-thaw stability data.',
    `nominal_timepoint_label` STRING COMMENT 'Descriptive label for the nominal PK sampling timepoint relative to dose administration (e.g., Pre-dose, 0.5h post-dose, 1h post-dose, 24h post-dose). Maps to CDISC SDTM PC.PCTPT.',
    `nominal_timepoint_unit` STRING COMMENT 'Unit of measure for the nominal timepoint value (e.g., hours, minutes, days). Maps to CDISC SDTM PC.PCTPTREF unit context.. Valid values are `hours|minutes|days|weeks`',
    `nominal_timepoint_value` DECIMAL(10,4) COMMENT 'Numeric value of the nominal sampling timepoint relative to dose administration. Used for PK modeling and CDISC SDTM PC.PCTPTNUM mapping. Expressed in the unit defined by nominal_timepoint_unit.',
    `number_of_aliquots` BIGINT COMMENT 'Number of aliquots into which the collected sample must be divided for analysis, backup, and archival purposes. Drives sample labelling and supply requirements.',
    `optional_sample` BOOLEAN COMMENT 'Indicates whether collection of this sample is optional (e.g., exploratory biomarker, sub-study) or mandatory per the study protocol. Affects protocol deviation assessment.',
    `pre_dose_sample` BOOLEAN COMMENT 'Indicates whether this sampling timepoint is a pre-dose (trough) sample collected before drug administration. Used to assess baseline concentrations and trough levels.',
    `protocol_version` STRING COMMENT 'Version of the study protocol under which this PK/PD sampling schedule was defined or last amended. Enables traceability of schedule changes across protocol amendments.. Valid values are `^v?[0-9]+.[0-9]+(.[0-9]+)?$`',
    `required_sample_volume_ml` DECIMAL(8,3) COMMENT 'Volume of biological sample required for bioanalytical analysis, expressed in millilitres (mL). Used for supply planning, patient burden assessment, and protocol feasibility.',
    `sample_type` STRING COMMENT 'Biological matrix type to be collected for PK/PD analysis (e.g., blood, plasma, serum, urine, tissue). Maps to CDISC SDTM PC.PCSPEC. [ENUM-REF-CANDIDATE: blood|plasma|serum|urine|cerebrospinal_fluid|tissue|saliva|feces|dried_blood_spot|other — promote to',
    `sampling_category` STRING COMMENT 'Classification of the sampling purpose: Pharmacokinetic (PK), Pharmacodynamic (PD), combined PK/PD, biomarker, immunogenicity, or safety assessment. Drives CDISC domain assignment (PC for PK, PP for PD).. Valid values are `PK|PD|PK_PD|biomarker|immunogenicity|safety`',
    `schedule_code` STRING COMMENT 'Unique alphanumeric code identifying this PK/PD sampling schedule entry within the study protocol. Used as the externally-known business identifier in CTMS and EDC systems such as Medidata Rave.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `schedule_name` STRING COMMENT 'Human-readable name or label for this sampling schedule entry (e.g., Pre-dose Day 1, 2h Post-dose Cycle 2). Used in protocol documents and EDC eCRF annotations.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of this PK/PD sampling schedule record. Tracks whether the schedule is in draft protocol design, active for data collection, amended via protocol amendment, retired, or cancelled.. Valid values are `draft|active|amended|retired|cancelled`',
    `sdtm_domain` STRING COMMENT 'CDISC Study Data Tabulation Model (SDTM) domain to which this sampling record maps (e.g., PC for Pharmacokinetics Concentrations, PP for Pharmacokinetic Parameters). Required for regulatory submission datasets.. Valid values are `PC|PP|LB|EG|VS`',
    `sdtm_pctptnum` DECIMAL(10,4) COMMENT 'Numeric representation of the planned timepoint as defined in CDISC SDTM PC.PCTPTNUM. Used for sorting and PK modeling in SAS Drug Development and ADaM datasets.',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number defining the order of this sampling timepoint within the visit or study day PK profile. Used for display ordering in eCRF and SDTM datasets.',
    `shipping_condition` STRING COMMENT 'Required temperature or condition for shipping the sample from the clinical site to the central or bioanalytical laboratory (e.g., dry ice, refrigerated, ambient).. Valid values are `ambient|refrigerated|dry_ice|liquid_nitrogen|frozen`',
    `sparse_sampling` BOOLEAN COMMENT 'Indicates whether this timepoint is part of a sparse (population PK) sampling design rather than a full intensive PK profile. Drives population PK modeling strategy.',
    `steady_state_sample` BOOLEAN COMMENT 'Indicates whether this sampling timepoint is intended to characterize drug concentrations at pharmacokinetic steady state. Relevant for multiple-dose PK studies.',
    `storage_temperature` STRING COMMENT 'Required storage temperature condition for the collected sample prior to shipment to the bioanalytical laboratory (e.g., ambient, refrigerated 2-8°C, frozen -20°C, frozen -70°C). Critical for sample stability.. Valid values are `ambient|refrigerated_2_8C|frozen_minus20C|frozen_minus70C|frozen_minus80C|dry_ice`',
    `timepoint_reference` STRING COMMENT 'The reference event from which the nominal timepoint is measured (e.g., first dose, previous dose, start of infusion, end of infusion). Maps to CDISC SDTM PC.PCTPTREF.. Valid values are `first_dose|previous_dose|start_of_infusion|end_of_infusion|study_day_1`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this PK/PD sampling schedule record was last modified. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `window_lower_bound` DECIMAL(10,4) COMMENT 'Allowable lower deviation from the nominal timepoint for sample collection (expressed as a negative or zero offset in the same unit as nominal_timepoint_unit). Defines the acceptable collection window per protocol.',
    `window_unit` STRING COMMENT 'Unit of measure for the sampling window lower and upper bounds (e.g., minutes, hours, days).. Valid values are `hours|minutes|days`',
    `window_upper_bound` DECIMAL(10,4) COMMENT 'Allowable upper deviation from the nominal timepoint for sample collection (expressed as a positive offset in the same unit as nominal_timepoint_unit). Defines the acceptable collection window per protocol.',
    CONSTRAINT pk_pk_sampling_schedule PRIMARY KEY(`pk_sampling_schedule_id`)
) COMMENT 'Defines the pharmacokinetic (PK) and pharmacodynamic (PD) blood/urine/tissue sampling schedule for a clinical study. Records sample type, nominal sampling timepoint (pre-dose, 0.5h, 1h, 2h, 4h, 8h, 24h post-dose, etc.), sampling window, visit association';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` (
    `amendment_site_implementation_id` BIGINT COMMENT 'Primary key for the amendment_site_implementation association',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — amendment site implementation should reference the study',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to the protocol amendment being implemented at this site.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site at which this amendment is being implemented.',
    `edc_configuration_updated_flag` BOOLEAN COMMENT 'Indicates whether the sites Electronic Data Capture system has been updated to reflect the changes introduced by this amendment (e.g., new CRF fields, modified visit schedules, updated eligibility criteria).',
    `implementation_date` DATE COMMENT 'Date on which the site confirmed full operational implementation of the amendment, including staff training, EDC updates, and any required reconsent. Marks closure of the implementation workflow for this site.',
    `implementation_deadline` DATE COMMENT 'Sponsor or regulatory authority mandated deadline by which this site must complete implementation of the amendment. Used for escalation and compliance monitoring.',
    `implementation_status` STRING COMMENT 'Current lifecycle status of the amendment implementation at this specific site. Drives operational follow-up by CRAs and clinical operations managers.',
    `notification_date` DATE COMMENT 'Date on which the site (principal investigator and study coordinator) was formally notified of this protocol amendment. Regulatory timelines for implementation are calculated from this date.',
    `reconsent_completed_flag` BOOLEAN COMMENT 'Indicates whether all currently enrolled subjects at this site who are impacted by the amendment have provided updated informed consent. Applicable only when the parent amendment has reconsent_required_flag = true.',
    `sites_implemented_count` BIGINT COMMENT 'Number of clinical investigative sites that have confirmed full implementation of the amendment, including staff training and updated procedures. Supports monitoring and close-out tracking.',
    `sites_notified_count` BIGINT COMMENT 'Number of clinical investigative sites that have been formally notified of this amendment. Used to track notification completeness against total active site count for the study.',
    CONSTRAINT pk_amendment_site_implementation PRIMARY KEY(`amendment_site_implementation_id`)
) COMMENT 'This association product represents the Event between study_protocol_amendment and study_site. It captures the formal process by which each protocol amendment is communicated to, acknowledged by, and operationally implemented at a specific investigational';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` (
    `ip_site_accountability_id` BIGINT COMMENT 'Primary key for the ip_site_accountability association',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to the investigational product master record for which site-level accountability is being tracked.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site at which the IMP is stored, dispensed, and accounted for.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — IP site accountability should reference the study',
    `accountability_log_reference` STRING COMMENT 'Reference identifier linking to the drug accountability log maintained at the site for this IMP. Required by GCP to reconcile quantities received, dispensed, returned, and destroyed.',
    `authorization_status` STRING COMMENT 'Overall lifecycle status of this IMP-site accountability record, reflecting whether the site is currently active for this product across both storage and dispensing dimensions.',
    `dispensing_authorization_status` STRING COMMENT 'Current authorization status for the site to dispense this investigational product to trial subjects. Distinct from storage authorization — a site may store but not yet be authorized to dispense.',
    `storage_authorization_date` DATE COMMENT 'Date on which the investigational site was formally authorized to store this investigational product. Belongs to the IMP-site relationship, not to either master record alone.',
    `storage_compliance_status` STRING COMMENT 'Current GCP storage compliance status for this IMP at this specific site. Reflects whether the site is meeting required storage conditions (e.g., temperature range) for this product.',
    `temperature_excursion_count` BIGINT COMMENT 'Cumulative count of documented temperature excursions recorded for this IMP at this site. Belongs to the IMP-site relationship as it reflects the storage history of a specific product at a specific location.',
    CONSTRAINT pk_ip_site_accountability PRIMARY KEY(`ip_site_accountability_id`)
) COMMENT 'This association product represents the regulatory and operational contract between an investigational product and an investigational site. It captures the per-site authorization, storage compliance, dispensing status, and drug accountability obligations';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`country_submission` (
    `country_submission_id` BIGINT COMMENT 'Primary key for the country_submission association',
    `country_id` BIGINT COMMENT 'Foreign key linking to the study_country record representing the country in which this regulatory filing is applicable.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — country_submission links a submission to a country but lacks study context',
    `submission_id` BIGINT COMMENT 'Foreign key linking to the regulatory submission record that was filed with or applies to this country.',
    `agency_acknowledgement_date` DATE COMMENT 'The date on which the national regulatory authority for this country officially acknowledged receipt of this submission. Distinct from the global agency_receipt_date on the submission record when acknowledgement timing varies by country.',
    `country_specific_sequence_number` STRING COMMENT 'The sequence number assigned by the national regulatory authority for this specific countrys dossier, distinct from the global eCTD sequence number on the submission record. Belongs to the country-submission pairing, not to either entity alone.',
    `filing_date` DATE COMMENT 'The date on which this submission was filed with or transmitted to the specific national regulatory authority for this country. May differ from the global submission_date on the submission record when a multi-country package is filed on a rolling basis.',
    `country_submission_status` STRING COMMENT 'Current lifecycle status of this submission as it applies to this specific countrys regulatory authority. A single submission may be approved in one country and still under review in another.',
    `submission_type` STRING COMMENT 'Classification of this submission event as it applies to this specific country — e.g., initial CTA filing, substantial amendment, annual safety update, or response to a national authority query. Sourced from detection phase relationship data.',
    CONSTRAINT pk_country_submission PRIMARY KEY(`country_submission_id`)
) COMMENT 'This association product represents the regulatory filing event between a study_country and a regulatory submission. It captures the operational record of a specific submission being filed with or applicable to a specific countrys regulatory authority';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`product_designation` (
    `product_designation_id` BIGINT COMMENT 'Primary key for the product_designation association',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to the investigational medicinal product that holds this special regulatory designation.',
    `special_designation_id` BIGINT COMMENT 'Foreign key linking to the special regulatory designation record granted to this investigational product.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — product designation should reference the study context',
    `applicable_study_phase` STRING COMMENT 'The clinical development phase of the investigational product at the time this designation was granted or at which the designation is applicable. Belongs to the association because the same product may receive different designations at different',
    `designation_type` STRING COMMENT 'Classification of the special regulatory designation as it applies to this specific investigational product pairing. Sourced from detection phase relationship data. Captures which type of expedited pathway applies in this product-designation context.',
    `grant_date` DATE COMMENT 'Calendar date on which the health authority officially granted this specific designation to this specific investigational product. Belongs to the association because the same product may receive the same designation type at different dates for different',
    `indication_scope` STRING COMMENT 'The specific disease, condition, or patient population for which this designation applies to this investigational product. Belongs to the association because the same product may hold different designations for different indications, and the same',
    CONSTRAINT pk_product_designation PRIMARY KEY(`product_designation_id`)
) COMMENT 'This association product represents the regulatory designation grant relationship between an investigational_product and a special_designation. It captures the operational record of which special regulatory designation applies to which investigational';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` (
    `intercurrent_event_id` BIGINT COMMENT 'Primary key.',
    `endpoint_id` BIGINT COMMENT 'add column endpoint_id (BIGINT) with FK to study.endpoint.endpoint_id — intercurrent events in the estimand framework should reference the endpoint they affect',
    `estimand_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — intercurrent_event should link to study_design for USDM alignment',
    `study_id` BIGINT COMMENT 'The study this intercurrent event belongs to.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `event_description` STRING COMMENT 'Description of the intercurrent event that may affect interpretation of the estimand. Implements USDM IntercurrentEvent.description.',
    `event_name` STRING COMMENT 'Name of the intercurrent event.',
    `handling_strategy` STRING COMMENT 'Strategy for handling the intercurrent event (e.g. treatment policy, hypothetical).',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_intercurrent_event PRIMARY KEY(`intercurrent_event_id`)
) COMMENT 'USDM/ICH E9(R1) intercurrent event occurring post-treatment that affects interpretation of the estimand.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`cohort` (
    `cohort_id` BIGINT COMMENT 'BIGINT',
    `population_id` BIGINT COMMENT 'Parent population of this cohort.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, cohort is defined within study_design',
    `study_id` BIGINT COMMENT 'BIGINT',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `cohort_description` STRING COMMENT 'STRING',
    `cohort_name` STRING COMMENT 'Name of the cohort.',
    `planned_enrollment_number` BIGINT COMMENT 'Planned enrollment for the cohort.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_cohort PRIMARY KEY(`cohort_id`)
) COMMENT 'USDM StudyCohort: a subset of the study population defined by shared characteristics.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`population` (
    `population_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, population is defined within study_design',
    `study_id` BIGINT COMMENT 'BIGINT',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `population_description` STRING COMMENT 'STRING',
    `includes_healthy_subjects` BOOLEAN COMMENT 'Whether healthy subjects are included.',
    `population_name` STRING COMMENT 'Name of the study population.',
    `planned_completion_number` BIGINT COMMENT 'Planned number of completers.',
    `planned_enrollment_number` BIGINT COMMENT 'Planned number of participants.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_population PRIMARY KEY(`population_id`)
) COMMENT 'USDM StudyDesignPopulation: the overall planned study population for a study design.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_intervention` (
    `study_intervention_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, study_intervention belongs to study_design',
    `study_id` BIGINT COMMENT 'BIGINT',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `dose_form` STRING COMMENT 'Dose form (CDISC CT governed).',
    `intervention_description` STRING COMMENT 'STRING',
    `intervention_name` STRING COMMENT 'Name of the intervention.',
    `intervention_type` STRING COMMENT 'STRING',
    `role` STRING COMMENT 'Role of the intervention.',
    `route_of_administration` STRING COMMENT 'Route of administration (CDISC CT governed).',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_study_intervention PRIMARY KEY(`study_intervention_id`)
) COMMENT 'USDM StudyIntervention: a planned intervention administered to study participants.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_cell` (
    `study_cell_id` BIGINT COMMENT 'BIGINT',
    `arm_id` BIGINT COMMENT 'BIGINT',
    `epoch_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'Reference to study.study_design.study_design_id.',
    `study_id` BIGINT COMMENT 'description',
    `cell_identifier` STRING COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_study_cell PRIMARY KEY(`study_cell_id`)
) COMMENT 'USDM StudyCell concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` (
    `schedule_timeline_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'Reference to study.study_design.study_design_id.',
    `study_id` BIGINT COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `is_main_timeline` BOOLEAN COMMENT 'Indicator for is main timeline on the schedule timeline.',
    `timeline_description` STRING COMMENT 'description',
    `timeline_name` STRING COMMENT 'The timeline name of the schedule timeline.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_schedule_timeline PRIMARY KEY(`schedule_timeline_id`)
) COMMENT 'USDM ScheduleTimeline concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_element` (
    `study_element_id` BIGINT COMMENT 'BIGINT',
    `epoch_id` BIGINT COMMENT 'add column epoch_id (BIGINT) with FK to study.epoch.epoch_id — study_element references study_cell and study_design but should also directly reference the epoch for CDISC Study Design Model compliance',
    `study_cell_id` BIGINT COMMENT 'Reference to study.study_cell.study_cell_id.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, study_element belongs to study_design',
    `study_id` BIGINT COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `element_description` STRING COMMENT 'STRING',
    `element_name` STRING COMMENT 'The element name of the study element.',
    `element_type` STRING COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_study_element PRIMARY KEY(`study_element_id`)
) COMMENT 'USDM StudyElement concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`encounter` (
    `encounter_id` BIGINT COMMENT 'BIGINT',
    `schedule_timeline_id` BIGINT COMMENT 'Reference to study.schedule_timeline.schedule_timeline_id.',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — per USDM, encounters belong to study_design',
    `study_id` BIGINT COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `encounter_description` STRING COMMENT 'description',
    `encounter_name` STRING COMMENT 'The encounter name of the encounter.',
    `encounter_type` STRING COMMENT 'STRING',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_encounter PRIMARY KEY(`encounter_id`)
) COMMENT 'USDM Encounter concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_identifier` (
    `study_identifier_id` BIGINT COMMENT 'BIGINT',
    `issuing_organization_id` BIGINT COMMENT 'add column issuing_organization_id (BIGINT) with FK to sponsor.organization.organization_id — per user vibes instruction 1, study_identifier must include issuing organization for registry identifiers',
    `study_id` BIGINT COMMENT 'description',
    `study_version_id` BIGINT COMMENT 'Reference to study.study_version.study_version_id.',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `identifier_scheme` STRING COMMENT 'description',
    `identifier_type` STRING COMMENT 'The identifier type of the study identifier.',
    `identifier_value` DECIMAL(18,2) COMMENT 'STRING',
    `issuing_organization` STRING COMMENT 'STRING',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_attribute_scheme` STRING COMMENT 'description',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_study_identifier PRIMARY KEY(`study_identifier_id`)
) COMMENT 'USDM StudyIdentifier concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` (
    `biomedical_concept_id` BIGINT COMMENT 'BIGINT',
    `code_system_version_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'Reference to study.study_design.study_design_id.',
    `study_id` BIGINT COMMENT 'description',
    `concept_code` STRING COMMENT 'description',
    `concept_description` STRING COMMENT 'description',
    `concept_name` STRING COMMENT 'The concept name of the biomedical concept.',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `reference_code` STRING COMMENT 'The reference code of the biomedical concept.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_biomedical_concept PRIMARY KEY(`biomedical_concept_id`)
) COMMENT 'USDM BiomedicalConcept concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`governance_date` (
    `governance_date_id` BIGINT COMMENT 'BIGINT',
    `date_type_codelist_term_id` BIGINT COMMENT 'add column date_type_codelist_term_id (BIGINT) with FK to datamanagement.codelist_term.codelist_term_id — governance_date types should reference controlled terminology',
    `study_id` BIGINT COMMENT 'description',
    `study_version_id` BIGINT COMMENT 'Reference to study.study_version.study_version_id.',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `date_type` STRING COMMENT 'STRING',
    `date_value` DATE COMMENT 'DATE',
    `governance_date_description` STRING COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_governance_date PRIMARY KEY(`governance_date_id`)
) COMMENT 'USDM GovernanceDate concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_design` (
    `study_design_id` BIGINT COMMENT 'BIGINT',
    `design_type_codelist_term_id` BIGINT COMMENT 'add column design_type_codelist_term_id (BIGINT) with FK to datamanagement.codelist_term.codelist_term_id — per user vibes instruction 1, study_design (interventional or observational) must reference controlled terminology',
    `study_id` BIGINT COMMENT 'description',
    `study_version_id` BIGINT COMMENT 'Reference to study.study_version.study_version_id.',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `design_name` STRING COMMENT 'The design name of the study design.',
    `design_type` STRING COMMENT 'The design type of the study design.',
    `intervention_model` STRING COMMENT 'STRING',
    `study_type` STRING COMMENT 'description',
    `trial_type` STRING COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_attribute_study_type` STRING COMMENT 'description',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_study_design PRIMARY KEY(`study_design_id`)
) COMMENT 'USDM StudyDesign concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`activity` (
    `activity_id` BIGINT COMMENT 'BIGINT',
    `biomedical_concept_id` BIGINT COMMENT 'Reference to study.biomedical_concept.biomedical_concept_id.',
    `schedule_timeline_id` BIGINT COMMENT 'add column schedule_timeline_id (BIGINT) with FK to study.schedule_timeline.schedule_timeline_id — per USDM, activities are scheduled on timelines',
    `study_design_id` BIGINT COMMENT 'Reference to study.study_design.study_design_id.',
    `study_id` BIGINT COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `activity_description` STRING COMMENT 'STRING',
    `activity_name` STRING COMMENT 'The activity name of the activity.',
    `activity_type` STRING COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    CONSTRAINT pk_activity PRIMARY KEY(`activity_id`)
) COMMENT 'USDM Activity concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` (
    `scheduled_activity_instance_id` BIGINT COMMENT 'BIGINT',
    `activity_id` BIGINT COMMENT 'BIGINT',
    `encounter_id` BIGINT COMMENT 'Reference to study.encounter.encounter_id.',
    `schedule_timeline_id` BIGINT COMMENT 'BIGINT',
    `study_design_id` BIGINT COMMENT 'add column study_design_id (BIGINT) with FK to study.study_design.study_design_id — scheduled_activity_instance references activity, encounter, schedule_timeline, and study but should also reference study_design for USDM alignment',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — scheduled_activity_instance missing direct study reference for query efficiency',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `scheduled_time_point` STRING COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    `window_after` STRING COMMENT 'description',
    `window_before` STRING COMMENT 'description',
    CONSTRAINT pk_scheduled_activity_instance PRIMARY KEY(`scheduled_activity_instance_id`)
) COMMENT 'USDM ScheduledActivityInstance concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_version` (
    `study_version_id` BIGINT COMMENT 'BIGINT',
    `study_id` BIGINT COMMENT 'BIGINT',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `effective_date` DATE COMMENT 'description',
    `rationale` STRING COMMENT 'STRING',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `usdm_attribute` STRING COMMENT 'USDM attribute reference',
    `usdm_class` STRING COMMENT 'description',
    `version_date` DATE COMMENT 'description',
    `version_identifier` STRING COMMENT 'STRING',
    CONSTRAINT pk_study_version PRIMARY KEY(`study_version_id`)
) COMMENT 'USDM StudyVersion concept in the study domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`study`.`study_milestone` (
    `study_milestone_id` BIGINT COMMENT 'Unique identifier for the study milestone record',
    `study_id` BIGINT COMMENT 'study.study.study_id',
    `actual_date` DATE COMMENT 'DATE',
    `milestone_name` STRING COMMENT 'The name of the study milestone.',
    `milestone_status` STRING COMMENT 'STRING',
    `planned_date` DATE COMMENT 'DATE',
    `study_milestone_status` STRING COMMENT 'STRING',
    CONSTRAINT pk_study_milestone PRIMARY KEY(`study_milestone_id`)
) COMMENT 'Records milestones associated with a study, tracking key events and their dates throughout the study lifecycle.';

ALTER SCHEMA `clinical_trials_ecm`.`study` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`study` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_sponsor_regulatory_strategy_id` FOREIGN KEY (`sponsor_regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`regulatory_strategy`(`regulatory_strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` SET TAGS ('dbx_owns' = 'digital_protocol');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `sponsor_regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'randomized|non-randomized|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_standard_element' = 'StudyDesign.subTypes');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.allocationMethod');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard_element' = 'StudyAmendment.date');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_standard_element' = 'StudyAmendment.number');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.number');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_standard_element' = 'StudyAmendment.summary');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.rationale');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non-substantial|administrative');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard_element' = 'StudyAmendment.changes');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.changeType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Approval Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `dsmb_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT / CTIS Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `gcp_compliance_declaration` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Declaration');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `ich_compliance_declaration` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation (ICH) Compliance Declaration');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_value_regex' = 'single_group|parallel|crossover|factorial|sequential');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_implements' = 'USDM StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_standard_element' = 'InterventionalStudyDesign.model');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|waived');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_business_glossary_term' = 'Adaptive Design Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.characteristics');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Study Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_usdm_class' = 'StudyPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_usdm_attribute' = 'StudyPopulation.plannedAge');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_business_glossary_term' = 'Masking Type (Blinding)');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind|quadruple_blind');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_implements' = 'USDM StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Study Arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard_element' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Duration (Months)');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyDuration');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.plannedSubjectCount');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_standard_element' = 'Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_standard_element' = 'Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_usdm_attribute' = 'Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_implements' = 'USDM StudyDesign.trialIntentType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_standard_element' = 'StudyDesign.intentType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Registry Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `regulatory_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `secondary_objectives` SET TAGS ('dbx_standard_element' = 'Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `secondary_objectives` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `secondary_objectives` SET TAGS ('dbx_usdm_attribute' = 'Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `secondary_objectives` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Short Title');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.shortTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_value_regex' = 'draft|approved|amended|superseded|final|retired');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolStatus');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolStatus');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_usdm_class' = 'StudyPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_usdm_attribute' = 'StudyPopulation.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'interventional|observational|expanded_access|compassionate_use');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Full Title');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.officialTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_implements' = 'USDM StudyVersion.versionIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_amendment_regulatory_binder_id` FOREIGN KEY (`amendment_regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_amendment_tmf_document_id` FOREIGN KEY (`amendment_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_authored_by_employee_id` FOREIGN KEY (`authored_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_clinical_one_amendment_id` FOREIGN KEY (`clinical_one_amendment_id`) REFERENCES `clinical_trials_ecm`.`program`.`amendment`(`amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Authored By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `clinical_one_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Oracle Clinical One Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `affected_sections` SET TAGS ('dbx_business_glossary_term' = 'Affected Protocol Sections');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard_element' = 'StudyAmendment.date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Description');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_standard_element' = 'StudyAmendment.summary');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|withdrawn|superseded');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Title');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_standard_element' = 'StudyAmendment.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non_substantial|administrative');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard_element' = 'StudyAmendment.changes');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Amendment Approver');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_business_glossary_term' = 'Amendment Change Category');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_standard_element' = 'StudyAmendmentReason.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `dsmb_dmc_recommendation_flag` SET TAGS ('dbx_business_glossary_term' = 'DSMB/DMC Recommendation Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Effective Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `ema_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|validated|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `fda_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged|approved|on_clinical_hold');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `icf_version_updated_flag` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Updated Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `impact_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Amendment Impact Assessment Summary');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `implementation_deadline` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Deadline');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|approved_with_conditions|rejected');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `pmda_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_business_glossary_term' = 'Previous Protocol Version Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Amendment Rationale');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_standard_element' = 'StudyAmendmentReason.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `reconsent_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `safety_driven_flag` SET TAGS ('dbx_business_glossary_term' = 'Safety-Driven Amendment Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `sap_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_amendment` ALTER COLUMN `veeva_vault_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ADD CONSTRAINT `fk_study_study_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ADD CONSTRAINT `fk_study_study_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ADD CONSTRAINT `fk_study_study_primary_study_cro_org_organization_id` FOREIGN KEY (`primary_study_cro_org_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ADD CONSTRAINT `fk_study_study_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'Study.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `primary_study_cro_org_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Study Acronym');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_standard_element' = 'StudyVersion.studyAcronym');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_usdm_attribute' = 'Study.studyAcronym');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrollment Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.enrolledSubjectCount');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'Open Label|Single Blind|Double Blind|Triple Blind');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `csr_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `ctms_study_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Study Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_business_glossary_term' = 'Study Design Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.subTypes');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `edc_study_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Study Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Initial Approval Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_business_glossary_term' = 'Randomization Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_standard_element' = 'StudyDesign.characteristics');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.allocationMethod');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_business_glossary_term' = 'ClinicalTrials.gov NCT Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_value_regex' = '^NCT[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Study Arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard_element' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `primary_regulatory_region` SET TAGS ('dbx_value_regex' = 'US|EU|JP|AU|CA|GLOBAL');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_business_glossary_term' = 'Study Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_value_regex' = 'Planned|Startup|Active|On Hold|Completed|Terminated');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_standard_element' = 'StudyVersion.status');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Target Enrollment Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_standard_element' = 'Population.plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.plannedSubjectCount');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Study Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Study Full Title');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_usdm_attribute' = 'Study.studyTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `tmf_archival_date` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Archival Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'Interventional|Observational|Expanded Access');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_primary_planned_arm_codelist_id` FOREIGN KEY (`primary_planned_arm_codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_type_codelist_term_id` FOREIGN KEY (`type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_implements' = 'USDM StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_standard_element' = 'StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_codelist' = 'ARMTYP');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `primary_planned_arm_codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'Open Label|Single Blind|Double Blind|Triple Blind');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `clinical_one_arm_code` SET TAGS ('dbx_business_glossary_term' = 'Oracle Clinical One Arm Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_implements' = 'USDM StudyArm.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_standard_element' = 'StudyArm.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `ctms_arm_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Arm Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `discontinuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Arm Discontinuation Reason');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_standard_element' = 'EX.EXDOSE');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_usdm_attribute' = 'StudyIntervention.dose');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_usdm_attribute' = 'StudyIntervention.frequency');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Arm End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_standard_element' = 'StudyIntervention.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_standard_element' = 'StudyIntervention.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Arm Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_business_glossary_term' = 'Control Arm Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_standard_element' = 'StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `itt_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `max_subjects_count` SET TAGS ('dbx_business_glossary_term' = 'Maximum Subjects Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `min_subjects_count` SET TAGS ('dbx_business_glossary_term' = 'Minimum Subjects Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_implements' = 'USDM StudyArm.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_standard_element' = 'StudyArm.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Arm Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `pp_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `protocol_version_ref` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_standard_element' = 'StudyArm.populationNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.populationNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Study Data Tabulation Model (SDTM) Arm Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_value_regex' = '^ARM$');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_standard_element' = 'TA.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Arm Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.studyArmSequence');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Arm Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `arm_status` SET TAGS ('dbx_value_regex' = 'Planned|Active|Suspended|Closed|Discontinued');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Treatment Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`arm` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_ctcae_grade_id` FOREIGN KEY (`ctcae_grade_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae_grade`(`ctcae_grade_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Study Endpoint ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_business_glossary_term' = 'Ctcae Grade Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_business_glossary_term' = 'Meddra Term Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Code (PARAMCD)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Name (PARAM)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Significance Level)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `analysis_population` SET TAGS ('dbx_value_regex' = 'ITT|mITT|PP|safety|PK|biomarker');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_category` SET TAGS ('dbx_value_regex' = 'efficacy|safety|tolerability|PK_PD|quality_of_life|biomarker');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_value_regex' = '^EP-[A-Z0-9]{2,10}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_standard_element' = 'Endpoint.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_implements' = 'USDM Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_standard_element' = 'Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `directionality` SET TAGS ('dbx_business_glossary_term' = 'Test Directionality');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `directionality` SET TAGS ('dbx_value_regex' = 'one_sided|two_sided');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_value_regex' = 'treatment_policy|hypothetical|composite|while_on_treatment|principal_stratum');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_standard_element' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_usdm_attribute' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_business_glossary_term' = 'Estimand Target Population');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_standard_element' = 'Estimand.analysisPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_usdm_attribute' = 'Estimand.analysisPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_business_glossary_term' = 'Estimand Population-Level Summary');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_standard_element' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_usdm_attribute' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_standard_element' = 'Estimand.intercurrentEvents');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_usdm_attribute' = 'Estimand.intervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_business_glossary_term' = 'Estimand Variable (Endpoint Variable)');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_standard_element' = 'Estimand.variableOfInterest');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_usdm_attribute' = 'Estimand.variableOfInterest');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_business_glossary_term' = 'Measurement Instrument or Scale');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.purpose');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard_element' = 'SOC.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Strategy');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `multiplicity_adjustment_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `multiplicity_adjustment_flag` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_business_glossary_term' = 'Multiplicity Adjustment Procedure');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_implements' = 'USDM Endpoint.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_standard_element' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority Margin');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_implements' = 'USDM Objective.level');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'Medidata_Rave|Oracle_Clinical_One|SAS_Drug_Development|manual');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `source_system_endpoint_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Endpoint Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `statistical_hypothesis` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|descriptive');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|retired|locked');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_implements' = 'USDM Endpoint.level');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_standard_element' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.level');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_standard_element' = 'Findings.--ORRESU');

ALTER TABLE `clinical_trials_ecm`.`study`.`endpoint` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_previous_criterion_eligibility_criterion_id` FOREIGN KEY (`previous_criterion_eligibility_criterion_id`) REFERENCES `clinical_trials_ecm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_business_glossary_term' = 'Meddra Term Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `previous_criterion_eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Criterion ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_value_regex' = 'ALL|FEMALE_ONLY|MALE_ONLY|PEDIATRIC|ADULT|ELDERLY');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `change_rationale` SET TAGS ('dbx_business_glossary_term' = 'Criterion Change Rationale');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_business_glossary_term' = 'Case Report Form (CRF) Page Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.category');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.category');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion.identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_status` SET TAGS ('dbx_value_regex' = 'DRAFT|ACTIVE|SUPERSEDED|RETIRED');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_value_regex' = 'INCLUSION|EXCLUSION');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.category');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.category');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.criterionSequence');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `edc_field_oid` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Field Object Identifier (OID)');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Criterion Effective Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) / Independent Ethics Committee (IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `is_amendment_driven` SET TAGS ('dbx_business_glossary_term' = 'Amendment-Driven Change Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `is_critical_criterion` SET TAGS ('dbx_business_glossary_term' = 'Critical Criterion Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `lab_test_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_standard_element' = 'PT.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `numeric_threshold_comparator` SET TAGS ('dbx_value_regex' = 'EQ|NE|LT|LE|GT|GE');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `requires_source_doc_verification` SET TAGS ('dbx_business_glossary_term' = 'Source Document Verification (SDV) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Criterion Retirement Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Inclusion/Exclusion (IE) Test Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_standard_element' = 'IE.IETESTCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `source_system_criterion_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Criterion ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `time_window_unit` SET TAGS ('dbx_value_regex' = 'DAYS|WEEKS|MONTHS|YEARS');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `waiver_allowed` SET TAGS ('dbx_business_glossary_term' = 'Waiver Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_business_glossary_term' = 'World Health Organization Drug Dictionary (WHO-DD) Drug Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_ecm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_standard_element' = 'DrugRecord.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_schedule_timeline_id` FOREIGN KEY (`schedule_timeline_id`) REFERENCES `clinical_trials_ecm`.`study`.`schedule_timeline`(`schedule_timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_visit_type_codelist_term_id` FOREIGN KEY (`visit_type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_attribute' = 'Encounter.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'USDM Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'VISITYP');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard_element' = 'Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_attribute' = 'Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_business_glossary_term' = 'CDISC Visit Reference Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_standard_element' = 'SV.VISIT');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_usdm_attribute' = 'Encounter.encounterId');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `fasting_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Required Fasting Duration (Hours)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_dosing_visit` SET TAGS ('dbx_business_glossary_term' = 'Dosing Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_in_itt_population` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_in_pp_population` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Procedure Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_pk_sampling_visit` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Sampling Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_primary_endpoint_visit` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_randomization_visit` SET TAGS ('dbx_business_glossary_term' = 'Randomization Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `is_unscheduled` SET TAGS ('dbx_business_glossary_term' = 'Unscheduled Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Schedule Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_standard_element' = 'SV.VISITDY');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_usdm_attribute' = 'Timing.value');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_business_glossary_term' = 'Procedure / Assessment Name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_sequence` SET TAGS ('dbx_business_glossary_term' = 'Procedure Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `requires_central_lab` SET TAGS ('dbx_business_glossary_term' = 'Central Laboratory Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `requires_local_lab` SET TAGS ('dbx_business_glossary_term' = 'Local Laboratory Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `schedule_version` SET TAGS ('dbx_business_glossary_term' = 'Schedule of Events (SoE) Version');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `schedule_version` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `source_system_visit_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Visit Identifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Planned Visit Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_implements' = 'SDTM SV.VISIT');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard_element' = 'Encounter.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_usdm_attribute' = 'Encounter.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_implements' = 'SDTM SV.VISITNUM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard_element' = 'SV.VISITNUM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_usdm_attribute' = 'Encounter.encounterSequence');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_standard_element' = 'Encounter.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_usdm_attribute' = 'Encounter.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_status` SET TAGS ('dbx_business_glossary_term' = 'Visit Schedule Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Window After (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_standard_element' = 'Timing.windowUpper');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_usdm_attribute' = 'Timing.windowUpper');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Before (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_standard_element' = 'Timing.windowLower');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_usdm_attribute' = 'Timing.windowLower');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `clinical_trials_ecm`.`study`.`activity`(`activity_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_ctcae_grade_id` FOREIGN KEY (`ctcae_grade_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae_grade`(`ctcae_grade_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ADD CONSTRAINT `fk_study_visit_procedure_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `visit_procedure_id` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `visit_procedure_id` SET TAGS ('dbx_usdm_attribute' = 'Activity.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `visit_procedure_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_business_glossary_term' = 'Ctcae Grade Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_class' = 'ScheduledActivityInstance');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_attribute' = 'ScheduledActivityInstance.encounterId');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `adam_dataset` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `adam_dataset` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `adam_dataset` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Acquisition Standards Harmonization (CDASH) Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_standard_element' = 'CDASHIG.VARIABLE');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `central_lab_required` SET TAGS ('dbx_business_glossary_term' = 'Central Laboratory Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `ctcae_grading_applicable` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grading Applicable Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Procedure Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Procedure Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `equipment_type` SET TAGS ('dbx_business_glossary_term' = 'Required Equipment Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `estimated_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Estimated Procedure Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Procedure Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `is_pk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Assessment Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `is_primary_endpoint` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Procedure Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `is_safety_assessment` SET TAGS ('dbx_business_glossary_term' = 'Safety Assessment Procedure Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `local_lab_allowed` SET TAGS ('dbx_business_glossary_term' = 'Local Laboratory Allowed Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Procedure Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `oracle_clinical_one_task_code` SET TAGS ('dbx_business_glossary_term' = 'Oracle Clinical One Task ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_category` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_category` SET TAGS ('dbx_standard_element' = 'Activity.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_standard_element' = 'Procedure.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_usdm_attribute' = 'Activity.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_description` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_description` SET TAGS ('dbx_usdm_attribute' = 'Activity.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_standard_element' = 'Procedure.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_usdm_attribute' = 'Activity.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `procedure_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|retired|superseded');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `qualified_personnel_required` SET TAGS ('dbx_business_glossary_term' = 'Qualified Personnel Requirement');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `qualified_personnel_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `qualified_personnel_required` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `rave_form_version` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave eCRF Form Version');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `requires_fasting` SET TAGS ('dbx_business_glossary_term' = 'Fasting Requirement Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `requires_unscheduled_flag` SET TAGS ('dbx_business_glossary_term' = 'Unscheduled Visit Procedure Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sdv_requirement` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Requirement');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sdv_requirement` SET TAGS ('dbx_value_regex' = '100_percent|risk_based|critical_only|not_required');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Procedure Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_attribute' = 'Activity.activitySequence');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `specimen_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `timing_reference` SET TAGS ('dbx_business_glossary_term' = 'Procedure Timing Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `timing_window_post_minutes` SET TAGS ('dbx_business_glossary_term' = 'Procedure Timing Window Post-Dose (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `timing_window_pre_minutes` SET TAGS ('dbx_business_glossary_term' = 'Procedure Timing Window Pre-Dose (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`study`.`visit_procedure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_type_codelist_term_id` FOREIGN KEY (`type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'USDM StudyEpoch.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard_element' = 'StudyEpoch.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'EPOCH');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_cdisc_ct' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `ae_reporting_applicable` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Reporting Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'OPEN-LABEL|SINGLE-BLIND|DOUBLE-BLIND|TRIPLE-BLIND|NOT-APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'StudyEpoch.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_standard_element' = 'StudyEpoch.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Epoch Definition Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Epoch Definition Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `extension_epoch` SET TAGS ('dbx_business_glossary_term' = 'Extension Epoch Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `follow_up_epoch` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Epoch Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `ip_administered` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Administered Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `is_deleted` SET TAGS ('dbx_business_glossary_term' = 'Soft Delete Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `itt_population_epoch` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Epoch Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `maximum_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Epoch Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `minimum_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Minimum Epoch Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_implements' = 'USDM StudyEpoch.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard_element' = 'StudyEpoch.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Planned Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.duration');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_business_glossary_term' = 'Planned Duration ISO 8601');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_value_regex' = '^P(d+Y)?(d+M)?(d+W)?(d+D)?(T(d+H)?(d+M)?(d+S)?)?$');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_standard_element' = 'Duration.durationWillVary');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_business_glossary_term' = 'Planned End Day (Study Day)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.plannedEndDay');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_business_glossary_term' = 'Planned Start Day (Study Day)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.plannedStartDay');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `primary_endpoint_epoch` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Epoch Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `randomization_applicable` SET TAGS ('dbx_business_glossary_term' = 'Randomization Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Epoch Code (ETCD)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_standard_element' = 'TA.EPOCH');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Trial Elements (TE) Domain Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Epoch Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard_element' = 'StudyEpoch.previousId');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.studyEpochSequence');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Epoch Short Name');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_standard_element' = 'StudyEpoch.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `source_system_epoch_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Epoch ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_value_regex' = 'ORACLE_CLINICAL_ONE|MEDIDATA_RAVE|MANUAL|OTHER');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `epoch_status` SET TAGS ('dbx_value_regex' = 'DRAFT|ACTIVE|AMENDED|SUPERSEDED|RETIRED');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Specific Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `washout_epoch` SET TAGS ('dbx_business_glossary_term' = 'Washout Epoch Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `window_after_days` SET TAGS ('dbx_business_glossary_term' = 'Epoch Window After (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`epoch` ALTER COLUMN `window_before_days` SET TAGS ('dbx_business_glossary_term' = 'Epoch Window Before (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_predecessor_study_protocol_milestone_id` FOREIGN KEY (`predecessor_study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ADD CONSTRAINT `fk_study_study_protocol_milestone_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` SET TAGS ('dbx_cross_domain_duplicate_resolved' = 'distinct_milestone');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Person ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `predecessor_study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `achievement_confirmed_by` SET TAGS ('dbx_business_glossary_term' = 'Milestone Achievement Confirmed By');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `achievement_confirmed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Milestone Achievement Confirmed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `baseline_date` SET TAGS ('dbx_business_glossary_term' = 'Baseline Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Milestone Comments');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `completion_criteria` SET TAGS ('dbx_business_glossary_term' = 'Milestone Completion Criteria');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `ctms_milestone_ref` SET TAGS ('dbx_business_glossary_term' = 'CTMS Milestone Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'siebel_ctms|oracle_clinical_one|manual|sponsor_feed|other');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `dependency_type` SET TAGS ('dbx_business_glossary_term' = 'Milestone Dependency Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `dependency_type` SET TAGS ('dbx_value_regex' = 'finish_to_start|start_to_start|finish_to_finish|start_to_finish');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `forecast_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `is_contractual` SET TAGS ('dbx_business_glossary_term' = 'Contractual Milestone Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `is_critical_path` SET TAGS ('dbx_business_glossary_term' = 'Critical Path Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `is_regulatory_milestone` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `lead_lag_days` SET TAGS ('dbx_business_glossary_term' = 'Lead/Lag Days');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_category` SET TAGS ('dbx_value_regex' = 'operational|regulatory|enrollment|safety|financial|data_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.plannedDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|achieved|delayed|waived|cancelled');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_standard_element' = 'GovernanceDate.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `notification_required` SET TAGS ('dbx_business_glossary_term' = 'Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `planned_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `planned_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `planned_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Milestone Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `study_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `variance_days` SET TAGS ('dbx_business_glossary_term' = 'Schedule Variance Days');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `variance_reason` SET TAGS ('dbx_business_glossary_term' = 'Milestone Variance Reason');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `variance_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Milestone Variance Reason Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Milestone Waiver Approved By');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_protocol_milestone` ALTER COLUMN `waiver_justification` SET TAGS ('dbx_business_glossary_term' = 'Milestone Waiver Justification');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_cta_regulatory_binder_id` FOREIGN KEY (`cta_regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_sponsor_regulatory_strategy_id` FOREIGN KEY (`sponsor_regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`regulatory_strategy`(`regulatory_strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ADD CONSTRAINT `fk_study_country_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `cta_regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Cta Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Country Lead Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `sponsor_regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `activation_status` SET TAGS ('dbx_business_glossary_term' = 'Country Activation Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `activation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_startup|activated|suspended|closed');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `actual_enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrolled Subject Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `actual_screened_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Screened Subject Count');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Country-Level Study Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166-1 Alpha-2)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_element' = 'ISO 3166 country code');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `cta_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `cta_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Approval Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `cta_approval_status` SET TAGS ('dbx_value_regex' = 'not_submitted|submitted|approved|rejected|withdrawn|pending_response');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `cta_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Country Currency Code (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Regulatory Framework');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `dropout_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Subject Dropout Rate Assumption');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `enrollment_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Rate Assumption (Subjects per Site per Month)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_business_glossary_term' = 'Country Enrollment Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_value_regex' = 'planned|active|enrollment_complete|on_hold|terminated|closed');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^d{4}-d{6}-d{2}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `feasibility_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Country Feasibility Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `feasibility_score` SET TAGS ('dbx_business_glossary_term' = 'Country Feasibility Score');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `icf_version_required` SET TAGS ('dbx_business_glossary_term' = 'Required Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `irb_iec_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_business_glossary_term' = 'Local Language Code (IETF BCP 47)');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_pii_language' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_standard_element' = 'GeographicScope.code');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_business_glossary_term' = 'National Clinical Trial Registry Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `subject_data_transfer_allowed` SET TAGS ('dbx_business_glossary_term' = 'Subject Data Cross-Border Transfer Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`country` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_imp_tmf_document_id` FOREIGN KEY (`imp_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IMP) ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `imp_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Nda Bla Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_business_glossary_term' = 'Active Pharmaceutical Ingredient (API) / Active Substance');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_standard_element' = 'MedicalDevice.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `cas_number` SET TAGS ('dbx_business_glossary_term' = 'Chemical Abstracts Service (CAS) Registry Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `cas_number` SET TAGS ('dbx_value_regex' = '^[0-9]{2,7}-[0-9]{2}-[0-9]$');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `controlled_substance_schedule` SET TAGS ('dbx_value_regex' = 'schedule_I|schedule_II|schedule_III|schedule_IV|schedule_V|not_controlled');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `ema_product_number` SET TAGS ('dbx_business_glossary_term' = 'European Medicines Agency (EMA) Product Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `first_in_human_date` SET TAGS ('dbx_business_glossary_term' = 'First-in-Human (FIH) Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `formulation` SET TAGS ('dbx_business_glossary_term' = 'Formulation Description');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `imp_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `imp_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `impd_version` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product Dossier (IMPD) Version');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `is_comparator` SET TAGS ('dbx_business_glossary_term' = 'Comparator Product Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `is_placebo` SET TAGS ('dbx_business_glossary_term' = 'Placebo Indicator');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_site` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Site');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `mechanism_of_action` SET TAGS ('dbx_business_glossary_term' = 'Mechanism of Action (MOA)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `ndc_number` SET TAGS ('dbx_business_glossary_term' = 'National Drug Code (NDC) Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `ndc_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4,5}-[0-9]{3,4}-[0-9]{1,2}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_standard_element' = 'StudyIntervention.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|investigational|withdrawn|not_approved');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `retest_period_months` SET TAGS ('dbx_business_glossary_term' = 'Retest Period (Months)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `shelf_life_months` SET TAGS ('dbx_business_glossary_term' = 'Shelf Life (Months)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_status` SET TAGS ('dbx_value_regex' = 'active|inactive|discontinued|on_hold|superseded');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Strength');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_standard_element' = 'AdministrableProduct.strength');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_business_glossary_term' = 'Strength Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_standard_element' = 'EX.EXDOSU');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_ecm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_standard_element' = 'DrugRecord.drugCode');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_dose_form_codelist_term_id` FOREIGN KEY (`dose_form_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_dose_unit_codelist_term_id` FOREIGN KEY (`dose_unit_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_route_codelist_term_id` FOREIGN KEY (`route_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'Dose Form');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_codelist' = 'FRM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_unit_codelist_term_id` SET TAGS ('dbx_codelist' = 'UNIT');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_unit_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSU');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Route of Administration');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_codelist' = 'ROUTE');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM EX.EXROUTE');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_business_glossary_term' = 'CDISC ADaM Exposure (ADEX) Domain Mapping Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open-label|single-blind|double-blind|triple-blind');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `comparator_type` SET TAGS ('dbx_value_regex' = 'active|placebo|vehicle|sham|no-treatment');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_escalation_step` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Step Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSE');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_standard_element' = 'EX.EXDOSE');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dose_reduction_levels` SET TAGS ('dbx_business_glossary_term' = 'Number of Dose Reduction Levels');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Dosing Interval (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Regimen Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Regimen Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `escalation_scheme_description` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Scheme Description');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `infusion_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Infusion Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `is_dose_escalation` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `is_mtd` SET TAGS ('dbx_business_glossary_term' = 'Maximum Tolerated Dose (MTD) Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `loading_dose_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Loading Dose Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `pd_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Pharmacodynamics (PD) Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `pk_sampling_required` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Sampling Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Planned Dosing Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `protocol_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_code` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Name');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_standard_element' = 'AdministrableProduct.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_status` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|discontinued|completed');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Exposure (EX) Domain Mapping Notes');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_standard_element' = 'EX');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`dosing_regimen` ALTER COLUMN `washout_period_days` SET TAGS ('dbx_business_glossary_term' = 'Washout Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_primary_endpoint_id` FOREIGN KEY (`primary_endpoint_id`) REFERENCES `clinical_trials_ecm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_business_glossary_term' = 'Study Objective ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_usdm_attribute' = 'Objective.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_usdm_attribute' = 'Objective.endpoints');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Type I Error Rate)');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `ctd_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `dsmb_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non-inferiority|equivalence|descriptive');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_value_regex' = 'while_on_treatment|hypothetical|composite|principal_stratum|treatment_policy');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_standard_element' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `irb_iec_review_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `last_amended_in_amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Last Amended in Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_business_glossary_term' = 'Multiplicity Adjustment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,2}-[0-9]{1,3}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_standard_element' = 'Objective.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_usdm_attribute' = 'Objective.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_description` SET TAGS ('dbx_standard_element' = 'AnalysisPopulation.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_value_regex' = 'ITT|mITT|PP|safety|PK|PD');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain Reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_business_glossary_term' = 'Objective Short Title');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_attribute' = 'Objective.label');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `summary_measure` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `summary_measure` SET TAGS ('dbx_standard_element' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_business_glossary_term' = 'Objective Text');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_implements' = 'USDM Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_usdm_attribute' = 'Objective.text');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety|pharmacokinetic|pharmacodynamic');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_implements' = 'USDM Objective.level');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_usdm_attribute' = 'Objective.level');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`objective` ALTER COLUMN `variable_description` SET TAGS ('dbx_business_glossary_term' = 'Estimand Variable Description');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ADD CONSTRAINT `fk_study_pk_sampling_schedule_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `pk_sampling_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetic (PK) Sampling Schedule ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Method ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_code` SET TAGS ('dbx_standard_element' = 'PC.PCTESTCD');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_name` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `analyte_name` SET TAGS ('dbx_standard_element' = 'PC.PCTEST');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `backup_sample_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Backup Sample Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `cycle_number` SET TAGS ('dbx_business_glossary_term' = 'Treatment Cycle Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `day_in_cycle` SET TAGS ('dbx_business_glossary_term' = 'Day in Treatment Cycle');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `edc_field_oid` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Field OID');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `max_storage_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Duration (Hours)');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `max_storage_duration_hours` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `max_storage_duration_hours` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `nominal_timepoint_label` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `nominal_timepoint_label` SET TAGS ('dbx_standard_element' = 'PC.PCTPT');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `nominal_timepoint_unit` SET TAGS ('dbx_value_regex' = 'hours|minutes|days|weeks');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `optional_sample` SET TAGS ('dbx_business_glossary_term' = 'Optional Sample Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `pre_dose_sample` SET TAGS ('dbx_business_glossary_term' = 'Pre-Dose Sample Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `protocol_version` SET TAGS ('dbx_value_regex' = '^v?[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `required_sample_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Required Sample Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sample_type` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sample_type` SET TAGS ('dbx_standard_element' = 'PC.PCSPEC');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sampling_category` SET TAGS ('dbx_value_regex' = 'PK|PD|PK_PD|biomarker|immunogenicity|safety');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Sampling Schedule Code');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Sampling Schedule Name');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Sampling Schedule Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|retired|cancelled');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Domain');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = 'PC|PP|LB|EG|VS');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_pctptnum` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM PC Timepoint Number (PCTPTNUM)');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_pctptnum` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sdtm_pctptnum` SET TAGS ('dbx_standard_element' = 'PC.PCTPTNUM');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Sampling Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `shipping_condition` SET TAGS ('dbx_business_glossary_term' = 'Sample Shipping Condition');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `shipping_condition` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|dry_ice|liquid_nitrogen|frozen');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `sparse_sampling` SET TAGS ('dbx_business_glossary_term' = 'Sparse Sampling Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `steady_state_sample` SET TAGS ('dbx_business_glossary_term' = 'Steady-State Sample Flag');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_business_glossary_term' = 'Sample Storage Temperature');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated_2_8C|frozen_minus20C|frozen_minus70C|frozen_minus80C|dry_ice');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `timepoint_reference` SET TAGS ('dbx_business_glossary_term' = 'Timepoint Reference Event');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `timepoint_reference` SET TAGS ('dbx_value_regex' = 'first_dose|previous_dose|start_of_infusion|end_of_infusion|study_day_1');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `window_lower_bound` SET TAGS ('dbx_business_glossary_term' = 'Sampling Window Lower Bound');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `window_unit` SET TAGS ('dbx_business_glossary_term' = 'Sampling Window Unit');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `window_unit` SET TAGS ('dbx_value_regex' = 'hours|minutes|days');

ALTER TABLE `clinical_trials_ecm`.`study`.`pk_sampling_schedule` ALTER COLUMN `window_upper_bound` SET TAGS ('dbx_business_glossary_term' = 'Sampling Window Upper Bound');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ADD CONSTRAINT `fk_study_amendment_site_implementation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ADD CONSTRAINT `fk_study_amendment_site_implementation_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ADD CONSTRAINT `fk_study_amendment_site_implementation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` SET TAGS ('dbx_association_edges' = 'study.study_protocol_amendment,site.study_site');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `amendment_site_implementation_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Site Implementation - Amendment Site Implementation Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Site Implementation - Study Protocol Amendment Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Site Implementation - Study Site Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `edc_configuration_updated_flag` SET TAGS ('dbx_business_glossary_term' = 'EDC Configuration Updated');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_status` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `implementation_status` SET TAGS ('dbx_standard_element' = 'StudyAmendment.changes');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Site Amendment Notification Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`amendment_site_implementation` ALTER COLUMN `reconsent_completed_flag` SET TAGS ('dbx_business_glossary_term' = 'Reconsent Completed');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ADD CONSTRAINT `fk_study_ip_site_accountability_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ADD CONSTRAINT `fk_study_ip_site_accountability_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ADD CONSTRAINT `fk_study_ip_site_accountability_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` SET TAGS ('dbx_association_edges' = 'study.investigational_product,site.investigational_site');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `ip_site_accountability_id` SET TAGS ('dbx_business_glossary_term' = 'Ip Site Accountability - Ip Site Accountability Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Ip Site Accountability - Investigational Product Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Ip Site Accountability - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Overall Authorization Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `authorization_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `authorization_status` SET TAGS ('dbx_standard_element' = 'StudyIntervention.administrationDuration');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `dispensing_authorization_status` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `dispensing_authorization_status` SET TAGS ('dbx_standard_element' = 'EX.EXDOSE');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `storage_authorization_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `storage_authorization_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `storage_compliance_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`ip_site_accountability` ALTER COLUMN `storage_compliance_status` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ADD CONSTRAINT `fk_study_country_submission_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ADD CONSTRAINT `fk_study_country_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ADD CONSTRAINT `fk_study_country_submission_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` SET TAGS ('dbx_association_edges' = 'study.study_country,regulatory.submission');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Country Submission - Country Submission Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Submission - Study Country Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Country Submission - Submission Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `agency_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'National Authority Acknowledgement Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `agency_acknowledgement_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `agency_acknowledgement_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_specific_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'National Dossier Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Country Filing Date');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_submission_status` SET TAGS ('dbx_business_glossary_term' = 'Country Filing Status');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_submission_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `country_submission_status` SET TAGS ('dbx_standard_element' = 'GovernanceDate.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Country Submission Type');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_standard' = 'ICH');

ALTER TABLE `clinical_trials_ecm`.`study`.`country_submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_standard_element' = 'M4 submission type');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ADD CONSTRAINT `fk_study_product_designation_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ADD CONSTRAINT `fk_study_product_designation_special_designation_id` FOREIGN KEY (`special_designation_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`special_designation`(`special_designation_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ADD CONSTRAINT `fk_study_product_designation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` SET TAGS ('dbx_subdomain' = 'operational_execution');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` SET TAGS ('dbx_association_edges' = 'study.investigational_product,regulatory.special_designation');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `product_designation_id` SET TAGS ('dbx_business_glossary_term' = 'Product Designation - Product Designation Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Product Designation - Investigational Product Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `special_designation_id` SET TAGS ('dbx_business_glossary_term' = 'Product Designation - Special Designation Id');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `designation_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `designation_type` SET TAGS ('dbx_standard_element' = 'StudyIntervention.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `indication_scope` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`product_designation` ALTER COLUMN `indication_scope` SET TAGS ('dbx_standard_element' = 'Indication.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ADD CONSTRAINT `fk_study_intercurrent_event_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_ecm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ADD CONSTRAINT `fk_study_intercurrent_event_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ADD CONSTRAINT `fk_study_intercurrent_event_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ADD CONSTRAINT `fk_study_intercurrent_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `estimand_id` SET TAGS ('dbx_business_glossary_term' = 'estimand');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `estimand_id` SET TAGS ('dbx_relationship' = 'many_to_one');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'studyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_description` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_description` SET TAGS ('dbx_usdm_attribute' = 'description');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_name` SET TAGS ('dbx_usdm_attribute' = 'name');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `event_name` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `handling_strategy` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `handling_strategy` SET TAGS ('dbx_usdm_attribute' = 'strategy');

ALTER TABLE `clinical_trials_ecm`.`study`.`intercurrent_event` ALTER COLUMN `handling_strategy` SET TAGS ('dbx_ich' = 'E9R1');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ADD CONSTRAINT `fk_study_cohort_population_id` FOREIGN KEY (`population_id`) REFERENCES `clinical_trials_ecm`.`study`.`population`(`population_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ADD CONSTRAINT `fk_study_cohort_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ADD CONSTRAINT `fk_study_cohort_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_usdm' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_clinical_trials_v2' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_id` SET TAGS ('dbx_business_glossary_term' = 'Cohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_id` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_id` SET TAGS ('dbx_usdm_attribute' = 'id');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `population_id` SET TAGS ('dbx_business_glossary_term' = 'Population');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `population_id` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `population_id` SET TAGS ('dbx_usdm_attribute' = 'population');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'studyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_description` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_description` SET TAGS ('dbx_usdm_attribute' = 'description');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_name` SET TAGS ('dbx_usdm_attribute' = 'name');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `cohort_name` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_business_glossary_term' = 'Planned Enrollment');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_usdm_attribute' = 'plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`cohort` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_usdm_class' = 'StudyCohort');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ADD CONSTRAINT `fk_study_population_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ADD CONSTRAINT `fk_study_population_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_usdm' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_clinical_trials_v2' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_id` SET TAGS ('dbx_business_glossary_term' = 'Study Population');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_id` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_id` SET TAGS ('dbx_usdm_attribute' = 'id');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'studyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_description` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_description` SET TAGS ('dbx_usdm_attribute' = 'description');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `includes_healthy_subjects` SET TAGS ('dbx_business_glossary_term' = 'Healthy Subjects');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `includes_healthy_subjects` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `includes_healthy_subjects` SET TAGS ('dbx_usdm_attribute' = 'includesHealthySubjects');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_name` SET TAGS ('dbx_usdm_attribute' = 'name');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `population_name` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_completion_number` SET TAGS ('dbx_business_glossary_term' = 'Planned Completion');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_completion_number` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_completion_number` SET TAGS ('dbx_usdm_attribute' = 'plannedCompletionNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_business_glossary_term' = 'Planned Enrollment');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_usdm_attribute' = 'plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_ecm`.`study`.`population` ALTER COLUMN `planned_enrollment_number` SET TAGS ('dbx_usdm_class' = 'StudyDesignPopulation');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ADD CONSTRAINT `fk_study_study_intervention_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ADD CONSTRAINT `fk_study_study_intervention_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_usdm' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_clinical_trials_v2' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_intervention_id` SET TAGS ('dbx_business_glossary_term' = 'Study Intervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_intervention_id` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_intervention_id` SET TAGS ('dbx_usdm_attribute' = 'id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'studyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `dose_form` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `dose_form` SET TAGS ('dbx_usdm_attribute' = 'pharmacologicClass');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `dose_form` SET TAGS ('dbx_cdisc_ct' = 'codelist');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_attribute' = 'description');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_name` SET TAGS ('dbx_usdm_attribute' = 'name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_name` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_attribute' = 'type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `intervention_type` SET TAGS ('dbx_cdisc_ct' = 'codelist');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `role` SET TAGS ('dbx_business_glossary_term' = 'Intervention Role');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `role` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `role` SET TAGS ('dbx_usdm_attribute' = 'role');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `route_of_administration` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `route_of_administration` SET TAGS ('dbx_usdm_attribute' = 'route');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_intervention` ALTER COLUMN `route_of_administration` SET TAGS ('dbx_cdisc_ct' = 'codelist');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ADD CONSTRAINT `fk_study_study_cell_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ADD CONSTRAINT `fk_study_study_cell_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ADD CONSTRAINT `fk_study_study_cell_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ADD CONSTRAINT `fk_study_study_cell_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` SET TAGS ('dbx_usdm_class' = 'StudyCell');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `study_cell_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `study_cell_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `study_cell_id` SET TAGS ('dbx_usdm_attribute' = 'StudyCell.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `arm_id` SET TAGS ('dbx_usdm_attribute' = 'StudyCell.armId');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `epoch_id` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `epoch_id` SET TAGS ('dbx_usdm_attribute' = 'StudyCell.epochId');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `epoch_id` SET TAGS ('dbx_note' = 'arm x epoch');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `cell_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_cell` ALTER COLUMN `cell_identifier` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ADD CONSTRAINT `fk_study_schedule_timeline_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ADD CONSTRAINT `fk_study_schedule_timeline_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` SET TAGS ('dbx_usdm_class' = 'ScheduleTimeline');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `schedule_timeline_id` SET TAGS ('dbx_usdm_attribute' = 'ScheduleTimeline.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `is_main_timeline` SET TAGS ('dbx_usdm_attribute' = 'ScheduleTimeline.mainTimeline');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `timeline_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `timeline_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `timeline_name` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`schedule_timeline` ALTER COLUMN `timeline_name` SET TAGS ('dbx_usdm_attribute' = 'ScheduleTimeline.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ADD CONSTRAINT `fk_study_study_element_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ADD CONSTRAINT `fk_study_study_element_study_cell_id` FOREIGN KEY (`study_cell_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_cell`(`study_cell_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ADD CONSTRAINT `fk_study_study_element_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ADD CONSTRAINT `fk_study_study_element_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` SET TAGS ('dbx_usdm_class' = 'StudyElement');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `study_element_id` SET TAGS ('dbx_usdm_attribute' = 'StudyElement.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `study_cell_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `element_description` SET TAGS ('dbx_usdm_attribute' = 'StudyElement.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `element_name` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `element_name` SET TAGS ('dbx_usdm_attribute' = 'StudyElement.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_element` ALTER COLUMN `element_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ADD CONSTRAINT `fk_study_encounter_schedule_timeline_id` FOREIGN KEY (`schedule_timeline_id`) REFERENCES `clinical_trials_ecm`.`study`.`schedule_timeline`(`schedule_timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ADD CONSTRAINT `fk_study_encounter_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ADD CONSTRAINT `fk_study_encounter_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ALTER COLUMN `encounter_id` SET TAGS ('dbx_usdm_attribute' = 'Encounter.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ALTER COLUMN `encounter_name` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ALTER COLUMN `encounter_name` SET TAGS ('dbx_usdm_attribute' = 'Encounter.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ALTER COLUMN `encounter_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`encounter` ALTER COLUMN `encounter_type` SET TAGS ('dbx_usdm_attribute' = 'Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ADD CONSTRAINT `fk_study_study_identifier_issuing_organization_id` FOREIGN KEY (`issuing_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ADD CONSTRAINT `fk_study_study_identifier_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ADD CONSTRAINT `fk_study_study_identifier_study_version_id` FOREIGN KEY (`study_version_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_version`(`study_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `study_identifier_id` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_type` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.scopeType');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_value` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_value` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_value` SET TAGS ('dbx_note' = 'NCT');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_value` SET TAGS ('dbx_EU_CT_number' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `identifier_value` SET TAGS ('dbx_IND' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_identifier` ALTER COLUMN `issuing_organization` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifierScope');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ADD CONSTRAINT `fk_study_biomedical_concept_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ADD CONSTRAINT `fk_study_biomedical_concept_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ADD CONSTRAINT `fk_study_biomedical_concept_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` SET TAGS ('dbx_usdm_class' = 'BiomedicalConcept');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ALTER COLUMN `biomedical_concept_id` SET TAGS ('dbx_usdm_attribute' = 'BiomedicalConcept.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ALTER COLUMN `concept_name` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ALTER COLUMN `concept_name` SET TAGS ('dbx_usdm_attribute' = 'BiomedicalConcept.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ALTER COLUMN `concept_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`biomedical_concept` ALTER COLUMN `reference_code` SET TAGS ('dbx_usdm_attribute' = 'BiomedicalConcept.reference');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ADD CONSTRAINT `fk_study_governance_date_date_type_codelist_term_id` FOREIGN KEY (`date_type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ADD CONSTRAINT `fk_study_governance_date_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ADD CONSTRAINT `fk_study_governance_date_study_version_id` FOREIGN KEY (`study_version_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_version`(`study_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ALTER COLUMN `governance_date_id` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ALTER COLUMN `date_type` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ALTER COLUMN `date_type` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.type');

ALTER TABLE `clinical_trials_ecm`.`study`.`governance_date` ALTER COLUMN `date_value` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ADD CONSTRAINT `fk_study_study_design_design_type_codelist_term_id` FOREIGN KEY (`design_type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ADD CONSTRAINT `fk_study_study_design_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ADD CONSTRAINT `fk_study_study_design_study_version_id` FOREIGN KEY (`study_version_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_version`(`study_version_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_subdomain' = 'design_elements');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `study_design_id` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `design_name` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `design_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `design_type` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `design_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `design_type` SET TAGS ('dbx_note' = 'interventional or observational');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_design` ALTER COLUMN `intervention_model` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.model');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ADD CONSTRAINT `fk_study_activity_biomedical_concept_id` FOREIGN KEY (`biomedical_concept_id`) REFERENCES `clinical_trials_ecm`.`study`.`biomedical_concept`(`biomedical_concept_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ADD CONSTRAINT `fk_study_activity_schedule_timeline_id` FOREIGN KEY (`schedule_timeline_id`) REFERENCES `clinical_trials_ecm`.`study`.`schedule_timeline`(`schedule_timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ADD CONSTRAINT `fk_study_activity_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ADD CONSTRAINT `fk_study_activity_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` SET TAGS ('dbx_usdm_class' = 'Activity');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ALTER COLUMN `activity_id` SET TAGS ('dbx_usdm_attribute' = 'Activity.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ALTER COLUMN `activity_description` SET TAGS ('dbx_usdm_attribute' = 'Activity.description');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ALTER COLUMN `activity_name` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ALTER COLUMN `activity_name` SET TAGS ('dbx_usdm_attribute' = 'Activity.name');

ALTER TABLE `clinical_trials_ecm`.`study`.`activity` ALTER COLUMN `activity_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ADD CONSTRAINT `fk_study_scheduled_activity_instance_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `clinical_trials_ecm`.`study`.`activity`(`activity_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ADD CONSTRAINT `fk_study_scheduled_activity_instance_encounter_id` FOREIGN KEY (`encounter_id`) REFERENCES `clinical_trials_ecm`.`study`.`encounter`(`encounter_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ADD CONSTRAINT `fk_study_scheduled_activity_instance_schedule_timeline_id` FOREIGN KEY (`schedule_timeline_id`) REFERENCES `clinical_trials_ecm`.`study`.`schedule_timeline`(`schedule_timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ADD CONSTRAINT `fk_study_scheduled_activity_instance_study_design_id` FOREIGN KEY (`study_design_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_design`(`study_design_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ADD CONSTRAINT `fk_study_scheduled_activity_instance_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_subdomain' = 'visit_scheduling');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` SET TAGS ('dbx_usdm_class' = 'ScheduledActivityInstance');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ALTER COLUMN `scheduled_activity_instance_id` SET TAGS ('dbx_usdm_attribute' = 'ScheduledActivityInstance.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ALTER COLUMN `activity_id` SET TAGS ('dbx_usdm_attribute' = 'ScheduledActivityInstance.activityIds');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ALTER COLUMN `encounter_id` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`scheduled_activity_instance` ALTER COLUMN `encounter_id` SET TAGS ('dbx_usdm_attribute' = 'ScheduledActivityInstance.encounterId');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` ADD CONSTRAINT `fk_study_study_version_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` SET TAGS ('dbx_usdm_class' = 'StudyVersion');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` ALTER COLUMN `study_version_id` SET TAGS ('dbx_usdm_attribute' = 'StudyVersion.id');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` ALTER COLUMN `rationale` SET TAGS ('dbx_usdm_attribute' = 'StudyVersion.rationale');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` ALTER COLUMN `version_identifier` SET TAGS ('dbx_standard' = 'CDISC_USDM');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_version` ALTER COLUMN `version_identifier` SET TAGS ('dbx_usdm_attribute' = 'StudyVersion.versionIdentifier');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` ADD CONSTRAINT `fk_study_study_milestone_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` SET TAGS ('dbx_subdomain' = 'protocol_management');

ALTER TABLE `clinical_trials_ecm`.`study`.`study_milestone` SET TAGS ('dbx_metric_view_owner' = 'true');
