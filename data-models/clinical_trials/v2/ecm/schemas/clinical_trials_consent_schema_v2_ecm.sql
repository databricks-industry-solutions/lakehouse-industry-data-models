-- Schema for Domain: consent | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:58

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`consent` COMMENT 'Manages the informed consent lifecycle for trial subjects. Owns ICF versions and amendments, eConsent workflows (Clinpal), subject consent status, re-consent triggers, capacity assessments, withdrawal tracking, consent audit trails, and IRB/IEC-approved';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` (
    `consent_icf_version_id` BIGINT COMMENT 'Unique surrogate identifier for each Informed Consent Form (ICF) version record in the consent master catalog. Primary key for this data product.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: ICF versions are authored, approved, and owned by the sponsor organization as IND holder.',
    `parent_icf_version_consent_icf_version_id` BIGINT COMMENT 'Self-referencing identifier pointing to the parent ICF version from which this version was derived. Used to track amendment lineage (e.g., v1.0 → v2.0) and translation relationships (e.g., English master → Spanish translation).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Regulatory requirement (FDA 21 CFR Part 50, ICH E6) mandates ICF versions reflect the current approved protocol version.',
    `reviewer_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICH E6(R2) GCP requires ICF versions to have a documented internal reviewer. Tracking reviewer_employee_id enables TMF inspection readiness reports and audit trails confirming qualified',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ICF version was developed and approved. Links the ICF version to its parent study context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: ICF versions are created or revised in direct response to protocol amendments (ICH E6 GCP requirement).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which this ICF version is approved and applicable. A site-specific ICF version may differ from the global master version due to local IRB/IEC requirements.',
    `template_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: ICF versions are authored from sponsor-approved document templates. Regulatory inspectors verify that the correct, current-version template was used to create each ICF.',
    `affected_population_description` STRING COMMENT 'Description of the subject population affected by the ICF amendment, specifying which enrolled subjects must be re-consented (e.g., All currently enrolled subjects, Subjects in Cohort A only, Subjects who have not yet completed Visit 4).',
    `amendment_nature_of_change` STRING COMMENT 'Free-text description of the substantive changes introduced in this ICF version relative to the prior version, including new risks, procedures, or study design changes that required IRB/IEC re-review.',
    `amendment_number` STRING COMMENT 'The protocol amendment number that necessitated this ICF version update (e.g., Amendment 1, Amendment 2). Null for the initial ICF version or for translation-only versions not triggered by a protocol amendment.',
    `approval_status` STRING COMMENT 'Current regulatory lifecycle status of this ICF version. draft = under internal review; pending_irb_iec = submitted to IRB/IEC awaiting approval; approved = IRB/IEC approved and active for use; superseded = replaced by a newer approved version. Valid values are `draft|pending_irb_iec|approved|superseded|withdrawn|expired`',
    `back_translation_completion_date` DATE COMMENT 'The date on which the back-translation quality review was completed and approved for this translated ICF version. Null for master language versions or translations where back-translation is not yet complete.',
    `back_translation_status` STRING COMMENT 'Status of the back-translation quality check for this translated ICF version. not_required = master language version; pending = back-translation in progress; completed = back-translation verified and approved; failed = back-translation identified. Valid values are `not_required|pending|completed|failed`',
    `biobanking_consent_included` BOOLEAN COMMENT 'Indicates whether this ICF version includes optional or mandatory consent language for the collection, storage, and future use of biological samples (biobanking). Relevant for studies collecting samples for future exploratory research.',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a formal cognitive or decisional capacity assessment is required before a subject can be consented using this ICF version (e.g., for vulnerable populations, pediatric studies, or studies involving subjects with cognitive impairment).',
    `clinpal_consent_form_code` STRING COMMENT 'The unique identifier assigned by Clinpal (eConsent platform) to the deployed electronic consent form corresponding to this ICF version. Enables reconciliation between the eTMF document record and the active eConsent workflow.',
    `consent_type` STRING COMMENT 'Classification of the consent form by its purpose in the subject enrollment lifecycle. initial = first consent at enrollment; re-consent = required after protocol amendment or new safety information; assent = minor subject assent form; lar =. Valid values are `initial|re-consent|assent|lar|short_form|addendum`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this ICF version record was first created in the system (Veeva Vault or Clinpal). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `econsent_deployment_date` DATE COMMENT 'The date on which this ICF version was deployed and activated in the Clinpal eConsent platform for subject use. Null if eConsent is not enabled for this version.',
    `econsent_enabled` BOOLEAN COMMENT 'Indicates whether this ICF version is deployed as an electronic consent (eConsent) form via Clinpal. True = eConsent workflow is active in Clinpal for this version; False = paper-based consent only.',
    `effective_date` DATE COMMENT 'The date from which this ICF version is authorized for use in obtaining subject consent. May equal or follow the IRB/IEC approval date. Subjects consented on or after this date must use this version.',
    `expiry_date` DATE COMMENT 'The date after which this ICF version is no longer valid for obtaining new subject consent, typically aligned with the IRB/IEC continuing review approval expiry. Null if no expiry has been set or the version is superseded before expiry.',
    `gdpr_data_processing_included` BOOLEAN COMMENT 'Indicates whether this ICF version includes the required GDPR data processing disclosure and consent language for EU/EEA subjects, covering data controller identity, processing purposes, data subject rights, and cross-border transfer provisions.',
    `genetic_testing_consent_included` BOOLEAN COMMENT 'Indicates whether this ICF version includes specific consent language for genetic or genomic testing, as required by applicable regulations and IRB/IEC requirements for studies involving genetic data collection.',
    `hipaa_authorization_included` BOOLEAN COMMENT 'Indicates whether this ICF version incorporates the HIPAA Authorization for use and disclosure of Protected Health Information (PHI), as required for U.S. clinical trial subjects under 45 CFR 164.508.',
    `icf_title` STRING COMMENT 'The official title of the Informed Consent Form as it appears on the document header (e.g., Informed Consent Form for Study XYZ-001 — Version 2.0 — Spanish). Used for document identification in the eTMF and regulatory binder.',
    `icf_version_number` STRING COMMENT 'The official version number of the ICF as assigned by the sponsor or CRO (e.g., 1.0, 2.1, 3.0a). Used to uniquely identify and reference the ICF version in regulatory submissions, IRB/IEC correspondence, and subject consent records.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?[a-zA-Z]?$`',
    `internal_review_status` STRING COMMENT 'Tracks the internal document lifecycle status of the ICF version within the sponsor/CRO quality management workflow, distinct from the external IRB/IEC regulatory approval status.. Valid values are `in_authoring|internal_review|sponsor_approved|submitted_to_irb_iec|approved|archived`',
    `is_master_language` BOOLEAN COMMENT 'Indicates whether this ICF version is the master (source) language version from which translations are derived. True = this is the authoritative master language document; False = this is a translation derived from a master language version.',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code (optionally with ISO 3166-1 country subtag) indicating the language of this ICF version (e.g., en, es, fr, de, ja, zh-CN). Supports multi-language consent management for trials.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `lar_consent_applicable` BOOLEAN COMMENT 'Indicates whether this ICF version includes or supports consent by a Legally Authorized Representative (LAR) on behalf of a subject who lacks decision-making capacity. Relevant for emergency research, pediatric studies, or cognitively impaired populations.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent modification to this ICF version record. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `readability_grade_level` STRING COMMENT 'The assessed reading grade level of this ICF version (e.g., 6th grade, 8th grade) based on a standardized readability assessment (e.g., Flesch-Kincaid, Gunning Fog).',
    `reconsent_deadline_date` DATE COMMENT 'The date by which all affected enrolled subjects must be re-consented using this ICF version, as specified by the IRB/IEC approval conditions or sponsor protocol. Null if re-consent is not required.',
    `reconsent_required` BOOLEAN COMMENT 'Indicates whether currently enrolled subjects are required to be re-consented using this new ICF version. True = re-consent is mandatory for affected enrolled subjects; False = re-consent is not required (e.g., administrative or translation-only update).',
    `regulatory_basis_for_change` STRING COMMENT 'The regulatory or scientific rationale driving the ICF amendment (e.g., new safety signal from DSMB review, protocol design change, updated risk-benefit information, new IND safety report, SUSAR notification).',
    `sponsor_approval_date` DATE COMMENT 'The date on which the sponsor (pharmaceutical or biotech company) formally approved this ICF version prior to IRB/IEC submission. Part of the internal quality control and document approval workflow.',
    `superseded_date` DATE COMMENT 'The date on which this ICF version was superseded by a newer approved version. After this date, new subjects must be consented using the superseding version. Null if the version is still current.',
    `tmf_reference_number` STRING COMMENT 'The TMF artifact reference number assigned to this ICF document per the TMF Reference Model (e.g., 04.01.01 for Informed Consent Forms). Enables systematic TMF completeness tracking and regulatory inspection readiness.',
    `translator_name` STRING COMMENT 'Full name of the qualified translator responsible for producing this translated ICF version. Applicable only for non-master-language versions. Required for translation quality audit trail.',
    `vault_document_code` STRING COMMENT 'The unique document identifier assigned by Veeva Vault (eTMF) to the ICF document record. Enables direct traceability back to the source system document for audit and regulatory inspection purposes.',
    `vault_lifecycle_state` STRING COMMENT 'The document lifecycle state as managed within Veeva Vault eTMF, reflecting the document management workflow state. Distinct from the regulatory approval_status — this represents the eTMF system-level document state used for TMF completeness and. Valid values are `draft|in_review|approved|obsolete|archived`',
    `witness_signature_required` BOOLEAN COMMENT 'Indicates whether a witness signature is required on this ICF version in addition to the subject and investigator signatures (e.g., for illiterate subjects, subjects using a short form, or per local regulatory requirements).',
    CONSTRAINT pk_consent_icf_version PRIMARY KEY(`consent_icf_version_id`)
) COMMENT 'Master record for each version of an Informed Consent Form (ICF) used in a clinical trial, including language translations and amendment-derived versions. Tracks ICF document version number, effective date, IRB/IEC approval reference, language (ISO';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` (
    `consent_subject_consent_id` BIGINT COMMENT 'Unique surrogate identifier for the subject consent record. Primary key for the subject_consent data product in the Silver Layer lakehouse.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version that was presented to and signed by the subject. Ensures traceability to the exact document version consented to.',
    `consenting_staff_study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: ICH E6(R2) requires that consenting staff have a valid, active study assignment at the time of consent.',
    `econsent_session_id` BIGINT COMMENT 'Unique session identifier from the Clinpal eConsent platform for this consent event. Enables direct traceability back to the eConsent audit trail in Clinpal for 21 CFR Part 11 electronic signature verification.',
    `employee_id` BIGINT COMMENT 'Reference to the qualified study staff member (Principal Investigator or delegated Clinical Research Coordinator) who conducted the informed consent discussion and obtained the subjects signature.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Each subject consent must be obtained under a currently ethics-approved ICF version.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: GCP requirement: consent obtained from a subject must reference the currently approved IRB/IEC approval in effect at consent date.',
    `lar_representative_id` BIGINT COMMENT 'Foreign key linking to consent.lar_representative. Business justification: subject_consent has denormalized lar_name and lar_relationship STRING fields. lar_representative is the master record for LARs associated with a subject.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this consent was obtained. Links the consent record to the parent study protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the consent was obtained. Used for site-level consent compliance monitoring.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The executed signed consent form is an essential TMF document (ICH E6 R2 Section 8). Site file completeness checks and TMF inspection readiness require tracing each subject_consent',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) who provided or withdrew consent. Core party reference for this consent transaction.',
    `capacity_assessment_outcome` STRING COMMENT 'Result of the subject decision-making capacity assessment. capable = subject has full capacity to consent; incapable = subject lacks capacity, LAR consent required; borderline = capacity is uncertain, additional review required; not_applicable =. Valid values are `capable|incapable|borderline|not_applicable`',
    `capacity_assessment_performed` BOOLEAN COMMENT 'Indicates whether a formal subject decision-making capacity assessment was performed prior to obtaining consent. Required for vulnerable populations and subjects with potential cognitive impairment.',
    `comprehension_assessment_performed` BOOLEAN COMMENT 'Indicates whether a formal comprehension assessment (e.g., teach-back method, quiz) was administered to verify the subject understood the consent information. Increasingly required by IRBs and FDA for complex protocols.',
    `comprehension_assessment_score` DECIMAL(5,2) COMMENT 'Numeric score from the comprehension assessment administered to the subject (e.g., percentage correct on a quiz). Populated when comprehension_assessment_performed is True. Used for quality metrics and IRB reporting.',
    `consent_date` DATE COMMENT 'Calendar date on which the subject (or LAR) signed or electronically acknowledged the Informed Consent Form. This is the principal real-world event date for the consent transaction and is used for protocol eligibility window calculations.',
    `consent_method` STRING COMMENT 'Method by which informed consent was obtained. paper = traditional wet-ink signature on paper ICF; econsent = electronic consent via Clinpal eConsent platform; remote_econsent = remote electronic consent (e.g., telemedicine); telephone = verbal. Valid values are `paper|econsent|remote_econsent|telephone|legally_authorized_rep`',
    `consent_number` STRING COMMENT 'Externally-known business identifier for this consent event, typically generated by the EDC or eConsent system (Clinpal). Used for cross-system traceability and audit referencing (e.g., CNST-2024-00123).',
    `consent_status` STRING COMMENT 'Current lifecycle status of the subjects consent. Drives subject eligibility and study participation decisions. consented = valid active consent; withdrawn = subject revoked consent; re_consent_pending = amendment requires new signature; expired. Valid values are `consented|withdrawn|re_consent_pending|expired|not_obtained`',
    `consent_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the consent signature or electronic acknowledgement was captured. Required for 21 CFR Part 11 electronic records compliance and ALCOA+ contemporaneous documentation.',
    `consent_type` STRING COMMENT 'Classification of the consent event. initial = first consent for study participation; re_consent = repeat consent after protocol amendment; amendment = consent to a specific protocol change; optional_procedure = consent for an optional sub-study. Valid values are `initial|re_consent|amendment|optional_procedure|genetic|long_term_followup`',
    `consenting_staff_role` STRING COMMENT 'Role of the staff member who obtained consent. PI = Principal Investigator; sub_investigator = Sub-Investigator; CRC = Clinical Research Coordinator; delegate = other delegated staff member listed on the delegation log.. Valid values are `PI|sub_investigator|CRC|delegate`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this consent record was first created in the Silver Layer lakehouse. Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `data_use_after_withdrawal` BOOLEAN COMMENT 'Indicates whether the subject explicitly permitted use of previously collected data after withdrawal of consent. Critical for GDPR right-to-erasure compliance and statistical analysis plan (the source system) decisions on data inclusion.',
    `econsent_completion_pct` DECIMAL(5,2) COMMENT 'Percentage of the eConsent workflow modules completed by the subject in Clinpal (0.00–100.00). Used to track partial completions and identify subjects who did not fully review all consent materials before signing.',
    `gdpr_lawful_basis` STRING COMMENT 'Legal basis under GDPR Article 9 for processing the subjects special category (health) data. explicit_consent = subject provided explicit consent per Article 9(2)(a); vital_interests = Article 9(2)(c); public_interest = Article 9(2)(i) for. Valid values are `explicit_consent|vital_interests|public_interest|legitimate_interests|not_applicable`',
    `hipaa_authorization_obtained` BOOLEAN COMMENT 'Indicates whether a HIPAA Authorization for use and disclosure of Protected Health Information (PHI) was obtained from the subject, as required for U.S. clinical trials. May be combined with or separate from the ICF.',
    `icf_approval_date` DATE COMMENT 'Date on which the IRB or IEC approved the specific ICF version used for this consent event. Confirms that the consent was obtained using a currently approved document, a key GCP compliance check.',
    `icf_version_number` STRING COMMENT 'Human-readable version identifier of the ICF document presented to the subject at the time of consent (e.g., v2.1, Amendment 3). Denormalized from the ICF version record for direct audit trail access without joins.',
    `lar_involved` BOOLEAN COMMENT 'Indicates whether a Legally Authorized Representative (LAR) provided consent on behalf of the subject (e.g., for subjects who lack decision-making capacity, minors, or cognitively impaired individuals).',
    `reconsent_due_date` DATE COMMENT 'Deadline by which the subject must complete re-consent to remain eligible for continued study participation. Populated when reconsent_required is True. Drives site monitoring alerts.',
    `reconsent_required` BOOLEAN COMMENT 'Indicates whether the subject is required to provide re-consent due to a protocol amendment, new safety information, or ICF version update. Triggers re-consent workflow in Clinpal.',
    `reconsent_trigger` STRING COMMENT 'Reason that triggered the re-consent requirement. protocol_amendment = protocol change affecting subject participation; safety_update = new safety information impacting risk-benefit; icf_version_update = new IRB-approved ICF version. Valid values are `protocol_amendment|safety_update|icf_version_update|irb_requirement|regulatory_request`',
    `sample_use_after_withdrawal` BOOLEAN COMMENT 'Indicates whether the subject permitted continued use of previously collected biological samples (e.g., blood, tissue) after withdrawal of consent. Distinct from data_use_after_withdrawal as it governs physical biospecimen retention.',
    `subject_questions_documented` BOOLEAN COMMENT 'Indicates whether the subjects questions and the investigators responses were documented during the consent discussion, as required by GCP. Supports audit readiness and IRB inspection compliance.',
    `translation_language` STRING COMMENT 'ISO 639-1/639-2 language code of the ICF translation provided to the subject (e.g., es for Spanish, fr for French, zh-CN for Simplified Chinese). Null if the ICF was provided in the sites primary language.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this consent record in the Silver Layer lakehouse. Required for change tracking, audit trail completeness, and ALCOA+ compliance.',
    `withdrawal_date` DATE COMMENT 'Date on which the subject formally withdrew consent to participate in the study. Populated only when consent_status is withdrawn. Triggers subject discontinuation workflow.',
    `withdrawal_reason` STRING COMMENT 'Primary reason for consent withdrawal as documented at the site. Used for subject disposition analysis and protocol feasibility reporting. Aligns with CDISC SDTM DS Domain disposition reason coding.. Valid values are `subject_decision|adverse_event|lost_to_followup|physician_decision|protocol_deviation|other`',
    `witness_name` STRING COMMENT 'Full name of the impartial witness present during the informed consent process, where required. Captured when witness_required is True. Classified as confidential as it identifies a third-party individual in a clinical context.',
    `witness_required` BOOLEAN COMMENT 'Indicates whether a witness was required for this consent event (e.g., for illiterate subjects, subjects with limited reading ability, or verbal consent scenarios per ICH E6(R2) Section 4.8.9).',
    `witness_signature_date` DATE COMMENT 'Date on which the impartial witness signed the ICF, confirming they witnessed the consent process. Must match or follow the subjects consent_date.',
    CONSTRAINT pk_consent_subject_consent PRIMARY KEY(`consent_subject_consent_id`)
) COMMENT 'Core transactional record capturing the consent event for a trial subject at a specific site and study. Records the date and time of consent, ICF version consented to, consent method (paper, eConsent via Clinpal), consenting staff (PI, CRC), witness';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`econsent_session` (
    `econsent_session_id` BIGINT COMMENT 'Unique surrogate identifier for each eConsent workflow session initiated in Clinpal for a trial subject. Primary key for this data product.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version presented to the subject during this session. Ensures the correct, current consent document was used.',
    `employee_id` BIGINT COMMENT 'Reference to the site staff member (Principal Investigator or delegated Clinical Research Coordinator) who witnessed or facilitated the eConsent session. Required for GCP compliance and delegation log traceability.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site at which the subject is enrolled and where this consent session is associated. Supports site-level compliance monitoring.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this eConsent session was conducted. Enables study-level consent compliance reporting.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) for whom this eConsent session was initiated. Links to the subject master record.',
    `capacity_assessment_outcome` STRING COMMENT 'Result of the capacity assessment performed for the subject. capable indicates the subject has decision-making capacity; not-capable indicates a legally authorized representative is required; not-assessed indicates no assessment was conducted. Valid values are `capable|not-capable|not-assessed|deferred`',
    `capacity_assessment_performed` BOOLEAN COMMENT 'Indicates whether a formal capacity assessment was performed for the subject prior to or during this consent session (True = performed; False = not performed). Required for vulnerable populations and subjects with potential cognitive impairment.',
    `clinpal_session_ref` STRING COMMENT 'The native session identifier assigned by the Clinpal eConsent platform for this workflow session. Used for cross-system traceability and reconciliation with the source system of record.',
    `communication_platform` STRING COMMENT 'The teleconference or video communication platform used for remote consent sessions (e.g., Zoom, Microsoft Teams, WebEx). Applicable only when session_modality is remote-video or remote-phone.',
    `comprehension_attempt_number` BIGINT COMMENT 'The sequential attempt number for the comprehension check within this session. Subjects may be permitted multiple attempts after remediation. Tracks how many times the subject attempted the comprehension assessment.',
    `comprehension_check_version` STRING COMMENT 'Version identifier of the comprehension check question set administered to the subject during this session. Ensures traceability to the specific validated question set used, as question sets may be updated with ICF amendments.',
    `comprehension_overall_passed` BOOLEAN COMMENT 'Indicates whether the subject passed the overall comprehension check for this session (True = passed; False = failed). Determined by comparing the score against the minimum passing threshold defined in the ICF version.',
    `comprehension_questions_passed` BIGINT COMMENT 'Number of comprehension check questions answered correctly by the subject in this session. Used to compute the overall comprehension score and determine pass/fail outcome.',
    `comprehension_questions_total` BIGINT COMMENT 'Total number of comprehension check questions administered to the subject in this session. Used to calculate the comprehension score and assess understanding of the consent content.',
    `consent_granted` BOOLEAN COMMENT 'Indicates whether the subject (or legally authorized representative) granted informed consent at the conclusion of this session (True = consent granted; False = consent not granted or declined). The definitive consent outcome flag for this session.',
    `consenter_role` STRING COMMENT 'The role of the individual who provided consent during this session. subject indicates the participant themselves; legally-authorized-representative indicates a proxy consenter; parent or guardian applies to pediatric studies.. Valid values are `subject|legally-authorized-representative|parent|guardian`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when this eConsent session record was first created in the data platform. Supports ALCOA+ (Attributable, Contemporaneous) audit trail requirements.',
    `device_os` STRING COMMENT 'Operating system and version of the device used during the eConsent session (e.g., iOS 16.4, Android 13, Windows 11). Supports technical audit trail and system validation requirements under 21 CFR Part 11.',
    `device_type` STRING COMMENT 'Category of device used by the subject to access and complete the eConsent session. Supports technical audit trail requirements and device compatibility analysis.. Valid values are `tablet|smartphone|desktop|laptop|kiosk`',
    `esignature_captured` BOOLEAN COMMENT 'Indicates whether an electronic signature was successfully captured from the subject (or legally authorized representative) during this session (True = captured; False = not captured).',
    `esignature_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when the subjects electronic signature was captured in Clinpal. Critical for ALCOA+ (Contemporaneous) compliance and 21 CFR Part 11 audit trail. Null if no signature was captured.',
    `interpreter_used` BOOLEAN COMMENT 'Indicates whether a language interpreter was used during the consent session (True = interpreter used; False = no interpreter). Relevant for non-English-speaking subjects and required for GCP documentation of consent comprehension.',
    `ip_address` STRING COMMENT 'IP address of the device used by the subject during the eConsent session. Required for 21 CFR Part 11 electronic records audit trail and GDPR accountability. May be considered PII in certain jurisdictions.',
    `irb_approval_ref` STRING COMMENT 'The IRB or IEC approval number or reference associated with the ICF version used in this session. Confirms the consent document presented was approved by the appropriate ethics body at the time of the session.',
    `reconsent_trigger` BOOLEAN COMMENT 'Indicates whether this session was initiated as a re-consent event (True) rather than an initial consent (False). Re-consent is triggered by protocol amendments, new safety information, or ICF version updates requiring subjects to re-affirm consent.',
    `remediation_provided` BOOLEAN COMMENT 'Indicates whether remediation (additional educational content or re-review of ICF sections) was provided to the subject following a failed comprehension check attempt (True = remediation was provided; False = not provided).',
    `remediation_steps_count` BIGINT COMMENT 'Number of remediation steps (re-review sections or educational modules) completed by the subject following a failed comprehension check. Null if no remediation was provided.',
    `review_steps_completed` BIGINT COMMENT 'The number of ICF review steps (content sections) the subject completed during this session. Compared against review_steps_total to assess session progress and identify drop-off points.',
    `review_steps_total` BIGINT COMMENT 'The total number of review steps (content sections or pages) defined in the ICF version presented during this session. Used to calculate completion percentage and identify where subjects abandoned the session.',
    `session_end_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when the eConsent session concluded, regardless of outcome (completed, abandoned, timed-out, or declined). Null if the session is still in-progress.',
    `session_language` STRING COMMENT 'IETF BCP 47 language tag representing the language in which the eConsent session was conducted (e.g., en, es, fr-CA). Ensures the subject received consent information in their preferred language, as required by GCP and GDPR.. Valid values are `^[a-z]{2,3}(-[A-Z]{2,3})?$`',
    `session_modality` STRING COMMENT 'The mode by which the consent session was conducted. in-person indicates the subject and site staff were physically co-located; remote-video indicates a teleconference/video call; remote-phone indicates a telephone-only session; hybrid indicates a. Valid values are `in-person|remote-video|remote-phone|hybrid`',
    `session_recording_ref` STRING COMMENT 'Reference identifier or URL to the recording of the remote consent session (e.g., stored in Veeva Vault or a secure media repository). Applicable for remote sessions where recording is required per FDA remote consent guidance. Null for in-person sessions.',
    `session_start_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when the eConsent session was initiated by the subject or site staff in Clinpal. Serves as the principal business event timestamp for this transaction.',
    `session_status` STRING COMMENT 'Current lifecycle state of the eConsent workflow session. in-progress indicates an active session; completed indicates the subject finished all steps; abandoned indicates the subject exited without completing; timed-out indicates the session. Valid values are `in-progress|completed|abandoned|timed-out|declined`',
    `subject_auth_method` STRING COMMENT 'The method used to authenticate the subjects identity at the start of the eConsent session. Supports 21 CFR Part 11 identity verification requirements for electronic signatures.. Valid values are `password|otp-sms|otp-email|biometric|pin|site-staff-verified`',
    `subject_location_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the country where the subject was physically located at the time of the eConsent session. Relevant for decentralized trials and cross-border GDPR/HIPAA compliance determination.. Valid values are `^[A-Z]{3}$`',
    `technical_issue_description` STRING COMMENT 'Free-text description of any technical issue encountered during the session (e.g., Video connection dropped at step 3, Signature pad unresponsive). Null if no technical issue was encountered. Supports deviation investigation and CAPA processes.',
    `technical_issue_encountered` BOOLEAN COMMENT 'Indicates whether any technical issue (connectivity failure, platform error, device malfunction, signature capture failure) was encountered during the session (True = issue encountered; False = no issues).',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when this eConsent session record was last modified in the data platform. Supports change tracking and audit trail completeness under 21 CFR Part 11 and ALCOA+.',
    `witness_esignature_timestamp` TIMESTAMP COMMENT 'Date and time (with timezone offset) when the site staff witness (PI or CRC) applied their electronic countersignature to the consent record. Required for GCP-compliant consent documentation. Null if witness signature was not captured in this session.',
    CONSTRAINT pk_econsent_session PRIMARY KEY(`econsent_session_id`)
) COMMENT 'Tracks each eConsent workflow session initiated in Clinpal for a subject, including both on-site and remote/decentralized consent sessions. Captures session start and end timestamps, device type, IP address, session modality (in-person, remote via';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` (
    `reconsent_trigger_id` BIGINT COMMENT 'Unique surrogate identifier for each re-consent trigger record in the system. Primary key for the reconsent_trigger data product.',
    `compliance_protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Protocol deviations are a primary trigger for reconsent requirements. reconsent_trigger has protocol_deviation_raised flag but no FK to the specific deviation record.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific Informed Consent Form (ICF) version that triggered the re-consent requirement. Identifies the new IRB/IEC-approved ICF version subjects must sign.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: A reconsent trigger is raised against a specific existing consent record that needs to be superseded.',
    `dsmb_recommendation_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_recommendation. Business justification: DSMB recommendations with `informed_consent_update_required=true` directly mandate reconsent. Sponsors must document which DSMB recommendation drove each reconsent campaign.',
    `econsent_session_id` BIGINT COMMENT 'The session identifier from the Clinpal eConsent platform for the re-consent workflow instance. Enables traceability back to the source eConsent system for audit and SDV purposes. Nullable when paper-based consent is used.',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: A protocol or ICF amendment is one of the primary triggers for re-consent. reconsent_trigger has trigger_type which can be protocol_amendment and has',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Operational compliance: reconsent triggers are often mandated by a new IRB/IEC approval of an amended ICF.',
    `primary_reconsent_employee_id` BIGINT COMMENT 'Reference to the site staff member (typically the Principal Investigator or Clinical Research Coordinator) responsible for executing the re-consent process with the subject. Drives task assignment and accountability tracking.',
    `primary_reconsent_safety_communication_id` BIGINT COMMENT 'Foreign key linking to safety.safety_communication. Business justification: Reconsent is formally initiated by safety communications (SUSAR notifications, urgent safety measures).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this re-consent trigger was raised. Links the trigger to the parent study protocol context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Reference to the protocol amendment that necessitated this re-consent trigger, when the trigger type is a protocol amendment. Nullable for non-amendment triggers.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigative site at which the re-consent trigger applies. Drives site-level workflow assignment and monitoring.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: When a reconsent trigger is raised (e.g., safety letter, protocol amendment), the subjects active randomization and treatment arm assignment must be reviewed to determine',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject who must be re-consented. Nullable when the trigger applies to all subjects at a site or study level rather than a specific individual.',
    `affected_icf_version_number` STRING COMMENT 'The version number of the new IRB/IEC-approved ICF that subjects must sign as part of the re-consent process. Stored as a human-readable version string (e.g., v3.0, Amendment 2) for audit trail and site communication purposes.',
    `affected_subject_count` BIGINT COMMENT 'The total number of subjects at the site (or study-wide, per subject_scope) who are required to be re-consented as a result of this trigger. Used for site workload planning and sponsor oversight reporting.',
    `capacity_assessment_date` DATE COMMENT 'The date on which the subjects mental capacity to provide informed consent was formally assessed. Nullable when capacity_assessment_required is False. Required for vulnerable population compliance documentation.',
    `capacity_assessment_outcome` STRING COMMENT 'The result of the mental capacity assessment for the subject. Determines whether the subject can provide direct consent or whether a legally authorized representative (LAR) must consent on their behalf.. Valid values are `has_capacity|lacks_capacity|assessment_pending|not_required`',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a mental capacity assessment is required before re-consent can be obtained from this subject, applicable for vulnerable populations or subjects with cognitive impairment. Triggers capacity assessment workflow when True.',
    `consent_method` STRING COMMENT 'The method by which re-consent was or will be obtained from the subject. Drives regulatory compliance checks and audit trail requirements. Values: electronic (eConsent via Clinpal), paper (wet-ink signature), verbal_with_witness (emergency/capacity. Valid values are `electronic|paper|verbal_with_witness|remote_electronic|legally_authorized_representative`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp at which this re-consent trigger record was first created in the system. Supports audit trail, data lineage, and ALCOA+ compliance. Distinct from trigger_date which represents the real-world event date.',
    `escalation_date` DATE COMMENT 'The date on which this re-consent trigger was escalated to the sponsor, CRA, or regulatory authority. Nullable when escalation_required is False. Used for compliance tracking and CAPA initiation.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether this re-consent trigger has been escalated to the sponsor, CRA, or regulatory authority due to non-compliance, overdue status, or subject refusal. Triggers escalation workflow and sponsor notification.',
    `irb_iec_approval_date` DATE COMMENT 'The date on which the IRB or IEC approved the updated ICF version that subjects must sign. Establishes the earliest permissible date for initiating re-consent at the site.',
    `issuing_regulatory_authority` STRING COMMENT 'The regulatory authority that issued the directive requiring re-consent, when trigger_type is regulatory_authority_requirement. Values: FDA (U.S. Food and Drug Administration), EMA (European Medicines Agency), PMDA (Pharmaceuticals and Medical Devices',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, site communications, or contextual information related to this re-consent trigger that is not captured in structured fields. Supports audit trail completeness per ALCOA+ principles.',
    `previous_icf_version_number` STRING COMMENT 'The version number of the ICF that the subject had previously signed before this re-consent trigger was raised. Enables version-to-version change tracking and audit trail completeness per ALCOA+ principles.',
    `protocol_deviation_raised` BOOLEAN COMMENT 'Indicates whether a protocol deviation has been raised in the compliance system as a result of failure to re-consent within the required timeframe. When True, links to the compliance.protocol_deviation product for CAPA tracking.',
    `reconsent_completed_date` DATE COMMENT 'The actual date on which the subject was successfully re-consented and signed the updated ICF. Nullable until re-consent is completed. Used to calculate cycle time and compliance metrics.',
    `reconsent_deadline` DATE COMMENT 'The date by which re-consent must be obtained from the subject, as mandated by the IRB/IEC approval, regulatory authority, or sponsor protocol. Used to calculate overdue status and drive site escalation workflows.',
    `reconsented_subject_count` BIGINT COMMENT 'The number of subjects who have been successfully re-consented to date against this trigger. Compared against affected_subject_count to track completion progress and identify outstanding re-consents.',
    `regulatory_authority_directive_ref` STRING COMMENT 'The reference number or identifier of the regulatory authority directive (e.g., FDA clinical hold letter, EMA variation request, PMDA query) that mandated this re-consent. Nullable for non-regulatory triggers.',
    `reminder_count` BIGINT COMMENT 'The total number of reminder notifications sent to the site for this re-consent trigger. Used to assess site responsiveness and determine when escalation is warranted per sponsor oversight SOPs.',
    `reminder_sent_date` DATE COMMENT 'The date on which the most recent reminder notification was sent to the site regarding the outstanding re-consent requirement. Used to track communication cadence and demonstrate sponsor oversight diligence.',
    `resolution_status` STRING COMMENT 'Current workflow state of the re-consent trigger. Drives operational dashboards and site follow-up. Values: pending (trigger raised, re-consent not yet initiated), in_progress (re-consent process underway), completed (subject successfully re-consented). Valid values are `pending|in_progress|completed|waived|overdue|cancelled`',
    `subject_scope` STRING COMMENT 'Defines the population of subjects affected by this re-consent trigger. Values: individual_subject (single subject identified by subject_id), all_active_subjects (all currently enrolled subjects at the site), site_cohort (a defined subset at the site). Valid values are `individual_subject|all_active_subjects|site_cohort|study_wide`',
    `subject_withdrawal_flag` BOOLEAN COMMENT 'Indicates whether the subject withdrew from the study as a result of the re-consent process (e.g., declined to sign the updated ICF). When True, triggers subject discontinuation workflow and safety follow-up per protocol.',
    `trigger_date` DATE COMMENT 'The date on which the re-consent triggering event occurred (e.g., date of protocol amendment approval, date of safety letter issuance, date of regulatory authority directive).',
    `trigger_description` STRING COMMENT 'Narrative description of the specific event or change that necessitated re-consent. Provides context beyond the trigger type classification, including the nature of the protocol change, safety finding, or regulatory directive.',
    `trigger_reference_number` STRING COMMENT 'Externally-known business identifier for the re-consent trigger event, used in site communications, audit trails, and regulatory correspondence. Follows the format RCT-{StudyCode}-{Sequence}.. Valid values are `^RCT-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `trigger_type` STRING COMMENT 'Classification of the event that necessitated re-consent. Drives workflow routing and regulatory reporting. Values: protocol_amendment (change to study protocol), new_safety_information (SAE/SUSAR/IB update), icf_version_update (administrative ICF. Valid values are `protocol_amendment|new_safety_information|icf_version_update|regulatory_authority_requirement|irb_iec_requirement|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp at which this re-consent trigger record was most recently modified. Required for audit trail integrity, change tracking, and ALCOA+ compliance in the Silver Layer lakehouse.',
    `waiver_approval_date` DATE COMMENT 'The date on which the IRB/IEC formally approved the waiver of re-consent for this trigger. Nullable when no waiver has been granted. Required for regulatory audit trail when resolution_status is waived.',
    `waiver_justification` STRING COMMENT 'Documented justification for waiving the re-consent requirement, as approved by the IRB/IEC. Required when resolution_status is waived. Must reference the IRB/IEC waiver approval and the regulatory basis for the waiver.',
    `withdrawal_date` DATE COMMENT 'The date on which the subject formally withdrew from the study following refusal to re-consent. Nullable when subject_withdrawal_flag is False. Used for subject disposition reporting and safety follow-up scheduling.',
    CONSTRAINT pk_reconsent_trigger PRIMARY KEY(`reconsent_trigger_id`)
) COMMENT 'Records events that necessitate re-consent of a subject, such as a protocol amendment, new safety information, ICF version update, or regulatory authority requirement.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` (
    `capacity_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the mental capacity assessment record. Primary key for the capacity_assessment data product in the consent domain.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version in effect at the time of this capacity assessment. Ensures traceability to the correct consent document.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: A capacity assessment is performed in the context of a specific consent event to determine whether the subject can provide informed consent.',
    `econsent_session_id` BIGINT COMMENT 'Unique session identifier from the Clinpal eConsent platform associated with this capacity assessment event. Enables cross-system traceability between the capacity assessment record and the eConsent audit trail.',
    `employee_id` BIGINT COMMENT 'Reference to the qualified individual (e.g., Principal Investigator, sub-investigator, or delegated clinician) who conducted the capacity assessment. Links to the workforce or site personnel record.',
    `lar_representative_id` BIGINT COMMENT 'Foreign key linking to consent.lar_representative. Business justification: capacity_assessment has lar_required (BOOLEAN), lar_name (STRING), and lar_relationship (STRING) as denormalized fields.',
    `prior_assessment_capacity_assessment_id` BIGINT COMMENT 'Reference to the immediately preceding capacity assessment record for this subject on this study, enabling longitudinal tracking of capacity status changes over the subjects participation lifecycle.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this capacity assessment is being conducted. Provides study-level context for regulatory reporting.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigative site where the capacity assessment was conducted. Used for site-level compliance monitoring and IRB/IEC reporting.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Capacity assessment supporting documentation must be filed in the TMF for vulnerable population oversight and regulatory inspection.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject whose mental capacity to provide informed consent is being assessed. Links to the subject master record.',
    `assessment_date` DATE COMMENT 'The calendar date on which the formal mental capacity assessment was conducted. This is the principal real-world event date for the assessment, distinct from the record creation timestamp. Required for GCP compliance and ALCOA+ data integrity.',
    `assessment_number` STRING COMMENT 'Externally-known, human-readable business identifier for this capacity assessment, typically generated by the CTMS or eConsent system (Clinpal). Used for cross-system referencing, audit trails, and regulatory submissions.. Valid values are `^CA-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `assessment_outcome` STRING COMMENT 'Formal determination of the subjects mental capacity to provide informed consent. Drives downstream consent workflow: Capable proceeds to standard ICF signing; Incapable triggers LAR (Legally Authorized Representative) requirement; Borderline may require. Valid values are `Capable|Incapable|Borderline|Deferred|Unable to Assess`',
    `assessment_score` DECIMAL(5,2) COMMENT 'Numeric score produced by the assessment tool (e.g., MMSE score out of 30, MacCAT-CR subscale score). Provides quantitative evidence supporting the capacity determination outcome.',
    `assessment_score_max` DECIMAL(5,2) COMMENT 'Maximum possible score for the assessment tool used, providing context for interpreting the assessment_score. Required when multiple tools with different scales are used across sites.',
    `assessment_setting` STRING COMMENT 'Mode in which the capacity assessment was conducted: In-Person at the investigative site, Remote via telehealth/eConsent platform (Clinpal), or Hybrid. Relevant for regulatory acceptability and audit trail documentation.. Valid values are `In-Person|Remote|Hybrid`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the capacity assessment record. Drives workflow routing in Clinpal and CTMS. Superseded indicates a newer assessment has replaced this one for the same subject-study combination.. Valid values are `Planned|In Progress|Completed|Cancelled|Superseded`',
    `assessment_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the capacity assessment was performed. Supports ALCOA+ contemporaneous documentation requirements and audit trail integrity per 21 CFR Part 11.',
    `assessment_tool` STRING COMMENT 'Name or code of the standardized tool, instrument, or method used to evaluate mental capacity (e.g., MacCAT-CR, MMSE, ACE-III, clinical interview, structured questionnaire). Supports methodological consistency and IRB/IEC reporting.',
    `assessment_tool_version` STRING COMMENT 'Version or edition of the assessment tool or instrument used. Ensures reproducibility and comparability of assessments across sites and time points.',
    `assessment_type` STRING COMMENT 'Classification of the assessment within the subjects consent lifecycle: Initial (first assessment at screening), Re-Assessment (triggered by condition change or borderline outcome), Periodic (scheduled interval), Post-Amendment (following protocol or ICF. Valid values are `Initial|Re-Assessment|Periodic|Post-Amendment|Withdrawal`',
    `assessor_credentials` STRING COMMENT 'Professional credentials or qualifications of the assessor (e.g., MD, PhD, RN, NP) as documented at the time of assessment. Supports regulatory verification of assessor competency.',
    `assessor_name` STRING COMMENT 'Full name of the qualified individual who conducted the capacity assessment, captured at the time of assessment for audit trail completeness. Retained as a denormalized field to preserve historical accuracy even if personnel records change.',
    `assessor_role` STRING COMMENT 'Professional role or qualification of the individual who conducted the capacity assessment. Determines the regulatory acceptability of the assessment per GCP and applicable local regulations.',
    `assessor_signature_timestamp` TIMESTAMP COMMENT 'Date and time at which the assessor applied their electronic signature to the capacity assessment record, as required by 21 CFR Part 11 for electronic records. Distinct from the assessment_timestamp (when the assessment occurred).',
    `comments` STRING COMMENT 'Free-text field for additional clinical observations, contextual notes, or qualifications related to the capacity assessment that are not captured in structured fields. Supports comprehensive documentation per ALCOA+ principles.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this capacity assessment record was first created in the system. Supports ALCOA+ contemporaneous documentation requirements and audit trail integrity per 21 CFR Part 11.',
    `interpreter_used` BOOLEAN COMMENT 'Indicates whether a language interpreter was used during the capacity assessment. Relevant for GCP compliance and assessment validity documentation.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the IRB/IEC was notified of the capacity assessment outcome. Populated when irb_iec_notification_required is True. Used for regulatory compliance tracking.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether the outcome of this capacity assessment requires notification to the IRB/IEC (e.g., enrollment of an incapable subject, use of LAR consent). Drives regulatory reporting workflow.',
    `language_of_assessment` STRING COMMENT 'ISO 639-1/639-2 language code indicating the language in which the capacity assessment was conducted (e.g., en, fr, de, zh-CN). Ensures the subject was assessed in their primary language per GCP requirements.. Valid values are `^[a-z]{2,3}(-[A-Z]{2,3})?$`',
    `lar_required` BOOLEAN COMMENT 'Indicates whether a Legally Authorized Representative (LAR) is required to provide consent on behalf of the subject due to incapacity or borderline capacity determination. Triggers LAR consent workflow in Clinpal eConsent system.',
    `outcome_basis` STRING COMMENT 'Narrative description of the clinical and factual basis for the capacity determination, including observations, test scores, and reasoning. Required for regulatory defensibility and IRB/IEC reporting. Supports ALCOA+ attributable and accurate principles.',
    `reassessment_due_date` DATE COMMENT 'Scheduled date by which a follow-up capacity re-assessment must be completed. Populated when reassessment_required is True. Used for site monitoring and compliance tracking.',
    `reassessment_required` BOOLEAN COMMENT 'Indicates whether a follow-up capacity re-assessment is required, typically triggered by a borderline outcome, change in subject condition, protocol amendment, or regulatory requirement.',
    `reassessment_trigger` STRING COMMENT 'Reason or event that triggered the requirement for a capacity re-assessment. Supports audit trail and IRB/IEC reporting on re-consent and re-assessment activities.. Valid values are `Borderline Outcome|Change in Condition|Protocol Amendment|Regulatory Requirement|Scheduled Interval|Other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this capacity assessment record was most recently modified. Supports audit trail completeness and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `vulnerability_category` STRING COMMENT 'Classification of the type of vulnerability applicable to the subject. Drives additional regulatory safeguards and IRB/IEC reporting requirements. Populated when vulnerable_population_flag is True.',
    `vulnerable_population_flag` BOOLEAN COMMENT 'Indicates whether the subject is classified as a member of a vulnerable population (e.g., cognitively impaired, prisoner, pregnant, minor, economically disadvantaged) requiring additional consent protections per GCP and applicable regulations.',
    `witness_name` STRING COMMENT 'Full name of the impartial witness present during the capacity assessment and consent process. Populated when witness_required is True. Classified as restricted PII.',
    `witness_required` BOOLEAN COMMENT 'Indicates whether an impartial witness was required to be present during the capacity assessment and consent process, as mandated for illiterate subjects or those with specific vulnerabilities per GCP.',
    CONSTRAINT pk_capacity_assessment PRIMARY KEY(`capacity_assessment_id`)
) COMMENT 'Documents the formal assessment of a subjects mental capacity to provide informed consent, as required by GCP and applicable regulations (e.g., ICH E6, 21 CFR 50).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`withdrawal` (
    `withdrawal_id` BIGINT COMMENT 'Unique surrogate identifier for the consent withdrawal event record. Primary key for the consent_withdrawal data product in the Silver Layer lakehouse.',
    `employee_id` BIGINT COMMENT 'Reference to the site staff member (Clinical Research Coordinator (CRC) or Clinical Research Associate (CRA)) who received and documented the withdrawal notification. Supports ALCOA+ attributability.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site where the subject was enrolled and where the withdrawal is being processed.',
    `lar_representative_id` BIGINT COMMENT 'Foreign key linking to consent.lar_representative. Business justification: consent_withdrawal has lar_name (STRING) and lar_relationship (STRING) as denormalized fields for cases where a LAR initiates withdrawal on behalf of the subject.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: When a subject withdraws consent, the IRT randomization record must be cancelled.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) who is withdrawing consent. Links to the subject master record.',
    `capacity_assessment_performed` BOOLEAN COMMENT 'Indicates whether a formal decision-making capacity assessment was performed for the subject prior to processing the withdrawal, particularly relevant for vulnerable populations or subjects with cognitive impairment.',
    `comments` STRING COMMENT 'Additional free-text comments or notes entered by site staff or the sponsor regarding the withdrawal event, circumstances, or follow-up actions required. Supplements the structured withdrawal reason fields.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this consent withdrawal record was first created in the system, per ALCOA+ contemporaneous documentation requirements. Distinct from the withdrawal_timestamp which captures the real-world event time.',
    `ctms_withdrawal_ref` STRING COMMENT 'Cross-reference identifier for this withdrawal event in the source system enabling reconciliation between the lakehouse Silver Layer and the operational CTMS system of record.',
    `data_retention_status` STRING COMMENT 'Current status of the subjects data retention following withdrawal. Tracks whether data has been retained, anonymized, or destroyed in accordance with post_withdrawal_data_handling instructions and applicable privacy regulations.. Valid values are `active|pending_review|anonymized|destroyed|retained`',
    `edc_subject_status_updated` BOOLEAN COMMENT 'Indicates whether the subjects status in the Electronic Data Capture (EDC) system (Medidata Rave) has been updated to reflect the withdrawal, ensuring downstream data collection is halted appropriately.',
    `initiated_by` STRING COMMENT 'Identifies the party who formally initiated the withdrawal: subject (the enrolled participant), lar (Legally Authorized Representative acting on behalf of the subject), investigator (Principal Investigator or site physician), sponsor (study. Valid values are `subject|lar|investigator|sponsor|regulatory_authority`',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Flag indicating whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) must be notified of this withdrawal event per protocol or regulatory requirements.',
    `irb_iec_notified_date` DATE COMMENT 'Date on which the IRB or IEC was formally notified of the consent withdrawal, when notification was required.',
    `itt_population_impact` STRING COMMENT 'Indicates the impact of this withdrawal on the subjects inclusion in the Intent-to-Treat (ITT) analysis population: included means the subject remains in ITT per the source system means the subject is removed from ITT; pending_review means. Valid values are `included|excluded|pending_review`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this consent withdrawal record was most recently modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `method` STRING COMMENT 'The medium through which the withdrawal was communicated and documented: electronic via Clinpal eConsent platform, paper via signed paper form, verbal with documented witness, telephone with documented confirmation.. Valid values are `electronic|paper|verbal|telephone`',
    `number` STRING COMMENT 'Externally-known, human-readable business identifier for this withdrawal event, typically generated by the eConsent system (Clinpal) or CTMS (the source system for cross-system traceability and regulatory audit trails.',
    `pi_notification_timestamp` TIMESTAMP COMMENT 'Date and time at which the Principal Investigator (PI) was formally notified of the consent withdrawal event.',
    `pi_notified` BOOLEAN COMMENT 'Indicates whether the Principal Investigator (PI) has been formally notified of the subjects withdrawal of consent, as required by GCP.',
    `post_withdrawal_data_handling` STRING COMMENT 'Specifies how previously collected subject data must be handled following withdrawal, per protocol and applicable regulations. retain_all allows retention of all data collected prior to withdrawal; retain_safety_only retains only safety-relevant data. Valid values are `retain_all|retain_safety_only|destroy_all|anonymize|per_protocol`',
    `protocol_deviation_triggered` BOOLEAN COMMENT 'Indicates whether the consent withdrawal event triggered a protocol deviation that must be reported to the sponsor, IRB/IEC, or regulatory authority.',
    `reason_category` STRING COMMENT 'Standardized categorical classification of the primary reason for withdrawal. voluntary indicates subject-initiated without specific cause; adverse_event_related indicates withdrawal driven by an Adverse Event (AE) or safety concern. Valid values are `voluntary|adverse_event_related|sponsor_decision|lost_to_follow_up|protocol_non_compliance|physician_decision`',
    `reconsent_attempted` BOOLEAN COMMENT 'Indicates whether site staff attempted to re-consent the subject before the withdrawal was finalized, for example by providing additional information or addressing concerns.',
    `reconsent_outcome` STRING COMMENT 'Outcome of the re-consent attempt: successful indicates the subject agreed to continue and withdrawal was rescinded; unsuccessful indicates the subject maintained the withdrawal decision; not_attempted indicates no re-consent was attempted.. Valid values are `successful|unsuccessful|not_attempted`',
    `safety_follow_up_end_date` DATE COMMENT 'The date through which safety follow-up activities must continue for the subject post-withdrawal, as defined by the protocol. Applicable when safety_follow_up_required is true.',
    `safety_follow_up_required` BOOLEAN COMMENT 'Indicates whether the subject requires ongoing safety follow-up activities (e.g., SAE reporting, survival follow-up) after withdrawal of consent, as mandated by the protocol or regulatory requirements.',
    `withdrawal_status` STRING COMMENT 'Current lifecycle state of the withdrawal record. pending indicates the withdrawal has been initiated but not yet formally confirmed; confirmed indicates the withdrawal is complete and binding; rescinded indicates the subject reversed the withdrawal. Valid values are `pending|confirmed|rescinded|superseded|archived`',
    `study_discontinuation_date` DATE COMMENT 'Date on which the subject was formally discontinued from the study following consent withdrawal. Used for Intent-to-Treat (ITT) and Per Protocol (PP) population analyses.',
    `subject_stated_reason` STRING COMMENT 'Free-text verbatim reason for withdrawal as stated by the subject or their Legally Authorized Representative (LAR). Captured to support ALCOA+ attributability and regulatory audit requirements. May contain sensitive personal context.',
    `timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the subject or their Legally Authorized Representative (LAR) formally communicated withdrawal of consent. This is the principal real-world event time per GCP requirements and ALCOA+ principles.',
    `tmf_filing_status` STRING COMMENT 'Status of the withdrawal documentation filing in the electronic Trial Master File (eTMF) in Veeva Vault: pending indicates documents are awaiting upload; filed indicates documents have been uploaded; verified indicates QC review of the filing is. Valid values are `pending|filed|verified`',
    `treatment_stop_date` DATE COMMENT 'Date on which the subjects investigational treatment was discontinued as a result of the consent withdrawal. May differ from the withdrawal_timestamp for treatment_withdrawal type.',
    `withdrawal_type` STRING COMMENT 'Categorizes the scope of the withdrawal: full_withdrawal means the subject withdraws from all study activities and data use; treatment_withdrawal means withdrawal from investigational treatment only while allowing continued data collection. Valid values are `full_withdrawal|treatment_withdrawal|data_use_withdrawal|future_sample_withdrawal`',
    CONSTRAINT pk_withdrawal PRIMARY KEY(`withdrawal_id`)
) COMMENT 'Records the formal withdrawal of informed consent by a subject or their LAR. Captures withdrawal date and time, withdrawal reason category (voluntary, AE-related, sponsor decision, lost to follow-up), subject-stated reason free text, withdrawal type (full';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`audit_entry` (
    `audit_entry_id` BIGINT COMMENT 'Unique surrogate identifier for each immutable consent audit trail record in the Silver Layer lakehouse. Primary key for the consent_audit_entry data product. Role: EVENT_LOG.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version that was in effect at the time of this audit event. Critical for demonstrating that the correct consent version was used.',
    `consent_subject_consent_id` BIGINT COMMENT 'Reference to the parent subject consent record that was created or modified by this audit event. Provides the link between the audit entry and the consent lifecycle record it documents.',
    `econsent_session_id` BIGINT COMMENT 'Identifier of the Clinpal eConsent session during which this audit event occurred. Links the audit entry to the specific electronic consent workflow session for end-to-end eConsent traceability.',
    `primary_audit_employee_id` BIGINT COMMENT 'System user identifier of the individual who performed the consent action that triggered this audit entry. Satisfies ALCOA+ Attributable requirement and 21 CFR Part 11 electronic signature attribution. Sourced from Clinpal or Veeva Vault user registry.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which the consent event occurred. Enables study-level audit trail aggregation and regulatory inspection queries.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the consent event took place. Required for site-level GCP monitoring and IRB/IEC jurisdiction tracking.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject whose consent record was affected by this audit event. Links to the subject master entity for subject-level consent history queries.',
    `actor_full_name` STRING COMMENT 'Full name of the user who performed the consent action, captured at the time of the event for human-readable audit trail display. Stored as confidential business data to support regulatory inspection readiness without exposing unnecessary PII.',
    `actor_role` STRING COMMENT 'Clinical role of the user who performed the consent action (e.g., Principal Investigator (PI), Clinical Research Coordinator (CRC), subject, Legally Authorized Representative (LAR)). Required for GCP accountability and regulatory inspection.',
    `affected_record_reference` BIGINT COMMENT 'Surrogate identifier of the specific consent domain record (subject_consent, icf_version, econsent_session, etc.) that was created or modified by this audit event. Used in conjunction with affected_record_type to locate the exact record.',
    `affected_record_type` STRING COMMENT 'Identifies the type of consent domain record that was created or modified by this audit event (e.g., subject_consent, icf_version, econsent_session, withdrawal). Enables filtering audit entries by consent entity type during regulatory inspections.. Valid values are `subject_consent|icf_version|econsent_session|withdrawal|capacity_assessment|re_consent`',
    `amendment_number` STRING COMMENT 'The protocol amendment number that necessitated the ICF update or re-consent event captured in this audit entry. Populated for event_type = amended or re_consented. Links consent changes to specific protocol amendments.',
    `capacity_assessment_result` STRING COMMENT 'Outcome of the subjects mental capacity assessment conducted prior to or during the consent process. Populated for events involving capacity evaluation. Determines whether direct consent or LAR consent pathway applies.. Valid values are `capable|incapable|reassessment_required`',
    `change_reason_code` STRING COMMENT 'Standardized reason code explaining why the consent record was modified (e.g., DATA_ENTRY_ERROR, PROTOCOL_AMENDMENT, SUBJECT_REQUEST, SYSTEM_CORRECTION). Supports ALCOA+ Attributable requirement and audit trail completeness for regulatory inspections.',
    `change_reason_text` STRING COMMENT 'Free-text narrative explanation provided by the actor for the consent record modification. Complements change_reason_code with additional context. Required by ALCOA+ and GCP for any post-entry modification to clinical data.',
    `changed_field_name` STRING COMMENT 'Name of the specific data field on the consent record that was modified by this audit event. Null for creation events where no prior value exists. Supports granular field-level audit trail as required by ALCOA+ and 21 CFR Part 11.',
    `consent_language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) of the ICF version presented to the subject at the time of this consent event (e.g., en, fr-FR, es-ES).. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `consent_method` STRING COMMENT 'The modality through which consent was obtained for this event (e.g., paper ICF, Clinpal eConsent, remote eConsent via video). Relevant for regulatory submissions and site monitoring to confirm GCP-compliant consent procedures.. Valid values are `paper|eConsent|remote_eConsent|telephone|video`',
    `consent_status_after` STRING COMMENT 'The overall consent status of the subject-study-site combination immediately after this audit event was applied. Together with consent_status_before, provides a complete state transition record for regulatory inspection and GCP compliance verification.. Valid values are `pending|consented|re_consent_required|withdrawn|capacity_assessed|voided`',
    `consent_status_before` STRING COMMENT 'The overall consent status of the subject-study-site combination immediately before this audit event. Provides a high-level consent lifecycle snapshot independent of field-level changes.. Valid values are `pending|consented|re_consent_required|withdrawn|capacity_assessed|voided`',
    `device_identifier` STRING COMMENT 'Unique identifier of the device (tablet, computer, mobile) used to perform the consent action. Relevant for eConsent sessions via Clinpal where device-level traceability is required for 21 CFR Part 11 compliance.',
    `digital_signature_hash` STRING COMMENT 'Cryptographic hash of the electronic signature applied to the consent record at the time of this audit event. Validates the integrity and non-repudiation of the electronic consent signature per 21 CFR Part 11 requirements.',
    `event_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) when the consent domain event occurred in the source system. This is the real-world event time, distinct from the record ingestion timestamp.',
    `event_type` STRING COMMENT 'Discriminator classifying the nature of the consent domain event captured in this audit record. Drives regulatory reporting and consent status history reconstruction.',
    `gdpr_lawful_basis` STRING COMMENT 'The GDPR Article 6/9 lawful basis under which the subjects personal data is processed in connection with this consent event. Required for EU/EEA trial sites to demonstrate lawful processing of special category health data.. Valid values are `explicit_consent|vital_interests|public_task|legitimate_interests`',
    `hipaa_authorization_flag` BOOLEAN COMMENT 'Indicates whether a HIPAA Authorization for use and disclosure of Protected Health Information (PHI) was obtained as part of this consent event. Applicable for US trial sites. Required for HIPAA compliance documentation.',
    `ip_address` STRING COMMENT 'IP address of the device from which the consent action was performed. Supports 21 CFR Part 11 electronic records compliance by providing network-level attribution for each consent event. May be considered PII under GDPR.',
    `irb_iec_approval_number` STRING COMMENT 'The IRB or IEC approval reference number associated with the ICF version in effect at the time of this audit event. Confirms that the consent was obtained under a currently approved protocol version, as required by GCP and FDA/EMA regulations.',
    `is_void` BOOLEAN COMMENT 'Indicates whether this audit entry has been voided due to a system error or data correction. Voided entries are retained for regulatory completeness but excluded from active consent status calculations. Supports ALCOA+ Enduring data integrity.',
    `lar_relationship` STRING COMMENT 'Relationship of the Legally Authorized Representative (LAR) to the subject when consent was obtained via a surrogate (e.g., parent, legal guardian, spouse). Populated when actor_role = LAR. Required for vulnerable population consent documentation.',
    `new_value` DECIMAL(18,2) COMMENT 'The value of the changed field after this audit event was applied. Stores the resulting state for the modified field. Required for before/after comparison in regulatory inspections and ALCOA+ data integrity verification.',
    `previous_value` DECIMAL(18,2) COMMENT 'The value of the changed field immediately before this audit event was applied. Null for record creation events. Stored as STRING to accommodate any field type.',
    `re_consent_trigger_reason` STRING COMMENT 'Free-text description of the reason that triggered a re-consent requirement for the subject (e.g., protocol amendment, new safety information, ICF version update). Populated only for event_type = re_consented or status_changed to re_consent_required.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this audit entry record was first ingested into the Silver Layer lakehouse. Distinct from event_timestamp (the real-world event time). Supports data lineage tracking and ETL reconciliation.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this audit entry record in the Silver Layer. Since consent audit entries are immutable by design, this field is expected to remain null after initial load; populated only for void corrections or metadata updates.',
    `signature_meaning` STRING COMMENT 'The declared meaning associated with the electronic signature captured at this audit event (e.g., I agree, Witnessed, Approved). Required by 21 CFR Part 11.50 to associate a meaning with each electronic signature in the audit trail.. Valid values are `I agree|I have reviewed|Approved|Witnessed|Countersigned`',
    `source_system_record_code` STRING COMMENT 'Native record identifier assigned by the originating source system (Clinpal, Veeva Vault, CTMS) for this audit event. Enables traceability back to the system of record for data lineage and reconciliation purposes.',
    `void_reason` STRING COMMENT 'Explanation for why this audit entry was voided. Populated only when is_void = True. Maintains a complete and transparent audit trail even for corrected records, as required by ALCOA+ and 21 CFR Part 11.',
    `withdrawal_reason` STRING COMMENT 'Documented reason provided by the subject or their Legally Authorized Representative (LAR) for withdrawing consent. Populated only for event_type = withdrawn. Required for subject safety follow-up and regulatory reporting.',
    CONSTRAINT pk_audit_entry PRIMARY KEY(`audit_entry_id`)
) COMMENT 'Immutable audit trail record for every create, update, or status change event on consent domain records (subject consent, ICF version, eConsent session, withdrawal, etc.).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`lar_representative` (
    `lar_representative_id` BIGINT COMMENT 'Unique surrogate identifier for the Legally Authorized Representative (LAR) master record in the Silver layer lakehouse. Primary key for this entity.',
    `legal_authority_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The legal authority document (power of attorney, guardianship order) authorizing the LAR must be on file in the TMF as an essential document for vulnerable subject protection.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this LAR authorization is applicable. Scopes the LAR record to a specific trial protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is enrolled and where the LAR authorization is operative.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject for whom this LAR is authorized to provide consent. Links the LAR record to the subject master.',
    `verified_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: LAR legal authority verification must be performed by a qualified employee per GCP and IRB requirements for vulnerable population protection.',
    `authorization_end_date` DATE COMMENT 'Date on which the LARs legal authority to consent on behalf of the subject expires or is terminated. Null indicates open-ended authority. Used to enforce consent eligibility checks.',
    `authorization_start_date` DATE COMMENT 'Date on which the LARs legal authority to consent on behalf of the subject became effective. Defines the beginning of the valid consent authorization window.',
    `authorization_status` STRING COMMENT 'Current lifecycle status of the LARs legal authorization to consent on behalf of the subject. Drives consent workflow eligibility in Clinpal eConsent and the source system. Valid values are `active|pending_verification|suspended|revoked|expired`',
    `capacity_assessment_date` DATE COMMENT 'Date on which the formal assessment of the subjects decision-making capacity was conducted, confirming the need for LAR consent. Required for regulatory documentation in pediatric and cognitively impaired populations.',
    `capacity_assessment_outcome` STRING COMMENT 'Outcome of the formal capacity assessment determining the subjects ability to provide independent informed consent. Drives the requirement for LAR consent and re-assessment scheduling.. Valid values are `lacks_capacity|has_capacity|partial_capacity|reassessment_required`',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a formal capacity assessment was required to establish the subjects inability to consent independently, thereby necessitating LAR involvement. True for cognitively impaired or pediatric populations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the LAR master record was first created in the system, conforming to ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) data integrity principles. Stored in ISO 8601 format with timezone offset.',
    `ctms_lar_record_code` STRING COMMENT 'Unique identifier of the LAR record in the source system Enables reconciliation between the lakehouse Silver layer and the CTMS operational system for site monitoring and visit tracking.',
    `econsent_platform_record_code` STRING COMMENT 'Unique identifier of the LAR record in the Clinpal eConsent platform. Used for cross-system traceability between the Silver layer lakehouse and the operational eConsent system of record.',
    `email_address` STRING COMMENT 'Email address of the Legally Authorized Representative. Used for eConsent workflow notifications via Clinpal, re-consent triggers, and regulatory correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `first_name` STRING COMMENT 'Legal given name of the Legally Authorized Representative as it appears on their government-issued identification or legal authority document.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether specific IRB (Institutional Review Board) or IEC (Independent Ethics Committee) approval was required for the use of LAR consent procedures for this subject population at this site.',
    `jurisdiction` STRING COMMENT 'The legal jurisdiction (country, state, or province) under whose laws the LARs authority document was issued and is recognized. Governs applicable legal standards for LAR validity (e.g., US-CA, US-NY, GBR, DEU).',
    `last_name` STRING COMMENT 'Legal family name or surname of the Legally Authorized Representative as it appears on their government-issued identification or legal authority document.',
    `legal_authority_document_date` DATE COMMENT 'Date on which the legal authority document (e.g., court order, power of attorney) was issued or became effective. Used to validate currency of authorization.',
    `legal_authority_document_type` STRING COMMENT 'Classification of the legal instrument that establishes the LARs authority to consent on behalf of the subject (e.g., court order, power of attorney, guardianship certificate). Required for regulatory compliance per 21 CFR 50.3(l).. Valid values are `court_order|power_of_attorney|guardianship_certificate|parental_rights_document|healthcare_proxy|advance_directive`',
    `mailing_address_line1` STRING COMMENT 'First line of the LARs mailing address (street number and name). Used for postal correspondence, regulatory notifications, and ICF delivery.',
    `mailing_address_line2` STRING COMMENT 'Second line of the LARs mailing address (apartment, suite, unit number). Supplements address line 1 for complete postal delivery.',
    `mailing_city` STRING COMMENT 'City or municipality of the LARs mailing address. Required for complete postal address and jurisdictional determination.',
    `mailing_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the LARs mailing address (e.g., USA, GBR, DEU). Determines applicable privacy regulations (GDPR, HIPAA) and legal authority standards.. Valid values are `^[A-Z]{3}$`',
    `mailing_postal_code` STRING COMMENT 'Postal or ZIP code of the LARs mailing address. Required for complete postal address and geographic analytics.',
    `mailing_state_province` STRING COMMENT 'State, province, or region of the LARs mailing address. Used for jurisdictional compliance and postal delivery.',
    `middle_name` STRING COMMENT 'Legal middle name or initial of the Legally Authorized Representative as recorded on official identification documents. May be null if not applicable.',
    `notes` STRING COMMENT 'Free-text field for site staff to record additional observations, special circumstances, or contextual information about the LARs authorization that are not captured in structured fields. Subject to ALCOA+ principles.',
    `population_category` STRING COMMENT 'Classification of the vulnerable population category that necessitates LAR consent for this subject. Determines applicable regulatory requirements and IRB/IEC conditions.. Valid values are `pediatric|cognitively_impaired|emergency_research|elderly_incapacitated|other`',
    `preferred_contact_method` STRING COMMENT 'The LARs preferred channel for receiving communications from the site, including re-consent notifications and study updates. Drives outreach workflow in Clinpal and the source system. Valid values are `email|phone|postal_mail|in_person`',
    `preferred_language` STRING COMMENT 'ISO 639-1/639-2 language code representing the LARs preferred language for consent documentation and communications (e.g., en, es, fr-CA). Ensures ICF is provided in a language the LAR understands per GCP.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `primary_phone` STRING COMMENT 'Primary telephone number for contacting the Legally Authorized Representative. Used for re-consent notifications, safety communications, and site follow-up.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `re_consent_required` BOOLEAN COMMENT 'Indicates whether a re-consent process is required for this LAR due to a protocol amendment, new safety information, or ICF version update. Triggers re-consent workflow in Clinpal.',
    `re_consent_trigger_reason` STRING COMMENT 'Reason code for why re-consent is required from the LAR. Drives re-consent workflow prioritization and regulatory documentation in the eConsent system.. Valid values are `protocol_amendment|new_safety_information|icf_version_update|regulatory_requirement|other`',
    `relationship_type` STRING COMMENT 'Categorical classification of the LARs legal or familial relationship to the trial subject (e.g., parent, legal guardian, healthcare proxy). Determines the basis of legal authority.',
    `secondary_phone` STRING COMMENT 'Alternate telephone number for the Legally Authorized Representative, used when the primary phone is unreachable. Supports continuity of contact for consent and safety communications.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `subject_assent_date` DATE COMMENT 'Date on which the subjects assent was obtained alongside the LARs consent. Applicable for pediatric or partially capacitated subjects. Null if assent was not required or not obtained.',
    `subject_assent_obtained` BOOLEAN COMMENT 'Indicates whether the subjects assent (agreement to participate, distinct from formal consent) was obtained in addition to the LARs consent. Applicable for pediatric subjects with developing capacity per 21 CFR 50.55.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the LAR master record. Used for change tracking, audit trail compliance, and Silver layer incremental processing.',
    `verification_date` DATE COMMENT 'Date on which the LARs identity and legal authority documentation were verified by authorized site personnel (PI or CRC). Required for GCP audit trail.',
    `verification_status` STRING COMMENT 'Status of the site staffs verification of the LARs identity and legal authority documentation. Tracks whether the CRC or PI has confirmed the LARs credentials per GCP requirements.. Valid values are `not_verified|verified|verification_failed|re_verification_required`',
    `withdrawal_date` DATE COMMENT 'Date on which the LAR withdrew their consent authorization on behalf of the subject, or the date on which the LARs authority was formally revoked. Triggers subject withdrawal workflow.',
    `withdrawal_reason` STRING COMMENT 'Free-text or coded reason for the withdrawal of the LARs consent authorization or revocation of legal authority. Required for regulatory reporting and subject safety follow-up.',
    CONSTRAINT pk_lar_representative PRIMARY KEY(`lar_representative_id`)
) COMMENT 'Master record for a Legally Authorized Representative (LAR) associated with a trial subject who lacks capacity to consent independently. Stores LAR full name, relationship to subject, contact details, legal authority documentation type and reference';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` (
    `icf_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for the ICF amendment record in the Databricks Silver Layer. Primary key for this entity.',
    `authored_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICF amendment authorship must be traceable to a qualified employee per ICH E6(R2) for TMF and regulatory inspection.',
    `clinpal_workflow_id` BIGINT COMMENT 'The workflow identifier assigned by the Clinpal eConsent system for the re-consent or new consent workflow triggered by this amendment. Enables traceability between the amendment record and the eConsent execution.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the new ICF version produced as a result of this amendment. Null until the amended ICF version is formally approved and issued.',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to safety.investigator_brochure_safety. Business justification: IB safety updates with new risk information directly trigger ICF amendments per ICH E6 GCP.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Regulatory requirement: every ICF amendment must receive IRB/IEC approval before implementation.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Every ICF amendment is driven by a protocol amendment requiring IRB/IEC resubmission.',
    `safety_communication_id` BIGINT COMMENT 'Foreign key linking to safety.safety_communication. Business justification: Safety-related ICF amendments are directly triggered by safety communications (e.g., SUSAR letters, urgent safety measures).',
    `superseded_by_amendment_icf_amendment_id` BIGINT COMMENT 'Reference to the subsequent amendment that supersedes this one, if applicable. Null for the current active amendment. Enables full amendment lineage chain reconstruction for regulatory inspection.',
    `affected_subject_population` STRING COMMENT 'Defines which subject population is required to undergo re-consent as a result of this amendment. Drives the re-consent workflow in Clinpal and determines the scope of CRA site monitoring activities.. Valid values are `all_enrolled|newly_enrolling_only|specific_cohort|screen_failures_only`',
    `amendment_date` DATE COMMENT 'The principal real-world date on which the amendment was formally initiated or authored. Serves as the primary business event date for the amendment lifecycle.',
    `amendment_number` STRING COMMENT 'Externally-known sequential identifier for the amendment (e.g., AM-001, AM-002). Used in regulatory submissions, IRB/IEC correspondence, and TMF filing to uniquely reference the amendment within the study.. Valid values are `^AM-[0-9]{3,6}$`',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the ICF amendment. Tracks progression from initial drafting through IRB/IEC submission, approval or rejection, and eventual supersession by a subsequent amendment.. Valid values are `draft|submitted|approved|rejected|superseded|withdrawn`',
    `amendment_type` STRING COMMENT 'Classification of the nature of change driving the amendment. Safety updates require expedited IRB/IEC review; protocol changes may require full board review; administrative corrections may qualify for expedited review.. Valid values are `safety_update|protocol_change|administrative_correction|regulatory_requirement|new_risk_information|other`',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a subject capacity or competency assessment is required before re-consent can be obtained under this amendment. Relevant for vulnerable populations, pediatric studies, or subjects with cognitive impairment.',
    `change_description` STRING COMMENT 'Detailed narrative describing the nature and rationale of the changes introduced by this amendment. Captures what was changed, why it was changed, and the impact on subject safety or study conduct.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the jurisdiction in which this amendment applies. Supports country-specific regulatory tracking where different health authorities have different amendment requirements.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ICF amendment record was first created in the Databricks Silver Layer. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11.',
    `deviation_risk_level` STRING COMMENT 'Risk classification assigned to the amendment indicating the potential for protocol deviations if re-consent is not completed within the required timeframe. Informs monitoring prioritization in the source system. Valid values are `critical|major|minor|not_assessed`',
    `econsent_applicable` BOOLEAN COMMENT 'Indicates whether the amended ICF will be deployed via the Clinpal eConsent platform. When True, triggers the eConsent build and validation workflow in Clinpal for the resulting ICF version.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether GDPR data privacy provisions apply to this amendment, typically for studies enrolling subjects in EU/EEA countries. When True, the amended ICF must include GDPR-compliant data processing disclosures.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether HIPAA authorization provisions apply to this amendment, typically for studies enrolling subjects at U.S. sites. When True, the amended ICF must include a HIPAA-compliant authorization section.',
    `implementation_date` DATE COMMENT 'The date from which the amended ICF version becomes effective for use at clinical sites. Sites must not use the amended ICF prior to this date. Typically set to or after the IRB/IEC approval date.',
    `irb_iec_decision` STRING COMMENT 'The formal decision rendered by the IRB or IEC on the amendment submission. Approved with modifications requires a revised ICF resubmission before implementation.. Valid values are `approved|approved_with_modifications|deferred|disapproved|pending`',
    `language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) of the amended ICF document (e.g., en-US, fr-FR, de-DE). Multi-language studies require separate amendment tracking per language version.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `lar_consent_applicable` BOOLEAN COMMENT 'Indicates whether consent from a Legally Authorized Representative (LAR) is applicable for this amendment, typically for subjects who lack decision-making capacity. Triggers LAR-specific consent workflow in Clinpal.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, internal comments, or contextual information related to the amendment that does not fit into structured fields. Not intended for regulatory submission content.',
    `reconsent_deadline_date` DATE COMMENT 'The date by which all affected subjects must complete re-consent. Null when reconsent_required is False. Used to monitor site compliance and escalate overdue re-consent activities.',
    `reconsent_required` BOOLEAN COMMENT 'Indicates whether currently enrolled subjects are obligated to provide re-consent under this amendment. True triggers re-consent workflow initiation in Clinpal and site notification via the source system',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether this amendment must be submitted to a health authority (e.g., FDA, EMA) as part of an IND, CTA, or equivalent regulatory filing. True triggers a regulatory submission workflow in Veeva Vault.',
    `rejection_reason` STRING COMMENT 'Free-text description of the reason provided by the IRB or IEC for rejecting or deferring the amendment. Populated only when irb_iec_decision is rejected or deferred. Required for CAPA tracking in MasterControl.',
    `requiring_authority` STRING COMMENT 'The regulatory authority, ethics committee, or organizational body that mandated or triggered this amendment. Supports regulatory inspection readiness by documenting the source of the amendment requirement.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the Principal Investigator (PI) or medical monitor who reviewed and approved the amendment content prior to IRB/IEC submission. Supports GCP audit trail requirements.',
    `safety_related` BOOLEAN COMMENT 'Indicates whether this amendment was triggered by a safety finding, SUSAR, SAE signal, or DSMB/DMC recommendation. Safety-related amendments require expedited IRB/IEC review and may trigger immediate site notification.',
    `site_applicability` STRING COMMENT 'Defines whether this amendment applies to all clinical sites globally, a specific subset of sites, or only sites within a particular country. Drives site notification and monitoring workflows in the source system. Valid values are `all_sites|specific_sites|country_specific`',
    `sponsor_approval_date` DATE COMMENT 'Date on which the pharmaceutical or biotech sponsor formally approved the amendment content prior to IRB/IEC submission. Required for sponsor oversight documentation in the TMF.',
    `tmf_section_reference` STRING COMMENT 'The TMF Reference Model section code under which this amendment document is filed (e.g., 06.02.01 for ICF amendments). Ensures correct eTMF filing and supports inspection readiness metrics.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ICF amendment record was last modified in the Databricks Silver Layer. Supports change tracking, audit trail completeness, and ALCOA+ contemporaneous documentation requirements.',
    `veeva_document_code` STRING COMMENT 'The document identifier in Veeva Vault eTMF for the amendment package (cover letter, revised ICF, IRB/IEC correspondence). Supports TMF completeness checks and regulatory inspection readiness.',
    CONSTRAINT pk_icf_amendment PRIMARY KEY(`icf_amendment_id`)
) COMMENT 'Tracks amendments to an approved ICF version, capturing the amendment number, amendment date, nature of change (safety update, protocol change, administrative correction), regulatory authority requiring the amendment, IRB/IEC submission date and approval';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` (
    `consent_delegation_log_id` BIGINT COMMENT 'Unique surrogate identifier for each consent delegation log record in the Databricks Silver Layer. Primary key for this entity.',
    `gcp_training_record_id` BIGINT COMMENT 'Reference to the GCP training record in MasterControl that documents the staff members current GCP certification, supporting delegation eligibility verification.',
    `primary_consent_employee_id` BIGINT COMMENT 'Reference to the site staff member (PI, sub-investigator, CRC, or other qualified personnel) to whom consent responsibilities are delegated.',
    `protocol_training_record_id` BIGINT COMMENT 'Reference to the protocol-specific training record confirming the staff member has been trained on the study protocol prior to conducting consent activities.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: GCP requires that staff delegated consent responsibilities have a valid study assignment.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this consent delegation is authorized. Links the delegation record to the specific trial protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the delegated staff member is authorized to conduct the informed consent process.',
    `superseded_by_log_consent_delegation_log_id` BIGINT COMMENT 'Reference to the newer consent_delegation_log record that supersedes this entry when a delegation is amended or replaced. Null if this is the current active delegation.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the signed delegation log document stored in Veeva Vault eTMF. The eTMF document serves as the regulatory-compliant archival record of the delegation per TMF Reference Model Section 04.',
    `workforce_delegation_log_id` BIGINT COMMENT 'Foreign key linking to workforce.workforce_delegation_log. Business justification: ICH E6(R2) requires consent delegation to be traceable to the master site delegation log.',
    `applicable_icf_versions` STRING COMMENT 'Comma-separated list or range of IRB/IEC-approved ICF version identifiers for which this delegation is valid (e.g., v1.0, v1.1, v2.0). Ensures the delegated staff member is only authorized for approved consent document versions.',
    `authorization_end_date` DATE COMMENT 'The date on which the staff members consent delegation authority expires or was terminated. Null indicates an open-ended delegation valid until study close-out or explicit withdrawal.',
    `authorization_start_date` DATE COMMENT 'The date from which the staff member is authorized to conduct the informed consent process under this delegation. Must not precede the PI signature date.',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether the delegated staff member is authorized to conduct subject capacity assessments as part of the consent process (relevant for vulnerable populations, pediatric studies, or cognitively impaired subjects).',
    `consent_scope` STRING COMMENT 'Defines the specific consent activities the staff member is authorized to perform under this delegation. initial_consent covers first-time ICF administration; re_consent covers protocol amendment re-consent; assent covers pediatric or. Valid values are `initial_consent|re_consent|assent|all|initial_and_reconsent`',
    `ctms_delegation_ref` STRING COMMENT 'The source system reference identifier for this delegation record as recorded in the source system supporting data lineage and reconciliation between the lakehouse and the operational system of record.',
    `delegated_role` STRING COMMENT 'The site role of the staff member receiving the consent delegation (e.g., sub-investigator, Clinical Research Coordinator (CRC)). Determines the scope of authority granted.. Valid values are `principal_investigator|sub_investigator|clinical_research_coordinator|study_nurse|research_assistant|other`',
    `delegation_amendment_number` BIGINT COMMENT 'Sequential amendment number for this delegation entry, incremented each time the scope, dates, or ICF versions are modified. Version 0 or 1 represents the original delegation; subsequent integers represent amendments.',
    `delegation_log_number` STRING COMMENT 'Externally-known alphanumeric identifier for this delegation log entry, typically generated by the CTMS or site delegation log system. Used for site inspection readiness and audit trail referencing.',
    `delegation_notes` STRING COMMENT 'Free-text field for additional context, restrictions, or conditions associated with this consent delegation (e.g., authorized for screening visits only, requires PI co-signature for re-consent).',
    `delegation_status` STRING COMMENT 'Current lifecycle state of the consent delegation authorization. active indicates the delegation is currently in force; superseded indicates replaced by a newer delegation; withdrawn indicates revoked by the PI; expired indicates the authorization. Valid values are `active|superseded|withdrawn|expired|pending`',
    `econsent_platform_user_code` STRING COMMENT 'The user account identifier of the delegated staff member within the Clinpal eConsent platform, enabling traceability of eConsent workflow actions to this delegation authorization.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this delegation log entry meets all completeness and compliance criteria required for regulatory inspection readiness (PI signature, staff signature, training confirmed, eTMF document filed).',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether the scope of this consent delegation requires specific IRB/IEC notification or approval at the site, based on local regulatory requirements.',
    `language_qualifications` STRING COMMENT 'Comma-separated list of languages in which the delegated staff member is qualified to administer the informed consent process (e.g., English, Spanish, Mandarin). Supports multilingual site operations and subject comprehension requirements.',
    `pi_signature_captured` BOOLEAN COMMENT 'Indicates whether the PIs electronic or wet signature has been captured and stored for this delegation record. Required for GCP compliance and site inspection readiness.',
    `pi_signature_date` DATE COMMENT 'The date on which the Principal Investigator (PI) signed the delegation of authority, formally authorizing the staff member to conduct the informed consent process.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this consent delegation log record was first created in the data platform. Supports audit trail and ALCOA+ data integrity requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this consent delegation log record was last modified in the data platform. Tracks changes to delegation scope, status, or signatures for audit trail purposes.',
    `staff_member_name` STRING COMMENT 'Full name of the site staff member to whom consent responsibilities are delegated. Captured at time of delegation for audit trail integrity per ALCOA+ principles, as the staff record may change over time.',
    `staff_member_signature_captured` BOOLEAN COMMENT 'Indicates whether the delegated staff members electronic or wet signature has been captured and stored for this delegation record, confirming acknowledgment of delegated responsibilities.',
    `staff_member_signature_date` DATE COMMENT 'The date on which the delegated staff member signed the delegation log, acknowledging their responsibilities and scope of consent authority.',
    `staff_member_title` STRING COMMENT 'Professional title or credentials of the delegated staff member at the time of delegation (e.g., MD, RN, PhD, CRC). Supports qualification verification for consent delegation eligibility.',
    `training_completion_confirmed` BOOLEAN COMMENT 'Indicates whether the delegated staff member has completed all required GCP and protocol-specific training prior to being authorized to conduct the informed consent process. Must be True before delegation becomes active.',
    `training_completion_date` DATE COMMENT 'The date on which the delegated staff member completed all required training (GCP, protocol, ICF-specific) as a prerequisite for consent delegation authorization.',
    `withdrawal_date` DATE COMMENT 'The date on which the PI formally withdrew or revoked this consent delegation. Populated only when delegation_status is withdrawn.',
    `withdrawal_reason` STRING COMMENT 'Free-text description of the reason the PI withdrew or revoked this consent delegation (e.g., staff departure, training lapse, protocol non-compliance). Populated only when delegation_status is withdrawn.',
    CONSTRAINT pk_consent_delegation_log PRIMARY KEY(`consent_delegation_log_id`)
) COMMENT 'Records the delegation of consent-related responsibilities at a site, capturing which qualified staff members (PI, sub-investigator, CRC) are authorized to conduct the informed consent process for a given study.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`assent_record` (
    `assent_record_id` BIGINT COMMENT 'Unique surrogate identifier for the assent record in the Databricks Silver Layer. Primary key for this entity.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the parental or guardian Informed Consent Form (ICF) version that is cross-referenced with this assent record, confirming legal consent was obtained concurrently.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: An assent record for a minor is always obtained alongside or in reference to the guardian/LARs subject_consent record.',
    `econsent_session_id` BIGINT COMMENT 'Unique session identifier from the Clinpal eConsent platform for the electronic assent interaction. Enables traceability back to the source system audit log for 21 CFR Part 11 compliance. Null for non-electronic assent methods.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Pediatric assent forms require separate IRB/IEC approval distinct from the main ICF approval.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: GCP/pediatric regulatory requirement: assent forms for pediatric subjects require separate IRB/IEC approval.',
    `lar_representative_id` BIGINT COMMENT 'Foreign key linking to consent.lar_representative. Business justification: For minors and cognitively limited subjects, the LAR (guardian/parent) provides consent while the subject provides assent.',
    `pi_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The PI overseeing pediatric assent must be documented as a qualified employee per GCP and IRB requirements for vulnerable population protection.',
    `reconsent_trigger_id` BIGINT COMMENT 'Foreign key linking to consent.reconsent_trigger. Business justification: assent_record has reconsent_required (BOOLEAN) and reconsent_trigger (STRING) as denormalized fields.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this assent record was obtained. Links the assent to the governing protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the assent was obtained. Used for site-level compliance monitoring and audit.',
    `tmf_document_id` BIGINT COMMENT 'Document identifier in the Veeva Vault eTMF system for the filed assent form. Enables direct linkage between the assent record and the regulatory-compliant document archive.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (minor or cognitively limited individual) from whom assent was obtained.',
    `assent_date` DATE COMMENT 'The calendar date on which the subject provided assent. This is the principal real-world event date per ALCOA+ contemporaneous documentation requirements.',
    `assent_form_version` STRING COMMENT 'Version identifier of the IRB/IEC-approved assent form used at the time of assent. Must correspond to the currently approved version on file in the eTMF (Veeva Vault). Format: v{Major}.{Minor}.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `assent_method` STRING COMMENT 'The method by which assent was obtained from the subject. written = paper-based signed form; verbal = verbal assent documented by witness; eassent = electronic assent via Clinpal platform; video_assisted = assent supported by video explanation. Valid values are `written|verbal|eassent|video_assisted|pictorial`',
    `assent_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the assent record, used in regulatory submissions, audit trails, and site communications. Format: ASN-{StudyCode}-{Sequence}.. Valid values are `^ASN-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `assent_status` STRING COMMENT 'Current lifecycle status of the assent record. obtained = assent successfully documented; declined = subject declined assent; withdrawn = previously given assent was withdrawn; pending = assent process initiated but not completed; not_applicable. Valid values are `obtained|declined|withdrawn|pending|not_applicable|capacity_reassessed`',
    `assent_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the assent was electronically captured or documented, including timezone offset. Required for 21 CFR Part 11 electronic records compliance and Clinpal eConsent audit trail.',
    `assent_waived` BOOLEAN COMMENT 'Indicates whether the IRB/IEC granted a waiver of assent for this subject, typically when the subject is incapable of providing meaningful assent or the research offers direct benefit not otherwise available.',
    `assent_waiver_reason` STRING COMMENT 'Documented justification for the IRB/IEC-approved waiver of assent. Required when assent_waived is True. Must reference the specific regulatory basis for the waiver.',
    `capacity_assessment_date` DATE COMMENT 'Date on which the capacity assessment was conducted. Must precede or coincide with the assent date to confirm eligibility for assent.',
    `capacity_assessment_outcome` STRING COMMENT 'Result of the cognitive capacity assessment determining the subjects ability to provide meaningful assent. capable = subject can provide assent; incapable = subject cannot provide assent (assent waived); partially_capable = limited capacity, assent. Valid values are `capable|incapable|partially_capable|deferred`',
    `capacity_assessment_performed` BOOLEAN COMMENT 'Indicates whether a formal cognitive capacity assessment was performed prior to obtaining assent. Required for subjects with potential cognitive limitations to confirm they are capable of providing meaningful assent.',
    `capacity_assessor_name` STRING COMMENT 'Full name of the qualified professional (e.g., physician, psychologist) who performed the capacity assessment. Retained for audit and regulatory inspection purposes.',
    `comprehension_confirmed` BOOLEAN COMMENT 'Indicates whether the consenter confirmed that the subject demonstrated adequate understanding of the study and their rights before assent was obtained. Core GCP requirement for valid assent.',
    `consenter_name` STRING COMMENT 'Full name of the qualified study team member (e.g., CRC, sub-investigator) who administered the assent process and documented the subjects assent.',
    `consenter_role` STRING COMMENT 'Role of the study team member who administered the assent. Must be a qualified individual delegated on the site delegation log per GCP requirements.. Valid values are `principal_investigator|sub_investigator|clinical_research_coordinator|study_nurse|delegated_staff`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this assent record was first created in the system. Part of the ALCOA+ audit trail and 21 CFR Part 11 electronic records compliance.',
    `eassent_platform` STRING COMMENT 'The technology platform used to capture the electronic assent. Clinpal is the primary eConsent system of record. Used for system-level audit and validation tracking.. Valid values are `clinpal|medidata_rave|oracle_clinical_one|paper|other`',
    `interpreter_used` BOOLEAN COMMENT 'Indicates whether a language interpreter was used during the assent process. When True, interpreter details must be documented in the site source records.',
    `language_code` STRING COMMENT 'ISO 639-1/639-2 language code of the assent form presented to the subject (e.g., en, fr, es, zh-CN). Ensures the subject received the form in their native language per GCP comprehension requirements.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `questions_asked` BOOLEAN COMMENT 'Indicates whether the subject asked questions during the assent discussion, and whether those questions were answered to the subjects satisfaction. Documents the interactive nature of the assent process per GCP.',
    `reconsent_due_date` DATE COMMENT 'The deadline by which re-assent must be obtained from the subject or their guardian. Drives compliance monitoring and site follow-up activities in the source system',
    `reconsent_required` BOOLEAN COMMENT 'Indicates whether a re-assent is required for this subject, triggered by a protocol amendment, new safety information, updated assent form version, or the subject reaching the age of majority.',
    `sdv_date` DATE COMMENT 'Date on which the CRA completed Source Data Verification (SDV) for this assent record during a monitoring visit.',
    `sdv_status` STRING COMMENT 'Status of Source Data Verification (SDV) for this assent record, performed by the Clinical Research Associate (CRA) during site monitoring visits. Tracks whether the assent documentation has been verified against source records.. Valid values are `not_required|pending|completed|discrepancy_found`',
    `source_document_location` STRING COMMENT 'Physical or electronic location of the original signed assent form source document (e.g., site binder reference, Veeva Vault eTMF document ID, or scanned document path). Required for SDV and regulatory inspection readiness.',
    `subject_age_at_assent` BIGINT COMMENT 'Age of the subject in whole years at the time assent was obtained. Critical for pediatric trial compliance to confirm the subject met the minimum age threshold for assent per applicable national regulations and ICH E11.',
    `subject_age_group` STRING COMMENT 'ICH E11 pediatric age group classification of the subject at time of assent. Used for regulatory reporting and pediatric study compliance. Values align with ICH E11(R1) age band definitions.. Valid values are `neonate|infant|toddler|child|adolescent|adult`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this assent record. Required for audit trail completeness per ALCOA+ and 21 CFR Part 11.',
    `withdrawal_date` DATE COMMENT 'Date on which the subject withdrew their assent. Populated only when assent_status is withdrawn. Triggers subject discontinuation workflow in the EDC and CTMS.',
    `withdrawal_reason` STRING COMMENT 'Free-text or coded reason provided by the subject or guardian for withdrawing assent. Retained for regulatory reporting and subject safety follow-up.',
    `witness_name` STRING COMMENT 'Full name of the impartial witness present during the assent process. Required when the subject cannot read or when verbal assent is documented. Null if no witness was required.',
    `witness_relationship` STRING COMMENT 'Relationship of the witness to the subject. Must be impartial and independent per GCP requirements. Used to verify no conflict of interest in the assent witnessing process.. Valid values are `impartial_third_party|site_staff|legal_representative|community_member`',
    `witness_required` BOOLEAN COMMENT 'Indicates whether a witness was required for the assent process, typically when the subject is illiterate, assent is verbal, or applicable regulations mandate a witness.',
    CONSTRAINT pk_assent_record PRIMARY KEY(`assent_record_id`)
) COMMENT 'Captures the formal assent obtained from a minor or cognitively limited subject who is capable of providing assent but not full legal consent. Records assent date, subject age at assent, assent form version used, assent method (verbal, written, eAssent)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`waiver` (
    `waiver_id` BIGINT COMMENT 'Unique surrogate identifier for the consent waiver record in the lakehouse Silver layer. Primary key for this entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Consent waiver approval must be traceable to a qualified employee (typically IRB liaison or medical monitor) for regulatory compliance.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Under EU CTR, consent waivers must be evaluated within the scope of the specific CTA for each member state.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the ICF version that is superseded or modified by this waiver, if applicable. Links to the document management domain for the approved ICF document.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.study_country. Business justification: Consent waivers are country-specific regulatory approvals. Linking consent_waiver to study_country enables country-level compliance reporting, supports regulatory authority notifications',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Consent waivers require formal IRB/IEC approval to be valid. Linking consent_waiver to ethics_approval normalizes denormalized irb_approval_number and irb_approval_date columns and',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the IRB or IEC that reviewed and approved this consent waiver. Establishes the authorising ethics body for the waiver.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: Consent waivers require formal ethics committee submission and review before being granted.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site at which this consent waiver applies. A waiver may be site-specific or study-wide; null if applicable to all sites.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Regulatory traceability: a consent waiver is granted by an IRB/IEC and must be directly linked to the formal approval record in site.irb_iec_approval.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Consent waivers are applied for by the sponsor as IND holder and must be reported in regulatory submissions.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Consent waivers are granted for specific protocol versions and must be traceable to the protocol for IRB/IEC submissions and regulatory authority notifications.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this consent waiver has been granted. Links the waiver to the parent protocol.',
    `superseded_by_waiver_id` BIGINT COMMENT 'Self-referencing identifier pointing to the newer consent waiver record that supersedes this one, enabling version chain traceability. Null if this is the current active version.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IRB/IEC-approved consent waivers are essential TMF documents that must be filed for regulatory inspection.',
    `community_consultation_conducted` BOOLEAN COMMENT 'Indicates whether community consultation was conducted prior to initiating the study under this waiver, as required for emergency research exception under 21 CFR 50.24. Mandatory for FDA-regulated emergency research.',
    `conditions_attached` STRING COMMENT 'Any conditions, restrictions, or obligations imposed by the IRB/IEC as part of granting the waiver (e.g., requirement to notify subjects post-study, community consultation obligations, mandatory safety reporting thresholds).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this consent waiver record was first created in the system. Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `data_privacy_impact_assessed` BOOLEAN COMMENT 'Indicates whether a Data Protection Impact Assessment (DPIA) was conducted prior to processing personal data under this consent waiver, as required by GDPR Article 35 for high-risk processing activities.',
    `effective_date` DATE COMMENT 'Date from which the consent waiver is operationally effective and may be applied to eligible subjects. May coincide with or follow the IRB/IEC approval date.',
    `expiry_date` DATE COMMENT 'Date on which the consent waiver expires and must be renewed or discontinued. Null for waivers with no defined expiry. Triggers re-approval workflow when approaching.',
    `gdpr_legal_basis` STRING COMMENT 'The GDPR Article 6/9 legal basis under which personal data is processed when informed consent is waived. Required for EU/EEA studies to ensure lawful processing of personal data without subject consent.. Valid values are `public_interest|vital_interests|scientific_research|legal_obligation|not_applicable`',
    `hipaa_authorization_waived` BOOLEAN COMMENT 'Indicates whether a HIPAA Authorization waiver has also been granted alongside the informed consent waiver, permitting use of Protected Health Information (PHI) without individual authorization. Applicable to US-based studies.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this consent waiver record. Supports ALCOA+ audit trail requirements and change detection in the Silver layer.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, clarifications, or contextual information related to this consent waiver that do not fit into structured fields. Used by CRAs and regulatory affairs staff.',
    `number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to this consent waiver by the IRB/IEC or the sponsor/CRO. Used in regulatory submissions and audit trails.',
    `pi_acknowledgement_date` DATE COMMENT 'Date on which the Principal Investigator acknowledged receipt and understanding of the consent waiver approval and its conditions. Required for GCP compliance and site activation under the waiver.',
    `post_study_notification_required` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has mandated that subjects (or their representatives) must be notified of their participation after the fact, as a condition of the waiver. Common in emergency research under 21 CFR 50.24.',
    `public_disclosure_conducted` BOOLEAN COMMENT 'Indicates whether public disclosure of the research was made prior to and following completion of the study, as required under 21 CFR 50.24 for exception from informed consent in emergency research.',
    `rationale` STRING COMMENT 'Detailed justification explaining why the waiver of informed consent is appropriate for this study and subject population. Must satisfy IRB/IEC criteria and is included in the regulatory submission package.',
    `regulatory_authority_name` STRING COMMENT 'Name of the regulatory authority notified or that granted approval for the waiver (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Supports multi-jurisdictional regulatory tracking.',
    `regulatory_authority_notified` BOOLEAN COMMENT 'Indicates whether the applicable regulatory authority (FDA, EMA, MHRA, etc.) has been formally notified of the consent waiver, as required for certain waiver types such as emergency research exceptions.',
    `regulatory_basis` STRING COMMENT 'The specific regulatory citation or legal basis under which the waiver is granted (e.g., 21 CFR 50.24 for emergency research exception, 45 CFR 46.116(c) for full waiver criteria, EU CTR 536/2014 Article 35 for emergency situations).',
    `regulatory_submission_date` DATE COMMENT 'Date on which the consent waiver documentation was submitted to the applicable regulatory authority. Required for compliance tracking and regulatory inspection readiness.',
    `renewal_due_date` DATE COMMENT 'Date by which the consent waiver must be renewed with the IRB/IEC to remain valid. Populated only when renewal_required is true. Triggers automated renewal reminders.',
    `renewal_required` BOOLEAN COMMENT 'Indicates whether this consent waiver requires periodic renewal by the IRB/IEC (e.g., annual continuing review). Drives renewal workflow and expiry notifications.',
    `research_category` STRING COMMENT 'Categorises the type of research context that necessitates the consent waiver. Drives applicable regulatory framework and reporting requirements. [ENUM-REF-CANDIDATE. Valid values are `emergency_research|retrospective_data_use|minimal_risk|public_benefit|deceased_subjects|other`',
    `scope` STRING COMMENT 'Defines the operational scope of the waiver: study_wide (applies to all sites and subjects), site_specific (limited to a named site), subject_population_specific (limited to a defined subject cohort), procedure_specific (limited to a particular study. Valid values are `study_wide|site_specific|subject_population_specific|procedure_specific`',
    `waiver_status` STRING COMMENT 'Current lifecycle state of the consent waiver from initial drafting through IRB/IEC approval, active use, expiry, or withdrawal. Controls whether the waiver may be applied to new subjects.',
    `subject_population_description` STRING COMMENT 'Narrative description of the subject population to which this waiver applies (e.g., unconscious emergency patients, retrospective data subjects, deceased individuals). Defines eligibility boundaries for waiver application.',
    `subjects_enrolled_under_waiver` BIGINT COMMENT 'Count of subjects enrolled into the study under the authority of this consent waiver. Tracked for regulatory reporting and IRB/IEC continuing review submissions.',
    `tmf_section_reference` STRING COMMENT 'The TMF Reference Model section identifier where the consent waiver documentation is filed in the eTMF (Veeva Vault), ensuring inspection-readiness and document traceability.',
    `waiver_type` STRING COMMENT 'Classification of the consent waiver: full_waiver (entire informed consent requirement waived), waiver_of_documentation (verbal consent permitted, no written ICF required), waiver_of_elements (specific ICF elements omitted), alteration_of_consent (consent. Valid values are `full_waiver|waiver_of_documentation|waiver_of_elements|alteration_of_consent`',
    `waived_elements` STRING COMMENT 'For waiver_of_elements type: free-text enumeration of the specific ICF elements that have been waived (e.g., right to withdraw, disclosure of experimental nature). Populated only when waiver_type is waiver_of_elements or alteration_of_consent.',
    `withdrawal_date` DATE COMMENT 'Date on which the IRB/IEC or regulatory authority formally withdrew or revoked this consent waiver. Populated only when waiver_status is withdrawn. Triggers immediate cessation of waiver application.',
    `withdrawal_reason` STRING COMMENT 'Narrative explanation for the withdrawal or revocation of the consent waiver by the IRB/IEC or regulatory authority. Required for audit trail completeness and CAPA initiation.',
    CONSTRAINT pk_waiver PRIMARY KEY(`waiver_id`)
) COMMENT 'Documents instances where the requirement for informed consent has been formally waived by an IRB/IEC or regulatory authority. Captures waiver type (full waiver, waiver of documentation, waiver of some elements), regulatory basis for waiver (e.g., 21 CFR';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` (
    `gdpr_data_consent_id` BIGINT COMMENT 'Unique surrogate identifier for each GDPR/HIPAA data processing consent record. Primary key for the gdpr_data_consent product in the consent domain.',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: GDPR data consent records must satisfy specific regulatory obligations (GDPR Article 6/9, HIPAA).',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GDPR/HIPAA data processing consent is typically obtained alongside the clinical ICF consent.',
    `econsent_session_id` BIGINT COMMENT 'Foreign key linking to consent.econsent_session. Business justification: gdpr_data_consent has clinpal_consent_record_id (STRING) referencing the Clinpal eConsent platform.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the data subject is enrolled and where this consent was obtained.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: The sponsor organization is the GDPR data controller in clinical trials. The existing data_controller_name is a denormalized text field; replacing it with a proper FK to',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this data processing consent was obtained. Scopes the consent record to a specific trial protocol.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (data subject) whose data processing consent is captured in this record. Links to the subject master entity.',
    `biobanking_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to long-term storage and use of biological samples and associated data in a biobank for future research. True = consented; False = not consented.',
    `clinpal_consent_record_code` STRING COMMENT 'The source system identifier from Clinpal (eConsent management platform) corresponding to this data processing consent record. Enables traceability back to the originating eConsent workflow and audit trail in Clinpal.',
    `commercial_use_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to use of their data for commercial purposes, such as drug development, licensing, or product registration activities beyond the immediate study.',
    `consent_collection_method` STRING COMMENT 'The method by which data processing consent was collected from the data subject. econsent refers to Clinpal or equivalent eConsent platform; paper refers to physical ICF/consent form; electronic_signature refers to 21 CFR Part 11 compliant. Valid values are `econsent|paper|verbal|electronic_signature|wet_signature`',
    `consent_date` DATE COMMENT 'The date on which the data subject provided explicit consent to data processing. This is the principal real-world event date for the consent transaction, distinct from the record creation timestamp.',
    `consent_expiry_date` DATE COMMENT 'The date on which this data processing consent expires, if a defined consent period was specified. Null for open-ended consents. Triggers re-consent workflow when approaching.',
    `consent_reference_number` STRING COMMENT 'Externally visible, human-readable unique reference number assigned to this data processing consent record (e.g., DPC-2024-00123). Used for audit trails, regulatory submissions, and subject rights request tracking.',
    `consent_status` STRING COMMENT 'Current lifecycle status of the data processing consent record. active indicates valid consent in force; withdrawn indicates the data subject has revoked consent; expired indicates the consent period has lapsed; pending indicates awaiting subject. Valid values are `active|withdrawn|expired|pending|superseded|refused`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this data processing consent record was first created in the system. Supports audit trail and ALCOA+ data integrity requirements.',
    `data_access_requested` BOOLEAN COMMENT 'Indicates whether the data subject has exercised their right of access under GDPR Article 15 to obtain a copy of their personal data. True = access request submitted.',
    `data_erasure_request_date` DATE COMMENT 'The date on which the data subject submitted a request for erasure of their personal data. Null if no erasure request has been made. Initiates the 30-day regulatory response clock.',
    `data_erasure_requested` BOOLEAN COMMENT 'Indicates whether the data subject has exercised their right to erasure (right to be forgotten) under GDPR Article 17. True = erasure request submitted. Triggers data deletion or anonymization workflow.',
    `data_portability_requested` BOOLEAN COMMENT 'Indicates whether the data subject has exercised their right to data portability under GDPR Article 20, requesting their data in a structured, machine-readable format.',
    `data_processor_name` STRING COMMENT 'The name of the legal entity acting as the GDPR Data Processor processing personal data on behalf of the Data Controller (e.g., the CRO, EDC vendor, or laboratory). Required for GDPR Article 30 records.',
    `data_restriction_requested` BOOLEAN COMMENT 'Indicates whether the data subject has exercised their right to restriction of processing under GDPR Article 18. True = restriction request submitted. Limits further processing until resolved.',
    `hipaa_authorization_date` DATE COMMENT 'The date on which the HIPAA Authorization was signed by the data subject or their legally authorized representative. Null if HIPAA authorization is not applicable.',
    `hipaa_authorization_expiry_date` DATE COMMENT 'The date on which the HIPAA Authorization expires, if a specific expiration date was stated. Null if the authorization is open-ended or not applicable.',
    `hipaa_authorization_required` BOOLEAN COMMENT 'Indicates whether a HIPAA Authorization (45 CFR 164.508) is required for this data subject in addition to GDPR consent, applicable for US-based subjects or US-covered entities. True = HIPAA authorization required.',
    `irb_iec_approval_reference` STRING COMMENT 'The IRB or IEC approval reference number for the privacy notice and data processing consent form version used. Confirms that the consent documentation was reviewed and approved by the ethics committee.',
    `jurisdiction` STRING COMMENT 'The regulatory jurisdiction applicable to this consent record (e.g., EU, US, UK, JP, AU). Determines which privacy regulation (GDPR, HIPAA, UK GDPR, APPI, Privacy Act) governs the data processing consent.',
    `legal_basis` STRING COMMENT 'The GDPR Article 6 lawful basis under which personal data is processed. consent applies when the data subject has given explicit consent; other bases apply per applicable regulatory context. Required for GDPR Article 30 Records of Processing Activities.. Valid values are `consent|legitimate_interest|legal_obligation|vital_interest|public_task|contract`',
    `notice_language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 alpha-2 country subtag) of the privacy notice delivered to the data subject (e.g., en, fr, de, ja, en-US). Ensures the notice was provided in the subjects native language.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `primary_research_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to processing of their personal data for the primary clinical research purpose of the study (e.g., efficacy and safety analysis). True = consented; False = not consented.',
    `privacy_notice_delivery_date` DATE COMMENT 'The date on which the privacy notice was delivered to the data subject prior to or at the time of consent. Required to demonstrate compliance with GDPR transparency obligations.',
    `privacy_notice_delivery_method` STRING COMMENT 'The method by which the privacy notice was delivered to the data subject. Supports audit evidence for GDPR transparency compliance. Values: paper, electronic (e.g., Clinpal eConsent), verbal (with written record), email, portal.. Valid values are `paper|electronic|verbal|email|portal`',
    `privacy_notice_version` STRING COMMENT 'Version identifier of the privacy notice (per GDPR Articles 13/14) delivered to the data subject at the time of consent. Enables tracking of which notice version was in effect when consent was obtained.',
    `re_consent_completion_date` DATE COMMENT 'The date on which the data subject completed the re-consent process following a re-consent trigger. Null if re-consent has not yet been completed.',
    `re_consent_required` BOOLEAN COMMENT 'Indicates whether the data subject is required to provide fresh data processing consent due to a material change in processing purposes, privacy notice amendment, or protocol amendment. True = re-consent workflow must be initiated.',
    `re_consent_trigger_reason` STRING COMMENT 'Description of the reason that triggered the re-consent requirement, such as a protocol amendment, updated privacy notice, new data processing purpose, or change in data controller. Null if re_consent_required is False.',
    `recontact_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to being re-contacted for future studies, follow-up research, or additional data collection after the current study concludes.',
    `rights_request_response_date` DATE COMMENT 'The date on which the organization responded to the data subjects rights request. Must be within 30 days of the request per GDPR Article 12(3). Null if no rights request has been submitted.',
    `rights_request_status` STRING COMMENT 'Current status of any outstanding data subject rights request (access, erasure, restriction, portability) associated with this consent record. none if no rights request has been submitted.. Valid values are `none|pending|in_progress|fulfilled|rejected|partially_fulfilled`',
    `secondary_research_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to use of their data for secondary research purposes beyond the primary study objective (e.g., exploratory analyses, future research). True = consented; False = not consented.',
    `subject_acknowledgment_date` DATE COMMENT 'The date on which the data subject formally acknowledged receipt and understanding of the privacy notice. May differ from consent_date if acknowledgment precedes formal consent signature.',
    `third_party_sharing_consent` BOOLEAN COMMENT 'Indicates whether the data subject has consented to sharing of their personal data with third parties (e.g., sponsors, regulatory authorities, CRO partners, academic institutions). True = consented; False = not consented.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this data processing consent record was last modified. Tracks amendments, status changes, and withdrawal events for audit compliance.',
    `withdrawal_date` DATE COMMENT 'The date on which the data subject withdrew their data processing consent. Null if consent has not been withdrawn. Triggers downstream data erasure or restriction workflows per GDPR Article 17.',
    `withdrawal_reason` STRING COMMENT 'Free-text or coded reason provided by the data subject for withdrawing data processing consent. Supports regulatory reporting and subject rights management.',
    CONSTRAINT pk_gdpr_data_consent PRIMARY KEY(`gdpr_data_consent_id`)
) COMMENT 'Manages GDPR and HIPAA-specific data processing consent and privacy notice records separate from clinical trial participation consent. Captures data processing purpose categories consented to (e.g., primary research, secondary research, biobanking, data';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`translation` (
    `translation_id` BIGINT COMMENT 'Unique surrogate identifier for each Informed Consent Form (ICF) translation record in the Silver Layer lakehouse. Primary key for the consent_translation data product.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the source ICF version that was translated. Links this translation record to the specific approved ICF version in the consent version master.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.study_country. Business justification: Consent translations are country-specific and must align with country-level IRB/IEC approvals and regulatory requirements.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Translated ICF versions require separate ethics committee approval in many jurisdictions before use.',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: When an ICF amendment is issued, translations of the amended ICF must be produced. consent_translation has amendment_number (STRING) as a denormalized reference.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical site or country/region where this translated ICF version is intended for use. Supports site-level consent document management.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Regulatory requirement: translated ICF versions require separate IRB/IEC approval in many jurisdictions.',
    `quality_reviewer_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICF translation quality review must be performed by a qualified internal employee per GCP and IRB requirements.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ICF translation was produced. Enables study-level aggregation of all translated consent documents.',
    `subcontract_id` BIGINT COMMENT 'Foreign key linking to agreement.subcontract. Business justification: Consent document translations are routinely performed by subcontracted translation vendors.',
    `superseded_by_translation_id` BIGINT COMMENT 'Reference to the newer consent_translation record that replaced this version. Enables forward navigation of the translation version chain for audit and compliance purposes.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Translated ICF documents are essential TMF documents requiring eTMF filing per ICH E6 R2. TMF completeness checks verify that each language translation is filed.',
    `amendment_number` STRING COMMENT 'The amendment number of the source ICF that this translation corresponds to, if the translation was produced for an amended consent form (e.g., Amendment 1, Amendment 2). Null for original (non-amended) ICF translations.',
    `back_translation_complete` BOOLEAN COMMENT 'Indicates whether the back-translation process has been completed for this ICF translation. True = back-translation is complete and reconciled. Used to gate IRB/IEC submission readiness.',
    `back_translation_date` DATE COMMENT 'The date on which the back-translation of the ICF was completed and reconciled against the source document. Null if back-translation has not been completed.',
    `back_translation_required` BOOLEAN COMMENT 'Indicates whether a back-translation (re-translation from target language back to source language) is required for this ICF translation per sponsor or regulatory requirements. True = back-translation is mandated.',
    `back_translator_name` STRING COMMENT 'Full name of the individual or vendor who performed the back-translation of the ICF. Must be independent from the forward translator per GCP best practice.',
    `translation_code` STRING COMMENT 'Externally-known unique business identifier for this translation record, following the format TRN-{StudyCode}-{LanguageCode}-{Sequence}. Used in eTMF filing, IRB/IEC submissions, and vendor communications.. Valid values are `^TRN-[A-Z0-9]{3,10}-[A-Z]{2,3}-[0-9]{3}$`',
    `comments` STRING COMMENT 'Free-text field for additional notes, context, or instructions related to this ICF translation record, such as special regulatory considerations, country-specific adaptations, or sponsor directives.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this consent translation record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record requirements.',
    `translation_date` DATE COMMENT 'The date on which the forward translation of the ICF was completed by the translation vendor or translator. Establishes the timeline for regulatory and IRB/IEC review.',
    `document_file_name` STRING COMMENT 'File name of the translated ICF document as stored in the eTMF or document management system (e.g., Veeva Vault). Supports document retrieval and audit trail.',
    `econsent_platform_ref` STRING COMMENT 'Reference identifier for this translated ICF version within the eConsent platform (Clinpal). Enables traceability between the lakehouse record and the operational eConsent workflow system.',
    `effective_date` DATE COMMENT 'The date from which this translated ICF version is authorized for use in subject consent activities at the applicable site. Typically aligned with IRB/IEC approval date or sponsor authorization date.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether this translated ICF version requires separate IRB/IEC approval in the applicable country or region. True = local ethics committee approval is required before use at site.',
    `irb_iec_approval_status` STRING COMMENT 'Current approval status of this translated ICF version with the relevant IRB or IEC. not_submitted = pending submission; submitted = under review; approved = ethics committee approved; rejected = not approved; waived = formal approval waived by. Valid values are `not_submitted|submitted|approved|rejected|waived`',
    `irb_iec_name` STRING COMMENT 'Name of the IRB or IEC responsible for reviewing and approving this translated ICF version. Supports multi-site trials where different ethics committees govern different countries.',
    `quality_review_complete` BOOLEAN COMMENT 'Indicates whether a formal quality review (QC check) of the translated ICF has been completed by the sponsor, CRO, or designated reviewer. True = QC review passed. Supports GCP quality assurance requirements.',
    `quality_review_date` DATE COMMENT 'The date on which the quality review of the translated ICF was completed. Null if quality review has not yet been performed.',
    `readability_grade_level` STRING COMMENT 'Descriptive grade level or reading age equivalent of the translated ICF (e.g., 6th grade, B1 CEFR). Supports compliance with FDA and EMA guidance that consent documents be understandable to the lay population.',
    `readability_score` DECIMAL(5,2) COMMENT 'Numeric readability score of the translated ICF document (e.g., Flesch-Kincaid or equivalent localized readability metric). Regulatory guidance recommends ICF documents be written at an appropriate reading level for the target population.',
    `reconciliation_notes` STRING COMMENT 'Free-text notes documenting any discrepancies identified during back-translation reconciliation and how they were resolved. Supports audit trail and regulatory inspection readiness.',
    `region_name` STRING COMMENT 'Named geographic region or territory for which this translation applies when a single language spans multiple countries (e.g., Latin America Spanish, Canadian French). Supplements country_code for multi-country language variants.',
    `source_icf_version_number` STRING COMMENT 'The version number of the source (original language) ICF document that was translated, as assigned by the sponsor or CRO (e.g., v1.0, v2.1). Ensures traceability between source and translated documents.',
    `source_language_code` STRING COMMENT 'ISO 639-1 two-letter code representing the original language of the ICF document prior to translation (e.g., en for English). Establishes the translation direction.. Valid values are `^[a-z]{2}$`',
    `sponsor_approval_date` DATE COMMENT 'The date on which the sponsor formally approved this translated ICF version. Null if sponsor approval has not been granted or is not required.',
    `sponsor_approval_required` BOOLEAN COMMENT 'Indicates whether formal sponsor approval is required for this translated ICF version before it can be submitted to the IRB/IEC or used at site. True = sponsor sign-off is mandatory.',
    `translation_status` STRING COMMENT 'Current lifecycle status of the ICF translation document. draft = initial translation in progress; under_review = submitted for back-translation or IRB/IEC review; approved = IRB/IEC approved for use at site; superseded = replaced by a newer. Valid values are `draft|under_review|approved|superseded|withdrawn`',
    `superseded_date` DATE COMMENT 'The date on which this translated ICF version was superseded by a newer approved version. Null if the translation is still current. Supports lifecycle management and ensures subjects are consented with the most current version.',
    `target_language_code` STRING COMMENT 'ISO 639-1 two-letter code representing the language into which the ICF was translated (e.g., fr for French, de for German, ja for Japanese). Required per GCP ICH E6 to provide consent in the subjects native language.. Valid values are `^[a-z]{2}$`',
    `target_language_name` STRING COMMENT 'Human-readable full name of the target language (e.g., French, German, Japanese). Complements the ISO code for display in reports and regulatory submissions.',
    `translator_name` STRING COMMENT 'Full name of the individual translator who performed the forward translation of the ICF, when translation is performed by a named individual rather than a vendor organization. Supports ALCOA+ attributability requirements.',
    `translator_qualification` STRING COMMENT 'Description of the translators professional qualifications, certifications, or credentials (e.g., ATA Certified Translator, medical translation specialist). Supports GCP documentation of qualified personnel.',
    `translation_type` STRING COMMENT 'Classifies the type of consent document translated. full = complete ICF; summary = short-form consent summary; assent = pediatric assent form; lay_summary = plain language summary; amendment_only = translation of an ICF amendment only.. Valid values are `full|summary|assent|lay_summary|amendment_only`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this consent translation record was most recently modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking, audit trail, and Silver Layer incremental processing.',
    `vault_document_code` STRING COMMENT 'The unique document identifier assigned by Veeva Vault eTMF for the translated ICF document. Enables direct cross-reference to the source system of record for document retrieval.',
    CONSTRAINT pk_translation PRIMARY KEY(`translation_id`)
) COMMENT 'Manages translations of ICF documents for multilingual trial sites. Records the source ICF version, target language (ISO 639-1 code), translation vendor or translator identity, translation date, back-translation completion flag, IRB/IEC approval of';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` (
    `consent_deviation_id` BIGINT COMMENT 'Unique surrogate identifier for each consent deviation record in the lakehouse silver layer. Primary key for this entity.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific Informed Consent Form (ICF) version that was involved in or relevant to the deviation (e.g., the expired version that was used, or the version that should have been used for re-consent).',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: A consent deviation records a protocol deviation in the consent process for a specific subject.',
    `discovered_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Consent deviation discovery must be attributed to a specific qualified employee for CAPA root cause analysis and regulatory reporting.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: The most critical consent deviation type is IMP dispensed without valid consent. Linking consent_deviation directly to the causative dispensing_record enables root cause analysis',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the parent protocol deviation record in the compliance domain, if this consent deviation was also logged as a broader protocol deviation. Enables cross-domain traceability.',
    `reconsent_trigger_id` BIGINT COMMENT 'Foreign key linking to consent.reconsent_trigger. Business justification: consent_deviation has reconsent_required (BOOLEAN) and reconsent_completed_date (DATE) fields. When a consent deviation requires re-consent, a reconsent_trigger is raised.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study in which the consent deviation occurred. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the consent deviation was identified. Links to the site master record.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Consent deviations (e.g., randomization before consent, wrong ICF version at randomization) must be linked to the specific randomization event for population impact',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Consent deviation reports must be filed in the TMF for inspection readiness and regulatory oversight.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) associated with this consent deviation. Links to the subject master record.',
    `comments` STRING COMMENT 'Additional free-text comments or notes entered by the deviation owner, quality manager, or reviewer that do not fit into other structured fields. Captures supplementary context for audit trail and inspection readiness purposes.',
    `corrective_action_description` STRING COMMENT 'Free-text description of the immediate corrective actions taken to address this specific consent deviation instance (e.g., re-consent obtained, missing witness signature collected, subject notified).',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this consent deviation record was first created in the system, capturing the audit trail entry point. Supports ALCOA+ data integrity requirements.',
    `data_integrity_impacted` BOOLEAN COMMENT 'Boolean flag indicating whether the consent deviation has a potential impact on the integrity or validity of data collected from the affected subject, which may affect the subjects inclusion in analysis populations (ITT, PP).',
    `consent_deviation_description` STRING COMMENT 'Free-text narrative describing the specific nature of the consent deviation, including what happened, when, and the circumstances surrounding the event. Provides context beyond the structured deviation type classification.',
    `deviation_number` STRING COMMENT 'Human-readable, externally-known business identifier for the consent deviation record, typically assigned by the CTMS or quality management system (e.g., CD-STUDY001-00042). Used for cross-system referencing, regulatory inspection, and CAPA linkage.. Valid values are `^CD-[A-Z0-9]{2,10}-[0-9]{4,8}$`',
    `deviation_status` STRING COMMENT 'Current lifecycle status of the consent deviation record, tracking its workflow from initial identification through resolution and closure. Drives inspection readiness dashboards and CAPA workflows.. Valid values are `open|under_review|resolved|closed|escalated`',
    `deviation_type` STRING COMMENT 'Categorical classification of the specific type of informed consent process failure. Examples: consent obtained after study procedures began (consent_after_procedure), an expired ICF version was used (expired_icf_version), required witness signature was. Valid values are `consent_after_procedure|expired_icf_version|missing_witness_signature|reconsent_not_completed|capacity_assessment_missing|other`',
    `discovery_date` DATE COMMENT 'The calendar date on which the consent deviation was first identified or discovered, whether by site staff, a Clinical Research Associate (CRA) during monitoring, or through a data review. Distinct from the date the deviation occurred.',
    `impact_assessment` STRING COMMENT 'Narrative assessment of the actual or potential impact of the consent deviation on subject rights, subject safety, data integrity, and study validity. Informs the regulatory reportability determination and severity classification.',
    `inspection_ready` BOOLEAN COMMENT 'Boolean flag indicating whether this consent deviation record and all associated documentation (CAPA, notifications, re-consent records) are complete and ready for regulatory inspection review. Supports inspection readiness dashboards.',
    `irb_iec_notification_date` DATE COMMENT 'The date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was formally notified of this consent deviation. Nullable if notification has not yet occurred or is not required.',
    `irb_iec_notified` BOOLEAN COMMENT 'Boolean flag indicating whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) overseeing the study has been formally notified of this consent deviation, as required by GCP and applicable regulations.',
    `occurrence_date` DATE COMMENT 'The calendar date on which the consent deviation actually occurred (e.g., the date the study procedure was performed before consent was obtained, or the date the expired ICF was signed).',
    `pi_aware` BOOLEAN COMMENT 'Boolean flag indicating whether the Principal Investigator (PI) at the site has been made aware of this consent deviation. PI awareness is a GCP requirement for site-level deviation management.',
    `pi_awareness_date` DATE COMMENT 'The date on which the Principal Investigator (PI) was formally made aware of this consent deviation. Used to track timeliness of PI notification and GCP compliance.',
    `preventive_action_description` STRING COMMENT 'Free-text description of preventive actions planned or implemented to prevent recurrence of this type of consent deviation (e.g., site retraining on ICF version control, system alert configuration in Clinpal for ICF expiry).',
    `reconsent_completed_date` DATE COMMENT 'The date on which the required re-consent process was completed and the subject signed the appropriate ICF version. Nullable if re-consent is not required or has not yet been completed.',
    `reconsent_required` BOOLEAN COMMENT 'Boolean flag indicating whether the subject must undergo a re-consent process as a corrective action for this deviation (e.g., signing the current approved ICF version to replace an expired version that was used).',
    `regulatory_reportable` BOOLEAN COMMENT 'Boolean flag indicating whether this consent deviation must be reported to a regulatory authority (FDA, EMA, MHRA, PMDA, etc.), IRB/IEC, or sponsor per applicable regulations and the study protocol. Drives regulatory submission workflows.',
    `reported_date` DATE COMMENT 'The date on which the consent deviation was formally reported to the sponsor, IRB/IEC, or regulatory authority as applicable. Used to calculate reporting timeliness and compliance with notification windows.',
    `resolution_date` DATE COMMENT 'The date on which the consent deviation was fully resolved, including completion of any required corrective actions (e.g., re-consent obtained, missing signatures collected, CAPA closed). Nullable until resolution is achieved.',
    `root_cause` STRING COMMENT 'Documented root cause analysis narrative explaining the underlying reason the consent deviation occurred (e.g., site staff training gap, ICF version control failure, system notification failure for re-consent trigger).',
    `root_cause_category` STRING COMMENT 'Structured categorical classification of the root cause to enable trend analysis across deviations. Categories include training deficiencies, process failures, system issues, communication breakdowns, and oversight gaps.. Valid values are `training|process|system|communication|oversight|other`',
    `severity` STRING COMMENT 'Risk-based severity classification of the consent deviation. Critical deviations may directly impact subject rights, safety, or data integrity and typically require immediate escalation and regulatory reporting.. Valid values are `critical|major|minor`',
    `source_system_record_code` STRING COMMENT 'The native record identifier from the originating operational system (e.g., MasterControl deviation record number, Clinpal event ID). Enables reverse traceability from the lakehouse back to the system of record.',
    `sponsor_notification_date` DATE COMMENT 'The date on which the study sponsor was formally notified of this consent deviation. Used to calculate notification timeliness against contractual and regulatory requirements.',
    `sponsor_notified` BOOLEAN COMMENT 'Boolean flag indicating whether the study sponsor has been formally notified of this consent deviation per the Clinical Trial Agreement and GCP requirements.',
    `subject_continued_in_study` BOOLEAN COMMENT 'Boolean flag indicating whether the affected subject continued participation in the clinical study following the consent deviation and any required corrective actions.',
    `subject_rights_impacted` BOOLEAN COMMENT 'Boolean flag indicating whether the consent deviation directly impacted the rights or welfare of the trial subject (e.g., subject underwent a procedure without valid informed consent).',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent modification to this consent deviation record. Used for change tracking, audit trail compliance, and incremental data pipeline processing.',
    CONSTRAINT pk_consent_deviation PRIMARY KEY(`consent_deviation_id`)
) COMMENT 'Records protocol deviations specifically related to the informed consent process, such as consent obtained after study procedures began, expired ICF version used, missing witness signature, or re-consent not completed within required timeframe.';

ALTER SCHEMA `clinical_trials_ecm`.`consent` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`consent` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_parent_icf_version_consent_icf_version_id` FOREIGN KEY (`parent_icf_version_consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ADD CONSTRAINT `fk_consent_consent_icf_version_template_id` FOREIGN KEY (`template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` SET TAGS ('dbx_subdomain' = 'document_management');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `parent_icf_version_consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `amendment_nature_of_change` SET TAGS ('dbx_business_glossary_term' = 'Amendment Nature of Change Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_irb_iec|approved|superseded|withdrawn|expired');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `back_translation_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Completion Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `back_translation_status` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `back_translation_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|completed|failed');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `biobanking_consent_included` SET TAGS ('dbx_business_glossary_term' = 'Biobanking Consent Included Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `clinpal_consent_form_code` SET TAGS ('dbx_business_glossary_term' = 'Clinpal eConsent Form ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `consent_type` SET TAGS ('dbx_value_regex' = 'initial|re-consent|assent|lar|short_form|addendum');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `econsent_deployment_date` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Deployment Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `econsent_enabled` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Enabled Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `gdpr_data_processing_included` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Data Processing Disclosure Included Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `gdpr_data_processing_included` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8;GDPR Art.6');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `genetic_testing_consent_included` SET TAGS ('dbx_business_glossary_term' = 'Genetic Testing Consent Included Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `hipaa_authorization_included` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Included Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `hipaa_authorization_included` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.508');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `icf_title` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Title');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?[a-zA-Z]?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `internal_review_status` SET TAGS ('dbx_value_regex' = 'in_authoring|internal_review|sponsor_approved|submitted_to_irb_iec|approved|archived');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `is_master_language` SET TAGS ('dbx_business_glossary_term' = 'Is Master Language Version Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `is_master_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code (ISO 639-1)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `lar_consent_applicable` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Consent Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `reconsent_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `tmf_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `vault_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|obsolete|archived');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Signature Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_consenting_staff_study_assignment_id` FOREIGN KEY (`consenting_staff_study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_ecm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consenting_staff_study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Consenting Staff Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Consenting Staff ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'capable|incapable|borderline|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Performed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `comprehension_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Assessment Performed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_standard_reference' = 'SDTM DS.DSSTDTC;ICH GCP E6(R2) 4.8.8');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'paper|econsent|remote_econsent|telephone|legally_authorized_rep');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_value_regex' = 'consented|withdrawn|re_consent_pending|expired|not_obtained');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_type` SET TAGS ('dbx_value_regex' = 'initial|re_consent|amendment|optional_procedure|genetic|long_term_followup');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `consenting_staff_role` SET TAGS ('dbx_value_regex' = 'PI|sub_investigator|CRC|delegate');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `data_use_after_withdrawal` SET TAGS ('dbx_business_glossary_term' = 'Data Use After Withdrawal Permitted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `econsent_completion_pct` SET TAGS ('dbx_business_glossary_term' = 'eConsent Completion Percentage');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_business_glossary_term' = 'GDPR Lawful Basis for Processing');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_value_regex' = 'explicit_consent|vital_interests|public_interest|legitimate_interests|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_standard_reference' = 'GDPR Art.6');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `hipaa_authorization_obtained` SET TAGS ('dbx_business_glossary_term' = 'HIPAA Authorization Obtained Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `hipaa_authorization_obtained` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.508');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `icf_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_involved` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Involved Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Due Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_value_regex' = 'protocol_amendment|safety_update|icf_version_update|irb_requirement|regulatory_request');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `sample_use_after_withdrawal` SET TAGS ('dbx_business_glossary_term' = 'Biological Sample Use After Withdrawal Permitted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `subject_questions_documented` SET TAGS ('dbx_business_glossary_term' = 'Subject Questions Documented Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_business_glossary_term' = 'ICF Translation Language');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_value_regex' = 'subject_decision|adverse_event|lost_to_followup|physician_decision|protocol_deviation|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_signature_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) / Site Staff ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'capable|not-capable|not-assessed|deferred');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Performed Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `clinpal_session_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinpal Session Reference ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `communication_platform` SET TAGS ('dbx_business_glossary_term' = 'Remote Communication Platform');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Attempt Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_check_version` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Question Set Version');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_overall_passed` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Overall Pass Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `consent_granted` SET TAGS ('dbx_business_glossary_term' = 'Consent Granted Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `consenter_role` SET TAGS ('dbx_value_regex' = 'subject|legally-authorized-representative|parent|guardian');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `device_os` SET TAGS ('dbx_business_glossary_term' = 'Device Operating System');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `device_type` SET TAGS ('dbx_value_regex' = 'tablet|smartphone|desktop|laptop|kiosk');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `esignature_captured` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Captured Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `esignature_captured` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Capture Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_standard_reference' = '21 CFR Part 11');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `interpreter_used` SET TAGS ('dbx_business_glossary_term' = 'Interpreter Used Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `irb_approval_ref` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) / Independent Ethics Committee (IEC) Approval Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Trigger Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `remediation_provided` SET TAGS ('dbx_business_glossary_term' = 'Remediation Provided Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `review_steps_total` SET TAGS ('dbx_business_glossary_term' = 'Total Review Steps');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_modality` SET TAGS ('dbx_business_glossary_term' = 'eConsent Session Modality');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_modality` SET TAGS ('dbx_value_regex' = 'in-person|remote-video|remote-phone|hybrid');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_recording_ref` SET TAGS ('dbx_business_glossary_term' = 'Session Recording Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_status` SET TAGS ('dbx_business_glossary_term' = 'eConsent Session Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `session_status` SET TAGS ('dbx_value_regex' = 'in-progress|completed|abandoned|timed-out|declined');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_auth_method` SET TAGS ('dbx_business_glossary_term' = 'Subject Authentication Method');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_auth_method` SET TAGS ('dbx_value_regex' = 'password|otp-sms|otp-email|biometric|pin|site-staff-verified');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `technical_issue_encountered` SET TAGS ('dbx_business_glossary_term' = 'Technical Issue Encountered Indicator');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `witness_esignature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Witness Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`econsent_session` ALTER COLUMN `witness_esignature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_compliance_protocol_deviation_id` FOREIGN KEY (`compliance_protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_dsmb_recommendation_id` FOREIGN KEY (`dsmb_recommendation_id`) REFERENCES `clinical_trials_ecm`.`safety`.`dsmb_recommendation`(`dsmb_recommendation_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_primary_reconsent_employee_id` FOREIGN KEY (`primary_reconsent_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_primary_reconsent_safety_communication_id` FOREIGN KEY (`primary_reconsent_safety_communication_id`) REFERENCES `clinical_trials_ecm`.`safety`.`safety_communication`(`safety_communication_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `compliance_protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `dsmb_recommendation_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Recommendation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `econsent_session_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Session ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `primary_reconsent_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Site Staff ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `primary_reconsent_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `primary_reconsent_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `primary_reconsent_safety_communication_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Communication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `affected_icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Affected Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'has_capacity|lacks_capacity|assessment_pending|not_required');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_method` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Method');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|verbal_with_witness|remote_electronic|legally_authorized_representative');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Notes');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `previous_icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Previous Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `protocol_deviation_raised` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Raised Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Completion Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_deadline` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsented_subject_count` SET TAGS ('dbx_business_glossary_term' = 'Re-Consented Subject Count');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `regulatory_authority_directive_ref` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Directive Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reminder_count` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Reminder Count');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `reminder_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Reminder Sent Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Resolution Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|waived|overdue|cancelled');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_scope` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Subject Scope');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_scope` SET TAGS ('dbx_value_regex' = 'individual_subject|all_active_subjects|site_cohort|study_wide');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_description` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Reference Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_reference_number` SET TAGS ('dbx_value_regex' = '^RCT-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'protocol_amendment|new_safety_information|icf_version_update|regulatory_authority_requirement|irb_iec_requirement|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Waiver Approval Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `waiver_justification` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Waiver Justification');

ALTER TABLE `clinical_trials_ecm`.`consent`.`reconsent_trigger` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Subject Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_ecm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_prior_assessment_capacity_assessment_id` FOREIGN KEY (`prior_assessment_capacity_assessment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`capacity_assessment`(`capacity_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `capacity_assessment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessor ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `prior_assessment_capacity_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Capacity Assessment ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `prior_assessment_capacity_assessment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_value_regex' = '^CA-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Outcome');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_outcome` SET TAGS ('dbx_value_regex' = 'Capable|Incapable|Borderline|Deferred|Unable to Assess');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_score_max` SET TAGS ('dbx_business_glossary_term' = 'Assessment Score Maximum');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_setting` SET TAGS ('dbx_value_regex' = 'In-Person|Remote|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'Planned|In Progress|Completed|Cancelled|Superseded');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_tool` SET TAGS ('dbx_business_glossary_term' = 'Assessment Tool or Method');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'Initial|Re-Assessment|Periodic|Post-Amendment|Withdrawal');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_credentials` SET TAGS ('dbx_business_glossary_term' = 'Assessor Professional Credentials');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_business_glossary_term' = 'Assessor Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assessor Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Assessment Comments');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `interpreter_used` SET TAGS ('dbx_business_glossary_term' = 'Interpreter Used Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `language_of_assessment` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `language_of_assessment` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_required` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `outcome_basis` SET TAGS ('dbx_business_glossary_term' = 'Basis for Capacity Determination');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Due Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Trigger');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_trigger` SET TAGS ('dbx_value_regex' = 'Borderline Outcome|Change in Condition|Protocol Amendment|Regulatory Requirement|Scheduled Interval|Other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_business_glossary_term' = 'Witness Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_ecm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Notifying Staff ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Decision-Making Capacity Assessment Performed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Comments');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `ctms_withdrawal_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Withdrawal Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `data_retention_status` SET TAGS ('dbx_value_regex' = 'active|pending_review|anonymized|destroyed|retained');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `edc_subject_status_updated` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Subject Status Updated Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `initiated_by` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Initiated By');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `initiated_by` SET TAGS ('dbx_value_regex' = 'subject|lar|investigator|sponsor|regulatory_authority');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `irb_iec_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `itt_population_impact` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Impact');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `itt_population_impact` SET TAGS ('dbx_value_regex' = 'included|excluded|pending_review');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Method');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'electronic|paper|verbal|telephone');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `pi_notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notification Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `pi_notified` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notified');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `post_withdrawal_data_handling` SET TAGS ('dbx_business_glossary_term' = 'Post-Withdrawal Data Handling Instruction');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `post_withdrawal_data_handling` SET TAGS ('dbx_value_regex' = 'retain_all|retain_safety_only|destroy_all|anonymize|per_protocol');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `protocol_deviation_triggered` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Triggered Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `reason_category` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Reason Category');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `reason_category` SET TAGS ('dbx_value_regex' = 'voluntary|adverse_event_related|sponsor_decision|lost_to_follow_up|protocol_non_compliance|physician_decision');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_attempted` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Attempted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_outcome` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Attempt Outcome');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_outcome` SET TAGS ('dbx_value_regex' = 'successful|unsuccessful|not_attempted');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `safety_follow_up_end_date` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up End Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `safety_follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_status` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|rescinded|superseded|archived');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `study_discontinuation_date` SET TAGS ('dbx_standard_reference' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_business_glossary_term' = 'Subject-Stated Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Filing Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_value_regex' = 'pending|filed|verified');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Treatment Stop Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_type` SET TAGS ('dbx_value_regex' = 'full_withdrawal|treatment_withdrawal|data_use_withdrawal|future_sample_withdrawal');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_primary_audit_employee_id` FOREIGN KEY (`primary_audit_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ADD CONSTRAINT `fk_consent_audit_entry_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` SET TAGS ('dbx_subdomain' = 'compliance_tracking');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `audit_entry_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Audit Entry ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `primary_audit_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Actor User ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `primary_audit_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `primary_audit_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `actor_full_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `actor_full_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `actor_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `affected_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Affected Consent Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `affected_record_type` SET TAGS ('dbx_business_glossary_term' = 'Affected Consent Record Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `affected_record_type` SET TAGS ('dbx_value_regex' = 'subject_consent|icf_version|econsent_session|withdrawal|capacity_assessment|re_consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `capacity_assessment_result` SET TAGS ('dbx_value_regex' = 'capable|incapable|reassessment_required');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `capacity_assessment_result` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `changed_field_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'paper|eConsent|remote_eConsent|telephone|video');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_status_after` SET TAGS ('dbx_business_glossary_term' = 'Consent Status After Event');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_status_after` SET TAGS ('dbx_value_regex' = 'pending|consented|re_consent_required|withdrawn|capacity_assessed|voided');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_status_before` SET TAGS ('dbx_business_glossary_term' = 'Consent Status Before Event');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `consent_status_before` SET TAGS ('dbx_value_regex' = 'pending|consented|re_consent_required|withdrawn|capacity_assessed|voided');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `device_identifier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `device_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `device_identifier` SET TAGS ('dbx_pii_device' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `digital_signature_hash` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `digital_signature_hash` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `digital_signature_hash` SET TAGS ('dbx_standard_reference' = '21 CFR Part 11');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Audit Event Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Audit Event Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Lawful Basis');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_value_regex' = 'explicit_consent|vital_interests|public_task|legitimate_interests');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `hipaa_authorization_flag` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `irb_iec_approval_number` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `is_void` SET TAGS ('dbx_business_glossary_term' = 'Is Void Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `lar_relationship` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Relationship');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `new_value` SET TAGS ('dbx_business_glossary_term' = 'New Field Value');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `previous_value` SET TAGS ('dbx_business_glossary_term' = 'Previous Field Value');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Meaning');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_value_regex' = 'I agree|I have reviewed|Approved|Witnessed|Countersigned');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_standard_reference' = '21 CFR Part 11');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`audit_entry` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_legal_authority_tmf_document_id` FOREIGN KEY (`legal_authority_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_verified_by_employee_id` FOREIGN KEY (`verified_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` SET TAGS ('dbx_subdomain' = 'legal_authorization');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Representative ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Authority Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verified_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Verified By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verified_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verified_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `authorization_end_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization End Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `authorization_start_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Start Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `authorization_status` SET TAGS ('dbx_value_regex' = 'active|pending_verification|suspended|revoked|expired');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Outcome');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'lacks_capacity|has_capacity|partial_capacity|reassessment_required');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `ctms_lar_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) LAR Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `econsent_platform_record_code` SET TAGS ('dbx_business_glossary_term' = 'eConsent Platform Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'LAR Email Address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email;standard_reference' = 'FHIR RelatedPerson.telecom');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'LAR First Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required for LAR Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Legal Jurisdiction');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'LAR Last Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Authority Document Issue Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_type` SET TAGS ('dbx_value_regex' = 'court_order|power_of_attorney|guardianship_certificate|parental_rights_document|healthcare_proxy|advance_directive');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Address Line 1');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Address Line 2');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing City');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Country Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Postal Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing State or Province');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'LAR Middle Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'LAR Record Notes');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `population_category` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Category');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `population_category` SET TAGS ('dbx_value_regex' = 'pediatric|cognitively_impaired|emergency_research|elderly_incapacitated|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'LAR Preferred Contact Method');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|postal_mail|in_person');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'LAR Preferred Language');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'LAR Primary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone;standard_reference' = 'FHIR RelatedPerson.telecom');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_value_regex' = 'protocol_amendment|new_safety_information|icf_version_update|regulatory_requirement|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'LAR Relationship Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_business_glossary_term' = 'LAR Secondary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_phone;standard_reference' = 'FHIR RelatedPerson.telecom');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `subject_assent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Subject Assent Obtained Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Verification Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'LAR Verification Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'not_verified|verified|verification_failed|re_verification_required');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`lar_representative` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_authored_by_employee_id` FOREIGN KEY (`authored_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_clinpal_workflow_id` FOREIGN KEY (`clinpal_workflow_id`) REFERENCES `clinical_trials_ecm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_safety_communication_id` FOREIGN KEY (`safety_communication_id`) REFERENCES `clinical_trials_ecm`.`safety`.`safety_communication`(`safety_communication_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_superseded_by_amendment_icf_amendment_id` FOREIGN KEY (`superseded_by_amendment_icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` SET TAGS ('dbx_subdomain' = 'document_management');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Authored By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `authored_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `clinpal_workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Clinpal eConsent Workflow ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Resulting Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `safety_communication_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Communication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `superseded_by_amendment_icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By ICF Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `affected_subject_population` SET TAGS ('dbx_value_regex' = 'all_enrolled|newly_enrolling_only|specific_cohort|screen_failures_only');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^AM-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|superseded|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'safety_update|protocol_change|administrative_correction|regulatory_requirement|new_risk_information|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `change_description` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Change Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `deviation_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Risk Level');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `deviation_risk_level` SET TAGS ('dbx_value_regex' = 'critical|major|minor|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `econsent_applicable` SET TAGS ('dbx_business_glossary_term' = 'eConsent Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Implementation Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `irb_iec_decision` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Decision');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `irb_iec_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_modifications|deferred|disapproved|pending');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'ICF Language Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `lar_consent_applicable` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Consent Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Notes');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `reconsent_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Rejection Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `requiring_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Requiring Amendment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reviewed By');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Amendment Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `site_applicability` SET TAGS ('dbx_business_glossary_term' = 'Site Applicability Scope');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `site_applicability` SET TAGS ('dbx_value_regex' = 'all_sites|specific_sites|country_specific');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `tmf_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`icf_amendment` ALTER COLUMN `veeva_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Document ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_gcp_training_record_id` FOREIGN KEY (`gcp_training_record_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`gcp_training_record`(`gcp_training_record_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_primary_consent_employee_id` FOREIGN KEY (`primary_consent_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_protocol_training_record_id` FOREIGN KEY (`protocol_training_record_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`protocol_training_record`(`protocol_training_record_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_superseded_by_log_consent_delegation_log_id` FOREIGN KEY (`superseded_by_log_consent_delegation_log_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_delegation_log`(`consent_delegation_log_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ADD CONSTRAINT `fk_consent_consent_delegation_log_workforce_delegation_log_id` FOREIGN KEY (`workforce_delegation_log_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_delegation_log`(`workforce_delegation_log_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` SET TAGS ('dbx_subdomain' = 'compliance_tracking');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `gcp_training_record_id` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `primary_consent_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Staff Member ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `primary_consent_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `primary_consent_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `superseded_by_log_consent_delegation_log_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Delegation Log ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `workforce_delegation_log_id` SET TAGS ('dbx_business_glossary_term' = 'Workforce Delegation Log Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `applicable_icf_versions` SET TAGS ('dbx_business_glossary_term' = 'Applicable Informed Consent Form (ICF) Versions');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `consent_scope` SET TAGS ('dbx_value_regex' = 'initial_consent|re_consent|assent|all|initial_and_reconsent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `ctms_delegation_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Delegation Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `delegated_role` SET TAGS ('dbx_value_regex' = 'principal_investigator|sub_investigator|clinical_research_coordinator|study_nurse|research_assistant|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `delegation_status` SET TAGS ('dbx_value_regex' = 'active|superseded|withdrawn|expired|pending');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `econsent_platform_user_code` SET TAGS ('dbx_business_glossary_term' = 'eConsent Platform User ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `econsent_platform_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `econsent_platform_user_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `econsent_platform_user_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `language_qualifications` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_captured` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Captured Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_captured` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_captured` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_name` SET TAGS ('dbx_business_glossary_term' = 'Delegated Staff Member Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_captured` SET TAGS ('dbx_business_glossary_term' = 'Delegated Staff Member Signature Captured Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_captured` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_captured` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_date` SET TAGS ('dbx_business_glossary_term' = 'Delegated Staff Member Signature Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `staff_member_title` SET TAGS ('dbx_business_glossary_term' = 'Delegated Staff Member Professional Title');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `training_completion_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Delegation Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_delegation_log` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Delegation Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_ecm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_pi_employee_id` FOREIGN KEY (`pi_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_ecm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ADD CONSTRAINT `fk_consent_assent_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` SET TAGS ('dbx_subdomain' = 'subject_enrollment');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `econsent_session_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Assent (eAssent) Session ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `pi_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Pi Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `pi_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `pi_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Reconsent Trigger Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_form_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_method` SET TAGS ('dbx_value_regex' = 'written|verbal|eassent|video_assisted|pictorial');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_number` SET TAGS ('dbx_business_glossary_term' = 'Assent Record Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_number` SET TAGS ('dbx_value_regex' = '^ASN-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_status` SET TAGS ('dbx_value_regex' = 'obtained|declined|withdrawn|pending|not_applicable|capacity_reassessed');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `assent_waived` SET TAGS ('dbx_business_glossary_term' = 'Assent Waived Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'capable|incapable|partially_capable|deferred');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Performed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `capacity_assessor_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `comprehension_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Subject Comprehension Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consenter_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consenter_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consenter_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `consenter_role` SET TAGS ('dbx_value_regex' = 'principal_investigator|sub_investigator|clinical_research_coordinator|study_nurse|delegated_staff');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `eassent_platform` SET TAGS ('dbx_business_glossary_term' = 'Electronic Assent (eAssent) Platform');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `eassent_platform` SET TAGS ('dbx_value_regex' = 'clinpal|medidata_rave|oracle_clinical_one|paper|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `interpreter_used` SET TAGS ('dbx_business_glossary_term' = 'Interpreter Used Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Assent Form Language Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `questions_asked` SET TAGS ('dbx_business_glossary_term' = 'Subject Questions Asked Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `reconsent_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Assent Due Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Assent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|completed|discrepancy_found');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_at_assent` SET TAGS ('dbx_business_glossary_term' = 'Subject Age at Assent (Years)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_at_assent` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_at_assent` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_at_assent` SET TAGS ('dbx_pii_health;standard_reference' = 'SDTM DM.AGE');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_at_assent` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_group` SET TAGS ('dbx_business_glossary_term' = 'Subject Age Group (ICH E11 Classification)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_group` SET TAGS ('dbx_value_regex' = 'neonate|infant|toddler|child|adolescent|adult');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_group` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `subject_age_group` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Assent Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Assent Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_relationship` SET TAGS ('dbx_business_glossary_term' = 'Witness Relationship to Subject');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_relationship` SET TAGS ('dbx_value_regex' = 'impartial_third_party|site_staff|legal_representative|community_member');

ALTER TABLE `clinical_trials_ecm`.`consent`.`assent_record` ALTER COLUMN `witness_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_superseded_by_waiver_id` FOREIGN KEY (`superseded_by_waiver_id`) REFERENCES `clinical_trials_ecm`.`consent`.`waiver`(`waiver_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ADD CONSTRAINT `fk_consent_waiver_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` SET TAGS ('dbx_subdomain' = 'legal_authorization');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `waiver_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `superseded_by_waiver_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Consent Waiver ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `community_consultation_conducted` SET TAGS ('dbx_business_glossary_term' = 'Community Consultation Conducted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `conditions_attached` SET TAGS ('dbx_business_glossary_term' = 'Conditions Attached to Waiver');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `data_privacy_impact_assessed` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Impact Assessment Conducted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Effective Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `gdpr_legal_basis` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Legal Basis for Processing');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `gdpr_legal_basis` SET TAGS ('dbx_value_regex' = 'public_interest|vital_interests|scientific_research|legal_obligation|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `gdpr_legal_basis` SET TAGS ('dbx_standard_reference' = 'GDPR Art.6');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `hipaa_authorization_waived` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Waiver Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `hipaa_authorization_waived` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.512');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Notes');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `pi_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Acknowledgement Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `post_study_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Post-Study Subject Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `public_disclosure_conducted` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Conducted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Rationale');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `regulatory_authority_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `regulatory_authority_notified` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Basis for Waiver');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `renewal_due_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Renewal Due Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `renewal_required` SET TAGS ('dbx_business_glossary_term' = 'Waiver Renewal Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `research_category` SET TAGS ('dbx_business_glossary_term' = 'Research Category for Waiver');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `research_category` SET TAGS ('dbx_value_regex' = 'emergency_research|retrospective_data_use|minimal_risk|public_benefit|deceased_subjects|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Scope');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'study_wide|site_specific|subject_population_specific|procedure_specific');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `waiver_status` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `subject_population_description` SET TAGS ('dbx_business_glossary_term' = 'Applicable Subject Population Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `subjects_enrolled_under_waiver` SET TAGS ('dbx_business_glossary_term' = 'Number of Subjects Enrolled Under Waiver');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `tmf_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `waiver_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `waiver_type` SET TAGS ('dbx_value_regex' = 'full_waiver|waiver_of_documentation|waiver_of_elements|alteration_of_consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `waived_elements` SET TAGS ('dbx_business_glossary_term' = 'Waived Informed Consent Form (ICF) Elements');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`waiver` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_ecm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ADD CONSTRAINT `fk_consent_gdpr_data_consent_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` SET TAGS ('dbx_subdomain' = 'legal_authorization');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `gdpr_data_consent_id` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Data Consent ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `econsent_session_id` SET TAGS ('dbx_business_glossary_term' = 'Econsent Session Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `biobanking_consent` SET TAGS ('dbx_business_glossary_term' = 'Biobanking Data Processing Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `clinpal_consent_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinpal eConsent Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `commercial_use_consent` SET TAGS ('dbx_business_glossary_term' = 'Commercial Use Data Processing Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_collection_method` SET TAGS ('dbx_value_regex' = 'econsent|paper|verbal|electronic_signature|wet_signature');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Reference Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_value_regex' = 'active|withdrawn|expired|pending|superseded|refused');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_access_requested` SET TAGS ('dbx_business_glossary_term' = 'Data Access Request Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_erasure_requested` SET TAGS ('dbx_business_glossary_term' = 'Data Erasure Request Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_portability_requested` SET TAGS ('dbx_business_glossary_term' = 'Data Portability Request Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_processor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_processor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_processor_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `data_restriction_requested` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Restriction Request Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `hipaa_authorization_date` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `hipaa_authorization_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `hipaa_authorization_required` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `hipaa_authorization_required` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.508');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `irb_iec_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Reference');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Jurisdiction');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `legal_basis` SET TAGS ('dbx_business_glossary_term' = 'Legal Basis for Data Processing');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `legal_basis` SET TAGS ('dbx_value_regex' = 'consent|legitimate_interest|legal_obligation|vital_interest|public_task|contract');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `legal_basis` SET TAGS ('dbx_standard_reference' = 'GDPR Art.6');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `notice_language_code` SET TAGS ('dbx_business_glossary_term' = 'Privacy Notice Language Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `notice_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `notice_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `primary_research_consent` SET TAGS ('dbx_business_glossary_term' = 'Primary Research Data Processing Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `privacy_notice_delivery_method` SET TAGS ('dbx_value_regex' = 'paper|electronic|verbal|email|portal');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `re_consent_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Completion Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `re_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Trigger Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `recontact_consent` SET TAGS ('dbx_business_glossary_term' = 'Re-contact Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `recontact_consent` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `rights_request_response_date` SET TAGS ('dbx_business_glossary_term' = 'Data Subject Rights Request Response Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `rights_request_status` SET TAGS ('dbx_business_glossary_term' = 'Data Subject Rights Request Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `rights_request_status` SET TAGS ('dbx_value_regex' = 'none|pending|in_progress|fulfilled|rejected|partially_fulfilled');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `secondary_research_consent` SET TAGS ('dbx_business_glossary_term' = 'Secondary Research Data Processing Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `subject_acknowledgment_date` SET TAGS ('dbx_business_glossary_term' = 'Data Subject Acknowledgment Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `third_party_sharing_consent` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Data Sharing Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`gdpr_data_consent` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_quality_reviewer_employee_id` FOREIGN KEY (`quality_reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_subcontract_id` FOREIGN KEY (`subcontract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`subcontract`(`subcontract_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_superseded_by_translation_id` FOREIGN KEY (`superseded_by_translation_id`) REFERENCES `clinical_trials_ecm`.`consent`.`translation`(`translation_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ADD CONSTRAINT `fk_consent_translation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` SET TAGS ('dbx_subdomain' = 'document_management');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Translation ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `quality_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Reviewer Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `quality_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `quality_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `subcontract_id` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translation_complete` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Completion Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translation_date` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Completion Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translation_required` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translator_name` SET TAGS ('dbx_business_glossary_term' = 'Back-Translator Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translator_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `back_translator_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_code` SET TAGS ('dbx_business_glossary_term' = 'Translation Document Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_code` SET TAGS ('dbx_value_regex' = '^TRN-[A-Z0-9]{3,10}-[A-Z]{2,3}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Translation Record Comments');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_date` SET TAGS ('dbx_business_glossary_term' = 'Translation Completion Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `document_file_name` SET TAGS ('dbx_business_glossary_term' = 'Translation Document File Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `document_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `econsent_platform_ref` SET TAGS ('dbx_business_glossary_term' = 'eConsent Platform Reference ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Translation Effective Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_value_regex' = 'not_submitted|submitted|approved|rejected|waived');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `quality_review_complete` SET TAGS ('dbx_business_glossary_term' = 'Quality Review Completion Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `reconciliation_notes` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Reconciliation Notes');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `region_name` SET TAGS ('dbx_business_glossary_term' = 'Region or Territory Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `region_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `source_icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Source Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `source_language_code` SET TAGS ('dbx_business_glossary_term' = 'Source Language ISO 639-1 Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `source_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `source_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `sponsor_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Translation Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `target_language_code` SET TAGS ('dbx_business_glossary_term' = 'Target Language ISO 639-1 Code');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `target_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `target_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `target_language_name` SET TAGS ('dbx_business_glossary_term' = 'Target Language Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `target_language_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translator_name` SET TAGS ('dbx_business_glossary_term' = 'Translator Full Name');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translator_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translator_qualification` SET TAGS ('dbx_business_glossary_term' = 'Translator Qualification Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_type` SET TAGS ('dbx_business_glossary_term' = 'Translation Document Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `translation_type` SET TAGS ('dbx_value_regex' = 'full|summary|assent|lay_summary|amendment_only');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`translation` ALTER COLUMN `vault_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_discovered_by_employee_id` FOREIGN KEY (`discovered_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_ecm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_ecm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ADD CONSTRAINT `fk_consent_consent_deviation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` SET TAGS ('dbx_subdomain' = 'compliance_tracking');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `discovered_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Discovered By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `discovered_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `discovered_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Reconsent Trigger Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `data_integrity_impacted` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impacted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `consent_deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Deviation Description');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_number` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Number');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_number` SET TAGS ('dbx_value_regex' = '^CD-[A-Z0-9]{2,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Status');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_value_regex' = 'open|under_review|resolved|closed|escalated');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Type');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_type` SET TAGS ('dbx_value_regex' = 'consent_after_procedure|expired_icf_version|missing_witness_signature|reconsent_not_completed|capacity_assessment_missing|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `deviation_type` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `discovery_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Discovery Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Occurrence Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `pi_aware` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Aware Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `pi_awareness_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Awareness Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `reconsent_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Completed Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Reported Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'training|process|system|communication|oversight|other');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Severity');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `subject_continued_in_study` SET TAGS ('dbx_business_glossary_term' = 'Subject Continued in Study Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `subject_rights_impacted` SET TAGS ('dbx_business_glossary_term' = 'Subject Rights Impacted Flag');

ALTER TABLE `clinical_trials_ecm`.`consent`.`consent_deviation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
