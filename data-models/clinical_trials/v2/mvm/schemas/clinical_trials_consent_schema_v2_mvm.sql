-- Schema for Domain: consent | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:46

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`consent` COMMENT 'Manages the informed consent lifecycle for trial subjects. Owns ICF versions and amendments, eConsent workflows (Clinpal), subject consent status, re-consent triggers, capacity assessments, withdrawal tracking, consent audit trails, and IRB/IEC-approved';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`icf_version` (
    `icf_version_id` BIGINT COMMENT 'Unique surrogate identifier for each Informed Consent Form (ICF) version record in the consent master catalog. Primary key for this data product.',
    `approval_workflow_id` BIGINT COMMENT 'Foreign key linking to document.workflow. Business justification: ICF versions require sponsor and IRB approval workflows tracked in document management systems like Veeva Vault.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU CTR 536/2014 requires ICF versions to be authorized under a specific CTA.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: ICF versions are authored from sponsor-approved document templates. Regulatory inspectors verify that the correct, current-version template was used to create each ICF.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.country. Business justification: Multi-country trials require country-specific ICF version approvals. Regulatory authorities in each country must approve the local-language ICF before subjects can be consented.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: US IND annual reports must enumerate all ICF versions in use during the reporting period.',
    `parent_icf_version_consent_icf_version_id` BIGINT COMMENT 'Self-referencing identifier pointing to the parent ICF version from which this version was derived. Used to track amendment lineage (e.g., v1.0 → v2.0) and translation relationships (e.g., English master → Spanish translation).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Regulatory requirement (FDA 21 CFR Part 50, ICH E6) mandates ICF versions reflect the current approved protocol version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ICF version was developed and approved. Links the ICF version to its parent study context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: ICF versions are created or revised in direct response to protocol amendments (ICH E6 GCP requirement).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which this ICF version is approved and applicable. A site-specific ICF version may differ from the global master version due to local IRB/IEC requirements.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: ICF versions are essential TMF documents (DIA TMF Reference Model Zone 5). Regulatory inspectors verify ICF versions against TMF filings.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.version. Business justification: ICF versions correspond to specific document version records in the TMF system. Document version tracking (21 CFR Part 11, ICH E6 R2) requires linking the consent domain ICF version to its',
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
    `translator_name` STRING COMMENT 'Full name of the qualified translator responsible for producing this translated ICF version. Applicable only for non-master-language versions. Required for translation quality audit trail.',
    `vault_lifecycle_state` STRING COMMENT 'The document lifecycle state as managed within Veeva Vault eTMF, reflecting the document management workflow state. Distinct from the regulatory approval_status — this represents the eTMF system-level document state used for TMF completeness and. Valid values are `draft|in_review|approved|obsolete|archived`',
    `witness_signature_required` BOOLEAN COMMENT 'Indicates whether a witness signature is required on this ICF version in addition to the subject and investigator signatures (e.g., for illiterate subjects, subjects using a short form, or per local regulatory requirements).',
    CONSTRAINT pk_icf_version PRIMARY KEY(`icf_version_id`)
) COMMENT 'Master record for each version of an Informed Consent Form (ICF) used in a clinical trial, including language translations and amendment-derived versions. Tracks ICF document version number, effective date, IRB/IEC approval reference, language (ISO';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` (
    `consent_subject_consent_id` BIGINT COMMENT 'Unique surrogate identifier for the subject consent record. Primary key for the subject_consent data product in the Silver Layer lakehouse.',
    `econsent_session_id` BIGINT COMMENT 'Unique session identifier from the Clinpal eConsent platform for this consent event. Enables direct traceability back to the eConsent audit trail in Clinpal for 21 CFR Part 11 electronic signature verification.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Each subject consent must be obtained under a currently ethics-approved ICF version.',
    `icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version that was presented to and signed by the subject. Ensures traceability to the exact document version consented to.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: ICH E6(R2) requires that consenting staff have a valid, active study assignment at the time of consent.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`econsent_session` (
    `econsent_session_id` BIGINT COMMENT 'Unique surrogate identifier for each eConsent workflow session initiated in Clinpal for a trial subject. Primary key for this data product.',
    `icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version presented to the subject during this session. Ensures the correct, current consent document was used.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site at which the subject is enrolled and where this consent session is associated. Supports site-level compliance monitoring.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this eConsent session was conducted. Enables study-level consent compliance reporting.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Econsent session audit trails and e-signature records are TMF-filed under 21 CFR Part 11 and ICH E6(R2). Regulatory inspectors review econsent session records against TMF filings.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` (
    `reconsent_trigger_id` BIGINT COMMENT 'Unique surrogate identifier for each re-consent trigger record in the system. Primary key for the reconsent_trigger data product.',
    `compliance_protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Protocol deviations are a primary trigger for reconsent requirements. reconsent_trigger has protocol_deviation_raised flag but no FK to the specific deviation record.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: A reconsent trigger is raised against a specific existing consent record that needs to be superseded.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.country. Business justification: Reconsent triggers are frequently issued by country-specific regulatory authorities (health authority directives, national IRB/IEC decisions).',
    `dsmb_recommendation_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_recommendation. Business justification: DSMB recommendations with `informed_consent_update_required=true` directly mandate reconsent. Sponsors must document which DSMB recommendation drove each reconsent campaign.',
    `econsent_session_id` BIGINT COMMENT 'The session identifier from the Clinpal eConsent platform for the re-consent workflow instance. Enables traceability back to the source eConsent system for audit and SDV purposes. Nullable when paper-based consent is used.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Reconsent triggers (protocol amendments, safety events) must link to affected enrollment records to track reconsent completion status, deadline compliance, and subject continuation',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: A protocol or ICF amendment is one of the primary triggers for re-consent. reconsent_trigger has trigger_type which can be protocol_amendment and has',
    `icf_version_id` BIGINT COMMENT 'Reference to the specific Informed Consent Form (ICF) version that triggered the re-consent requirement. Identifies the new IRB/IEC-approved ICF version subjects must sign.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Operational compliance: reconsent triggers are often mandated by a new IRB/IEC approval of an amended ICF.',
    `safety_report_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.safety_report_submission. Business justification: Safety report submissions to health authorities (e.g., expedited SUSAR reports) can trigger agency-mandated reconsent when new safety information emerges.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this re-consent trigger was raised. Links the trigger to the parent study protocol context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Reference to the protocol amendment that necessitated this re-consent trigger, when the trigger type is a protocol amendment. Nullable for non-amendment triggers.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigative site at which the re-consent trigger applies. Drives site-level workflow assignment and monitoring.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: When a reconsent trigger is raised (e.g., safety letter, protocol amendment), the subjects active randomization and treatment arm assignment must be reviewed to determine',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.safety_communication. Business justification: Reconsent is formally initiated by safety communications (SUSAR notifications, urgent safety measures).',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject who must be re-consented. Nullable when the trigger applies to all subjects at a site or study level rather than a specific individual.',
    `triggering_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Regulatory submissions (e.g., agency-directed safety label updates) directly mandate reconsent.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.withdrawal. Business justification: The reconsent_trigger table tracks events that necessitate re-consent, and one possible resolution outcome is subject withdrawal.',
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
    `notes` STRING COMMENT 'Free-text field for additional operational notes, site communications, or contextual information related to this re-consent trigger that is not captured in structured fields. Supports audit trail completeness per ALCOA+ principles.',
    `previous_icf_version_number` STRING COMMENT 'The version number of the ICF that the subject had previously signed before this re-consent trigger was raised. Enables version-to-version change tracking and audit trail completeness per ALCOA+ principles.',
    `protocol_deviation_raised` BOOLEAN COMMENT 'Indicates whether a protocol deviation has been raised in the compliance system as a result of failure to re-consent within the required timeframe. When True, links to the compliance.protocol_deviation product for CAPA tracking.',
    `reconsent_completed_date` DATE COMMENT 'The actual date on which the subject was successfully re-consented and signed the updated ICF. Nullable until re-consent is completed. Used to calculate cycle time and compliance metrics.',
    `reconsent_deadline` DATE COMMENT 'The date by which re-consent must be obtained from the subject, as mandated by the IRB/IEC approval, regulatory authority, or sponsor protocol. Used to calculate overdue status and drive site escalation workflows.',
    `reconsented_subject_count` BIGINT COMMENT 'The number of subjects who have been successfully re-consented to date against this trigger. Compared against affected_subject_count to track completion progress and identify outstanding re-consents.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` (
    `capacity_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the mental capacity assessment record. Primary key for the capacity_assessment data product in the consent domain.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: A capacity assessment is performed in the context of a specific consent event to determine whether the subject can provide informed consent.',
    `econsent_session_id` BIGINT COMMENT 'Unique session identifier from the Clinpal eConsent platform associated with this capacity assessment event. Enables cross-system traceability between the capacity assessment record and the eConsent audit trail.',
    `icf_version_id` BIGINT COMMENT 'Reference to the specific IRB/IEC-approved Informed Consent Form (ICF) version in effect at the time of this capacity assessment. Ensures traceability to the correct consent document.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`withdrawal` (
    `withdrawal_id` BIGINT COMMENT 'Unique surrogate identifier for the consent withdrawal event record. Primary key for the consent_withdrawal data product in the Silver Layer lakehouse.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: A withdrawal is the formal termination of a specific consent event. The withdrawal table currently has no FK back to the consent_subject_consent record it terminates, only a',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site where the subject was enrolled and where the withdrawal is being processed.',
    `lar_representative_id` BIGINT COMMENT 'Foreign key linking to consent.lar_representative. Business justification: consent_withdrawal has lar_name (STRING) and lar_relationship (STRING) as denormalized fields for cases where a LAR initiates withdrawal on behalf of the subject.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: When a subject withdraws consent, the IRT randomization record must be cancelled.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Subject withdrawal records are essential TMF documents. The tmf_filing_status attribute on withdrawal confirms TMF filing is required.',
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
    `study_discontinuation_date` DATE COMMENT 'Date on which the subject was formally discontinued from the study following consent withdrawal. Used for Intent-to-Treat (ITT) and Per Protocol (PP) population analyses.',
    `subject_stated_reason` STRING COMMENT 'Free-text verbatim reason for withdrawal as stated by the subject or their Legally Authorized Representative (LAR). Captured to support ALCOA+ attributability and regulatory audit requirements. May contain sensitive personal context.',
    `timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the subject or their Legally Authorized Representative (LAR) formally communicated withdrawal of consent. This is the principal real-world event time per GCP requirements and ALCOA+ principles.',
    `tmf_filing_status` STRING COMMENT 'Status of the withdrawal documentation filing in the electronic Trial Master File (eTMF) in Veeva Vault: pending indicates documents are awaiting upload; filed indicates documents have been uploaded; verified indicates QC review of the filing is. Valid values are `pending|filed|verified`',
    `treatment_stop_date` DATE COMMENT 'Date on which the subjects investigational treatment was discontinued as a result of the consent withdrawal. May differ from the withdrawal_timestamp for treatment_withdrawal type.',
    `withdrawal_status` STRING COMMENT 'Current lifecycle state of the withdrawal record. pending indicates the withdrawal has been initiated but not yet formally confirmed; confirmed indicates the withdrawal is complete and binding; rescinded indicates the subject reversed the withdrawal. Valid values are `pending|confirmed|rescinded|superseded|archived`',
    `withdrawal_type` STRING COMMENT 'Categorizes the scope of the withdrawal: full_withdrawal means the subject withdraws from all study activities and data use; treatment_withdrawal means withdrawal from investigational treatment only while allowing continued data collection. Valid values are `full_withdrawal|treatment_withdrawal|data_use_withdrawal|future_sample_withdrawal`',
    CONSTRAINT pk_withdrawal PRIMARY KEY(`withdrawal_id`)
) COMMENT 'Records the formal withdrawal of informed consent by a subject or their LAR. Captures withdrawal date and time, withdrawal reason category (voluntary, AE-related, sponsor decision, lost to follow-up), subject-stated reason free text, withdrawal type (full';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`lar_representative` (
    `lar_representative_id` BIGINT COMMENT 'Unique surrogate identifier for the Legally Authorized Representative (LAR) master record in the Silver layer lakehouse. Primary key for this entity.',
    `legal_authority_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The legal authority document (power of attorney, guardianship order) authorizing the LAR must be on file in the TMF as an essential document for vulnerable subject protection.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this LAR authorization is applicable. Scopes the LAR record to a specific trial protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is enrolled and where the LAR authorization is operative.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject for whom this LAR is authorized to provide consent. Links the LAR record to the subject master.',
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
    `subject_assent_date` DATE COMMENT 'Date on which the subjects assent was obtained alongside the LARs consent. Applicable for pediatric or partially capacitated subjects. Null if assent was not required or not obtained.',
    `subject_assent_obtained` BOOLEAN COMMENT 'Indicates whether the subjects assent (agreement to participate, distinct from formal consent) was obtained in addition to the LARs consent. Applicable for pediatric subjects with developing capacity per 21 CFR 50.55.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the LAR master record. Used for change tracking, audit trail compliance, and Silver layer incremental processing.',
    `verification_date` DATE COMMENT 'Date on which the LARs identity and legal authority documentation were verified by authorized site personnel (PI or CRC). Required for GCP audit trail.',
    `verification_status` STRING COMMENT 'Status of the site staffs verification of the LARs identity and legal authority documentation. Tracks whether the CRC or PI has confirmed the LARs credentials per GCP requirements.. Valid values are `not_verified|verified|verification_failed|re_verification_required`',
    `withdrawal_date` DATE COMMENT 'Date on which the LAR withdrew their consent authorization on behalf of the subject, or the date on which the LARs authority was formally revoked. Triggers subject withdrawal workflow.',
    `withdrawal_reason` STRING COMMENT 'Free-text or coded reason for the withdrawal of the LARs consent authorization or revocation of legal authority. Required for regulatory reporting and subject safety follow-up.',
    CONSTRAINT pk_lar_representative PRIMARY KEY(`lar_representative_id`)
) COMMENT 'Master record for a Legally Authorized Representative (LAR) associated with a trial subject who lacks capacity to consent independently. Stores LAR full name, relationship to subject, contact details, legal authority documentation type and reference';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` (
    `icf_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for the ICF amendment record in the Databricks Silver Layer. Primary key for this entity.',
    `clinpal_workflow_id` BIGINT COMMENT 'The workflow identifier assigned by the Clinpal eConsent system for the re-consent or new consent workflow triggered by this amendment. Enables traceability between the amendment record and the eConsent execution.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.country. Business justification: ICF amendments have country-specific applicability and require country-level regulatory submission and approval. The existing country_code plain attribute is a denormalization of study.country.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: GCP requires that amended ICFs are only implemented after ethics committee approval.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: An ICF amendment is formally submitted to the ethics committee via an ethics_submission.',
    `icf_version_id` BIGINT COMMENT 'Reference to the new ICF version produced as a result of this amendment. Null until the amended ICF version is formally approved and issued.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IB safety updates with new risk information directly trigger ICF amendments per ICH E6 GCP.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: ICF amendments are directly triggered by protocol amendments and must reference the governing protocol version.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: ICF amendments requiring regulatory submission (regulatory_submission_required flag) are filed in regulatory binders for agency review.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments directly drive ICF amendments — when a study_protocol_amendment is approved, corresponding ICF amendments must be issued.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: ICF amendments with regulatory_submission_required=true must be filed as part of a regulatory submission.',
    `superseded_by_amendment_icf_amendment_id` BIGINT COMMENT 'Reference to the subsequent amendment that supersedes this one, if applicable. Null for the current active amendment. Enables full amendment lineage chain reconstruction for regulatory inspection.',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.safety_communication. Business justification: Safety-related ICF amendments are directly triggered by safety communications (e.g., SUSAR letters, urgent safety measures).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: ICF amendments are essential TMF documents (DIA TMF Reference Model). Regulatory inspectors verify amendments against TMF filings.',
    `affected_subject_population` STRING COMMENT 'Defines which subject population is required to undergo re-consent as a result of this amendment. Drives the re-consent workflow in Clinpal and determines the scope of CRA site monitoring activities.. Valid values are `all_enrolled|newly_enrolling_only|specific_cohort|screen_failures_only`',
    `amendment_date` DATE COMMENT 'The principal real-world date on which the amendment was formally initiated or authored. Serves as the primary business event date for the amendment lifecycle.',
    `amendment_number` STRING COMMENT 'Externally-known sequential identifier for the amendment (e.g., AM-001, AM-002). Used in regulatory submissions, IRB/IEC correspondence, and TMF filing to uniquely reference the amendment within the study.. Valid values are `^AM-[0-9]{3,6}$`',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the ICF amendment. Tracks progression from initial drafting through IRB/IEC submission, approval or rejection, and eventual supersession by a subsequent amendment.. Valid values are `draft|submitted|approved|rejected|superseded|withdrawn`',
    `amendment_type` STRING COMMENT 'Classification of the nature of change driving the amendment. Safety updates require expedited IRB/IEC review; protocol changes may require full board review; administrative corrections may qualify for expedited review.. Valid values are `safety_update|protocol_change|administrative_correction|regulatory_requirement|new_risk_information|other`',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a subject capacity or competency assessment is required before re-consent can be obtained under this amendment. Relevant for vulnerable populations, pediatric studies, or subjects with cognitive impairment.',
    `change_description` STRING COMMENT 'Detailed narrative describing the nature and rationale of the changes introduced by this amendment. Captures what was changed, why it was changed, and the impact on subject safety or study conduct.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ICF amendment record was first created in the Databricks Silver Layer. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11.',
    `deviation_risk_level` STRING COMMENT 'Risk classification assigned to the amendment indicating the potential for protocol deviations if re-consent is not completed within the required timeframe. Informs monitoring prioritization in the source system. Valid values are `critical|major|minor|not_assessed`',
    `econsent_applicable` BOOLEAN COMMENT 'Indicates whether the amended ICF will be deployed via the Clinpal eConsent platform. When True, triggers the eConsent build and validation workflow in Clinpal for the resulting ICF version.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether GDPR data privacy provisions apply to this amendment, typically for studies enrolling subjects in EU/EEA countries. When True, the amended ICF must include GDPR-compliant data processing disclosures.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether HIPAA authorization provisions apply to this amendment, typically for studies enrolling subjects at U.S. sites. When True, the amended ICF must include a HIPAA-compliant authorization section.',
    `implementation_date` DATE COMMENT 'The date from which the amended ICF version becomes effective for use at clinical sites. Sites must not use the amended ICF prior to this date. Typically set to or after the IRB/IEC approval date.',
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
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ICF amendment record was last modified in the Databricks Silver Layer. Supports change tracking, audit trail completeness, and ALCOA+ contemporaneous documentation requirements.',
    CONSTRAINT pk_icf_amendment PRIMARY KEY(`icf_amendment_id`)
) COMMENT 'Tracks amendments to an approved ICF version, capturing the amendment number, amendment date, nature of change (safety update, protocol change, administrative correction), regulatory authority requiring the amendment, IRB/IEC submission date and approval';

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_parent_icf_version_consent_icf_version_id` FOREIGN KEY (`parent_icf_version_consent_icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER SCHEMA `clinical_trials_mvm`.`consent` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`consent` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` SET TAGS ('dbx_subdomain' = 'consent_documentation');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `approval_workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Workflow Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `parent_icf_version_consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `amendment_nature_of_change` SET TAGS ('dbx_business_glossary_term' = 'Amendment Nature of Change Description');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_irb_iec|approved|superseded|withdrawn|expired');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `back_translation_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Completion Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `back_translation_status` SET TAGS ('dbx_business_glossary_term' = 'Back-Translation Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `back_translation_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|completed|failed');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `biobanking_consent_included` SET TAGS ('dbx_business_glossary_term' = 'Biobanking Consent Included Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `clinpal_consent_form_code` SET TAGS ('dbx_business_glossary_term' = 'Clinpal eConsent Form ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `consent_type` SET TAGS ('dbx_value_regex' = 'initial|re-consent|assent|lar|short_form|addendum');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `econsent_deployment_date` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Deployment Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `econsent_enabled` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Enabled Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `gdpr_data_processing_included` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Data Processing Disclosure Included Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `gdpr_data_processing_included` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8;GDPR Art.6');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `genetic_testing_consent_included` SET TAGS ('dbx_business_glossary_term' = 'Genetic Testing Consent Included Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `hipaa_authorization_included` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Authorization Included Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `hipaa_authorization_included` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.508');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `icf_title` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Title');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?[a-zA-Z]?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `icf_version_number` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `internal_review_status` SET TAGS ('dbx_value_regex' = 'in_authoring|internal_review|sponsor_approved|submitted_to_irb_iec|approved|archived');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `is_master_language` SET TAGS ('dbx_business_glossary_term' = 'Is Master Language Version Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `is_master_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code (ISO 639-1)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `lar_consent_applicable` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Consent Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `reconsent_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `translator_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|obsolete|archived');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Signature Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ALTER COLUMN `witness_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_mvm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_mvm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` SET TAGS ('dbx_subdomain' = 'consent_documentation');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Consenting Staff Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'capable|incapable|borderline|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Performed Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `comprehension_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Assessment Performed Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_standard_reference' = 'SDTM DS.DSSTDTC;ICH GCP E6(R2) 4.8.8');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'paper|econsent|remote_econsent|telephone|legally_authorized_rep');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_value_regex' = 'consented|withdrawn|re_consent_pending|expired|not_obtained');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_status` SET TAGS ('dbx_standard_reference' = 'ICH GCP E6(R2) 4.8');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consent_type` SET TAGS ('dbx_value_regex' = 'initial|re_consent|amendment|optional_procedure|genetic|long_term_followup');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `consenting_staff_role` SET TAGS ('dbx_value_regex' = 'PI|sub_investigator|CRC|delegate');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `data_use_after_withdrawal` SET TAGS ('dbx_business_glossary_term' = 'Data Use After Withdrawal Permitted Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `econsent_completion_pct` SET TAGS ('dbx_business_glossary_term' = 'eConsent Completion Percentage');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_business_glossary_term' = 'GDPR Lawful Basis for Processing');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_value_regex' = 'explicit_consent|vital_interests|public_interest|legitimate_interests|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_standard_reference' = 'GDPR Art.6');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `hipaa_authorization_obtained` SET TAGS ('dbx_business_glossary_term' = 'HIPAA Authorization Obtained Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `hipaa_authorization_obtained` SET TAGS ('dbx_standard_reference' = 'HIPAA 45 CFR 164.508');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `icf_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `lar_involved` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Involved Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Due Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_value_regex' = 'protocol_amendment|safety_update|icf_version_update|irb_requirement|regulatory_request');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `sample_use_after_withdrawal` SET TAGS ('dbx_business_glossary_term' = 'Biological Sample Use After Withdrawal Permitted Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `subject_questions_documented` SET TAGS ('dbx_business_glossary_term' = 'Subject Questions Documented Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_business_glossary_term' = 'ICF Translation Language');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `translation_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Reason');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_value_regex' = 'subject_decision|adverse_event|lost_to_followup|physician_decision|protocol_deviation|other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_signature_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ALTER COLUMN `witness_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` SET TAGS ('dbx_subdomain' = 'consent_documentation');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'capable|not-capable|not-assessed|deferred');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Performed Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `clinpal_session_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinpal Session Reference ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `communication_platform` SET TAGS ('dbx_business_glossary_term' = 'Remote Communication Platform');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Attempt Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_check_version` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Question Set Version');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `comprehension_overall_passed` SET TAGS ('dbx_business_glossary_term' = 'Comprehension Check Overall Pass Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `consent_granted` SET TAGS ('dbx_business_glossary_term' = 'Consent Granted Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `consenter_role` SET TAGS ('dbx_value_regex' = 'subject|legally-authorized-representative|parent|guardian');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `device_os` SET TAGS ('dbx_business_glossary_term' = 'Device Operating System');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `device_type` SET TAGS ('dbx_value_regex' = 'tablet|smartphone|desktop|laptop|kiosk');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `esignature_captured` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Captured Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `esignature_captured` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Capture Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_standard_reference' = '21 CFR Part 11');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `esignature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `interpreter_used` SET TAGS ('dbx_business_glossary_term' = 'Interpreter Used Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `irb_approval_ref` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) / Independent Ethics Committee (IEC) Approval Reference');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `reconsent_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Trigger Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `remediation_provided` SET TAGS ('dbx_business_glossary_term' = 'Remediation Provided Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `review_steps_total` SET TAGS ('dbx_business_glossary_term' = 'Total Review Steps');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_modality` SET TAGS ('dbx_business_glossary_term' = 'eConsent Session Modality');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_modality` SET TAGS ('dbx_value_regex' = 'in-person|remote-video|remote-phone|hybrid');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_status` SET TAGS ('dbx_business_glossary_term' = 'eConsent Session Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `session_status` SET TAGS ('dbx_value_regex' = 'in-progress|completed|abandoned|timed-out|declined');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_auth_method` SET TAGS ('dbx_business_glossary_term' = 'Subject Authentication Method');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_auth_method` SET TAGS ('dbx_value_regex' = 'password|otp-sms|otp-email|biometric|pin|site-staff-verified');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `subject_location_country` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `technical_issue_encountered` SET TAGS ('dbx_business_glossary_term' = 'Technical Issue Encountered Indicator');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `witness_esignature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Witness Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ALTER COLUMN `witness_esignature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_mvm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` SET TAGS ('dbx_subdomain' = 'subject_management');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `compliance_protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `dsmb_recommendation_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Recommendation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `econsent_session_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Session ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `safety_report_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Communication Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `triggering_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `affected_icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Affected Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'has_capacity|lacks_capacity|assessment_pending|not_required');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_method` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Method');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|verbal_with_witness|remote_electronic|legally_authorized_representative');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Notes');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `previous_icf_version_number` SET TAGS ('dbx_business_glossary_term' = 'Previous Informed Consent Form (ICF) Version Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `protocol_deviation_raised` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Raised Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Completion Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsent_deadline` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reconsented_subject_count` SET TAGS ('dbx_business_glossary_term' = 'Re-Consented Subject Count');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reminder_count` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Reminder Count');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `reminder_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Reminder Sent Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Resolution Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|waived|overdue|cancelled');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_scope` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Subject Scope');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `subject_scope` SET TAGS ('dbx_value_regex' = 'individual_subject|all_active_subjects|site_cohort|study_wide');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_description` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Description');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Reference Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_reference_number` SET TAGS ('dbx_value_regex' = '^RCT-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Type');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'protocol_amendment|new_safety_information|icf_version_update|regulatory_authority_requirement|irb_iec_requirement|other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Waiver Approval Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `waiver_justification` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Waiver Justification');

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Subject Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_econsent_session_id` FOREIGN KEY (`econsent_session_id`) REFERENCES `clinical_trials_mvm`.`consent`.`econsent_session`(`econsent_session_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_mvm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_prior_assessment_capacity_assessment_id` FOREIGN KEY (`prior_assessment_capacity_assessment_id`) REFERENCES `clinical_trials_mvm`.`consent`.`capacity_assessment`(`capacity_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` SET TAGS ('dbx_subdomain' = 'subject_management');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `capacity_assessment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `prior_assessment_capacity_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Capacity Assessment ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `prior_assessment_capacity_assessment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_value_regex' = '^CA-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Outcome');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_outcome` SET TAGS ('dbx_value_regex' = 'Capable|Incapable|Borderline|Deferred|Unable to Assess');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_score_max` SET TAGS ('dbx_business_glossary_term' = 'Assessment Score Maximum');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_setting` SET TAGS ('dbx_value_regex' = 'In-Person|Remote|Hybrid');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'Planned|In Progress|Completed|Cancelled|Superseded');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_tool` SET TAGS ('dbx_business_glossary_term' = 'Assessment Tool or Method');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Type');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'Initial|Re-Assessment|Periodic|Post-Amendment|Withdrawal');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_credentials` SET TAGS ('dbx_business_glossary_term' = 'Assessor Professional Credentials');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_business_glossary_term' = 'Assessor Full Name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assessor Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `assessor_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Assessment Comments');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `interpreter_used` SET TAGS ('dbx_business_glossary_term' = 'Interpreter Used Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `language_of_assessment` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `language_of_assessment` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `lar_required` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `outcome_basis` SET TAGS ('dbx_business_glossary_term' = 'Basis for Capacity Determination');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Due Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_trigger` SET TAGS ('dbx_business_glossary_term' = 'Re-Assessment Trigger');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `reassessment_trigger` SET TAGS ('dbx_value_regex' = 'Borderline Outcome|Change in Condition|Protocol Amendment|Regulatory Requirement|Scheduled Interval|Other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_business_glossary_term' = 'Witness Full Name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ALTER COLUMN `witness_required` SET TAGS ('dbx_business_glossary_term' = 'Witness Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_mvm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` SET TAGS ('dbx_subdomain' = 'subject_management');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Lar Representative Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Decision-Making Capacity Assessment Performed Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `capacity_assessment_performed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Comments');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `ctms_withdrawal_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Withdrawal Reference');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `data_retention_status` SET TAGS ('dbx_value_regex' = 'active|pending_review|anonymized|destroyed|retained');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `edc_subject_status_updated` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Subject Status Updated Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `initiated_by` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Initiated By');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `initiated_by` SET TAGS ('dbx_value_regex' = 'subject|lar|investigator|sponsor|regulatory_authority');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `irb_iec_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `itt_population_impact` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Impact');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `itt_population_impact` SET TAGS ('dbx_value_regex' = 'included|excluded|pending_review');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Method');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'electronic|paper|verbal|telephone');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `pi_notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notification Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `pi_notified` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notified');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `post_withdrawal_data_handling` SET TAGS ('dbx_business_glossary_term' = 'Post-Withdrawal Data Handling Instruction');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `post_withdrawal_data_handling` SET TAGS ('dbx_value_regex' = 'retain_all|retain_safety_only|destroy_all|anonymize|per_protocol');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `protocol_deviation_triggered` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Triggered Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `reason_category` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Reason Category');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `reason_category` SET TAGS ('dbx_value_regex' = 'voluntary|adverse_event_related|sponsor_decision|lost_to_follow_up|protocol_non_compliance|physician_decision');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_attempted` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Attempted Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_outcome` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Attempt Outcome');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `reconsent_outcome` SET TAGS ('dbx_value_regex' = 'successful|unsuccessful|not_attempted');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `safety_follow_up_end_date` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up End Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `safety_follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Safety Follow-Up Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `study_discontinuation_date` SET TAGS ('dbx_standard_reference' = 'SDTM DS.DSSTDTC');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_business_glossary_term' = 'Subject-Stated Withdrawal Reason');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `subject_stated_reason` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Filing Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_value_regex' = 'pending|filed|verified');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Treatment Stop Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `treatment_stop_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_status` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|rescinded|superseded|archived');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Type');

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ALTER COLUMN `withdrawal_type` SET TAGS ('dbx_value_regex' = 'full_withdrawal|treatment_withdrawal|data_use_withdrawal|future_sample_withdrawal');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` SET TAGS ('dbx_subdomain' = 'subject_management');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Representative ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Authority Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `authorization_end_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization End Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `authorization_start_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Start Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `authorization_status` SET TAGS ('dbx_value_regex' = 'active|pending_verification|suspended|revoked|expired');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Outcome');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_value_regex' = 'lacks_capacity|has_capacity|partial_capacity|reassessment_required');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_outcome` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Subject Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `ctms_lar_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) LAR Record ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `econsent_platform_record_code` SET TAGS ('dbx_business_glossary_term' = 'eConsent Platform Record ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'LAR Email Address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email;standard_reference' = 'FHIR RelatedPerson.telecom');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'LAR First Name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required for LAR Consent Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Legal Jurisdiction');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'LAR Last Name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Authority Document Issue Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `legal_authority_document_type` SET TAGS ('dbx_value_regex' = 'court_order|power_of_attorney|guardianship_certificate|parental_rights_document|healthcare_proxy|advance_directive');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Address Line 1');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Address Line 2');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing City');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_city` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Country Code');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing Postal Code');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_business_glossary_term' = 'LAR Mailing State or Province');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_pii_address;standard_reference' = 'FHIR RelatedPerson.address');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `mailing_state_province` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'LAR Middle Name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name;standard_reference' = 'FHIR RelatedPerson.name');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'LAR Record Notes');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `population_category` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Category');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `population_category` SET TAGS ('dbx_value_regex' = 'pediatric|cognitively_impaired|emergency_research|elderly_incapacitated|other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'LAR Preferred Contact Method');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|postal_mail|in_person');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'LAR Preferred Language');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `preferred_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'LAR Primary Phone Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone;standard_reference' = 'FHIR RelatedPerson.telecom');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Trigger Reason');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `re_consent_trigger_reason` SET TAGS ('dbx_value_regex' = 'protocol_amendment|new_safety_information|icf_version_update|regulatory_requirement|other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'LAR Relationship Type');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `subject_assent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Subject Assent Obtained Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Verification Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'LAR Verification Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'not_verified|verified|verification_failed|re_verification_required');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'LAR Authorization Withdrawal Reason');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_superseded_by_amendment_icf_amendment_id` FOREIGN KEY (`superseded_by_amendment_icf_amendment_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` SET TAGS ('dbx_domain' = 'consent');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` SET TAGS ('dbx_subdomain' = 'consent_documentation');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Amendment ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `clinpal_workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Clinpal eConsent Workflow ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Resulting Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `superseded_by_amendment_icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By ICF Amendment ID');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Communication Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `affected_subject_population` SET TAGS ('dbx_value_regex' = 'all_enrolled|newly_enrolling_only|specific_cohort|screen_failures_only');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^AM-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Status');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|superseded|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Type');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'safety_update|protocol_change|administrative_correction|regulatory_requirement|new_risk_information|other');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `change_description` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Change Description');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `deviation_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Risk Level');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `deviation_risk_level` SET TAGS ('dbx_value_regex' = 'critical|major|minor|not_assessed');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `econsent_applicable` SET TAGS ('dbx_business_glossary_term' = 'eConsent Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Implementation Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'ICF Language Code');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `lar_consent_applicable` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Consent Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'ICF Amendment Notes');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `reconsent_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Rejection Reason');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `requiring_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Requiring Amendment');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reviewed By');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Amendment Flag');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `site_applicability` SET TAGS ('dbx_business_glossary_term' = 'Site Applicability Scope');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `site_applicability` SET TAGS ('dbx_value_regex' = 'all_sites|specific_sites|country_specific');

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
