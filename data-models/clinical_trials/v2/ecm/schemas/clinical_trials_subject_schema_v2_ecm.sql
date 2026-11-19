-- Schema for Domain: subject | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:35

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`subject` COMMENT 'SSOT for trial participants (subjects/patients) across all studies. Owns subject enrollment, demographics, randomization assignments via IRT/RTSM, treatment arms, visit compliance, protocol deviations, and subject disposition from screening through study';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`trial_subject` (
    `trial_subject_id` BIGINT COMMENT 'Unique surrogate identifier for a trial subject record in the lakehouse Silver layer. Primary key for the trial_subject entity. All subject-level transactional records in the subject domain reference this identifier.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: SDTM ACTARM/ARM derivation and enrollment-by-arm reporting require linking each subject to their assigned study_arm.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Regulatory compliance requires every enrolled subject to be traceable to the active CTA for their country.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: FDA 21 CFR Part 312 and ICH E6(R2) require that each enrolled subject is traceable to the specific IRB/IEC approval governing their enrollment, including approved ICF version and',
    `study_id` BIGINT COMMENT 'Reference to the clinical study in which this subject is enrolled or screened. Links the subject to the parent study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which this subject was screened or enrolled. Supports site-level enrollment analytics and monitoring.',
    `age_at_enrollment` BIGINT COMMENT 'Subjects age in years at the time of enrollment or first dose, calculated from date of birth and enrollment date. Used for eligibility verification, demographic reporting, and subgroup analyses.',
    `completion_date` DATE COMMENT 'Date on which the subject completed all required study procedures per protocol, including end-of-study visit. Used for subject disposition reporting, CSR preparation, and database lock readiness assessment.',
    `country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the investigational site where the subject is enrolled. Used for geographic stratification, regulatory jurisdiction determination, and multi-regional trial reporting. Corresponds to CDISC SDTM DM COUNTRY variable.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the trial subject record was first created in the lakehouse Silver layer. Supports ALCOA+ audit trail requirements and data lineage tracking. Stored in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX).',
    `data_lock_flag` BOOLEAN COMMENT 'Indicates whether the subjects data has been locked as part of the Database Lock (DBL) process, preventing further modifications to the subjects eCRF data. True = subject data locked; False = data still open for entry or query resolution.',
    `date_of_birth` DATE COMMENT 'Subjects date of birth used to calculate age at screening, enrollment, and key study milestones. Classified as restricted PHI/PII. Stored in yyyy-MM-dd format.',
    `eligible_flag` BOOLEAN COMMENT 'Indicates whether the subject met all inclusion and exclusion criteria as assessed during screening. True = all eligibility criteria confirmed met; False = one or more criteria not met. Sourced from the source system eligibility assessment.',
    `enrollment_date` DATE COMMENT 'Date on which the subject was formally enrolled in the study following confirmation of eligibility criteria. Distinct from screening date and randomization date. Used for enrollment tracking, site performance KPIs, and study timeline reporting.',
    `enrollment_status` STRING COMMENT 'Current lifecycle status of the subject within the study, reflecting their progression from screening through completion or withdrawal. Drives subject disposition reporting and ITT/PP population flags.',
    `ethnicity` STRING COMMENT 'Subjects self-reported ethnic origin as collected at screening, coded per CDISC SDTM controlled terminology. Distinct from race per FDA demographic reporting requirements. Used in regulatory demographic summary tables.. Valid values are `HISPANIC OR LATINO|NOT HISPANIC OR LATINO|NOT REPORTED|UNKNOWN`',
    `first_dose_date` DATE COMMENT 'Date on which the subject received the first dose of investigational product. Used as the reference anchor for treatment-emergent adverse event (TEAE) analysis, PK sampling schedules, and per-protocol population definitions.',
    `itt_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the Intent-to-Treat (ITT) analysis population as defined in the Statistical Analysis Plan (the source system). True = subject is in ITT population; False = excluded.',
    `last_dose_date` DATE COMMENT 'Date on which the subject received the last dose of investigational product. Used to define the end of the treatment-emergent window for adverse event analysis and to calculate treatment duration. Sourced from Medidata Rave EDC exposure domain.',
    `pp_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the Per Protocol (PP) analysis population as defined in the Statistical Analysis Plan (the source system). Subjects may be excluded from PP due to major protocol deviations, insufficient drug exposure, or',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether the subject has at least one recorded protocol deviation during the study. True = one or more deviations recorded; False = no deviations.',
    `race` STRING COMMENT 'Subjects self-reported racial category as collected at screening, coded per CDISC SDTM controlled terminology and FDA demographic reporting requirements. Used for regulatory demographic tables and diversity reporting.',
    `randomization_date` DATE COMMENT 'Date on which the subject was randomized to a treatment arm via the IRT/RTSM system. Defines the start of the treatment period and is used as the reference date for TEAE analysis windows and ITT population inclusion. Null for screen-failed subjects.',
    `randomization_number` STRING COMMENT 'Unique number assigned to a subject at the point of randomization via the IRT/RTSM system (Medidata Rave RTSM or the source system Determines treatment arm assignment and links to investigational product supply allocation.',
    `safety_population_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the safety analysis population (typically all randomized subjects who received at least one dose of investigational product). Used for adverse event incidence tables and safety reporting.',
    `screen_failure_reason` STRING COMMENT 'Reason why a screened subject did not proceed to enrollment, coded per protocol-defined eligibility criteria categories (e.g., INCLUSION CRITERIA NOT MET, EXCLUSION CRITERIA MET, SUBJECT WITHDREW CONSENT, INVESTIGATOR DECISION).',
    `screening_date` DATE COMMENT 'Date on which the subject first underwent screening procedures for the study, including signing of the Informed Consent Form (ICF). Marks the start of the subjects participation timeline. Sourced from the source system and Medidata Rave EDC.',
    `screening_number` STRING COMMENT 'Unique alphanumeric identifier assigned to a potential subject at the point of screening, prior to randomization or enrollment confirmation. Used to track pre-enrollment eligibility assessments. Sourced from the source system and Medidata Rave EDC.',
    `serious_adverse_event_flag` BOOLEAN COMMENT 'Indicates whether the subject has experienced at least one Serious Adverse Event (SAE) during the study. True = one or more SAEs reported; False = no SAEs.',
    `sex` STRING COMMENT 'Biological sex of the subject as recorded at screening. Coded per CDISC SDTM controlled terminology (M=Male, F=Female, U=Unknown, UNDIFFERENTIATED). Used for demographic reporting, eligibility criteria verification, and PK/PD subgroup analyses.. Valid values are `M|F|U|UNDIFFERENTIATED`',
    `source_subject_key` STRING COMMENT 'The native primary key or identifier for this subject record in the originating operational system (e.g., Medidata Rave subject OID, the source system patient ID).',
    `subject_number` STRING COMMENT 'Sponsor-assigned unique subject identifier within the study, typically formatted as site-subject (e.g., 001-0042). This is the primary operational identifier used across EDC, CTMS, and regulatory submissions. Corresponds to SUBJID in CDISC SDTM DM domain.',
    `subject_source_system` STRING COMMENT 'Identifies the operational system of record from which this subject record was sourced or is mastered (e.g., Medidata Rave EDC, the source system the source system Supports data lineage, reconciliation, and ALCOA+ compliance tracing.. Valid values are `Medidata Rave|Oracle Clinical One|Oracle Siebel CTMS`',
    `unique_subject_identifier` STRING COMMENT 'Globally unique subject identifier combining sponsor, study, and subject number (e.g., SPONSOR-STUDY-001-0042). Mandatory CDISC SDTM variable used across all regulatory submission datasets to unambiguously identify a subject across studies and submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the trial subject record was last modified in the lakehouse Silver layer. Used for incremental data pipeline processing, change detection, and audit trail compliance. Stored in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX).',
    `withdrawal_date` DATE COMMENT 'Date on which the subject withdrew from the study or was discontinued, if applicable. Null for subjects who completed the study. Used in subject disposition analysis and survival/time-to-event analyses.',
    `withdrawal_reason` STRING COMMENT 'Coded reason for subject withdrawal or discontinuation from the study, per CDISC SDTM DS domain controlled terminology (e.g., ADVERSE EVENT, WITHDRAWAL BY SUBJECT, PROTOCOL DEVIATION, LOST TO FOLLOW-UP, PHYSICIAN DECISION, DEATH).',
    CONSTRAINT pk_trial_subject PRIMARY KEY(`trial_subject_id`)
) COMMENT 'Core master entity representing a unique trial participant (subject/patient) screened or enrolled in a clinical study. Serves as the SSOT for subject identity including screening number, subject number, randomization number, demographic profile (age, sex';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`enrollment` (
    `enrollment_id` BIGINT COMMENT 'Unique surrogate identifier for the enrollment record in the Databricks Silver Layer. Primary key for this data product.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Enrollment records capture arm assignment; linking to study_arm enables CTMS arm-level enrollment closure decisions, randomization ratio compliance monitoring, and CSR enrollment flow tables.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Enrollment must be validated against the CTA for the subjects country — regulatory teams report enrollment counts per CTA to health authorities.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: ICH E6 GCP mandates informed consent precedes enrollment. The enrollment record must reference the specific subject_consent obtained at enrollment time for regulatory audit trail',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: Enrollment records must reference the exact ICF document version under which informed consent was obtained — a direct IRB/IEC and GCP regulatory requirement.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Coordinator (CRC) assigned to manage this subjects study activities at the site. Sourced from the source system',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Enrollment records must reference the governing IRB/IEC approval to validate that the ICF version used matches the approved version and that enrollment does not exceed the approved',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) responsible for the subjects care and study conduct at the investigational site. Sourced from the source system',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: ICH E6 GCP requires documenting which protocol version governed each subjects enrollment. FK to protocol enables protocol-version-level enrollment reporting, amendment impact assessment on',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Enrollment must reference the randomization scheme version active at enrollment time for protocol amendment tracking, SDTM SUPPDM population, and regulatory submissions requiring',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Enrollment coordinators must record which protocol amendment version was in effect at enrollment, especially when amendments change eligibility criteria or require reconsent.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this subject is being enrolled. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is being enrolled. Sourced from the source system site master.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Enrollment-to-randomization reconciliation is a standard CTMS data integrity check.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) master record. Links to the subject demographic and identity record.',
    `blinding_status` STRING COMMENT 'Indicates the blinding status of the subjects treatment assignment at the time of this record. blinded = treatment assignment is masked; unblinded = treatment assignment has been revealed (e.g., emergency unblinding or end-of-study unblinding). Valid values are `blinded|unblinded|open_label`',
    `cohort_code` STRING COMMENT 'Code identifying the study cohort or stratum to which the subject belongs, used in stratified randomization designs. Distinct from treatment arm — a cohort may span multiple arms.',
    `completion_date` DATE COMMENT 'Date on which the subject completed all required study procedures and visits per the protocol. Populated only when enrollment_status = completed. Used for study close-out and CSR reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this enrollment record was first created in the data platform. RECORD_AUDIT_CREATED category. Supports ALCOA+ auditability and data lineage requirements.',
    `enrollment_date` DATE COMMENT 'Date on which the subject was formally enrolled into the clinical study following confirmation of eligibility and completion of informed consent. BUSINESS_EVENT_TIMESTAMP (date precision) for this enrollment transaction. Sourced from the source system',
    `eligibility_confirmed` BOOLEAN COMMENT 'Indicates whether the subject has been confirmed as meeting all inclusion/exclusion criteria defined in the study protocol prior to enrollment. True = all criteria verified; False = criteria not yet confirmed or subject failed screening.',
    `first_dose_date` DATE COMMENT 'Date on which the subject received the first dose of investigational product (IP). Defines the start of the treatment-emergent period for TEAE analysis. Sourced from Medidata Rave EDC.',
    `icf_signed_date` DATE COMMENT 'Date on which the subject (or legally authorized representative) signed the Informed Consent Form (ICF), confirming voluntary agreement to participate. Must precede any study-specific procedures. Sourced from Clinpal eConsent.',
    `icf_version` STRING COMMENT 'Version identifier of the Informed Consent Form (ICF) signed by the subject at enrollment. Critical for regulatory compliance to confirm the subject consented under the correct IRB/IEC-approved version. Sourced from Clinpal eConsent and Veeva Vault.',
    `itt_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the Intent-to-Treat (ITT) analysis population as defined in the Statistical Analysis Plan (the source system). True = subject is in the ITT population. Used by biostatistics for primary efficacy analysis.',
    `last_dose_date` DATE COMMENT 'Date on which the subject received the last dose of investigational product (IP). Defines the end of the treatment-emergent period. Sourced from Medidata Rave EDC.',
    `last_visit_date` DATE COMMENT 'Date of the subjects most recent completed study visit. Used to assess subject engagement, identify lost-to-follow-up risk, and support study close-out activities. Sourced from the source system',
    `pp_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the Per Protocol (PP) analysis population as defined in the Statistical Analysis Plan (the source system). True = subject meets all protocol compliance criteria for PP inclusion.',
    `randomization_date` DATE COMMENT 'Date on which the subject was randomized to a treatment arm via the IRT/RTSM system. Null if the subject has not yet been randomized or was screen-failed prior to randomization. Sourced from Medidata Rave RTSM and the source system',
    `randomization_eligible` BOOLEAN COMMENT 'Indicates whether the subject has been confirmed as eligible for randomization following completion of the run-in or screening period. True = subject meets all randomization criteria per protocol. Sourced from the source system',
    `safety_population_flag` BOOLEAN COMMENT 'Indicates whether the subject is included in the safety analysis population (typically all subjects who received at least one dose of study treatment). Used for adverse event and safety reporting.',
    `screen_failure_reason` STRING COMMENT 'Coded or free-text reason why a subject failed screening and was not enrolled into the study. Populated only when enrollment_status = screen_failed. Used for site feasibility analysis and protocol amendment decisions.',
    `screening_date` DATE COMMENT 'Date on which the subject first presented at the site and underwent initial screening procedures to assess eligibility for the study. Represents the first contact milestone in the subject lifecycle.',
    `screening_number` STRING COMMENT 'Unique identifier assigned to the subject at the time of screening, prior to formal enrollment or randomization. Used to track subjects who may not proceed to enrollment. Sourced from the source system',
    `source_system_record_reference` STRING COMMENT 'Native primary key or record identifier from the originating operational system (the source system or the source system for this enrollment record. Used for data lineage, reconciliation, and audit traceability per ALCOA+ principles.',
    `enrollment_status` STRING COMMENT 'Current lifecycle status of the subject within the enrollment process. Represents the subjects progression from initial screening through study completion or withdrawal. LIFECYCLE_STATUS for this TRANSACTION_HEADER entity.. Valid values are `screened|enrolled|randomized|withdrawn|completed|screen_failed`',
    `stratification_factor_1` STRING COMMENT 'Value of the first stratification factor used in the randomization scheme (e.g., disease severity, geographic region, biomarker status). Captured at randomization from the IRT/RTSM system. Specific factor definition is protocol-dependent.',
    `stratification_factor_2` STRING COMMENT 'Value of the second stratification factor used in the randomization scheme (e.g., prior treatment history, age group, sex). Captured at randomization from the IRT/RTSM system. Null if the protocol uses fewer than two stratification factors.',
    `subject_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the subject at the site level, typically formatted as site-number + sequential subject number (e.g., 001-001). This is the BUSINESS_IDENTIFIER used in eCRFs, EDC, and regulatory submissions.',
    `enrollment_type` STRING COMMENT 'Classification of the enrollment event type. new = first-time enrollment in this study; re_enrolled = subject re-enrolled after a protocol-allowed break; rollover = subject rolled over from a preceding study; replacement = subject enrolled as a. Valid values are `new|re_enrolled|rollover|replacement`',
    `unblinding_date` DATE COMMENT 'Date on which the subjects treatment assignment was unblinded, if applicable. Populated only for emergency or end-of-study unblinding events. Null for blinded or open-label subjects.',
    `unblinding_reason` STRING COMMENT 'Reason for unblinding the subjects treatment assignment. emergency = medical emergency requiring knowledge of treatment; end_of_study = routine unblinding at study completion; dsmb_request = DSMB/DMC-directed unblinding; regulatory_request =. Valid values are `emergency|end_of_study|dsmb_request|regulatory_request`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this enrollment record was last modified in the data platform. RECORD_AUDIT_UPDATED category. Supports ALCOA+ auditability and change tracking requirements.',
    `visit_compliance_pct` DECIMAL(5,2) COMMENT 'Percentage of required protocol visits completed by the subject relative to the total number of scheduled visits. Calculated as (completed visits / scheduled visits) × 100. Used for per-protocol population determination and site performance monitoring.',
    `withdrawal_date` DATE COMMENT 'Date on which the subject withdrew from the study or was withdrawn by the investigator. Populated only when enrollment_status = withdrawn.',
    `withdrawal_reason` STRING COMMENT 'Coded reason for subject withdrawal from the study (e.g., adverse event, subject decision, lost to follow-up, protocol deviation, sponsor decision). Populated only when enrollment_status = withdrawn.',
    CONSTRAINT pk_enrollment PRIMARY KEY(`enrollment_id`)
) COMMENT 'Transactional record capturing the formal enrollment event of a subject into a clinical study at a specific investigational site. Tracks screening date, enrollment date, randomization eligibility confirmation, enrollment status (screened, enrolled';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` (
    `randomization_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for each randomization assignment record in the Silver layer lakehouse. Primary key for this transactional entity.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Randomization assignment is the definitive arm allocation record. FK to study_arm enables IRT-to-CTMS arm reconciliation, SDTM ACTARM derivation, and blinded arm unmasking workflows.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: The blinding configuration active at randomization must be traceable per subject for unblinding procedure documentation, SAE unblinding policy application, and GCP audit trail.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: ICH E6 R2 requires confirmed informed consent before IRT/IWRS randomization. The randomization record must reference the consent in effect at randomization time for regulatory audit',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Randomization determines which dosing regimen a subject follows. FK to dosing_regimen enables IP dispensing validation against the assigned regimen, dose escalation cohort tracking, and',
    `irt_transaction_id` BIGINT COMMENT 'The unique transaction reference number generated by the IRT/RTSM system (Medidata Rave RTSM or the source system IRT) at the moment of randomization. Serves as the audit trail linkage back to the source system transaction log.',
    `prior_assignment_randomization_assignment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the previous randomization assignment record that this record supersedes or replaces. Populated only when re_randomization_flag = True or assignment_status = replaced.',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: IRT/RTSM reconciliation requires proof that the correct randomization code slot was consumed per subject assignment.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: ICH E9 requires that the exact randomization list version used for each assignment be documented.',
    `randomization_performed_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: GCP requires randomization events to be attributed to the qualified staff member who performed them for audit trail, delegation log verification, and regulatory inspection.',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: treatment_arm_code and treatment_arm_description on randomization_assignment are denormalized from the canonical treatment_arm definition.',
    `stratification_cell_id` BIGINT COMMENT 'Foreign key linking to randomization.stratification_cell. Business justification: Each randomization assignment occupies a specific stratification cell; balance monitoring per cell and SDTM STRAT variable derivation require this link.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this randomization assignment was generated. Links the assignment to the governing study protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subject was randomized. Used for site-level randomization balance reporting and monitoring.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Reconciliation between CTMS randomization_assignment records and IRT subject_randomization records is a mandatory data integrity check for SDTM submission and IRT audit.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) who received this randomization assignment. Core party reference for this transaction.',
    `allocation_ratio` DECIMAL(18,2) COMMENT 'The allocation ratio of the randomization assignment.',
    `assignment_status` STRING COMMENT 'Current lifecycle state of this randomization assignment record. active indicates the assignment is in force; cancelled indicates it was voided (e.g., randomization error); replaced indicates superseded by a re-randomization; unblinded indicates. Valid values are `active|cancelled|replaced|unblinded|pending`',
    `blinding_status` STRING COMMENT 'Indicates the blinding state of this randomization assignment. blinded means the treatment identity is masked; open_label means the study is non-blinded by design; unblinded means the blind has been intentionally broken (e.g., for a SAE or emergency. Valid values are `blinded|open_label|unblinded`',
    `cancellation_reason` STRING COMMENT 'Reason for cancellation of this randomization assignment, populated only when assignment_status = cancelled. Examples include Randomization error, Subject ineligible post-randomization, System error. Required for regulatory audit trail.',
    `cancellation_timestamp` TIMESTAMP COMMENT 'Date and time at which this randomization assignment was cancelled in the RTSM system. Null when assignment_status is not cancelled. Part of the lifecycle audit trail.',
    `cohort_code` STRING COMMENT 'Identifier for the cohort or sub-study within the trial to which this randomization assignment belongs (e.g., COHORT-A, PART-2, EXPANSION). Relevant for multi-cohort, basket, or umbrella trial designs. Null for single-cohort studies.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the investigational site where randomization occurred (e.g., USA, GBR, DEU). Used for regional randomization balance reporting and regulatory submissions to FDA, EMA, PMDA, and other health authorities.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization assignment record was first created in the Silver layer lakehouse. Represents the ingestion/creation audit timestamp, distinct from the business event randomization_timestamp.',
    `dispensing_visit_number` STRING COMMENT 'The protocol-defined visit number or name at which the investigational product was dispensed following randomization (e.g., Visit 2 - Day 1). Links the randomization event to the subject visit schedule for compliance tracking.',
    `epoch_name` STRING COMMENT 'The name of the study epoch during which randomization occurred (e.g., Treatment Period 1, Crossover Period, Extension Phase). Relevant for crossover and multi-period designs. Corresponds to CDISC SDTM SE.EPOCH.',
    `irt_system_name` STRING COMMENT 'Name of the IRT/RTSM system that generated this randomization assignment. Supports multi-system environments and audit traceability. Values include Medidata Rave RTSM, the source system IRT, or Other for legacy/custom systems.. Valid values are `Medidata Rave RTSM|Oracle Clinical One IRT|Other`',
    `kit_number` STRING COMMENT 'The unique kit or pack number of the investigational product (IP) dispensed to the subject at randomization, as assigned by the RTSM system. Links the randomization event to the specific IP supply unit for accountability and supply chain traceability.',
    `protocol_version` STRING COMMENT 'The version of the study protocol that was in effect at the time of randomization. Ensures the assignment is traceable to the correct protocol amendment, which is critical for regulatory submissions and deviation assessments.',
    `randomization_confirmed_flag` BOOLEAN COMMENT 'Indicates whether the randomization assignment has been confirmed and accepted in the RTSM system (True) or is in a provisional/pending state (False). A confirmed assignment is the authoritative allocation record.',
    `randomization_date` DATE COMMENT 'Calendar date on which the subject was randomized, derived from randomization_timestamp for day-level reporting, SDTM mapping, and enrollment tracking. Stored as yyyy-MM-dd. Used in CDISC SDTM DM.RANDDT (date portion).',
    `randomization_method` STRING COMMENT 'The statistical randomization method used to generate this assignment (e.g., block for permuted block randomization, minimization for minimization/adaptive biased-coin, adaptive for response-adaptive, simple for simple randomization. Valid values are `block|minimization|adaptive|simple|stratified_block`',
    `randomization_number` STRING COMMENT 'The externally-known unique randomization code assigned to the subject by the IRT/RTSM system (e.g., Medidata Rave RTSM or the source system IRT) at the time of randomization.',
    `randomization_ratio` DECIMAL(18,2) COMMENT 'The allocation ratio applied at randomization (e.g., 1:1, 2:1, 1:1:1). Represents the relative probability of assignment to each treatment arm as defined in the protocol and RTSM configuration.',
    `randomization_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the subject was randomized as recorded by the IRT/RTSM system. This is the authoritative business event timestamp for the randomization transaction.',
    `re_randomization_flag` BOOLEAN COMMENT 'Indicates whether this assignment is a re-randomization event (True) rather than the initial randomization (False). Re-randomization may occur in crossover designs, adaptive trials, or following a protocol deviation that necessitates re-assignment.',
    `sdtm_randfl` STRING COMMENT 'CDISC SDTM-compliant randomization flag (Y/N) indicating whether the subject was randomized, as mapped to the DM.RANDFL variable. Populated during SDTM transformation to support regulatory submission datasets.. Valid values are `Y|N`',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating IRT/RTSM system (Medidata Rave RTSM or the source system IRT). Enables bidirectional traceability between the Silver layer lakehouse and the operational source system for reconciliation and audit',
    `stratification_factor_3_code` STRING COMMENT 'The code or value of the third stratification factor applied at randomization. Null if the study protocol defines fewer than three stratification factors.',
    `unblinding_reason` STRING COMMENT 'Free-text or coded reason for breaking the blind on this assignment, populated only when blinding_status = unblinded. Examples include SAE requiring treatment knowledge, DSMB interim analysis, Subject withdrawal. Null when blinding is intact.',
    `unblinding_timestamp` TIMESTAMP COMMENT 'Date and time at which the blind was broken for this randomization assignment. Null when blinding_status is blinded or open_label. Used for safety reporting timelines and DSMB audit trails.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization assignment record was last modified in the Silver layer lakehouse. Tracks data currency and supports incremental processing. Required for ALCOA+ data integrity compliance.',
    CONSTRAINT pk_randomization_assignment PRIMARY KEY(`randomization_assignment_id`)
) COMMENT 'Transactional record of a subjects randomization event, capturing the randomization code, treatment arm assignment, stratification factor values applied at randomization, randomization date and time, IRT/RTSM transaction reference, blinding status, and';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`subject_visit` (
    `subject_visit_id` BIGINT COMMENT 'Unique surrogate identifier for each subject visit record in the Silver layer lakehouse. Primary key for the subject_visit data product.',
    `agreement_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to agreement.billing_milestone. Business justification: Billing milestones in study contracts are triggered by specific subject visit events (FPFV, LPLV, visit count targets). billing_milestone has visit_count_target confirming this.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP requires visit-level consent verification (subject_visit.informed_consent_verified already exists).',
    `ecrf_form_id` BIGINT COMMENT 'Reference to the Electronic Case Report Form (eCRF) visit form in the EDC system (Medidata Rave) associated with this visit. Links visit scheduling metadata to the data collection form for completeness tracking.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) responsible for monitoring this visit or the associated monitoring visit. Used for monitoring accountability and workload tracking in the source system',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: A subject visit is performed within the context of a specific enrollment. One enrollment has many visits.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Each subject visit occurs within a study epoch. FK to study_epoch enables epoch-level visit compliance analysis, SDTM SV epoch derivation, and epoch-based data review in EDC.',
    `primary_trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) who performed or missed this visit. Core party reference for the transaction.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) or sub-investigator who conducted or supervised this visit at the investigational site. Required for regulatory accountability per GCP.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where this visit was conducted or was scheduled to occur. Supports site-level visit compliance monitoring.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Each subject visit is an instance of a planned visit in study_visit_schedule. This FK enables visit window compliance reporting (planned vs actual day), protocol deviation',
    `actual_visit_date` DATE COMMENT 'The actual calendar date on which the subject attended the visit and assessments were performed. Maps to SVSTDTC in CDISC SDTM SV domain. Null if the visit was missed or not yet conducted. Principal real-world event date for this transaction.',
    `actual_visit_end_date` DATE COMMENT 'The actual calendar date on which the visit concluded, applicable for multi-day visits or inpatient stays. Maps to SVENDTC in CDISC SDTM SV domain. Null for single-day visits.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this subject visit record was first created in the source system or ingested into the Silver layer lakehouse. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `data_entry_status` STRING COMMENT 'Status of eCRF data entry for this visit in the EDC system (Medidata Rave), indicating whether data collection has been initiated, is in progress, completed, locked, or frozen. Used for data management tracking and database lock readiness assessment.. Valid values are `not_started|in_progress|complete|locked|frozen`',
    `days_from_planned` BIGINT COMMENT 'Signed integer representing the deviation in days between the actual visit date and the planned visit date (actual minus planned). Negative values indicate early visits; positive values indicate late visits. Zero indicates on-schedule.',
    `duration_minutes` BIGINT COMMENT 'Total duration of the visit in minutes from check-in to check-out as recorded in the CTMS or EDC. Used for site capacity planning, resource utilization analysis, and subject burden assessment.',
    `early_termination_reason` STRING COMMENT 'Reason for early termination of the visit or the subjects participation, applicable when visit_type is early_termination. Captures clinical, safety, or administrative reasons per protocol requirements.',
    `informed_consent_verified` BOOLEAN COMMENT 'Indicates whether a valid, signed Informed Consent Form (ICF) was confirmed on file prior to this visit (True) or not (False). Critical GCP compliance requirement; absence may constitute a major protocol deviation.',
    `is_scheduled` BOOLEAN COMMENT 'Indicates whether this visit was a protocol-scheduled visit (True) or an unscheduled/ad-hoc visit not defined in the protocol schedule of assessments (False). Unscheduled visits may indicate safety events or protocol deviations.',
    `is_unblinded` BOOLEAN COMMENT 'Indicates whether the treatment assignment was unblinded at or prior to this visit (True) or the subject remained blinded (False). Relevant for double-blind studies and impacts data integrity assessments.',
    `missed_reason` STRING COMMENT 'Free-text or coded reason explaining why a scheduled visit was missed by the subject (e.g., subject unavailable, adverse event, travel, withdrew consent, site closure). Populated only when visit_status is missed.',
    `missed_reason_code` STRING COMMENT 'Standardized coded value for the reason a scheduled visit was missed, aligned with sponsor or protocol-defined coding scheme. Complements missed_reason free text for structured analytics and regulatory submissions.',
    `notes` STRING COMMENT 'Free-text clinical or operational notes recorded by the site staff or CRA regarding this visit, including observations about subject condition, procedural issues, or site-specific circumstances. Sourced from the source system or Medidata Rave.',
    `planned_visit_date` DATE COMMENT 'The target date on which the visit was scheduled to occur per the protocol-defined visit schedule, calculated from the subjects reference date (e.g., randomization date or first dose date). Used to compute visit window compliance.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether this visit resulted in a protocol deviation (True), such as a visit outside the allowed window, missed required assessments, or procedural non-compliance. Triggers downstream protocol deviation record creation in the compliance domain.',
    `query_count` BIGINT COMMENT 'Number of open data discrepancy queries (DCFs) associated with this visits eCRF data in the EDC system. Used for data quality monitoring and site performance tracking. Non-zero values may block database lock.',
    `source_system_visit_key` STRING COMMENT 'The native primary key or unique identifier for this visit record in the originating source system (e.g., Medidata Rave visit OID, Siebel CTMS visit row ID).',
    `study_day` BIGINT COMMENT 'The relative study day on which the visit occurred, calculated from the subjects reference start date per CDISC convention (Day 1 = reference date; Day -1 = day before; no Day 0). Maps to SVSTDY in CDISC SDTM SV domain.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this subject visit record in the source system or Silver layer. Required for change tracking, audit trail compliance, and incremental data pipeline processing.',
    `visit_code` STRING COMMENT 'Protocol-defined alphanumeric code uniquely identifying the visit within the study schedule (e.g., SCR, BL, V01, V02, ET, EOS). Maps to VISITNUM/VISIT in CDISC SDTM SV domain. Used as the externally-known business identifier for the visit.',
    `visit_number` BIGINT COMMENT 'Sequential numeric identifier for the visit as defined in the study protocol schedule of assessments. Maps directly to VISITNUM in CDISC SDTM SV domain. Used for ordering visits chronologically within a subjects participation.',
    `visit_status` STRING COMMENT 'Current completion status of the visit indicating whether the subject attended and completed all required assessments, missed the visit entirely, partially completed assessments, had the visit rescheduled, or the visit was cancelled.. Valid values are `completed|missed|partial|rescheduled|cancelled`',
    `visit_type` STRING COMMENT 'Classification of the visit by its role in the study protocol lifecycle. Drives SDTM SV domain population and visit compliance analytics. [ENUM-REF-CANDIDATE: screening|baseline|treatment|follow_up|unscheduled|early_termination|end_of_study — promote to',
    `week` BIGINT COMMENT 'The nominal study week associated with this visit as defined in the protocol schedule of assessments (e.g., Week 1, Week 4, Week 12). Used for time-point labeling in biostatistical analyses and ADaM dataset derivations.',
    `window_close_date` DATE COMMENT 'The latest acceptable date for the visit to occur per the protocol-defined visit window (planned date plus the allowed late deviation in days). Used to determine visit window compliance status.',
    `window_compliance_status` STRING COMMENT 'Indicates whether the actual visit date fell within the protocol-defined visit window, occurred early (before window open), occurred late (after window close), was missed entirely, or is not applicable (e.g., unscheduled visits).. Valid values are `within_window|early|late|missed|not_applicable`',
    `window_open_date` DATE COMMENT 'The earliest acceptable date for the visit to occur per the protocol-defined visit window (planned date minus the allowed early deviation in days). Used to determine visit window compliance status.',
    CONSTRAINT pk_subject_visit PRIMARY KEY(`subject_visit_id`)
) COMMENT 'Single owner of a subjects protocol-scheduled study visit (clinical visit).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` (
    `subject_deviation_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol deviation record associated with a trial subject. Primary key for the subject_deviation data product in the Silver Layer lakehouse.',
    `amendment_id` BIGINT COMMENT 'Foreign key linking to program.program_amendment. Business justification: Regulatory traceability requires mapping subject deviations to the protocol amendment version in effect at occurrence.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the formal Corrective and Preventive Action (CAPA) record in MasterControl that was initiated as a result of this deviation. Enables traceability between deviations and the quality management system.',
    `compliance_deviation_classification_id` BIGINT COMMENT 'Foreign key linking to compliance.deviation_classification. Business justification: GCP compliance requires every subject deviation to be classified against a standard taxonomy to determine regulatory reporting obligations, CAPA triggers, and CSR',
    `detected_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: GCP and ICH E6 require protocol deviations to be attributed to the staff member who detected them for CAPA initiation, regulatory inspection readiness, and sponsor oversight reports.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Protocol deviations are assessed against the specific SOP that was violated or not followed.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Protocol deviations are enrollment-specific events — they occur within the context of a subjects participation in a specific study enrollment.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: Subject deviations with irb_iec_reportable_flag=true must be reported to the IRB/IEC via a formal ethics submission.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the deviation occurred. Used for site-level deviation trending, monitoring, and risk assessment.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Protocol deviations are frequently identified through abnormal lab results (e.g., subject continued dosing despite creatinine exceeding stopping rule).',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: A subject deviation is assessed against the protocol version in effect at the time of occurrence.',
    `site_file_document_id` BIGINT COMMENT 'Foreign key linking to document.site_file_document. Business justification: Deviation reports and supporting documentation must be filed in the Investigator Site File as GCP-required essential documents.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this deviation was identified. Links the deviation to the governing protocol and sponsor.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Deviations are assessed against the protocol amendment in effect at occurrence.',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Protocol deviations are frequently identified at or associated with a specific study visit.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) for whom this protocol deviation was recorded. Core party reference linking the deviation to the enrolled participant.',
    `closed_timestamp` TIMESTAMP COMMENT 'The precise date and time when the deviation record was formally closed in the quality management system. Provides higher precision than resolution_date for audit and compliance reporting.',
    `comments` STRING COMMENT 'Free-text field for additional comments, clarifications, or contextual notes related to the deviation that do not fit into structured fields. May include reviewer notes, sponsor feedback, or monitoring observations.',
    `corrective_action_description` STRING COMMENT 'Narrative description of the immediate corrective action taken to address the deviation and prevent recurrence at the subject or site level. Distinct from the formal CAPA process which is tracked separately in MasterControl.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this deviation record was first created in the source system. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11 and ICH E6(R2).',
    `data_integrity_impact` STRING COMMENT 'Assessment of whether the deviation compromised the integrity of study data collected from the subject. Informs decisions on data exclusion, sensitivity analyses, and per-protocol (PP) population definitions.. Valid values are `none|potential|confirmed`',
    `deviation_category` STRING COMMENT 'Classification of the deviation by severity and impact. Major deviations significantly affect subject safety or data integrity; important deviations may affect subject rights or study data; minor deviations have minimal impact.. Valid values are `major|minor|important`',
    `deviation_description` STRING COMMENT 'Detailed narrative description of the specific deviation that occurred, including what protocol requirement was not met, the circumstances, and any relevant context.',
    `deviation_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the deviation record as assigned by the Clinical Trial Management System (CTMS) or MasterControl. Used for cross-system referencing, regulatory submissions, and audit trail purposes.. Valid values are `^DEV-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `deviation_status` STRING COMMENT 'Current workflow lifecycle state of the deviation record. Tracks progression from initial identification through review, resolution, and closure. Drives operational dashboards and compliance monitoring in the source system and MasterControl.. Valid values are `open|under_review|resolved|closed|escalated`',
    `identified_date` DATE COMMENT 'The calendar date on which the deviation was first identified or discovered, which may differ from the occurrence date. Used to calculate detection lag and assess monitoring effectiveness.',
    `irb_iec_reportable_flag` BOOLEAN COMMENT 'Indicates whether this deviation must be reported to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) overseeing the study. Separate from regulatory authority reportability. True = must report to IRB/IEC.',
    `occurrence_date` DATE COMMENT 'The calendar date on which the protocol deviation actually occurred. This is the principal real-world event date, distinct from the date the deviation was identified or reported. Critical for ALCOA+ compliance and regulatory timelines.',
    `pi_aware_date` DATE COMMENT 'The date on which the Principal Investigator (PI) was informed of the deviation. Used to track compliance with site notification requirements.',
    `pi_aware_flag` BOOLEAN COMMENT 'Indicates whether the Principal Investigator (PI) at the site has been made aware of this deviation. True = PI has been informed. Required for GCP compliance as the PI bears ultimate responsibility for conduct of the trial at the site.',
    `protocol_section_reference` STRING COMMENT 'Reference to the specific section, clause, or requirement number within the approved study protocol that was deviated from (e.g., Section 6.3.2 - Inclusion Criteria). Enables precise traceability to the protocol document.',
    `regulatory_reportable_flag` BOOLEAN COMMENT 'Indicates whether this deviation must be reported to a regulatory authority (FDA, EMA, PMDA, etc.), IRB/IEC, or sponsor per applicable regulations and the study protocol. True = reportable; False = not reportable. Drives regulatory submission workflows.',
    `reported_date` DATE COMMENT 'The date on which the deviation was formally reported to the sponsor, IRB/IEC, or regulatory authority as applicable. Used to track compliance with reporting timelines mandated by GCP and applicable regulations.',
    `resolution_date` DATE COMMENT 'The date on which the deviation was formally resolved and closed in the quality management system. Used to calculate time-to-resolution metrics and assess site responsiveness.',
    `root_cause` STRING COMMENT 'Narrative description of the underlying root cause of the deviation as determined through investigation. Used to inform corrective and preventive actions (CAPA) and systemic quality improvement. Captured in MasterControl.',
    `root_cause_category` STRING COMMENT 'Categorical classification of the root cause to enable trending and systemic analysis across deviations. Categories align with standard quality management frameworks used in MasterControl.. Valid values are `process|training|system|communication|resource|oversight`',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain to which this deviation maps for regulatory submission. Protocol deviations are mapped to the DV (Protocol Deviations) domain per CDISC SDTM Implementation Guide.',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating source system (the source system or MasterControl). Enables bidirectional traceability between the lakehouse Silver Layer and the operational system of record.',
    `sponsor_notified_date` DATE COMMENT 'The date on which the sponsor was formally notified of the deviation. Used to verify compliance with contractual and regulatory notification timelines.',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this deviation. True = sponsor has been notified. Required per GCP obligations for sponsor oversight of investigational sites.',
    `subject_continuation_decision` STRING COMMENT 'Decision regarding the subjects continued participation in the study following the deviation. Informs subject disposition tracking and intent-to-treat (ITT) and per-protocol (PP) population assignments.. Valid values are `continue|withdrawn|on_hold|pending_review`',
    `subject_rights_impact` STRING COMMENT 'Assessment of whether the deviation affected the rights or well-being of the trial subject, including informed consent procedures, privacy protections, or voluntary participation rights.. Valid values are `none|potential|confirmed`',
    `subject_safety_impact` STRING COMMENT 'Assessment of whether the deviation had an impact on subject safety. None indicates no safety impact; potential indicates possible but unconfirmed impact; confirmed indicates a verified safety impact.. Valid values are `none|potential|confirmed`',
    `type_code` STRING COMMENT 'Standardized code identifying the specific type of protocol deviation (e.g., eligibility criteria violation, missed visit, incorrect dosing, prohibited medication use, consent procedure deviation).',
    `type_description` STRING COMMENT 'Human-readable label corresponding to the deviation_type_code, providing a plain-language description of the deviation type for reporting and review purposes.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this deviation record was most recently modified. Supports change tracking, audit trail compliance, and incremental data loading in the Databricks Silver Layer.',
    CONSTRAINT pk_subject_deviation PRIMARY KEY(`subject_deviation_id`)
) COMMENT 'Transactional record of a protocol deviation identified for a subject, capturing deviation category (major, minor, important), deviation type code, description, date of occurrence, date identified, root cause, impact on subject safety and data integrity';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`disposition` (
    `disposition_id` BIGINT COMMENT 'Unique surrogate identifier for each subject disposition milestone record in the Silver Layer lakehouse. Primary key for the disposition data product. Entity role: TRANSACTION_HEADER — captures a discrete formal disposition event in the subject study',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Disposition records AE-driven discontinuations (ae_related_discontinuation flag). SDTM DS domain mapping (DSDECOD=ADVERSE EVENT) and regulatory narratives require identifying the',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Disposition records capture the arm a subject was in at discontinuation or completion. FK to study_arm enables arm-level completion/discontinuation analysis for CSR disposition tables and',
    `codelist_id` BIGINT COMMENT 'Standardized disposition event, governed by CDISC CT codelist DSDECOD.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Disposition data is captured on the DS eCRF form; CRAs must reference the specific form version during SDV and SDTM DS domain generation.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: A disposition milestone (completion, withdrawal, screen failure) is a formal event within a specific enrollment.',
    `estimand_id` BIGINT COMMENT 'Foreign key linking to biostatistics.estimand. Business justification: ICH E9(R1) estimand framework requires disposition events (treatment discontinuation, death) to be classified as intercurrent events per the estimands ICE strategy.',
    `meddra_term_id` BIGINT COMMENT 'add column meddra_term_id (BIGINT) with FK to terminology.meddra_term.meddra_term_id — per user vibes instruction 4, disposition must reference coded concept',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the protocol deviation record that directly caused or is associated with the subjects discontinuation. Populated when the coded reason is PROTOCOL DEVIATION. Links disposition to the compliance domain.',
    `randomization_assignment_id` BIGINT COMMENT 'Foreign key linking to subject.randomization_assignment. Business justification: Disposition records for randomized subjects should reference the specific randomization assignment that was active at the time of disposition.',
    `recorded_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Subject disposition records (withdrawal, completion, death) must be attributed to the staff member who recorded them for SDTM DS domain audit trail, regulatory submission, and GCP',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this disposition event occurred. Links the disposition record to the parent study master.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subjects disposition event was recorded. Used for site-level CONSORT flow and enrollment reporting.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: SDTM DS domain and CONSORT flow reporting require disposition records to be traceable to the specific IRT randomization event.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) whose formal disposition milestone is being recorded. Core PARTY_REFERENCE for this transaction. Sourced from Medidata Rave EDC subject master.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.consent_withdrawal. Business justification: SDTM DS domain reconciliation requires linking subject disposition (withdrawal/discontinuation) to the formal consent_withdrawal record.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `ae_related_discontinuation` BOOLEAN COMMENT 'Indicates whether the subjects discontinuation was due to an adverse event (AE) or serious adverse event (SAE). When True, links to the safety domain for AE-driven disposition analysis and regulatory safety reporting.',
    `analysis_population_itt` BOOLEAN COMMENT 'Indicates whether the subject is included in the Intent-to-Treat (ITT) analysis population based on disposition and protocol criteria. Drives primary efficacy analysis dataset inclusion.',
    `analysis_population_pp` BOOLEAN COMMENT 'Indicates whether the subject is included in the Per Protocol (PP) analysis population. Subjects with major protocol deviations affecting efficacy assessment are typically excluded. Determined by biostatistics per the the source system.',
    `analysis_population_safety` BOOLEAN COMMENT 'Indicates whether the subject is included in the Safety analysis population (subjects who received at least one dose of investigational product). Drives safety tabulations in the CSR and regulatory submissions.',
    `data_entry_timestamp` TIMESTAMP COMMENT 'RECORD_AUDIT_CREATED — timestamp when the disposition record was first entered into the EDC system (Medidata Rave). Supports ALCOA+ contemporaneous data entry requirements and audit trail compliance.',
    `disposition_date` DATE COMMENT 'BUSINESS_EVENT_TIMESTAMP (date precision) — the calendar date on which the formal disposition milestone occurred for the subject (e.g., date of randomization, date of last study visit, date of withdrawal).',
    `death_cause` STRING COMMENT 'Verbatim or coded cause of death for subjects with DEATH disposition. Used in safety narratives, CSR, and regulatory submissions. Coded against MedDRA when applicable.',
    `death_date` DATE COMMENT 'Date of subject death when the disposition term is DEATH. Required for survival analysis, time-to-event endpoints, and expedited safety reporting. Sourced from Medidata Rave EDC death records and the source system',
    `ds_seq` BIGINT COMMENT 'Sequential number identifying the order of disposition records for a given subject within the study, corresponding to the SDTM DSSEQ variable. Supports multiple disposition milestones per subject (e.g., enrolled then discontinued).',
    `early_termination_flag` BOOLEAN COMMENT 'Indicates whether the subject terminated study participation before completing all protocol-required activities. Distinct from study_completion_flag in that it specifically flags premature exit for operational tracking and site performance metrics.',
    `event` STRING COMMENT 'The event of the disposition.',
    `last_contact_date` DATE COMMENT 'Date of the subjects last known contact with the study team, including phone calls, remote visits, or any study-related communication. Used for lost-to-follow-up determination and survival analysis censoring.',
    `last_dose_date` DATE COMMENT 'Date of the subjects last administration of investigational product (IP) prior to or at the disposition milestone. Critical for calculating treatment duration, exposure windows, and safety follow-up periods. Sourced from Medidata Rave EDC dosing records.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'RECORD_AUDIT_UPDATED — timestamp of the most recent modification to this disposition record in the EDC system. Supports audit trail requirements and data change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `last_visit_date` DATE COMMENT 'Date of the subjects last scheduled or unscheduled study visit prior to or at the disposition milestone. Used to determine last study contact and assess visit compliance. Sourced from Medidata Rave EDC visit records.',
    `meddra_pt` STRING COMMENT 'MedDRA Preferred Term (PT) assigned to the coded discontinuation reason. Enables standardized cross-study analysis and regulatory reporting of disposition reasons. Populated by the medical coding process.',
    `meddra_soc` STRING COMMENT 'MedDRA System Organ Class (SOC) associated with the coded discontinuation reason Preferred Term. Supports regulatory tabulation and signal detection for disposition-related safety analysis.',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for coding the disposition reason (e.g., 26.0, 26.1). Required for regulatory submission traceability and reproducibility of coded terms.. Valid values are `^[0-9]{1,2}.[0-9]{1,2}$`',
    `milestone_category` STRING COMMENT 'High-level category classifying the type of disposition milestone. Used to group disposition events for CONSORT flow diagram construction and CSR disposition tables. Aligns with SDTM DSCAT variable.',
    `milestone_subcategory` STRING COMMENT 'Sponsor-defined subcategory further classifying the disposition milestone within its category (e.g., PROTOCOL DEVIATION, ADVERSE EVENT, SPONSOR DECISION under DISCONTINUATION). Corresponds to SDTM DSSCAT variable.',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether there is at least one open data discrepancy query against this disposition record in the EDC system. Supports data management oversight and database lock (DBL) readiness tracking.',
    `safety_followup_end_date` DATE COMMENT 'Planned or actual end date of the post-discontinuation safety follow-up period. Populated when safety_followup_required is True. Used to track completion of safety obligations for discontinued subjects.',
    `safety_followup_required` BOOLEAN COMMENT 'Indicates whether the subject requires a post-discontinuation safety follow-up period per protocol requirements. True when the subject discontinued early and protocol mandates continued safety monitoring. Drives safety follow-up visit scheduling.',
    `screen_failure_reason` STRING COMMENT 'Reason why a screened subject failed to meet eligibility criteria and was not enrolled. Populated only for SCREEN FAILURE disposition. Used for site feasibility analysis and protocol amendment decisions.',
    `sdtm_ds_record_reference` STRING COMMENT 'Unique record identifier from the CDISC SDTM DS (Disposition) domain dataset, enabling traceability between the Silver Layer lakehouse record and the regulatory submission dataset. Supports eCTD submission package linkage.',
    `sdv_status` STRING COMMENT 'Status of source data verification (SDV) for this disposition record, indicating whether the CRA has verified the data against source documents. Sourced from the source system monitoring records. Supports GCP compliance and monitoring oversight.. Valid values are `NOT_REQUIRED|PENDING|VERIFIED|QUERIED`',
    `disposition_status` STRING COMMENT 'LIFECYCLE_STATUS of this disposition record within the EDC/data management workflow. Indicates whether the record is the current active disposition, has been superseded by a correction, is pending data review, or has been cancelled.. Valid values are `active|superseded|cancelled|pending_review`',
    `study_completion_flag` BOOLEAN COMMENT 'Indicates whether the subject completed the study per protocol (True) or did not complete (False). Drives CONSORT flow diagram completion counts and CSR disposition summary tables.',
    `subject_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the subject at the site (e.g., 001-001). Corresponds to SDTM USUBJID or site-assigned subject number. BUSINESS_IDENTIFIER for this transaction. Sourced from Medidata Rave EDC.',
    `term` STRING COMMENT 'Standardized disposition term describing the subjects formal study milestone (e.g., COMPLETED, SCREEN FAILURE, DISCONTINUED, WITHDRAWN BY SUBJECT, LOST TO FOLLOW-UP, DEATH). Corresponds to SDTM DSTERM.',
    `timestamp` TIMESTAMP COMMENT 'Full ISO 8601 timestamp of the disposition event when time-of-day precision is available. Supplements disposition_date for events requiring precise timing (e.g., time of death, time of last dose). Corresponds to SDTM DSSTDTC full datetime.',
    `verbatim_reason` STRING COMMENT 'Free-text verbatim reason for discontinuation or withdrawal as entered by the investigator or site staff in the eCRF. Captured prior to coding. Supports ALCOA+ attributability and audit trail requirements.',
    `verbatim_term` STRING COMMENT 'STRING',
    CONSTRAINT pk_disposition PRIMARY KEY(`disposition_id`)
) COMMENT 'Transactional record capturing each formal disposition milestone of a subject through the study lifecycle (screened, enrolled, randomized, completed, discontinued, withdrawn, lost to follow-up, death).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` (
    `eligibility_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for each eligibility assessment record in the Silver layer lakehouse. Primary key for this data product.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the version of the Informed Consent Form (ICF) that was in effect at the time of this eligibility assessment. Ensures the subject consented under the correct protocol version before assessment.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP requires consent to precede eligibility assessment. While icf_version_id already links to consent_icf_version, linking to subject_consent confirms the actual signed consent record',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Inclusion/exclusion criteria are captured on the IE eCRF form. Linking eligibility_assessment to ecrf_form normalizes the denormalized edc_form_name, supports SDV of eligibility',
    `eligibility_criterion_id` BIGINT COMMENT 'Foreign key linking to study.eligibility_criterion. Business justification: Each eligibility assessment row evaluates one protocol-defined criterion. FK to eligibility_criterion enables SDTM IE domain derivation, criterion-level screen failure rate',
    `employee_id` BIGINT COMMENT 'Reference to the qualified site staff member (Principal Investigator or delegated Clinical Research Coordinator) who performed and recorded the eligibility criterion assessment. Supports GCP accountability requirements.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Eligibility assessments (inclusion/exclusion criteria checks) are performed as part of the screening phase of a specific enrollment.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Eligibility criteria assessments must be conducted under the protocol version authorized by a valid ethics approval.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Eligibility criteria are frequently lab-based (eGFR, HbA1c, platelet count). The eligibility_assessment must reference the specific lab_result that drove the pass/fail decision to',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this eligibility assessment was performed. Links the assessment to the governing protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Eligibility criteria change with protocol amendments; the amendment version governing an assessment is critical for regulatory submissions and screen failure analysis.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the eligibility assessment was conducted.',
    `subject_deviation_id` BIGINT COMMENT 'Reference to the protocol deviation record created when a subject was enrolled despite failing this eligibility criterion. Populated only when protocol_deviation_flag is True.',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Eligibility assessments are performed during screening visits. eligibility_assessment carries a denormalized screening_visit_number (STRING) that should be normalized via FK to',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) whose eligibility is being assessed. Core party reference for this transactional record.',
    `validation_rule_id` BIGINT COMMENT 'Foreign key linking to datamanagement.validation_rule. Business justification: Inclusion/exclusion criteria are implemented as EDC validation/edit-check rules.',
    `assessment_date` DATE COMMENT 'Calendar date on which the eligibility criterion was assessed for the subject. Principal real-world event date for this transactional record. Maps to CDISC SDTM IE.IEDTC (date portion).',
    `assessment_number` STRING COMMENT 'Externally-known business identifier for this eligibility assessment, typically generated by the EDC system (Medidata Rave or the source system Used for cross-system traceability and audit trail references.',
    `assessment_result` STRING COMMENT 'Outcome of the eligibility criterion assessment for this subject. MET indicates the criterion was satisfied; NOT MET indicates failure; NOT ASSESSED indicates the criterion was not evaluated. Maps to CDISC SDTM IE.IEORRES.. Valid values are `MET|NOT MET|NOT ASSESSED`',
    `assessment_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the eligibility criterion assessment was recorded in the EDC system. Supports ALCOA+ contemporaneous documentation requirements and 21 CFR Part 11 audit trail.',
    `assessor_role` STRING COMMENT 'Role of the site staff member who performed the eligibility assessment (e.g., Principal Investigator, Sub-Investigator, Clinical Research Coordinator). Required for GCP delegation log compliance.. Valid values are `PI|SUB-INVESTIGATOR|CRC|STUDY_NURSE|DESIGNEE`',
    `comments` STRING COMMENT 'Free-text comments or clinical notes entered by the assessor regarding this eligibility criterion assessment. May include clarifications, borderline findings, or contextual information relevant to the eligibility decision.',
    `data_entry_timestamp` TIMESTAMP COMMENT 'Date and time when this eligibility assessment record was first entered into the EDC system. Distinct from assessment_timestamp (when assessment occurred). Supports ALCOA+ contemporaneous data entry monitoring.',
    `data_source_system` STRING COMMENT 'Identifies the operational system of record from which this eligibility assessment record was sourced (Medidata Rave EDC or the source system Supports data lineage and reconciliation in the Silver layer.. Valid values are `MEDIDATA_RAVE|ORACLE_CLINICAL_ONE|MANUAL`',
    `edc_record_reference` STRING COMMENT 'Source system record identifier from the EDC platform (Medidata Rave or the source system for this eligibility assessment entry. Enables traceability back to the source system for SDV and audit.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether IRB/IEC approval is required for the waiver or exception associated with this eligibility criterion assessment. Drives regulatory workflow routing.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this eligibility assessment record was last updated in the source EDC system. Required for 21 CFR Part 11 audit trail and ALCOA+ data integrity compliance.',
    `lock_status` STRING COMMENT 'Data lock status of this eligibility assessment record in the EDC system. LOCKED records cannot be modified without an audit-trailed unlock. Supports Database Lock (DBL) readiness and 21 CFR Part 11 compliance.. Valid values are `UNLOCKED|LOCKED|FROZEN`',
    `not_met_reason` STRING COMMENT 'Free-text or coded reason explaining why the subject did not meet this eligibility criterion. Populated when assessment_result is NOT MET. Supports clinical review and protocol deviation analysis.',
    `overall_eligibility_status` STRING COMMENT 'Overall eligibility determination for the subject based on the complete set of inclusion/exclusion criteria assessments. Drives subject enrollment decision. Lifecycle status for this assessment record.. Valid values are `ELIGIBLE|INELIGIBLE|PENDING|WAIVER_REQUESTED|WAIVER_APPROVED|WAIVER_DENIED`',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether this eligibility criterion assessment resulted in a protocol deviation (i.e., subject enrolled despite not meeting a criterion without an approved waiver). Triggers deviation reporting workflow.',
    `protocol_version` STRING COMMENT 'Version of the study protocol under which this eligibility assessment was performed. Critical for audit trail when protocol amendments change inclusion/exclusion criteria.',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether an open data discrepancy query exists against this eligibility assessment record in the EDC system. Supports data cleaning status monitoring and DBL readiness tracking.',
    `re_screening_flag` BOOLEAN COMMENT 'Indicates whether this eligibility assessment is part of a re-screening attempt following an initial screen failure. Supports enrollment funnel analytics and re-screening rate KPI reporting.',
    `screen_failure_reason` STRING COMMENT 'Coded or free-text reason for screen failure when the overall eligibility determination is INELIGIBLE. Used for enrollment analytics, site performance reporting, and protocol feasibility review.',
    `sdtm_domain` STRING COMMENT 'CDISC SDTM domain code for this eligibility assessment record. Always IE (Inclusion/Exclusion Criteria Not Met) for regulatory submission datasets. Supports SDTM mapping and NDA/BLA/MAA submission.',
    `sdtm_sequence_number` BIGINT COMMENT 'CDISC SDTM sequence number (IESEQ) uniquely identifying this record within the IE domain for a given subject. Required for regulatory submission dataset construction.',
    `sdv_date` DATE COMMENT 'Date on which Source Data Verification (SDV) was completed for this eligibility assessment record by the CRA. Null when SDV has not yet been performed.',
    `sdv_status` STRING COMMENT 'Status of Source Data Verification (SDV) performed by the Clinical Research Associate (CRA) for this eligibility assessment record. Tracks monitoring compliance per the monitoring plan.. Valid values are `NOT_REQUIRED|PENDING|VERIFIED|PARTIAL`',
    `source_data_reference` STRING COMMENT 'Reference to the source document or data entry (e.g., medical record number, lab report ID, physical examination note) that supports the eligibility criterion assessment. Required for Source Data Verification (SDV) by CRA.',
    `waiver_approval_date` DATE COMMENT 'Date on which the sponsor or IRB/IEC approved the protocol exception or waiver for this eligibility criterion. Null when no waiver was requested or waiver was denied.',
    `waiver_justification` STRING COMMENT 'Free-text clinical or scientific justification provided by the investigator for requesting a protocol exception or waiver for this eligibility criterion. Required for regulatory audit trail.',
    `waiver_requested` BOOLEAN COMMENT 'Indicates whether a protocol deviation waiver or exception was requested for this criterion when the subject did not meet it. True when a waiver request has been submitted to the sponsor or IRB/IEC.',
    `waiver_status` STRING COMMENT 'Current status of the protocol-specified exception or waiver request for this eligibility criterion. Applicable only when waiver_requested is True. Tracks sponsor or IRB/IEC decision.. Valid values are `PENDING|APPROVED|DENIED|NOT_APPLICABLE`',
    CONSTRAINT pk_eligibility_assessment PRIMARY KEY(`eligibility_assessment_id`)
) COMMENT 'Transactional record of the inclusion/exclusion criteria assessment performed for a subject during screening. Captures each criterion code, criterion text, assessment result (met/not met/not assessed), assessment date, assessor identity, and overall';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` (
    `subject_status_history_id` BIGINT COMMENT 'Unique surrogate identifier for each subject status transition record in the lifecycle history table. Primary key for the subject_status_history data product.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Subject status transitions (withdrawal, early termination, study suspension) triggered by an AE require referencing the causative event for regulatory audit trail and GCP compliance.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Status transitions (screening→enrolled, enrolled→withdrawn) are driven by consent events.',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: Status transitions (e.g., enrolled, re-consented, withdrawn) are driven by specific ICF document versions.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Subject status transitions (screening, enrolled, randomized, completed, withdrawn) are enrollment-specific lifecycle events.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Subject status transitions (screening, randomization, treatment, follow-up, completion) occur within defined study epochs.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subject status transition was recorded. Supports site-level enrollment flow analysis and monitoring.',
    `primary_subject_employee_id` BIGINT COMMENT 'The system user (CRC, CRA, PI, or system account) who initiated or recorded this status transition in the source system. Supports 21 CFR Part 11 electronic signature audit trail and ALCOA+ attributability requirements.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the specific protocol deviation record associated with this status transition, when protocol_deviation_flag is True. Links to the compliance.protocol_deviation product for full deviation details.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Status transitions triggered by protocol amendments (reconsent required, arm reassignment, eligibility re-evaluation) must reference the causative amendment for regulatory audit',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this subject status transition occurred. Links the history record to the governing study protocol.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: ICH E6 R2 audit trail requires status transitions (Randomized, Re-randomized, Unblinded) to be traceable to the specific IRT event that triggered them.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) whose enrollment lifecycle status changed. Core party reference for this event log record.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time at which the status transition was formally approved or electronically signed by the authorized user. Distinct from transition_timestamp (when the event occurred) and created_timestamp (when the record was created).',
    `comments` STRING COMMENT 'Free-text field for additional clinical or administrative comments related to this status transition, entered by the site staff or sponsor. Supports contextual documentation for audit trail completeness per ALCOA+ standards.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this status history record was first created in the data lakehouse Silver layer. Supports audit trail, data lineage, and ALCOA+ contemporaneous documentation requirements.',
    `disposition_category` STRING COMMENT 'High-level classification of the disposition event type associated with this status transition. Used for regulatory reporting in the CDISC SDTM DS domain and for subject flow summaries in Clinical Study Reports (CSRs).',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether this status transition required prior approval from the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) (e.g., re-consent due to protocol amendment). True = IRB/IEC approval was required.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether the subjects treatment assignment was blinded at the time of this status transition. True = blinded (treatment identity concealed); False = unblinded (treatment identity known).',
    `is_terminal_status` BOOLEAN COMMENT 'Indicates whether the new_status represents a terminal (end-state) disposition for the subject in this study. True = the subject has reached a final state (completed, withdrawn, screen-failed, lost-to-follow-up) with no further expected transitions.',
    `itt_population_flag` BOOLEAN COMMENT 'Indicates whether the subject was included in the Intent-to-Treat (ITT) analysis population at the time of this status transition. Supports biostatistical analysis population tracking per the Statistical Analysis Plan (the source system).',
    `new_status` STRING COMMENT 'The subjects enrollment lifecycle status after this transition event. Represents the current state the subject entered as a result of this change. [ENUM-REF-CANDIDATE',
    `pp_population_flag` BOOLEAN COMMENT 'Indicates whether the subject was included in the Per Protocol (PP) analysis population at the time of this status transition. Supports biostatistical analysis population tracking per the Statistical Analysis Plan (the source system).',
    `prior_status` STRING COMMENT 'The subjects enrollment lifecycle status immediately before this transition event. Together with new_status, defines the state transition vector for longitudinal subject flow analysis.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation (PD) was associated with or triggered this status transition. True = a protocol deviation is linked to this transition event. Supports GCP compliance monitoring and regulatory inspection readiness.',
    `safety_population_flag` BOOLEAN COMMENT 'Indicates whether the subject was included in the safety analysis population at the time of this status transition (i.e., received at least one dose of investigational product). Supports safety reporting and TEAE analysis.',
    `screen_failure_reason` STRING COMMENT 'Specific reason why the subject failed screening and did not proceed to enrollment. Populated only when new_status = screen-failed. Used for site feasibility analysis, protocol amendment decisions, and enrollment optimization.',
    `source_system_record_key` STRING COMMENT 'The native primary key or unique identifier of this status transition record in the originating source system (the source system or Medidata Rave). Enables traceability back to the system of record for reconciliation and audit purposes.',
    `study_day` BIGINT COMMENT 'The relative study day on which the status transition occurred, calculated from the subjects reference start date (typically first dose date). Negative values indicate pre-treatment days. Aligns with CDISC SDTM timing variable conventions.',
    `subject_number` STRING COMMENT 'The externally-known alphanumeric subject identifier assigned at enrollment (e.g., site-sequential number such as 001-001). Used in regulatory submissions, eCRFs, and audit trails to identify the participant without revealing personal identity.',
    `transition_date` DATE COMMENT 'The calendar date on which the subjects status transition occurred in the real-world clinical context. This is the principal business event date used for enrollment timelines, regulatory reporting, and subject flow analysis.',
    `transition_reason` STRING COMMENT 'Free-text narrative describing the clinical or administrative reason for the subject status change (e.g., Subject met all inclusion/exclusion criteria, Subject withdrew consent, Adverse event led to discontinuation).',
    `transition_reason_code` STRING COMMENT 'Standardized coded value for the transition reason, aligned with CDISC SDTM DS domain disposition event codes (e.g., COMPLETED, WITHDRAWAL BY SUBJECT, ADVERSE EVENT, SCREEN FAILURE). Enables structured analysis and regulatory submission mapping.',
    `transition_sequence` BIGINT COMMENT 'Sequential ordinal number of this status transition within the subjects complete enrollment lifecycle history. Enables chronological ordering of all transitions for a given subject within a study. Starts at 1 for the first recorded transition.',
    `transition_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone) at which the subject status transition was recorded in the source system (the source system or Medidata Rave). Supports 21 CFR Part 11 audit trail requirements and ALCOA+ contemporaneous documentation standards.',
    `triggered_by_system` STRING COMMENT 'Identifies whether the status transition was triggered by a human user or an automated system process, and which source system initiated it (the source system Medidata Rave, IRT/RTSM). Supports data lineage and audit trail requirements.. Valid values are `Oracle Clinical One|Medidata Rave|manual|IRT|RTSM`',
    `triggered_by_user_role` STRING COMMENT 'The clinical role of the user who triggered this status transition (e.g., CRC - Clinical Research Coordinator, CRA - Clinical Research Associate, PI - Principal Investigator). Supports audit trail completeness and role-based accountability per GCP.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this status history record was last modified in the data lakehouse Silver layer. Supports change tracking, audit trail completeness, and data quality monitoring per 21 CFR Part 11 and ALCOA+ standards.',
    `withdrawal_reason` STRING COMMENT 'Specific reason for subject withdrawal or discontinuation from the study. Populated when new_status is withdrawn or discontinued. Categorized per CDISC SDTM DS domain controlled terminology (e.g., ADVERSE EVENT, WITHDRAWAL BY SUBJECT, LOST TO',
    CONSTRAINT pk_subject_status_history PRIMARY KEY(`subject_status_history_id`)
) COMMENT 'Lifecycle history table tracking every status transition of a trial subject across the enrollment lifecycle (e.g., pre-screened → screened → screen-failed → enrolled → randomized → on-treatment → completed → withdrawn).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`subject_contact` (
    `subject_contact_id` BIGINT COMMENT 'Unique surrogate identifier for the subject contact record in the Silver Layer lakehouse. Primary key for this entity.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the version of the Informed Consent Form (ICF) under which the subjects contact data privacy consent was obtained. Ensures traceability of consent to the specific ICF version approved by the IRB/IEC.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is enrolled. Used to scope contact data to the correct site for monitoring and follow-up.',
    `primary_subject_primary_organization_contact_id` BIGINT COMMENT 'Optional reference to the canonical sponsor contact record when a subject contact is also a sponsor contact (resolves contact duplicate by making sponsor.sponsor_contact the canonical owner).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this subject is enrolled. Scopes the contact record to a specific trial.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose contact information is stored in this record. Links to the subject master entity.',
    `type_codelist_term_id` BIGINT COMMENT 'foreign key to shared contact type reference',
    `address_line1` STRING COMMENT 'First line of the subjects home address (street number and street name). Used for postal communications, visit logistics, and safety follow-up mailings.',
    `address_line2` STRING COMMENT 'Second line of the subjects home address (apartment, suite, unit, floor, or building name). Supplements address_line1 for complete postal address.',
    `address_verified_date` DATE COMMENT 'Date on which the subjects home address was last verified by site staff. Supports ALCOA+ data quality requirements and ensures contact information is current for safety follow-up.',
    `address_verified_flag` BOOLEAN COMMENT 'Indicates whether the subjects home address has been verified by site staff or through an address validation service. True = address confirmed; False = address unverified or pending confirmation.',
    `city` STRING COMMENT 'City or municipality of the subjects home address. Used for geographic analysis of subject distribution and postal communications.',
    `consent_date` DATE COMMENT 'Date on which the subject granted consent for contact communications. Required for GDPR and HIPAA audit trails to demonstrate lawful basis for processing contact data.',
    `consent_flag` BOOLEAN COMMENT 'Indicates whether the subject has provided explicit consent to be contacted for study-related communications (visit reminders, follow-up calls). True = consent granted; False = consent not granted or withdrawn.',
    `consent_withdrawn_date` DATE COMMENT 'Date on which the subject withdrew consent for contact communications. Null if consent has not been withdrawn. Once populated, all non-safety-critical outreach must cease per GDPR right to withdraw.',
    `contact_status` STRING COMMENT 'Current lifecycle status of the subject contact record. active indicates the contact details are current and in use; inactive indicates superseded or no longer valid; withdrawn indicates the subject has withdrawn consent for contact. Valid values are `active|inactive|withdrawn|pending_verification|deceased`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the subjects home address (e.g., USA, GBR, DEU). Determines applicable data privacy regulations (GDPR, HIPAA) and communication rules.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this subject contact record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) principles.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Hard stop flag indicating the subject must not be contacted under any circumstances (excluding mandatory safety communications). True = do not contact; False = contact permitted per consent settings. Overrides all other contact preferences.',
    `effective_from_date` DATE COMMENT 'Date from which this contact record is considered valid and active. Supports temporal versioning of contact information to maintain a history of address and phone changes over the course of a long-running trial.',
    `email_address` STRING COMMENT 'Primary email address for the subject. Used for electronic communications including visit reminders, eConsent notifications, and patient engagement via Clinpal.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `email_consent_flag` BOOLEAN COMMENT 'Indicates whether the subject has specifically consented to receive communications via email. True = email contact permitted; False = email contact not permitted. Distinct from general contact consent as email may carry additional regulatory requirements.',
    `emergency_contact_name` STRING COMMENT 'Full name of the subjects designated emergency contact person. Used by site staff to reach a responsible party in the event of a serious adverse event (SAE) or medical emergency.',
    `emergency_contact_phone` STRING COMMENT 'Phone number for the subjects emergency contact. Used exclusively for safety-related communications and serious adverse event (SAE) follow-up.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `emergency_contact_relationship` STRING COMMENT 'Relationship of the emergency contact person to the subject (e.g., spouse, parent, legal guardian). Provides context for site staff when initiating emergency communications.',
    `last_contact_date` DATE COMMENT 'Date of the most recent successful contact with the subject. Used to track subject engagement, identify subjects at risk of dropout, and support visit compliance monitoring.',
    `last_contact_method` STRING COMMENT 'Communication channel used during the most recent successful contact with the subject. Supports analysis of effective outreach strategies and visit compliance improvement.. Valid values are `phone|email|sms|mail|in_person`',
    `notes` STRING COMMENT 'Free-text notes recorded by site staff regarding the subjects contact preferences, special communication instructions, or relevant context (e.g., best time to call, language interpreter required).',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the subjects home address. Used for geographic analysis, site feasibility, and postal communications.',
    `preferred_contact_method` STRING COMMENT 'Subjects stated preference for how they wish to be contacted by the site or sponsor. Governs outreach channel selection for visit reminders and safety follow-up. no_contact indicates the subject has requested no proactive outreach.. Valid values are `phone|email|sms|mail|no_contact`',
    `preferred_contact_time` TIMESTAMP COMMENT 'Subjects preferred time of day to be contacted. Supports scheduling of outreach calls and reminders to maximize response rates and respect subject preferences.',
    `preferred_language` STRING COMMENT 'ISO 639-1/639-2 language code representing the subjects preferred language for communications (e.g., en, fr, de, zh-CN). Ensures communications are delivered in the subjects native language to support informed participation.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `primary_phone` STRING COMMENT 'Primary telephone number for contacting the subject. Used for visit reminders, recruitment follow-up, and safety follow-up communications. Stored in international format where possible.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `primary_phone_type` STRING COMMENT 'Classification of the primary phone number (e.g., mobile, home, work). Informs the appropriate time and method for outreach.. Valid values are `mobile|home|work|other`',
    `record_type` STRING COMMENT 'Classification of the contact record indicating the role of the contact in relation to the subject. primary is the subject themselves; secondary is an alternate contact; emergency is for emergency use only; caregiver is a designated caregiver. Valid values are `primary|secondary|emergency|caregiver|legal_representative`',
    `safety_contact_override_flag` BOOLEAN COMMENT 'Indicates whether safety-critical communications (e.g., SAE follow-up, urgent safety notifications) are permitted even when do_not_contact_flag is True. True = safety contact allowed regardless of general consent; False = all contact restricted.',
    `secondary_phone` STRING COMMENT 'Alternate telephone number for the subject, used when the primary phone is unreachable. Supports visit compliance and safety follow-up.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `secondary_phone_type` STRING COMMENT 'Classification of the secondary phone number (e.g., mobile, home, work).. Valid values are `mobile|home|work|other`',
    `sms_consent_flag` BOOLEAN COMMENT 'Indicates whether the subject has specifically consented to receive communications via SMS/text message. True = SMS contact permitted; False = SMS contact not permitted.',
    `source_system_contact_key` STRING COMMENT 'Natural key or unique identifier of this contact record in the originating source system (Clinpal or the source system Enables bidirectional traceability and reconciliation between the lakehouse Silver Layer and the operational system.',
    `state_province` STRING COMMENT 'State, province, or region of the subjects home address. Supports regulatory reporting and geographic stratification of subject populations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this subject contact record. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ principles. Tracks when contact details were last updated by site staff.',
    CONSTRAINT pk_subject_contact PRIMARY KEY(`subject_contact_id`)
) COMMENT 'Canonical contact entity for trial subject emergency contacts, next of kin, and legally authorized representatives. Sponsor organization contacts reference sponsor.sponsor_contact; this entity is reserved for subject-related contacts only.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` (
    `stipend_payment_id` BIGINT COMMENT 'Unique surrogate identifier for each stipend or reimbursement payment record issued to a trial participant. Primary key of this table.',
    `agreement_investigator_grant_id` BIGINT COMMENT 'Foreign key linking to agreement.investigator_grant. Business justification: Investigator grants define IRB-approved stipend amounts and payment schedules for subjects.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: IRB-approved stipend payments require documented approval by a named study staff member (CRC/study coordinator) for audit trail, IRB compliance, and financial reconciliation reports.',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: Change orders can revise subject reimbursement amounts, payment schedules, or add new payment categories.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: IRB regulations require stipend payments only to subjects consented under an IRB-approved ICF version containing the approved payment schedule.',
    `enrollment_id` BIGINT COMMENT 'Reference to the subject enrollment record, linking the payment to the subjects study participation context including treatment arm and randomization assignment.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: IRB/IEC must approve subject compensation amounts and schedules as part of ethics review.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subject is enrolled and where the associated visit or activity generating this payment occurred.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: IRB/IEC approvals specify the maximum allowable stipend amounts and payment schedules for subject participation.',
    `patient_stipend_id` BIGINT COMMENT 'Foreign key linking to finance.patient_stipend. Business justification: Stipend reconciliation process: the CTMS operational stipend_payment record must be matched to the finance.patient_stipend accounting record for month-end close, IRB compliance',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: IRB-approved stipend schedules are tied to specific protocol versions; payments must be validated against the IRB-approved amount for that protocol version.',
    `site_agreement_id` BIGINT COMMENT 'Foreign key linking to site.site_agreement. Business justification: Subject stipend payments are governed by the site agreements per-patient fee schedule and payment terms.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this stipend payment was issued. Links the payment to the governing protocol and IRB/IEC-approved payment schedule.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the specific study visit that triggered this stipend or reimbursement payment, enabling reconciliation of payments against visit attendance records.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the supporting receipt or expense documentation submitted by the subject to substantiate a reimbursement claim (e.g., travel receipts, parking tickets). Links to the document management system.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial participant (subject/patient) who received this stipend or reimbursement payment. Core party reference for this transaction.',
    `approval_date` DATE COMMENT 'Date on which the payment was formally approved by the authorized approver (e.g., site coordinator, sponsor representative) prior to disbursement. Supports audit trail and approval workflow compliance.',
    `approved_amount` DECIMAL(18,4) COMMENT 'Amount formally authorized for disbursement following review and approval, which may differ from the requested amount if partial approval was granted or adjustments were made during the approval workflow.',
    `cleared_date` DATE COMMENT 'Date on which the payment was confirmed as received and settled by the subject (e.g., check cashed, ACH settled, card loaded). Used for financial reconciliation and outstanding payment tracking.',
    `clincard_transaction_reference` STRING COMMENT 'Unique transaction identifier assigned by the Greenphire ClinCard payment platform for this disbursement. Used for reconciliation between the clinical trial management system and the ClinCard payment processor.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this stipend payment record was first created in the system. Supports audit trail, data lineage, and ALCOA+ compliance requirements for clinical trial data.',
    `ctms_payment_key` STRING COMMENT 'Source system record identifier from the source system for this payment record. Enables bidirectional traceability between the lakehouse silver layer and the operational CTMS source system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the payment amount (e.g., USD, EUR, GBP, JPY). Required for multi-country studies to support financial reconciliation and tax reporting.. Valid values are `^[A-Z]{3}$`',
    `irb_approved_amount` DECIMAL(18,4) COMMENT 'The maximum per-visit or per-activity payment amount as approved by the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) for this study.',
    `irb_payment_schedule_version` STRING COMMENT 'Version identifier of the IRB/IEC-approved payment schedule that governs this payment. Ensures traceability to the specific approved schedule in effect at the time of payment, supporting regulatory audit readiness.',
    `over_irb_threshold_flag` BOOLEAN COMMENT 'Indicates whether this payment exceeds the IRB/IEC-approved maximum payment amount for the associated visit or activity type. True triggers a compliance review workflow to ensure undue inducement rules are not violated.',
    `payment_amount` DECIMAL(18,4) COMMENT 'Gross amount of the stipend or reimbursement payment issued to the subject in the transaction currency, before any tax withholding. This is the base monetary amount per the IRB/IEC-approved payment schedule.',
    `payment_date` DATE COMMENT 'The actual calendar date on which the payment was issued/disbursed to the subject. This is the principal business event date for this transaction, used for tax year determination and financial reporting.',
    `payment_method` STRING COMMENT 'Instrument used to disburse the payment to the subject. check = paper check; ach = Automated Clearing House bank transfer; gift_card = retail gift card; prepaid_debit_card = reloadable prepaid card (e.g., Greenphire ClinCard); clincard =. Valid values are `check|ach|gift_card|prepaid_debit_card|clincard|wire_transfer`',
    `payment_notes` STRING COMMENT 'Free-text field for additional context, special circumstances, or operational notes related to this payment (e.g., delayed payment justification, partial payment explanation, subject hardship accommodation). Not for audit trail entries.',
    `payment_processor` STRING COMMENT 'System or entity responsible for processing and disbursing the payment. greenphire_clincard = Greenphire ClinCard platform; sponsor_direct = sponsor-issued payment; site_petty_cash = site-managed cash reimbursement; accounts_payable = routed. Valid values are `greenphire_clincard|sponsor_direct|site_petty_cash|accounts_payable|other`',
    `payment_reference_number` STRING COMMENT 'Externally-known unique business identifier for this payment transaction as assigned by the payment processing system (Greenphire ClinCard or the source system Used for reconciliation, audit, and subject inquiries.',
    `payment_status` STRING COMMENT 'Current lifecycle state of the stipend payment. pending = awaiting approval; approved = authorized but not yet disbursed; issued = disbursed to subject; cleared = confirmed received/settled; voided = cancelled and reversed.. Valid values are `pending|approved|issued|cleared|voided`',
    `payment_type` STRING COMMENT 'Classification of the payment purpose. stipend = compensation for time and inconvenience; travel_reimbursement = transport costs; meal_allowance = food costs; lodging_reimbursement = overnight accommodation; parking_reimbursement = parking fees. Valid values are `stipend|travel_reimbursement|meal_allowance|lodging_reimbursement|parking_reimbursement|other_reimbursement`',
    `reimbursement_request_date` DATE COMMENT 'Date on which the subject or site submitted the reimbursement request or expense claim. Used to track processing turnaround time and ensure timely payment per protocol commitments.',
    `subject_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the subjects country of residence at the time of payment. Determines applicable tax reporting requirements, withholding rules, and regulatory jurisdiction for the payment.. Valid values are `^[A-Z]{3}$`',
    `tax_reportable_flag` BOOLEAN COMMENT 'Indicates whether this payment is subject to tax reporting obligations (e.g., IRS Form 1099-MISC for US subjects). True when the cumulative annual payments to the subject meet or exceed the IRS reporting threshold ($600 USD).',
    `tax_year` BIGINT COMMENT 'Calendar year in which this payment was issued, used for IRS 1099 reporting period assignment and annual tax reporting aggregation for US subjects.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this stipend payment record. Used for change detection, incremental data loading, and audit trail compliance per 21 CFR Part 11 and ALCOA+ principles.',
    `visit_type_at_payment` STRING COMMENT 'Type of study visit associated with this payment (e.g., screening, baseline, treatment, follow-up, unscheduled). Captured at payment time to support payment schedule compliance analysis independent of visit record changes.',
    `void_date` DATE COMMENT 'Date on which the payment was voided or cancelled. Populated only when payment_status is voided. Required for financial reconciliation and audit trail.',
    `void_reason` STRING COMMENT 'Free-text explanation for why the payment was voided (e.g., duplicate payment, subject withdrew, incorrect amount, payment returned). Required when void_date is populated.',
    `withholding_amount` DECIMAL(18,4) COMMENT 'Amount withheld from the gross payment for tax purposes (e.g., backup withholding for US subjects who have not provided a valid TIN/SSN). Net payment to subject equals payment_amount minus withholding_amount.',
    `ytd_payment_total` DECIMAL(18,4) COMMENT 'Cumulative total of all stipend and reimbursement payments made to this subject within the current calendar year across all studies, as of this payment. Used for IRS 1099 threshold tracking and tax reporting compliance for US subjects.',
    CONSTRAINT pk_stipend_payment PRIMARY KEY(`stipend_payment_id`)
) COMMENT 'Transactional record of subject stipend and reimbursement payments issued to trial participants for visit attendance, travel expenses, and participation costs per IRB/IEC-approved payment schedule.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`population_assignment` (
    `population_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for each population assignment record in the Silver Layer lakehouse. Primary key for this transactional entity.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: population_assignment is the operational bridge assigning subjects to analysis populations; it must reference the specific analysis_population_id being assigned.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Analysis population assignments (ITT, PP, Safety) are arm-specific. FK to study_arm enables arm-level population counts in CSR tables, the source system-defined population summaries, and',
    `database_lock_event_id` BIGINT COMMENT 'Reference to the database lock event during which this population assignment was finalized. Ensures traceability of population assignments to a specific DBL milestone, critical for regulatory submission integrity.',
    `decision_id` BIGINT COMMENT 'Foreign key linking to program.program_decision. Business justification: Governance decisions (interim analysis outcomes, unblinding decisions, DSMB recommendations) drive population assignment changes.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Analysis population assignments (ITT, PP, Safety) are made for a subject within the context of a specific enrollment.',
    `estimand_id` BIGINT COMMENT 'Reference to the estimand definition (per ICH E9(R1)) that this population assignment supports. Links the population to the specific treatment effect being estimated, including intercurrent event handling strategy.',
    `primary_population_employee_id` BIGINT COMMENT 'Reference to the biostatistician or statistical reviewer who determined and approved this population assignment. Supports ALCOA+ attributability requirements and audit trail for regulatory submissions.',
    `primary_superseded_by_population_assignment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the newer population assignment record that supersedes this one (e.g., after a protocol amendment or the source system if this is the current active assignment. Supports assignment version history.',
    `randomization_assignment_id` BIGINT COMMENT 'Foreign key linking to subject.randomization_assignment. Business justification: Population assignments (ITT, PP, Safety) are directly tied to a subjects randomization event — the treatment arm and randomization number determine which analysis',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: ADaM analysis population datasets (ITT, PP, Safety) are stratified by treatment arm per the source system',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) version that defines the criteria and rules governing this population assignment. Ensures population definitions are traceable to the approved the source system.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this population assignment was determined. Links the assignment to the governing protocol and sponsor.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments can redefine analysis populations (e.g., change ITT definition).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subject was enrolled, used for site-level population analytics and CONSORT flow reporting.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) receiving this population assignment. Core party reference for this transactional record.',
    `adam_flag_value` BOOLEAN COMMENT 'The CDISC ADaM-compliant flag value (Y or N) for the population flag variable, conforming to CDISC controlled terminology. Directly used in ADaM dataset generation for regulatory submissions.',
    `adam_population_flag_variable` STRING COMMENT 'The CDISC ADaM variable name corresponding to this population assignment (e.g., ITTFL, SAFFL, PPROTFL, PKFL). Used to map Silver Layer records to SDTM/ADaM submission datasets for regulatory packages (NDA, BLA, MAA).',
    `amendment_driven_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) denoting whether this population assignment was created or revised as a direct result of a protocol amendment. Supports impact analysis of protocol changes on analysis populations.',
    `analysis_cutoff_date` DATE COMMENT 'The data cutoff date used to determine subject eligibility for this population assignment. All subject data up to and including this date was considered in the population determination.',
    `approval_status` STRING COMMENT 'Workflow approval status of the population assignment record (draft, under_review, approved, rejected). Tracks the QC/QA review lifecycle before the assignment is finalized for regulatory submission.. Valid values are `draft|under_review|approved|rejected`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the population assignment was formally approved by the authorized statistical reviewer. Required for 21 CFR Part 11 electronic signature audit trail.',
    `assignment_date` DATE COMMENT 'Calendar date on which the biostatistics team formally assigned the subject to this analysis population, typically at or after Database Lock (DBL). Critical business event date for audit trail and regulatory submission timelines.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of this population assignment record. included = subject is a member of the population; excluded = subject is explicitly excluded; pending = under biostatistics review; superseded = replaced by a later assignment after. Valid values are `included|excluded|pending|superseded`',
    `assignment_timestamp` TIMESTAMP COMMENT 'Precise date and time (ISO 8601 with timezone offset) when the population assignment record was created or last confirmed in the SAS Drug Development system. Supports 21 CFR Part 11 electronic record audit requirements.',
    `comments` STRING COMMENT 'Free-text comments or notes from the biostatistician or statistical reviewer regarding this population assignment, including any edge cases, adjudication decisions, or sponsor queries resolved during the assignment process.',
    `consort_flow_category` STRING COMMENT 'Category used to classify this subjects disposition in the CONSORT flow diagram (e.g., randomized, allocated, lost_to_followup, discontinued, analyzed, excluded). Required for CSR Section 10 and regulatory submission disposition tables.. Valid values are `randomized|allocated|lost_to_followup|discontinued|analyzed|excluded`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this population assignment record was first created in the Silver Layer lakehouse. Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `exclusion_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) denoting whether the subject is explicitly excluded from this analysis population. Complements inclusion_flag to support CONSORT flow diagrams and regulatory disposition tables.',
    `exclusion_reason_code` STRING COMMENT 'Coded reason for exclusion from the analysis population when exclusion_flag is True (e.g., NO_DOSE, MAJOR_PROTOCOL_DEVIATION, CONSENT_WITHDRAWN, ELIGIBILITY_CRITERIA_NOT_MET).',
    `exclusion_reason_description` STRING COMMENT 'Verbatim or standardized narrative description of why the subject was excluded from this analysis population. Supports regulatory reviewer queries and CSR narrative sections.',
    `inclusion_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) denoting whether the subject is included in this analysis population. True = subject meets all criteria and is included; False = subject is excluded.',
    `interim_analysis_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) denoting whether this population assignment was generated for an interim analysis rather than the final database lock. Interim assignments may differ from final assignments and must be tracked separately.',
    `interim_analysis_number` BIGINT COMMENT 'Sequential number identifying which interim analysis this population assignment corresponds to (e.g., 1 = first interim, 2 = second interim). Null for final analysis assignments. Used by DSMB/DMC reporting.',
    `population_code` STRING COMMENT 'Standardized code identifying the analysis population to which the subject is assigned (e.g., ITT = Intent-to-Treat, mITT = modified Intent-to-Treat, PP = Per-Protocol, SAF = Safety, PK = Pharmacokinetic, PD = Pharmacodynamic, FAS = Full Analysis Set).',
    `population_name` STRING COMMENT 'Full descriptive name of the analysis population (e.g., Intent-to-Treat Population, Per-Protocol Population, Safety Population). Used in CSR tables, TLF shells, and regulatory submission narratives.',
    `randomization_number` STRING COMMENT 'The IRT/RTSM-assigned randomization number for the subject at the time of population assignment. Used to cross-reference with randomization_assignment records and validate treatment arm alignment in population analyses.',
    `reviewer_role` STRING COMMENT 'Role of the individual who performed or approved the population assignment (e.g., biostatistician, lead statistician, statistical programmer). Supports audit trail and responsibility tracking per GCP requirements.. Valid values are `biostatistician|lead_statistician|statistical_programmer|data_manager|sponsor_reviewer`',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain associated with the primary data supporting this population assignment (e.g., DM for Demographics, DS for Disposition, EX for Exposure). Used for regulatory submission dataset traceability.',
    `sensitivity_analysis_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) denoting whether this population assignment is used in a sensitivity analysis rather than the primary analysis. Sensitivity analyses test robustness of primary population definitions per ICH E9(R1) estimand framework.',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating source system (SAS Drug Development job ID, the source system record key). Enables bidirectional traceability between the Silver Layer and the operational system of record.',
    `subject_number` STRING COMMENT 'The human-readable subject identifier (e.g., 001-001) as assigned by the site and recorded in the EDC system. Used for cross-referencing with eCRF data and regulatory submission datasets.',
    `unique_subject_identifier` STRING COMMENT 'The CDISC SDTM-compliant Unique Subject Identifier (USUBJID) combining study and subject identifiers (e.g., STUDY001-001-001). Required for regulatory submission datasets and cross-domain subject traceability.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this population assignment record was last modified in the Silver Layer lakehouse. Required for change tracking and regulatory audit trail per 21 CFR Part 11.',
    CONSTRAINT pk_population_assignment PRIMARY KEY(`population_assignment_id`)
) COMMENT 'Transactional record assigning a trial subject to one or more analysis populations (Intent-to-Treat/ITT, modified ITT/mITT, Per-Protocol/PP, Safety/SAF, Pharmacokinetic/PK) as determined by the biostatistics team during database lock.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`demographic` (
    `demographic_id` BIGINT COMMENT 'Unique surrogate identifier for each subject demographic record in the silver layer lakehouse. Primary key for the demographic data product.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: SDTM DM domain requires ARM and ACTARM derivation from the authoritative study_arm definition. Baseline characteristic tables in CSR are stratified by arm.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: SDTM DM domain derivation requires the authoritative consent record to populate RFICDTC (informed consent date).',
    `corrected_demographic_id` BIGINT COMMENT 'Self-referencing FK on demographic (corrected_demographic_id)',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Demographic data is collected on the DM eCRF form. Linking demographic to ecrf_form enables SDV tracking, form version traceability, and SDTM DM domain generation.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Demographic records in clinical trials are captured per enrollment (SDTM DM domain is study-specific).',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: SDTM DM domain requires ARM and ACTARM per subject derived from the canonical treatment_arm definition.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this demographic record was collected. Links the subject demographics to the parent study context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject was enrolled and demographic data was collected.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) whose demographic data is captured in this record. Core linkage to the trial_subject master entity.',
    `sex_codelist_term_id` BIGINT COMMENT 'the subjects sex from CDISC CT codelist SEX (C66731)',
    `race_codelist_term_id` BIGINT COMMENT 'race from CDISC CT codelist RACE (C74457)',
    `age_unit_codelist_term_id` BIGINT COMMENT 'the unit of age_at_screening from CDISC CT codelist AGEU (C66781)',
    `ethnicity_codelist_term_id` BIGINT COMMENT 'ethnicity from CDISC CT codelist ETHNIC (C66790)',
    `age_at_screening` BIGINT COMMENT 'Subjects age in whole years at the time of the screening visit, derived from date of birth and screening date. Used for eligibility verification, stratification, and CDISC SDTM DM domain submission.',
    `birth_year` BIGINT COMMENT 'Subjects year of birth as a four-digit integer. Used when full date of birth is masked for privacy compliance but year-level granularity is required for age-cohort analyses and CDISC partial date handling.',
    `bmi` DECIMAL(5,2) COMMENT 'Subjects body mass index calculated as weight (kg) divided by height squared (m²) at baseline. Stored as a baseline characteristic per CDISC ADaM ADSL convention; used in eligibility assessment and subgroup analyses.',
    `comments` STRING COMMENT 'Free-text field for additional notes or clarifications related to the subjects demographic data, such as explanations for partial dates, data corrections, or special circumstances noted by the site or data manager.',
    `country` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code representing the country where the subject was enrolled. Used for geographic subgroup analyses, regulatory reporting by region, and CDISC SDTM DM domain.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the demographic record was first created in the silver layer lakehouse, in ISO 8601 format with timezone offset. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+.',
    `data_entry_status` STRING COMMENT 'Current data entry and verification status of the demographic eCRF form in the EDC system. Tracks completeness and readiness for database lock (DBL) and SDTM submission.. Valid values are `NOT STARTED|IN PROGRESS|COMPLETE|LOCKED|VERIFIED`',
    `data_source_system` STRING COMMENT 'Identifies the operational system of record from which the demographic data was sourced. Supports data lineage, reconciliation, and audit trail requirements across the lakehouse pipeline.. Valid values are `MEDIDATA_RAVE|ORACLE_CLINICAL_ONE|PAPER_CRF|EXTERNAL_TRANSFER`',
    `date_of_birth` DATE COMMENT 'Subjects date of birth in ISO 8601 format (yyyy-MM-dd). Used to calculate age at key study milestones and to verify age-based eligibility criteria. May be partially masked (year only) per privacy regulations.',
    `dm_sequence_number` BIGINT COMMENT 'Sequential record number within the DM domain for a given subject, per CDISC SDTM convention. Used to uniquely identify each demographic record when multiple records exist per subject (e.g., re-screening scenarios).',
    `edc_subject_key` STRING COMMENT 'Source system record key for the subjects demographic record in the EDC system (Medidata Rave). Enables traceability from the silver layer back to the source EDC record for SDV and audit purposes.',
    `epoch` STRING COMMENT 'The study epoch (e.g., SCREENING, TREATMENT, FOLLOW-UP) during which the demographic data was collected, per CDISC SDTM Trial Epochs dataset. Used for temporal context in multi-epoch study designs.',
    `first_exposure_date` DATE COMMENT 'Date of the subjects first exposure to the investigational product (IP). Defines the start of the treatment period and is the reference date for study day calculations in CDISC SDTM DM domain.',
    `gender_identity` STRING COMMENT 'Subjects self-reported gender identity, distinct from biological sex. Collected per evolving FDA guidance on inclusion of gender identity in clinical trials.',
    `height_cm` DECIMAL(6,2) COMMENT 'Subjects height in centimeters measured at baseline/screening visit. Used for body surface area (BSA) calculations, dose determination, and baseline characteristic tables in the Clinical Study Report (CSR).',
    `informed_consent_date` DATE COMMENT 'Date on which the subject signed the informed consent form (ICF) prior to any study-related procedures. Anchors the CDISC SDTM DM.RFICDTC reference date and is required for regulatory compliance and ALCOA+ data integrity.',
    `last_exposure_date` DATE COMMENT 'Date of the subjects last exposure to the investigational product (IP). Used to define the end of the treatment period and calculate treatment duration for safety and efficacy analyses.',
    `lock_status` STRING COMMENT 'Lock status of the demographic eCRF record in the EDC system. LOCKED records cannot be modified without an audit-trailed unlock. FROZEN records are pending final database lock (DBL).. Valid values are `UNLOCKED|LOCKED|FROZEN`',
    `protocol_version` STRING COMMENT 'Version of the study protocol in effect at the time the demographic data was collected. Ensures traceability of demographic assessments to the applicable protocol amendment.',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether one or more open data queries (discrepancies) exist against this demographic record in the EDC system. True = at least one unresolved query; False = no open queries. Used for data cleaning tracking.',
    `race_other_description` STRING COMMENT 'Free-text description of race when the subject selects OTHER or MULTIPLE as their racial category. Captures verbatim self-reported race for completeness in regulatory submissions.',
    `reference_start_date` DATE COMMENT 'The protocol-defined reference start date for the subject, used as the anchor for study day (STUDYDAY) calculations across all SDTM domains. May differ from first_exposure_date in some study designs (e.g., observational studies).',
    `sdtm_domain` STRING COMMENT 'CDISC SDTM domain code for this record. Always DM for demographic records. Included to support automated SDTM dataset generation and regulatory submission pipelines.',
    `sdv_status` STRING COMMENT 'Status of source data verification (SDV) for the demographic record, indicating whether the EDC data has been verified against source documents by the Clinical Research Associate (CRA) during site monitoring.. Valid values are `NOT REQUIRED|PENDING|VERIFIED|PARTIAL`',
    `subject_number` STRING COMMENT 'Site-assigned subject number used to identify the participant within the study site. Typically formatted as a numeric or alphanumeric code assigned at screening or enrollment.',
    `unique_subject_identifier` STRING COMMENT 'Globally unique identifier for the subject across the study, constructed per CDISC SDTM convention (typically STUDYID-SITEID-SUBJID). Used as the primary cross-domain linkage key in SDTM submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the demographic record in the silver layer lakehouse. Used for incremental data processing, change detection, and audit trail compliance.',
    `weight_kg` DECIMAL(6,2) COMMENT 'Subjects body weight in kilograms measured at baseline/screening visit. Used for dose calculations, PK/PD modeling, BMI derivation, and baseline characteristic tables in the CSR.',
    CONSTRAINT pk_demographic PRIMARY KEY(`demographic_id`)
) COMMENT 'Captures subject demographic data including age, sex, race, ethnicity, height, weight, and other baseline characteristics collected at screening per CDISC DM domain standards.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`medical_history` (
    `medical_history_id` BIGINT COMMENT 'Unique surrogate identifier for each medical history record in the clinical trial system. Primary key for the medical_history data product.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: medical_history.ae_related_flag indicates a pre-existing condition that evolved into an AE.',
    `coded_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: MedDRA coding of medical history conditions must be attributed to the qualified coder for data quality audits, coding consistency reports, and regulatory submission traceability (SDTM MH',
    `coding_assignment_id` BIGINT COMMENT 'Foreign key linking to datamanagement.coding_assignment. Business justification: Medical history conditions require MedDRA coding for SDTM MH domain submission.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Medical history is captured on the MH eCRF form. Replacing the denormalized ecrf_form_name with a proper FK to ecrf_form supports SDV workflows, form version tracking, and SDTM MH',
    `meddra_pt_id` BIGINT COMMENT 'add column meddra_term_id (BIGINT) with FK to terminology.meddra_term.meddra_term_id — per user vibes instruction 4, medical_history must reference MedDRA coded concept',
    `code_system_version_id` BIGINT COMMENT 'Foreign key to the MedDRA dictionary version used to code this medical history.',
    `medical_dictionary_code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_medical_history_id` BIGINT COMMENT 'Self-referencing FK on medical_history (related_medical_history_id)',
    `primary_medical_dictionary_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for MedDRA dictionary version applied',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this medical history record was collected. Links the record to the sponsoring protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the medical history was collected during screening or baseline assessment.',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Medical history is collected during screening visits. medical_history carries a denormalized screening_visit_number (STRING) that should be normalized via FK to subject_visit.',
    `tertiary_medical_code_system_version_id` BIGINT COMMENT 'BIGINT',
    `tertiary_quaternary_medical_meddra_code_system_version_id` BIGINT COMMENT 'MedDRA dictionary version applied when coding this medical history record',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose medical history is recorded. Core linkage to the trial_subject master record.',
    `meddra_term_id` BIGINT COMMENT 'Reference to terminology.meddra_term.meddra_term_id.',
    `meddra_version_id` BIGINT COMMENT 'Reference to safety.meddra_version.meddra_version_id.',
    `ae_related_flag` BOOLEAN COMMENT 'Indicates whether this medical history condition has been associated with or contributed to an adverse event (AE) reported during the study. Supports integrated safety analysis.',
    `assessment_date` DATE COMMENT 'The date on which the medical history was collected or assessed by the investigator or CRC during the screening visit. Corresponds to the eCRF data entry date for this record.',
    `coding_date` DATE COMMENT 'The date on which the verbatim medical history condition was coded to a MedDRA term. Supports audit trail requirements for medical coding activities.',
    `coding_status` STRING COMMENT 'Current status of the MedDRA coding process for this medical history condition. Tracks whether the verbatim term has been coded, auto-coded, reviewed, or approved by the medical coder.. Valid values are `UNCODED|CODED|AUTOCODED|REVIEWED|APPROVED`',
    `comments` STRING COMMENT 'Free-text comments or additional clinical context provided by the investigator regarding this medical history condition. May include relevant clinical details not captured in structured fields.',
    `concomitant_medication_flag` BOOLEAN COMMENT 'Indicates whether the subject is receiving concomitant medication for this medical history condition at the time of screening. Supports concomitant medication reconciliation and safety analysis.',
    `condition_category` STRING COMMENT 'High-level category classifying the type of medical history entry. Corresponds to SDTM MHCAT variable. [ENUM-REF-CANDIDATE: MEDICAL HISTORY|SURGICAL HISTORY|FAMILY HISTORY|PSYCHIATRIC HISTORY|ALLERGY|OBSTETRIC HISTORY — promote to reference product]',
    `condition_status` STRING COMMENT 'Current clinical status of the pre-existing medical condition at the time of data collection. Supports safety profiling and eligibility determination.. Valid values are `ACTIVE|RESOLVED|CHRONIC|INTERMITTENT|UNKNOWN`',
    `condition_subcategory` STRING COMMENT 'Optional secondary classification of the medical history condition providing further granularity within the category (e.g., CARDIOVASCULAR within MEDICAL HISTORY). Corresponds to SDTM MHSCAT.',
    `condition_verbatim` STRING COMMENT 'The verbatim (as-reported) text of the pre-existing medical condition or medical history event as entered by the investigator or CRC in the eCRF. This is the raw, uncoded term prior to MedDRA coding.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this medical history record was first created in the EDC system or lakehouse. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `edc_record_reference` STRING COMMENT 'The unique record identifier assigned by the EDC system (Medidata Rave) for this medical history entry. Used for source data verification (SDV) and data reconciliation.',
    `eligibility_relevant_flag` BOOLEAN COMMENT 'Indicates whether this medical history condition is relevant to the studys inclusion/exclusion eligibility criteria. Used by the medical monitor and data management team to assess protocol compliance.',
    `lock_status` STRING COMMENT 'Data lock status of this medical history record in the EDC system. Locked records cannot be modified without an authorized unlock procedure, supporting database lock (DBL) integrity.. Valid values are `UNLOCKED|LOCKED|FROZEN`',
    `meddra_llt` STRING COMMENT 'The MedDRA Lowest Level Term (LLT) that most closely maps to the verbatim condition text. Provides the most granular level of MedDRA coding hierarchy.',
    `meddra_pt` STRING COMMENT 'The MedDRA Preferred Term (PT) assigned to the verbatim medical history condition during medical coding. Used for standardized regulatory reporting and safety analysis.',
    `meddra_soc` STRING COMMENT 'The MedDRA System Organ Class (SOC) associated with the coded medical history condition. Used for aggregate safety reporting and tabulation by body system.',
    `meddra_version` STRING COMMENT 'The version of the MedDRA dictionary used to code this medical history condition (e.g., 26.0). Required for regulatory submissions to ensure reproducibility of coding.',
    `mh_seq` BIGINT COMMENT 'Sequential number identifying each medical history record for a given subject within a study. Corresponds to the SDTM MHSEQ variable used in regulatory submissions.',
    `ongoing_flag` BOOLEAN COMMENT 'Indicates whether the medical history condition was ongoing at the time of the subjects screening or baseline assessment. True = condition is still active; False = condition has resolved. Corresponds to SDTM MHENRF or MHONGO.',
    `onset_date` DATE COMMENT 'The date on which the pre-existing medical condition first began or was first diagnosed. May be partial (year only or year-month) per CDISC partial date conventions. Corresponds to SDTM MHSTDTC.',
    `pre_existing_flag` BOOLEAN COMMENT 'Indicates whether the condition was present prior to the subjects first dose of investigational product. Distinguishes pre-existing conditions from treatment-emergent adverse events (TEAEs) in safety analysis.',
    `protocol_version` STRING COMMENT 'The version of the study protocol in effect at the time this medical history record was collected. Ensures traceability of data to the applicable protocol amendment.',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether there is at least one open data query (discrepancy) against this medical history record in the EDC system. Supports data cleaning and database lock readiness tracking.',
    `resolution_date` DATE COMMENT 'The date on which the pre-existing medical condition resolved or ended. Null if the condition is ongoing at the time of assessment. Corresponds to SDTM MHENDTC.',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain code for this record. For medical history records this is always MH. Used during SDTM dataset generation for regulatory submissions.',
    `sdv_date` DATE COMMENT 'The date on which source data verification was completed for this medical history record by the Clinical Research Associate (CRA).',
    `sdv_status` STRING COMMENT 'Status of source data verification for this medical history record. Indicates whether the CRA has verified the eCRF data against source documents at the investigational site.. Valid values are `NOT REQUIRED|PENDING|VERIFIED|QUERIED`',
    `severity` STRING COMMENT 'Clinical severity grading of the pre-existing medical condition as assessed by the investigator. Supports safety profiling and eligibility assessment.. Valid values are `MILD|MODERATE|SEVERE`',
    `source_system_record_reference` STRING COMMENT 'The native primary key or record identifier of this medical history entry in the originating source system (e.g., Medidata Rave record OID). Enables bidirectional traceability between the lakehouse and the EDC.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this medical history record was last modified in the EDC system or lakehouse. Required for audit trail compliance and change tracking per 21 CFR Part 11.',
    `verbatim_term` STRING COMMENT 'STRING',
    CONSTRAINT pk_medical_history PRIMARY KEY(`medical_history_id`)
) COMMENT 'Records subject medical history and pre-existing conditions collected during screening, coded to MedDRA terms, with onset dates, resolution status, and relevance to study eligibility.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` (
    `concomitant_medication_id` BIGINT COMMENT 'Unique surrogate identifier for each concomitant medication record in the Silver Layer lakehouse. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the adverse event record that prompted initiation or modification of this concomitant medication, when ae_related_flag is True. Supports traceability between safety events and concomitant medication changes.',
    `coding_assignment_id` BIGINT COMMENT 'Foreign key linking to datamanagement.coding_assignment. Business justification: Concomitant medications require WHO Drug Dictionary coding for SDTM CM domain.',
    `concomitant_dictionary_code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `continuation_of_concomitant_medication_id` BIGINT COMMENT 'Self-referencing FK on concomitant_medication (continuation_of_concomitant_medication_id)',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Concomitant medications are collected within the context of a specific study enrollment.',
    `primary_concomitant_dictionary_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for WHODrug dictionary version applied',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this concomitant medication record was collected.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the concomitant medication was reported or collected.',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Concomitant medications are recorded and assessed at study visits. concomitant_medication carries denormalized visit_name (STRING) and visit_number (INT) that should be normalized via',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) for whom this concomitant medication is recorded.',
    `whodrug_drug_record_id` BIGINT COMMENT 'add column whodrug_drug_record_id (BIGINT) with FK to terminology.whodrug_drug_record.whodrug_drug_record_id — per user vibes instruction 4, concomitant_medication must reference WHODrug coded concept',
    `whodrug_record_id` BIGINT COMMENT 'Foreign key to the WHODrug dictionary record for the coded concomitant medication.',
    `code_system_version_id` BIGINT COMMENT 'Foreign key to the WHODrug dictionary version used to code this concomitant medication.',
    `dose_form_codelist_term_id` BIGINT COMMENT 'the dose form from CDISC CT codelist FRM (C66726)',
    `route_codelist_term_id` BIGINT COMMENT 'the route from CDISC CT codelist ROUTE (C66729)',
    `dose_unit_codelist_term_id` BIGINT COMMENT 'the dose unit from CDISC CT codelist UNIT (C71620)',
    `ae_related_flag` BOOLEAN COMMENT 'Indicates whether this concomitant medication was initiated or modified in response to an adverse event (AE). Supports causality assessment and safety narrative construction in the source system',
    `concomitant_medication_category` STRING COMMENT 'Sponsor-defined category grouping for the concomitant medication (e.g., PRIOR, CONCOMITANT, PROHIBITED, RESCUE). Corresponds to SDTM CMCAT. Used for protocol-specific medication classification and reporting.',
    `cm_seq` BIGINT COMMENT 'Sequential number identifying each concomitant medication record for a given subject within a study, used for SDTM CM domain sequencing (CMSEQ). Enables ordering of multiple medication records per subject.',
    `comments` STRING COMMENT 'Free-text comments or notes entered by the investigator, CRC, or data manager regarding this concomitant medication record. May include clarifications on dose changes, interruptions, or special circumstances not captured in structured fields.',
    `concomitant_flag` BOOLEAN COMMENT 'Indicates whether the medication was taken concomitantly (during the study treatment period) as opposed to only in the pre-study period. Supports classification of medications as prior vs. concomitant per SDTM CM domain conventions.',
    `data_entry_timestamp` TIMESTAMP COMMENT 'The date and time when this concomitant medication record was first entered into the EDC system (Medidata Rave). Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic record compliance.',
    `dose` DECIMAL(10,4) COMMENT 'The numeric dose amount of the concomitant medication administered per dose event. Corresponds to SDTM CMDOSE. Must be interpreted in conjunction with dose_unit.',
    `dose_frequency` STRING COMMENT 'The frequency at which the concomitant medication is administered (e.g., QD, BID, TID, QID, PRN, weekly). Corresponds to SDTM CMDOSFRQ. Uses CDISC controlled terminology for standardized reporting.',
    `end_date` DATE COMMENT 'The date on which the subject stopped taking the concomitant medication. Corresponds to SDTM CMENDTC (date portion). Null if medication is ongoing at time of data collection. Used for duration calculations and temporal overlap analysis.',
    `indication` STRING COMMENT 'The clinical reason or medical condition for which the concomitant medication is being taken, as reported by the subject or investigator. Corresponds to SDTM CMINDC. Used for safety and drug-drug interaction analysis.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this concomitant medication record was most recently modified in the source EDC system. Required for audit trail compliance per 21 CFR Part 11 and ALCOA+ principles.',
    `modified_drug_name` STRING COMMENT 'Standardized or sponsor-modified version of the verbatim drug name after data cleaning, prior to WHO-DD coding. Corresponds to SDTM CMMODIFY. Used when the verbatim term is modified for coding purposes.',
    `ongoing_flag` BOOLEAN COMMENT 'Indicates whether the concomitant medication was still ongoing at the time of the last assessment or data collection. Corresponds to SDTM CMONGO. True when end_date is not yet known or medication continues beyond the observation window.',
    `prior_therapy_flag` BOOLEAN COMMENT 'Indicates whether the medication was taken prior to the start of the study (pre-existing medication) as opposed to being initiated during the study. Corresponds to SDTM CMPRESP/CMOCCUR context.',
    `prohibited_medication_flag` BOOLEAN COMMENT 'Indicates whether this concomitant medication is classified as a prohibited medication per the study protocol. A True value may trigger a protocol deviation review. Critical for protocol compliance monitoring.',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether there is at least one open data discrepancy query against this concomitant medication record in the EDC system. Supports data management workflow tracking and database lock (DBL) readiness assessment.',
    `record_status` STRING COMMENT 'Current data management status of the concomitant medication record in the EDC system (Medidata Rave). Indicates whether the record is active, has been deleted, amended after lock, or locked for database lock (DBL).. Valid values are `ACTIVE|DELETED|AMENDED|LOCKED`',
    `rescue_medication_flag` BOOLEAN COMMENT 'Indicates whether this medication was administered as a rescue therapy per the study protocol (e.g., for breakthrough pain, hypoglycemia rescue). Rescue medication use is a key efficacy endpoint in many trials.',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain code for this record. Always CM (Concomitant and Prior Medications) for records in this product. Used for SDTM dataset generation and regulatory submission via eCTD.',
    `sdv_status` STRING COMMENT 'Current source data verification (SDV) status for this concomitant medication record, as tracked by the Clinical Research Associate (CRA) in the CTMS. Indicates whether the data has been verified against source documents.. Valid values are `NOT_REQUIRED|PENDING|VERIFIED|FAILED`',
    `source_record_reference` STRING COMMENT 'The native record identifier from the source EDC system (e.g., Medidata Rave internal record key) for this concomitant medication entry. Enables bidirectional traceability between the lakehouse Silver Layer and the operational system of record.',
    `start_date` DATE COMMENT 'The date on which the subject began taking the concomitant medication. Corresponds to SDTM CMSTDTC (date portion). Used to determine temporal overlap with investigational product exposure and adverse event onset.',
    `study_day_end` BIGINT COMMENT 'The study day on which the concomitant medication was stopped, calculated relative to the reference start date. Corresponds to SDTM CMENDY. Null if medication is ongoing. Used for duration and overlap calculations.',
    `study_day_start` BIGINT COMMENT 'The study day on which the concomitant medication was started, calculated relative to the reference start date (Day 1 = first dose of investigational product). Corresponds to SDTM CMSTDY. Enables temporal analysis relative to IP exposure.',
    `subcategory` STRING COMMENT 'Sponsor-defined subcategory for further classification of the concomitant medication within its category (e.g., ANALGESIC, ANTIBIOTIC, ANTIHYPERTENSIVE). Corresponds to SDTM CMSCAT. Enables granular therapeutic class reporting.',
    `verbatim_drug_name` STRING COMMENT 'The medication name exactly as reported by the subject or investigator on the electronic Case Report Form (eCRF), prior to WHO-DD coding. Corresponds to SDTM CMTRT field. Preserved for source data traceability per ALCOA+ principles.',
    `verbatim_term` STRING COMMENT 'STRING',
    `whodrug_atc_code` STRING COMMENT 'The Anatomical Therapeutic Chemical (ATC) classification code assigned by the WHO Drug Dictionary (WHO-DD) for the concomitant medication. Enables therapeutic class-level analysis and drug-drug interaction assessment.. Valid values are `^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$`',
    `whodrug_drug_name` STRING COMMENT 'WHODrug drug name (verbatim/coded).',
    `whodrug_version` STRING COMMENT 'Version of the WHO Drug Dictionary (WHO-DD) used for coding this concomitant medication record. Required for regulatory submissions to ensure reproducibility of coded data.',
    CONSTRAINT pk_concomitant_medication PRIMARY KEY(`concomitant_medication_id`)
) COMMENT 'Records medications taken by subjects before and during the trial, including drug name, indication, dose, route, start/stop dates, and WHO-DD coding.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` (
    `visit_billing_reconciliation_id` BIGINT COMMENT 'Primary key for the visit_billing_reconciliation association',
    `invoice_line_id` BIGINT COMMENT 'Foreign key linking to the sponsor invoice line item under which this subject visit is being billed.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — visit billing reconciliation should reference the study for financial traceability',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to the subject visit record being reconciled against a sponsor invoice line.',
    `billing_period_end` DATE COMMENT 'The end date of the billing period during which this subject visit was included in the invoice line. Together with billing_period_start, defines the billing window for this reconciliation record.',
    `billing_period_start` DATE COMMENT 'The start date of the billing period during which this subject visit was included in the invoice line. Belongs to the reconciliation relationship as it defines the temporal scope of this specific visit-to-line billing association.',
    `billing_status` STRING COMMENT 'Current status of the billing reconciliation for this subject visit against this invoice line. Tracks the lifecycle of the billing event from initial inclusion through dispute resolution and final reconciliation.',
    `quantity_billed` DECIMAL(18,4) COMMENT 'The number of visit units attributed to this subject_visit on this invoice_line. Belongs to the reconciliation relationship as it represents the billing quantity allocated to this specific visit-line pairing, which may differ from the',
    `subject_count` BIGINT COMMENT 'Number of clinical trial subjects (patients) associated with this billing line item, applicable for per-patient billing milestones such as enrollment, randomization, or completion fees.',
    `visit_completion_date` DATE COMMENT 'The date the subject visit was confirmed complete and eligible for billing reconciliation against this invoice line. Belongs to the reconciliation relationship, not to the visit record alone, as the billing-eligible completion date may differ from the',
    CONSTRAINT pk_visit_billing_reconciliation PRIMARY KEY(`visit_billing_reconciliation_id`)
) COMMENT 'This association product represents the billing reconciliation event between a subject_visit and an invoice_line in clinical trials sponsor invoicing. It captures the operational linkage used by finance teams to reconcile per-visit billing charges on';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`sdv_review` (
    `sdv_review_id` BIGINT COMMENT 'Primary key for the sdv_review association',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — SDV review should reference the study for operational context',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to the subject visit that was reviewed during this SDV review event.',
    `trial_subject_id` BIGINT COMMENT 'add column trial_subject_id (BIGINT) with FK to subject.trial_subject.trial_subject_id — SDV review should reference the trial subject',
    `review_date` DATE COMMENT 'The calendar date on which the CRA performed SDV for this subject visit during this monitoring visit. Distinct from the monitoring visit actual_start_date as SDV may span multiple days.',
    `review_status` STRING COMMENT 'Current lifecycle status of this SDV review record. Drives follow-up actions and monitoring report completeness checks.',
    `sdv_coverage_percent` DECIMAL(18,2) COMMENT 'Percentage of data points or CRF fields within this subject visit that were verified during this monitoring visit. Belongs to the review pair, not to either entity alone.',
    `sdv_date` DATE COMMENT 'Date on which Source Data Verification (SDV) was completed for this visit by the assigned CRA. Null if SDV has not been completed. Used for monitoring compliance reporting.',
    `sdv_outcome` STRING COMMENT 'Result of the SDV review for this subject visit during this monitoring visit. Captures whether data was verified clean, discrepancies were found, or verification was not possible.',
    `sdv_performed` BOOLEAN COMMENT 'Indicates whether Source Data Verification was actually conducted for this subject visit during this monitoring visit. False indicates the subject visit was in scope but SDV was not completed (e.g., source documents unavailable).',
    `sdv_status` STRING COMMENT 'Status of Source Data Verification (SDV) for this visit, indicating whether the CRA has verified the eCRF data against source documents. Drives monitoring visit planning and risk-based monitoring decisions.. Valid values are `not_required|pending|partial|complete`',
    CONSTRAINT pk_sdv_review PRIMARY KEY(`sdv_review_id`)
) COMMENT 'This association product represents the Source Data Verification (SDV) Review event between a subject_visit and a monitoring_visit. It captures the operational record of a CRA reviewing a specific subject visit during a specific monitoring visit';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`subject_consent` (
    `subject_consent_id` BIGINT COMMENT 'Primary key for the subject_consent association',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking this consent event to the specific ICF version that was signed.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — subject_consent should reference the study for traceability',
    `trial_subject_id` BIGINT COMMENT 'Foreign key linking this consent event to the trial subject who signed the ICF.',
    `witness_employee_id` BIGINT COMMENT 'Foreign key reference to the staff member (e.g., site coordinator, investigator) who witnessed the consent signing. Required for GCP compliance when the subject is illiterate or consent is obtained verbally. Belongs to the signing event.',
    `consent_date` DATE COMMENT 'The date on which the subject signed this specific ICF version. Belongs to the consent event, not to the subject master or the ICF document master. Moved from trial_subject.icf_date (which only captured the latest consent date).',
    `consent_method` STRING COMMENT 'The method by which consent was obtained for this signing event (e.g., paper, eConsent platform, verbal with witness). Belongs to the individual signing event, not to the subject or the ICF version document.',
    `consent_status` STRING COMMENT 'Current status of this specific consent signing event. A subject may have a signed status for an earlier ICF version and a pending status for a newer version requiring re-consent. Belongs to the individual consent event record.',
    `icf_date` DATE COMMENT 'Date on which the subject signed the most recent version of the Informed Consent Form (ICF). Must precede any study-related screening procedures. Used for GCP compliance verification and regulatory inspection readiness.',
    `icf_signed` BOOLEAN COMMENT 'Indicates whether the subject has signed a valid Informed Consent Form (ICF) prior to any study-related procedures. Mandatory regulatory requirement. True = ICF signed and on file; False = ICF not yet signed or consent withdrawn.',
    `icf_version` STRING COMMENT 'Version identifier of the Informed Consent Form signed by the subject. Tracks which IRB/IEC-approved consent version was used. Critical for re-consent tracking when protocol amendments require updated ICF versions.',
    `reconsent_flag` BOOLEAN COMMENT 'Indicates whether this consent event was a re-consent (true) due to a protocol amendment or new safety information, or an initial consent (false) at enrollment. Belongs to the signing event, not to the subject or the ICF version.',
    CONSTRAINT pk_subject_consent PRIMARY KEY(`subject_consent_id`)
) COMMENT 'This association product represents the Informed Consent Event between a trial_subject and a document_icf_version. It captures the complete regulatory audit trail of every consent and re-consent signing event for each subject across all ICF versions';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` (
    `drug_lab_interaction_id` BIGINT COMMENT 'Primary key for the drug_lab_interaction association',
    `assessor_employee_id` BIGINT COMMENT 'Reference to the employee (clinician, medical monitor, or data manager) who performed the drug-lab interaction assessment and documented the linkage. Belongs to the relationship as it identifies who made the specific clinical judgment connecting this lab',
    `concomitant_medication_id` BIGINT COMMENT 'Foreign key linking to the concomitant medication record whose initiation, dose change, or discontinuation was driven by the associated laboratory finding.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to the laboratory result that triggered or informed the concomitant medication decision.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — drug-lab interaction should reference the study context',
    `trial_subject_id` BIGINT COMMENT 'add column trial_subject_id (BIGINT) with FK to subject.trial_subject.trial_subject_id — drug-lab interaction should reference the trial subject',
    `assessment_date` DATE COMMENT 'The date on which the clinical assessment was performed connecting the laboratory result to the medication action. Belongs to the relationship as it records when the linkage was evaluated, independent of the lab result date or medication start/stop dates.',
    `clinical_rationale` STRING COMMENT 'Free-text or coded clinical justification provided by the assessor explaining the causal or correlative link between the laboratory finding and the medication decision. Belongs to the relationship, not to either entity alone.',
    `trigger_type` STRING COMMENT 'Classifies the type of medication action that was triggered or informed by the associated laboratory result. Belongs to the relationship because the same medication record may be initiated for one lab result and dose-reduced for another.',
    CONSTRAINT pk_drug_lab_interaction PRIMARY KEY(`drug_lab_interaction_id`)
) COMMENT 'This association product represents the clinical assessment event linking a concomitant medication record to a laboratory result that triggered or informed a medication decision.';

ALTER SCHEMA `clinical_trials_ecm`.`subject` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`subject` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard_element' = 'DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `age_at_enrollment` SET TAGS ('dbx_implements' = 'SDTM DM.AGE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `age_at_enrollment` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `age_at_enrollment` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `age_at_enrollment` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `age_at_enrollment` SET TAGS ('dbx_standard_element' = 'DM.AGE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Study Completion Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `completion_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `completion_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `country` SET TAGS ('dbx_standard_element' = 'DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `data_lock_flag` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_implements' = 'SDTM DM.BRTHDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_field_type' = 'date_of_birth');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_standard_element' = 'DM.BRTHDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard' = 'FHIR');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'FHIR ResearchSubject.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard_element' = 'ResearchSubject.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_value_regex' = 'HISPANIC OR LATINO|NOT HISPANIC OR LATINO|NOT REPORTED|UNKNOWN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_implements' = 'SDTM DM.ETHNIC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_pii_field_type' = 'health');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_standard_element' = 'DM.ETHNIC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_pii_special_category_gdpr_article_9' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `ethnicity` SET TAGS ('dbx_gdpr_article9_special_category' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_implements' = 'SDTM EX.EXSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_standard_element' = 'EX.EXSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `itt_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `itt_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `itt_flag` SET TAGS ('dbx_standard_element' = 'ADSL.ITTFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_implements' = 'SDTM EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard_element' = 'EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `pp_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `pp_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `pp_flag` SET TAGS ('dbx_standard_element' = 'ADSL.PPROTFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_implements' = 'SDTM DM.RACE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_standard_element' = 'DM.RACE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_pii_field_type' = 'health');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_pii_special_category_gdpr_article_9' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `race` SET TAGS ('dbx_gdpr_article9_special_category' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_implements' = 'SDTM DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard_element' = 'DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `safety_population_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `safety_population_flag` SET TAGS ('dbx_standard_element' = 'ADSL.SAFFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_date` SET TAGS ('dbx_standard_element' = 'DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_implements' = 'CDASH SCRNID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `screening_number` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `serious_adverse_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `serious_adverse_event_flag` SET TAGS ('dbx_implements' = 'ICH E2B(R3) C.1.1');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `serious_adverse_event_flag` SET TAGS ('dbx_standard' = 'ICH');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `serious_adverse_event_flag` SET TAGS ('dbx_standard_element' = 'E2B(R3) C.1.1');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_value_regex' = 'M|F|U|UNDIFFERENTIATED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_implements' = 'SDTM DM.SEX');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_standard_element' = 'DM.SEX');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_pii_field_type' = 'health');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `sex` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_business_glossary_term' = 'Source System Subject Key');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `source_subject_key` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_value_regex' = 'Medidata Rave|Oracle Clinical One|Oracle Siebel CTMS');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `subject_source_system` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_implements' = 'SDTM DM.USUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard_element' = 'ResearchSubject.identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`trial_subject` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Coordinator (CRC) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Study Completion Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `completion_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `completion_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `eligibility_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_implements' = 'SDTM EX.EXSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `first_dose_date` SET TAGS ('dbx_standard_element' = 'EX.EXSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Signed Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_signed_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_signed_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_signed_date` SET TAGS ('dbx_standard_element' = 'DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_version` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_version` SET TAGS ('dbx_implements' = 'USDM StudyProtocolDocumentVersion.version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_version` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `icf_version` SET TAGS ('dbx_standard_element' = 'StudyProtocolDocumentVersion.version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `itt_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `itt_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `itt_flag` SET TAGS ('dbx_standard_element' = 'ADSL.ITTFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_implements' = 'SDTM EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard_element' = 'EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `last_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `pp_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `pp_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `pp_flag` SET TAGS ('dbx_standard_element' = 'ADSL.PPROTFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `randomization_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `randomization_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `randomization_date` SET TAGS ('dbx_standard_element' = 'DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `randomization_eligible` SET TAGS ('dbx_business_glossary_term' = 'Randomization Eligibility Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `safety_population_flag` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `safety_population_flag` SET TAGS ('dbx_standard_element' = 'ADSL.SAFFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_date` SET TAGS ('dbx_standard_element' = 'DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_implements' = 'CDASH SCRNID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `screening_number` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_value_regex' = 'screened|enrolled|randomized|withdrawn|completed|screen_failed');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard' = 'FHIR');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_implements' = 'FHIR ResearchSubject.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_standard_element' = 'ResearchSubject.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `enrollment_type` SET TAGS ('dbx_value_regex' = 'new|re_enrolled|rollover|replacement');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_value_regex' = 'emergency|end_of_study|dsmb_request|regulatory_request');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `visit_compliance_pct` SET TAGS ('dbx_business_glossary_term' = 'Visit Compliance Percentage');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`enrollment` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_ecm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_prior_assignment_randomization_assignment_id` FOREIGN KEY (`prior_assignment_randomization_assignment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`randomization_assignment`(`randomization_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_randomization_performed_by_employee_id` FOREIGN KEY (`randomization_performed_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_stratification_cell_id` FOREIGN KEY (`stratification_cell_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`stratification_cell`(`stratification_cell_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Transaction ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `prior_assignment_randomization_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Randomization Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_performed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Performed By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_performed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_performed_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `stratification_cell_id` SET TAGS ('dbx_business_glossary_term' = 'Stratification Cell Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `stratification_cell_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Randomization Assignment Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|cancelled|replaced|unblinded|pending');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|open_label|unblinded');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `cancellation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date and Time');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `cancellation_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_element' = 'DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `epoch_name` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `epoch_name` SET TAGS ('dbx_implements' = 'USDM StudyEpoch.name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `epoch_name` SET TAGS ('dbx_standard_element' = 'StudyEpoch.name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) / Randomization and Trial Supply Management (RTSM) System Name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_value_regex' = 'Medidata Rave RTSM|Oracle Clinical One IRT|Other');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `kit_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Kit Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_date` SET TAGS ('dbx_implements' = 'SDTM DM.RFSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'block|minimization|adaptive|simple|stratified_block');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_implements' = 'SDTM DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard_element' = 'DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `randomization_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Randomization Date and Time');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `re_randomization_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-Randomization Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `sdtm_randfl` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Randomized Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `sdtm_randfl` SET TAGS ('dbx_value_regex' = 'Y|N');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `sdtm_randfl` SET TAGS ('dbx_implements' = 'SDTM DM.RANDFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `sdtm_randfl` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `sdtm_randfl` SET TAGS ('dbx_standard_element' = 'DM.RANDFL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `unblinding_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Date and Time');

ALTER TABLE `clinical_trials_ecm`.`subject`.`randomization_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_agreement_billing_milestone_id` FOREIGN KEY (`agreement_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone`(`agreement_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_primary_trial_subject_id` FOREIGN KEY (`primary_trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ADD CONSTRAINT `fk_subject_subject_visit_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_single_source_of_truth' = 'subject_visit');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` SET TAGS ('dbx_distinct_from' = 'monitoring_visit');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `agreement_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `primary_trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `primary_trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `actual_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `data_entry_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|locked|frozen');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `days_from_planned` SET TAGS ('dbx_business_glossary_term' = 'Days From Planned Visit Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Visit Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `informed_consent_verified` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `is_scheduled` SET TAGS ('dbx_business_glossary_term' = 'Is Scheduled Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_business_glossary_term' = 'Is Unblinded Visit Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `missed_reason` SET TAGS ('dbx_business_glossary_term' = 'Missed Visit Reason');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `missed_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Missed Visit Reason Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Visit Notes');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `notes` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `notes` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `planned_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `query_count` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Count');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_number` SET TAGS ('dbx_implements' = 'SDTM SV.VISITNUM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_number` SET TAGS ('dbx_standard_element' = 'SV.VISITNUM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_value_regex' = 'completed|missed|partial|rescheduled|cancelled');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_implements' = 'SDTM SV.SVSTATUS');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_standard_element' = 'SV.SVSTATUS');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_implements' = 'USDM Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_codelist' = 'VISITTYPE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_standard_element' = 'Encounter.type');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `week` SET TAGS ('dbx_business_glossary_term' = 'Visit Week');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `window_close_date` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Close Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `window_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `window_compliance_status` SET TAGS ('dbx_value_regex' = 'within_window|early|late|missed|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_visit` ALTER COLUMN `window_open_date` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Open Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_amendment_id` FOREIGN KEY (`amendment_id`) REFERENCES `clinical_trials_ecm`.`program`.`amendment`(`amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_compliance_deviation_classification_id` FOREIGN KEY (`compliance_deviation_classification_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`deviation_classification`(`deviation_classification_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_detected_by_employee_id` FOREIGN KEY (`detected_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_site_file_document_id` FOREIGN KEY (`site_file_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`site_file_document`(`site_file_document_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ADD CONSTRAINT `fk_subject_subject_deviation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Program Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `compliance_deviation_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Deviation Classification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `detected_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Detected By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `detected_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `detected_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `site_file_document_id` SET TAGS ('dbx_business_glossary_term' = 'Deviation Site File Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Deviation Closed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Deviation Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|important');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_implements' = 'SDTM DV.DVDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_standard_element' = 'DV.DVDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Description');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_implements' = 'SDTM DV.DVTERM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_standard_element' = 'DV.DVTERM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_number` SET TAGS ('dbx_value_regex' = '^DEV-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_value_regex' = 'open|under_review|resolved|closed|escalated');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Identified Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `irb_iec_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reportability Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Occurrence Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `pi_aware_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Awareness Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `pi_aware_flag` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Awareness Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `regulatory_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportability Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Reported Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Deviation Root Cause');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_business_glossary_term' = 'Deviation Root Cause Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'process|training|system|communication|resource|oversight');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM DV.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sponsor_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notification Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `sponsor_notified_flag` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notification Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_continuation_decision` SET TAGS ('dbx_business_glossary_term' = 'Subject Study Continuation Decision');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_continuation_decision` SET TAGS ('dbx_value_regex' = 'continue|withdrawn|on_hold|pending_review');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_rights_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Rights Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_rights_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `type_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type Description');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_deviation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_randomization_assignment_id` FOREIGN KEY (`randomization_assignment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`randomization_assignment`(`randomization_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_recorded_by_employee_id` FOREIGN KEY (`recorded_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_ecm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard_element' = 'DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `codelist_id` SET TAGS ('dbx_tag_set' = 'governing_standard=CDISC CT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `estimand_id` SET TAGS ('dbx_business_glossary_term' = 'Estimand Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `randomization_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `recorded_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Recorded By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `recorded_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `recorded_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_renamed_from' = 'code_system_version_id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `ae_related_discontinuation` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Related Discontinuation Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `analysis_population_itt` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `analysis_population_pp` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `analysis_population_safety` SET TAGS ('dbx_business_glossary_term' = 'Safety Analysis Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `disposition_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `disposition_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `disposition_date` SET TAGS ('dbx_standard_element' = 'DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `death_cause` SET TAGS ('dbx_business_glossary_term' = 'Cause of Death');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `ds_seq` SET TAGS ('dbx_business_glossary_term' = 'Disposition Sequence Number (DS SEQ)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Study Contact Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_implements' = 'SDTM EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_dose_date` SET TAGS ('dbx_standard_element' = 'EX.EXENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `last_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Preferred Term (PT)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_implements' = 'MedDRA PT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_standard_element' = 'PT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_business_glossary_term' = 'MedDRA System Organ Class (SOC)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_implements' = 'MedDRA SOC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard_element' = 'SOC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1,2}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `milestone_category` SET TAGS ('dbx_business_glossary_term' = 'Disposition Milestone Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `milestone_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Disposition Milestone Subcategory');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `safety_followup_end_date` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up End Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `safety_followup_required` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up Required Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdtm_ds_record_reference` SET TAGS ('dbx_business_glossary_term' = 'SDTM DS Domain Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdtm_ds_record_reference` SET TAGS ('dbx_implements' = 'SDTM DS.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdtm_ds_record_reference` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdtm_ds_record_reference` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT_REQUIRED|PENDING|VERIFIED|QUERIED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `disposition_status` SET TAGS ('dbx_business_glossary_term' = 'Disposition Record Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `disposition_status` SET TAGS ('dbx_value_regex' = 'active|superseded|cancelled|pending_review');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `subject_number` SET TAGS ('dbx_tag_set' = 'PII');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `term` SET TAGS ('dbx_business_glossary_term' = 'Disposition Term');

ALTER TABLE `clinical_trials_ecm`.`subject`.`disposition` ALTER COLUMN `verbatim_reason` SET TAGS ('dbx_business_glossary_term' = 'Verbatim Discontinuation Reason');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_ecm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_subject_deviation_id` FOREIGN KEY (`subject_deviation_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_deviation`(`subject_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criterion Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessor ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `subject_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `validation_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Assessment Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessment_result` SET TAGS ('dbx_value_regex' = 'MET|NOT MET|NOT ASSESSED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessment_result` SET TAGS ('dbx_implements' = 'SDTM IE.IEORRES');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessment_result` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessment_result` SET TAGS ('dbx_standard_element' = 'IE.IEORRES');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `assessor_role` SET TAGS ('dbx_value_regex' = 'PI|SUB-INVESTIGATOR|CRC|STUDY_NURSE|DESIGNEE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Assessment Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'MEDIDATA_RAVE|ORACLE_CLINICAL_ONE|MANUAL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `edc_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Record Lock Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'UNLOCKED|LOCKED|FROZEN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `not_met_reason` SET TAGS ('dbx_business_glossary_term' = 'Criterion Not Met Reason');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `overall_eligibility_status` SET TAGS ('dbx_value_regex' = 'ELIGIBLE|INELIGIBLE|PENDING|WAIVER_REQUESTED|WAIVER_APPROVED|WAIVER_DENIED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Query Open Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `re_screening_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-Screening Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM IE.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_sequence_number` SET TAGS ('dbx_implements' = 'SDTM IE.IESEQ');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_sequence_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdtm_sequence_number` SET TAGS ('dbx_standard_element' = 'IE.IESEQ');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT_REQUIRED|PENDING|VERIFIED|PARTIAL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `waiver_requested` SET TAGS ('dbx_business_glossary_term' = 'Waiver Requested Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`eligibility_assessment` ALTER COLUMN `waiver_status` SET TAGS ('dbx_value_regex' = 'PENDING|APPROVED|DENIED|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_primary_subject_employee_id` FOREIGN KEY (`primary_subject_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ADD CONSTRAINT `fk_subject_subject_status_history_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `primary_subject_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Triggered By User ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `primary_subject_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `primary_subject_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Transition Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Status Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `is_terminal_status` SET TAGS ('dbx_business_glossary_term' = 'Terminal Status Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `itt_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Subject Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `pp_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `prior_status` SET TAGS ('dbx_business_glossary_term' = 'Prior Subject Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `screen_failure_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `transition_date` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `transition_reason` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `transition_sequence` SET TAGS ('dbx_business_glossary_term' = 'Transition Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `triggered_by_system` SET TAGS ('dbx_value_regex' = 'Oracle Clinical One|Medidata Rave|manual|IRT|RTSM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_status_history` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_implements' = 'SDTM DS.DSDECOD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_primary_subject_primary_organization_contact_id` FOREIGN KEY (`primary_subject_primary_organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ADD CONSTRAINT `fk_subject_subject_contact_type_codelist_term_id` FOREIGN KEY (`type_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_ownership' = 'self_owned');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_cross_domain_duplicate_resolved' = 'distinct_contact');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_owner_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_ssot' = 'subject_contact');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_ssot_owner' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_disambiguated' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_duplicate_of' = 'sponsor.sponsor_contact');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` SET TAGS ('dbx_duplicate_resolved' = 'subject_contact/sponsor_contact');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `subject_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_subject_primary_organization_contact_id` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_subject_primary_organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Home Address Line 1');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_implements' = 'FHIR Patient.address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_standard' = 'FHIR');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line1` SET TAGS ('dbx_standard_element' = 'Patient.address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Home Address Line 2');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Address Verification Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_date` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_date` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_date` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_flag` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_flag` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_flag` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `address_verified_flag` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `city` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `city` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `consent_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Consent Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Contact Privacy Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `consent_withdrawn_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Consent Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Record Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|withdrawn|pending_verification|deceased');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_element' = 'DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Record Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Email Contact Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_consent_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_consent_flag` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_consent_flag` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `email_consent_flag` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Emergency Contact Full Name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Emergency Contact Phone Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_relationship` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_relationship` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `emergency_contact_relationship` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Successful Contact Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Last Successful Contact Method');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_method` SET TAGS ('dbx_value_regex' = 'phone|email|sms|mail|in_person');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `last_contact_method` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Notes');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `notes` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `notes` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'phone|email|sms|mail|no_contact');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_contact_time` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_contact_time` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Preferred Communication Language');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone_type` SET TAGS ('dbx_value_regex' = 'mobile|home|work|other');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone_type` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone_type` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone_type` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `primary_phone_type` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `record_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Record Type');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `record_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|emergency|caregiver|legal_representative');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `safety_contact_override_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `safety_contact_override_flag` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_business_glossary_term' = 'Secondary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone_type` SET TAGS ('dbx_value_regex' = 'mobile|home|work|other');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone_type` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone_type` SET TAGS ('dbx_pii_field_type' = 'contact_details');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone_type` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `secondary_phone_type` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `sms_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'SMS Contact Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `sms_consent_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `source_system_contact_key` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `source_system_contact_key` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `state_province` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_contact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_agreement_investigator_grant_id` FOREIGN KEY (`agreement_investigator_grant_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`investigator_grant`(`investigator_grant_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_patient_stipend_id` FOREIGN KEY (`patient_stipend_id`) REFERENCES `clinical_trials_ecm`.`finance`.`patient_stipend`(`patient_stipend_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_site_agreement_id` FOREIGN KEY (`site_agreement_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_agreement`(`site_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ADD CONSTRAINT `fk_subject_stipend_payment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `agreement_investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Investigator Grant Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `patient_stipend_id` SET TAGS ('dbx_business_glossary_term' = 'Patient Stipend Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `patient_stipend_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `site_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Site Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Receipt Document ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Payment Amount');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `approved_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Cleared Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `clincard_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Greenphire ClinCard Transaction ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `ctms_payment_key` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Payment Key');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `irb_approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) Approved Payment Amount');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `irb_payment_schedule_version` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) Payment Schedule Version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `over_irb_threshold_flag` SET TAGS ('dbx_business_glossary_term' = 'Over Institutional Review Board (IRB) Threshold Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|ach|gift_card|prepaid_debit_card|clincard|wire_transfer');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_processor` SET TAGS ('dbx_value_regex' = 'greenphire_clincard|sponsor_direct|site_petty_cash|accounts_payable|other');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|issued|cleared|voided');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'stipend|travel_reimbursement|meal_allowance|lodging_reimbursement|parking_reimbursement|other_reimbursement');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `subject_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `subject_country_code` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `subject_country_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `subject_country_code` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Void Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `void_reason` SET TAGS ('dbx_business_glossary_term' = 'Payment Void Reason');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `ytd_payment_total` SET TAGS ('dbx_business_glossary_term' = 'Year-to-Date (YTD) Payment Total');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `ytd_payment_total` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`stipend_payment` ALTER COLUMN `ytd_payment_total` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_decision_id` FOREIGN KEY (`decision_id`) REFERENCES `clinical_trials_ecm`.`program`.`decision`(`decision_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_primary_population_employee_id` FOREIGN KEY (`primary_population_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_primary_superseded_by_population_assignment_id` FOREIGN KEY (`primary_superseded_by_population_assignment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`population_assignment`(`population_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_randomization_assignment_id` FOREIGN KEY (`randomization_assignment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`randomization_assignment`(`randomization_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ADD CONSTRAINT `fk_subject_population_assignment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` SET TAGS ('dbx_subdomain' = 'participant_management');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Event ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `decision_id` SET TAGS ('dbx_business_glossary_term' = 'Program Decision Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `primary_population_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Reviewer ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `primary_population_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `primary_population_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `primary_superseded_by_population_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Population Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_flag_value` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Flag Value');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_flag_value` SET TAGS ('dbx_implements' = 'ADaM ADSL.population flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_flag_value` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_flag_value` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_population_flag_variable` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Population Flag Variable Name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_population_flag_variable` SET TAGS ('dbx_implements' = 'ADaM ADSL population flag variable');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_population_flag_variable` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `adam_population_flag_variable` SET TAGS ('dbx_standard_element' = 'ADaM.PARAM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `amendment_driven_flag` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Driven Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `analysis_cutoff_date` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Cutoff Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Approval Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'included|excluded|pending|superseded');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `assignment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Population Assignment Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `consort_flow_category` SET TAGS ('dbx_business_glossary_term' = 'CONSORT Flow Diagram Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `consort_flow_category` SET TAGS ('dbx_value_regex' = 'randomized|allocated|lost_to_followup|discontinued|analyzed|excluded');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Population Exclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `exclusion_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Population Exclusion Reason Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `exclusion_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Population Exclusion Reason Description');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Population Inclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `population_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `population_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Name');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `population_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_implements' = 'SDTM DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_standard_element' = 'DM.RANDID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `reviewer_role` SET TAGS ('dbx_business_glossary_term' = 'Statistical Reviewer Role');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `reviewer_role` SET TAGS ('dbx_value_regex' = 'biostatistician|lead_statistician|statistical_programmer|data_manager|sponsor_reviewer');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM DM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_implements' = 'SDTM DM.USUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard_element' = 'DM.USUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`population_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_corrected_demographic_id` FOREIGN KEY (`corrected_demographic_id`) REFERENCES `clinical_trials_ecm`.`subject`.`demographic`(`demographic_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_sex_codelist_term_id` FOREIGN KEY (`sex_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_race_codelist_term_id` FOREIGN KEY (`race_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_age_unit_codelist_term_id` FOREIGN KEY (`age_unit_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_ethnicity_codelist_term_id` FOREIGN KEY (`ethnicity_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_over_fk_limit' = 'refactored');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_refactor_candidate' = 'excess_outbound_fk');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_outbound_fk_count' = '17');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_max_outbound_fk' = '25');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` SET TAGS ('dbx_ct_fk_dedup_reduces_count' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `demographic_id` SET TAGS ('dbx_business_glossary_term' = 'Demographic Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `arm_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `arm_id` SET TAGS ('dbx_implements' = 'SDTM DM.ARMCD');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `corrected_demographic_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sex_codelist_term_id` SET TAGS ('dbx_codelist' = 'SEX');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sex_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM DM.SEX');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_codelist_term_id` SET TAGS ('dbx_codelist' = 'RACE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM DM.RACE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_codelist_term_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_codelist_term_id` SET TAGS ('dbx_special_category_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_unit_codelist_term_id` SET TAGS ('dbx_codelist' = 'AGEU');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_unit_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM DM.AGEU');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `ethnicity_codelist_term_id` SET TAGS ('dbx_codelist' = 'ETHNIC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `ethnicity_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM DM.ETHNIC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `ethnicity_codelist_term_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `ethnicity_codelist_term_id` SET TAGS ('dbx_special_category_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_at_screening` SET TAGS ('dbx_business_glossary_term' = 'Age at Screening (Years)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_at_screening` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_at_screening` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `age_at_screening` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_business_glossary_term' = 'Year of Birth');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_pii_dob' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_pii_field_type' = 'date_of_birth');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `birth_year` SET TAGS ('dbx_pii_quasi' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `bmi` SET TAGS ('dbx_business_glossary_term' = 'Body Mass Index (BMI)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `bmi` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `bmi` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `bmi` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Demographic Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_business_glossary_term' = 'Country of Enrollment');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_implements' = 'SDTM DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_pii_field_type' = 'address');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `country` SET TAGS ('dbx_standard_element' = 'DM.COUNTRY');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `data_entry_status` SET TAGS ('dbx_value_regex' = 'NOT STARTED|IN PROGRESS|COMPLETE|LOCKED|VERIFIED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'MEDIDATA_RAVE|ORACLE_CLINICAL_ONE|PAPER_CRF|EXTERNAL_TRANSFER');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_implements' = 'SDTM DM.BRTHDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_field_type' = 'date_of_birth');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_standard_element' = 'DM.BRTHDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_direct' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `dm_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Demographic Sequence Number (DMSEQ)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Subject Key');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_standard_element' = 'DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `edc_subject_key` SET TAGS ('dbx_pii_direct' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `epoch` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `first_exposure_date` SET TAGS ('dbx_business_glossary_term' = 'First Exposure Date (RFSTDTC)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `gender_identity` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `gender_identity` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `gender_identity` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `gender_identity` SET TAGS ('dbx_special_category_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `height_cm` SET TAGS ('dbx_business_glossary_term' = 'Height (Centimeters)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `height_cm` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `height_cm` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `height_cm` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `informed_consent_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `informed_consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `last_exposure_date` SET TAGS ('dbx_business_glossary_term' = 'Last Exposure Date (RFENDTC)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Record Lock Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'UNLOCKED|LOCKED|FROZEN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_other_description` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_other_description` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_other_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_other_description` SET TAGS ('dbx_pii_special_category_gdpr_article_9' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `race_other_description` SET TAGS ('dbx_special_category_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `reference_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reference Start Date (RFSTDTC)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM DM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT REQUIRED|PENDING|VERIFIED|PARTIAL');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_direct' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_implements' = 'SDTM DM.USUBJID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_standard_element' = 'ResearchSubject.identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `unique_subject_identifier` SET TAGS ('dbx_pii_direct' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight (Kilograms)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `weight_kg` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `weight_kg` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`demographic` ALTER COLUMN `weight_kg` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_coded_by_employee_id` FOREIGN KEY (`coded_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_coding_assignment_id` FOREIGN KEY (`coding_assignment_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`coding_assignment`(`coding_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_meddra_pt_id` FOREIGN KEY (`meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_medical_dictionary_code_system_version_id` FOREIGN KEY (`medical_dictionary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_parent_medical_history_id` FOREIGN KEY (`parent_medical_history_id`) REFERENCES `clinical_trials_ecm`.`subject`.`medical_history`(`medical_history_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_primary_medical_dictionary_code_system_version_id` FOREIGN KEY (`primary_medical_dictionary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_tertiary_medical_code_system_version_id` FOREIGN KEY (`tertiary_medical_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_tertiary_quaternary_medical_meddra_code_system_version_id` FOREIGN KEY (`tertiary_quaternary_medical_meddra_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_meddra_version_id` FOREIGN KEY (`meddra_version_id`) REFERENCES `clinical_trials_ecm`.`safety`.`meddra_version`(`meddra_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `medical_history_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `medical_history_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coded_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Coded By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coded_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coded_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coding_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Coding Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_dictionary_fk' = 'preserved');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk_label' = 'code_system_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `medical_dictionary_code_system_version_id` SET TAGS ('dbx_fk_label' = 'medical_dictionary_code_system_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `parent_medical_history_id` SET TAGS ('dbx_business_glossary_term' = 'Related Medical History Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `parent_medical_history_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `parent_medical_history_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `parent_medical_history_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `primary_medical_dictionary_code_system_version_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `primary_medical_dictionary_code_system_version_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `primary_medical_dictionary_code_system_version_id` SET TAGS ('dbx_fk_label' = 'primary_medical_dictionary_code_system_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_medical_code_system_version_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_medical_code_system_version_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_medical_code_system_version_id` SET TAGS ('dbx_fk_label' = 'tertiary_medical_code_system_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_quaternary_medical_meddra_code_system_version_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_quaternary_medical_meddra_code_system_version_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `tertiary_quaternary_medical_meddra_code_system_version_id` SET TAGS ('dbx_fk_label' = 'tertiary_quaternary_medical_meddra_code_system_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_fk_role' = 'meddra_term');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_version_id` SET TAGS ('dbx_fk_role' = 'meddra_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `ae_related_flag` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Related Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Medical History Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coding_date` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coding_status` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `coding_status` SET TAGS ('dbx_value_regex' = 'UNCODED|CODED|AUTOCODED|REVIEWED|APPROVED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Medical History Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `comments` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `comments` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_category` SET TAGS ('dbx_business_glossary_term' = 'Medical History Condition Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_status` SET TAGS ('dbx_business_glossary_term' = 'Medical History Condition Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|RESOLVED|CHRONIC|INTERMITTENT|UNKNOWN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Medical History Condition Subcategory');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_verbatim` SET TAGS ('dbx_business_glossary_term' = 'Medical Condition Verbatim Text');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_verbatim` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `condition_verbatim` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `edc_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `eligibility_relevant_flag` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Relevance Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Record Lock Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'UNLOCKED|LOCKED|FROZEN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Lowest Level Term');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_implements' = 'MedDRA LLT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_llt` SET TAGS ('dbx_standard_element' = 'LLT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_implements' = 'MedDRA PT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_pt` SET TAGS ('dbx_standard_element' = 'PT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_implements' = 'MedDRA SOC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard_element' = 'SOC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `mh_seq` SET TAGS ('dbx_business_glossary_term' = 'Medical History (MH) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `ongoing_flag` SET TAGS ('dbx_business_glossary_term' = 'Condition Ongoing Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `ongoing_flag` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `ongoing_flag` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `onset_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Onset Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `onset_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `onset_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `pre_existing_flag` SET TAGS ('dbx_business_glossary_term' = 'Pre-Existing Condition Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Query Open Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `resolution_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `resolution_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM MH.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT REQUIRED|PENDING|VERIFIED|QUERIED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Condition Severity');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'MILD|MODERATE|SEVERE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`medical_history` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_coding_assignment_id` FOREIGN KEY (`coding_assignment_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`coding_assignment`(`coding_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_concomitant_dictionary_code_system_version_id` FOREIGN KEY (`concomitant_dictionary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_continuation_of_concomitant_medication_id` FOREIGN KEY (`continuation_of_concomitant_medication_id`) REFERENCES `clinical_trials_ecm`.`subject`.`concomitant_medication`(`concomitant_medication_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_primary_concomitant_dictionary_code_system_version_id` FOREIGN KEY (`primary_concomitant_dictionary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_whodrug_drug_record_id` FOREIGN KEY (`whodrug_drug_record_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_drug_record`(`whodrug_drug_record_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_whodrug_record_id` FOREIGN KEY (`whodrug_record_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_record`(`whodrug_record_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_dose_form_codelist_term_id` FOREIGN KEY (`dose_form_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_route_codelist_term_id` FOREIGN KEY (`route_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_dose_unit_codelist_term_id` FOREIGN KEY (`dose_unit_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `coding_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Coding Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `continuation_of_concomitant_medication_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_dictionary_fk' = 'preserved');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_record_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'Medication Dose Form');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_codelist' = 'FRM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_form_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM CM.CMDOSFRM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'Medication Route of Administration');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_codelist' = 'ROUTE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `route_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM CM.CMROUTE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_unit_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'Medication Dose Unit');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_unit_codelist_term_id` SET TAGS ('dbx_codelist' = 'UNIT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_unit_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM CM.CMDOSU');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `ae_related_flag` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Related Medication Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `concomitant_medication_category` SET TAGS ('dbx_business_glossary_term' = 'Medication Category');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `cm_seq` SET TAGS ('dbx_business_glossary_term' = 'Concomitant Medication (CM) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Medication Record Comments');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `concomitant_flag` SET TAGS ('dbx_business_glossary_term' = 'Concomitant Medication Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose` SET TAGS ('dbx_business_glossary_term' = 'Medication Dose');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose` SET TAGS ('dbx_implements' = 'SDTM CM.CMDOSE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose` SET TAGS ('dbx_standard_element' = 'CM.CMDOSE');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `dose_frequency` SET TAGS ('dbx_business_glossary_term' = 'Medication Dose Frequency');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Medication End Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `end_date` SET TAGS ('dbx_implements' = 'SDTM CM.CMENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `end_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `end_date` SET TAGS ('dbx_standard_element' = 'CM.CMENDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Medication Indication');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `indication` SET TAGS ('dbx_implements' = 'SDTM CM.CMINDC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `indication` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `indication` SET TAGS ('dbx_standard_element' = 'CM.CMINDC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `modified_drug_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `ongoing_flag` SET TAGS ('dbx_business_glossary_term' = 'Medication Ongoing Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Query Open Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `record_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|DELETED|AMENDED|LOCKED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM CM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard_element' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT_REQUIRED|PENDING|VERIFIED|FAILED');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Medication Start Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `start_date` SET TAGS ('dbx_implements' = 'SDTM CM.CMSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `start_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `start_date` SET TAGS ('dbx_standard_element' = 'CM.CMSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `study_day_end` SET TAGS ('dbx_business_glossary_term' = 'Medication End Study Day');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `study_day_start` SET TAGS ('dbx_business_glossary_term' = 'Medication Start Study Day');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `subcategory` SET TAGS ('dbx_business_glossary_term' = 'Medication Subcategory');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_drug_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_implements' = 'SDTM CM.CMTRT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_standard_element' = 'CM.CMTRT');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_atc_code` SET TAGS ('dbx_business_glossary_term' = 'WHO Anatomical Therapeutic Chemical (ATC) Classification Code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_atc_code` SET TAGS ('dbx_value_regex' = '^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_atc_code` SET TAGS ('dbx_implements' = 'WHODrug ATC code');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_atc_code` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_atc_code` SET TAGS ('dbx_standard_element' = 'ATC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_drug_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_version` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_version` SET TAGS ('dbx_implements' = 'WHODrug dictionary version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_version` SET TAGS ('dbx_standard' = 'WHODrug');

ALTER TABLE `clinical_trials_ecm`.`subject`.`concomitant_medication` ALTER COLUMN `whodrug_version` SET TAGS ('dbx_standard_element' = 'DictionaryVersion');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ADD CONSTRAINT `fk_subject_visit_billing_reconciliation_invoice_line_id` FOREIGN KEY (`invoice_line_id`) REFERENCES `clinical_trials_ecm`.`finance`.`invoice_line`(`invoice_line_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ADD CONSTRAINT `fk_subject_visit_billing_reconciliation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ADD CONSTRAINT `fk_subject_visit_billing_reconciliation_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` SET TAGS ('dbx_association_edges' = 'subject.subject_visit,finance.invoice_line');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ALTER COLUMN `visit_billing_reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Billing Reconciliation - Visit Billing Reconciliation Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ALTER COLUMN `invoice_line_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Billing Reconciliation - Invoice Line Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Billing Reconciliation - Subject Visit Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`visit_billing_reconciliation` ALTER COLUMN `visit_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Visit Completion Date for Billing');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` SET TAGS ('dbx_association_edges' = 'subject.subject_visit,monitoring.monitoring_visit');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_review_id` SET TAGS ('dbx_business_glossary_term' = 'Sdv Review - Sdv Review Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Sdv Review - Subject Visit Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_coverage_percent` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|partial|complete');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_status` SET TAGS ('dbx_implements' = 'ICH E6(R2) source data verification');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_status` SET TAGS ('dbx_standard' = 'ICH');

ALTER TABLE `clinical_trials_ecm`.`subject`.`sdv_review` ALTER COLUMN `sdv_status` SET TAGS ('dbx_standard_element' = 'ICH E6(R2) 5.18.4');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_witness_employee_id` FOREIGN KEY (`witness_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` SET TAGS ('dbx_association_edges' = 'subject.trial_subject,document.document_icf_version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent - Subject Consent Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `subject_consent_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `subject_consent_id` SET TAGS ('dbx_pii_field_type' = 'subject_identifier');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent - Document Icf Version Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent - Trial Subject Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `witness_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `witness_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_implements' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_phi_adjacent' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_standard_element' = 'DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_implements' = 'FHIR Consent.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_standard' = 'FHIR');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_standard_element' = 'Consent.status');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Date');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_signed` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Signed Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_version` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_version` SET TAGS ('dbx_implements' = 'USDM StudyProtocolDocumentVersion.version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_version` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `icf_version` SET TAGS ('dbx_standard_element' = 'StudyProtocolDocumentVersion.version');

ALTER TABLE `clinical_trials_ecm`.`subject`.`subject_consent` ALTER COLUMN `reconsent_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Flag');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ADD CONSTRAINT `fk_subject_drug_lab_interaction_assessor_employee_id` FOREIGN KEY (`assessor_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ADD CONSTRAINT `fk_subject_drug_lab_interaction_concomitant_medication_id` FOREIGN KEY (`concomitant_medication_id`) REFERENCES `clinical_trials_ecm`.`subject`.`concomitant_medication`(`concomitant_medication_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ADD CONSTRAINT `fk_subject_drug_lab_interaction_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ADD CONSTRAINT `fk_subject_drug_lab_interaction_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ADD CONSTRAINT `fk_subject_drug_lab_interaction_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` SET TAGS ('dbx_domain' = 'subject');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` SET TAGS ('dbx_subdomain' = 'clinical_data');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` SET TAGS ('dbx_association_edges' = 'subject.concomitant_medication,laboratory.lab_result');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `drug_lab_interaction_id` SET TAGS ('dbx_business_glossary_term' = 'Drug Lab Interaction - Drug Lab Interaction Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `assessor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessor');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `assessor_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `assessor_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `concomitant_medication_id` SET TAGS ('dbx_business_glossary_term' = 'Drug Lab Interaction - Concomitant Medication Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Drug Lab Interaction - Lab Result Id');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`subject`.`drug_lab_interaction` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Medication Trigger Type');
