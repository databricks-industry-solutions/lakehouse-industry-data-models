-- Schema for Domain: study | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:49

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`study` COMMENT 'Core operational domain managing clinical study protocols, design, phases, objectives, endpoints, inclusion/exclusion criteria, visit schedules, and study lifecycle from protocol development through database lock.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`protocol` (
    `protocol_id` BIGINT COMMENT 'Unique surrogate identifier for the clinical study protocol record in the lakehouse. Primary key for the protocol data product.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: ICH E6(R2) GCP requires protocol development and amendment to follow documented SOPs.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Protocols are developed in alignment with the sponsors regulatory strategy (submission pathway, health authority requirements, special designations).',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: The original protocol submission (IND/CTA initial filing) is housed in a regulatory binder distinct from amendment binders.',
    `study_id` BIGINT COMMENT 'Foreign key linking to study.study. Business justification: A clinical study protocol belongs to exactly one study. The protocol table currently has no FK to study, creating a gap in the relational graph.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: The DIA TMF Reference Model defines a specific artifact for the clinical protocol. Linking protocol to its tmf_artifact definition enables automated TMF completeness scoring, inspection',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: GCP and ICH E6 require the approved protocol document to be filed as an essential TMF document.',
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
    `protocol_status` STRING COMMENT 'Current lifecycle state of the protocol version. draft indicates under development; approved indicates IRB/IEC and sponsor approval obtained; amended indicates a formal amendment is in effect; superseded indicates replaced by a newer version. Valid values are `draft|approved|amended|superseded|final|retired`',
    `registry_identifier` STRING COMMENT 'Public clinical trial registry identifier such as ClinicalTrials.gov NCT number (e.g., NCT12345678) or WHO ICTRP identifier. Required by ICMJE for publication eligibility and by FDA/EMA for transparency. Sourced from the source system',
    `regulatory_submission_status` STRING COMMENT 'Status of the regulatory authority submission for this protocol version or amendment (e.g., IND amendment to FDA, CTA variation to EMA/MHRA). Tracks compliance with regulatory notification and approval requirements.. Valid values are `not_required|pending|submitted|approved|rejected`',
    `short_title` STRING COMMENT 'Abbreviated or lay-language title of the clinical study used in operational communications, CTMS displays, patient-facing materials, and internal reporting. Distinct from the full regulatory title.',
    `source_system_identifier` STRING COMMENT 'Native record identifier from the originating operational system (the source system study ID or Veeva Vault document ID). Enables bidirectional traceability between the lakehouse silver layer and the system of record for audit and reconciliation',
    `study_phase` STRING COMMENT 'ICH-defined phase of clinical development for the investigational product. Determines regulatory requirements, sample size expectations, and study design complexity. Not Applicable used for non-IND studies such as device or observational studies.',
    `study_population_description` STRING COMMENT 'Narrative description of the target patient population for the study, including disease characteristics, demographic parameters, and key eligibility criteria summary. Used in IRB/IEC submissions, regulatory filings, and patient recruitment materials.',
    `study_type` STRING COMMENT 'Broad classification of the study design indicating whether participants receive an intervention or are observed. Determines applicable regulatory framework, IRB review requirements, and reporting obligations.. Valid values are `interventional|observational|expanded_access|compassionate_use`',
    `title` STRING COMMENT 'Full official title of the clinical study protocol as it appears on the protocol document and regulatory submissions. Used in IRB/IEC submissions, clinical trial registries, and the Clinical Study Report (CSR).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this protocol record in the source system or lakehouse. Supports change tracking, audit trail requirements, and incremental data pipeline processing.',
    `version_number` STRING COMMENT 'Version identifier of the protocol document (e.g., 1.0, 2.0, 3.1). Combined with protocol_number, uniquely identifies a specific iteration of the protocol. Incremented with each formal amendment. Sourced from Veeva Vault.',
    CONSTRAINT pk_protocol PRIMARY KEY(`protocol_id`)
) COMMENT 'Master record for the clinical study protocol including all formal amendments (version history). Captures protocol number, version, title, phase, therapeutic area, indication, investigational product, study design parameters (allocation method';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` (
    `study_protocol_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol amendment record in the lakehouse silver layer. Primary key for this entity.',
    `amendment_regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Protocol amendments are submitted as IND amendments or CTA variations filed in regulatory binders.',
    `amendment_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Each protocol amendment generates a TMF essential document (DIA TMF Zone 4). Amendment tracking and TMF completeness assessments require linking the amendment record to its filed TMF',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: A protocol amendment is by definition an amendment TO a specific protocol version. The study_protocol_amendment table currently has study_id but no direct FK to the protocol it amends.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Protocol amendments that add stratification factors or change allocation ratios trigger new rand_scheme versions.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Regulatory affairs teams must link each internal study amendment record to its corresponding regulatory submission record in the regulatory domain.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this protocol amendment belongs. Links the amendment to the study master record.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: GCP requires that when an amendment triggers ICF updates (icf_version_updated_flag, reconsent_required_flag), the specific new ICF version is traceable to the amendment.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`study` (
    `study_id` BIGINT COMMENT 'Unique surrogate identifier for the clinical study record in the lakehouse Silver layer. Primary key for the study_study entity. Sourced from the source system',
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
    `study_type` STRING COMMENT 'The fundamental classification of the clinical study design indicating whether participants receive an investigational intervention (Interventional), are observed without intervention (Observational), or receive investigational product outside a trial. Valid values are `Interventional|Observational|Expanded Access`',
    `target_enrollment` BIGINT COMMENT 'The planned total number of subjects to be enrolled across all study sites as specified in the approved protocol and statistical analysis plan (the source system). Drives site allocation, recruitment planning, and power calculations.',
    `termination_reason` STRING COMMENT 'The documented reason for early termination of the clinical study when study_status is Terminated. Captures the primary rationale (e.g., Safety Concerns, Lack of Efficacy, Business Decision, Regulatory Hold, Enrollment Failure).',
    `title` STRING COMMENT 'The complete official title of the clinical study as stated in the approved protocol document. Used in regulatory submissions, IRB/IEC applications, informed consent forms, and the Trial Master File.',
    `tmf_archival_date` DATE COMMENT 'The date on which the Trial Master File (TMF) was formally archived following study close-out. The TMF must be retained for a minimum of 15 years (or longer per regional requirements) after study completion. Tracked in Veeva Vault eTMF.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when the study record was most recently modified in the source system (the source system Supports incremental data loading, change detection, and audit trail requirements per 21 CFR Part 11.',
    CONSTRAINT pk_study PRIMARY KEY(`study_id`)
) COMMENT 'Top-level master entity representing a clinical trial as a business and operational unit. Captures the unique study identifier (sponsor study number, ClinicalTrials.gov NCT number, EudraCT number), study title, acronym, therapeutic area, indication';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`arm` (
    `arm_id` BIGINT COMMENT 'Unique surrogate identifier for each study arm record in the lakehouse Silver layer. Primary key for the study_arm data product.',
    `investigational_product_id` BIGINT COMMENT 'FK to study.investigational_product',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Protocol design and IRT configuration require each study arm to reference its governing randomization scheme.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this arm belongs. Links the arm to its governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Treatment arms are defined and potentially modified by protocol amendments. The arm table currently has protocol_version_ref (STRING) which is a denormalized text reference to',
    `adaptive_design_flag` BOOLEAN COMMENT 'Indicates whether this arm is part of an adaptive trial design where arm allocation, sample size, or continuation may be modified based on interim analysis results per a pre-specified adaptation rule.',
    `allocation_ratio` DECIMAL(10,4) COMMENT 'The ratio used to allocate subjects to this arm relative to other arms in the study design.',
    `arm_status` STRING COMMENT 'Current lifecycle status of the study arm, reflecting whether the arm is planned, actively enrolling, suspended, closed to enrollment, or discontinued per protocol amendment.. Valid values are `Planned|Active|Suspended|Closed|Discontinued`',
    `arm_type` STRING COMMENT 'The arm type of the arm.',
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
    `randomization_ratio` DECIMAL(18,2) COMMENT 'The allocation ratio for randomization of subjects into this arm relative to other arms (e.g., 1:1, 2:1:1). Used by the RTSM/IRT system (Medidata Rave RTSM) to control subject assignment.',
    `randomization_ratio_numeric` DECIMAL(5,2) COMMENT 'Numeric representation of the allocation weight for this arm relative to total allocation (e.g., 0.50 for a 1:1 ratio arm). Supports quantitative analysis and reporting of enrollment balance.',
    `safety_population_flag` BOOLEAN COMMENT 'Indicates whether subjects enrolled in this arm are included in the safety analysis population (all subjects who received at least one dose of study treatment), as defined in the the source system.',
    `sdtm_arm_domain` STRING COMMENT 'CDISC SDTM domain identifier confirming this arm maps to the ARM domain in the SDTM submission dataset. Always ARM per CDISC standard; included for regulatory submission traceability.. Valid values are `^ARM$`',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number defining the display and processing order of arms within the study. Used for consistent ordering in reports, eCRFs, and SDTM datasets.',
    `start_date` DATE COMMENT 'The date on which the study arm became active and eligible for subject enrollment, as defined in the approved protocol or protocol amendment. Supports enrollment timeline tracking.',
    `treatment_duration_days` BIGINT COMMENT 'Planned duration of treatment for subjects in this arm, expressed in days. Used for supply planning, visit schedule design, and protocol compliance monitoring.',
    `updated_by` STRING COMMENT 'The username or system identifier of the user or process that last modified this study arm record. Required for audit trail compliance under FDA 21 CFR Part 11 and ALCOA+ (Attributable) principle.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this study arm record was last modified, in ISO 8601 format with timezone offset. Supports audit trail requirements and change tracking under 21 CFR Part 11.',
    `created_by` STRING COMMENT 'The username or system identifier of the user or process that created this study arm record. Required for audit trail compliance under FDA 21 CFR Part 11 and ALCOA+ (Attributable) principle.',
    CONSTRAINT pk_arm PRIMARY KEY(`arm_id`)
) COMMENT 'Defines each treatment arm or cohort within a clinical study. Records arm name, arm code, arm type (experimental, active comparator, placebo comparator, sham comparator, no intervention, other), description of intervention, planned number of subjects per';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`endpoint` (
    `endpoint_id` BIGINT COMMENT 'Unique surrogate identifier for a study endpoint record in the lakehouse silver layer. Primary key for the study_endpoint data product.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this endpoint belongs. Links the endpoint to its governing protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Endpoints are formally defined in the protocol and can be added, modified, or removed via protocol amendments.',
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
    `endpoint_status` STRING COMMENT 'Current lifecycle state of the endpoint definition: draft (under authoring), active (protocol-approved), amended (modified via protocol amendment), retired (removed from protocol), locked (post-Database Lock). Drives the source system. Valid values are `draft|active|amended|retired|locked`',
    `endpoint_type` STRING COMMENT 'Classification of the endpoint role within the study hierarchy: primary (confirmatory, drives sample size), secondary (supportive), exploratory, safety, Pharmacokinetic (PK), Pharmacodynamic (PD), or biomarker.',
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
    `unit_of_measure` STRING COMMENT 'The unit in which the endpoint outcome is expressed (e.g., months, mg/dL, mmHg, score, %, events/patient-year). Required for ADaM AVALU mapping and regulatory submission.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this endpoint record was most recently modified, in ISO 8601 format with timezone offset. Supports ALCOA+ audit trail and change control requirements.',
    CONSTRAINT pk_endpoint PRIMARY KEY(`endpoint_id`)
) COMMENT 'Defines the formal objectives and their associated endpoints (primary, secondary, exploratory) for a clinical study. Captures objective text, objective type, endpoint name, endpoint type (primary, secondary, exploratory, safety, PK, PD, biomarker)';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` (
    `eligibility_criterion_id` BIGINT COMMENT 'Unique surrogate identifier for each eligibility criterion record in the clinical study. Primary key for the eligibility_criterion data product.',
    `previous_criterion_eligibility_criterion_id` BIGINT COMMENT 'Reference to the prior version of this criterion that was superseded by the current record. Enables full version history chain for audit trail and regulatory traceability of criterion evolution across protocol amendments.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version under which this criterion was introduced or last modified. Supports amendment-driven criterion tracking.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` (
    `study_visit_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for each study visit schedule record in the lakehouse. Primary key for the study_visit_schedule data product.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: In clinical trials, the Schedule of Events (SoE) can be arm-specific — different treatment arms may have different visit frequencies, procedures, or timing windows.',
    `codelist_id` BIGINT COMMENT 'Classification of the visit by its functional role in the study timeline. Drives site operational planning, subject visit tracking in CTMS, and CDISC SDTM epoch mapping.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: study_visit_schedule has epoch_name as a STRING but no FK to study_epoch. Visits in the Schedule of Events belong to specific study epochs (Screening, Treatment, Follow-up) — this FK',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version or amendment under which this visit schedule was defined. Enables tracking of schedule changes across protocol amendments.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this visit schedule is defined. Links the Schedule of Events (SoE) to its governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: study_visit_schedule has amendment_number as a STRING but no FK to study_protocol_amendment.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`epoch` (
    `epoch_id` BIGINT COMMENT 'Unique surrogate identifier for a study epoch record in the lakehouse Silver layer. Primary key for the study_epoch data product.',
    `codelist_id` BIGINT COMMENT 'Controlled vocabulary classification of the epochs functional purpose within the study design. Drives SDTM dataset construction and subject disposition analysis.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version that defines this epoch. Epochs may be added, removed, or modified across protocol amendments.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this epoch belongs. Links the epoch to its governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: study_epoch has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `ae_reporting_applicable` BOOLEAN COMMENT 'Indicates whether adverse event (AE) and serious adverse event (SAE) collection and reporting obligations are active during this epoch. Drives safety data collection rules in the EDC and the source system',
    `blinding_type` STRING COMMENT 'Blinding methodology applied during this epoch as specified in the protocol. Determines data access controls and unblinding procedures applicable to the epoch period.. Valid values are `OPEN-LABEL|SINGLE-BLIND|DOUBLE-BLIND|TRIPLE-BLIND|NOT-APPLICABLE`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this epoch record was first created in the lakehouse Silver layer. Supports audit trail requirements under FDA 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `epoch_description` STRING COMMENT 'Textual description of the study epoch, including its purpose and duration.',
    `effective_end_date` DATE COMMENT 'Date on which this epoch definition version ceased to be effective, typically due to a protocol amendment superseding it. Null for the currently active epoch definition version.',
    `effective_start_date` DATE COMMENT 'Date from which this epoch definition version became effective in the study protocol. Used for amendment tracking and determining which epoch definition applies to a given subject enrollment date.',
    `epoch_status` STRING COMMENT 'Current lifecycle status of the epoch definition within the study protocol. DRAFT indicates under development; ACTIVE indicates approved and in use; AMENDED indicates modified by protocol amendment; SUPERSEDED indicates replaced by a newer version. Valid values are `DRAFT|ACTIVE|AMENDED|SUPERSEDED|RETIRED`',
    `epoch_type` STRING COMMENT 'The epoch type of the epoch.',
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
    `treatment_arm_specific` BOOLEAN COMMENT 'Indicates whether this epoch applies to a specific treatment arm only (True) or is common across all arms of the study (False). Relevant for crossover and multi-arm study designs.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this epoch record was last modified in the lakehouse Silver layer. Supports change tracking, audit trail requirements, and incremental data pipeline processing.',
    `washout_epoch` BOOLEAN COMMENT 'Indicates whether this epoch is a washout period during which prior treatment effects are expected to dissipate before the next treatment period. Used in crossover study design analysis.',
    `window_after_days` BIGINT COMMENT 'Allowable number of days after the planned epoch start date within which the epoch transition is considered protocol-compliant. Used for protocol deviation assessment.',
    `window_before_days` BIGINT COMMENT 'Allowable number of days before the planned epoch start date within which the epoch transition is considered protocol-compliant. Used for protocol deviation assessment.',
    CONSTRAINT pk_epoch PRIMARY KEY(`epoch_id`)
) COMMENT 'Defines the temporal epochs (periods) of a clinical study such as Screening, Run-in, Treatment Period 1, Washout, Treatment Period 2, Follow-up, and Extension.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`country` (
    `country_id` BIGINT COMMENT 'Unique surrogate identifier for the study-country record. Primary key for the study_country data product in the Databricks Silver Layer.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: A CTA is issued per country enabling trial conduct. Country activation, enrollment start, and site initiation all depend on CTA status.',
    `cta_regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Each countrys CTA submission (tracked via cta_submission_date, cta_approval_date on study_country) is filed in a country-specific regulatory binder.',
    `health_authority_id` BIGINT COMMENT 'Reference to the governing regulatory authority responsible for clinical trial oversight in this country (e.g., FDA for US, EMA/national competent authority for EU member states, PMDA for Japan). Links to the health_authority reference product.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Country-level regulatory submissions (CTA, IND) are made against a specific protocol version.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Randomization schemes can be country-specific (rand_scheme.geographic_scope). Country-level IRT configuration, CTA submissions, and enrollment management require knowing which',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this country-level record is maintained. Links the country configuration to the study protocol.',
    `activated_site_count` BIGINT COMMENT 'Actual number of investigative sites that have been activated and authorized to enroll subjects in this country. Compared against planned_site_count for country-level site activation KPI reporting.',
    `activation_status` STRING COMMENT 'Overall operational activation status of the country within the study lifecycle, distinct from enrollment_status. Reflects the countrys readiness and operational state as tracked in the source system and the source system. Valid values are `not_started|in_startup|activated|suspended|closed`',
    `actual_enrolled_count` BIGINT COMMENT 'Actual number of subjects enrolled (consented and randomized or screened) in this country to date. Compared against planned_enrollment_target for enrollment performance reporting in Medidata Rave and the source system',
    `actual_screened_count` BIGINT COMMENT 'Actual number of subjects screened at sites in this country to date. Used to calculate the realized screen failure rate and to assess enrollment efficiency.',
    `budget_amount` DECIMAL(18,2) COMMENT 'Total approved budget allocated for all study activities in this country, expressed in the countrys local currency (see currency_code). Sourced from the source system accounting and used for country-level financial performance tracking.',
    `country_code` STRING COMMENT 'Two-letter ISO 3166-1 alpha-2 country code identifying the country where the clinical study is conducted (e.g., US, DE, JP). Used as the primary geographic identifier for regulatory and enrollment reporting.. Valid values are `^[A-Z]{2}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this study-country record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ data integrity principles and audit trail requirements.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`investigational_product` (
    `investigational_product_id` BIGINT COMMENT 'Unique surrogate identifier for the investigational medicinal product (IMP) or investigational device record in the lakehouse silver layer. Primary key for this master resource entity.',
    `country_registration_id` BIGINT COMMENT 'Foreign key linking to regulatory.country_registration. Business justification: An investigational product may have existing country registrations (approved comparators, reference products).',
    `imp_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The Investigational Medicinal Product Dossier (IMPD) / Investigators Brochure is a DIA TMF Zone 4 essential document.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: An investigational product is authorized for clinical use under a specific IND/IMPD.',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.nda_bla_application. Business justification: For late-phase trials, the investigational product is the subject of an NDA/BLA.',
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
    `investigational_product_status` STRING COMMENT 'Current lifecycle status of the investigational product master record (e.g., active for ongoing studies, discontinued if development halted, superseded if replaced by a new formulation). Drives supply chain and regulatory workflow decisions.. Valid values are `active|inactive|discontinued|on_hold|superseded`',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` (
    `dosing_regimen_id` BIGINT COMMENT 'Unique surrogate identifier for the dosing regimen record within the Clinical Trials data platform. Primary key for the dosing_regimen product in the study domain.',
    `arm_id` BIGINT COMMENT 'Reference to the study arm (treatment group) to which this dosing regimen applies. A study may have multiple arms each with distinct regimens (e.g., active drug arm vs. placebo arm).',
    `codelist_id` BIGINT COMMENT 'the pharmaceutical dose form from CDISC CT codelist FRM (C66726)',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.epoch. Business justification: A dosing regimen is administered during a specific study epoch (e.g., a loading dose regimen during the Run-in epoch, a maintenance regimen during the Treatment epoch).',
    `investigational_product_id` BIGINT COMMENT 'Reference to the investigational product (IP) being administered under this dosing regimen. Supports traceability from regimen to supply chain and accountability logs.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this dosing regimen is defined. Links the regimen to the study protocol and all associated study-level metadata.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: dosing_regimen has amendment_number as a STRING but no FK to study_protocol_amendment.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: A dosing regimen is the operational specification of what a treatment_arm administers.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`study`.`objective` (
    `objective_id` BIGINT COMMENT 'Unique surrogate identifier for a study objective record in the clinical trial data platform. Primary key for the study_objective entity.',
    `primary_endpoint_id` BIGINT COMMENT 'Reference to the primary endpoint directly associated with this objective. Establishes the objective-to-endpoint traceability chain required by the the source system submissions. Nullable for objectives that map to multiple endpoints.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this objective belongs. Links the objective to its governing protocol and study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Study objectives are formally documented in the protocol and can be revised via amendments.',
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
    `multiplicity_adjustment_required` BOOLEAN COMMENT 'Indicates whether statistical multiplicity adjustment (e.g., Bonferroni, Hochberg, hierarchical testing) is required for this objective due to multiple comparisons. Informs the the source system strategy.',
    `notes` STRING COMMENT 'Free-text field for additional context, clarifications, or internal commentary related to this objective that does not fit structured fields. Used by data managers and biostatisticians during protocol development and the source system',
    `number` STRING COMMENT 'Structured alphanumeric identifier for the objective within the protocol (e.g., P-1 for Primary Objective 1, S-2 for Secondary Objective 2). Used for cross-referencing in the Statistical Analysis Plan (the source system) and Clinical Study Report (CSR).. Valid values are `^[A-Z0-9]{1,2}-[0-9]{1,3}$`',
    `objective_status` STRING COMMENT 'Current lifecycle state of the study objective. Draft objectives are under authoring review; active objectives are in the approved protocol; amended objectives have been modified by a protocol amendment; superseded objectives have been replaced; retired. Valid values are `draft|active|amended|superseded|retired`',
    `objective_type` STRING COMMENT 'Classification of the study objective by its scientific hierarchy and regulatory weight. Primary objectives drive the primary endpoint and sample size calculation; secondary objectives provide supportive evidence; exploratory objectives generate. Valid values are `primary|secondary|exploratory|safety|pharmacokinetic|pharmacodynamic`',
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
    `summary_measure` STRING COMMENT 'Statistical summary measure used to quantify the treatment effect for this objective (e.g., difference in means, odds ratio, hazard ratio, response rate difference). Corresponds to the population-level summary attribute of the ICH E9(R1) estimand.',
    `testing_hierarchy_level` BIGINT COMMENT 'Numeric level in the hierarchical testing procedure for this objective. Level 1 is tested first; subsequent levels are tested only if the preceding level achieves statistical significance.',
    `text` STRING COMMENT 'Full verbatim text of the study objective as stated in the approved protocol. This is the authoritative scientific statement of what the study aims to demonstrate or evaluate, used verbatim in regulatory submissions and the CSR.',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication to which this objective is aligned (e.g., Oncology, Cardiology, Neurology). Supports cross-study analytics and portfolio-level objective benchmarking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this study objective record in the data platform. Required for change tracking, data lineage, and compliance with 21 CFR Part 11 audit trail requirements.',
    `variable_description` STRING COMMENT 'Description of the variable (outcome measure) used to address this objective, as defined in the ICH E9(R1) estimand framework. Specifies what is measured on each subject to evaluate the treatment effect.',
    CONSTRAINT pk_objective PRIMARY KEY(`objective_id`)
) COMMENT 'Formally documents the primary, secondary, and exploratory objectives of a clinical study as stated in the protocol. Captures objective number, objective type (primary, secondary, exploratory), objective text, associated endpoint references, ICH E9(R1)';

ALTER SCHEMA `clinical_trials_mvm`.`study` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`study` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'randomized|non-randomized|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_standard_element' = 'StudyDesign.subTypes');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.allocationMethod');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `allocation_method` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard_element' = 'StudyAmendment.date');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_standard_element' = 'StudyAmendment.number');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.number');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_standard_element' = 'StudyAmendment.summary');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.rationale');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non-substantial|administrative');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard_element' = 'StudyAmendment.changes');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_usdm_class' = 'StudyAmendment');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_usdm_attribute' = 'StudyAmendment.changeType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Approval Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `approval_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `dsmb_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT / CTIS Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `gcp_compliance_declaration` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Declaration');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `ich_compliance_declaration` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation (ICH) Compliance Declaration');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_value_regex' = 'single_group|parallel|crossover|factorial|sequential');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_implements' = 'USDM StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_standard_element' = 'InterventionalStudyDesign.model');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `intervention_model` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|waived');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_business_glossary_term' = 'Adaptive Design Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.characteristics');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_adaptive_design` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Study Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_usdm_class' = 'StudyPopulation');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_usdm_attribute' = 'StudyPopulation.plannedAge');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_business_glossary_term' = 'Masking Type (Blinding)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind|quadruple_blind');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `masking_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_implements' = 'USDM StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Study Arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard_element' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Duration (Months)');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyDuration');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_duration_months` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.plannedSubjectCount');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_sample_size` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_standard_element' = 'Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_endpoint` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_standard_element' = 'Objective.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_usdm_attribute' = 'Objective.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_objective` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_implements' = 'USDM StudyDesign.trialIntentType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_standard_element' = 'StudyDesign.intentType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `primary_purpose` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_value_regex' = 'draft|approved|amended|superseded|final|retired');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolStatus');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolStatus');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `protocol_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Registry Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `registry_identifier` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `regulatory_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|rejected');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Short Title');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.shortTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `short_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_usdm_class' = 'StudyPopulation');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_usdm_attribute' = 'StudyPopulation.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_population_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'interventional|observational|expanded_access|compassionate_use');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `study_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Full Title');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.officialTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_implements' = 'USDM StudyVersion.versionIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ALTER COLUMN `version_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Document Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `affected_sections` SET TAGS ('dbx_business_glossary_term' = 'Affected Protocol Sections');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_standard_element' = 'StudyAmendment.date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Description');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_standard_element' = 'StudyAmendment.summary');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|withdrawn|superseded');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Title');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_standard_element' = 'StudyAmendment.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non_substantial|administrative');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_standard_element' = 'StudyAmendment.changes');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Amendment Approver');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_business_glossary_term' = 'Amendment Change Category');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `change_category` SET TAGS ('dbx_standard_element' = 'StudyAmendmentReason.code');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `dsmb_dmc_recommendation_flag` SET TAGS ('dbx_business_glossary_term' = 'DSMB/DMC Recommendation Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Effective Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_standard_element' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `ema_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|validated|approved|rejected');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `fda_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged|approved|on_clinical_hold');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `icf_version_updated_flag` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Updated Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `impact_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Amendment Impact Assessment Summary');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `implementation_deadline` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Deadline');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|approved_with_conditions|rejected');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `pmda_submission_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged|approved|rejected');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_business_glossary_term' = 'Previous Protocol Version Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `previous_protocol_version` SET TAGS ('dbx_standard_element' = 'StudyProtocolVersion.protocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Amendment Rationale');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `rationale` SET TAGS ('dbx_standard_element' = 'StudyAmendmentReason.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `reconsent_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `safety_driven_flag` SET TAGS ('dbx_business_glossary_term' = 'Safety-Driven Amendment Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `sap_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Impact Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ALTER COLUMN `veeva_vault_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_usdm_attribute' = 'Study.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Study Acronym');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_standard_element' = 'StudyVersion.studyAcronym');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_usdm_attribute' = 'Study.studyAcronym');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `acronym` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrollment Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.enrolledSubjectCount');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'Open Label|Single Blind|Double Blind|Triple Blind');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `csr_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Submission Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `ctms_study_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Study Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_business_glossary_term' = 'Study Design Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.subTypes');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.interventionModel');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `design_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_usdm_class' = 'StudyProtocolVersion');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_usdm_attribute' = 'StudyProtocolVersion.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `edc_study_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Study Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Initial Approval Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_business_glossary_term' = 'Randomization Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_standard_element' = 'StudyDesign.characteristics');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.allocationMethod');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `is_randomized` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_business_glossary_term' = 'ClinicalTrials.gov NCT Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_value_regex' = '^NCT[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `nct_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Study Arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard_element' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.arms');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_class' = 'GovernanceDate');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_usdm_attribute' = 'GovernanceDate.dateValue');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `primary_regulatory_region` SET TAGS ('dbx_value_regex' = 'US|EU|JP|AU|CA|GLOBAL');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_usdm_class' = 'StudyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_usdm_attribute' = 'StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `sponsor_study_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_business_glossary_term' = 'Study Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_value_regex' = 'Planned|Startup|Active|On Hold|Completed|Terminated');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_status` SET TAGS ('dbx_standard_element' = 'StudyVersion.status');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'Interventional|Observational|Expanded Access');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_standard_element' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.studyType');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `study_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Target Enrollment Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_standard_element' = 'Population.plannedEnrollmentNumber');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_usdm_class' = 'StudyDesign');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_usdm_attribute' = 'StudyDesign.plannedSubjectCount');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `target_enrollment` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Study Termination Reason');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Study Full Title');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_standard_element' = 'StudyTitle.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_usdm_class' = 'Study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_usdm_attribute' = 'Study.studyTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `tmf_archival_date` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Archival Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_status` SET TAGS ('dbx_value_regex' = 'Planned|Active|Suspended|Closed|Discontinued');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'Open Label|Single Blind|Double Blind|Triple Blind');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'Masking.isMasked');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `clinical_one_arm_code` SET TAGS ('dbx_business_glossary_term' = 'Oracle Clinical One Arm Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,20}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_implements' = 'USDM StudyArm.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_standard_element' = 'StudyArm.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_code` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `ctms_arm_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Arm Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `discontinuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Arm Discontinuation Reason');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_standard_element' = 'EX.EXDOSE');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_usdm_attribute' = 'StudyIntervention.dose');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dose_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_usdm_class' = 'StudyIntervention');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_usdm_attribute' = 'StudyIntervention.frequency');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Arm End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_standard_element' = 'StudyIntervention.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_standard_element' = 'StudyIntervention.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `intervention_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Arm Indicator');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_business_glossary_term' = 'Control Arm Indicator');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_standard_element' = 'StudyArm.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `itt_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `max_subjects_count` SET TAGS ('dbx_business_glossary_term' = 'Maximum Subjects Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `min_subjects_count` SET TAGS ('dbx_business_glossary_term' = 'Minimum Subjects Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_implements' = 'USDM StudyArm.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_standard_element' = 'StudyArm.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `arm_name` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Arm Notes');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `pp_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_standard_element' = 'StudyArm.populationNumber');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.populationNumber');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `randomization_ratio` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Study Data Tabulation Model (SDTM) Arm Domain');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_value_regex' = '^ARM$');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sdtm_arm_domain` SET TAGS ('dbx_standard_element' = 'TA.ARMCD');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Arm Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_class' = 'StudyArm');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_attribute' = 'StudyArm.studyArmSequence');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Arm Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Treatment Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `treatment_duration_days` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ADD CONSTRAINT `fk_study_endpoint_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Study Endpoint ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Code (PARAMCD)');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Name (PARAM)');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `adam_parameter_name` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Significance Level)');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `analysis_population` SET TAGS ('dbx_value_regex' = 'ITT|mITT|PP|safety|PK|biomarker');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_category` SET TAGS ('dbx_value_regex' = 'efficacy|safety|tolerability|PK_PD|quality_of_life|biomarker');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_value_regex' = '^EP-[A-Z0-9]{2,10}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_standard_element' = 'Endpoint.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_code` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_implements' = 'USDM Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_standard_element' = 'Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `directionality` SET TAGS ('dbx_business_glossary_term' = 'Test Directionality');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `directionality` SET TAGS ('dbx_value_regex' = 'one_sided|two_sided');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|retired|locked');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_implements' = 'USDM Endpoint.level');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_standard_element' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.level');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_value_regex' = 'treatment_policy|hypothetical|composite|while_on_treatment|principal_stratum');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_standard_element' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_usdm_class' = 'IntercurrentEvent');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_usdm_attribute' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_intercurrent_event_strategy` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_business_glossary_term' = 'Estimand Target Population');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_standard_element' = 'Estimand.analysisPopulation');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_usdm_attribute' = 'Estimand.analysisPopulation');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_business_glossary_term' = 'Estimand Population-Level Summary');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_standard_element' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_usdm_attribute' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_population_level_summary` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_standard_element' = 'Estimand.intercurrentEvents');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_usdm_attribute' = 'Estimand.intervention');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_treatment_condition` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_business_glossary_term' = 'Estimand Variable (Endpoint Variable)');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_standard_element' = 'Estimand.variableOfInterest');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_usdm_class' = 'Estimand');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_usdm_attribute' = 'Estimand.variableOfInterest');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `estimand_variable` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_business_glossary_term' = 'Measurement Instrument or Scale');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.purpose');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `measurement_instrument` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard_element' = 'SOC.code');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Strategy');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `multiplicity_adjustment_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `multiplicity_adjustment_flag` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_business_glossary_term' = 'Multiplicity Adjustment Procedure');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `multiplicity_procedure` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_implements' = 'USDM Endpoint.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_standard_element' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_usdm_attribute' = 'Endpoint.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_usdm_class' = 'Endpoint');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority Margin');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_implements' = 'USDM Objective.level');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'Medidata_Rave|Oracle_Clinical_One|SAS_Drug_Development|manual');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `source_system_endpoint_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Endpoint Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `statistical_hypothesis` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|descriptive');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_standard_element' = 'Findings.--ORRESU');

ALTER TABLE `clinical_trials_mvm`.`study`.`endpoint` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_previous_criterion_eligibility_criterion_id` FOREIGN KEY (`previous_criterion_eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ADD CONSTRAINT `fk_study_eligibility_criterion_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `previous_criterion_eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Criterion ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_value_regex' = 'ALL|FEMALE_ONLY|MALE_ONLY|PEDIATRIC|ADULT|ELDERLY');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `applicable_population` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `change_rationale` SET TAGS ('dbx_business_glossary_term' = 'Criterion Change Rationale');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_business_glossary_term' = 'Case Report Form (CRF) Page Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `crf_page_reference` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.category');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.category');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_category` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion.identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_short_name` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_status` SET TAGS ('dbx_value_regex' = 'DRAFT|ACTIVE|SUPERSEDED|RETIRED');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_text` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_value_regex' = 'INCLUSION|EXCLUSION');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_implements' = 'USDM EligibilityCriterion.category');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_standard_element' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.category');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `criterion_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_usdm_class' = 'EligibilityCriterion');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_usdm_attribute' = 'EligibilityCriterion.criterionSequence');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `display_order` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `edc_field_oid` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Field Object Identifier (OID)');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Criterion Effective Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) / Independent Ethics Committee (IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `is_amendment_driven` SET TAGS ('dbx_business_glossary_term' = 'Amendment-Driven Change Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `is_critical_criterion` SET TAGS ('dbx_business_glossary_term' = 'Critical Criterion Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `lab_test_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_standard_element' = 'PT.code');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `numeric_threshold_comparator` SET TAGS ('dbx_value_regex' = 'EQ|NE|LT|LE|GT|GE');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `requires_source_doc_verification` SET TAGS ('dbx_business_glossary_term' = 'Source Document Verification (SDV) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Criterion Retirement Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Inclusion/Exclusion (IE) Test Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,8}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `sdtm_ie_testcd` SET TAGS ('dbx_standard_element' = 'IE.IETESTCD');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `source_system_criterion_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Criterion ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `time_window_unit` SET TAGS ('dbx_value_regex' = 'DAYS|WEEKS|MONTHS|YEARS');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `waiver_allowed` SET TAGS ('dbx_business_glossary_term' = 'Waiver Allowed Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_business_glossary_term' = 'World Health Organization Drug Dictionary (WHO-DD) Drug Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_mvm`.`study`.`eligibility_criterion` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_standard_element' = 'DrugRecord.code');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_usdm_attribute' = 'Encounter.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'USDM Encounter.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'VISITYP');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard_element' = 'Encounter.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_attribute' = 'Encounter.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_business_glossary_term' = 'CDISC Visit Reference Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_standard_element' = 'SV.VISIT');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_usdm_attribute' = 'Encounter.encounterId');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `cdisc_visit_reference` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `fasting_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Required Fasting Duration (Hours)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_dosing_visit` SET TAGS ('dbx_business_glossary_term' = 'Dosing Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_in_itt_population` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_in_pp_population` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Procedure Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_pk_sampling_visit` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Sampling Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_primary_endpoint_visit` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_randomization_visit` SET TAGS ('dbx_business_glossary_term' = 'Randomization Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `is_unscheduled` SET TAGS ('dbx_business_glossary_term' = 'Unscheduled Visit Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Schedule Notes');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_standard_element' = 'SV.VISITDY');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_usdm_attribute' = 'Timing.value');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `planned_study_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_business_glossary_term' = 'Procedure / Assessment Name');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `procedure_sequence` SET TAGS ('dbx_business_glossary_term' = 'Procedure Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `requires_central_lab` SET TAGS ('dbx_business_glossary_term' = 'Central Laboratory Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `requires_local_lab` SET TAGS ('dbx_business_glossary_term' = 'Local Laboratory Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `schedule_version` SET TAGS ('dbx_business_glossary_term' = 'Schedule of Events (SoE) Version');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `schedule_version` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Domain');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `source_system_visit_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Visit Identifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Planned Visit Duration (Minutes)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_implements' = 'SDTM SV.VISIT');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard_element' = 'Encounter.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_usdm_attribute' = 'Encounter.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_implements' = 'SDTM SV.VISITNUM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard_element' = 'SV.VISITNUM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_usdm_attribute' = 'Encounter.encounterSequence');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_standard_element' = 'Encounter.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_usdm_class' = 'Encounter');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_usdm_attribute' = 'Encounter.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_short_label` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_status` SET TAGS ('dbx_business_glossary_term' = 'Visit Schedule Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `visit_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Window After (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_standard_element' = 'Timing.windowUpper');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_usdm_attribute' = 'Timing.windowUpper');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_after_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Before (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_standard_element' = 'Timing.windowLower');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_usdm_class' = 'Timing');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_usdm_attribute' = 'Timing.windowLower');

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ALTER COLUMN `window_before_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'USDM StudyEpoch.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard_element' = 'StudyEpoch.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'EPOCH');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `codelist_id` SET TAGS ('dbx_cdisc_ct' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `ae_reporting_applicable` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Reporting Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'OPEN-LABEL|SINGLE-BLIND|DOUBLE-BLIND|TRIPLE-BLIND|NOT-APPLICABLE');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard_element' = 'StudyEpoch.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_standard_element' = 'StudyEpoch.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Epoch Definition Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Epoch Definition Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_status` SET TAGS ('dbx_value_regex' = 'DRAFT|ACTIVE|AMENDED|SUPERSEDED|RETIRED');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `extension_epoch` SET TAGS ('dbx_business_glossary_term' = 'Extension Epoch Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `follow_up_epoch` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Epoch Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `ip_administered` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Administered Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `is_deleted` SET TAGS ('dbx_business_glossary_term' = 'Soft Delete Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `itt_population_epoch` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Epoch Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `maximum_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Epoch Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `minimum_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Minimum Epoch Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_implements' = 'USDM StudyEpoch.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard_element' = 'StudyEpoch.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `epoch_name` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Planned Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.duration');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_business_glossary_term' = 'Planned Duration ISO 8601');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_value_regex' = '^P(d+Y)?(d+M)?(d+W)?(d+D)?(T(d+H)?(d+M)?(d+S)?)?$');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_duration_iso` SET TAGS ('dbx_standard_element' = 'Duration.durationWillVary');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_business_glossary_term' = 'Planned End Day (Study Day)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.plannedEndDay');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_end_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_business_glossary_term' = 'Planned Start Day (Study Day)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.plannedStartDay');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `planned_start_day` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `primary_endpoint_epoch` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Epoch Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `randomization_applicable` SET TAGS ('dbx_business_glossary_term' = 'Randomization Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Epoch Code (ETCD)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_epoch_code` SET TAGS ('dbx_standard_element' = 'TA.EPOCH');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Trial Elements (TE) Domain Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sdtm_te_domain_flag` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Epoch Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard_element' = 'StudyEpoch.previousId');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.studyEpochSequence');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `sequence_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Epoch Short Name');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_standard_element' = 'StudyEpoch.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_usdm_attribute' = 'StudyEpoch.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `short_name` SET TAGS ('dbx_usdm_class' = 'StudyEpoch');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `source_system_epoch_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Epoch ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_value_regex' = 'ORACLE_CLINICAL_ONE|MEDIDATA_RAVE|MANUAL|OTHER');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `source_system_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Specific Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `treatment_arm_specific` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `washout_epoch` SET TAGS ('dbx_business_glossary_term' = 'Washout Epoch Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `window_after_days` SET TAGS ('dbx_business_glossary_term' = 'Epoch Window After (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ALTER COLUMN `window_before_days` SET TAGS ('dbx_business_glossary_term' = 'Epoch Window Before (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` SET TAGS ('dbx_subdomain' = 'trial_operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `cta_regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Cta Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `activation_status` SET TAGS ('dbx_business_glossary_term' = 'Country Activation Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `activation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_startup|activated|suspended|closed');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `actual_enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrolled Subject Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `actual_screened_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Screened Subject Count');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Country-Level Study Budget Amount');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166-1 Alpha-2)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_element' = 'ISO 3166 country code');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Country Currency Code (ISO 4217)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Regulatory Framework');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `dropout_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Subject Dropout Rate Assumption');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `enrollment_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Rate Assumption (Subjects per Site per Month)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_business_glossary_term' = 'Country Enrollment Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_value_regex' = 'planned|active|enrollment_complete|on_hold|terminated|closed');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^d{4}-d{6}-d{2}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_implements' = 'USDM StudyIdentifier.studyIdentifier');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `feasibility_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Country Feasibility Assessment Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `feasibility_score` SET TAGS ('dbx_business_glossary_term' = 'Country Feasibility Score');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `icf_version_required` SET TAGS ('dbx_business_glossary_term' = 'Required Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `irb_iec_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Submission Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_business_glossary_term' = 'Local Language Code (IETF BCP 47)');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `local_language_code` SET TAGS ('dbx_pii_language' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_standard_element' = 'GeographicScope.code');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_business_glossary_term' = 'National Clinical Trial Registry Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `national_registry_number` SET TAGS ('dbx_standard_element' = 'StudyIdentifier.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `subject_data_transfer_allowed` SET TAGS ('dbx_business_glossary_term' = 'Subject Data Cross-Border Transfer Allowed Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` SET TAGS ('dbx_subdomain' = 'trial_operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `country_registration_id` SET TAGS ('dbx_business_glossary_term' = 'Country Registration Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `imp_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Nda Bla Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_business_glossary_term' = 'Active Pharmaceutical Ingredient (API) / Active Substance');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `active_substance` SET TAGS ('dbx_standard_element' = 'MedicalDevice.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `cas_number` SET TAGS ('dbx_business_glossary_term' = 'Chemical Abstracts Service (CAS) Registry Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `cas_number` SET TAGS ('dbx_value_regex' = '^[0-9]{2,7}-[0-9]{2}-[0-9]$');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `controlled_substance_schedule` SET TAGS ('dbx_value_regex' = 'schedule_I|schedule_II|schedule_III|schedule_IV|schedule_V|not_controlled');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `development_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `dosage_form` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `ema_product_number` SET TAGS ('dbx_business_glossary_term' = 'European Medicines Agency (EMA) Product Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `first_in_human_date` SET TAGS ('dbx_business_glossary_term' = 'First-in-Human (FIH) Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `formulation` SET TAGS ('dbx_business_glossary_term' = 'Formulation Description');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `imp_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `imp_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,30}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `impd_version` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product Dossier (IMPD) Version');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Submission Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `investigational_product_status` SET TAGS ('dbx_value_regex' = 'active|inactive|discontinued|on_hold|superseded');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Indicator');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `is_comparator` SET TAGS ('dbx_business_glossary_term' = 'Comparator Product Indicator');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `is_placebo` SET TAGS ('dbx_business_glossary_term' = 'Placebo Indicator');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `manufacturer_site` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Site');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `mechanism_of_action` SET TAGS ('dbx_business_glossary_term' = 'Mechanism of Action (MOA)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `ndc_number` SET TAGS ('dbx_business_glossary_term' = 'National Drug Code (NDC) Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `ndc_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4,5}-[0-9]{3,4}-[0-9]{1,2}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Notes');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `product_type` SET TAGS ('dbx_standard_element' = 'StudyIntervention.type');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|investigational|withdrawn|not_approved');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `retest_period_months` SET TAGS ('dbx_business_glossary_term' = 'Retest Period (Months)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `shelf_life_months` SET TAGS ('dbx_business_glossary_term' = 'Shelf Life (Months)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Strength');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength` SET TAGS ('dbx_standard_element' = 'AdministrableProduct.strength');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_business_glossary_term' = 'Strength Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `strength_unit` SET TAGS ('dbx_standard_element' = 'EX.EXDOSU');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_standard_element' = 'DrugRecord.drugCode');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` SET TAGS ('dbx_subdomain' = 'trial_operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Dose Form');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'FRM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_business_glossary_term' = 'CDISC ADaM Exposure (ADEX) Domain Mapping Notes');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `adam_adex_mapping_notes` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open-label|single-blind|double-blind|triple-blind');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `blinding_type` SET TAGS ('dbx_implements' = 'USDM StudyDesign.blindingSchema');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `comparator_type` SET TAGS ('dbx_value_regex' = 'active|placebo|vehicle|sham|no-treatment');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dose_escalation_step` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Step Number');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSE');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dose_level` SET TAGS ('dbx_standard_element' = 'EX.EXDOSE');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dose_reduction_levels` SET TAGS ('dbx_business_glossary_term' = 'Number of Dose Reduction Levels');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_implements' = 'SDTM EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_frequency` SET TAGS ('dbx_standard_element' = 'EX.EXDOSFRQ');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `dosing_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Dosing Interval (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Regimen Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Regimen Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `escalation_scheme_description` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Scheme Description');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `infusion_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Infusion Duration (Minutes)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `is_dose_escalation` SET TAGS ('dbx_business_glossary_term' = 'Dose Escalation Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `is_mtd` SET TAGS ('dbx_business_glossary_term' = 'Maximum Tolerated Dose (MTD) Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `loading_dose_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Loading Dose Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `pd_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Pharmacodynamics (PD) Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `pk_sampling_required` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Sampling Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Planned Dosing Duration (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `protocol_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_code` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Code');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Name');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_name` SET TAGS ('dbx_standard_element' = 'AdministrableProduct.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_status` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Status');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `regimen_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|discontinued|completed');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Exposure (EX) Domain Mapping Notes');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `sdtm_ex_mapping_notes` SET TAGS ('dbx_standard_element' = 'EX');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `treatment_period_label` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ALTER COLUMN `washout_period_days` SET TAGS ('dbx_business_glossary_term' = 'Washout Period (Days)');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_primary_endpoint_id` FOREIGN KEY (`primary_endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ADD CONSTRAINT `fk_study_objective_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` SET TAGS ('dbx_domain' = 'study');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` SET TAGS ('dbx_subdomain' = 'study_design');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_business_glossary_term' = 'Study Objective ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_usdm_attribute' = 'Objective.id');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_usdm_attribute' = 'Objective.endpoints');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `primary_endpoint_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `adam_dataset_reference` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Type I Error Rate)');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `ctd_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `dsmb_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reportable Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non-inferiority|equivalence|descriptive');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_value_regex' = 'while_on_treatment|hypothetical|composite|principal_stratum|treatment_policy');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_standard_element' = 'IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `irb_iec_review_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Review Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_business_glossary_term' = 'Multiplicity Adjustment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `multiplicity_adjustment_required` SET TAGS ('dbx_pii_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,2}-[0-9]{1,3}$');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_standard_element' = 'Objective.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_usdm_attribute' = 'Objective.name');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety|pharmacokinetic|pharmacodynamic');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_implements' = 'USDM Objective.level');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_usdm_attribute' = 'Objective.level');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_description` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_description` SET TAGS ('dbx_standard_element' = 'AnalysisPopulation.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Type');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_value_regex' = 'ITT|mITT|PP|safety|PK|PD');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `population_type` SET TAGS ('dbx_standard_element' = 'StudyDesignPopulation.description');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain Reference');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `sdtm_domain_reference` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_business_glossary_term' = 'Objective Short Title');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_implements' = 'USDM StudyVersion.studyTitle');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_usdm_attribute' = 'Objective.label');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `short_title` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `summary_measure` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `summary_measure` SET TAGS ('dbx_standard_element' = 'Estimand.populationSummary');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_business_glossary_term' = 'Objective Text');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_implements' = 'USDM Objective.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_standard_element' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_usdm_class' = 'Objective');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_usdm_attribute' = 'Objective.text');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `text` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`study`.`objective` ALTER COLUMN `variable_description` SET TAGS ('dbx_business_glossary_term' = 'Estimand Variable Description');
