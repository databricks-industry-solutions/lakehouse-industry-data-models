-- Schema for Domain: regulatory | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:48

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`regulatory` COMMENT 'Manages regulatory submissions, approvals, and agency interactions across global health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Owns IND/NDA/BLA/MAA applications, clinical trial authorizations, protocol amendments, regulatory correspondence';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`submission` (
    `submission_id` BIGINT COMMENT 'Unique system-generated identifier for each regulatory submission record. Primary key for the submission data product.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Submissions (eCTD sequences) belong to a regulatory application; submission only holds application_number STRING. Add application_id FK.',
    `controlled_terminology_codelist_id` BIGINT COMMENT 'Optional CDISC CT codelist governing categorical values on this record.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this regulatory submission is made.',
    `target_health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: A submission is sent to a target health authority but only stores target_agency STRING. Normalize to health_authority FK. No reverse FK exists.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Each regulatory submission generates essential TMF documents (cover letters, agency correspondence, submission confirmations) that must be filed per ICH E6 GCP.',
    `agency_acknowledgement_number` STRING COMMENT 'Official reference number or acknowledgement identifier issued by the health authority upon receipt of the submission (e.g., FDA STN number, EMA submission number). Used for all subsequent agency correspondence.',
    `agency_action_date` DATE COMMENT 'Actual date on which the health authority issued its regulatory decision or action (approval, complete response letter, refusal to file, approvable letter, etc.). Compared against target_action_date to measure review performance.',
    `agency_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the health authority jurisdiction to which this submission is directed (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-regional submission tracking.. Valid values are `^[A-Z]{3}$`',
    `agency_decision` STRING COMMENT 'The formal regulatory decision issued by the health authority in response to this submission (e.g., approved, complete response letter (CRL), refuse to file (RTF), approvable, not approvable, withdrawn). Drives downstream regulatory strategy.',
    `agency_receipt_date` DATE COMMENT 'Date on which the health authority officially acknowledged receipt of the submission. Triggers the start of the agency review clock for PDUFA/regulatory review timelines.',
    `submission_category` STRING COMMENT 'High-level regulatory category of the submission indicating the application type: IND (Investigational New Drug), NDA (New Drug Application), BLA (Biologics License Application), MAA (Marketing Authorization Application), CTA (Clinical Trial',
    `cover_letter_title` STRING COMMENT 'The official title or subject line of the cover letter accompanying this submission, as filed with the health authority. Provides a human-readable summary of the submission purpose for regulatory correspondence tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this submission record was first created in the system of record (Veeva Vault). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_module_scope` STRING COMMENT 'Identifies which CTD module(s) are included in this submission (e.g., Module 1 - Administrative, Module 2 - Summaries, Module 3 - Quality, Module 4 - Nonclinical, Module 5 - Clinical). Supports dossier completeness tracking.',
    `dossier_format` STRING COMMENT 'Technical format of the regulatory dossier submitted to the health authority: eCTD (Electronic Common Technical Document), NeeS (Non-eCTD Electronic Submission), VNeeS (Veterinary NeeS), or paper. Determines validation and processing requirements.. Valid values are `eCTD|NeeS|paper|VNeeS`',
    `drug_product_name` STRING COMMENT 'The proprietary or non-proprietary name of the investigational drug, biologic, or device that is the subject of this regulatory submission. Provides direct product context for the submission record.',
    `ectd_operation` STRING COMMENT 'The eCTD lifecycle operation applied to documents in this submission sequence: new (first submission of a document), replace (supersedes a prior version), append (adds to an existing document), or delete (removes a document from the dossier).. Valid values are `new|replace|append|delete`',
    `filing_fee_paid` BOOLEAN COMMENT 'Indicates whether the applicable regulatory filing fee (e.g., FDA PDUFA application fee, EMA fee) has been paid for this submission. Non-payment can result in refuse-to-file action.',
    `indication` STRING COMMENT 'The specific disease, condition, or patient population for which the investigational product is being developed or for which approval is sought in this submission. Aligns with MedDRA preferred term coding.',
    `inn_name` STRING COMMENT 'The WHO-assigned International Nonproprietary Name (INN) for the active substance that is the subject of this submission. Provides standardized global drug identification aligned with WHO-DD.',
    `is_expedited` BOOLEAN COMMENT 'Indicates whether this submission is subject to an expedited review pathway (e.g., FDA Breakthrough Therapy, Priority Review, Accelerated Approval, EMA PRIME scheme). Drives prioritization in regulatory operations workflows.',
    `is_resubmission` BOOLEAN COMMENT 'Indicates whether this submission is a resubmission following a prior agency rejection, complete response letter (CRL), or refuse-to-file (RTF) action. Triggers specific regulatory review timelines under PDUFA.',
    `method` STRING COMMENT 'The technical method by which the submission was delivered to the health authority (e.g., electronic gateway such as FDA ESG or EMA eSubmission Gateway, physical media, agency portal, email, or paper).. Valid values are `electronic_gateway|physical_media|portal|email|paper`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, internal commentary, or regulatory strategy notes associated with this submission event. Not transmitted to the agency; for internal regulatory operations use only.',
    `number` STRING COMMENT 'Externally-known unique identifier for this submission as assigned by the health authority or internal tracking system (e.g., IND number, NDA number, sequence number within an eCTD dossier). Used for cross-referencing with agency correspondence.',
    `phase` STRING COMMENT 'The clinical development phase associated with this submission (e.g., Phase 1, Phase 2, Phase 3, Phase 4, pre-IND, post-approval). Contextualizes the submission within the drug development lifecycle.',
    `reason` STRING COMMENT 'Narrative or coded reason for this submission event (e.g., initial IND filing, protocol amendment for safety update, response to FDA information request, annual IND report, post-approval labeling change).',
    `regulatory_procedure_type` STRING COMMENT 'Specific regulatory procedure under which this submission is filed (e.g., standard review, priority review, accelerated approval, breakthrough therapy, orphan drug, centralized procedure, mutual recognition procedure, decentralized procedure).',
    `resubmission_class` STRING COMMENT 'For FDA resubmissions following a complete response letter (CRL), the classification of the resubmission: Class 1 (2-month review goal) or Class 2 (6-month review goal), based on the nature of the response. Null or not_applicable for non-resubmissions.. Valid values are `class_1|class_2|not_applicable`',
    `sequence_number` STRING COMMENT 'Four-digit zero-padded sequence number identifying the specific eCTD submission sequence within a dossier lifecycle (e.g., 0000 for initial submission, 0001 for first amendment). Conforms to ICH M8 eCTD specification.. Valid values are `^[0-9]{4}$`',
    `submission_date` DATE COMMENT 'The actual calendar date on which the submission was transmitted or delivered to the target health authority. This is the principal real-world event date for regulatory timeline calculations and compliance tracking.',
    `submission_status` STRING COMMENT 'Current lifecycle state of the submission: draft (being prepared), pending (awaiting dispatch), submitted (sent to agency), validated (passed technical validation), accepted (agency acknowledged receipt), rejected (agency refused), or withdrawn (sponsor',
    `submission_type` STRING COMMENT 'Classification of the submission event in the dossier lifecycle: original (first submission), amendment (change to an approved application), supplement (post-approval change), response (reply to agency query or complete response letter), or withdrawal. Valid values are `original|amendment|supplement|response|withdrawal`',
    `target_action_date` DATE COMMENT 'The regulatory deadline by which the health authority is expected to take action on the submission (e.g., PDUFA goal date for FDA NDA/BLA reviews, EMA opinion deadline). Critical for regulatory milestone tracking and resource planning.',
    `therapeutic_area` STRING COMMENT 'The clinical or disease area that the investigational product targets (e.g., oncology, cardiology, neurology, infectious disease, rare disease). Used for portfolio analytics and regulatory strategy segmentation.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone) at which the submission was electronically transmitted to the health authority gateway. Used for exact regulatory deadline compliance and audit trail purposes per 21 CFR Part 11.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this submission record was most recently modified in the system of record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `validation_status` STRING COMMENT 'Technical validation outcome of the eCTD dossier package against agency-published validation criteria (e.g., FDA eCTD Validation Criteria, EMA eCTD Specification).. Valid values are `not_validated|passed|failed|waived`',
    `veeva_vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault (eTMF/Regulatory Submissions module) to the submission package or primary dossier document. Enables direct traceability to the source system of record.',
    CONSTRAINT pk_submission PRIMARY KEY(`submission_id`)
) COMMENT 'Master record for regulatory submissions and eCTD sequences sent to health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Each record represents a discrete submission event with sequence number, submission type (original, amendment, supplement';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`application` (
    `application_id` BIGINT COMMENT 'Unique surrogate identifier for the regulatory application record in the lakehouse silver layer. Primary key for all downstream joins to submissions, correspondence, approvals, and commitments under this dossier.',
    `lead_agency_health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: application is a master regulatory application filed with a lead health authority but has only a lead_agency STRING, no FK. Normalize to health_authority.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — regulatory applications are submitted for specific studies',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory applications (IND, NDA, BLA lifecycle) generate TMF-essential documents including approval letters, complete response letters, and application correspondence filed in TMF',
    `accelerated_approval` BOOLEAN COMMENT 'Indicates whether this application is approved or being reviewed under the FDA Accelerated Approval pathway, based on a surrogate or intermediate clinical endpoint reasonably likely to predict clinical benefit. Requires post-approval confirmatory trials.',
    `agency_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the health authority jurisdiction (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-regional dossier tracking and jurisdiction-specific compliance reporting.. Valid values are `^[A-Z]{3}$`',
    `agency_receipt_date` DATE COMMENT 'Date the health authority officially acknowledged receipt of the application. May differ from initial_filing_date if the agency issues a receipt acknowledgment letter after a validation check.',
    `annual_report_last_submitted_date` DATE COMMENT 'Date the most recent IND Annual Report was submitted to FDA. Used to calculate the next due date and to confirm compliance with 21 CFR 312.33 annual reporting obligations.',
    `application_status` STRING COMMENT 'Current lifecycle status of the regulatory application. active = application is open and under review or in use; approved = marketing authorization or IND in good standing with approval; withdrawn = sponsor voluntarily withdrew; refused = agency. Valid values are `active|approved|withdrawn|refused|on_clinical_hold|inactive`',
    `application_type` STRING COMMENT 'Classification of the regulatory application by submission type. IND = Investigational New Drug; NDA = New Drug Application; BLA = Biologics License Application; MAA = Marketing Authorization Application; CTA = Clinical Trial Authorization; IMPD =. Valid values are `IND|NDA|BLA|MAA|CTA|IMPD`',
    `approval_date` DATE COMMENT 'Date on which the health authority granted marketing authorization or IND approval. Null for applications that have not yet been approved. Critical milestone for commercial launch planning and post-approval commitment tracking.',
    `breakthrough_therapy` BOOLEAN COMMENT 'Indicates whether FDA has granted Breakthrough Therapy Designation (BTD) for this application, enabling intensive FDA guidance and rolling review. Granted when preliminary clinical evidence shows substantial improvement over available therapy for serious',
    `clinical_hold_date` DATE COMMENT 'Date on which the FDA issued the clinical hold order for this application. Null if no clinical hold has been imposed. Used to track hold duration and response timelines.',
    `clinical_hold_status` STRING COMMENT 'Current clinical hold status issued by FDA under 21 CFR 312.42. none = no hold; partial = hold on specific studies or patient populations; full = all clinical investigations halted; lifted = hold previously issued but now removed.. Valid values are `none|partial|full|lifted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory application record was first created in the lakehouse silver layer. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctd_module` STRING COMMENT 'Indicates which CTD modules are included in this application. M1=Regional Administrative; M2=Summaries; M3=Quality; M4=Nonclinical; M5=Clinical. full indicates all modules are present. Supports dossier completeness tracking.. Valid values are `M1|M2|M3|M4|M5|full`',
    `dossier_language` STRING COMMENT 'ISO 639-2 three-letter language code of the primary language in which the regulatory dossier is submitted (e.g., ENG for English, JPN for Japanese, DEU for German). Relevant for multi-regional submissions requiring translation.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date the application became legally effective and binding. For INDs, this is 30 days after FDA receipt unless a clinical hold is issued. For approved applications, this is the date the approval letter takes effect.',
    `expiry_date` DATE COMMENT 'Date on which the application or authorization expires, if applicable. Relevant for CTAs with fixed authorization periods and some national approvals. Null for open-ended authorizations such as US NDA/BLA approvals.',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether FDA has granted Fast Track Designation for this application, facilitating development and expediting review of drugs to treat serious conditions and fill unmet medical needs. Enables rolling review and more frequent FDA interactions.',
    `ind_annual_report_due_date` DATE COMMENT 'Next due date for the IND Annual Report submission to FDA, calculated as 60 days before the anniversary of the IND effective date. Tracks compliance with mandatory annual reporting obligations.',
    `ind_number` STRING COMMENT 'FDA-assigned IND serial number for investigational applications (e.g., IND 123456). Populated only for IND-type applications. Used in all FDA correspondence, annual reports, and safety reporting.',
    `ind_type` STRING COMMENT 'Subclassification of the IND by purpose. Commercial IND is sponsor-held for drug development; Research IND is investigator-initiated; Treatment IND allows expanded access; Emergency IND is for single-patient emergency use.. Valid values are `commercial|research|treatment|emergency`',
    `initial_filing_date` DATE COMMENT 'Date the application was first submitted to the health authority. For INDs, this is the date the IND package was received by FDA. For NDAs/BLAs, this is the date of original submission. This is the principal BUSINESS_EVENT_TIMESTAMP for this entity.',
    `lifecycle_phase` STRING COMMENT 'Current development phase associated with this regulatory application. Tracks the application from pre-IND through post-approval lifecycle. Supports portfolio planning and regulatory strategy alignment.',
    `notes` STRING COMMENT 'Free-text field for capturing additional regulatory context, strategic notes, or agency-specific instructions not captured in structured fields. Used by regulatory affairs teams for internal documentation.',
    `number` STRING COMMENT 'Externally assigned application number issued by the health authority (e.g., IND 123456, NDA 210001, BLA 761234, EMA/H/C/004321, CTA-2024-001). This is the official dossier identifier used in all agency correspondence and is the BUSINESS_IDENTIFIER for',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the FDA Office of Orphan Products Development (OOPD) or EMA Committee for Orphan Medicinal Products (COMP) has granted Orphan Drug Designation for this application. Confers 7-year market exclusivity (FDA) or 10-year (EMA) and fee waivers.',
    `pdufa_goal_date` DATE COMMENT 'FDA-assigned PDUFA action date by which the agency commits to completing its review of an NDA or BLA. Applicable only to marketing applications under PDUFA. Drives internal milestone planning and commercial readiness timelines.',
    `priority_review` BOOLEAN COMMENT 'Indicates whether the FDA has granted Priority Review designation to this NDA or BLA, reducing the standard review clock from 12 months to 6 months. Applicable to drugs offering major advances in treatment or providing treatment where no adequate therapy',
    `product_name` STRING COMMENT 'Name of the drug, biologic, or device covered by this application. May be the INN (International Nonproprietary Name), proprietary brand name, or code name at the investigational stage.',
    `product_type` STRING COMMENT 'Classification of the investigational or approved product by modality. Determines the applicable regulatory pathway, CMC requirements, and review division assignment at the agency.. Valid values are `small_molecule|biologic|gene_therapy|cell_therapy|medical_device|combination`',
    `rolling_review` BOOLEAN COMMENT 'Indicates whether the health authority has granted rolling review, allowing submission and review of completed sections of the dossier before the full application is submitted. Applicable under FDA Fast Track and EMA PRIME/rolling review procedures.',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this application.',
    `submission_format` STRING COMMENT 'Technical format used for dossier submission to the health authority. eCTD (Electronic Common Technical Document) is the standard for FDA, EMA, PMDA; NeeS (Non-eCTD Electronic Submission) is a transitional format; paper submissions are legacy.. Valid values are `eCTD|NeeS|paper|eCTD_v4`',
    `subtype` STRING COMMENT 'Further classification within the application type. Examples for IND: Commercial, Research, Treatment, Emergency; for NDA: 505(b)(1) Full, 505(b)(2), 505(j) ANDA; for BLA: Original, Supplement, Efficacy Supplement.',
    `therapeutic_area` STRING COMMENT 'Broad disease or medical specialty area covered by the application (e.g., Oncology, Cardiology, Neurology, Infectious Disease, Immunology). Used for portfolio segmentation, resource allocation, and regulatory strategy reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory application record was most recently modified. Supports change tracking, data lineage, and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_dossier_reference` STRING COMMENT 'Cross-reference identifier linking this application record to the corresponding eTMF/regulatory dossier in Veeva Vault (the system of record for regulatory submissions and document management).',
    CONSTRAINT pk_application PRIMARY KEY(`application_id`)
) COMMENT 'Master record for regulatory applications (IND, NDA, BLA, MAA, CTA, IMPD) filed with health authorities. Tracks application number, application type and subtype, therapeutic area, indication, sponsor reference, lead agency, application status (active';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` (
    `health_authority_id` BIGINT COMMENT 'Unique surrogate identifier for the health authority record in the regulatory reference master. Primary key for all downstream FK references across submission, application, correspondence, and authorization records.',
    `acronym` STRING COMMENT 'Widely recognized abbreviation for the health authority (e.g., FDA, EMA, PMDA, MHRA, TGA, HC). Used in reporting dashboards, regulatory tracking systems, and internal communications.. Valid values are `^[A-Z]{2,10}$`',
    `agency_code` STRING COMMENT 'Short, standardized alphanumeric code uniquely identifying the health authority (e.g., FDA, EMA, PMDA, MHRA, HC, TGA, ANVISA, NMPA). Used as a business key in regulatory workflows, submission routing, and eCTD gateway configuration.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `agency_status` STRING COMMENT 'Current operational lifecycle status of the health authority record. Active indicates the agency is currently accepting submissions; inactive indicates it is no longer operational; merged indicates it has been absorbed into another agency; superseded. Valid values are `active|inactive|merged|superseded`',
    `annual_safety_report_type` STRING COMMENT 'Type of periodic safety report required by this health authority for ongoing clinical trials (e.g., DSUR - Development Safety Update Report per ICH E2F for EMA/MHRA, IND Annual Report per 21 CFR 312.33 for FDA, PBRER for post-marketing).. Valid values are `DSUR|PSUR|IND_Annual|PBRER|other`',
    `authority_type` STRING COMMENT 'Classification of the health authority by its jurisdictional scope: national (single country, e.g., FDA, PMDA), supranational (multi-country, e.g., EMA), regional (sub-national or regional body), or reference_agency (recognized reference authority used by. Valid values are `national|supranational|regional|reference_agency`',
    `clinical_trial_registry_required` BOOLEAN COMMENT 'Indicates whether the health authority requires mandatory registration of clinical trials in a public registry (e.g., ClinicalTrials.gov for FDA, EU Clinical Trials Register for EMA, JAPIC for PMDA) as a condition of authorization or publication.',
    `contact_division_name` STRING COMMENT 'Name of the primary regulatory division or office within the health authority responsible for receiving submissions and correspondence for the sponsors therapeutic area (e.g., FDA CDER Office of New Drugs, EMA Human Medicines Division, PMDA New Drug',
    `contact_email` STRING COMMENT 'Official email address for regulatory correspondence with the health authoritys primary contact division. Used for submission cover letter addressing, meeting request submissions, and regulatory query responses.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Official telephone number for the health authoritys primary regulatory contact division. Used for urgent regulatory communications, inspection notifications, and meeting coordination.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this health authority record was first created in the regulatory reference master. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles for regulatory data.',
    `ctd_format_required` BOOLEAN COMMENT 'Indicates whether the health authority mandates submission of dossiers in the ICH Common Technical Document (CTD) format. True for ICH member agencies (FDA, EMA, PMDA, MHRA, Health Canada); may be false for non-ICH jurisdictions with proprietary',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy legislation or framework applicable to clinical trial data collected under this health authoritys jurisdiction (e.g., GDPR for EMA/MHRA, HIPAA for FDA, PIPEDA for Health Canada, APPI for PMDA).',
    `ectd_gateway_code` STRING COMMENT 'Unique identifier assigned to the health authoritys eCTD submission gateway endpoint (e.g., FDA ESG sender ID, EMA DUNS number for eSubmission). Required for configuring automated eCTD transmission via Veeva Vault and validating submission',
    `ectd_specification_version` STRING COMMENT 'Version of the eCTD technical specification required by this health authority for electronic submissions (e.g., 3.2.2, 4.0). Governs the XML backbone structure, validation criteria, and submission package format for IND, NDA, BLA, and MAA applications.',
    `effective_from_date` DATE COMMENT 'Date from which this health authority record is considered valid and active for use in regulatory submissions and correspondence. Supports temporal validity tracking for agencies that have been established, reorganized, or renamed.',
    `electronic_submission_required` BOOLEAN COMMENT 'Indicates whether the health authority mandates electronic submission (eCTD or equivalent) for regulatory applications. True for FDA, EMA, PMDA, MHRA; may be false for agencies still accepting paper or hybrid submissions.',
    `fee_schedule_effective_date` DATE COMMENT 'Date from which the current regulatory fee schedule for this health authority is effective. Fee schedules are typically updated annually (e.g., FDA PDUFA fees effective October 1 each fiscal year).',
    `full_name` STRING COMMENT 'Official full name of the health authority.',
    `gcp_guideline_version` STRING COMMENT 'Version of the GCP guideline mandated or recognized by this health authority (e.g., ICH E6(R2), ICH E6(R3), EU CTR GCP Annex). Governs clinical trial conduct standards, monitoring requirements, and inspection readiness criteria applicable to studies',
    `ich_member` BOOLEAN COMMENT 'Indicates whether the health authority is a full member or observer of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH).',
    `ind_application_type` STRING COMMENT 'Local equivalent application type for initiating clinical trials under this health authoritys jurisdiction (e.g., IND for FDA, CTA for EMA/MHRA/Health Canada, JIND for PMDA, CTN for TGA).',
    `ind_review_clock_days` BIGINT COMMENT 'Number of calendar days the health authority has to review and respond to a clinical trial authorization application before the sponsor may proceed (e.g., 30 days for FDA IND, 30 days for EMA CTA under EU CTR).',
    `ind_submission_fee_amount` DECIMAL(18,2) COMMENT 'Standard regulatory fee amount charged by this health authority for an IND or CTA application in the currency specified by submission_fee_currency. May be zero for agencies that do not charge IND/CTA fees (e.g., FDA does not charge IND fees).',
    `inspection_authority` BOOLEAN COMMENT 'Indicates whether this health authority has the mandate and capability to conduct Good Clinical Practice (GCP) inspections of clinical trial sites, sponsors, and CROs. True for FDA, EMA (via national competent authorities), MHRA, PMDA.',
    `local_language_required` BOOLEAN COMMENT 'Indicates whether the health authority requires submission documents (or portions thereof) to be translated into the local national language in addition to English. True for agencies such as PMDA (Japanese), NMPA (Chinese), ANVISA (Portuguese).',
    `mailing_address` STRING COMMENT 'Postal address for correspondence with the health authority.',
    `mutual_recognition_agreements` STRING COMMENT 'Comma-separated list of mutual recognition agreement frameworks in which this health authority participates (e.g., FDA-EMA Parallel Scientific Advice, MHRA-EMA MRA, ACSS - Australia-Canada-Singapore-Switzerland).',
    `nda_application_type` STRING COMMENT 'Local equivalent marketing authorization application type for this health authority (e.g., NDA/BLA for FDA, MAA for EMA, J-NDA for PMDA, ANDS for Health Canada).',
    `nda_submission_fee_amount` DECIMAL(18,2) COMMENT 'Standard regulatory submission fee amount charged by this health authority for a full marketing authorization application (NDA/BLA/MAA) in the currency specified by submission_fee_currency.',
    `non_fatal_sadr_reporting_clock_hours` BIGINT COMMENT 'Mandatory expedited safety reporting timeline in hours for non-fatal, non-life-threatening SUSARs to this health authority (e.g., 15 calendar days / 360 hours for FDA and EMA).',
    `notes` STRING COMMENT 'Free-text field for regulatory affairs teams to capture additional context, special submission requirements, known agency preferences, or recent regulatory guidance updates specific to this health authority that are not captured in structured fields.',
    `paper_submission_accepted` BOOLEAN COMMENT 'Indicates whether the health authority still accepts paper-based regulatory submissions as an alternative or supplement to electronic submissions. Relevant for agencies in transition to full eCTD mandates or for specific submission types (e.g., original',
    `priority_review_clock_days` BIGINT COMMENT 'Number of calendar days in the expedited or priority review clock for marketing authorization applications under this health authority (e.g., 180 days for FDA priority NDA review, 150 days for EMA accelerated assessment).',
    `region_name` STRING COMMENT 'Geopolitical or regulatory region associated with the health authority (e.g., North America, European Union, Asia-Pacific, Latin America, Middle East & Africa). Supports regional regulatory strategy grouping and multi-regional submission planning.',
    `regulatory_framework` STRING COMMENT 'Primary regulatory framework or legislation governing the health authoritys operations (e.g., 21 CFR Parts 312/314/601 for FDA, EU CTR 536/2014 for EMA, PMDA Act for Japan, Medicines Act for MHRA).',
    `review_procedure_type` STRING COMMENT 'Primary review procedure applicable under this health authority (e.g., Standard Review, Priority Review, Accelerated Assessment, Breakthrough Therapy, PRIME, Conditional Approval, Orphan Drug). Determines review timelines and regulatory strategy.',
    `sadr_reporting_clock_hours` BIGINT COMMENT 'Mandatory expedited safety reporting timeline in hours for fatal or life-threatening SUSARs to this health authority (e.g., 7 calendar days / 168 hours for FDA, 7 days for EMA).',
    `standard_review_clock_days` BIGINT COMMENT 'Number of calendar days in the standard regulatory review clock for marketing authorization applications under this health authority (e.g., 365 days for FDA standard NDA review, 210 days for EMA MAA).',
    `submission_fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code for regulatory submission fees charged by this health authority (e.g., USD for FDA PDUFA fees, EUR for EMA fees, JPY for PMDA fees).. Valid values are `^[A-Z]{3}$`',
    `submission_language` STRING COMMENT 'ISO 639 language code(s) required for regulatory submissions to this health authority (e.g., en for English, ja for Japanese, zh for Chinese, de/fr/it for Switzerland).. Valid values are `^[a-z]{2,3}(-[A-Z]{2,3})?$`',
    `submission_portal_url` STRING COMMENT 'Official URL of the health authoritys electronic submission portal (e.g., FDA ESG gateway, EMA eSubmission portal, PMDA eCTD gateway). Used by regulatory affairs teams to route eCTD dossier submissions and track submission acknowledgements.. Valid values are `^https?://.+$`',
    `trial_registry_name` STRING COMMENT 'Name of the primary public clinical trial registry mandated by this health authority for trial registration (e.g., ClinicalTrials.gov for FDA, EU Clinical Trials Register for EMA, JAPIC CTI for PMDA, ANZCTR for TGA).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this health authority record was most recently modified. Supports change tracking, data lineage, and audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_health_authority PRIMARY KEY(`health_authority_id`)
) COMMENT 'Reference master for global health authority organizations (FDA, EMA, PMDA, MHRA, Health Canada, TGA, ANVISA, NMPA, etc.). Stores agency code, full name, country/region, regulatory framework, submission portal URL, eCTD gateway identifier, contact';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` (
    `submission_sequence_id` BIGINT COMMENT 'Unique surrogate identifier for each eCTD submission sequence record within the regulatory application dossier.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND, NDA, BLA, MAA, CTA) to which this submission sequence belongs.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Each eCTD submission sequence is sent to a specific health authority. The regulatory_authority_code and submission_country_code STRING fields on submission_sequence are',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Each eCTD submission sequence is packaged as a regulatory binder. Regulatory publishing teams build a binder per sequence; linking submission_sequence to regulatory_binder enables',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this submission sequence, where the sequence relates to a specific study (e.g., a clinical study report submission). Null for application-level sequences not tied to a single study.',
    `veeva_vault_submission_id` BIGINT COMMENT 'External identifier of this submission sequence record within Veeva Vault RIM Submissions module, the system of record for regulatory dossier management. Enables cross-system traceability between the lakehouse silver layer and the operational eTMF/RIM',
    `agency_acknowledgement_number` STRING COMMENT 'Official confirmation or acknowledgement number issued by the regulatory authority upon receipt of the submission sequence (e.g., FDA ESG acknowledgement ID, EMA CESP submission ID). Used for tracking and correspondence reference.',
    `agency_action_date` DATE COMMENT 'Date on which the regulatory authority issued a formal action or decision on this submission sequence (e.g., approval letter, complete response letter, refuse-to-file letter, Day 120 list of questions). Null if no action has been issued.',
    `agency_action_type` STRING COMMENT 'Type of formal regulatory action issued by the agency in response to this submission sequence. Drives downstream regulatory strategy and response planning.. Valid values are `approval|complete_response|refuse_to_file|information_request|withdrawal_accepted|no_action`',
    `agency_receipt_date` DATE COMMENT 'The date on which the regulatory authority officially acknowledged receipt of this submission sequence. Triggers the start of the agency review clock (e.g., PDUFA clock for FDA, Day 0 for EMA).',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this submission sequence reflecting the sensitivity of the dossier content. Governs access controls within Veeva Vault and the lakehouse. highly_confidential applies to trade secret CMC data.. Valid values are `public|restricted|confidential|highly_confidential`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this submission sequence record was first created in the system, supporting audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctd_module_scope` STRING COMMENT 'Identifies which CTD module(s) are primarily affected by this submission sequence. Module 1: Administrative/Regional; Module 2: Summaries; Module 3: Quality; Module 4: Nonclinical; Module 5: Clinical. multiple indicates cross-module content.. Valid values are `module_1|module_2|module_3|module_4|module_5|multiple`',
    `ctd_section_list` STRING COMMENT 'Comma-delimited list of specific CTD section identifiers (e.g., 3.2.P.1, 3.2.P.2, 5.3.5.1) included or modified in this submission sequence. Enables granular tracking of which dossier sections evolved with each sequence.',
    `document_count` BIGINT COMMENT 'Total number of documents included in this eCTD submission sequence package. Supports completeness verification and dossier audit.',
    `dossier_package_name` STRING COMMENT 'Human-readable name or label assigned to the eCTD submission package for this sequence (e.g., NDA 123456 Seq 0012 — CMC Amendment). Used for identification in Veeva Vault and internal tracking systems.',
    `dossier_package_size_mb` DECIMAL(10,2) COMMENT 'Total file size in megabytes of the eCTD submission package for this sequence. Used for submission gateway capacity planning and agency file size compliance checks.',
    `ectd_operation` STRING COMMENT 'Specifies the eCTD XML backbone lifecycle operation applied to documents in this sequence. new adds documents for the first time; replace supersedes a prior document; append adds to an existing document set; delete removes a document from the. Valid values are `new|replace|append|delete`',
    `ectd_validation_date` DATE COMMENT 'Date on which the eCTD technical validation was performed for this submission sequence. Used to confirm validation was completed prior to submission deadline.',
    `ectd_validation_error_count` BIGINT COMMENT 'Total number of technical validation errors identified during eCTD validation of this submission sequence. A value of zero is required for a passing validation status.',
    `ectd_validation_status` STRING COMMENT 'Result of the eCTD technical validation check performed against the agencys published validation criteria prior to or upon submission. pass indicates full conformance; warning indicates non-critical issues; fail indicates the sequence was rejected. Valid values are `pass|fail|warning|pending`',
    `ectd_validation_tool` STRING COMMENT 'Name and version of the eCTD validation software used to validate this submission sequence (e.g., Lorenz docuBridge v5.2, Extedo eCTD Manager v8.1, Veeva Vault RIM Submissions v23.1). Required for audit trail and reproducibility.',
    `ectd_validation_warning_count` BIGINT COMMENT 'Total number of non-critical technical validation warnings identified during eCTD validation of this submission sequence. Warnings do not block submission but must be reviewed and justified.',
    `is_expedited` BOOLEAN COMMENT 'Indicates whether this submission sequence qualifies for or was filed under an expedited regulatory pathway (e.g., FDA Fast Track, Breakthrough Therapy, Priority Review; EMA PRIME). True if expedited designation applies.',
    `is_safety_related` BOOLEAN COMMENT 'Indicates whether this submission sequence contains or is primarily driven by safety-related content (e.g., IND Safety Report, SUSAR narrative, labeling safety update, DSUR). True if safety content is the primary driver.',
    `response_due_date` DATE COMMENT 'Deadline by which the sponsor must submit a response to an agency information request or complete response letter associated with this submission sequence. Null if no response is required.',
    `review_clock_start_date` DATE COMMENT 'Date on which the regulatory authoritys formal review clock begins for this submission sequence (e.g., PDUFA Day 1 for FDA, Day 0 for EMA). Derived from agency acknowledgement and used for PDUFA/review deadline tracking.',
    `review_clock_target_date` DATE COMMENT 'Target date by which the regulatory authority is expected to complete review of this submission sequence, calculated from the review clock start date per applicable PDUFA or EMA timelines. Critical for regulatory milestone planning.',
    `sequence_number` STRING COMMENT 'Four-digit zero-padded sequence number uniquely identifying this submission within the regulatory application lifecycle (e.g., 0000 for original, 0001 for first amendment).. Valid values are `^[0-9]{4}$`',
    `submission_subtype` STRING COMMENT 'Further classification of the submission type providing regulatory-specific granularity (e.g., Prior Approval Supplement, Changes Being Effected, Complete Response, Major Amendment, Minor Amendment).',
    `submission_unit` STRING COMMENT 'The specific regulatory submission unit or grouping within the eCTD backbone that this sequence belongs to (e.g., IND Safety Report, NDA Module 5 Clinical Study Report, BLA CMC Supplement). Aligns with Veeva Vault RIM submission unit taxonomy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this submission sequence record, supporting audit trail and data lineage requirements under 21 CFR Part 11 and ALCOA+.',
    CONSTRAINT pk_submission_sequence PRIMARY KEY(`submission_sequence_id`)
) COMMENT 'Tracks individual eCTD submission sequences within a regulatory application. Each sequence has a sequence number, submission type (original, amendment, supplement, response, withdrawal), sequence date, eCTD lifecycle operation (new, replace, append';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` (
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for the protocol amendment record in the regulatory domain. Primary key for this entity.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Protocol amendments are submitted to specific health authorities and ethics committees.',
    `parent_application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND/NDA/BLA/MAA/CTA) under which this protocol amendment is filed.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific study protocol document that this amendment modifies.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this protocol amendment belongs.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Protocol amendments are submitted to health authorities as part of regulatory submissions (eCTD sequences).',
    `submission_sequence_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission_sequence. Business justification: A protocol amendment is submitted as a specific eCTD sequence. The ectd_sequence_number STRING on regulatory_protocol_amendment is a denormalized reference.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Protocol amendments are essential TMF documents per ICH E6 (TMF Zone 4, Section 4.1) requiring version-controlled filing.',
    `affected_sections` STRING COMMENT 'Comma-delimited list or narrative description of the specific protocol sections modified by this amendment (e.g., Section 4.1 Inclusion Criteria, Section 6.2 Dosing Schedule). Supports impact assessment and site notification planning.',
    `agency_acknowledgment_date` DATE COMMENT 'Date on which the health authority formally acknowledged receipt of the protocol amendment submission. Initiates the regulatory review period clock per applicable regulations.',
    `agency_approval_date` DATE COMMENT 'Date on which the health authority granted formal approval or no-objection for the protocol amendment. For non-substantial amendments, this may be the date of implicit approval after the notification period.',
    `agency_response_comments` STRING COMMENT 'Summary of conditions, queries, or comments provided by the health authority in their formal response to the amendment submission. Drives follow-up actions and response preparation.',
    `agency_response_date` DATE COMMENT 'Date on which the formal response (approval, rejection, clinical hold, information request) was received from the health authority.',
    `agency_response_type` STRING COMMENT 'Type of formal response received from the health authority regarding the amendment submission. [ENUM-REF-CANDIDATE: approved|approved_with_conditions|clinical_hold|information_requested|rejected|no_objection|withdrawn — promote to reference product]',
    `amendment_date` DATE COMMENT 'Date on which the protocol amendment document was finalized and signed off internally, prior to regulatory submission. Represents the official amendment authoring date per ALCOA+ principles.',
    `amendment_number` STRING COMMENT 'Sequential identifier for the amendment within the study protocol (e.g., AM-001, AM-002). Used to track the version history of protocol changes and referenced in regulatory submissions.. Valid values are `^[A-Z]{0,3}-?d{1,4}$`',
    `amendment_rationale` STRING COMMENT 'Detailed scientific, safety, or operational justification for the protocol amendment as documented in the amendment cover letter and regulatory submission package. Required by health authorities to assess the necessity and appropriateness of the change.',
    `amendment_status` STRING COMMENT 'Current lifecycle status of the protocol amendment across all regulatory and ethics review processes. Drives workflow routing in Veeva Vault and the source system',
    `amendment_title` STRING COMMENT 'Short descriptive title summarizing the primary purpose or scope of the protocol amendment (e.g., Addition of New Biomarker Assessments, Dose Escalation Cohort Expansion).',
    `amendment_type` STRING COMMENT 'Classification of the amendment per regulatory definitions: substantial (requires prior regulatory/ethics approval), non-substantial (notification only), administrative (clerical corrections), or urgent_safety (immediate safety measure).. Valid values are `substantial|non_substantial|administrative|urgent_safety`',
    `amendment_version` STRING COMMENT 'Version label of the amended protocol document (e.g., v2.0, v3.1) as tracked in Veeva Vault regulatory binder. Distinct from amendment number — version reflects the resulting protocol document version after the amendment is applied.',
    `change_summary` STRING COMMENT 'Concise narrative summary of all changes introduced by this amendment, including additions, deletions, and modifications to protocol text. Included in the amendment cover letter submitted to health authorities and IRB/IEC.',
    `clinical_hold_flag` BOOLEAN COMMENT 'Indicates whether the health authority has placed a clinical hold on the study as a result of this amendment submission or related safety concerns. A clinical hold suspends enrollment and/or ongoing study conduct.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this protocol amendment record was first created in the system, supporting audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `dsmb_notification_required_flag` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) must be notified of this protocol amendment, typically required for amendments affecting safety monitoring, stopping rules, or interim analysis plans.',
    `ethics_approval_date` DATE COMMENT 'Date on which the IRB/IEC granted approval for the protocol amendment. Required before implementation at sites under the jurisdiction of that ethics committee.',
    `ethics_submission_date` DATE COMMENT 'Date on which the protocol amendment was submitted to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) for review and approval.',
    `global_submission_flag` BOOLEAN COMMENT 'Indicates whether this amendment was submitted simultaneously to multiple health authorities as part of a global regulatory strategy, requiring coordinated timelines across FDA, EMA, PMDA, and other agencies.',
    `icf_version_impacted` STRING COMMENT 'Version identifier of the Informed Consent Form (ICF) that must be updated as a result of this amendment. Links to the ICF version management workflow in Clinpal and the document management system.',
    `implementation_date` DATE COMMENT 'Date on which the protocol amendment was operationally implemented at clinical sites, including updated procedures, training, and revised eCRF forms in Medidata Rave. Must be on or after all required regulatory and ethics approvals.',
    `planned_implementation_date` DATE COMMENT 'Target date for operational implementation of the amendment at clinical sites, used for project planning and site readiness tracking in the source system',
    `prior_approval_required_flag` BOOLEAN COMMENT 'Indicates whether this amendment requires prior approval from the health authority before implementation (true for substantial amendments) versus notification-only (false for non-substantial/administrative amendments).',
    `reconsent_required_flag` BOOLEAN COMMENT 'Indicates whether enrolled subjects must provide updated informed consent (ICF re-consent) as a result of this amendment. Triggers ICF version update workflow in Clinpal and site notification via the source system',
    `review_deadline_date` DATE COMMENT 'Calculated or mandated deadline by which the health authority must respond to the amendment submission per applicable regulations (e.g., 30-day FDA IND amendment review window, EMA assessment timeline). Used for escalation and follow-up tracking.',
    `safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the protocol amendment has a direct impact on subject safety, risk-benefit profile, or safety monitoring procedures. Triggers expedited regulatory review and DSMB/DMC notification requirements.',
    `site_notification_date` DATE COMMENT 'Date on which clinical sites were formally notified of the approved protocol amendment and required to begin implementation, including updated training and revised procedures. Tracked in the source system',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this protocol amendment.',
    `subject_impact_flag` BOOLEAN COMMENT 'Indicates whether the amendment affects subjects currently enrolled in the study, requiring re-consent, protocol deviation assessment, or updated procedures for ongoing participants.',
    `submission_date` DATE COMMENT 'Date on which the protocol amendment was formally submitted to the primary health authority (e.g., FDA, EMA, PMDA). Marks the start of the regulatory review clock.',
    `submission_reference_number` STRING COMMENT 'Official reference number assigned by the health authority upon receipt of the amendment submission (e.g., FDA IND amendment serial number, EMA submission tracking number). Used for all subsequent regulatory correspondence.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this protocol amendment record, supporting audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `urgent_safety_measure_flag` BOOLEAN COMMENT 'Indicates whether this amendment was implemented as an urgent safety measure prior to regulatory approval, as permitted under GCP and EU CTR for immediate risk mitigation. Requires retrospective notification to health authorities.',
    CONSTRAINT pk_regulatory_protocol_amendment PRIMARY KEY(`regulatory_protocol_amendment_id`)
) COMMENT 'Tracks protocol amendments submitted to health authorities and ethics committees. Captures amendment number, amendment type (substantial/non-substantial), amendment rationale, affected study sections, submission date to each agency, agency acknowledgment';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`approval` (
    `approval_id` BIGINT COMMENT 'Primary key for approval',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Regulatory approvals are granted for specific regulatory applications (NDA, BLA, MAA, CTA).',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.nda_bla_application. Business justification: An approval (marketing authorization decision) is the direct outcome of an NDA/BLA application.',
    `primary_approval_health_authority_id` BIGINT COMMENT 'Reference to the health authority or regulatory agency (e.g., FDA, EMA, PMDA, MHRA, Health Canada, TGA) that issued this approval decision.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or program for which this regulatory approval was granted. Enables cross-domain linkage between regulatory decisions and study operations.',
    `submission_id` BIGINT COMMENT 'Reference to the parent regulatory submission (IND, NDA, BLA, MAA, CTA) that resulted in this approval decision. Links approval back to the originating dossier.',
    `submission_sequence_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission_sequence. Business justification: An approval is granted in response to a specific eCTD submission sequence. The approval.ectd_sequence_number STRING field is a denormalized reference to submission_sequence',
    `tertiary_approval_health_authority_id` BIGINT COMMENT 'FK to regulatory.health_authority',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory approvals generate critical TMF documents — approval letters, labeling approvals, post-marketing commitment letters — that must be TMF-filed per ICH E6.',
    `agency_decision_date` DATE COMMENT 'The official date on which the health authority issued its approval decision or authorization. This is the principal real-world event date for the approval transaction, as recorded in the agency approval letter.',
    `agency_decision_rationale` STRING COMMENT 'Summary of the health authoritys stated rationale or basis for the approval decision, as documented in the approval letter, assessment report, or public review document. Captures key scientific and regulatory justification.',
    `approval_status` STRING COMMENT 'Current lifecycle status of the regulatory approval. Tracks whether the approval is active, conditionally approved (with post-marketing commitments), withdrawn by sponsor, suspended or revoked by the agency, or pending final decision.. Valid values are `APPROVED|CONDITIONALLY_APPROVED|WITHDRAWN|SUSPENDED|REVOKED|PENDING`',
    `approval_type` STRING COMMENT 'Classification of the regulatory approval or authorization received. Distinguishes between IND allowance (Investigational New Drug), NDA approval (New Drug Application), BLA approval (Biologics License Application), MAA approval (Marketing Authorization. Valid values are `IND_ALLOWANCE|NDA_APPROVAL|BLA_APPROVAL|MAA_APPROVAL|CTA_AUTHORIZATION|LABEL_APPROVAL`',
    `approved_dose` STRING COMMENT 'The approved dose or dose range as specified in the regulatory approval (e.g., 10 mg once daily, 200 mg/m² every 3 weeks). Captures the label-approved dosing regimen for the approved indication and population.',
    `approved_indication` STRING COMMENT 'The specific disease, condition, or therapeutic indication for which the health authority has granted approval. Reflects the exact label language or CTA scope as approved (e.g., Treatment of moderate-to-severe plaque psoriasis in adults).',
    `approved_population` STRING COMMENT 'Description of the patient population covered by the approval, including age group, disease severity, prior treatment requirements, or other eligibility criteria as specified in the approved label or CTA (e.g., Adults ≥18 years with inadequate response',
    `compliance_inspection_code` BIGINT COMMENT 'Foreign key linking to compliance.inspection. Business justification: Pre-approval inspections (PAIs) are a standard FDA/EMA step before granting marketing approval.',
    `conditions_of_approval` STRING COMMENT 'Narrative description of any conditions, restrictions, or requirements attached to the approval by the health authority (e.g., REMS requirements, restricted distribution, mandatory risk minimization measures, specific labeling requirements).',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory approval record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `dosage_form` STRING COMMENT 'The pharmaceutical dosage form approved by the health authority (e.g., tablet, capsule, injection, infusion, patch). Reflects the specific formulation covered by the approval as stated in the approved label.',
    `drug_name` STRING COMMENT 'The International Nonproprietary Name (INN) or brand name of the drug, biologic, or investigational medicinal product covered by this approval. Denormalized for regulatory reporting and label management.',
    `effective_date` DATE COMMENT 'The date from which the regulatory approval becomes legally effective and the sponsor may act upon it (e.g., commence the trial, market the product). May differ from the agency decision date for conditional or phased approvals.',
    `expiry_date` DATE COMMENT 'The date on which the regulatory approval expires or requires renewal (applicable to CTAs, annual IND renewals, and time-limited authorizations). Null for indefinite approvals such as standard NDA/BLA marketing authorizations.',
    `geographic_scope` STRING COMMENT 'Description of the geographic territory or jurisdictions covered by this approval (e.g., United States, European Union - 27 Member States, Japan). Supports multi-regional regulatory portfolio management.',
    `inn_code` STRING COMMENT 'The WHO-assigned International Nonproprietary Name (INN) code or identifier for the active substance covered by this approval. Supports WHO-DD coding and cross-study drug identification.',
    `inspection_readiness_status` STRING COMMENT 'Current inspection readiness status for this approval record, indicating whether all supporting documentation in the eTMF is complete and audit-ready for potential agency inspection. Supports GCP inspection preparedness.. Valid values are `READY|NOT_READY|IN_REVIEW|NOT_APPLICABLE`',
    `irb_iec_reference` STRING COMMENT 'Reference number or identifier of the corresponding IRB (Institutional Review Board) or IEC (Independent Ethics Committee) approval associated with this regulatory authorization. Supports ethics and regulatory approval alignment tracking.',
    `is_conditional_approval` BOOLEAN COMMENT 'Indicates whether this approval was granted conditionally (True) or as a full unconditional approval (False). Conditional approvals require the sponsor to fulfill specific post-marketing commitments or confirmatory studies.',
    `is_renewal_required` BOOLEAN COMMENT 'Indicates whether this approval requires periodic renewal or re-authorization (True) or is granted indefinitely (False). Relevant for CTAs, annual IND reports, and time-limited authorizations in certain jurisdictions.',
    `letter_date` DATE COMMENT 'The date printed on the official agency approval letter or decision notice. May differ from the agency decision date if the letter was issued after the formal decision was recorded.',
    `letter_reference` STRING COMMENT 'Official reference number or document identifier of the agency approval letter or decision notice (e.g., FDA approval letter reference, EMA decision reference). Used to locate the source document in the eTMF or regulatory binder in Veeva Vault.',
    `mah_name` STRING COMMENT 'Name of the Marketing Authorization Holder.',
    `notes` STRING COMMENT 'Free-text field for additional regulatory context, internal commentary, or supplementary information about this approval that does not fit into structured fields. Used by regulatory affairs teams for operational notes.',
    `number` STRING COMMENT 'Externally-assigned unique identifier issued by the health authority for this approval (e.g., NDA 123456, EMA/H/C/004321, IND 12345). This is the official agency-assigned reference number used in all regulatory correspondence.',
    `post_marketing_commitments` STRING COMMENT 'Description of post-marketing study commitments, confirmatory trials, or pharmacovigilance obligations required by the health authority as a condition of approval. Includes Phase IV studies, REMS, and risk management plans.',
    `protocol_amendment_version` STRING COMMENT 'The version of the study protocol or protocol amendment that was in effect at the time of this approval. Relevant for CTA authorizations and protocol amendment approvals to ensure the correct protocol version is linked.',
    `renewal_due_date` DATE COMMENT 'The date by which the sponsor must submit a renewal application or annual report to maintain the validity of this approval. Null if renewal is not required. Critical for regulatory compliance tracking.',
    `review_pathway` STRING COMMENT 'The regulatory review pathway or designation under which the application was reviewed and approved (e.g., Standard, Priority Review, Accelerated Approval, Breakthrough Therapy, Fast Track, Orphan Drug).. Valid values are `STANDARD|PRIORITY|ACCELERATED|BREAKTHROUGH|FAST_TRACK|ORPHAN`',
    `sponsor_name` STRING COMMENT 'Name of the sponsor organization for this approval.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease category associated with the approved indication (e.g., Oncology, Cardiovascular, Immunology, Neurology, Infectious Disease). Used for portfolio analytics and regulatory strategy reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory approval record was most recently modified. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_approval PRIMARY KEY(`approval_id`)
) COMMENT 'Records regulatory approvals, authorizations, and decisions received from health authorities. Captures approval type (IND allowance, NDA approval, MAA approval, CTA authorization, label approval), approval date, effective date, approved indication';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` (
    `ind_application_id` BIGINT COMMENT 'Unique surrogate identifier for the IND application record in the lakehouse silver layer. Primary key for this entity.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: IND applications require audit verification of manufacturing, preclinical, and early clinical data before FDA submission.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: ind_application is filed with the FDA or equivalent competent authority but only stores regulatory_agency STRING. Normalize to a health_authority FK. No reverse FK exists.',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.nda_bla_application. Business justification: An IND application is the precursor to an NDA/BLA application — the IND enables clinical trials that generate the data for the NDA/BLA.',
    `parent_application_id` BIGINT COMMENT 'Reference to the parent regulatory application record when this IND is a sub-application or cross-references a master NDA/BLA/MAA application. Enables hierarchical navigation of the regulatory application portfolio.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IND applications and their annual reports, safety updates, and FDA correspondence are essential TMF documents (TMF Zone 1).',
    `amendment_count` BIGINT COMMENT 'The cumulative number of IND amendments (protocol amendments, information amendments, safety reports) submitted to the FDA under this IND. Tracks the volume of regulatory activity and dossier complexity.',
    `annual_report_due_date` DATE COMMENT 'The next due date for the IND Annual Report submission to the FDA. Annual reports are required within 60 days of the anniversary of the IND effective date and must summarize clinical progress, safety data, and manufacturing updates.',
    `application_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction in which this application is filed (e.g., USA for FDA, GBR for MHRA, JPN for PMDA). Enables multi-country regulatory portfolio analytics.. Valid values are `^[A-Z]{3}$`',
    `breakthrough_therapy_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Breakthrough Therapy designation for the investigational product under this IND. Breakthrough Therapy designation provides intensive FDA guidance and rolling review for drugs showing substantial improvement over',
    `clinical_hold_date` DATE COMMENT 'The date on which the FDA issued a clinical hold order on this IND, halting enrollment or dosing of subjects. Nullable for INDs not on clinical hold. Triggers mandatory sponsor response within 30 days.',
    `clinical_hold_lifted_date` DATE COMMENT 'The date on which the FDA lifted the clinical hold and authorized resumption of clinical trials under this IND. Nullable for INDs that have never been on clinical hold or where the hold remains active.',
    `clinical_hold_reason` STRING COMMENT 'Description of the FDAs stated reason for imposing a clinical hold on this IND. Captures the safety concern, protocol deficiency, or regulatory non-compliance issue cited by the agency. Nullable for INDs not on clinical hold.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this IND application record was first created in the lakehouse data platform. Represents the RECORD_AUDIT_CREATED category for audit trail and data lineage purposes. Conforms to 21 CFR Part 11 electronic records requirements.',
    `dosage_form` STRING COMMENT 'The pharmaceutical dosage form of the investigational product (e.g., tablet, capsule, injection, infusion, patch). Captured from the IND CMC section and used for supply chain and regulatory tracking.',
    `drug_substance_name` STRING COMMENT 'International Nonproprietary Name (INN) or chemical name of the active pharmaceutical ingredient (API) covered under this IND. Used for regulatory cross-referencing and WHO-DD coding.',
    `ectd_submission_flag` BOOLEAN COMMENT 'Indicates whether this IND application is submitted in eCTD format via the FDA Electronic Submissions Gateway. True indicates eCTD format; False indicates paper or non-eCTD electronic submission. FDA mandates eCTD for most IND submissions.',
    `effective_date` DATE COMMENT 'The date on which the IND became effective and clinical trials were authorized to commence. Under 21 CFR Part 312.40, an IND becomes effective 30 days after FDA receipt unless FDA places a clinical hold.',
    `equivalent_application_number` STRING COMMENT 'The application number assigned by a non-FDA regulatory agency for an equivalent authorization (e.g., EMA CTA number, MHRA CTA reference, PMDA CTN). Used to cross-reference the IND with parallel international submissions.',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Fast Track designation for the investigational product under this IND. Fast Track facilitates development and expedites review of drugs treating serious conditions with unmet medical need.',
    `fda_application_receipt_date` DATE COMMENT 'The date on which the FDA officially acknowledged receipt of the IND application. Starts the 30-day review clock per 21 CFR Part 312.40. May differ from the initial submission date if there were transmission delays.',
    `fda_division` STRING COMMENT 'The FDA Center and Division responsible for reviewing this IND application (e.g., CDER/Division of Oncology Products 1, CBER/Division of Vaccines). Determines the regulatory review team and applicable FDA guidance documents.',
    `inactivation_date` DATE COMMENT 'The date on which the IND was placed into inactive status, either by sponsor notification or FDA action. Nullable for active INDs. Represents the EFFECTIVE_UNTIL boundary for the active IND period.',
    `ind_number` STRING COMMENT 'Official IND number assigned by the FDA upon receipt of the IND application. This is the externally-known regulatory identifier used in all agency correspondence, safety reports, and annual reports.. Valid values are `^[0-9]{1,6}$`',
    `ind_serial_number_latest` STRING COMMENT 'The most recent serial number assigned to the latest IND submission sequence (original or amendment). IND submissions are numbered sequentially starting from 0000. Used to track the current version of the IND dossier in Veeva Vault eTMF.. Valid values are `^[0-9]{4}$`',
    `ind_type` STRING COMMENT 'Classification of the IND application by its intended purpose. Commercial INDs are filed by pharmaceutical/biotech sponsors for drug development. Research INDs are filed by investigators for academic studies.. Valid values are `commercial|research|emergency_use|treatment|expanded_access`',
    `indication` STRING COMMENT 'The specific disease, condition, or patient population for which the investigational product is being studied under this IND. Aligns with the MedDRA Preferred Term (PT) for the target indication.',
    `initial_submission_date` DATE COMMENT 'The date on which the original IND application was first submitted to the FDA. This is the principal business event date for the IND lifecycle and triggers the 30-day FDA review clock per 21 CFR Part 312.40.',
    `investigational_product_code` STRING COMMENT 'Internal sponsor code or development compound number assigned to the investigational product (e.g., ABC-123). Used for cross-referencing across clinical, regulatory, and supply chain systems including RTSM and the source system',
    `investigational_product_name` STRING COMMENT 'The name of the investigational drug, biologic, or compound covered under this IND application. May be a code name, generic name, or proprietary name as designated by the sponsor.',
    `last_annual_report_date` DATE COMMENT 'The date on which the most recent IND Annual Report was submitted to the FDA. Used to track compliance with annual reporting obligations and calculate the next due date.',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the FDA Office of Orphan Products Development (OOPD) has granted Orphan Drug designation for the investigational product. Orphan designation provides tax credits, market exclusivity, and expedited review for drugs targeting rare diseases',
    `phase_coverage` STRING COMMENT 'The clinical development phase(s) authorized under this IND application. An IND may cover a single phase or span multiple phases. Phase 1 covers first-in-human safety studies; Phase 2 covers efficacy and dose-ranging; Phase 3 covers confirmatory trials',
    `protocol_count` BIGINT COMMENT 'The total number of clinical study protocols currently authorized and active under this IND application. An IND may cover multiple protocols across different phases and indications.',
    `safety_reporting_obligation` STRING COMMENT 'Defines the IND-level safety reporting obligation tier. Standard obligations apply to all INDs. Expedited 7-day reporting applies to fatal or life-threatening unexpected SUSARs.. Valid values are `standard|expedited_7day|expedited_15day|both`',
    `sponsor_contact_email` STRING COMMENT 'Email address of the designated sponsor contact person for FDA correspondence related to this IND application. Used for regulatory notifications and agency communication tracking.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this IND application.',
    `sponsor_name` STRING COMMENT 'Name of the sponsor organization for this IND application.',
    `sponsor_type` STRING COMMENT 'Classification of the sponsor organization type. Distinguishes between commercial pharmaceutical/biotech companies, academic institutions, government agencies, and Contract Research Organizations (CROs) acting as sponsor.. Valid values are `pharmaceutical|biotech|academic|government|cro`',
    `therapeutic_area` STRING COMMENT 'The disease area or medical specialty that the investigational product targets (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for portfolio analytics, regulatory strategy, and resource planning.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this IND application record was most recently modified in the lakehouse data platform. Represents the RECORD_AUDIT_UPDATED category. Used for incremental data pipeline processing and audit trail compliance per 21 CFR Part 11.',
    `withdrawal_date` DATE COMMENT 'The date on which the sponsor formally withdrew the IND application from FDA. Nullable for non-withdrawn INDs. Triggers archival obligations and cessation of all clinical activities under the IND.',
    CONSTRAINT pk_ind_application PRIMARY KEY(`ind_application_id`)
) COMMENT 'Specialized master record for Investigational New Drug (IND) applications filed with the FDA (or equivalent CTAs with EMA/MHRA). Tracks IND number, IND type (commercial, research, emergency), sponsor name, investigational product name, phase coverage';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` (
    `nda_bla_application_id` BIGINT COMMENT 'Unique surrogate identifier for the NDA, BLA, or equivalent marketing authorization application record in the lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: nda_bla_application is a specialized master record that extends the generic application record for NDA/BLA/MAA submissions, mirroring the pattern of',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Pre-NDA/BLA submission QA audits are a mandatory step in regulatory operations. The audit record must reference the NDA/BLA application being audited, supporting the submission quality',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: nda_bla_application stores the reviewing authority as a health_authority STRING. Normalize to a health_authority_id FK. No reverse FK exists; no cycle.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: NDA/BLA applications are assembled as regulatory binders for eCTD submission. Linking the NDA/BLA application record to its primary regulatory binder enables application-level',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_sequence_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission_sequence. Business justification: An NDA/BLA application tracks its current or most recent eCTD sequence via the denormalized ectd_sequence_number STRING.',
    `accelerated_approval_flag` BOOLEAN COMMENT 'Indicates whether the application is submitted under the FDA Accelerated Approval pathway (Subpart H/E), based on a surrogate or intermediate clinical endpoint with post-marketing confirmatory trial requirements.',
    `acceptance_date` DATE COMMENT 'Date on which the health authority formally accepted the application for substantive review (Day 74 for EMA; Day 60 for FDA filing decision). Null if not yet accepted or if refused at filing.',
    `advisory_committee_date` DATE COMMENT 'Scheduled or actual date of the FDA Advisory Committee (AdCom) meeting convened to review this application. Null if no advisory committee meeting is planned or held.',
    `advisory_committee_flag` BOOLEAN COMMENT 'Indicates whether an FDA Advisory Committee (AdCom) meeting has been scheduled or held for this application. Advisory committee recommendations are a key input to the FDA approval decision.',
    `advisory_committee_recommendation` STRING COMMENT 'Outcome vote or recommendation issued by the FDA Advisory Committee following their review meeting. Null if no meeting held. Informs but does not bind the FDA approval decision.. Valid values are `approve|approve_with_conditions|not_approve|no_recommendation`',
    `application_status` STRING COMMENT 'Current lifecycle status of the marketing authorization application as tracked in Veeva Vault regulatory submissions module. Drives workflow routing and regulatory milestone tracking.',
    `application_type` STRING COMMENT 'Classification of the marketing authorization application: NDA (New Drug Application), BLA (Biologics License Application), sNDA (supplemental NDA), sBLA (supplemental BLA), or MAA (Marketing Authorization Application for EMA).. Valid values are `NDA|BLA|sNDA|sBLA|MAA`',
    `approval_date` DATE COMMENT 'Date on which the health authority issued the formal approval decision (FDA approval letter, EMA CHMP positive opinion, PMDA approval). Null if not yet approved.',
    `approval_pathway` STRING COMMENT 'Regulatory approval pathway under which the application is reviewed: standard review, accelerated approval (FDA), conditional marketing authorization (EMA), exceptional circumstances (EMA), or rolling review.. Valid values are `standard|accelerated|conditional|exceptional|rolling_review`',
    `breakthrough_therapy_flag` BOOLEAN COMMENT 'Indicates whether the FDA has granted Breakthrough Therapy Designation (BTD) for this drug, enabling intensive FDA guidance and rolling review. Applicable to FDA NDA/BLA only.',
    `complete_response_letter_date` DATE COMMENT 'Date on which the FDA issued a Complete Response Letter (CRL) indicating the application cannot be approved in its current form and specifying deficiencies to be addressed. Null if no CRL issued.',
    `compliance_inspection_code` BIGINT COMMENT 'Foreign key linking to compliance.inspection. Business justification: Pre-approval inspections (PAIs) are triggered by NDA/BLA applications. The NDA/BLA record must reference the PAI to support the complete application file and demonstrate inspection',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this NDA/BLA application record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and data lineage requirements under 21 CFR Part 11.',
    `ctd_module_status` STRING COMMENT 'Overall completeness status of the CTD dossier modules (1–5) at time of submission. Tracks whether all required CTD modules have been submitted to the health authority.. Valid values are `complete|partial|pending|not_applicable`',
    `dosage_form` STRING COMMENT 'Physical form of the drug product as approved or under review (e.g., tablet, capsule, injection, lyophilized powder for injection, transdermal patch). Captured per ICH M4 CTD Module 3 pharmaceutical development.',
    `drug_name` STRING COMMENT 'Proprietary (brand) name or proposed trade name of the drug or biologic product as submitted in the application. Used for regulatory correspondence, labeling, and commercial tracking.',
    `exclusivity_type` STRING COMMENT 'Type of regulatory market exclusivity granted upon approval: NCE (5-year new chemical entity), biologic (12-year), orphan drug (7-year), pediatric (6-month extension), new indication (3-year), or none.. Valid values are `NCE|biologic|orphan|pediatric|new_indication|none`',
    `fast_track_flag` BOOLEAN COMMENT 'Indicates whether the FDA has granted Fast Track designation, facilitating more frequent interactions with FDA and eligibility for rolling review. Applicable to FDA NDA/BLA only.',
    `ind_number` STRING COMMENT 'FDA-assigned Investigational New Drug (IND) application number that served as the regulatory basis for the clinical development program supporting this NDA/BLA. Links the marketing application to its clinical development history.. Valid values are `^IND[0-9]{6}$`',
    `indication` STRING COMMENT 'Full text of the proposed or approved indication statement describing the disease, condition, or patient population for which the drug is intended. Directly maps to the approved labeling indication section.',
    `inn` STRING COMMENT 'WHO-assigned International Nonproprietary Name (INN) for the active substance. Provides a globally unique, non-proprietary identifier for the drug substance used across regulatory submissions and scientific literature.',
    `market_exclusivity_expiry_date` DATE COMMENT 'Date on which the regulatory market exclusivity period expires (e.g., 5-year NCE exclusivity, 12-year biologic exclusivity, 7-year orphan drug exclusivity). Critical for commercial lifecycle and generic/biosimilar entry planning.',
    `orphan_drug_flag` BOOLEAN COMMENT 'Indicates whether the drug or biologic has received Orphan Drug Designation (ODD) from FDA (Orphan Drug Act) or EMA (EC Regulation 141/2000), conferring market exclusivity and fee waivers.',
    `pdufa_goal_date` DATE COMMENT 'FDA-assigned PDUFA action goal date by which the agency commits to completing its review. Applicable to FDA NDA/BLA submissions; null for non-FDA applications. Critical KPI for regulatory timeline management.',
    `post_marketing_commitment_flag` BOOLEAN COMMENT 'Indicates whether the approval includes required post-marketing commitments (PMCs) or post-marketing requirements (PMRs), such as confirmatory trials for accelerated approval or pediatric studies under PREA.',
    `priority_review_flag` BOOLEAN COMMENT 'Indicates whether the FDA has granted Priority Review designation to this application, reducing the standard review period from 12 months to 6 months. Applicable to FDA NDA/BLA only.',
    `rems_required_flag` BOOLEAN COMMENT 'Indicates whether the FDA has required a Risk Evaluation and Mitigation Strategy (REMS) as a condition of approval to ensure the drugs benefits outweigh its risks.',
    `resubmission_class` STRING COMMENT 'FDA classification of the resubmission following a CRL: Class 1 (2-month review goal) for minor responses, Class 2 (6-month review goal) for major responses requiring extensive review.. Valid values are `class_1|class_2|not_applicable`',
    `resubmission_date` DATE COMMENT 'Date on which the sponsor resubmitted the application following a Complete Response Letter (CRL) or other agency deficiency communication. Null if no resubmission has occurred.',
    `review_division` STRING COMMENT 'FDA Office or Division (e.g., Office of Oncology Products, Division of Psychiatry) or EMA Committee (CHMP, COMP) responsible for reviewing this application. Used for regulatory relationship management and escalation routing.',
    `rolling_review_flag` BOOLEAN COMMENT 'Indicates whether the health authority has granted rolling review, allowing submission and review of completed CTD modules before the full dossier is complete. Applicable to FDA (Fast Track) and EMA rolling review procedures.',
    `submission_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the application was submitted (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-regional regulatory tracking.. Valid values are `^[A-Z]{3}$`',
    `submission_date` DATE COMMENT 'Date on which the complete application dossier was formally submitted to the health authority. Triggers the regulatory review clock and PDUFA goal date calculation.',
    `therapeutic_area` STRING COMMENT 'Clinical therapeutic area or disease area for which the drug or biologic is being developed (e.g., oncology, cardiovascular, infectious disease, neurology). Used for portfolio management and regulatory strategy alignment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this NDA/BLA application record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for change tracking and audit compliance under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_document_reference` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF/regulatory submissions module where the eCTD dossier and regulatory correspondence are stored. Enables direct traceability from the lakehouse record to the source document management system.',
    CONSTRAINT pk_nda_bla_application PRIMARY KEY(`nda_bla_application_id`)
) COMMENT 'Specialized master record for New Drug Applications (NDA), Biologics License Applications (BLA), and equivalent marketing authorization applications (MAA).';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` (
    `safety_report_submission_id` BIGINT COMMENT 'Unique surrogate identifier for each safety report submission record in the regulatory domain. Primary key for this data product.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: IND Annual Reports, DSURs, and expedited safety reports are filed under specific regulatory applications.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Safety reports are submitted to specific health authorities (FDA, EMA, PMDA). The agency_code STRING field on safety_report_submission is a denormalized reference to',
    `icsr_id` BIGINT COMMENT 'Foreign key linking to safety.icsr. Business justification: Expedited safety report submissions (ICSRs) are the regulatory filing of ICSR cases. Linking safety_report_submission to the specific ICSR case it reports is fundamental to pharmacovigilance',
    `parent_submission_id` BIGINT COMMENT 'Reference to the original or preceding safety report submission record when this record is a follow-up or amendment. Enables lineage tracking across submission versions for the same safety event.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: Safety report submissions (DSURs, IND Annual Reports) are generated from a specific SDTM dataset version locked at the data cut date.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this safety report is submitted. Links to the study master record.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Safety reports (DSURs, IND annual reports, SUSARs) are TMF Zone 1 essential documents.',
    `agency_acknowledgment_date` DATE COMMENT 'Date on which the health authority formally acknowledged receipt of the safety report submission. For FDA IND submissions this is the date of the FDA acknowledgment letter; for EMA SUSAR submissions this is the EudraVigilance gateway acknowledgment date.',
    `agency_reference_number` STRING COMMENT 'Reference or tracking number assigned by the health authority upon receipt or acknowledgment of the safety report (e.g., FDA case number, EudraVigilance case ID, PMDA receipt number). Used for follow-up correspondence.',
    `approval_date` DATE COMMENT 'Date on which the safety report received final internal approval for submission. Used to calculate the internal review cycle time and to verify compliance with expedited reporting timelines.',
    `approved_by` STRING COMMENT 'Name or user identifier of the qualified person, medical officer, or regulatory lead who provided final approval of the safety report prior to submission. Supports 21 CFR Part 11 electronic signature and ALCOA+ requirements.',
    `argus_safety_case_reference` STRING COMMENT 'Case identifier in the source system system that is the source of the safety data underlying this submission. Provides traceability from the regulatory submission back to the adverse event case in the pharmacovigilance system of record.',
    `causality_assessment` STRING COMMENT 'Sponsor or investigator assessment of the causal relationship between the investigational product and the adverse reaction reported in this submission. Drives the reporting obligation classification.. Valid values are `RELATED|NOT_RELATED|POSSIBLY_RELATED|UNASSESSABLE`',
    `compliance_inspection_code` BIGINT COMMENT 'Foreign key linking to compliance.inspection. Business justification: Safety reporting compliance is a frequent focus of regulatory inspections. Linking safety report submissions to inspection records enables traceability from specific safety reports to',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this safety report submission record was first created in the system. Supports audit trail and ALCOA+ contemporaneous documentation requirements per 21 CFR Part 11.',
    `ctis_number` STRING COMMENT 'EU Clinical Trials Information System (CTIS) authorization number under EU CTR 536/2014, replacing EudraCT for trials authorized under the new regulation. Used for SUSAR submissions via the CTIS portal.',
    `data_lock_date` DATE COMMENT 'The date on which the safety database was locked for the purpose of generating this periodic safety report. No new safety data is included after this date. Equivalent to the reporting period end date for periodic reports.',
    `dibd` DATE COMMENT 'Development International Birth Date (DIBD) — the date of the first authorization to conduct a clinical trial with the investigational product in any country.',
    `due_date` DATE COMMENT 'Regulatory deadline by which the safety report must be submitted to the health authority. For expedited SUSAR/IND safety reports this is typically 7 or 15 calendar days from initial awareness; for DSURs it is 60 days from the Development International',
    `eudract_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) number assigned to the clinical trial, used for EMA and EU member state safety report submissions. Format: YYYY-NNNNNN-CC.',
    `expedited_report_timeline_days` BIGINT COMMENT 'Regulatory reporting timeline in calendar days applicable to this expedited submission (typically 7 days for fatal/life-threatening unexpected SARs or 15 days for other unexpected serious adverse reactions). Null for periodic reports.',
    `investigational_product_name` STRING COMMENT 'Name of the investigational medicinal product (IMP) or drug substance that is the subject of this safety report. Aligns with the IND/CTA product designation.',
    `is_expedited` BOOLEAN COMMENT 'Indicates whether this safety report is an expedited submission (True) subject to 7-day or 15-day reporting timelines, as opposed to a periodic report. Expedited reports include SUSARs and IND safety reports for unexpected serious adverse reactions.',
    `is_follow_up` BOOLEAN COMMENT 'Indicates whether this submission is a follow-up (True) to a previously submitted safety report for the same event or reporting period, as opposed to an initial/original submission (False). Follow-up submissions provide updated or additional information.',
    `listedness_assessment` STRING COMMENT 'Assessment of whether the adverse reaction is listed (expected) or unlisted (unexpected) in the current Investigators Brochure (IB) or Reference Safety Information (RSI).. Valid values are `LISTED|UNLISTED|UNKNOWN`',
    `meddra_pt_code` STRING COMMENT 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) code for the primary adverse reaction or event described in this safety report. Standardizes event terminology for regulatory submissions and signal detection.',
    `meddra_soc_code` STRING COMMENT 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) code associated with the primary adverse reaction in this safety report. Used for aggregate safety analysis and tabulation in periodic reports.',
    `regulatory_action_description` STRING COMMENT 'Free-text description of the regulatory action required or taken as a result of this safety report submission (e.g., IB update, protocol amendment, clinical hold notification, Dear Investigator Letter). Populated when regulatory_action_required is True.',
    `regulatory_action_required` BOOLEAN COMMENT 'Indicates whether this safety report submission has triggered or requires a regulatory action such as a protocol amendment, IB update, informed consent revision, or clinical hold. Supports inspection readiness and CAPA tracking.',
    `report_type` STRING COMMENT 'Classification of the safety report being submitted. IND_SAFETY_REPORT = expedited IND safety report (15-day/7-day); DSUR = Development Safety Update Report; PSUR_PBRER = Periodic Safety Update Report / Periodic Benefit-Risk Evaluation Report; SUSAR =. Valid values are `IND_SAFETY_REPORT|DSUR|PSUR_PBRER|SUSAR|IND_ANNUAL_REPORT|CIOMS`',
    `report_version` STRING COMMENT 'Version identifier of the safety report document (e.g., 1.0, 2.0, 1.1 for amendments). Tracks original submissions versus follow-up or amended versions submitted to the same agency.',
    `reporting_period_end_date` DATE COMMENT 'End date of the data collection period covered by this safety report, also known as the data lock point (DLP). Defines the cut-off date for safety data included in the report.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the data collection period covered by this safety report (e.g., the beginning of the DSUR or PSUR/PBRER data lock window). Applicable to periodic reports; may be null for expedited reports.',
    `seriousness_criteria` STRING COMMENT 'ICH E2A seriousness criterion that triggered the expedited reporting obligation for this submission. Applicable to SUSAR and IND safety reports. FATAL = resulted in death; LIFE_THREATENING = immediately life-threatening; HOSPITALIZATION = required or. Valid values are `FATAL|LIFE_THREATENING|HOSPITALIZATION|DISABILITY|CONGENITAL_ANOMALY|MEDICALLY_SIGNIFICANT`',
    `submission_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction to which the safety report is submitted (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-country submission tracking.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this safety report submission record. Supports audit trail integrity and change tracking per 21 CFR Part 11 and ALCOA+ requirements.',
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault (eTMF/regulatory submissions module) for the finalized safety report document. Enables direct traceability from this submission record to the source document in the system of record.',
    CONSTRAINT pk_safety_report_submission PRIMARY KEY(`safety_report_submission_id`)
) COMMENT 'Tracks regulatory safety report submissions including IND Annual Reports, Development Safety Update Reports (DSURs), Periodic Safety Update Reports (PSURs/PBRERs), and expedited SUSAR/IND safety reports.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` (
    `clinical_trial_authorization_id` BIGINT COMMENT 'Unique surrogate identifier for the Clinical Trial Authorization record in the lakehouse Silver layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Clinical Trial Authorizations (CTAs) are filed with national competent authorities as part of the overall regulatory application process for a development program.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: CTAs are filed with specific national competent authorities (MHRA, BfArM, ANSM).',
    `parent_cta_clinical_trial_authorization_id` BIGINT COMMENT 'Reference to the original or preceding CTA record from which this substantial modification, renewal, or extension derives. Enables reconstruction of the full authorization history chain for a trial in a given member state.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: A Clinical Trial Authorization is submitted to a national competent authority as a regulatory submission.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: CTAs and their agency decision letters are essential TMF documents per ICH E6 and EU CTR (TMF Zone 1, Section 1.2).',
    `authorization_date` DATE COMMENT 'Date on which the national competent authority formally granted the Clinical Trial Authorization. This is the principal regulatory event date and the start of the authorized trial period. Corresponds to TRANSACTION_HEADER BUSINESS_EVENT_TIMESTAMP.',
    `authorization_status` STRING COMMENT 'Current lifecycle status of the Clinical Trial Authorization as determined by the national competent authority. Drives regulatory compliance monitoring, site activation eligibility, and inspection readiness assessments.',
    `authorization_type` STRING COMMENT 'Classification of the CTA record by authorization event type: initial authorization, substantial modification (protocol amendment requiring NCA approval), renewal, geographic extension, or withdrawal. Drives workflow and regulatory reporting logic.. Valid values are `initial|substantial_modification|renewal|extension|withdrawal`',
    `conditions_attached` BOOLEAN COMMENT 'Indicates whether the national competent authority attached specific conditions or obligations to the Clinical Trial Authorization that must be fulfilled for the authorization to remain valid. True if conditions exist; False otherwise.',
    `conditions_description` STRING COMMENT 'Narrative description of any conditions, restrictions, or obligations attached to the Clinical Trial Authorization by the national competent authority. Populated only when conditions_attached is True.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this Clinical Trial Authorization record was first created in the lakehouse Silver layer. Supports audit trail, data lineage, and ALCOA+ compliance requirements.',
    `cta_reference_number` STRING COMMENT 'Externally-assigned reference number issued by the national competent authority (NCA) or EU CTIS portal upon authorization of the clinical trial. This is the official business identifier used in all regulatory correspondence and submissions.',
    `ctd_section_reference` STRING COMMENT 'Reference to the relevant Common Technical Document (CTD) or eCTD dossier section submitted in support of this CTA application (e.g., Module 5 clinical study reports). Supports regulatory dossier traceability.',
    `ctis_trial_number` STRING COMMENT 'Unique trial identifier assigned within the EU Clinical Trials Information System (CTIS) under EU CTR 536/2014. Used for multi-country EU submissions and authorization tracking via the centralized CTIS portal.',
    `decision_date` DATE COMMENT 'Date on which the national competent authority issued its formal decision (authorization, conditional authorization, refusal, or withdrawal). Used for regulatory timeline KPI reporting and compliance tracking.',
    `decision_outcome` STRING COMMENT 'Formal outcome of the national competent authoritys review decision for this CTA application. Distinct from authorization_status in that it captures the point-in-time decision rather than the current lifecycle state.. Valid values are `authorized|conditionally_authorized|refused|withdrawn`',
    `effective_from_date` DATE COMMENT 'Date from which the Clinical Trial Authorization is legally effective and trial activities may commence in the member state. May differ from authorization_date if conditions or a deferred start apply.',
    `ethics_committee_opinion` STRING COMMENT 'Outcome of the ethics committee (IRB/IEC) review associated with this CTA in the member state. Tracks whether a favorable opinion was obtained, which is a prerequisite for trial commencement in most jurisdictions.. Valid values are `favorable|favorable_with_conditions|unfavorable|pending|not_required`',
    `ethics_opinion_date` DATE COMMENT 'Date on which the ethics committee (IRB/IEC) issued its opinion for this CTA in the member state. Used to confirm that ethics approval preceded trial commencement and to track parallel review timelines.',
    `eudract_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) number assigned to the trial, serving as the pan-European unique trial identifier. Used for cross-referencing across EU member states and EU CTIS.. Valid values are `^[0-9]{4}-[0-9]{6}-[0-9]{2}$`',
    `expiry_date` DATE COMMENT 'Date on which the Clinical Trial Authorization expires, after which trial activities in the member state are no longer authorized unless a renewal has been granted. Null for open-ended authorizations.',
    `gdpr_data_transfer_mechanism` STRING COMMENT 'Legal mechanism under GDPR used to authorize the transfer of personal data of EU trial subjects to non-EU countries in connection with this CTA. Required for EU-based trials involving cross-border data flows.. Valid values are `adequacy_decision|standard_contractual_clauses|binding_corporate_rules|derogation|not_applicable`',
    `indication_meddra_code` STRING COMMENT 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) code for the primary disease indication under investigation in this authorized trial. Enables standardized cross-study and cross-authority indication reporting.',
    `inspection_readiness_status` STRING COMMENT 'Current inspection readiness status for this CTA record, indicating whether the regulatory documentation and evidence supporting this authorization is ready for NCA or GCP inspection. Supports proactive inspection readiness management.. Valid values are `ready|in_preparation|gap_identified|not_assessed`',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether a separate Institutional Review Board (IRB) or Independent Ethics Committee (IEC) approval is required in addition to the NCA authorization in the member state. Relevant for countries with parallel ethics and regulatory review tracks.',
    `member_state_code` STRING COMMENT 'ISO 3166-1 alpha-2 or alpha-3 country code of the EU member state or non-EU country in which this Clinical Trial Authorization was granted by the national competent authority. Enables multi-country authorization tracking.. Valid values are `^[A-Z]{2,3}$`',
    `modification_scope` STRING COMMENT 'Brief description of the scope of the substantial modification covered by this CTA record (e.g., protocol amendment, IMP change, new investigational site addition, safety update). Populated for substantial_modification authorization types.',
    `national_portal_reference` STRING COMMENT 'Reference number or identifier assigned by the national regulatory portal (e.g., MHRA IRAS number, BfArM reference, ANSM reference, Health Canada CTD number) for this CTA. Complements the CTIS trial ID for country-specific tracking.',
    `planned_subject_count` BIGINT COMMENT 'Number of trial subjects planned to be enrolled in the member state under this Clinical Trial Authorization, as declared in the approved protocol. Used for site capacity planning and regulatory reporting.',
    `regulatory_framework` STRING COMMENT 'Primary regulatory framework under which this Clinical Trial Authorization was granted (e.g., EU CTR 536/2014, national regulation, ISO 14155 for medical devices). Determines applicable procedural and reporting requirements.. Valid values are `EU_CTR_536_2014|EU_CTD|national_regulation|ICH_E6|ISO_14155|other`',
    `sponsor_protocol_number` STRING COMMENT 'Internal protocol identifier assigned by the sponsor or CRO to uniquely identify the study protocol associated with this CTA. Used to link the authorization to the study protocol design and development records.',
    `submission_date` DATE COMMENT 'Date on which the Clinical Trial Authorization application was formally submitted to the national competent authority. Used to calculate regulatory review timelines and track compliance with submission deadlines.',
    `substantial_modification_number` STRING COMMENT 'Sequential identifier for substantial modifications to the original CTA, as assigned by the sponsor or NCA. Populated only for authorization_type = substantial_modification. Enables tracking of the amendment history chain.',
    `suspension_date` DATE COMMENT 'Date on which the Clinical Trial Authorization was suspended by the national competent authority or voluntarily by the sponsor. Null if the CTA has never been suspended. Triggers safety and compliance escalation workflows.',
    `suspension_reason` STRING COMMENT 'Narrative reason for the suspension of the Clinical Trial Authorization, as communicated by the national competent authority or sponsor. Populated only when suspension_date is not null.',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication covered by the clinical trial authorized under this CTA (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for portfolio analytics and regulatory reporting segmentation.',
    `trial_phase` STRING COMMENT 'Regulatory phase of the clinical trial covered by this authorization (Phase I through Phase IV), as defined by ICH E8 and applicable NCA guidelines. Determines applicable regulatory requirements, safety reporting thresholds, and monitoring intensity.. Valid values are `Phase I|Phase I/II|Phase II|Phase IIa|Phase IIb|Phase III`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this Clinical Trial Authorization record was last modified in the lakehouse Silver layer. Supports audit trail, change tracking, and ALCOA+ compliance requirements.',
    `validation_date` DATE COMMENT 'Date on which the national competent authority confirmed the CTA application was formally valid and complete for review. Marks the start of the regulatory assessment clock under EU CTR 536/2014.',
    `withdrawal_date` DATE COMMENT 'Date on which the Clinical Trial Authorization was formally withdrawn, either by the sponsor or by the national competent authority. Null if the CTA has not been withdrawn.',
    `withdrawal_reason` STRING COMMENT 'Narrative reason for the withdrawal of the Clinical Trial Authorization. Populated only when withdrawal_date is not null. Required for regulatory reporting and inspection readiness.',
    CONSTRAINT pk_clinical_trial_authorization PRIMARY KEY(`clinical_trial_authorization_id`)
) COMMENT 'Master record for Clinical Trial Authorizations (CTAs) issued by national competent authorities under EU CTR 536/2014, national regulations, and equivalent non-US frameworks.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` (
    `country_registration_id` BIGINT COMMENT 'Unique surrogate identifier for each country-level product registration record in the regulatory lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND/NDA/BLA/MAA) under which this country registration was granted.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: A country registration for a clinical trial is often directly tied to the Clinical Trial Authorization issued by the national competent authority for that country.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Country registrations require local ethics approval in many jurisdictions as part of the authorization package.',
    `health_authority_id` BIGINT COMMENT 'Reference to the health authority (FDA, EMA, PMDA, MHRA, Health Canada, TGA, etc.) that issued or oversees this country registration.',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: A country registration is the direct outcome of a regulatory approval in a specific country/jurisdiction.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Country registrations are initiated through regulatory submissions (initial marketing authorization applications, renewal submissions).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Country registration certificates and approval letters are TMF Zone 1 essential documents.',
    `annual_report_due_date` DATE COMMENT 'Next due date for the periodic safety update report (PSUR), development safety update report (DSUR), or annual product report required by the health authority in this country to maintain the registration.',
    `conditional_approval` BOOLEAN COMMENT 'Indicates whether this registration was granted under conditional or accelerated approval, requiring post-marketing confirmatory studies or commitments. True if conditional approval conditions are still outstanding.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code identifying the jurisdiction in which the product is registered (e.g., USA, GBR, JPN, CAN, AUS, DEU).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this country registration record was first created in the regulatory data product. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_module_scope` STRING COMMENT 'Scope of the Common Technical Document (CTD) dossier submitted for this registration: full (complete Modules 1-5), abridged (generic/hybrid referencing originator data), hybrid (mixed), or bibliographic (literature-based).. Valid values are `full|abridged|hybrid|bibliographic`',
    `dosage_form` STRING COMMENT 'Pharmaceutical dosage form as registered in this country (e.g., tablet, capsule, solution for injection, lyophilized powder). Must match the approved product dossier.',
    `dossier_format` STRING COMMENT 'Format of the regulatory dossier submitted for this registration: eCTD (Electronic Common Technical Document), NeeS (Non-eCTD Electronic Submission), paper, or VNeeS (Veterinary NeeS). Determines submission and archival requirements.. Valid values are `eCTD|NeeS|paper|VNeeS`',
    `expiry_date` DATE COMMENT 'Date on which the current registration period expires and renewal is required to maintain marketing authorization. Null for registrations that do not expire (e.g., some FDA approvals).',
    `indication` STRING COMMENT 'Approved therapeutic indication(s) for which the product is registered in this country, as stated in the approved product labeling or Summary of Product Characteristics (SmPC). May be narrower than the global indication.',
    `inn_name` STRING COMMENT 'WHO-assigned International Nonproprietary Name (INN) for the active substance, as recognized in the country registration. Provides a globally consistent scientific identifier independent of brand name.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether the regulatory file and documentation for this country registration are currently in a state of inspection readiness as assessed by the regulatory affairs team. True if ready for a health authority inspection.',
    `last_annual_report_date` DATE COMMENT 'Date on which the most recent annual product report, PSUR, or equivalent periodic safety report was submitted to the health authority for this country registration.',
    `last_renewal_date` DATE COMMENT 'Date on which the most recent registration renewal was granted by the health authority. Establishes the start of the current registration period for expiry and renewal due date calculations.',
    `last_variation_date` DATE COMMENT 'Date of the most recently approved post-approval variation or amendment to this country registration. Used to track the currency of the approved dossier and labeling.',
    `local_agent_contact` STRING COMMENT 'Primary contact details (phone, email, or address) for the local regulatory agent or marketing authorization holder in the registered country. Used for regulatory correspondence and inspection coordination.',
    `local_agent_name` STRING COMMENT 'Name of the local agent representing the sponsor in this country.',
    `market_exclusivity_expiry` DATE COMMENT 'Date on which the data exclusivity or market exclusivity period expires in this country, after which generic or biosimilar applications may reference the originator dossier. Critical for lifecycle and competitive intelligence planning.',
    `notes` STRING COMMENT 'Free-text field for additional regulatory context, authority-specific conditions, post-approval commitments, or operational notes relevant to this country registration that are not captured in structured fields.',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the product holds orphan drug designation in this country, conferring market exclusivity and regulatory incentives for rare disease treatments. True if orphan designation is active.',
    `patent_expiry_date` DATE COMMENT 'Date on which the primary product patent expires in this country. Used in conjunction with market exclusivity for lifecycle management and generic entry forecasting.',
    `product_name` STRING COMMENT 'Brand or trade name of the medicinal product as approved and registered in this specific country. May differ from the global brand name due to local naming requirements.',
    `registration_date` DATE COMMENT 'Date on which the health authority formally granted or issued the product registration or marketing authorization. Represents the effective start of the registration.',
    `registration_number` STRING COMMENT 'Official registration or marketing authorization number assigned by the national health authority upon approval (e.g., NDA 123456, EU/1/20/1234, PMDA approval number). This is the externally-known business identifier for the registration.',
    `registration_status` STRING COMMENT 'Current lifecycle status of the country registration: active (valid and in force), expired (past expiry date without renewal), suspended (temporarily halted by authority), withdrawn (voluntarily or involuntarily removed), pending (application submitted. Valid values are `active|expired|suspended|withdrawn|pending|cancelled`',
    `registration_type` STRING COMMENT 'Classification of the regulatory procedure used to obtain this registration: national (single-country), mutual recognition (MRP), decentralized (DCP), centralized (EMA), or bilateral agreement.. Valid values are `national|mutual_recognition|decentralized|centralized|bilateral`',
    `regulatory_procedure_number` STRING COMMENT 'Procedure number assigned by the health authority for the specific regulatory review procedure (e.g., EMA centralized procedure number EMEA/H/C/XXXXXX, MRP/DCP reference number). Distinct from the final registration number.',
    `reimbursement_status` STRING COMMENT 'Current reimbursement or health technology assessment (HTA) status of the registered product in this country. Indicates whether the product is covered by national health insurance or payer systems, supporting market access planning.. Valid values are `reimbursed|not_reimbursed|partial|pending|under_review`',
    `renewal_due_date` DATE COMMENT 'Deadline by which the renewal application must be submitted to the health authority to avoid lapse of the registration. May precede the expiry date by a regulatory-mandated lead time.',
    `renewal_submission_date` DATE COMMENT 'Actual date on which the renewal application was submitted to the health authority. Used to confirm timely submission relative to the renewal due date.',
    `strength` STRING COMMENT 'Approved strength or concentration of the active substance as registered in this country (e.g., 10 mg, 100 mg/mL, 500 mg/5 mL). Expressed as a free-text string to accommodate varied unit formats across jurisdictions.',
    `submission_language` STRING COMMENT 'ISO 639-1/639-2 language code of the primary language in which the registration dossier was submitted to the health authority (e.g., en, fr, de, ja). Relevant for translation management and local labeling compliance.. Valid values are `^[a-z]{2,3}$`',
    `therapeutic_area` STRING COMMENT 'Broad therapeutic area classification for the registered product (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for portfolio reporting and market access analytics.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this country registration record. Supports change tracking, audit trail, and data lineage requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault (eTMF/Regulatory module) for the approved registration certificate, marketing authorization letter, or associated dossier. Enables direct traceability to the source regulatory document.',
    CONSTRAINT pk_country_registration PRIMARY KEY(`country_registration_id`)
) COMMENT 'Tracks product registration status and requirements across individual countries and jurisdictions. Captures country, registration number, registration type (national, mutual recognition, decentralized, centralized), registration date, expiry date, renewal';

ALTER SCHEMA `clinical_trials_mvm`.`regulatory` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_mvm`.`regulatory` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_target_health_authority_id` FOREIGN KEY (`target_health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` SET TAGS ('dbx_subdomain' = 'regulatory_submissions');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Target Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_acknowledgement_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_decision` SET TAGS ('dbx_business_glossary_term' = 'Agency Regulatory Decision');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_decision` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|VNeeS');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `drug_product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug Product Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `drug_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_business_glossary_term' = 'eCTD Lifecycle Operation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_value_regex' = 'new|replace|append|delete');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `filing_fee_paid` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Paid Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `is_resubmission` SET TAGS ('dbx_business_glossary_term' = 'Resubmission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Submission Delivery Method');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'electronic_gateway|physical_media|portal|email|paper');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Submission Notes');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Submission Reason');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `resubmission_class` SET TAGS ('dbx_value_regex' = 'class_1|class_2|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'original|amendment|supplement|response|withdrawal');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `target_action_date` SET TAGS ('dbx_business_glossary_term' = 'Target Action Date (PDUFA Date)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'eCTD Validation Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_validated|passed|failed|waived');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_lead_agency_health_authority_id` FOREIGN KEY (`lead_agency_health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` SET TAGS ('dbx_subdomain' = 'application_tracking');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Agency Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `accelerated_approval` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Designation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `annual_report_last_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'IND Annual Report Last Submitted Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `application_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `application_status` SET TAGS ('dbx_value_regex' = 'active|approved|withdrawn|refused|on_clinical_hold|inactive');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `application_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `application_type` SET TAGS ('dbx_value_regex' = 'IND|NDA|BLA|MAA|CTA|IMPD');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `breakthrough_therapy` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `clinical_hold_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Hold Imposition Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `clinical_hold_status` SET TAGS ('dbx_value_regex' = 'none|partial|full|lifted');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `ctd_module` SET TAGS ('dbx_value_regex' = 'M1|M2|M3|M4|M5|full');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `dossier_language` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `dossier_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Application Effective Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Application Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `ind_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `ind_type` SET TAGS ('dbx_value_regex' = 'commercial|research|treatment|emergency');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `lifecycle_phase` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Lifecycle Phase');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Notes');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `pdufa_goal_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Goal Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `priority_review` SET TAGS ('dbx_business_glossary_term' = 'Priority Review Designation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational or Approved Product Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `product_type` SET TAGS ('dbx_value_regex' = 'small_molecule|biologic|gene_therapy|cell_therapy|medical_device|combination');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Contact Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `submission_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|eCTD_v4');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Subtype');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ALTER COLUMN `veeva_vault_dossier_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Dossier ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` SET TAGS ('dbx_subdomain' = 'authority_registry');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Acronym');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `acronym` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency Code');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_value_regex' = 'active|inactive|merged|superseded');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `annual_safety_report_type` SET TAGS ('dbx_value_regex' = 'DSUR|PSUR|IND_Annual|PBRER|other');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_value_regex' = 'national|supranational|regional|reference_agency');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `clinical_trial_registry_required` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Registry Registration Required');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_division_name` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Division Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_division_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Email Address');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Phone Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ctd_format_required` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Format Required');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_business_glossary_term' = 'Applicable Data Privacy Regulatory Framework');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ectd_gateway_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Gateway Identifier');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ectd_specification_version` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Specification Version');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Record Effective From Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `fee_schedule_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Fee Schedule Effective Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Full Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Guideline Version');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ich_member` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation (ICH) Member Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ind_application_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ind_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) / Clinical Trial Authorization (CTA) Review Clock (Days)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ind_submission_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) / Clinical Trial Authorization (CTA) Submission Fee Amount');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `ind_submission_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `inspection_authority` SET TAGS ('dbx_business_glossary_term' = 'GCP Inspection Authority');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `local_language_required` SET TAGS ('dbx_business_glossary_term' = 'Local Language Submission Required');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `local_language_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Mailing Address');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `mutual_recognition_agreements` SET TAGS ('dbx_business_glossary_term' = 'Mutual Recognition Agreement (MRA) Participation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `nda_application_type` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Marketing Authorization Application (MAA) Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `nda_submission_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Marketing Authorization Application (MAA) Submission Fee Amount');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `nda_submission_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `non_fatal_sadr_reporting_clock_hours` SET TAGS ('dbx_business_glossary_term' = 'Non-Fatal Serious Adverse Drug Reaction (SADR) Expedited Reporting Clock (Hours)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Notes');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `priority_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Priority Regulatory Review Clock (Days)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `region_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Region Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `region_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `review_procedure_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Procedure Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `sadr_reporting_clock_hours` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Drug Reaction (SADR) / Suspected Unexpected Serious Adverse Reaction (SUSAR) Expedited Reporting Clock (Hours)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `standard_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Standard Regulatory Review Clock (Days)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Fee Currency (ISO 4217)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_business_glossary_term' = 'Required Submission Language (ISO 639)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Portal URL');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_value_regex' = '^https?://.+$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `trial_registry_name` SET TAGS ('dbx_business_glossary_term' = 'Mandated Clinical Trial Registry Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `trial_registry_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`health_authority` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_veeva_vault_submission_id` FOREIGN KEY (`veeva_vault_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_subdomain' = 'regulatory_submissions');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `veeva_vault_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Regulatory Information Management (RIM) Submission ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_acknowledgement_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_value_regex' = 'approval|complete_response|refuse_to_file|information_request|withdrawal_accepted|no_action');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Submission Confidentiality Level');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|restricted|confidential|highly_confidential');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_value_regex' = 'module_1|module_2|module_3|module_4|module_5|multiple');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_section_list` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section List');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_size_mb` SET TAGS ('dbx_business_glossary_term' = 'Dossier Package Size (MB)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_size_mb` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_business_glossary_term' = 'eCTD Lifecycle Operation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_value_regex' = 'new|replace|append|delete');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_date` SET TAGS ('dbx_business_glossary_term' = 'eCTD Technical Validation Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_status` SET TAGS ('dbx_business_glossary_term' = 'eCTD Technical Validation Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_status` SET TAGS ('dbx_value_regex' = 'pass|fail|warning|pending');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `is_safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Response Due Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `review_clock_start_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Review Clock Start Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `review_clock_target_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Review Clock Target Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `submission_subtype` SET TAGS ('dbx_business_glossary_term' = 'Submission Sub-Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_parent_application_id` FOREIGN KEY (`parent_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_submission_sequence_id` FOREIGN KEY (`submission_sequence_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission_sequence`(`submission_sequence_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_subdomain' = 'regulatory_submissions');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `parent_application_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Regulatory Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_sequence_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Sequence Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `affected_sections` SET TAGS ('dbx_business_glossary_term' = 'Affected Protocol Sections');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_acknowledgment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_approval_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_comments` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{0,3}-?d{1,4}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Rationale');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Title');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non_substantial|administrative|urgent_safety');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_version` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Version');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'Protocol Change Summary');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `dsmb_notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `ethics_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Approval Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `ethics_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `icf_version_impacted` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Impacted');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `planned_implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Amendment Implementation Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `reconsent_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `review_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `subject_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Ongoing Subject Impact Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Reference Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_primary_approval_health_authority_id` FOREIGN KEY (`primary_approval_health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_submission_sequence_id` FOREIGN KEY (`submission_sequence_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission_sequence`(`submission_sequence_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_tertiary_approval_health_authority_id` FOREIGN KEY (`tertiary_approval_health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` SET TAGS ('dbx_subdomain' = 'authority_registry');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approval_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Identifier');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Nda Bla Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `submission_sequence_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Sequence Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `tertiary_approval_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Health Authority Id');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `tertiary_approval_health_authority_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `agency_decision_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `agency_decision_rationale` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'APPROVED|CONDITIONALLY_APPROVED|WITHDRAWN|SUSPENDED|REVOKED|PENDING');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'IND_ALLOWANCE|NDA_APPROVAL|BLA_APPROVAL|MAA_APPROVAL|CTA_AUTHORIZATION|LABEL_APPROVAL');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `approved_population` SET TAGS ('dbx_business_glossary_term' = 'Approved Patient Population');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Approved Dosage Form');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `drug_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug / Product Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `drug_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Effective Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope of Approval');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `inn_code` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN) Code');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'READY|NOT_READY|IN_REVIEW|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `irb_iec_reference` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reference');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `is_conditional_approval` SET TAGS ('dbx_business_glossary_term' = 'Conditional Approval Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `is_renewal_required` SET TAGS ('dbx_business_glossary_term' = 'Renewal Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `letter_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Letter Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Approval Letter Reference Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_business_glossary_term' = 'Marketing Authorization Holder (MAH) Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Notes');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `post_marketing_commitments` SET TAGS ('dbx_business_glossary_term' = 'Post-Marketing Commitments');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `review_pathway` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Pathway');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `review_pathway` SET TAGS ('dbx_value_regex' = 'STANDARD|PRIORITY|ACCELERATED|BREAKTHROUGH|FAST_TRACK|ORPHAN');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_parent_application_id` FOREIGN KEY (`parent_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` SET TAGS ('dbx_subdomain' = 'application_tracking');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Nda Bla Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `parent_application_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Regulatory Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'IND Amendment Count');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `annual_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'IND Annual Report Due Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `application_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `breakthrough_therapy_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `clinical_hold_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Hold Imposition Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Dosage Form');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `drug_substance_name` SET TAGS ('dbx_business_glossary_term' = 'Drug Substance (Active Pharmaceutical Ingredient) Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `drug_substance_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ectd_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'IND Effective Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `equivalent_application_number` SET TAGS ('dbx_business_glossary_term' = 'Equivalent Regulatory Application Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `fast_track_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Fast Track Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `fda_division` SET TAGS ('dbx_business_glossary_term' = 'FDA Review Division');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `inactivation_date` SET TAGS ('dbx_business_glossary_term' = 'IND Inactivation Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,6}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_serial_number_latest` SET TAGS ('dbx_business_glossary_term' = 'IND Latest Serial Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_serial_number_latest` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `ind_type` SET TAGS ('dbx_value_regex' = 'commercial|research|emergency_use|treatment|expanded_access');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `initial_submission_date` SET TAGS ('dbx_business_glossary_term' = 'IND Initial Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `last_annual_report_date` SET TAGS ('dbx_business_glossary_term' = 'Last IND Annual Report Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `phase_coverage` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase Coverage');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `phase_coverage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `protocol_count` SET TAGS ('dbx_business_glossary_term' = 'Protocol Count Under IND');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `safety_reporting_obligation` SET TAGS ('dbx_value_regex' = 'standard|expedited_7day|expedited_15day|both');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Email Address');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'IND Sponsor Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_type` SET TAGS ('dbx_business_glossary_term' = 'IND Sponsor Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_type` SET TAGS ('dbx_value_regex' = 'pharmaceutical|biotech|academic|government|cro');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'IND Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_submission_sequence_id` FOREIGN KEY (`submission_sequence_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission_sequence`(`submission_sequence_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_subdomain' = 'application_tracking');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Biologics License Application (BLA) Application ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `submission_sequence_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Sequence Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_date` SET TAGS ('dbx_business_glossary_term' = 'Advisory Committee Meeting Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_flag` SET TAGS ('dbx_business_glossary_term' = 'Advisory Committee Meeting Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_recommendation` SET TAGS ('dbx_value_regex' = 'approve|approve_with_conditions|not_approve|no_recommendation');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `application_type` SET TAGS ('dbx_value_regex' = 'NDA|BLA|sNDA|sBLA|MAA');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `approval_pathway` SET TAGS ('dbx_value_regex' = 'standard|accelerated|conditional|exceptional|rolling_review');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `breakthrough_therapy_flag` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation (BTD) Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `complete_response_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Complete Response Letter (CRL) Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ctd_module_status` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Completeness Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ctd_module_status` SET TAGS ('dbx_value_regex' = 'complete|partial|pending|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `drug_name` SET TAGS ('dbx_business_glossary_term' = 'Drug / Biologic Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `drug_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `exclusivity_type` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `exclusivity_type` SET TAGS ('dbx_value_regex' = 'NCE|biologic|orphan|pediatric|new_indication|none');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `fast_track_flag` SET TAGS ('dbx_business_glossary_term' = 'Fast Track Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^IND[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `inn` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `orphan_drug_flag` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation (ODD) Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `pdufa_goal_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Goal Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `post_marketing_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Post-Marketing Commitment (PMC) Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `priority_review_flag` SET TAGS ('dbx_business_glossary_term' = 'Priority Review Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `rems_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `resubmission_class` SET TAGS ('dbx_value_regex' = 'class_1|class_2|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `review_division` SET TAGS ('dbx_business_glossary_term' = 'Review Division / Office');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `submission_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_parent_submission_id` FOREIGN KEY (`parent_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_subdomain' = 'regulatory_submissions');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Icsr Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `agency_acknowledgment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `agency_reference_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `argus_safety_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_value_regex' = 'RELATED|NOT_RELATED|POSSIBLY_RELATED|UNASSESSABLE');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `ctis_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trials Information System (CTIS) Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `dibd` SET TAGS ('dbx_business_glossary_term' = 'Development International Birth Date (DIBD)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Due Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `expedited_report_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Expedited Report Timeline (Days)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `is_follow_up` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `listedness_assessment` SET TAGS ('dbx_value_regex' = 'LISTED|UNLISTED|UNKNOWN');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `regulatory_action_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'IND_SAFETY_REPORT|DSUR|PSUR_PBRER|SUSAR|IND_ANNUAL_REPORT|CIOMS');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `seriousness_criteria` SET TAGS ('dbx_value_regex' = 'FATAL|LIFE_THREATENING|HOSPITALIZATION|DISABILITY|CONGENITAL_ANOMALY|MEDICALLY_SIGNIFICANT');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `submission_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_parent_cta_clinical_trial_authorization_id` FOREIGN KEY (`parent_cta_clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_subdomain' = 'application_tracking');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `parent_cta_clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Clinical Trial Authorization (CTA) ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Authorization Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Status');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_type` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Type');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_type` SET TAGS ('dbx_value_regex' = 'initial|substantial_modification|renewal|extension|withdrawal');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `conditions_attached` SET TAGS ('dbx_business_glossary_term' = 'CTA Conditions Attached Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `conditions_description` SET TAGS ('dbx_business_glossary_term' = 'CTA Conditions Description');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `cta_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Reference Number');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ctd_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ctis_trial_number` SET TAGS ('dbx_business_glossary_term' = 'EU Clinical Trials Information System (CTIS) Trial ID');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'NCA Decision Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'NCA Decision Outcome');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'authorized|conditionally_authorized|refused|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Effective From Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ethics_committee_opinion` SET TAGS ('dbx_value_regex' = 'favorable|favorable_with_conditions|unfavorable|pending|not_required');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ethics_opinion_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Opinion Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `gdpr_data_transfer_mechanism` SET TAGS ('dbx_value_regex' = 'adequacy_decision|standard_contractual_clauses|binding_corporate_rules|derogation|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|in_preparation|gap_identified|not_assessed');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `member_state_code` SET TAGS ('dbx_business_glossary_term' = 'Member State / Country Code');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `member_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `modification_scope` SET TAGS ('dbx_business_glossary_term' = 'Substantial Modification Scope');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `national_portal_reference` SET TAGS ('dbx_business_glossary_term' = 'National Regulatory Portal Reference');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_value_regex' = 'EU_CTR_536_2014|EU_CTD|national_regulation|ICH_E6|ISO_14155|other');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `suspension_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Suspension Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'CTA Suspension Reason');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `trial_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `trial_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase IIa|Phase IIb|Phase III');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Validation Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'CTA Withdrawal Reason');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` SET TAGS ('dbx_subdomain' = 'authority_registry');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `conditional_approval` SET TAGS ('dbx_business_glossary_term' = 'Conditional Approval Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_value_regex' = 'full|abridged|hybrid|bibliographic');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Registered Dosage Form');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|VNeeS');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Registration Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Registered Indication');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `last_annual_report_date` SET TAGS ('dbx_business_glossary_term' = 'Last Annual Report Submission Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `last_variation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Variation Approval Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_business_glossary_term' = 'Local Agent Contact Information');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_business_glossary_term' = 'Local Agent / Marketing Authorization Holder Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `market_exclusivity_expiry` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Registration Notes');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Registered Product Name');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `registration_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|withdrawn|pending|cancelled');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `registration_type` SET TAGS ('dbx_value_regex' = 'national|mutual_recognition|decentralized|centralized|bilateral');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `reimbursement_status` SET TAGS ('dbx_value_regex' = 'reimbursed|not_reimbursed|partial|pending|under_review');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'Registered Strength');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `submission_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}$');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `submission_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');
