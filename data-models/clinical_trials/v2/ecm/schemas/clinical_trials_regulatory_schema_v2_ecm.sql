-- Schema for Domain: regulatory | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:03:00

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`regulatory` COMMENT 'Manages regulatory submissions, approvals, and agency interactions across global health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Owns IND/NDA/BLA/MAA applications, clinical trial authorizations, protocol amendments, regulatory correspondence';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`submission` (
    `submission_id` BIGINT COMMENT 'Unique system-generated identifier for each regulatory submission record. Primary key for the submission data product.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Submissions (eCTD sequences) belong to a regulatory application; submission only holds application_number STRING. Add application_id FK.',
    `controlled_terminology_codelist_id` BIGINT COMMENT 'Optional CDISC CT codelist governing categorical values on this record.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns this regulatory submission.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this regulatory submission is made.',
    `submitter_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The regulatory affairs employee who prepares and submits dossiers must be traceable for submission workload reporting, audit trails, and GCP inspection readiness.',
    `target_health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: A submission is sent to a target health authority but only stores target_agency STRING. Normalize to health_authority FK. No reverse FK exists.',
    `agency_acknowledgement_number` STRING COMMENT 'Official reference number or acknowledgement identifier issued by the health authority upon receipt of the submission (e.g., FDA STN number, EMA submission number). Used for all subsequent agency correspondence.',
    `agency_action_date` DATE COMMENT 'Actual date on which the health authority issued its regulatory decision or action (approval, complete response letter, refusal to file, approvable letter, etc.). Compared against target_action_date to measure review performance.',
    `agency_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the health authority jurisdiction to which this submission is directed (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-regional submission tracking.. Valid values are `^[A-Z]{3}$`',
    `agency_decision` STRING COMMENT 'The formal regulatory decision issued by the health authority in response to this submission (e.g., approved, complete response letter (CRL), refuse to file (RTF), approvable, not approvable, withdrawn). Drives downstream regulatory strategy.',
    `agency_receipt_date` DATE COMMENT 'Date on which the health authority officially acknowledged receipt of the submission. Triggers the start of the agency review clock for PDUFA/regulatory review timelines.',
    `submission_category` STRING COMMENT 'High-level regulatory category of the submission indicating the application type: IND (Investigational New Drug), NDA (New Drug Application), BLA (Biologics License Application), MAA (Marketing Authorization Application), CTA (Clinical Trial',
    `cover_letter_title` STRING COMMENT 'The official title or subject line of the cover letter accompanying this submission, as filed with the health authority. Provides a human-readable summary of the submission purpose for regulatory correspondence tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this submission record was first created in the system of record (Veeva Vault). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_module_scope` STRING COMMENT 'Identifies which CTD module(s) are included in this submission (e.g., Module 1 - Administrative, Module 2 - Summaries, Module 3 - Quality, Module 4 - Nonclinical, Module 5 - Clinical). Supports dossier completeness tracking.',
    `submission_date` DATE COMMENT 'The actual calendar date on which the submission was transmitted or delivered to the target health authority. This is the principal real-world event date for regulatory timeline calculations and compliance tracking.',
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
    `prior_sequence_number` STRING COMMENT 'The eCTD sequence number of the immediately preceding submission in the dossier lifecycle that this submission amends, replaces, or responds to. Enables reconstruction of the full dossier evolution chain.. Valid values are `^[0-9]{4}$`',
    `reason` STRING COMMENT 'Narrative or coded reason for this submission event (e.g., initial IND filing, protocol amendment for safety update, response to FDA information request, annual IND report, post-approval labeling change).',
    `regulatory_procedure_type` STRING COMMENT 'Specific regulatory procedure under which this submission is filed (e.g., standard review, priority review, accelerated approval, breakthrough therapy, orphan drug, centralized procedure, mutual recognition procedure, decentralized procedure).',
    `resubmission_class` STRING COMMENT 'For FDA resubmissions following a complete response letter (CRL), the classification of the resubmission: Class 1 (2-month review goal) or Class 2 (6-month review goal), based on the nature of the response. Null or not_applicable for non-resubmissions.. Valid values are `class_1|class_2|not_applicable`',
    `sequence_number` STRING COMMENT 'Four-digit zero-padded sequence number identifying the specific eCTD submission sequence within a dossier lifecycle (e.g., 0000 for initial submission, 0001 for first amendment). Conforms to ICH M8 eCTD specification.. Valid values are `^[0-9]{4}$`',
    `submission_status` STRING COMMENT 'Current lifecycle state of the submission: draft (being prepared), pending (awaiting dispatch), submitted (sent to agency), validated (passed technical validation), accepted (agency acknowledged receipt), rejected (agency refused), or withdrawn (sponsor',
    `target_action_date` DATE COMMENT 'The regulatory deadline by which the health authority is expected to take action on the submission (e.g., PDUFA goal date for FDA NDA/BLA reviews, EMA opinion deadline). Critical for regulatory milestone tracking and resource planning.',
    `therapeutic_area` STRING COMMENT 'The clinical or disease area that the investigational product targets (e.g., oncology, cardiology, neurology, infectious disease, rare disease). Used for portfolio analytics and regulatory strategy segmentation.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone) at which the submission was electronically transmitted to the health authority gateway. Used for exact regulatory deadline compliance and audit trail purposes per 21 CFR Part 11.',
    `submission_type` STRING COMMENT 'Classification of the submission event in the dossier lifecycle: original (first submission), amendment (change to an approved application), supplement (post-approval change), response (reply to agency query or complete response letter), or withdrawal. Valid values are `original|amendment|supplement|response|withdrawal`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this submission record was most recently modified in the system of record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `validation_status` STRING COMMENT 'Technical validation outcome of the eCTD dossier package against agency-published validation criteria (e.g., FDA eCTD Validation Criteria, EMA eCTD Specification).. Valid values are `not_validated|passed|failed|waived`',
    `veeva_vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault (eTMF/Regulatory Submissions module) to the submission package or primary dossier document. Enables direct traceability to the source system of record.',
    CONSTRAINT pk_submission PRIMARY KEY(`submission_id`)
) COMMENT 'Master record for regulatory submissions and eCTD sequences sent to health authorities (FDA, EMA, PMDA, MHRA, Health Canada). Each record represents a discrete submission event with sequence number, submission type (original, amendment, supplement';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`application` (
    `application_id` BIGINT COMMENT 'Unique surrogate identifier for the regulatory application record in the lakehouse silver layer. Primary key for all downstream joins to submissions, correspondence, approvals, and commitments under this dossier.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Regulatory applications are filed for specific indications. application.indication is a denormalized text field.',
    `lead_agency_health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: application is a master regulatory application filed with a lead health authority but has only a lead_agency STRING, no FK. Normalize to health_authority.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity that owns this regulatory application. Enables sponsor-level portfolio reporting across all applications.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — regulatory applications are submitted for specific studies',
    `accelerated_approval` BOOLEAN COMMENT 'Indicates whether this application is approved or being reviewed under the FDA Accelerated Approval pathway, based on a surrogate or intermediate clinical endpoint reasonably likely to predict clinical benefit. Requires post-approval confirmatory trials.',
    `agency_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the health authority jurisdiction (e.g., USA, GBR, JPN, CAN, AUS). Supports multi-regional dossier tracking and jurisdiction-specific compliance reporting.. Valid values are `^[A-Z]{3}$`',
    `agency_receipt_date` DATE COMMENT 'Date the health authority officially acknowledged receipt of the application. May differ from initial_filing_date if the agency issues a receipt acknowledgment letter after a validation check.',
    `annual_report_last_submitted_date` DATE COMMENT 'Date the most recent IND Annual Report was submitted to FDA. Used to calculate the next due date and to confirm compliance with 21 CFR 312.33 annual reporting obligations.',
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
    `application_status` STRING COMMENT 'Current lifecycle status of the regulatory application. active = application is open and under review or in use; approved = marketing authorization or IND in good standing with approval; withdrawn = sponsor voluntarily withdrew; refused = agency. Valid values are `active|approved|withdrawn|refused|on_clinical_hold|inactive`',
    `submission_format` STRING COMMENT 'Technical format used for dossier submission to the health authority. eCTD (Electronic Common Technical Document) is the standard for FDA, EMA, PMDA; NeeS (Non-eCTD Electronic Submission) is a transitional format; paper submissions are legacy.. Valid values are `eCTD|NeeS|paper|eCTD_v4`',
    `subtype` STRING COMMENT 'Further classification within the application type. Examples for IND: Commercial, Research, Treatment, Emergency; for NDA: 505(b)(1) Full, 505(b)(2), 505(j) ANDA; for BLA: Original, Supplement, Efficacy Supplement.',
    `therapeutic_area` STRING COMMENT 'Broad disease or medical specialty area covered by the application (e.g., Oncology, Cardiology, Neurology, Infectious Disease, Immunology). Used for portfolio segmentation, resource allocation, and regulatory strategy reporting.',
    `application_type` STRING COMMENT 'Classification of the regulatory application by submission type. IND = Investigational New Drug; NDA = New Drug Application; BLA = Biologics License Application; MAA = Marketing Authorization Application; CTA = Clinical Trial Authorization; IMPD =. Valid values are `IND|NDA|BLA|MAA|CTA|IMPD`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory application record was most recently modified. Supports change tracking, data lineage, and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_dossier_reference` STRING COMMENT 'Cross-reference identifier linking this application record to the corresponding eTMF/regulatory dossier in Veeva Vault (the system of record for regulatory submissions and document management).',
    CONSTRAINT pk_application PRIMARY KEY(`application_id`)
) COMMENT 'Master record for regulatory applications (IND, NDA, BLA, MAA, CTA, IMPD) filed with health authorities. Tracks application number, application type and subtype, therapeutic area, indication, sponsor reference, lead agency, application status (active';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` (
    `health_authority_id` BIGINT COMMENT 'Unique surrogate identifier for the health authority record in the regulatory reference master. Primary key for all downstream FK references across submission, application, correspondence, and authorization records.',
    `country_codelist_term_id` BIGINT COMMENT 'add column country_codelist_term_id (BIGINT) with FK to datamanagement.codelist_term.codelist_term_id — health_authority is a reference table with zero outbound FKs; it should at minimum reference the country it governs',
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

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` (
    `submission_sequence_id` BIGINT COMMENT 'Unique surrogate identifier for each eCTD submission sequence record within the regulatory application dossier.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND, NDA, BLA, MAA, CTA) to which this submission sequence belongs.',
    `employee_id` BIGINT COMMENT 'Reference to the internal regulatory affairs professional responsible for preparing and submitting this sequence. Supports accountability tracking and ALCOA+ compliance.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Each eCTD submission sequence is sent to a specific health authority. The regulatory_authority_code and submission_country_code STRING fields on submission_sequence are',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor on whose behalf this submission sequence was filed. Supports multi-sponsor CRO operations and sponsor-level regulatory reporting.',
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
    `prior_sequence_number` STRING COMMENT 'Four-digit sequence number of the immediately preceding submission sequence that this sequence supersedes or builds upon. Enables reconstruction of the dossier evolution chain and supports lifecycle operation traceability.. Valid values are `^[0-9]{4}$`',
    `response_due_date` DATE COMMENT 'Deadline by which the sponsor must submit a response to an agency information request or complete response letter associated with this submission sequence. Null if no response is required.',
    `review_clock_start_date` DATE COMMENT 'Date on which the regulatory authoritys formal review clock begins for this submission sequence (e.g., PDUFA Day 1 for FDA, Day 0 for EMA). Derived from agency acknowledgement and used for PDUFA/review deadline tracking.',
    `review_clock_target_date` DATE COMMENT 'Target date by which the regulatory authority is expected to complete review of this submission sequence, calculated from the review clock start date per applicable PDUFA or EMA timelines. Critical for regulatory milestone planning.',
    `sequence_number` STRING COMMENT 'Four-digit zero-padded sequence number uniquely identifying this submission within the regulatory application lifecycle (e.g., 0000 for original, 0001 for first amendment).. Valid values are `^[0-9]{4}$`',
    `submission_subtype` STRING COMMENT 'Further classification of the submission type providing regulatory-specific granularity (e.g., Prior Approval Supplement, Changes Being Effected, Complete Response, Major Amendment, Minor Amendment).',
    `submission_unit` STRING COMMENT 'The specific regulatory submission unit or grouping within the eCTD backbone that this sequence belongs to (e.g., IND Safety Report, NDA Module 5 Clinical Study Report, BLA CMC Supplement). Aligns with Veeva Vault RIM submission unit taxonomy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this submission sequence record, supporting audit trail and data lineage requirements under 21 CFR Part 11 and ALCOA+.',
    CONSTRAINT pk_submission_sequence PRIMARY KEY(`submission_sequence_id`)
) COMMENT 'Tracks individual eCTD submission sequences within a regulatory application. Each sequence has a sequence number, submission type (original, amendment, supplement, response, withdrawal), sequence date, eCTD lifecycle operation (new, replace, append';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` (
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for the protocol amendment record in the regulatory domain. Primary key for this entity.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Protocol amendments are submitted to specific health authorities and ethics committees.',
    `parent_application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND/NDA/BLA/MAA/CTA) under which this protocol amendment is filed.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific study protocol document that this amendment modifies.',
    `regulatory_affairs_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The regulatory affairs lead managing a protocol amendment is a workforce employee. Amendment workload tracking, agency submission accountability, and GCP inspection readiness all require',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study to which this protocol amendment belongs.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Protocol amendments are submitted to health authorities as part of regulatory submissions (eCTD sequences).',
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
    `ectd_sequence_number` STRING COMMENT 'Sequence number assigned to the eCTD submission package containing this protocol amendment, as tracked in Veeva Vault regulatory submissions module. Enables traceability to the specific eCTD lifecycle submission.',
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
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault eTMF/regulatory binder for the amendment package. Provides direct traceability to the source document management system of record.',
    CONSTRAINT pk_regulatory_protocol_amendment PRIMARY KEY(`regulatory_protocol_amendment_id`)
) COMMENT 'Tracks protocol amendments submitted to health authorities and ethics committees. Captures amendment number, amendment type (substantial/non-substantial), amendment rationale, affected study sections, submission date to each agency, agency acknowledgment';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` (
    `correspondence_id` BIGINT COMMENT 'Primary key for correspondence',
    `agency_meeting_id` BIGINT COMMENT 'Foreign key linking to regulatory.agency_meeting. Business justification: Regulatory correspondence frequently arises from or relates to agency meetings — meeting request letters, briefing documents, meeting minutes, and follow-up correspondence are all',
    `application_id` BIGINT COMMENT 'Reference to the regulatory application (IND/NDA/BLA/MAA) under which this correspondence is filed. Enables grouping of all correspondence across the application lifecycle.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Regulatory correspondence may be generated in response to audit findings requiring agency notification.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Formal regulatory correspondence is exchanged with specific health authorities.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor on whose behalf the correspondence is sent or received. Required for multi-sponsor CRO environments.',
    `parent_correspondence_id` BIGINT COMMENT 'Self-referencing identifier linking this correspondence to a prior or related correspondence record (e.g., a response linked to the original information request, or a follow-up linked to a meeting minutes record). Enables correspondence thread tracking.',
    `regulatory_contact_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The employee managing agency correspondence owns response deadlines and escalation decisions — a core regulatory operations accountability requirement.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_inspection. Business justification: Regulatory correspondence (FDA information requests, inspection-related queries) is frequently triggered by or related to inspections.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or protocol to which this regulatory correspondence pertains. Supports study-level regulatory intelligence and inspection readiness.',
    `submission_id` BIGINT COMMENT 'Reference to the regulatory submission (IND, NDA, BLA, MAA, CTA) with which this correspondence is associated. Links correspondence to its parent dossier context.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory correspondence (agency letters, complete response letters, information requests) are TMF Zone 1 essential documents.',
    `action_required` STRING COMMENT 'Description of the specific action(s) required by the sponsor or CRO in response to this correspondence (e.g., Submit updated clinical protocol within 30 days, Provide additional safety data for Module 5). Drives task assignment and workflow.',
    `agency_division` STRING COMMENT 'The specific division, office, or directorate within the health authority handling this correspondence (e.g., FDA CDER Division of Oncology Products, EMA Committee for Medicinal Products for Human Use). Supports targeted regulatory relationship management.',
    `agency_reference_number` STRING COMMENT 'The official reference number assigned by the health authority (FDA, EMA, PMDA, MHRA, Health Canada) to this correspondence or the associated submission. Used for tracking agency-side docket and regulatory intelligence.',
    `amendment_number` STRING COMMENT 'The protocol amendment number associated with this correspondence, when the correspondence relates to a protocol amendment submission or agency review thereof. Links correspondence to the specific amendment version.',
    `clinical_hold_flag` BOOLEAN COMMENT 'Indicates whether this correspondence is associated with an FDA clinical hold order (full or partial) under 21 CFR Part 312.42. When True, triggers immediate escalation and study suspension workflows.',
    `confidentiality_level` STRING COMMENT 'Confidentiality level assigned to this correspondence.. Valid values are `public|internal|confidential|restricted`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the health authority jurisdiction to which this correspondence pertains (e.g., USA for FDA, DEU/NLD for EMA, JPN for PMDA, GBR for MHRA, CAN for Health Canada). Enables multi-country regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this correspondence record was first created in the system (Veeva Vault / CTMS). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_section` STRING COMMENT 'The CTD/eCTD dossier section to which this correspondence relates (e.g., Module 2.7.4 Summary of Clinical Safety, Module 5.3.5 Reports of Controlled Clinical Studies). Enables dossier-level regulatory intelligence.',
    `correspondence_date` DATE COMMENT 'The official date on which the correspondence was issued, sent, or received. This is the principal real-world event date used for regulatory timeline calculations and compliance tracking.',
    `direction` STRING COMMENT 'Indicates whether the correspondence was received from the health authority (inbound) or sent to the health authority (outbound) by the sponsor or CRO. Critical for response tracking and regulatory intelligence.. Valid values are `inbound|outbound`',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this correspondence has been escalated to senior regulatory leadership or the sponsor due to urgency, clinical hold, refuse-to-file, or overdue response. Drives escalation workflow in CTMS.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this correspondence has been reviewed and confirmed as inspection-ready for regulatory authority audits (FDA, EMA, MHRA). Supports TMF completeness and inspection readiness assessments.',
    `language_code` STRING COMMENT 'ISO 639-1/639-2 language code of the correspondence document (e.g., en for English, ja for Japanese, de for German). Required for multi-regional submissions and translation tracking.. Valid values are `^[a-z]{2,3}$`',
    `meeting_type` STRING COMMENT 'For correspondence related to agency meetings, the FDA meeting type classification (Type A, B, C) or equivalent EMA/PMDA meeting category. Applicable when correspondence_type is meeting_minutes or meeting_request.',
    `number` STRING COMMENT 'Internally assigned unique reference number for this correspondence record, used for tracking and cross-referencing within the CTMS and eTMF (e.g., CORR-2024-00123). Serves as the business identifier for audit trails.',
    `priority_level` STRING COMMENT 'Business-assigned priority level indicating the urgency of the correspondence and required response. Critical items (e.g., clinical holds, refuse-to-file letters) require immediate escalation.. Valid values are `critical|high|medium|low`',
    `received_date` DATE COMMENT 'The date on which the correspondence was physically or electronically received by the sponsor or CRO (for inbound) or confirmed received by the agency (for outbound). May differ from correspondence_date due to postal or electronic transmission delays.',
    `response_date` DATE COMMENT 'The actual date on which the sponsor or CRO submitted the response to the health authority. Used to calculate response timeliness and compliance with regulatory deadlines.',
    `response_due_date` DATE COMMENT 'The regulatory deadline by which a response must be submitted to the health authority. Calculated based on agency-mandated timelines (e.g., 30-day FDA information request response window). Critical for inspection readiness and compliance.',
    `response_required_flag` BOOLEAN COMMENT 'Indicates whether a formal response to the health authority is required for this correspondence. When True, activates response tracking, due date monitoring, and escalation workflows.',
    `response_submitted_flag` BOOLEAN COMMENT 'Indicates whether the required response has been submitted to the health authority. Used in conjunction with response_required_flag and response_due_date for compliance monitoring and inspection readiness.',
    `sequence_number` BIGINT COMMENT 'The eCTD submission sequence number associated with this correspondence, when the correspondence is linked to a specific eCTD submission sequence. Enables traceability between correspondence and dossier submission history.',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this correspondence.',
    `correspondence_status` STRING COMMENT 'Current lifecycle status of the correspondence record within the regulatory workflow. Drives action queues, escalation triggers, and inspection readiness dashboards.',
    `subject_matter` STRING COMMENT 'Free-text or structured description of the primary subject or topic of the correspondence (e.g., Protocol Amendment Review, Clinical Hold Notification, Safety Data Request). Used for regulatory intelligence and search.',
    `summary` STRING COMMENT 'Structured executive summary of the correspondence content, key regulatory questions raised, commitments made, or decisions communicated. Used for regulatory intelligence, briefing documents, and inspection preparation.',
    `tmf_section` STRING COMMENT 'The TMF reference model section under which this correspondence is filed in the eTMF (e.g., Zone 1.2 Regulatory, Zone 1.2.1 Health Authority Correspondence). Ensures correct eTMF filing and completeness tracking.',
    `transmission_method` STRING COMMENT 'The method by which the correspondence was transmitted to or received from the health authority (eCTD electronic submission gateway, email, fax, postal mail, hand delivery). Required for audit trail and ALCOA+ compliance.. Valid values are `ectd|email|fax|postal|hand_delivery|gateway`',
    `correspondence_type` STRING COMMENT 'Classification of the formal communication type. Drives workflow routing and response obligations. [ENUM-REF-CANDIDATE. Valid values are `information_request|complete_response_letter|refuse_to_file|meeting_minutes|agency_query|label_negotiation`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this correspondence record was most recently modified in the system. Required for change tracking, audit trail compliance, and data lineage in the lakehouse silver layer.',
    `veeva_vault_document_reference` STRING COMMENT 'The document identifier in Veeva Vault eTMF where the correspondence document is stored. Enables direct linkage between the correspondence metadata record and the source document in the eTMF system of record.',
    CONSTRAINT pk_correspondence PRIMARY KEY(`correspondence_id`)
) COMMENT 'Records all formal communications between the sponsor/CRO and health authorities. Includes correspondence type (information request, complete response letter, refuse-to-file, meeting minutes, agency query, label negotiation), direction (inbound/outbound)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` (
    `agency_meeting_id` BIGINT COMMENT 'Unique surrogate identifier for the agency meeting record in the Databricks Silver Layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: FDA Type A/B/C meetings and EMA scientific advice meetings are held in the context of a specific regulatory application (IND, NDA, BLA, MAA).',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Agency meetings are held with specific health authorities (FDA, EMA, PMDA). The agency_code STRING field on agency_meeting is a denormalized reference to',
    `sponsor_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The sponsor lead attending FDA/EMA meetings (Type B, pre-NDA) is a workforce employee. Meeting preparation accountability, action item ownership, and inspection readiness tracking require',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or development program associated with this agency meeting, enabling cross-domain linkage for regulatory strategy planning.',
    `submission_id` BIGINT COMMENT 'Reference to the parent regulatory submission (IND, NDA, BLA, MAA) under which this agency meeting is requested or conducted.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Agency meeting minutes and briefing documents are TMF Zone 1 essential documents per DIA TMF Reference Model.',
    `action_items_count` BIGINT COMMENT 'Total number of action items arising from the agency meeting, as documented in the finalized meeting minutes. Used to track post-meeting follow-up workload and regulatory commitments.',
    `agency_acknowledgement_date` DATE COMMENT 'The date on which the health authority formally acknowledged receipt of the meeting request. Marks the start of the regulatory response clock for PDUFA-governed timelines.',
    `agency_contact_name` STRING COMMENT 'Name of the agency contact person for this meeting.',
    `agency_division` STRING COMMENT 'Specific division, office, or therapeutic area unit within the health authority responsible for the meeting (e.g., FDA Office of Oncology Products, EMA Committee for Medicinal Products for Human Use (CHMP), PMDA Office of New Drug I).',
    `agency_feedback_summary` STRING COMMENT 'Summary of feedback provided by the agency during the meeting.',
    `agency_response_date` DATE COMMENT 'The date on which the health authority provided its formal response to the meeting request (granting, denying, or proposing alternatives). Used to measure agency response time against PDUFA commitments.',
    `briefing_document_due_date` DATE COMMENT 'The deadline by which the sponsor must submit the meeting briefing document (background package) to the health authority prior to the meeting. Typically 30 days before the meeting for FDA Type B meetings.',
    `briefing_document_submission_date` DATE COMMENT 'The actual date on which the meeting briefing document (background package) was submitted to the health authority via eCTD or other regulatory submission channel in Veeva Vault.',
    `briefing_document_version` STRING COMMENT 'Version identifier of the meeting briefing document submitted to the health authority, as tracked in Veeva Vault document management. Enables traceability of the exact document version reviewed by the agency.',
    `confirmed_meeting_date` DATE COMMENT 'The date confirmed by the health authority for the meeting to take place. This is the operationally binding date used for scheduling, briefing document preparation, and attendee coordination.',
    `confirmed_meeting_time` TIMESTAMP COMMENT 'The precise date and time (with timezone) confirmed by the health authority for the meeting, used for scheduling teleconferences and videoconferences across global time zones.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this agency meeting record was first created in the system, used for audit trail and data lineage purposes per 21 CFR Part 11 electronic records requirements.',
    `etmf_section_reference` STRING COMMENT 'The eTMF section or zone reference where the agency meeting documents (request, briefing document, minutes) are filed, per the DIA Reference Model for the TMF. Ensures regulatory inspection readiness and document traceability.',
    `follow_up_submission_due_date` DATE COMMENT 'The deadline by which the sponsor must submit any follow-up regulatory documents or responses to the health authority as agreed during or after the meeting.',
    `follow_up_submission_required` BOOLEAN COMMENT 'Indicates whether the agency meeting outcome requires a follow-up regulatory submission (e.g., protocol amendment, IND amendment, additional data package) as a result of agency feedback or commitments made during the meeting.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether all required documentation for this agency meeting (request, briefing document, minutes, action items) is complete and filed in the eTMF, making the record inspection-ready for FDA, EMA, or other health authority audits.',
    `meeting_duration_minutes` BIGINT COMMENT 'The planned or actual duration of the agency meeting in minutes, as agreed with the health authority. Typically 60–90 minutes for FDA Type B meetings.',
    `meeting_format` STRING COMMENT 'The format in which the agency meeting is conducted. Face-to-Face = in-person at agency or sponsor site; Teleconference = audio-only call; Videoconference = video-enabled remote meeting; Written Response Only = agency responds in writing without a live. Valid values are `Face-to-Face|Teleconference|Videoconference|Written Response Only`',
    `meeting_number` STRING COMMENT 'Externally assigned or internally generated unique reference number for the meeting request, as tracked in Veeva Vault regulatory submissions module and referenced in agency correspondence (e.g., FDA meeting request number).',
    `meeting_objectives` STRING COMMENT 'Free-text description of the primary scientific, regulatory, or strategic objectives for the agency meeting, as stated in the meeting request. Captures the key questions and discussion topics the sponsor seeks to resolve.',
    `meeting_stage` STRING COMMENT 'The clinical development stage at which the agency meeting is requested, indicating the regulatory milestone context (e.g., Pre-IND, End-of-Phase 2, Pre-NDA/BLA submission). Aligns with FDA Type B meeting sub-categories.. Valid values are `Pre-IND|End-of-Phase 1|End-of-Phase 2|Pre-NDA/BLA|Post-Approval|Other`',
    `meeting_status` STRING COMMENT 'Current lifecycle status of the agency meeting. Planned = internally identified need; Requested = formal meeting request submitted to agency; Granted = agency has agreed to hold the meeting; Scheduled = date and format confirmed; Completed = meeting has',
    `meeting_type` STRING COMMENT 'Classification of the meeting per agency-defined categories. FDA meetings are classified as Type A (urgent/critical), Type B (pre-IND, end-of-Phase 2, pre-NDA/BLA), or Type C (other). EMA meetings are classified as Scientific Advice.. Valid values are `Type A|Type B|Type C|Scientific Advice|Consultation|Written Response Only`',
    `minutes_draft_date` DATE COMMENT 'The date on which the draft meeting minutes were prepared by the sponsor following the agency meeting. FDA requires sponsors to submit draft minutes within 30 days of the meeting.',
    `minutes_finalized_date` DATE COMMENT 'The date on which the meeting minutes were finalized and agreed upon by both the sponsor and the health authority. Finalized minutes represent the official record of agency agreements and commitments.',
    `minutes_submitted_date` DATE COMMENT 'The date on which the sponsor submitted the draft meeting minutes to the health authority for review and comment.',
    `nda_bla_number` STRING COMMENT 'The FDA-assigned NDA or BLA application number if the meeting is related to a marketing application. Applicable for pre-NDA/BLA, post-approval, or labeling meetings.',
    `open_action_items_count` BIGINT COMMENT 'Number of action items from the agency meeting that remain open or unresolved. Used for regulatory follow-up tracking and inspection readiness monitoring.',
    `outcome_classification` STRING COMMENT 'Classification of the overall outcome of the agency meeting with respect to the sponsors objectives. Agreement Reached = agency aligned with sponsors proposed approach; Partial Agreement = some questions resolved; No Agreement = agency did not concur. Valid values are `Agreement Reached|Partial Agreement|No Agreement|Pending Agency Response|Information Only`',
    `pdufa_response_deadline` DATE COMMENT 'The regulatory deadline by which the FDA must respond to the meeting request under Prescription Drug User Fee Act (PDUFA) commitments. Type A: 30 days; Type B: 70 days; Type C: 90 days from receipt of meeting request.',
    `product_name` STRING COMMENT 'Name of the investigational product discussed in this meeting.',
    `proposed_meeting_date` DATE COMMENT 'The date proposed by the sponsor in the meeting request for when the meeting should occur. May differ from the agency-confirmed date.',
    `questions_submitted_count` BIGINT COMMENT 'The number of formal questions submitted to the health authority in the meeting request or briefing document. Used to track scope and complexity of the meeting agenda.',
    `request_date` DATE COMMENT 'The date on which the formal meeting request was submitted to the health authority. This is the principal business event timestamp that initiates the regulatory clock for agency response timelines under PDUFA commitments.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication relevant to the meeting (e.g., Oncology, Cardiovascular, Neurology, Infectious Disease). Used for regulatory strategy analytics and agency workload tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this agency meeting record was last modified, supporting audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `veeva_vault_document_reference` STRING COMMENT 'The document identifier in Veeva Vault eTMF/regulatory submissions module for the meeting request package, briefing document, or meeting minutes. Enables direct traceability to the source document management system.',
    CONSTRAINT pk_agency_meeting PRIMARY KEY(`agency_meeting_id`)
) COMMENT 'Master record for formal meetings with health authorities (FDA Type A/B/C meetings, EMA scientific advice, PMDA consultations). Tracks meeting type, request date, agency-confirmed date, meeting format (face-to-face, teleconference, written response)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` (
    `ctd_dossier_id` BIGINT COMMENT 'Unique system-generated identifier for the CTD dossier record. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND, NDA, BLA, MAA, CTA) to which this CTD dossier belongs.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: CTD dossier compilation is subject to QA audit before submission to verify completeness and compliance.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: CTD dossiers are prepared and compiled for specific health authorities (FDA, EMA, PMDA).',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: A CTD dossier is physically packaged as a regulatory binder for submission. Publishing teams compile the dossier into a binder; this FK enables dossier-to-binder traceability for',
    `regulatory_contact_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The employee responsible for CTD dossier compilation, gap analysis, and publishing is accountable for submission readiness.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Reference to the specific regulatory submission sequence this dossier version supports.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The CTD dossier compilation report and validation report are TMF Zone 1 documents. Linking the dossier record to its TMF document enables inspection-ready retrieval of the dossier',
    `actual_submission_date` DATE COMMENT 'Date on which the CTD dossier was actually submitted to the regulatory agency. Null until submission occurs.',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when the CTD dossier was formally approved internally for submission. Captures the approval event in the dossier lifecycle per 21 CFR Part 11 electronic signature requirements.',
    `archival_location` STRING COMMENT 'Physical or electronic archival location of the compiled CTD dossier package (e.g., Veeva Vault path, network share, or physical archive reference). Required for inspection readiness and long-term retention.',
    `comments` STRING COMMENT 'Free-text field for regulatory affairs team notes, submission strategy remarks, or outstanding action items related to the CTD dossier.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the CTD dossier record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_format` STRING COMMENT 'Submission format of the CTD dossier. eCTD (Electronic Common Technical Document) is the standard for FDA, EMA, and PMDA. NeeS (Non-eCTD Electronic Submission) and paper formats are legacy options.. Valid values are `eCTD|NeeS|paper|VNeeS`',
    `dossier_number` STRING COMMENT 'Externally-known unique business identifier for the CTD dossier, used in regulatory correspondence and Veeva Vault tracking. Format: CTD-{AppCode}-{Year}-{Seq}.. Valid values are `^CTD-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{3}$`',
    `dossier_status` STRING COMMENT 'Current lifecycle status of the CTD dossier. Tracks progression from authoring through regulatory submission and archival.. Valid values are `draft|in_review|approved|submitted|archived|withdrawn`',
    `dossier_title` STRING COMMENT 'Human-readable title of the CTD dossier, typically including the drug name, application type, and submission sequence (e.g., DrugX NDA Initial Submission CTD Dossier).',
    `dossier_type` STRING COMMENT 'Classification of the dossier submission type. Initial submissions establish the application; amendments and supplements update specific modules; annual reports fulfill periodic reporting obligations.. Valid values are `initial|amendment|supplement|annual_report|response_to_query`',
    `dossier_version` STRING COMMENT 'Version number of the CTD dossier (e.g., 1.0, 2.1). Incremented with each major revision or amendment cycle.. Valid values are `^[0-9]+.[0-9]+$`',
    `drug_name` STRING COMMENT 'Name of the investigational drug or biologic product that is the subject of the CTD dossier (proprietary name, INN, or code name).',
    `dtd_version` STRING COMMENT 'Version of the eCTD Document Type Definition (DTD) or XML schema used for the dossier backbone (e.g., 3.2.2 for FDA, 4.0 for EMA). Determines structural compliance requirements.',
    `gap_analysis_date` DATE COMMENT 'Date on which the most recent dossier gap analysis was completed. Used to assess the currency of the gap analysis relative to dossier updates.',
    `gap_analysis_status` STRING COMMENT 'Status of the formal gap analysis conducted to identify missing or incomplete content units within the CTD dossier prior to submission.. Valid values are `not_started|in_progress|complete|remediation_required`',
    `indication` STRING COMMENT 'The therapeutic indication or disease area for which the drug is being developed and for which the CTD dossier is submitted.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether the CTD dossier has been assessed and confirmed as ready for regulatory agency inspection. True when all required documents are present, validated, and accessible.',
    `last_compiled_date` DATE COMMENT 'Date on which the CTD dossier was most recently compiled and packaged for submission or review. Tracks the currency of the assembled dossier.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the CTD dossier record. Required for audit trail and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `module1_status` STRING COMMENT 'Completeness status of CTD Module 1 (Regional Administrative Information), which contains region-specific forms, cover letters, and labeling. Content varies by target agency.. Valid values are `not_started|in_progress|complete|not_applicable`',
    `module2_status` STRING COMMENT 'Completeness status of CTD Module 2 (CTD Summaries), including the Quality Overall Summary (QOS), Nonclinical Overview, Clinical Overview, Nonclinical Written and Tabulated Summaries, and Clinical Summary.. Valid values are `not_started|in_progress|complete|not_applicable`',
    `module3_status` STRING COMMENT 'Completeness status of CTD Module 3 (Quality), covering drug substance, drug product, and related quality documentation per ICH M4Q.. Valid values are `not_started|in_progress|complete|not_applicable`',
    `module4_status` STRING COMMENT 'Completeness status of CTD Module 4 (Nonclinical Study Reports), including pharmacology, pharmacokinetics, and toxicology study reports per ICH M4S.. Valid values are `not_started|in_progress|complete|not_applicable`',
    `module5_status` STRING COMMENT 'Completeness status of CTD Module 5 (Clinical Study Reports), including all clinical pharmacology, efficacy, and safety study reports per ICH M4E.. Valid values are `not_started|in_progress|complete|not_applicable`',
    `open_gap_count` BIGINT COMMENT 'Number of identified content gaps (missing or incomplete documents/sections) that remain unresolved in the current dossier version. Key metric for submission readiness.',
    `overall_completeness_status` STRING COMMENT 'Aggregate readiness assessment of the entire CTD dossier across all five modules. Used for dossier gap analysis and submission readiness reviews.. Valid values are `incomplete|substantially_complete|complete|gap_identified`',
    `planned_submission_date` DATE COMMENT 'Target date on which the CTD dossier is planned to be submitted to the regulatory agency. Used for milestone tracking and resource planning.',
    `prior_submission_reference` STRING COMMENT 'Reference number of the prior submission or dossier version that this submission amends or supplements. Enables lineage tracking across submission cycles.',
    `publishing_tool` STRING COMMENT 'Name and version of the publishing software used to compile and validate the eCTD dossier (e.g., Lorenz docuBridge, Extedo eCTD Manager, Veeva Vault RIM Publisher). Critical for reproducibility and troubleshooting.',
    `publishing_tool_version` STRING COMMENT 'Version number of the publishing tool used to compile this dossier. Required for audit trail and reproducibility of the eCTD package.',
    `sponsor_name` STRING COMMENT 'Name of the sponsor organization responsible for the dossier.',
    `total_document_count` BIGINT COMMENT 'Total number of individual content units (documents, datasets, study reports) included in this CTD dossier version. Used for completeness tracking and submission package verification.',
    `validation_report_date` DATE COMMENT 'Date on which the most recent eCTD technical validation report was generated for this dossier.',
    `validation_report_status` STRING COMMENT 'Status of the eCTD technical validation report generated by the publishing tool. Agencies require a passing validation report before accepting eCTD submissions.. Valid values are `pending|passed|failed|passed_with_warnings`',
    `veeva_vault_binder_reference` STRING COMMENT 'Identifier of the Veeva Vault submission binder that organizes all CTD documents for this dossier. Enables navigation of the dossier structure within Veeva Vault.',
    `veeva_vault_dossier_reference` STRING COMMENT 'Unique document identifier assigned by Veeva Vault RIM to the CTD dossier record. Used for cross-system traceability between the lakehouse and the Veeva Vault eTMF/regulatory submissions system.',
    CONSTRAINT pk_ctd_dossier PRIMARY KEY(`ctd_dossier_id`)
) COMMENT 'Master record for the Common Technical Document (CTD) dossier structure and content inventory associated with a regulatory application. Tracks CTD format (eCTD/NeeS/paper), dossier version, completeness status, module-level readiness (Modules 1-5), last';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`approval` (
    `approval_id` BIGINT COMMENT 'Primary key for approval',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Regulatory approvals are granted for specific regulatory applications (NDA, BLA, MAA, CTA).',
    `primary_approval_health_authority_id` BIGINT COMMENT 'Reference to the health authority or regulatory agency (e.g., FDA, EMA, PMDA, MHRA, Health Canada, TGA) that issued this approval decision.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or program for which this regulatory approval was granted. Enables cross-domain linkage between regulatory decisions and study operations.',
    `submission_id` BIGINT COMMENT 'Reference to the parent regulatory submission (IND, NDA, BLA, MAA, CTA) that resulted in this approval decision. Links approval back to the originating dossier.',
    `tertiary_approval_health_authority_id` BIGINT COMMENT 'FK to regulatory.health_authority',
    `agency_decision_date` DATE COMMENT 'The official date on which the health authority issued its approval decision or authorization. This is the principal real-world event date for the approval transaction, as recorded in the agency approval letter.',
    `agency_decision_rationale` STRING COMMENT 'Summary of the health authoritys stated rationale or basis for the approval decision, as documented in the approval letter, assessment report, or public review document. Captures key scientific and regulatory justification.',
    `approved_dose` STRING COMMENT 'The approved dose or dose range as specified in the regulatory approval (e.g., 10 mg once daily, 200 mg/m² every 3 weeks). Captures the label-approved dosing regimen for the approved indication and population.',
    `approved_indication` STRING COMMENT 'The specific disease, condition, or therapeutic indication for which the health authority has granted approval. Reflects the exact label language or CTA scope as approved (e.g., Treatment of moderate-to-severe plaque psoriasis in adults).',
    `approved_population` STRING COMMENT 'Description of the patient population covered by the approval, including age group, disease severity, prior treatment requirements, or other eligibility criteria as specified in the approved label or CTA (e.g., Adults ≥18 years with inadequate response',
    `compliance_inspection_code` BIGINT COMMENT 'Foreign key linking to compliance.inspection. Business justification: Pre-approval inspections (PAIs) are a standard FDA/EMA step before granting marketing approval.',
    `conditions_of_approval` STRING COMMENT 'Narrative description of any conditions, restrictions, or requirements attached to the approval by the health authority (e.g., REMS requirements, restricted distribution, mandatory risk minimization measures, specific labeling requirements).',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory approval record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `dosage_form` STRING COMMENT 'The pharmaceutical dosage form approved by the health authority (e.g., tablet, capsule, injection, infusion, patch). Reflects the specific formulation covered by the approval as stated in the approved label.',
    `drug_name` STRING COMMENT 'The International Nonproprietary Name (INN) or brand name of the drug, biologic, or investigational medicinal product covered by this approval. Denormalized for regulatory reporting and label management.',
    `ectd_sequence_number` STRING COMMENT 'The eCTD sequence number of the submission cycle that received this approval decision. Enables direct linkage to the specific eCTD dossier version in Veeva Vault that was reviewed and approved by the agency.. Valid values are `^[0-9]{4}$`',
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
    `approval_status` STRING COMMENT 'Current lifecycle status of the regulatory approval. Tracks whether the approval is active, conditionally approved (with post-marketing commitments), withdrawn by sponsor, suspended or revoked by the agency, or pending final decision.. Valid values are `APPROVED|CONDITIONALLY_APPROVED|WITHDRAWN|SUSPENDED|REVOKED|PENDING`',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease category associated with the approved indication (e.g., Oncology, Cardiovascular, Immunology, Neurology, Infectious Disease). Used for portfolio analytics and regulatory strategy reporting.',
    `approval_type` STRING COMMENT 'Classification of the regulatory approval or authorization received. Distinguishes between IND allowance (Investigational New Drug), NDA approval (New Drug Application), BLA approval (Biologics License Application), MAA approval (Marketing Authorization. Valid values are `IND_ALLOWANCE|NDA_APPROVAL|BLA_APPROVAL|MAA_APPROVAL|CTA_AUTHORIZATION|LABEL_APPROVAL`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory approval record was most recently modified. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `veeva_vault_document_reference` STRING COMMENT 'The document identifier in Veeva Vault (eTMF/regulatory submissions module) for the approval letter or decision document. Enables direct navigation to the source document in the system of record.',
    CONSTRAINT pk_approval PRIMARY KEY(`approval_id`)
) COMMENT 'Records regulatory approvals, authorizations, and decisions received from health authorities. Captures approval type (IND allowance, NDA approval, MAA approval, CTA authorization, label approval), approval date, effective date, approved indication';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` (
    `ind_application_id` BIGINT COMMENT 'Unique surrogate identifier for the IND application record in the lakehouse silver layer. Primary key for this entity.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: ind_application is filed with the FDA or equivalent competent authority but only stores regulatory_agency STRING. Normalize to a health_authority FK. No reverse FK exists.',
    `parent_application_id` BIGINT COMMENT 'Reference to the parent regulatory application record when this IND is a sub-application or cross-references a master NDA/BLA/MAA application. Enables hierarchical navigation of the regulatory application portfolio.',
    `responsible_regulatory_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The regulatory lead managing an IND is accountable for annual reports, clinical hold responses, and protocol submissions. IND lifecycle management requires a traceable workforce employee.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
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
    `nda_bla_number` STRING COMMENT 'The NDA or BLA application number to which this IND is expected to transition upon successful completion of clinical development. Nullable for early-phase INDs where the downstream marketing application has not yet been filed.',
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
    `veeva_vault_document_reference` STRING COMMENT 'The document identifier in Veeva Vault eTMF corresponding to the master IND application dossier. Enables direct cross-reference to the regulatory binder and TMF artifact in the document management system.',
    `withdrawal_date` DATE COMMENT 'The date on which the sponsor formally withdrew the IND application from FDA. Nullable for non-withdrawn INDs. Triggers archival obligations and cessation of all clinical activities under the IND.',
    CONSTRAINT pk_ind_application PRIMARY KEY(`ind_application_id`)
) COMMENT 'Specialized master record for Investigational New Drug (IND) applications filed with the FDA (or equivalent CTAs with EMA/MHRA). Tracks IND number, IND type (commercial, research, emergency), sponsor name, investigational product name, phase coverage';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` (
    `nda_bla_application_id` BIGINT COMMENT 'Unique surrogate identifier for the NDA, BLA, or equivalent marketing authorization application record in the lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: nda_bla_application is a specialized master record that extends the generic application record for NDA/BLA/MAA submissions, mirroring the pattern of',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Pre-NDA/BLA submission QA audits are a mandatory step in regulatory operations. The audit record must reference the NDA/BLA application being audited, supporting the submission quality',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: nda_bla_application stores the reviewing authority as a health_authority STRING. Normalize to a health_authority_id FK. No reverse FK exists; no cycle.',
    `organization_id` BIGINT COMMENT 'FK to sponsor.organization',
    `project_manager_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The project manager for an NDA/BLA owns PDUFA goal date tracking, rolling review coordination, and advisory committee preparation — all named regulatory operations processes.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: NDA/BLA applications are assembled as regulatory binders for eCTD submission. Linking the NDA/BLA application record to its primary regulatory binder enables application-level',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
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
    `ectd_sequence_number` STRING COMMENT 'Four-digit eCTD sequence number assigned to the initial submission or most recent submission sequence in the eCTD lifecycle. Used to track the dossier version in Veeva Vault regulatory submissions.. Valid values are `^[0-9]{4}$`',
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

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` (
    `regulatory_program_milestone_id` BIGINT COMMENT 'Unique surrogate identifier for each regulatory milestone record in the lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND, NDA, BLA, MAA, CTA) to which this milestone belongs.',
    `employee_id` BIGINT COMMENT 'Reference to the responsible regulatory affairs lead or manager accountable for achieving this milestone.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Regulatory milestones are tracked per health authority (FDA PDUFA date, EMA opinion date, PMDA approval date).',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Regulatory milestones (IND submission, NDA filing, approval) are often driven by regulatory obligations with specific deadlines.',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: Regulatory milestones (IND submission, NDA filing, approval) are synchronized with program-level milestones for integrated critical-path analysis.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or protocol for which this regulatory milestone is being tracked.',
    `study_milestone_id` BIGINT COMMENT 'foreign key to study.study_milestone for study-level milestones',
    `submission_id` BIGINT COMMENT 'Reference to the specific regulatory submission sequence (e.g., initial filing, amendment, response) associated with this milestone, if applicable.',
    `upstream_milestone_regulatory_milestone_id` BIGINT COMMENT 'Self-referencing identifier of the predecessor regulatory milestone that must be completed before this milestone can begin, enabling dependency chain tracking and critical path analysis.',
    `acceptance_date` DATE COMMENT 'Date on which the regulatory agency formally accepted the submission for review (e.g., FDA 74-day filing acceptance for NDA/BLA, EMA validation date for MAA). Null if not yet accepted.',
    `actual_date` DATE COMMENT 'The real-world date on which the regulatory milestone was achieved or completed. Null if the milestone has not yet been reached.',
    `agency_action_date` DATE COMMENT 'The date by which the regulatory agency is expected or required to take a formal action (e.g., PDUFA goal date for FDA, Day 120/180 for EMA). Distinct from the planned milestone date as it is set by the agency, not the sponsor.',
    `approval_date` DATE COMMENT 'Date on which the regulatory agency granted marketing authorization or study approval. Populated only for milestones of type approval. Null for all other milestone types.',
    `baseline_date` DATE COMMENT 'The original approved baseline date for this milestone at the time the regulatory project plan was first formally approved, preserved for variance and trend analysis even after re-baselining.',
    `completed_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the milestone status was set to completed, capturing the exact moment of milestone achievement for audit trail and regulatory timeline reporting purposes.',
    `completion_notes` STRING COMMENT 'Free-text notes recorded at the time of milestone completion, capturing any conditions, caveats, agency feedback, or follow-up actions associated with the milestone outcome.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory milestone record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_milestone_ref` STRING COMMENT 'Cross-reference identifier from the source system for the corresponding milestone or project task record, enabling reconciliation between the regulatory milestone tracker and the operational CTMS project plan.',
    `delay_reason_code` STRING COMMENT 'Standardized code categorizing the root cause of a milestone delay when variance_days is positive: agency_query (information request from agency), data_deficiency (incomplete or inadequate data package), resource_constraint (internal capacity issue)',
    `delay_reason_description` STRING COMMENT 'Free-text narrative providing detailed explanation of the reason for milestone delay or schedule change, supplementing the delay_reason_code with context for regulatory project management and escalation.',
    `forecast_date` DATE COMMENT 'Current best-estimate date for milestone completion based on latest scenario planning and risk assessment, used for regulatory timeline management and scenario analysis without formally re-baselining the plan.',
    `is_agency_committed` BOOLEAN COMMENT 'Flag indicating whether the planned or agency action date for this milestone has been formally committed to or communicated by the regulatory agency (e.g., PDUFA date confirmed, EMA Day 120 clock set).',
    `is_critical_path` BOOLEAN COMMENT 'Flag indicating whether this milestone lies on the critical path of the regulatory project plan. Critical path milestones directly impact the overall regulatory approval timeline and require heightened monitoring.',
    `milestone_category` STRING COMMENT 'High-level grouping of the milestone within the drug development lifecycle: pre_clinical (pre-IND activities), clinical (study execution phases), regulatory (submission and review activities), commercial (post-approval activities).. Valid values are `pre_clinical|clinical|regulatory|commercial`',
    `milestone_code` STRING COMMENT 'Externally-known alphanumeric business identifier for the milestone (e.g., RM-IND-FILING, RM-NDA-SUB), used in regulatory project plans, TMF cross-references, and agency correspondence.. Valid values are `^RM-[A-Z0-9]{3,20}$`',
    `milestone_description` STRING COMMENT 'Detailed narrative description of the regulatory milestone, including scope, deliverables, entry/exit criteria, and any specific regulatory requirements or conditions associated with achieving this milestone.',
    `milestone_name` STRING COMMENT 'Human-readable name of the regulatory milestone (e.g., IND Filing, Phase I Study Start, Phase III Study Start, NDA Submission, PDUFA Date, Approval, Label Finalization).',
    `milestone_status` STRING COMMENT 'Current lifecycle status of the regulatory milestone: planned (not yet started), in_progress (activities underway), completed (milestone achieved), delayed (past planned date without completion), cancelled (milestone removed from plan), on_hold. Valid values are `planned|in_progress|completed|delayed|cancelled|on_hold`',
    `milestone_type` STRING COMMENT 'Categorical classification of the milestone by its regulatory function: filing (IND/CTA initial filing), study_start (Phase I/II/III initiation), study_completion (DBL or study close-out), submission (NDA/BLA/MAA dossier submission), agency_action (PDUFA',
    `phase` STRING COMMENT 'Clinical development phase associated with this milestone, enabling phase-level timeline tracking and portfolio analytics across the drug development lifecycle.',
    `planned_date` DATE COMMENT 'Originally scheduled target date for achieving this regulatory milestone, as defined in the regulatory project plan or integrated development timeline.',
    `priority_designation` STRING COMMENT 'Special regulatory designation granted by the agency that may affect review timelines and milestone dates (e.g., FDA Priority Review, Breakthrough Therapy, Fast Track, Accelerated Approval, Orphan Drug).',
    `probability_of_success_pct` DECIMAL(5,2) COMMENT 'Estimated probability (0.00–100.00%) that this regulatory milestone will be achieved on or before the planned date, used in risk-adjusted scenario planning and portfolio forecasting.',
    `regulatory_strategy_notes` STRING COMMENT 'Confidential free-text field capturing regulatory strategy considerations, agency meeting outcomes, or scenario planning assumptions relevant to this milestone. Classified as confidential due to commercially sensitive strategic content.',
    `review_cycle` STRING COMMENT 'Type of agency review cycle applicable to this milestone, which determines the review clock duration: standard (12-month FDA standard review), priority (6-month FDA priority review), rolling (rolling review during development), accelerated (EMA. Valid values are `standard|priority|rolling|accelerated`',
    `revised_planned_date` DATE COMMENT 'Most recently updated target date for the milestone following a formal re-baseline of the regulatory project plan, reflecting approved schedule changes.',
    `scenario_label` STRING COMMENT 'Label identifying the planning scenario under which this milestone date was projected, supporting regulatory timeline scenario planning and what-if analysis: base_case (most likely), optimistic (best case), pessimistic (worst case), risk_adjusted. Valid values are `base_case|optimistic|pessimistic|risk_adjusted`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this regulatory milestone record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `variance_days` BIGINT COMMENT 'Signed integer representing the difference in calendar days between the actual (or forecast) date and the planned date. Positive values indicate delay; negative values indicate early completion. Enables regulatory timeline KPI reporting.',
    `veeva_vault_doc_reference` STRING COMMENT 'Cross-reference identifier linking this milestone to the corresponding document, dossier, or workflow object in Veeva Vault (eTMF/regulatory submissions module), enabling traceability between milestone tracking and the source document management system.',
    CONSTRAINT pk_regulatory_program_milestone PRIMARY KEY(`regulatory_program_milestone_id`)
) COMMENT 'Canonical regulatory milestone entity. Tracks regulatory submission deadlines, agency action dates, approval milestones, and other regulatory timeline events.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` (
    `labeling_document_id` BIGINT COMMENT 'Unique surrogate identifier for the labeling document record in the regulatory domain. Primary key for the labeling_document data product.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Labeling documents (Investigator Brochure, SmPC, package insert) are created and managed as part of a specific regulatory application.',
    `author_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Labeling document authorship is a regulated activity requiring traceable employee accountability for version control, ICF update triggers, and health authority inspection readiness.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Labeling document preparation, review, and approval follows specific SOPs. Linking labeling documents to the governing SOP supports GCP compliance documentation, labeling change control, and',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Labeling documents are approved by specific health authorities (FDA, EMA, MHRA). The existing health_authority STRING field is a denormalized reference to health_authority.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Labeling documents are submitted to health authorities as part of regulatory submissions.',
    `template_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: Labeling documents (USPI, SmPC, IB) are produced from controlled document templates (e.g., FDA USPI template, EMA SmPC template).',
    `approval_date` DATE COMMENT 'The date on which this version of the labeling document received final regulatory or internal quality approval. Distinct from effective_date; approval may precede the effective date by a transition period.',
    `approval_status` STRING COMMENT 'Current lifecycle state of the labeling document within the regulatory review and approval workflow. Drives distribution eligibility, site notification requirements, and TMF completeness checks.. Valid values are `Draft|Under Review|Approved|Superseded|Withdrawn|Archived`',
    `approver_name` STRING COMMENT 'The name of the qualified person (e.g., Medical Director, Regulatory Affairs Lead) who provided final approval for this labeling document version. Required for GCP compliance and electronic signature audit trail.',
    `change_summary` STRING COMMENT 'A narrative summary of the key changes introduced in this version of the labeling document compared to the previous version. Required for regulatory submissions and site notification letters to explain the nature and significance of updates.',
    `confidentiality_classification` STRING COMMENT 'Confidentiality classification level of this labeling document.. Valid values are `Restricted|Confidential|Internal|Public`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this labeling document record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `ctd_section` STRING COMMENT 'The CTD/eCTD module and section reference where this labeling document is filed within the regulatory dossier (e.g., Module 1.3.1, Module 2.7.4, Module 5.3.5.1). Supports eCTD dossier assembly and regulatory submission management.',
    `current_version_flag` BOOLEAN COMMENT 'Indicates whether this record represents the currently active and approved version of the labeling document. True = current version in effect. Enables efficient filtering for active labeling without date-range logic.',
    `distribution_required_flag` BOOLEAN COMMENT 'Indicates whether this labeling document version requires mandatory distribution to investigative sites and principal investigators. True = distribution to all active sites is required upon approval. Triggers site notification workflows in CTMS.',
    `document_format` STRING COMMENT 'The electronic file format of the labeling document as stored in Veeva Vault (e.g., PDF for final approved versions, Word for working drafts, XML for eCTD submissions). Governs rendering and submission compatibility.. Valid values are `PDF|Word|XML|HTML|eCTD`',
    `document_number` STRING COMMENT 'The externally-known, human-readable document control number assigned to this labeling document (e.g., LBL-2024-0042). Used for regulatory submissions, cross-referencing in CTD/eCTD dossiers, and correspondence with health authorities.',
    `document_title` STRING COMMENT 'The full descriptive title of the labeling document as it appears on the document face (e.g., Investigator Brochure for Compound XYZ Edition 5, Summary of Product Characteristics v3.1). Used for identification and TMF indexing.',
    `document_type` STRING COMMENT 'Classification of the labeling document by regulatory category. IB = Investigator Brochure; PI = Package Insert (US); SmPC = Summary of Product Characteristics (EU); PIL = Patient Information Leaflet; RSI = Reference Safety Information; USPI = US',
    `effective_date` DATE COMMENT 'The date on which this version of the labeling document becomes officially effective and must be used by investigators and sites. Triggers site notification and ICF update obligations under GCP.',
    `health_authority_approval_date` DATE COMMENT 'The date on which the relevant health authority (FDA, EMA, PMDA, MHRA, Health Canada, TGA) formally approved or acknowledged this labeling document version. Null for documents not requiring direct health authority approval (e.g., internal IB editions).',
    `ib_edition_number` BIGINT COMMENT 'For Investigator Brochure (IB) document types, the sequential edition number (e.g., Edition 1, Edition 2). Distinct from version_number; the IB edition is the regulatory-facing identifier used in IND/CTA submissions and site communications.',
    `icf_update_required_flag` BOOLEAN COMMENT 'Indicates whether changes in this labeling document version necessitate an update to the Informed Consent Form (ICF) at investigative sites. True = ICF amendment required. Triggers IRB/IEC re-submission workflows and subject re-consent processes.',
    `indication` STRING COMMENT 'The specific disease, condition, or indication for which the investigational product is being studied or for which the labeling document describes use. Aligns with MedDRA coding and regulatory submission scope.',
    `inn_name` STRING COMMENT 'The WHO-assigned International Nonproprietary Name (INN) for the active substance described in the labeling document. Used for regulatory submissions and cross-referencing with WHO Drug Dictionary (WHO-DD).',
    `language_code` STRING COMMENT 'The ISO 639-1 language code (optionally with ISO 3166-1 country subtag) of the labeling document (e.g., en, fr, de, ja, zh-CN). Required for multi-regional studies where labeling must be provided in local languages per health authority. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `product_name` STRING COMMENT 'The name of the investigational or approved medicinal product to which this labeling document pertains. May be the International Nonproprietary Name (INN), brand name, or code name depending on development stage.',
    `region` STRING COMMENT 'The regulatory region or market grouping for which this labeling document applies. Complements country_code for regional labeling strategies and multi-regional submission planning.. Valid values are `North America|Europe|Asia Pacific|Latin America|Middle East Africa|Global`',
    `review_due_date` DATE COMMENT 'The date by which this labeling document is due for its next periodic review to ensure continued accuracy and currency of safety and efficacy information. Particularly relevant for the Investigator Brochure which requires at least annual review per ICH',
    `rsi_flag` BOOLEAN COMMENT 'Indicates whether this labeling document serves as the Reference Safety Information (RSI) for the purpose of SUSAR (Suspected Unexpected Serious Adverse Reaction) expectedness assessment. True = this document is the designated RSI.',
    `safety_update_flag` BOOLEAN COMMENT 'Indicates whether this version of the labeling document was issued primarily due to a safety update (e.g., new adverse event data, updated risk information, SUSAR findings). True = safety-driven revision.',
    `sponsor_name` STRING COMMENT 'Name of the sponsor organization for this labeling document.',
    `study_phase` STRING COMMENT 'The clinical development phase associated with this labeling document. Determines the depth of safety and efficacy information required in the document (e.g., IB content requirements differ between Phase I and Phase III).. Valid values are `Phase I|Phase II|Phase III|Phase IV|Pre-clinical|Post-marketing`',
    `submission_date` DATE COMMENT 'The date on which this labeling document version was submitted to the relevant health authority (FDA, EMA, PMDA, MHRA, Health Canada, etc.) as part of an IND, NDA, BLA, MAA, or protocol amendment package.',
    `submission_type` STRING COMMENT 'The type of regulatory submission in which this labeling document is included. IND = Investigational New Drug; NDA = New Drug Application; BLA = Biologics License Application; MAA = Marketing Authorization Application; CTA = Clinical Trial Authorization',
    `superseded_date` DATE COMMENT 'The date on which this version of the labeling document was superseded by a newer version. Null if the document is currently the active version. Used for version lifecycle tracking and regulatory audit trails.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication to which the investigational product and this labeling document pertain (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Supports portfolio-level labeling analytics and regulatory strategy.',
    `tmf_zone` STRING COMMENT 'The TMF Reference Model zone and section where this labeling document is filed within the eTMF (e.g., Zone 4 - Investigational Product, Section 04.01 - Investigator Brochure). Supports TMF completeness tracking and inspection readiness.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this labeling document record was most recently modified in the system. Required for audit trail completeness and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault (eTMF/regulatory submissions module) as the system-of-record identifier for this labeling document. Used for cross-system traceability and audit.',
    `veeva_vault_lifecycle_state` STRING COMMENT 'The document lifecycle state as recorded in Veeva Vaults document management workflow. Mirrors the Vault-native state for reconciliation and audit purposes. Distinct from approval_status which reflects the business/regulatory approval state.. Valid values are `Draft|In Review|Approved|Superseded|Obsolete`',
    CONSTRAINT pk_labeling_document PRIMARY KEY(`labeling_document_id`)
) COMMENT 'Manages investigational and approved product labeling documents including Investigator Brochure (IB), Package Insert (PI/SmPC), Patient Information Leaflet (PIL), and Reference Safety Information (RSI).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` (
    `safety_report_submission_id` BIGINT COMMENT 'Unique surrogate identifier for each safety report submission record in the regulatory domain. Primary key for this data product.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: IND Annual Reports, DSURs, and expedited safety reports are filed under specific regulatory applications.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Safety reports are submitted to specific health authorities (FDA, EMA, PMDA). The agency_code STRING field on safety_report_submission is a denormalized reference to',
    `icsr_id` BIGINT COMMENT 'Foreign key linking to safety.icsr. Business justification: Expedited safety report submissions (ICSRs) are the regulatory filing of ICSR cases. Linking safety_report_submission to the specific ICSR case it reports is fundamental to pharmacovigilance',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization responsible for the safety report submission obligation.',
    `parent_submission_id` BIGINT COMMENT 'Reference to the original or preceding safety report submission record when this record is a follow-up or amendment. Enables lineage tracking across submission versions for the same safety event.',
    `prepared_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Safety report preparation (ICSRs, DSURs, PSURs) is a regulated activity with 7/15-day expedited timelines requiring traceable employee accountability.',
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

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` (
    `clinical_trial_authorization_id` BIGINT COMMENT 'Unique surrogate identifier for the Clinical Trial Authorization record in the lakehouse Silver layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Clinical Trial Authorizations (CTAs) are filed with national competent authorities as part of the overall regulatory application process for a development program.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: CTAs are filed with specific national competent authorities (MHRA, BfArM, ANSM).',
    `parent_cta_clinical_trial_authorization_id` BIGINT COMMENT 'Reference to the original or preceding CTA record from which this substantial modification, renewal, or extension derives. Enables reconstruction of the full authorization history chain for a trial in a given member state.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
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
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault (eTMF/regulatory submissions module) for the CTA authorization letter or dossier. Enables direct linkage from this master record to the source regulatory document in the eTMF system of record.',
    `withdrawal_date` DATE COMMENT 'Date on which the Clinical Trial Authorization was formally withdrawn, either by the sponsor or by the national competent authority. Null if the CTA has not been withdrawn.',
    `withdrawal_reason` STRING COMMENT 'Narrative reason for the withdrawal of the Clinical Trial Authorization. Populated only when withdrawal_date is not null. Required for regulatory reporting and inspection readiness.',
    CONSTRAINT pk_clinical_trial_authorization PRIMARY KEY(`clinical_trial_authorization_id`)
) COMMENT 'Master record for Clinical Trial Authorizations (CTAs) issued by national competent authorities under EU CTR 536/2014, national regulations, and equivalent non-US frameworks.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`strategy` (
    `strategy_id` BIGINT COMMENT 'Primary key for strategy',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Regulatory strategies are developed for specific regulatory applications (IND, NDA, BLA, MAA).',
    `employee_id` BIGINT COMMENT 'Reference to the the source system record of the Regulatory Affairs professional responsible for authoring, maintaining, and executing this regulatory strategy.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Regulatory strategies target specific lead health authorities (FDA, EMA, PMDA). The lead_agency STRING field on strategy is a denormalized reference to health_authority.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Regulatory strategy is indication-specific; strategy.target_indication is a denormalized text field.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization for whom this regulatory strategy is developed. Aligns with the sponsor entity in the Sponsor domain.',
    `program_strategic_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_plan. Business justification: A regulatory strategy is developed in direct alignment with a specific program development plan version.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `adaptive_pathway_applicable` BOOLEAN COMMENT 'Indicates whether an adaptive licensing or adaptive pathway approach (EMA Adaptive Pathways Pilot, FDA Accelerated Approval) is incorporated into this regulatory strategy, allowing staged approval based on interim data.',
    `agency_interaction_plan` STRING COMMENT 'Narrative description of planned agency interactions (e.g., Pre-IND meeting, Type B End-of-Phase 2 meeting, Pre-NDA meeting, Scientific Advice, PRIME eligibility request) including meeting types, timing, and objectives as documented in the strategy.',
    `approval_date` DATE COMMENT 'Date on which this regulatory strategy document was formally approved internally by the Regulatory Affairs leadership and/or sponsor. Marks the transition from draft to approved status in Veeva Vault.',
    `breakthrough_therapy_designation` BOOLEAN COMMENT 'Indicates whether FDA Breakthrough Therapy Designation (BTD) has been requested or granted for this program, enabling intensive FDA guidance and rolling review benefits.',
    `strategy_code` STRING COMMENT 'Externally-known, human-readable unique code assigned to this regulatory strategy document within the Veeva Vault regulatory submissions module (e.g., REG-STR-2024-0042). Used for cross-system referencing and TMF indexing.. Valid values are `^REG-STR-[A-Z0-9]{4,20}$`',
    `competitive_landscape_notes` STRING COMMENT 'Notes on the competitive landscape relevant to this regulatory strategy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory strategy record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_ectd_format_required` BOOLEAN COMMENT 'Indicates whether the submission dossier must be prepared in CTD/eCTD format as required by ICH M4 and the target agencies. True for most major agency submissions (FDA, EMA, PMDA); may be False for certain early-phase or regional submissions.',
    `development_phase` STRING COMMENT 'Clinical development phase covered by this regulatory strategy. Determines the regulatory requirements, agency interaction types, and submission milestones applicable.',
    `dossier_format` STRING COMMENT 'Format of the regulatory submission dossier planned under this strategy: eCTD (Electronic Common Technical Document), NeeS (Non-eCTD Electronic Submission), paper, or regional format for specific agencies.. Valid values are `eCTD|NeeS|paper|regional`',
    `effective_date` DATE COMMENT 'Date from which this version of the regulatory strategy is operationally effective and binding for the program team. Supports version-controlled strategy lifecycle management.',
    `expiry_date` DATE COMMENT 'Date on which this version of the regulatory strategy is superseded or retired. Null for the currently active version. Enables historical strategy version tracking.',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether FDA Fast Track Designation has been requested or granted, enabling more frequent FDA interactions and eligibility for rolling review of the NDA/BLA.',
    `health_authority_scientific_advice_planned` BOOLEAN COMMENT 'Flag indicating whether scientific advice from the health authority is planned.',
    `key_regulatory_risks` STRING COMMENT 'Narrative summary of identified regulatory risks that could impact approval timelines or probability of success (e.g., unresolved safety signals, insufficient efficacy data, CMC concerns, precedent gaps). Supports risk-based regulatory planning.',
    `meddra_indication_code` STRING COMMENT 'MedDRA Preferred Term (PT) code corresponding to the target indication, enabling standardized cross-study and cross-agency reporting and signal detection alignment.. Valid values are `^[0-9]{8}$`',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether orphan drug designation has been sought or granted for this program by FDA (ODD) or EMA (OMP), which confers market exclusivity and fee waivers. True if designation is active or planned.',
    `pediatric_investigation_plan_required` BOOLEAN COMMENT 'Indicates whether a Pediatric Investigation Plan (EMA PIP) or Pediatric Study Plan (FDA PSP) is required as part of this regulatory strategy, per pediatric regulatory obligations.',
    `planned_approval_date` DATE COMMENT 'Anticipated date of regulatory approval from the lead agency based on standard or expedited review timelines. Used for commercial launch planning and portfolio milestone tracking.',
    `planned_ind_submission_date` DATE COMMENT 'Target date for submission of the IND application to the FDA as planned in this regulatory strategy. Drives pre-IND meeting scheduling and CMC/nonclinical package readiness timelines.',
    `planned_nda_bla_maa_submission_date` DATE COMMENT 'Target date for submission of the marketing authorization application (NDA, BLA, or MAA) as planned in this regulatory strategy. Key milestone for program planning and resource allocation.',
    `prime_designation` BOOLEAN COMMENT 'Indicates whether EMA PRIME (PRIority MEdicines) designation has been requested or granted, providing enhanced EMA support for medicines that target unmet medical needs.',
    `regulatory_pathway` STRING COMMENT 'Global regulatory pathway designation for this strategy. Captures whether the program pursues standard review, accelerated approval (FDA), Breakthrough Therapy, Fast Track, PRIME (EMA), Conditional Marketing Authorization, or adaptive pathway.',
    `regulatory_precedents` STRING COMMENT 'Summary of relevant regulatory precedents from previously approved products in the same therapeutic class or indication that inform the strategy (e.g., approved comparators, agency guidance documents, advisory committee outcomes).',
    `rems_required` BOOLEAN COMMENT 'Indicates whether a Risk Evaluation and Mitigation Strategy (REMS) is anticipated or required by FDA as a condition of approval, based on the safety profile of the investigational product.',
    `risk_level` STRING COMMENT 'Overall regulatory risk classification for this strategy based on the risk assessment of approval probability, data package adequacy, and agency precedent. Drives escalation and mitigation planning.. Valid values are `low|medium|high|critical`',
    `rolling_review_planned` BOOLEAN COMMENT 'Indicates whether a rolling review submission strategy is planned, allowing completed sections of the dossier to be submitted to the agency before the full application is complete. Applicable for FDA Fast Track and EMA Rolling Review.',
    `strategy_status` STRING COMMENT 'Current lifecycle status of the regulatory strategy document. Tracks progression from initial drafting through internal review, formal approval, and eventual supersession or retirement when a new version is issued.. Valid values are `draft|under_review|approved|superseded|retired`',
    `submission_sequence_strategy` STRING COMMENT 'Planned sequencing approach for multi-regional submissions: simultaneous (all agencies at once), sequential lead-first (lead agency then others), rolling (submit sections as available), or staggered (phased by region). Drives submission timeline planning.. Valid values are `simultaneous|sequential_lead_first|rolling|staggered`',
    `submission_type` STRING COMMENT 'Primary regulatory submission type targeted by this strategy (e.g., IND - Investigational New Drug, NDA - New Drug Application, BLA - Biologics License Application, MAA - Marketing Authorization Application, CTA - Clinical Trial Authorization).',
    `target_agencies` STRING COMMENT 'Comma-separated list of all global health authorities targeted for submission under this strategy (e.g., FDA, EMA, PMDA, MHRA, Health Canada). Supports multi-regional submission planning and sequencing.',
    `title` STRING COMMENT 'Descriptive title of the regulatory strategy document, summarizing the development program, indication, and regulatory pathway scope (e.g., Global NDA/MAA Regulatory Strategy for Drug X in Indication Y Phase III).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this regulatory strategy record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for audit trail and data lineage tracking per 21 CFR Part 11.',
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault eTMF/Regulatory Submissions module where the approved regulatory strategy document is stored. Enables direct traceability from this data record to the source document.',
    `version` STRING COMMENT 'Version number of the regulatory strategy document following major.minor versioning convention (e.g., 1.0, 2.1). Incremented upon each approved revision to support document lifecycle management in Veeva Vault.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_strategy PRIMARY KEY(`strategy_id`)
) COMMENT 'Documents the regulatory strategy plan for a development program or individual study. Captures target indication, development phase, global regulatory pathway (standard, accelerated, adaptive), key agency interactions planned, submission sequence';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`commitment` (
    `commitment_id` BIGINT COMMENT 'Primary key for commitment',
    `application_id` BIGINT COMMENT 'Reference to the regulatory application (IND/NDA/BLA/MAA) under which this commitment was imposed as a condition of approval.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Post-approval commitments (PMCs, PMRs) are audited for timely completion and quality of deliverables.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Post-approval regulatory commitments are imposed by specific health authorities (FDA, EMA).',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Post-approval commitments (PMCs, PMRs) are a specific category of regulatory obligation.',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: Post-approval regulatory commitments are imposed as conditions of a specific regulatory approval (e.g., post-marketing studies required as conditions of accelerated approval).',
    `regulatory_contact_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Post-approval commitments (PMCs/PMRs) require a named workforce employee accountable for due dates, agency reporting, and completion tracking.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Post-approval regulatory commitments (PMC studies, REMS programs, pediatric studies) require dedicated budget allocations tracked separately from the main study budget.',
    `study_id` BIGINT COMMENT 'Reference to the post-marketing clinical study or trial being conducted to fulfill this commitment, where applicable (e.g., a post-marketing required study or confirmatory trial).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Post-marketing commitment reports and pediatric study plans are TMF documents filed with the agency.',
    `accelerated_approval_condition` BOOLEAN COMMENT 'Indicates whether this commitment is a confirmatory trial required as a condition of accelerated approval (True) or a standard post-approval commitment (False). Accelerated approval conditions carry heightened regulatory scrutiny.',
    `agency_commitment_number` STRING COMMENT 'The official commitment or post-marketing requirement number assigned by the health authority (e.g., FDA PMR/PMC number, EMA obligation number) at the time of approval. Used for regulatory correspondence and agency tracking.',
    `approval_date` DATE COMMENT 'The date on which the health authority granted product approval and formally imposed this commitment. Establishes the baseline for commitment timelines.',
    `associated_protocol_number` STRING COMMENT 'The clinical study protocol number associated with the post-marketing study or confirmatory trial being conducted to fulfill this commitment. Enables traceability to the study protocol.',
    `commitment_category` STRING COMMENT 'Regulatory category distinguishing legally binding Post-Marketing Requirements (PMR) mandated by the FDA versus voluntary Post-Marketing Commitments (PMC), or conditions of approval imposed by other agencies such as EMA or PMDA.. Valid values are `pmr|pmc|condition_of_approval|accelerated_approval_condition|other`',
    `completion_date` DATE COMMENT 'The actual date on which the regulatory commitment was fulfilled and the required deliverable was submitted to or accepted by the health authority. Null if not yet completed.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory commitment record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Provides audit trail for record provenance per 21 CFR Part 11 and ALCOA+ principles.',
    `ctd_module` STRING COMMENT 'The CTD module to which the deliverable for this commitment will be submitted (e.g., Module 5 for clinical study reports, Module 1 for labeling updates). Aligns commitment deliverables with eCTD dossier structure.. Valid values are `module_1|module_2|module_3|module_4|module_5`',
    `deferral_reason` STRING COMMENT 'Narrative explanation for any agency-approved deferral or extension of the commitment due date. Documents the justification submitted to and accepted by the health authority.',
    `commitment_description` STRING COMMENT 'Full narrative description of the regulatory commitment as stated in the approval letter or agency decision document. Captures the exact obligation language including scope, objectives, and deliverables required by the health authority.',
    `due_date` DATE COMMENT 'The date by which the regulatory commitment must be fulfilled or the required deliverable (e.g., final study report, label update, REMS implementation) must be submitted to the health authority. Drives overdue status calculation.',
    `indication` STRING COMMENT 'The approved therapeutic indication or disease area for which the product received approval and to which this commitment is specifically tied.',
    `inn_name` STRING COMMENT 'WHO-assigned International Nonproprietary Name (INN) of the active substance subject to this commitment. Provides a globally standardized identifier for the drug substance independent of brand name.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether documentation and evidence for this commitment has been reviewed and confirmed as inspection-ready (True) for potential health authority inspection or audit. Supports regulatory inspection preparedness.',
    `is_binding` BOOLEAN COMMENT 'Indicates whether this commitment is legally binding (True = Post-Marketing Requirement mandated by law, e.g., FDA PMR under FDAAA) or voluntary (False = Post-Marketing Commitment, e.g., FDA PMC).',
    `is_pediatric` BOOLEAN COMMENT 'Indicates whether this commitment involves a pediatric study required under the Pediatric Research Equity Act (PREA) or EMA Paediatric Regulation. Enables filtering and reporting on pediatric obligations.',
    `last_report_submitted_date` DATE COMMENT 'The date on which the most recent progress report or status update for this commitment was submitted to the health authority. Used to calculate next reporting due date.',
    `milestone_date` DATE COMMENT 'The date on which the most recent commitment milestone was achieved or is targeted. Used in conjunction with milestone_description to track incremental progress toward fulfillment.',
    `milestone_description` STRING COMMENT 'Description of the current or most recent milestone achieved in fulfilling this commitment (e.g., protocol submitted, enrollment complete, interim analysis submitted, final report submitted). Supports granular progress tracking.',
    `next_report_due_date` DATE COMMENT 'The date by which the next scheduled progress report or status update on this commitment must be submitted to the health authority. Calculated based on reporting frequency and last submission date.',
    `notes` STRING COMMENT 'Free-text field for additional context, internal commentary, or operational notes related to this commitment that do not fit into structured fields. Used by regulatory affairs teams for tracking nuances and agency communication history.',
    `original_due_date` DATE COMMENT 'The initial due date as specified in the original approval letter or agency decision, before any agency-approved extensions or deferrals. Preserved for audit trail and compliance tracking.',
    `priority_level` STRING COMMENT 'Internal priority classification assigned to this commitment based on regulatory risk, binding nature, and proximity to due date. Drives resource allocation and escalation decisions within the regulatory affairs function.. Valid values are `critical|high|medium|low`',
    `product_name` STRING COMMENT 'Proprietary or brand name of the drug product or biologic to which this regulatory commitment applies, as registered with the health authority.',
    `release_reason` STRING COMMENT 'Narrative explanation for why the health authority released or waived this commitment (e.g., scientific evidence no longer supports the requirement, alternative data satisfied the obligation). Populated only when commitment_status is released.',
    `rems_program_name` STRING COMMENT 'Name of the FDA-required Risk Evaluation and Mitigation Strategy (REMS) program associated with this commitment, if the commitment type is REMS. Null for non-REMS commitments.',
    `reporting_frequency` STRING COMMENT 'The frequency at which progress updates or status reports on this commitment must be submitted to the health authority (e.g., annual, semi-annual, quarterly, one-time final report). Drives scheduling of regulatory submissions.. Valid values are `annual|semi_annual|quarterly|monthly|one_time|ad_hoc`',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this regulatory commitment.',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the regulatory commitment. Tracks progression from pending through active execution to fulfillment or overdue state. Deferred indicates agency-approved extension; released indicates the agency has waived the obligation.',
    `title` STRING COMMENT 'Short, descriptive title of the regulatory commitment as referenced in the approval letter or agency correspondence. Used for display and reporting purposes.',
    `commitment_type` STRING COMMENT 'Classification of the regulatory commitment imposed by the health authority. Indicates whether it is a post-marketing study (PMR/PMC), label update, Risk Evaluation and Mitigation Strategy (REMS), risk minimization measure, pediatric study, confirmatory',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory commitment record was last modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking and audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_document_reference` STRING COMMENT 'The document identifier in Veeva Vault (eTMF/regulatory submissions module) for the approval letter, agency decision document, or commitment tracking record associated with this commitment. Enables direct traceability to the source regulatory document.',
    CONSTRAINT pk_commitment PRIMARY KEY(`commitment_id`)
) COMMENT 'Tracks post-approval regulatory commitments and post-marketing requirements imposed by health authorities as conditions of approval. Captures commitment type (post-marketing study, label update, REMS, risk minimization measure), commitment description';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` (
    `special_designation_id` BIGINT COMMENT 'Unique surrogate identifier for a special regulatory designation record in the Clinical Trials lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND, NDA, BLA, MAA, or CTA) under which this special designation was requested or granted.',
    `health_authority_id` BIGINT COMMENT 'Reference to the granting health authority (e.g., FDA, EMA, PMDA, MHRA, Health Canada) that issued or manages this special designation.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Special designations (orphan drug, breakthrough therapy, fast track) create specific regulatory obligations (annual reports, confirmatory trials, pediatric plans).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that holds or requested the special designation. The sponsor is the legal entity responsible for the designation obligations.',
    `regulatory_contact_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The employee managing breakthrough therapy, orphan drug, or fast track designations is accountable for annual reports and designation maintenance.',
    `study_id` BIGINT COMMENT 'Reference to the primary clinical study that provided the evidence base for the designation request (e.g., the pivotal Phase 2 study supporting a Breakthrough Therapy designation request).',
    `submission_id` BIGINT COMMENT 'Reference to the regulatory submission record through which the designation request was filed or through which the designation was referenced in a marketing application (e.g., the NDA/BLA submission citing the Breakthrough Therapy designation).',
    `agency_contact_name` STRING COMMENT 'Name of the agency contact person for this special designation.',
    `agency_letter_date` DATE COMMENT 'Date of the official agency letter communicating the designation decision (grant, denial, or revocation). Used for regulatory correspondence tracking and TMF filing in Veeva Vault.',
    `agency_receipt_date` DATE COMMENT 'Date on which the health authority officially acknowledged receipt of the designation request. Triggers the formal review clock for the agencys response timeline.',
    `agency_reference_number` STRING COMMENT 'Internal reference or tracking number assigned by the health authority to the designation request or correspondence (e.g., FDA CDER tracking number, EMA EMEA procedure number). Distinct from the designation number issued upon grant.',
    `annual_report_due_date` DATE COMMENT 'Due date for the next mandatory annual progress report to the health authority as required under the designation conditions (e.g., FDA Orphan Drug annual report per 21 CFR Part 316.27). Null if no annual reporting obligation applies.',
    `confirmatory_trial_required` BOOLEAN COMMENT 'Indicates whether a post-approval confirmatory clinical trial is required as a condition of the designation or approval pathway (e.g., mandatory for FDA Accelerated Approval under 21 CFR Part 314 Subpart H). Drives post-marketing commitment tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this special designation record was first created in the Clinical Trials lakehouse. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `denial_date` DATE COMMENT 'Calendar date on which the health authority formally denied the designation request. Null if the designation was not denied. Used to track agency response timelines and inform resubmission strategy.',
    `denial_reason` STRING COMMENT 'Summary of the health authoritys stated rationale for denying the designation request. Captured from the agencys denial letter to inform resubmission strategy and regulatory intelligence. Null if not denied.',
    `designation_conditions` STRING COMMENT 'Free-text description of any conditions, post-designation obligations, or commitments attached to the granted designation by the health authority (e.g., annual progress reports, specific clinical milestones, post-marketing studies for Accelerated',
    `designation_number` STRING COMMENT 'Externally assigned unique reference number issued by the health authority for this special designation (e.g., FDA Orphan Drug designation number OD-XXXXXX, Breakthrough Therapy designation reference).',
    `designation_status` STRING COMMENT 'Current lifecycle status of the special designation. Tracks the progression from initial request through agency review to grant, denial, withdrawal, or revocation.',
    `designation_type` STRING COMMENT 'Classification of the special regulatory designation granted by the health authority. Determines the expedited development pathway and associated regulatory obligations.',
    `expiry_date` DATE COMMENT 'Date on which the special designation expires or lapses, if applicable. Relevant for time-limited designations such as PRIME (EMA) or SAKIGAKE (PMDA) where the designation has a defined validity period.',
    `fee_waiver_applicable` BOOLEAN COMMENT 'Indicates whether the special designation confers eligibility for a regulatory fee waiver or reduction (e.g., FDA Orphan Drug designation entitles sponsors to a waiver of the NDA/BLA application user fee under PDUFA). True if fee waiver applies.',
    `grant_date` DATE COMMENT 'Calendar date on which the health authority officially granted the special designation. Null if the designation has not yet been granted. This is the principal business event date for the designation lifecycle.',
    `indication` STRING COMMENT 'Specific disease, condition, or patient population for which the special designation is requested or granted. Aligns with the MedDRA Preferred Term (PT) or Lowest Level Term (LLT) used in the regulatory submission.',
    `inn_name` STRING COMMENT 'WHO-assigned International Nonproprietary Name (INN) for the active substance of the investigational product. Used for standardized identification across regulatory submissions and health authority correspondence.',
    `market_exclusivity_years` BIGINT COMMENT 'Number of years of market exclusivity conferred by the designation upon product approval (e.g., 7 years for FDA Orphan Drug, 10 years for EU Orphan Medicinal Product).',
    `notes` STRING COMMENT 'Free-text field for additional regulatory context, internal commentary, or strategic notes related to this special designation (e.g., agency meeting outcomes, key discussion points, competitive intelligence). Not for official regulatory correspondence.',
    `orphan_disease_prevalence` STRING COMMENT 'Stated prevalence or incidence of the rare disease or condition as submitted to the health authority in support of an Orphan Drug Designation request (e.g., fewer than 200,000 patients in the US per 21 CFR Part 316, or ≤5 in 10,000 in the EU per EC',
    `product_name` STRING COMMENT 'Proprietary or working name of the investigational medicinal product (IMP) for which the special designation is sought or granted. May differ from the INN (International Nonproprietary Name) at early development stages.',
    `request_date` DATE COMMENT 'Calendar date on which the sponsor formally submitted the designation request to the health authority. Marks the start of the agency review clock for expedited designation programs.',
    `resubmission_planned` BOOLEAN COMMENT 'Indicates whether the sponsor plans to resubmit the designation request following a denial or withdrawal. Drives regulatory planning and resource allocation.',
    `resubmission_target_date` DATE COMMENT 'Planned date for resubmitting the designation request to the health authority after a denial or withdrawal. Null if resubmission is not planned or not yet scheduled.',
    `rolling_review_eligible` BOOLEAN COMMENT 'Indicates whether the designation enables rolling review of the marketing application (submission of completed CTD modules before the full dossier is ready). Applicable to FDA Fast Track and EMA PRIME designations.',
    `surrogate_endpoint_used` BOOLEAN COMMENT 'Indicates whether the designation was granted or the approval pathway relies on a surrogate or intermediate clinical endpoint rather than a traditional clinical outcome endpoint. Relevant for Accelerated Approval and Breakthrough Therapy designations.',
    `tax_credit_applicable` BOOLEAN COMMENT 'Indicates whether the designation qualifies the sponsor for the Orphan Drug Tax Credit (50% of qualified clinical testing expenses in the US under IRC Section 45C). Applicable only to FDA Orphan Drug designations.',
    `therapeutic_area` STRING COMMENT 'Broad medical or scientific domain in which the investigational product is being developed (e.g., Oncology, Rare Disease, Neurology, Infectious Disease). Used for portfolio analytics and regulatory strategy alignment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this special designation record. Supports change tracking, audit trail compliance, and incremental data pipeline processing in the Databricks lakehouse silver layer.',
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault (eTMF/Regulatory module) for the designation request package, agency grant letter, or related regulatory correspondence. Enables direct traceability to the source document in the electronic Trial Master File.',
    `withdrawal_date` DATE COMMENT 'Date on which the sponsor voluntarily withdrew the designation request or the health authority revoked the granted designation. Null if not withdrawn or revoked.',
    CONSTRAINT pk_special_designation PRIMARY KEY(`special_designation_id`)
) COMMENT 'Tracks special regulatory designations granted to investigational products by health authorities. Includes designation type (Breakthrough Therapy, Fast Track, Accelerated Approval, Priority Review, Orphan Drug, PRIME, Adaptive Pathways, SAKIGAKE)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` (
    `regulatory_action_item_id` BIGINT COMMENT 'Unique surrogate identifier for each regulatory action item record in the lakehouse silver layer. Primary key for this entity.',
    `agency_meeting_id` BIGINT COMMENT 'Foreign key linking to regulatory.agency_meeting. Business justification: Action items frequently arise from agency meetings (FDA Type A/B/C meetings, EMA scientific advice).',
    `application_id` BIGINT COMMENT 'Reference to the regulatory application (IND/NDA/BLA/MAA) under which this action item was generated. Provides dossier-level context for the task.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Regulatory action items are frequently generated from audit findings with regulatory implications.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the associated CAPA record in MasterControl when this action item is linked to a quality event, inspection finding, or deviation. Nullable when no formal CAPA is required.',
    `health_authority_id` BIGINT COMMENT 'Reference to the health authority (FDA, EMA, PMDA, MHRA, Health Canada, etc.) whose interaction generated this action item. Drives jurisdiction-specific reporting and escalation rules.',
    `monitoring_action_item_id` BIGINT COMMENT 'Cross-reference identifier for this action item in the source system enabling bidirectional traceability between the lakehouse silver layer and the operational CTMS system of record.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Regulatory action items are often generated to fulfill specific regulatory obligations with agency-mandated deadlines.',
    `prior_action_item_regulatory_action_item_id` BIGINT COMMENT 'Self-referencing identifier pointing to the previous action item from which this one was derived (e.g., a re-opened or recurring item). Enables lineage tracking across action item generations. Nullable for original items.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Protocol deviations with regulatory reporting requirements generate regulatory action items.',
    `regulatory_correspondence_id` BIGINT COMMENT 'Foreign key linking to regulatory.correspondence. Business justification: Action items can arise from regulatory correspondence (Complete Response Letters, Information Requests, deficiency letters).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) to which this regulatory action item belongs. Links the action item to the relevant trial context for reporting and filtering.',
    `submission_id` BIGINT COMMENT 'Reference to the specific regulatory submission (e.g., a response sequence, amendment, or safety report) that triggered or is associated with this action item. Nullable when the action item originates from a meeting or inspection rather than a submission.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory action item responses (agency information requests, inspection findings responses) are filed as TMF documents.',
    `action_item_description` STRING COMMENT 'Detailed narrative describing the specific regulatory task, finding, or commitment that must be addressed. Captures the full context of what is required, including any agency-specified language from meeting minutes or inspection reports.',
    `action_item_number` STRING COMMENT 'Human-readable, externally-known business identifier for the action item (e.g., RAI-2024-00123). Used in regulatory correspondence, meeting minutes, and inspection response packages to uniquely reference the task.. Valid values are `^RAI-[0-9]{4}-[0-9]{5}$`',
    `action_item_status` STRING COMMENT 'Current lifecycle state of the regulatory action item. Drives operational dashboards, escalation logic, and compliance reporting. overdue is system-set when due_date has passed without closure.. Valid values are `open|in_progress|closed|overdue|cancelled`',
    `action_item_type` STRING COMMENT 'Categorical classification of the nature of the action item. Drives workflow templates and regulatory reporting. [ENUM-REF-CANDIDATE: commitment|information_request|capa|protocol_amendment|label_update|response_to_agency|internal_task|other — promote to',
    `agency_acknowledgement_date` DATE COMMENT 'The date on which the health authority formally acknowledged receipt of the response or deliverable. Used to confirm the regulatory clock was stopped and to document agency receipt for the eTMF.',
    `agency_mandated_due_date` DATE COMMENT 'The specific response deadline formally communicated by the health authority (e.g., FDA 30-day information request clock, EMA Day 120 response). Distinct from the internal due_date which may be set earlier to allow review time.',
    `agency_submission_date` DATE COMMENT 'The date on which the completed response or deliverable was formally submitted to the health authority. Distinct from completion_date (internal closure) — captures the actual agency-facing delivery date for regulatory clock tracking.',
    `assigned_owner_email` STRING COMMENT 'Email address of the individual responsible for completing this action item. Used for automated notifications, escalation alerts, and audit trail. Classified as confidential PII per GDPR and HIPAA.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `assigned_owner_name` STRING COMMENT 'Name of the person assigned to own this regulatory action item.',
    `assigned_team` STRING COMMENT 'Name of the regulatory affairs team or functional group responsible for this action item (e.g., Global Regulatory Strategy, Submissions Team, Safety Reporting). Supports team-level workload reporting and capacity planning.',
    `completion_date` DATE COMMENT 'The date on which the action item was fully completed and closed. Nullable until the item reaches closed status. Used to calculate cycle time and measure regulatory responsiveness KPIs.',
    `compliance_inspection_code` BIGINT COMMENT 'Reference to the regulatory inspection (GCP, GMP, GLP) that generated this action item. Nullable when the source event is a meeting or correspondence rather than an inspection.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this regulatory action item record was first created in the data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `due_date` DATE COMMENT 'The date by which the action item must be completed. May be agency-mandated (e.g., 30-day response clock from FDA information request) or internally set. Drives overdue status calculation and escalation triggers.',
    `escalation_date` DATE COMMENT 'The date on which this action item was escalated. Nullable when escalation_flag is False. Used to track escalation response time and management intervention patterns.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this action item has been escalated to senior regulatory leadership or executive management due to risk, overdue status, or strategic importance. True = escalated; False = not escalated.',
    `escalation_reason` STRING COMMENT 'Narrative explanation of why this action item was escalated (e.g., Approaching agency deadline with incomplete data package, Potential clinical hold risk identified). Provides context for management review.',
    `finding_classification` STRING COMMENT 'GCP/GMP inspection finding classification when the action item originates from an inspection finding. Aligns with FDA and EMA inspection classification standards. Nullable for non-inspection-sourced action items.. Valid values are `critical|major|minor|observation|not_applicable`',
    `notes` STRING COMMENT 'Free-text field for additional context, interim progress updates, or commentary on the action item that does not fit structured fields. Supports operational communication within the regulatory affairs team.',
    `open_date` DATE COMMENT 'The date on which this action item was formally opened and entered into the regulatory task register. Represents the business event timestamp for the creation of the obligation.',
    `priority_level` STRING COMMENT 'Business priority assigned to the action item, reflecting urgency and regulatory risk. critical typically indicates a potential clinical hold, safety signal, or imminent agency deadline. Used for resource allocation and escalation decisions.. Valid values are `critical|high|medium|low`',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this action item represents a recurrence of a previously identified issue or finding. True = recurrence of a prior finding; False = new issue. Used in quality trend analysis and CAPA effectiveness assessments.',
    `regulatory_area` STRING COMMENT 'Functional regulatory domain to which this action item belongs (e.g., clinical, safety, CMC). Enables domain-specific filtering and assignment routing within the regulatory affairs team.',
    `regulatory_procedure_reference` STRING COMMENT 'Reference to the specific regulatory procedure, guideline, or regulation that this action item must satisfy (e.g., 21 CFR 312.32, EMA/CHMP/ICH/295148/2004, ICH E6(R2) Section 5.18). Provides the regulatory basis for the required action.',
    `response_document_title` STRING COMMENT 'Title of the formal response document prepared to address this action item (e.g., Response to FDA Information Request Letter dated 2024-03-15). Supports eTMF filing and regulatory correspondence tracking.',
    `review_cycle` STRING COMMENT 'Indicates the review cycle stage of this action item within an ongoing agency interaction (e.g., initial response, follow-up clarification, final closure). Supports multi-round agency dialogue tracking.. Valid values are `initial|follow_up|final|not_applicable`',
    `source_event_reference` STRING COMMENT 'Free-text or structured reference identifier for the originating event (e.g., meeting number, inspection report number, correspondence reference number, or internal review ID). Provides traceability back to the source document or event record.',
    `source_event_type` STRING COMMENT 'Classification of the business event that originated this action item. Drives workflow routing and reporting dashboards. [ENUM-REF-CANDIDATE: agency_meeting|inspection_finding|regulatory_correspondence|internal_review|dsmb_recommendation|other — promote',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsor contact person for this regulatory action item.',
    `title` STRING COMMENT 'Short, human-readable title summarizing the regulatory action item (e.g., Respond to FDA Information Request on CMC Data). Used in dashboards, email notifications, and task lists.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this regulatory action item record was last modified. Supports change detection, incremental ETL processing, and audit trail requirements under 21 CFR Part 11.',
    `veeva_vault_document_reference` STRING COMMENT 'Identifier of the associated document or record in Veeva Vault (eTMF or regulatory submissions module), such as the meeting minutes, inspection report, or correspondence document that originated this action item.',
    CONSTRAINT pk_regulatory_action_item PRIMARY KEY(`regulatory_action_item_id`)
) COMMENT 'Tracks action items arising from agency meetings, correspondence, inspection findings, and internal regulatory reviews. Captures action item description, source event (meeting, inspection, correspondence), assigned owner, due date, completion date';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` (
    `country_registration_id` BIGINT COMMENT 'Unique surrogate identifier for each country-level product registration record in the regulatory lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Reference to the parent regulatory application (IND/NDA/BLA/MAA) under which this country registration was granted.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Country registrations require local ethics approval in many jurisdictions as part of the authorization package.',
    `health_authority_id` BIGINT COMMENT 'Reference to the health authority (FDA, EMA, PMDA, MHRA, Health Canada, TGA, etc.) that issued or oversees this country registration.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Each country registration creates specific local regulatory obligations (annual reports, renewals, variations, local language labeling).',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: A country registration is the direct outcome of a regulatory approval in a specific country/jurisdiction.',
    `regulatory_contact_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The employee managing country-level product registrations owns renewal deadlines and local agent coordination — a named regulatory operations process.',
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

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`procedure` (
    `procedure_id` BIGINT COMMENT 'Primary key for procedure',
    `application_id` BIGINT COMMENT 'add column application_id (BIGINT) with FK to regulatory.application.application_id — regulatory procedures apply to specific applications',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Regulatory procedures (centralized procedure, MRP, DCP) are governed by internal SOPs defining how the company executes each procedure type.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Regulatory procedures (centralized, decentralized, national) are defined and governed by specific health authorities.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — regulatory procedures should link to studies they govern',
    `applicable_product_types` STRING COMMENT 'Pipe-delimited list of product types for which this procedure is applicable (e.g., small_molecule|biologic|vaccine|gene_therapy|medical_device|combination_product).',
    `application_type` STRING COMMENT 'Type of regulatory application to which this procedure applies (e.g., IND, NDA, BLA, MAA, ANDA, sNDA, sBLA, CTA). Links the procedure to the correct application lifecycle and dossier structure.',
    `assessment_report_type` STRING COMMENT 'Type of public assessment report published by the health authority upon completion of review under this procedure (e.g., EPAR for EMA Centralized Procedure, PAR for MHRA, Assessment Report for PMDA, Review Memo for FDA).. Valid values are `EPAR|PAR|Assessment_Report|Review_Memo|None`',
    `clock_stop_allowed` BOOLEAN COMMENT 'Indicates whether the health authority may issue a clock stop (List of Outstanding Issues / Major Objection) that pauses the review clock under this procedure. True for EMA centralized procedure (Day 120/180 clock stops); False for FDA standard review.',
    `procedure_code` STRING COMMENT 'Standardized alphanumeric code uniquely identifying the regulatory procedure or pathway (e.g., EU-CENTRAL, FDA-NDA-STANDARD, FDA-NDA-PRIORITY, EMA-DCP, EMA-MRP, PMDA-NATIONAL).. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory procedure reference record was first created in the data platform. Supports audit trail, data lineage, and ALCOA+ compliance requirements for regulated clinical research data.',
    `ctd_modules_required` STRING COMMENT 'Pipe-delimited list of CTD modules required for a complete submission under this procedure (e.g., module1|module2|module3|module4|module5 for a full NDA/MAA; module1|module2|module3 for a CMC-only variation).',
    `data_exclusivity_period_years` DECIMAL(4,1) COMMENT 'Number of years of data exclusivity granted upon approval under this procedure (e.g., 5 years for FDA NCE exclusivity, 8 years data exclusivity + 2 years market exclusivity for EMA). Used in lifecycle management and competitive intelligence planning.',
    `dossier_format` STRING COMMENT 'Required dossier submission format for this procedure (e.g., eCTD v3.2.2, eCTD v4.0, NeeS, paper). Drives publishing tool configuration in Veeva Vault and determines the technical submission package structure.. Valid values are `eCTD|NeeS|paper|eCTD_v3|eCTD_v4`',
    `effective_date` DATE COMMENT 'Date from which this regulatory procedure definition became or becomes effective and applicable for new submissions. Used to determine which procedure version applies to a given submission based on its filing date.',
    `electronic_submission_required` BOOLEAN COMMENT 'Indicates whether electronic submission (e.g., via FDA ESG, EMA CESP, or equivalent gateway) is mandatory for this procedure. Drives submission method configuration and Veeva Vault publishing workflow.',
    `expedited_pathway_available` BOOLEAN COMMENT 'Indicates whether an expedited or accelerated review pathway is available under this procedure (e.g., FDA Priority Review, Breakthrough Therapy, Accelerated Approval; EMA Accelerated Assessment, PRIME scheme).',
    `expedited_review_clock_days` BIGINT COMMENT 'Number of calendar days for expedited or priority review under this procedure (e.g., 180 days for FDA priority review NDA, 150 days for EMA accelerated assessment). Null if no expedited pathway exists for this procedure.',
    `expiry_date` DATE COMMENT 'Date on which this regulatory procedure definition expires or is superseded. Null for currently active procedures with no defined end date. Used to enforce version-controlled procedure selection in submission planning.',
    `fee_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the submission fee associated with this procedure (e.g., USD for FDA, EUR for EMA, GBP for MHRA, JPY for PMDA). Null if no fee applies. Used in financial planning and budget forecasting for regulatory submissions.. Valid values are `^[A-Z]{3}$`',
    `guidance_document_reference` STRING COMMENT 'Reference to the primary agency guidance document or procedural guidance that describes this procedure in detail (e.g., FDA Guidance for Industry: Submitting an NDA, EMA Procedural Guidance for MAA, ICH M4 CTD Guidance).',
    `local_agent_required` BOOLEAN COMMENT 'Indicates whether a local regulatory agent or representative is required in the target jurisdiction to submit under this procedure (e.g., EU Qualified Person for Pharmacovigilance, Japan local agent for PMDA submissions).',
    `market_exclusivity_period_years` DECIMAL(4,1) COMMENT 'Number of years of market exclusivity (protection from generic/biosimilar competition) granted upon approval under this procedure (e.g., 12 years for FDA biologic exclusivity, 10 years for EMA). Distinct from data exclusivity.',
    `mutual_recognition_agreement_applicable` BOOLEAN COMMENT 'Indicates whether a Mutual Recognition Agreement (MRA) between jurisdictions is applicable to this procedure, potentially enabling reliance on another agencys assessment to streamline review.',
    `procedure_name` STRING COMMENT 'Full human-readable name of the regulatory procedure or pathway (e.g., Centralized Procedure, Decentralized Procedure, Mutual Recognition Procedure, National Procedure, Abbreviated New Drug Application Procedure).',
    `orphan_designation_applicable` BOOLEAN COMMENT 'Indicates whether orphan drug designation (FDA) or orphan medicinal product designation (EMA) can be applied in conjunction with this procedure, potentially conferring fee waivers, market exclusivity, and protocol assistance.',
    `pediatric_plan_required` BOOLEAN COMMENT 'Indicates whether a Pediatric Investigation Plan (EMA PIP) or Pediatric Study Plan (FDA PSP) must be submitted or agreed upon as part of this procedure. Drives pediatric regulatory commitment tracking.',
    `post_approval_variation_procedure` STRING COMMENT 'Classification of the post-approval variation procedure applicable after initial approval under this procedure (e.g., EMA Type IA/IB/II Variation, FDA Prior Approval Supplement, Changes Being Effected CBE-30, CBE-0, Annual Report).',
    `pre_submission_meeting_available` BOOLEAN COMMENT 'Indicates whether the health authority offers a formal pre-submission meeting (e.g., FDA Type B Pre-NDA meeting, EMA Scientific Advice) for this procedure type. Used in regulatory strategy planning to schedule agency interactions before dossier filing.',
    `procedural_requirements` STRING COMMENT 'Free-text description of key procedural requirements, mandatory steps, and conditions that must be met to initiate and complete a submission under this procedure (e.g., pre-submission validation, mandatory scientific advice, specific data package',
    `rapporteur_required` BOOLEAN COMMENT 'Indicates whether a Rapporteur and Co-Rapporteur must be appointed by the CHMP/CVMP for this procedure (applicable to EMA Centralized Procedure). The Rapporteur leads the scientific assessment and prepares the Assessment Report.',
    `reference_member_state_required` BOOLEAN COMMENT 'Indicates whether a Reference Member State (RMS) must be designated for this procedure (applicable to EMA Decentralized Procedure and Mutual Recognition Procedure). The RMS leads the scientific assessment on behalf of all Concerned Member States.',
    `region_name` STRING COMMENT 'Geographic regulatory region associated with this procedure (e.g., Europe, North America, Asia Pacific). Used for regional submission strategy planning, portfolio analytics, and regulatory intelligence reporting.. Valid values are `North America|Europe|Asia Pacific|Latin America|Middle East Africa|Global`',
    `regulatory_framework_reference` STRING COMMENT 'Primary legal or regulatory framework citation governing this procedure (e.g., 21 CFR Part 314 for FDA NDA, Regulation (EC) No 726/2004 for EMA Centralized Procedure, EU CTR 536/2014 for clinical trial authorization).',
    `rems_applicable` BOOLEAN COMMENT 'Indicates whether a Risk Evaluation and Mitigation Strategy (REMS) or Risk Management Plan (RMP) may be required as a condition of approval under this procedure. Relevant for FDA REMS and EMA RMP requirements.',
    `rolling_review_allowed` BOOLEAN COMMENT 'Indicates whether the health authority permits rolling review (submission of completed CTD modules before the full dossier is ready) under this procedure. Applicable to FDA Rolling Review and EMA Rolling Review for medicines of major public health',
    `standard_fee_amount` DECIMAL(18,2) COMMENT 'Standard fee amount for this regulatory procedure.',
    `standard_review_clock_days` BIGINT COMMENT 'Number of calendar days defined by the health authority for standard (non-expedited) review of a submission under this procedure (e.g., 365 days for FDA standard NDA review, 210 days for EMA centralized procedure).',
    `procedure_status` STRING COMMENT 'Current lifecycle status of this regulatory procedure definition. Active: currently applicable and in use for submission planning. Inactive: no longer accepted by the agency. Deprecated: superseded by a newer procedure.. Valid values are `active|inactive|deprecated|under_revision`',
    `submission_fee_applicable` BOOLEAN COMMENT 'Indicates whether a regulatory submission fee is required for this procedure (e.g., FDA PDUFA user fee, EMA fee). Drives financial planning and fee waiver eligibility assessment for orphan or small business designations.',
    `subtype` STRING COMMENT 'Further classification within the procedure type (e.g., Type II Variation, Type IB Variation, Type IA Variation, Line Extension, New Active Substance, Well-Established Use, Fixed Combination).',
    `procedure_type` STRING COMMENT 'High-level classification of the regulatory procedure pathway. Centralized: single EMA review for all EU member states. Decentralized: simultaneous national applications. Mutual Recognition: extension of existing national approval.. Valid values are `centralized|decentralized|mutual_recognition|national|abbreviated|hybrid`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory procedure reference record was last modified in the data platform. Supports change tracking, audit trail, and ALCOA+ compliance for regulated clinical research data.',
    `validation_criteria` STRING COMMENT 'Description of the formal validation or completeness check criteria applied by the health authority upon receipt of a submission under this procedure (e.g., FDA 60-day filing review criteria, EMA Day 0 validation checklist).',
    `veeva_vault_procedure_reference` STRING COMMENT 'Reference identifier for this regulatory procedure record in Veeva Vault (eTMF/regulatory submissions module). Enables traceability between the silver layer data product and the source system of record for regulatory document management and submission',
    CONSTRAINT pk_procedure PRIMARY KEY(`procedure_id`)
) COMMENT 'Reference data defining regulatory procedures and pathways available across health authorities. Captures procedure type (centralized, decentralized, mutual recognition, national, abbreviated, hybrid), applicable agency, procedure code, standard review';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` (
    `submission_content_unit_id` BIGINT COMMENT 'Unique surrogate identifier for each individual content unit (document, dataset, or study report) included within a CTD/eCTD submission sequence. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Reference to the regulatory application (IND/NDA/BLA/MAA) under which this content unit is submitted, supporting application-level dossier completeness tracking.',
    `ctd_dossier_id` BIGINT COMMENT 'Reference to the CTD/eCTD dossier binder that contains this content unit, enabling dossier-level aggregation and gap analysis.',
    `prepared_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: eCTD document preparation is a regulated publishing activity requiring traceable employee accountability for audit trails and inspection readiness.',
    `primary_submission_veeva_vault_version_id` BIGINT COMMENT 'Specific version identifier of the document in Veeva Vault at the time it was included in this submission sequence. Ensures the exact approved version is captured for audit and regulatory traceability.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: Regulatory publishers building CTD Module 5 map each submission content unit (e.g., dataset listing, define.xml) to a specific SDTM dataset.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this content unit, particularly relevant for Module 5 clinical study reports, datasets, and study-level documents. Enables study-level dossier completeness tracking.',
    `submission_id` BIGINT COMMENT 'Reference to the parent regulatory submission sequence to which this content unit belongs. Links the content unit to its containing submission record.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Each submission content unit (eCTD leaf) corresponds to a TMF document. Regulatory publishing teams must trace each submitted document to its TMF record for inspection readiness and',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this content unit received final regulatory document approval in Veeva Vault prior to inclusion in the submission. Supports audit trail and 21 CFR Part 11 electronic signature compliance.',
    `cdisc_standard` STRING COMMENT 'CDISC data standard applicable to this content unit when the document type is a dataset or define file (e.g., SDTM for tabulation datasets, ADaM for analysis datasets, SEND for nonclinical datasets, define-xml for data definitions).. Valid values are `SDTM|ADaM|SEND|define-xml|none`',
    `cdisc_version` STRING COMMENT 'Version of the CDISC standard applied to this dataset content unit (e.g., SDTM 3.3, ADaM 1.3). Required for FDA and EMA dataset submissions to ensure conformance with the declared standard version.',
    `checksum_algorithm` STRING COMMENT 'Cryptographic algorithm used to generate the checksum value (e.g., MD5, SHA-256). Required for integrity verification during agency validation and archival processes.. Valid values are `MD5|SHA-256|SHA-1`',
    `checksum_value` DECIMAL(18,2) COMMENT 'Cryptographic hash value (MD5 or SHA-256) of the content unit file, as declared in the eCTD XML backbone. Used to verify file integrity during agency validation, transmission, and archival. Supports ALCOA+ data integrity requirements.',
    `content_notes` STRING COMMENT 'Free-text notes or comments regarding this content unit, such as rationale for document inclusion, known limitations, pending updates, or agency-specific instructions. Used by regulatory affairs teams for dossier management.',
    `content_unit_number` STRING COMMENT 'Externally-known unique business identifier for this content unit within the submission sequence, typically assigned by the publishing tool (e.g., Lorenz docuBridge, Extedo eCTD Manager) or Veeva Vault.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this submission content unit record was first created in the data platform. Supports audit trail and data lineage tracking.',
    `ctd_module` BIGINT COMMENT 'Top-level CTD module number (1 through 5) to which this content unit belongs. Module 1 = Administrative/Regional; Module 2 = Summaries; Module 3 = Quality; Module 4 = Nonclinical; Module 5 = Clinical.',
    `ctd_section_code` STRING COMMENT 'Standardized CTD section reference code indicating the module and subsection where this content unit is placed (e.g., 2.7.3, 5.3.5.1, 3.2.P.1). Drives dossier structure validation and gap analysis against the ICH M4 table of contents.. Valid values are `^[1-5](.[0-9]{1,2}){0,4}$`',
    `document_date` DATE COMMENT 'Official date of the content unit document as stated on the document itself (e.g., report date, approval date of the document). Distinct from submission date; used for document currency assessment and regulatory review.',
    `document_status` STRING COMMENT 'Current lifecycle status of this content unit within the regulatory dossier workflow. Tracks progression from authoring through agency submission and potential supersession.',
    `document_title` STRING COMMENT 'Full descriptive title of the content unit as it appears in the eCTD leaf title element and the CTD table of contents. Used for dossier navigation and agency review.',
    `document_type` STRING COMMENT 'Classification of the content unit by document category (e.g., Clinical Study Report, Investigator Brochure, Protocol, Statistical Analysis Plan, Dataset, Labeling, Module 2 Summary).',
    `dtd_version` STRING COMMENT 'Version of the eCTD Document Type Definition (DTD) or XML schema used for the backbone of the submission sequence containing this content unit (e.g., 3.2.2, 4.0). Determines structural validation rules applied by agency gateway.',
    `ectd_operation` STRING COMMENT 'eCTD leaf-level lifecycle operation applied to this content unit in the current submission sequence. new = first submission of this document; replace = supersedes a prior version; append = adds to existing content; delete = removes a previously. Valid values are `new|replace|append|delete`',
    `file_format` STRING COMMENT 'Electronic file format of the content unit (e.g., PDF for narrative documents, XPT for CDISC SDTM/ADaM datasets, XML for eCTD backbone). Must comply with agency-specific technical specifications for electronic submissions.',
    `file_name` STRING COMMENT 'Actual file name of the content unit as stored in the eCTD submission package (e.g., csr-study-001-v1.pdf). Must conform to eCTD file naming conventions (lowercase, no spaces, hyphen-delimited).',
    `file_path` STRING COMMENT 'Relative file path of the content unit within the eCTD submission folder structure (e.g., m5/53-clin-stud-rep/535-rep-effic-safety-stud/5351-stud-rep-uncontrol/). Used for dossier navigation and publishing validation.',
    `file_size_bytes` BIGINT COMMENT 'Size of the content unit file in bytes. Used for submission package size validation, agency gateway transmission compliance, and storage management. Agencies impose maximum file size limits for electronic submissions.',
    `gap_analysis_flag` BOOLEAN COMMENT 'Indicates whether this content unit has been identified as a gap (missing or incomplete) during dossier gap analysis. When True, the CTD section requires a new or updated document before submission can proceed.',
    `included_timestamp` TIMESTAMP COMMENT 'Date and time when this content unit was formally included in the submission sequence package, as recorded by the publishing tool or Veeva Vault. Represents the principal business event time for this transaction line.',
    `is_bookmarked` BOOLEAN COMMENT 'Indicates whether this PDF content unit contains required PDF bookmarks as mandated by agency technical specifications. Bookmark compliance is validated during eCTD technical review.',
    `is_hyperlinked` BOOLEAN COMMENT 'Indicates whether this content unit contains internal eCTD hyperlinks to other documents within the dossier. Hyperlink integrity is a key validation criterion for FDA and EMA submissions.',
    `is_searchable_pdf` BOOLEAN COMMENT 'Indicates whether this PDF content unit is text-searchable (OCR-processed or natively digital), as required by FDA and EMA for narrative documents submitted in PDF format.',
    `language_code` STRING COMMENT 'ISO 639-1 language code of the content unit (e.g., en, ja, de, fr). Required for multi-regional submissions where local language documents are mandated by agencies such as PMDA (Japanese) or Health Canada (French/English).. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `leaf_identifier` STRING COMMENT 'Unique XML leaf element identifier assigned to this content unit within the eCTD backbone XML file. Used for cross-referencing between eCTD sequences and for lifecycle operations (replace/delete) that reference prior leaf IDs.',
    `prior_leaf_identifier` STRING COMMENT 'Leaf ID of the previously submitted content unit that this document replaces, appends, or deletes. Required for eCTD lifecycle operations to maintain document lineage across submission sequences.',
    `protocol_number` STRING COMMENT 'Sponsor-assigned protocol number of the clinical study associated with this content unit. Provides direct traceability between dossier documents and the study protocol without requiring a join to the study table.',
    `publishing_tool` STRING COMMENT 'Name of the eCTD publishing software used to compile and validate this content unit within the submission package (e.g., Lorenz docuBridge, Extedo eCTD Manager, Certus). Required for technical conformance documentation.',
    `publishing_tool_version` STRING COMMENT 'Version of the eCTD publishing software used to compile this content unit. Tracked for technical conformance and reproducibility of the submission package.',
    `reviewed_by` STRING COMMENT 'Name or user identifier of the regulatory affairs reviewer who performed quality check on this content unit prior to submission. Supports QC accountability and audit trail requirements.',
    `sequence_number` STRING COMMENT 'Four-digit eCTD sequence number of the submission in which this content unit is included (e.g., 0000 for initial submission, 0001 for first amendment). Aligns with the eCTD backbone sequence numbering convention.. Valid values are `^[0-9]{4}$`',
    `target_agency_code` STRING COMMENT 'Code identifying the health authority for which this content unit is specifically prepared or applicable (e.g., FDA, EMA, PMDA). Some documents are agency-specific (e.g., Module 1 administrative documents differ by region).',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this submission content unit record was last modified in the data platform. Supports change tracking and data integrity auditing.',
    `validation_error_message` STRING COMMENT 'Descriptive error or warning message returned by the eCTD validation tool or agency gateway when validation_status is failed or warning. Used for remediation and resubmission planning.',
    `validation_status` STRING COMMENT 'Result of the eCTD technical validation check performed on this content unit prior to or upon agency receipt. Indicates whether the file passed agency gateway validation criteria (e.g., FDA ECTD Validation Criteria, EMA validation rules).. Valid values are `passed|failed|warning|not_validated|pending`',
    `veeva_vault_document_reference` STRING COMMENT 'Unique document identifier in Veeva Vault RIM (Regulatory Information Management) system, which serves as the system of record for regulatory document management.',
    CONSTRAINT pk_submission_content_unit PRIMARY KEY(`submission_content_unit_id`)
) COMMENT 'Tracks individual content units (documents, datasets, study reports) included within a CTD/eCTD submission sequence. Captures CTD section reference (e.g., Module 2.7.3, Module 5.3.5.1), document title, document type, document version, file format, file';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` (
    `rems_program_id` BIGINT COMMENT 'Unique surrogate identifier for the REMS program record in the lakehouse silver layer.',
    `application_id` BIGINT COMMENT 'Reference to the NDA, BLA, or NDA supplement under which the FDA mandated this REMS program.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: REMS programs are subject to FDA audits for compliance with ETASU and enrollment requirements.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: REMS programs create specific regulatory obligations (prescriber certification, pharmacy enrollment, lab monitoring, periodic assessments).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor responsible for maintaining and submitting the REMS program.',
    `rems_administrator_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The REMS administrator is a workforce employee accountable for program compliance rates, assessment submissions, and FDA interactions.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: REMS programs are risk management tools whose design is based on formal risk assessments.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: REMS program documents (FDA-approved REMS, medication guides, communication plans) are regulatory TMF artifacts.',
    `approval_date` DATE COMMENT 'Date on which FDA formally approved the REMS program as a condition of product approval or post-market requirement.',
    `assessment_schedule` STRING COMMENT 'FDA-mandated schedule for submitting REMS program assessments (e.g., 18 months, 3 years, 7 years post-approval, or annual). Defined in the approved REMS document.. Valid values are `18_months|3_years|7_years|annual|biennial|as_required`',
    `compliance_rate_percent` DECIMAL(5,2) COMMENT 'Most recently reported overall REMS program compliance rate as a percentage, reflecting adherence to ETASU and dispensing controls across enrolled prescribers and pharmacies. Sourced from the latest REMS assessment submission.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this REMS program record was first created in the lakehouse data platform, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX).',
    `effective_date` DATE COMMENT 'Date on which the REMS program became operationally effective and enrollment/dispensing controls were activated.',
    `enrolled_patient_count` BIGINT COMMENT 'Current total number of patients enrolled in the REMS program registry as of the most recent reporting period.',
    `enrolled_pharmacy_count` BIGINT COMMENT 'Current total number of pharmacies certified and enrolled in the REMS program as authorized dispensing sites.',
    `enrolled_prescriber_count` BIGINT COMMENT 'Current total number of healthcare providers certified and enrolled in the REMS program as authorized prescribers.',
    `etasu_description` STRING COMMENT 'Narrative description of the specific ETASU elements required by the REMS program, including prescriber certification, pharmacy enrollment, patient registry, lab monitoring, or dispensing restrictions.',
    `eu_risk_minimization_description` STRING COMMENT 'Narrative description of the EU additional risk minimization measures in place for this product, as required by EMA Risk Management Plan (RMP) obligations.',
    `eu_risk_minimization_type` STRING COMMENT 'Type of equivalent EU additional risk minimization measure applicable to this product (e.g., Direct Healthcare Professional Communication (DHPC), educational material, controlled access program, pregnancy prevention program).. Valid values are `dhpc|educational_material|controlled_access|pregnancy_prevention|patient_alert_card|none`',
    `expiry_date` DATE COMMENT 'Date on which the REMS program is scheduled to expire or be reviewed for continuation. Null for open-ended programs.',
    `goal_compliance_rate_percent` DECIMAL(5,2) COMMENT 'FDA-agreed target compliance rate percentage for the REMS program, used as the benchmark against which actual compliance is measured in assessments.',
    `has_communication_plan` BOOLEAN COMMENT 'Indicates whether the REMS program includes a Communication Plan element targeting healthcare providers with safety information.',
    `has_etasu` BOOLEAN COMMENT 'Indicates whether the REMS program includes Elements to Assure Safe Use (ETASU), such as prescriber certification, pharmacy certification, or patient enrollment requirements.',
    `has_medication_guide` BOOLEAN COMMENT 'Indicates whether the REMS program includes a Medication Guide element that must be dispensed to patients at each prescription fill.',
    `indication` STRING COMMENT 'FDA-approved indication for which the product is marketed and for which the REMS applies.',
    `inn_name` STRING COMMENT 'WHO-assigned International Nonproprietary Name (INN) / generic name of the active substance covered by the REMS program.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether the REMS program documentation, enrollment records, and compliance evidence are current and ready for an FDA inspection or audit.',
    `lab_monitoring_required` BOOLEAN COMMENT 'Indicates whether the REMS requires mandatory laboratory testing (e.g., pregnancy tests, liver function tests) before or during product use.',
    `last_assessment_fda_response_date` DATE COMMENT 'Date on which FDA provided its formal response or determination on the most recently submitted REMS assessment.',
    `last_assessment_submission_date` DATE COMMENT 'Date on which the most recent REMS program assessment was submitted to FDA.',
    `last_modification_date` DATE COMMENT 'Date on which the most recent FDA-approved modification or amendment to the REMS program was implemented.',
    `modification_reason` STRING COMMENT 'Description of the reason for the most recent modification to the REMS program (e.g., new safety signal, FDA-required update, sponsor-initiated improvement).',
    `next_assessment_due_date` DATE COMMENT 'Date by which the next REMS program assessment must be submitted to FDA per the approved assessment schedule.',
    `notes` STRING COMMENT 'Free-text field for additional regulatory context, open action items, FDA correspondence summaries, or program-specific observations not captured in structured fields.',
    `patient_enrollment_required` BOOLEAN COMMENT 'Indicates whether patients must be enrolled in the REMS program registry before receiving the product.',
    `pharmacy_certification_required` BOOLEAN COMMENT 'Indicates whether pharmacies must enroll and be certified before dispensing the product under this REMS program.',
    `prescriber_certification_required` BOOLEAN COMMENT 'Indicates whether healthcare providers must complete a certification or training program before being authorized to prescribe the product under this REMS.',
    `product_name` STRING COMMENT 'Brand or proprietary name of the drug or biologic product covered by this REMS program.',
    `program_code` STRING COMMENT 'Internal sponsor-assigned alphanumeric code uniquely identifying the REMS program for cross-system reference and reporting.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `program_name` STRING COMMENT 'Official FDA-approved name of the Risk Evaluation and Mitigation Strategy program (e.g., iPLEDGE, TIRF REMS Access).',
    `program_status` STRING COMMENT 'Current lifecycle status of the REMS program as recognized by FDA. active indicates the program is in force; suspended indicates temporary halt; withdrawn indicates FDA has removed the REMS requirement.. Valid values are `active|suspended|withdrawn|under_review|pending_approval`',
    `program_type` STRING COMMENT 'Classification of the REMS program based on its required elements: Medication Guide only, Communication Plan, Elements to Assure Safe Use (ETASU), or a combination.. Valid values are `medication_guide|communication_plan|etasu|medication_guide_and_communication_plan|full_rems`',
    `rems_contact_email` STRING COMMENT 'Email address of the sponsors primary regulatory contact responsible for REMS program management and FDA communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease category for which the product covered by this REMS is indicated (e.g., oncology, neurology, hematology).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this REMS program record was most recently updated in the lakehouse data platform, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX).',
    `veeva_vault_document_reference` STRING COMMENT 'Document identifier in Veeva Vault (eTMF/regulatory submissions module) for the approved REMS program document and supporting dossier.',
    CONSTRAINT pk_rems_program PRIMARY KEY(`rems_program_id`)
) COMMENT 'Manages Risk Evaluation and Mitigation Strategy (REMS) programs required by FDA as a condition of approval for certain high-risk products. Tracks REMS program name, product covered, REMS elements (medication guide, communication plan, ETASU), program';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` (
    `intelligence_id` BIGINT COMMENT 'Primary key for intelligence',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Regulatory intelligence items (new agency guidance, ICH guidelines) are assessed for impact on specific development programs.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Regulatory intelligence tracks guidelines, regulations, and policy changes issued by specific health authorities.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Regulatory intelligence (new guidelines, guidance documents, agency actions) may create new compliance obligations.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `action_completed_date` DATE COMMENT 'Date on which all recommended regulatory actions for this intelligence item were completed and verified. Used to close out the intelligence record and confirm compliance readiness.',
    `action_due_date` DATE COMMENT 'Target date by which the recommended regulatory actions must be completed or initiated to ensure compliance with the new or updated regulation or guidance.',
    `capture_date` DATE COMMENT 'Date on which this regulatory intelligence item was first identified and entered into the tracking system by the regulatory affairs team. Supports timeliness KPI measurement.',
    `intelligence_category` STRING COMMENT 'High-level category classifying the nature of the regulatory intelligence item (e.g., guideline update, new regulation, policy change, enforcement action, agency communication).',
    `cdisc_impact_flag` BOOLEAN COMMENT 'Indicates whether this regulatory intelligence item has a direct impact on Clinical Data Interchange Standards Consortium (CDISC) data standards (SDTM, ADaM) or submission data requirements.',
    `comment_deadline_date` DATE COMMENT 'Deadline date by which public comments or industry responses must be submitted to the issuing agency for draft guidance documents or proposed regulations. Null for final documents.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory intelligence record was first created in the system, conforming to ALCOA+ principles for audit trail integrity. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `document_status_type` STRING COMMENT 'Publication status of the underlying regulatory document (e.g., draft for comment, final, revised, withdrawn). Distinguishes between draft guidance requiring monitoring and final guidance requiring action.. Valid values are `draft|final|revised|withdrawn|superseded`',
    `document_type` STRING COMMENT 'Classification of the regulatory document type associated with this intelligence record (e.g., guidance document, regulation, directive, ICH guideline, concept paper).',
    `effective_date` DATE COMMENT 'Date on which the regulatory change, guideline, or policy becomes legally or procedurally effective and must be complied with. May differ from publication date for transition periods.',
    `ich_guideline_code` STRING COMMENT 'International Council for Harmonisation (ICH) guideline code associated with this intelligence item, if applicable (e.g., E6(R2), E8(R1), Q9, M4, S1). Enables cross-referencing with ICH harmonization activities.',
    `impact_level` STRING COMMENT 'Assessed severity of the impact this regulatory intelligence item has on the organizations portfolio, ongoing submissions, or clinical operations. Drives prioritization of regulatory strategy response.. Valid values are `critical|high|medium|low|informational`',
    `impact_scope` STRING COMMENT 'Geographic or operational scope of the regulatory intelligence impact, indicating whether it affects global operations, a specific region, a single country, a specific product, or an individual study.. Valid values are `global|regional|country_specific|product_specific|study_specific`',
    `impact_summary` STRING COMMENT 'Narrative assessment of how this regulatory intelligence item impacts the organizations portfolio, ongoing or planned submissions, clinical operations, or regulatory strategy. Authored by the regulatory affairs team.',
    `impacted_submission_types` STRING COMMENT 'Comma-separated list of regulatory submission types affected by this intelligence item (e.g., IND, NDA, BLA, MAA, CTA, SUSAR, DSUR). Enables targeted impact assessment across the submission portfolio.',
    `impacted_trial_phases` STRING COMMENT 'Comma-separated list of clinical trial phases impacted by this regulatory change (e.g., Phase I, Phase II, Phase III, Phase IV). Supports scoping of impact to active studies.',
    `is_public_comment_opportunity` BOOLEAN COMMENT 'Indicates whether this intelligence item represents a draft guidance or proposed regulation for which the organization has an opportunity to submit public comments to the issuing agency.',
    `keywords` STRING COMMENT 'Comma-separated list of searchable keywords or tags associated with this intelligence record (e.g., decentralized trials, eCOA, real-world evidence, pediatric). Supports full-text search and categorization in analytics.',
    `notes` STRING COMMENT 'Free-text field for additional context, observations, or supplementary information captured by the regulatory affairs team regarding this intelligence item that does not fit into structured fields.',
    `priority_level` STRING COMMENT 'Business priority assigned to this intelligence item by the regulatory affairs team, reflecting urgency of response required relative to portfolio impact and effective date proximity.. Valid values are `urgent|high|medium|low`',
    `protocol_amendment_required_flag` BOOLEAN COMMENT 'Indicates whether this regulatory intelligence item necessitates a protocol amendment for one or more active clinical studies to maintain compliance with the updated regulation or guidance.',
    `public_comment_submitted_flag` BOOLEAN COMMENT 'Indicates whether the organization has submitted a formal public comment or industry response to the issuing agency for this draft guidance or proposed regulation.',
    `publication_date` DATE COMMENT 'Date on which the regulatory guidance, regulation, or policy was officially published by the issuing health authority. Used to establish the regulatory intelligence timeline.',
    `recommended_actions` STRING COMMENT 'Narrative description of the recommended actions the regulatory affairs team should take in response to this intelligence item (e.g., update submission strategy, revise protocol, amend IND, submit public comment).',
    `reference_number` STRING COMMENT 'Externally-known business identifier assigned to this intelligence record, used for cross-referencing in regulatory strategy documents, Veeva Vault, and internal tracking systems. Format: RI-YYYY-NNNNN.. Valid values are `^RI-[0-9]{4}-[0-9]{5}$`',
    `regulatory_framework` STRING COMMENT 'Primary regulatory framework or legal basis under which this intelligence item falls (e.g., ICH GCP, EU CTR 536/2014, 21 CFR Part 312, GDPR, HIPAA, ISO 14155). Supports compliance mapping.',
    `related_application_number` STRING COMMENT 'IND, NDA, BLA, MAA, or CTA application number most directly impacted by this intelligence item, enabling linkage to the regulatory.application product for portfolio impact tracking.',
    `review_date` DATE COMMENT 'Date on which the regulatory affairs team completed the formal impact assessment review of this intelligence item.',
    `reviewed_by` STRING COMMENT 'Name or employee identifier of the regulatory affairs manager or senior reviewer who reviewed and approved the impact assessment for this intelligence record.',
    `source_name` STRING COMMENT 'Specific name of the publication, website, journal, or agency communication from which this intelligence was sourced (e.g., FDA.gov Guidance Documents, EMA News, Regulatory Affairs Professionals Society Journal).',
    `source_type` STRING COMMENT 'Category of the source from which this regulatory intelligence was obtained (e.g., agency website, Federal Register, EMA news, industry publication). Drives source credibility weighting and monitoring workflow routing.',
    `source_url` STRING COMMENT 'Direct hyperlink to the original regulatory document, guidance, or publication on the issuing agencys website or publication portal, enabling direct access for verification.',
    `intelligence_status` STRING COMMENT 'Current workflow status of the intelligence record, tracking its lifecycle from initial capture through assessment and action. [ENUM-REF-CANDIDATE: draft|under_review|assessed|actioned|closed|archived — promote to reference product if additional statuses',
    `submission_strategy_impact_flag` BOOLEAN COMMENT 'Indicates whether this regulatory intelligence item requires a revision to the organizations regulatory submission strategy for one or more applications (IND, NDA, BLA, MAA, CTA).',
    `therapeutic_area` STRING COMMENT 'Therapeutic area(s) impacted by this regulatory intelligence item (e.g., Oncology, Cardiovascular, Neurology, Rare Disease, Infectious Disease). Supports portfolio-level impact scoping and regulatory strategy alignment.',
    `title` STRING COMMENT 'Concise human-readable title summarizing the regulatory change, guideline update, or policy development captured in this intelligence record (e.g., FDA Draft Guidance on Decentralized Clinical Trials).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this regulatory intelligence record, supporting audit trail requirements and change tracking per ALCOA+ principles. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `veeva_vault_document_reference` STRING COMMENT 'Reference identifier for the associated document stored in Veeva Vault eTMF or regulatory submissions module, linking this intelligence record to the source document or internal assessment report.',
    CONSTRAINT pk_intelligence PRIMARY KEY(`intelligence_id`)
) COMMENT 'Captures regulatory intelligence records tracking changes in health authority guidelines, regulations, and policies that may impact ongoing or planned submissions.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` (
    `regulatory_engagement_id` BIGINT COMMENT 'Primary key for the regulatory_engagement association',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to the clinical development program subject to this regulatory engagement',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to the health authority involved in this regulatory engagement',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `agency_interaction_plan` STRING COMMENT 'Summary of planned pre-submission meetings and formal agency interactions for this program at this authority (e.g., Type B Pre-NDA meeting with FDA, Scientific Advice with EMA). Captures meeting types, planned dates, and objectives.',
    `application_number` STRING COMMENT 'The official application reference number assigned by this health authority for this program (e.g., FDA IND number, EudraCT number, PMDA consultation number).',
    `application_type` STRING COMMENT 'The specific application type being pursued at this authority for this program (e.g., IND, NDA, BLA, CTA, MAA, JNDA). Resolves the agency-specific application type from health_authority against the program context.',
    `engagement_status` STRING COMMENT 'Current lifecycle status of this program-authority regulatory engagement (e.g., Planned, Active, Submitted, Under Review, Approved, Withdrawn, On Hold).',
    `eudract_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) number assigned to the program for EU regulatory tracking. Required for all clinical trials conducted in the EU under EU CTR 536/2014.. Valid values are `^[0-9]{4}-[0-9]{6}-[0-9]{2}$`',
    `ind_number` STRING COMMENT 'FDA-assigned Investigational New Drug (IND) application number for the programs lead investigational compound. Primary regulatory identifier for U.S. clinical development activities under 21 CFR Part 312.. Valid values are `^[0-9]{1,6}$`',
    `lead_agency_flag` BOOLEAN COMMENT 'Indicates whether this health authority is the primary or lead regulatory agency for the programs global submission strategy. Replaces the denormalized primary_regulatory_agency string field on clinical_program.',
    `planned_approval_date` DATE COMMENT 'Projected date by which marketing authorization or clinical trial approval is expected from this specific health authority, based on the applicable review clock and pathway.',
    `primary_regulatory_agency` STRING COMMENT 'Lead regulatory authority for the programs primary marketing authorization submission (e.g., FDA for U.S., EMA for EU, PMDA for Japan). Determines applicable regulatory requirements and submission standards.',
    `priority_designation` STRING COMMENT 'Agency-specific priority or expedited designation granted or planned for this program at this authority (e.g., Breakthrough Therapy Designation at FDA, PRIME at EMA, Sakigake at PMDA, Promising Innovative Medicine at MHRA).',
    `regulatory_pathway` STRING COMMENT 'The specific regulatory review pathway applicable to this program at this authority (e.g., Standard Review, Priority Review, Accelerated Approval, Conditional Marketing Authorization, Exceptional Circumstances). Varies by agency and program.',
    `start_date` DATE COMMENT 'Date on which the regulatory engagement with this authority for this program was formally initiated (e.g., first pre-IND meeting, first CTA submission, first scientific advice request).',
    `submission_strategy` STRING COMMENT 'Narrative description of the agency-specific regulatory submission strategy for this program-authority pairing, including sequencing decisions, rolling submission plans, and dossier scope.',
    `target_submission_date` DATE COMMENT 'Planned date for submitting the primary regulatory application (IND, CTA, NDA, MAA, etc.) to this specific health authority. Distinct from the program-level target_submission_date which represents the lead agency only.',
    CONSTRAINT pk_regulatory_engagement PRIMARY KEY(`regulatory_engagement_id`)
) COMMENT 'This association product represents the Contract/Strategy between a clinical_program and a health_authority. It captures the agency-specific regulatory engagement plan for a given clinical development program — including submission strategy, target dates';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` (
    `protocol_ethics_coverage_id` BIGINT COMMENT 'Primary key for the protocol_ethics_coverage association',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to the ethics submission package submitted to the IRB/IEC for this IND protocol',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to the IND application whose authorized protocol is covered by this ethics submission',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — protocol ethics coverage should reference the study',
    `ethics_committee_name` STRING COMMENT 'The name of the IRB or IEC that received this ethics submission in the context of this IND protocol coverage. Retained at the association level to support regulatory reporting that maps IND protocols to specific reviewing ethics committees.',
    `ind_serial_number` STRING COMMENT 'The specific IND serial number (amendment sequence number) referenced by this ethics submission. Ethics submissions for protocol amendments reference the corresponding IND amendment serial number, enabling traceability between regulatory filings and',
    `protocol_number` STRING COMMENT 'The protocol number identifying the specific clinical study protocol within the IND application that this ethics submission covers. A single IND may authorize multiple protocols; this attribute identifies which one is the subject of the ethics submission.',
    `protocol_version` STRING COMMENT 'The version identifier of the protocol document included in this ethics submission package as it relates to the IND. Captures which version of the IND-authorized protocol was submitted for IRB/IEC review in this specific linkage.',
    `submission_date` DATE COMMENT 'The date on which this ethics submission was transmitted to the IRB/IEC in the context of this specific IND protocol linkage. Retained at the association level to support timeline analysis across IND-ethics coverage records independently of the',
    CONSTRAINT pk_protocol_ethics_coverage PRIMARY KEY(`protocol_ethics_coverage_id`)
) COMMENT 'This association product represents the regulatory-compliance contract between an IND application and an ethics submission. It captures which specific protocol (by number and version) under a given IND application is covered by a given IRB/IEC ethics';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` (
    `label_approval_id` BIGINT COMMENT 'Primary key for the label_approval association',
    `country_registration_id` BIGINT COMMENT 'Foreign key linking to the country registration for which this labeling document version was approved.',
    `labeling_document_id` BIGINT COMMENT 'Foreign key linking to the specific labeling document version that was approved for this country registration.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — label approval should reference the study context',
    `approval_status` STRING COMMENT 'Current lifecycle status of this labeling document versions approval for this specific country registration. Tracks whether the label is currently approved, pending health authority review, superseded by a newer version, or withdrawn.',
    `country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code identifying the primary country or market for which this labeling document version applies (e.g., USA, GBR, DEU, JPN, CAN, AUS). Supports multi-regional labeling lifecycle management.. Valid values are `^[A-Z]{3}$`',
    `current_approved_flag` BOOLEAN COMMENT 'Indicates whether this record represents the currently active and approved labeling document version for this country registration. Only one record per country_registration should have this flag set to true at any point in time.',
    `effective_date` DATE COMMENT 'The date on which this labeling document version became officially effective for this specific country registration. Differs per country as each health authority issues its own effective date.',
    `health_authority_approval_date` DATE COMMENT 'The date on which the health authority for this country formally approved this labeling document version for this registration. Country-specific — the same document version may be approved on different dates in different countries.',
    `labeling_version` STRING COMMENT 'Version identifier of the currently approved product labeling (SmPC, Package Insert, or equivalent) in this country. Tracks which labeling version is in force and supports variation management.',
    `superseded_date` DATE COMMENT 'The date on which this labeling document version was superseded by a newer approved version for this country registration. Null if this version is still the currently approved label in this country.',
    CONSTRAINT pk_label_approval PRIMARY KEY(`label_approval_id`)
) COMMENT 'This association product represents the formal approval event between a labeling_document version and a country_registration. It captures the regulatory act by which a health authority approves a specific labeling document version as the valid label for a';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` (
    `binder_document_inclusion_id` BIGINT COMMENT 'Primary key for the binder_document_inclusion association',
    `labeling_document_id` BIGINT COMMENT 'Foreign key linking to the labeling document version included in this binder submission.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to the regulatory binder or eCTD submission package that contains this document.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — binder document inclusion should reference the study for context',
    `ctd_section_code` STRING COMMENT 'The specific CTD/eCTD module and section reference where this labeling document is filed within this particular binder (e.g., m1.3.1 for USPI in an NDA). Belongs to the inclusion relationship because the same document may be filed under different CTD',
    `inclusion_type` STRING COMMENT 'Describes how the labeling document is included in the binder — e.g., ORIGINAL (full document), REFERENCE (hyperlinked reference to previously submitted document), AMENDMENT (revised version replacing prior inclusion).',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether inclusion of this labeling document is required by regulation or agency guidance for this specific binder type and submission. A document may be mandatory in an NDA original but optional in a supplement, making this an attribute of the',
    `language_code` STRING COMMENT 'The ISO 639-1 language code of the labeling document as included in this specific binder. Captured at the inclusion level because a binder may include the same document type in multiple languages, and the language context of inclusion may differ from the',
    `redaction_required` BOOLEAN COMMENT 'Indicates whether this labeling document requires redaction of confidential commercial information (CCI) for this particular submission and target agency. Redaction requirements vary by agency and submission type, making this an attribute of the inclusion',
    CONSTRAINT pk_binder_document_inclusion PRIMARY KEY(`binder_document_inclusion_id`)
) COMMENT 'This association product represents the inclusion contract between a labeling_document and a regulatory_binder. It captures the operational act of assembling a regulatory submission binder by including specific labeling document versions, recording where';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` (
    `dossier_ethics_reference_id` BIGINT COMMENT 'Primary key for the dossier_ethics_reference association',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to the specific IRB/IEC ethics approval record being cited within the application dossier.',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to the NDA, BLA, or equivalent marketing authorization application dossier in which this ethics approval is cited.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — dossier ethics reference should reference the study',
    `added_date` DATE COMMENT 'The date on which this ethics approval citation was formally added to the application dossier by the regulatory affairs team. Supports audit trail requirements for dossier assembly.',
    `approval_scope` STRING COMMENT 'Description of the scope of the ethics approval as it is relevant to this application — e.g., whether it covers the full study population, a specific sub-population, or a particular protocol amendment version cited in the dossier.',
    `citation_status` STRING COMMENT 'Lifecycle status of this ethics approval citation within the dossier: active (currently included), superseded (replaced by a newer ethics approval version), or withdrawn (removed from the dossier).',
    `ethics_committee_name` STRING COMMENT 'The name of the IRB/IEC as it appears in the application dossier submission, which may differ from the canonical name stored on the ethics_approval record due to name changes, translations, or dossier-specific formatting requirements.',
    `inclusion_rationale` STRING COMMENT 'Narrative explanation of why this specific ethics approval is included in the application dossier — e.g., it covers the pivotal Phase III study, or it governs the paediatric sub-study referenced in Module 5.',
    `submission_module_reference` STRING COMMENT 'The CTD (Common Technical Document) module and section number where this ethics approval document is filed within the application dossier (e.g., Module 5.3.1.1).',
    CONSTRAINT pk_dossier_ethics_reference PRIMARY KEY(`dossier_ethics_reference_id`)
) COMMENT 'This association product represents the formal inclusion of an ethics approval record within an NDA/BLA (or equivalent) application dossier. It captures the regulatory affairs act of citing a specific IRB/IEC ethics approval as supporting evidence within';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` (
    `substantial_modification_submission_id` BIGINT COMMENT 'Primary key for the substantial_modification_submission association',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to the Clinical Trial Authorization held by the national competent authority receiving this substantial modification submission.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to the protocol amendment that is being submitted as a substantial modification to the competent authority.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `approval_date` DATE COMMENT 'Date on which the national competent authority formally approved this substantial modification submission. Null if decision is pending or negative.',
    `decision_outcome` STRING COMMENT 'Formal outcome of the national competent authoritys review of this substantial modification submission. Each member state issues an independent decision;',
    `member_state_code` STRING COMMENT 'ISO 3166-1 alpha-2 or alpha-3 country code identifying the EU member state or non-EU jurisdiction whose competent authority is receiving this substantial modification submission. Denormalized here for query convenience alongside the CTA FK.',
    `modification_scope` STRING COMMENT 'Brief narrative description of the scope of the substantial modification as presented to this specific national competent authority. May differ slightly from the global amendment rationale to address country-specific regulatory requirements or language.',
    `submission_date` DATE COMMENT 'Date on which this protocol amendment was formally submitted as a substantial modification to the national competent authority associated with this CTA. Distinct from the protocol_amendment.submission_date, which captures the primary authority submission',
    CONSTRAINT pk_substantial_modification_submission PRIMARY KEY(`substantial_modification_submission_id`)
) COMMENT 'This association product represents the regulatory submission event between a protocol_amendment and a clinical_trial_authorization. It captures the per-member-state, per-amendment submission workflow required under EU CTR 536/2014 and equivalent national';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` (
    `binder_content_inclusion_id` BIGINT COMMENT 'Primary key for the binder_content_inclusion association',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to the regulatory submission binder or eCTD sequence package into which this content unit is included.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — binder content inclusion should reference the study for context',
    `submission_content_unit_id` BIGINT COMMENT 'Foreign key linking to the submission content unit (eCTD leaf document, dataset, or study report) included in this binder.',
    `ctd_section_code` STRING COMMENT 'The CTD/eCTD section reference code (e.g., 2.7.3, 5.3.5.1) indicating where this content unit is placed within this specific binder. May differ from the content units own ctd_section_code if the document is cross-referenced in a different section for a',
    `inclusion_type` STRING COMMENT 'Describes how this content unit is included in this binder — whether it is a new leaf, a replacement of a prior submission, an append, a deletion, a cross-reference, or a hyperlink. Governs eCTD lifecycle operation for this binder context.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this content unit is a required (mandatory) component for the binder type (e.g., IND, NDA, BLA). Used during gap analysis to flag missing mandatory documents before submission.',
    `qc_review_status` STRING COMMENT 'The quality control review status of this content unit within the context of this specific binder. A document may be QC-approved in one binder but still pending review in a subsequent resubmission binder.',
    `sequence_order` BIGINT COMMENT 'The ordinal position of this content unit within its CTD section in this specific binder. Determines the display and navigation order in the eCTD viewer and the published submission package.',
    CONSTRAINT pk_binder_content_inclusion PRIMARY KEY(`binder_content_inclusion_id`)
) COMMENT 'This association product represents the Inclusion relationship between a submission_content_unit and a regulatory_binder. It captures the operational record of a specific eCTD content unit (document, dataset, or study report) being included within a';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` (
    `regulatory_inspection_id` BIGINT COMMENT 'Primary key for regulatory_inspection',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Inspections are frequently tied to a specific regulatory application (pre-approval inspection, BIMO). application_reference STRING should be normalized to a FK to application.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: regulatory_inspection is currently siloed (no FK in or out). An inspection is conducted by a health authority (FDA, EMA, etc.).',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `announced_flag` BOOLEAN COMMENT 'Indicates whether the inspection was announced in advance (true) or unannounced (false).',
    `capa_required_flag` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) plan is required in response to findings.',
    `closure_date` DATE COMMENT 'Date the inspection was formally closed by the regulatory agency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this inspection record was first captured in the system.',
    `critical_findings_count` BIGINT COMMENT 'Number of findings classified as critical severity.',
    `data_classification` STRING COMMENT 'Information sensitivity classification applied to this inspection record.',
    `findings_count` BIGINT COMMENT 'Total number of observations or findings raised during the inspection.',
    `form_483_issued_flag` BOOLEAN COMMENT 'Indicates whether an FDA Form 483 (inspectional observations) was issued at the close of inspection.',
    `inspected_entity_address` STRING COMMENT 'Physical address of the facility or site being inspected.',
    `inspected_entity_name` STRING COMMENT 'Name of the organization, site, or facility that is the subject of the inspection.',
    `inspection_end_date` DATE COMMENT 'Actual date the inspection concluded.',
    `inspection_number` STRING COMMENT 'Externally-known reference number assigned by the health authority or internal tracking system for this inspection.',
    `inspection_outcome` STRING COMMENT 'Final classification outcome: NAI (No Action Indicated), VAI (Voluntary Action Indicated), OAI (Official Action Indicated).',
    `inspection_scope` STRING COMMENT 'Entity scope being inspected (sponsor, CRO, clinical site, laboratory, manufacturing, ethics committee).',
    `inspection_start_date` DATE COMMENT 'Actual date the inspection commenced on-site or remotely.',
    `inspection_status` STRING COMMENT 'Current workflow state of the regulatory inspection lifecycle.',
    `inspection_type` STRING COMMENT 'Category of inspection conducted by the regulatory agency.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this inspection record was last modified.',
    `lead_inspector_name` STRING COMMENT 'Full name of the lead regulatory inspector assigned to the inspection.',
    `major_findings_count` BIGINT COMMENT 'Number of findings classified as major severity.',
    `notification_date` DATE COMMENT 'Date the regulatory agency notified the entity of the upcoming inspection.',
    `protocol_number` STRING COMMENT 'Protocol number of the clinical study associated with the inspection.',
    `regulatory_citation` STRING COMMENT 'Primary regulation or standard cited in the inspection findings (e.g., 21 CFR 312, GCP E6(R2)).',
    `report_received_date` DATE COMMENT 'Date the official inspection report was received from the agency.',
    `response_due_date` DATE COMMENT 'Deadline by which the entity must formally respond to inspection findings.',
    `response_submitted_date` DATE COMMENT 'Date on which the entity submitted its formal response to the agency.',
    `scheduled_date` DATE COMMENT 'Date on which the inspection was scheduled to commence.',
    `summary_description` STRING COMMENT 'Narrative summary of the inspection focus, observations, and overall conclusions.',
    `warning_letter_issued_flag` BOOLEAN COMMENT 'Indicates whether a regulatory warning letter was issued following the inspection.',
    CONSTRAINT pk_regulatory_inspection PRIMARY KEY(`regulatory_inspection_id`)
) COMMENT 'Master reference table for regulatory_inspection. Referenced by regulatory_inspection_id.';

ALTER SCHEMA `clinical_trials_ecm`.`regulatory` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_ecm`.`regulatory` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_controlled_terminology_codelist_id` FOREIGN KEY (`controlled_terminology_codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_submitter_employee_id` FOREIGN KEY (`submitter_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_target_health_authority_id` FOREIGN KEY (`target_health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `submitter_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Submitter Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `submitter_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `submitter_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `submitter_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Target Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `target_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_acknowledgement_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_decision` SET TAGS ('dbx_business_glossary_term' = 'Agency Regulatory Decision');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_decision` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|VNeeS');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `drug_product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `drug_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_business_glossary_term' = 'eCTD Lifecycle Operation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_value_regex' = 'new|replace|append|delete');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `filing_fee_paid` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Paid Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `is_resubmission` SET TAGS ('dbx_business_glossary_term' = 'Resubmission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Submission Delivery Method');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'electronic_gateway|physical_media|portal|email|paper');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Submission Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `prior_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Prior eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `prior_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Submission Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `resubmission_class` SET TAGS ('dbx_value_regex' = 'class_1|class_2|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `target_action_date` SET TAGS ('dbx_business_glossary_term' = 'Target Action Date (PDUFA Date)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'original|amendment|supplement|response|withdrawal');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'eCTD Validation Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_validated|passed|failed|waived');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_lead_agency_health_authority_id` FOREIGN KEY (`lead_agency_health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Agency Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `lead_agency_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `accelerated_approval` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Designation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `agency_country_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `annual_report_last_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'IND Annual Report Last Submitted Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `breakthrough_therapy` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `clinical_hold_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Hold Imposition Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `clinical_hold_status` SET TAGS ('dbx_value_regex' = 'none|partial|full|lifted');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `ctd_module` SET TAGS ('dbx_value_regex' = 'M1|M2|M3|M4|M5|full');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `dossier_language` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `dossier_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Application Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Application Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `ind_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `ind_type` SET TAGS ('dbx_value_regex' = 'commercial|research|treatment|emergency');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `lifecycle_phase` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Lifecycle Phase');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `pdufa_goal_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Goal Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `priority_review` SET TAGS ('dbx_business_glossary_term' = 'Priority Review Designation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational or Approved Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `product_type` SET TAGS ('dbx_value_regex' = 'small_molecule|biologic|gene_therapy|cell_therapy|medical_device|combination');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Contact Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `application_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `application_status` SET TAGS ('dbx_value_regex' = 'active|approved|withdrawn|refused|on_clinical_hold|inactive');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `submission_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|eCTD_v4');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Subtype');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `application_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `application_type` SET TAGS ('dbx_value_regex' = 'IND|NDA|BLA|MAA|CTA|IMPD');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`application` ALTER COLUMN `veeva_vault_dossier_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Dossier ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ADD CONSTRAINT `fk_regulatory_health_authority_country_codelist_term_id` FOREIGN KEY (`country_codelist_term_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Acronym');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `acronym` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_value_regex' = 'active|inactive|merged|superseded');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `agency_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `annual_safety_report_type` SET TAGS ('dbx_value_regex' = 'DSUR|PSUR|IND_Annual|PBRER|other');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_value_regex' = 'national|supranational|regional|reference_agency');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `clinical_trial_registry_required` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Registry Registration Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_division_name` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Division Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_division_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Contact Phone Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ctd_format_required` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Format Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_business_glossary_term' = 'Applicable Data Privacy Regulatory Framework');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ectd_gateway_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Gateway Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ectd_specification_version` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Specification Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Record Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `fee_schedule_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Fee Schedule Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Full Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Guideline Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ich_member` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation (ICH) Member Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ind_application_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ind_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) / Clinical Trial Authorization (CTA) Review Clock (Days)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ind_submission_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) / Clinical Trial Authorization (CTA) Submission Fee Amount');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `ind_submission_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `inspection_authority` SET TAGS ('dbx_business_glossary_term' = 'GCP Inspection Authority');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `local_language_required` SET TAGS ('dbx_business_glossary_term' = 'Local Language Submission Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `local_language_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Mailing Address');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `mailing_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `mutual_recognition_agreements` SET TAGS ('dbx_business_glossary_term' = 'Mutual Recognition Agreement (MRA) Participation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `nda_application_type` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Marketing Authorization Application (MAA) Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `nda_submission_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Marketing Authorization Application (MAA) Submission Fee Amount');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `nda_submission_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `non_fatal_sadr_reporting_clock_hours` SET TAGS ('dbx_business_glossary_term' = 'Non-Fatal Serious Adverse Drug Reaction (SADR) Expedited Reporting Clock (Hours)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `priority_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Priority Regulatory Review Clock (Days)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `region_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Region Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `region_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `review_procedure_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Procedure Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `sadr_reporting_clock_hours` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Drug Reaction (SADR) / Suspected Unexpected Serious Adverse Reaction (SUSAR) Expedited Reporting Clock (Hours)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `standard_review_clock_days` SET TAGS ('dbx_business_glossary_term' = 'Standard Regulatory Review Clock (Days)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Fee Currency (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_business_glossary_term' = 'Required Submission Language (ISO 639)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2,3})?$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Portal URL');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_value_regex' = '^https?://.+$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `trial_registry_name` SET TAGS ('dbx_business_glossary_term' = 'Mandated Clinical Trial Registry Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `trial_registry_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`health_authority` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_veeva_vault_submission_id` FOREIGN KEY (`veeva_vault_submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Contact ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `veeva_vault_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Regulatory Information Management (RIM) Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_acknowledgement_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_value_regex' = 'approval|complete_response|refuse_to_file|information_request|withdrawal_accepted|no_action');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Submission Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|restricted|confidential|highly_confidential');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_value_regex' = 'module_1|module_2|module_3|module_4|module_5|multiple');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ctd_section_list` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section List');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_size_mb` SET TAGS ('dbx_business_glossary_term' = 'Dossier Package Size (MB)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `dossier_package_size_mb` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_business_glossary_term' = 'eCTD Lifecycle Operation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_value_regex' = 'new|replace|append|delete');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_date` SET TAGS ('dbx_business_glossary_term' = 'eCTD Technical Validation Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_status` SET TAGS ('dbx_business_glossary_term' = 'eCTD Technical Validation Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `ectd_validation_status` SET TAGS ('dbx_value_regex' = 'pass|fail|warning|pending');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `is_safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `prior_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Prior eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `prior_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Response Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `review_clock_start_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Review Clock Start Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `review_clock_target_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Review Clock Target Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `submission_subtype` SET TAGS ('dbx_business_glossary_term' = 'Submission Sub-Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_sequence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_parent_application_id` FOREIGN KEY (`parent_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_regulatory_affairs_lead_employee_id` FOREIGN KEY (`regulatory_affairs_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` SET TAGS ('dbx_subdomain' = 'protocol_governance');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `parent_application_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `regulatory_affairs_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `regulatory_affairs_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `regulatory_affairs_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `regulatory_affairs_lead_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `affected_sections` SET TAGS ('dbx_business_glossary_term' = 'Affected Protocol Sections');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_acknowledgment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_approval_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_comments` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `agency_response_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{0,3}-?d{1,4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Rationale');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'substantial|non_substantial|administrative|urgent_safety');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `amendment_version` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'Protocol Change Summary');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `dsmb_notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `ethics_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `ethics_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `icf_version_impacted` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Impacted');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Implementation Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `planned_implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Amendment Implementation Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `reconsent_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `review_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `subject_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Ongoing Subject Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `submission_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_agency_meeting_id` FOREIGN KEY (`agency_meeting_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`agency_meeting`(`agency_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_parent_correspondence_id` FOREIGN KEY (`parent_correspondence_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`correspondence`(`correspondence_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_regulatory_contact_employee_id` FOREIGN KEY (`regulatory_contact_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ADD CONSTRAINT `fk_regulatory_correspondence_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `correspondence_id` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `parent_correspondence_id` SET TAGS ('dbx_business_glossary_term' = 'Related Correspondence ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Contact Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `action_required` SET TAGS ('dbx_business_glossary_term' = 'Required Action Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `agency_division` SET TAGS ('dbx_business_glossary_term' = 'Agency Division or Office');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `agency_division` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `agency_reference_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `ctd_section` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `direction` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Direction');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `direction` SET TAGS ('dbx_value_regex' = 'inbound|outbound');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Language Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Priority Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Received Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `response_date` SET TAGS ('dbx_business_glossary_term' = 'Response Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Contact Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `subject_matter` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Subject Matter');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `summary` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Summary');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `transmission_method` SET TAGS ('dbx_value_regex' = 'ectd|email|fax|postal|hand_delivery|gateway');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `correspondence_type` SET TAGS ('dbx_value_regex' = 'information_request|complete_response_letter|refuse_to_file|meeting_minutes|agency_query|label_negotiation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`correspondence` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_sponsor_lead_employee_id` FOREIGN KEY (`sponsor_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ADD CONSTRAINT `fk_regulatory_agency_meeting_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `sponsor_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `sponsor_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `sponsor_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `sponsor_lead_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_acknowledgement_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_division` SET TAGS ('dbx_business_glossary_term' = 'Agency Division or Office');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_division` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_feedback_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_feedback_summary` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `agency_response_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `confirmed_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Agency-Confirmed Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `confirmed_meeting_time` SET TAGS ('dbx_business_glossary_term' = 'Agency-Confirmed Meeting Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `etmf_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `follow_up_submission_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Submission Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `follow_up_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Meeting Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_format` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Format');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_format` SET TAGS ('dbx_value_regex' = 'Face-to-Face|Teleconference|Videoconference|Written Response Only');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_stage` SET TAGS ('dbx_business_glossary_term' = 'Development Stage at Meeting');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_stage` SET TAGS ('dbx_value_regex' = 'Pre-IND|End-of-Phase 1|End-of-Phase 2|Pre-NDA/BLA|Post-Approval|Other');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_stage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'Type A|Type B|Type C|Scientific Advice|Consultation|Written Response Only');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `minutes_draft_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Draft Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `minutes_finalized_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Finalization Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `minutes_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `nda_bla_number` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Biologics License Application (BLA) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `outcome_classification` SET TAGS ('dbx_business_glossary_term' = 'Meeting Outcome Classification');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `outcome_classification` SET TAGS ('dbx_value_regex' = 'Agreement Reached|Partial Agreement|No Agreement|Pending Agency Response|Information Only');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `pdufa_response_deadline` SET TAGS ('dbx_business_glossary_term' = 'PDUFA Response Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `product_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `request_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Request Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`agency_meeting` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_regulatory_contact_employee_id` FOREIGN KEY (`regulatory_contact_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ADD CONSTRAINT `fk_regulatory_ctd_dossier_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `ctd_dossier_id` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Dossier ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Contact Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Dossier Approved Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `archival_location` SET TAGS ('dbx_business_glossary_term' = 'Dossier Archival Location');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Dossier Comments');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `ctd_format` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Format');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `ctd_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|VNeeS');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_number` SET TAGS ('dbx_business_glossary_term' = 'CTD Dossier Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_number` SET TAGS ('dbx_value_regex' = '^CTD-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Dossier Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|submitted|archived|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_title` SET TAGS ('dbx_business_glossary_term' = 'CTD Dossier Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_type` SET TAGS ('dbx_business_glossary_term' = 'CTD Dossier Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_type` SET TAGS ('dbx_value_regex' = 'initial|amendment|supplement|annual_report|response_to_query');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_version` SET TAGS ('dbx_business_glossary_term' = 'CTD Dossier Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dossier_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `drug_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `drug_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `dtd_version` SET TAGS ('dbx_business_glossary_term' = 'eCTD Document Type Definition (DTD) Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `gap_analysis_date` SET TAGS ('dbx_business_glossary_term' = 'Dossier Gap Analysis Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `gap_analysis_status` SET TAGS ('dbx_business_glossary_term' = 'Dossier Gap Analysis Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `gap_analysis_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|remediation_required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `last_compiled_date` SET TAGS ('dbx_business_glossary_term' = 'Dossier Last Compiled Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module1_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Module 1 Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module1_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module2_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Module 2 Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module2_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module3_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Module 3 Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module3_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module4_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Module 4 Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module4_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module5_status` SET TAGS ('dbx_business_glossary_term' = 'CTD Module 5 Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `module5_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|complete|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `open_gap_count` SET TAGS ('dbx_business_glossary_term' = 'Open Dossier Gap Count');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `overall_completeness_status` SET TAGS ('dbx_business_glossary_term' = 'Overall Dossier Completeness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `overall_completeness_status` SET TAGS ('dbx_value_regex' = 'incomplete|substantially_complete|complete|gap_identified');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `prior_submission_reference` SET TAGS ('dbx_business_glossary_term' = 'Prior Submission Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `publishing_tool` SET TAGS ('dbx_business_glossary_term' = 'eCTD Publishing Tool');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `publishing_tool_version` SET TAGS ('dbx_business_glossary_term' = 'eCTD Publishing Tool Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `total_document_count` SET TAGS ('dbx_business_glossary_term' = 'Total CTD Document Count');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `validation_report_date` SET TAGS ('dbx_business_glossary_term' = 'eCTD Validation Report Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `validation_report_status` SET TAGS ('dbx_business_glossary_term' = 'eCTD Validation Report Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `validation_report_status` SET TAGS ('dbx_value_regex' = 'pending|passed|failed|passed_with_warnings');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `veeva_vault_binder_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Submission Binder ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ctd_dossier` ALTER COLUMN `veeva_vault_dossier_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Dossier Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_primary_approval_health_authority_id` FOREIGN KEY (`primary_approval_health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_tertiary_approval_health_authority_id` FOREIGN KEY (`tertiary_approval_health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approval_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Agency ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `primary_approval_health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `tertiary_approval_health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Health Authority Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `tertiary_approval_health_authority_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `agency_decision_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `agency_decision_rationale` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approved_population` SET TAGS ('dbx_business_glossary_term' = 'Approved Patient Population');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Approved Dosage Form');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `drug_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug / Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `drug_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope of Approval');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `inn_code` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN) Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'READY|NOT_READY|IN_REVIEW|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `irb_iec_reference` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `is_conditional_approval` SET TAGS ('dbx_business_glossary_term' = 'Conditional Approval Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `is_renewal_required` SET TAGS ('dbx_business_glossary_term' = 'Renewal Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `letter_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Letter Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Approval Letter Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_business_glossary_term' = 'Marketing Authorization Holder (MAH) Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `mah_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `post_marketing_commitments` SET TAGS ('dbx_business_glossary_term' = 'Post-Marketing Commitments');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `review_pathway` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Pathway');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `review_pathway` SET TAGS ('dbx_value_regex' = 'STANDARD|PRIORITY|ACCELERATED|BREAKTHROUGH|FAST_TRACK|ORPHAN');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'APPROVED|CONDITIONALLY_APPROVED|WITHDRAWN|SUSPENDED|REVOKED|PENDING');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'IND_ALLOWANCE|NDA_APPROVAL|BLA_APPROVAL|MAA_APPROVAL|CTA_AUTHORIZATION|LABEL_APPROVAL');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`approval` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_parent_application_id` FOREIGN KEY (`parent_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_responsible_regulatory_lead_employee_id` FOREIGN KEY (`responsible_regulatory_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `parent_application_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `responsible_regulatory_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Regulatory Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `responsible_regulatory_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `responsible_regulatory_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `responsible_regulatory_lead_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'IND Amendment Count');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `annual_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'IND Annual Report Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `application_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `breakthrough_therapy_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `clinical_hold_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Hold Imposition Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Dosage Form');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `drug_substance_name` SET TAGS ('dbx_business_glossary_term' = 'Drug Substance (Active Pharmaceutical Ingredient) Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `drug_substance_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ectd_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'IND Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `equivalent_application_number` SET TAGS ('dbx_business_glossary_term' = 'Equivalent Regulatory Application Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `fast_track_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `fda_division` SET TAGS ('dbx_business_glossary_term' = 'FDA Review Division');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `inactivation_date` SET TAGS ('dbx_business_glossary_term' = 'IND Inactivation Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,6}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_serial_number_latest` SET TAGS ('dbx_business_glossary_term' = 'IND Latest Serial Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_serial_number_latest` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `ind_type` SET TAGS ('dbx_value_regex' = 'commercial|research|emergency_use|treatment|expanded_access');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `initial_submission_date` SET TAGS ('dbx_business_glossary_term' = 'IND Initial Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `last_annual_report_date` SET TAGS ('dbx_business_glossary_term' = 'Last IND Annual Report Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `nda_bla_number` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Biologics License Application (BLA) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `phase_coverage` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase Coverage');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `phase_coverage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `protocol_count` SET TAGS ('dbx_business_glossary_term' = 'Protocol Count Under IND');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `safety_reporting_obligation` SET TAGS ('dbx_value_regex' = 'standard|expedited_7day|expedited_15day|both');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'IND Sponsor Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_type` SET TAGS ('dbx_business_glossary_term' = 'IND Sponsor Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `sponsor_type` SET TAGS ('dbx_value_regex' = 'pharmaceutical|biotech|academic|government|cro');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`ind_application` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'IND Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_project_manager_employee_id` FOREIGN KEY (`project_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Biologics License Application (BLA) Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `organization_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `project_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Project Manager Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `project_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `project_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `project_manager_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_date` SET TAGS ('dbx_business_glossary_term' = 'Advisory Committee Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_flag` SET TAGS ('dbx_business_glossary_term' = 'Advisory Committee Meeting Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `advisory_committee_recommendation` SET TAGS ('dbx_value_regex' = 'approve|approve_with_conditions|not_approve|no_recommendation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `application_type` SET TAGS ('dbx_value_regex' = 'NDA|BLA|sNDA|sBLA|MAA');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `approval_pathway` SET TAGS ('dbx_value_regex' = 'standard|accelerated|conditional|exceptional|rolling_review');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `breakthrough_therapy_flag` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation (BTD) Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `complete_response_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Complete Response Letter (CRL) Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ctd_module_status` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Completeness Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ctd_module_status` SET TAGS ('dbx_value_regex' = 'complete|partial|pending|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `drug_name` SET TAGS ('dbx_business_glossary_term' = 'Drug / Biologic Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `drug_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `exclusivity_type` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `exclusivity_type` SET TAGS ('dbx_value_regex' = 'NCE|biologic|orphan|pediatric|new_indication|none');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `fast_track_flag` SET TAGS ('dbx_business_glossary_term' = 'Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^IND[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Proposed Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `inn` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `orphan_drug_flag` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation (ODD) Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `pdufa_goal_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Goal Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `post_marketing_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Post-Marketing Commitment (PMC) Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `priority_review_flag` SET TAGS ('dbx_business_glossary_term' = 'Priority Review Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `rems_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `resubmission_class` SET TAGS ('dbx_value_regex' = 'class_1|class_2|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `review_division` SET TAGS ('dbx_business_glossary_term' = 'Review Division / Office');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `submission_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`nda_bla_application` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_study_milestone_id` FOREIGN KEY (`study_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_milestone`(`study_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ADD CONSTRAINT `fk_regulatory_regulatory_program_milestone_upstream_milestone_regulatory_milestone_id` FOREIGN KEY (`upstream_milestone_regulatory_milestone_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone`(`regulatory_program_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_canonical_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_milestone_scope' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` SET TAGS ('dbx_distinct_concept' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Lead ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `upstream_milestone_regulatory_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Upstream Dependency Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Acceptance Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `baseline_date` SET TAGS ('dbx_business_glossary_term' = 'Baseline Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `completed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Milestone Completed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `completion_notes` SET TAGS ('dbx_business_glossary_term' = 'Milestone Completion Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `ctms_milestone_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Milestone Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `delay_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Milestone Delay Reason Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `delay_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Milestone Delay Reason Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `forecast_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `is_agency_committed` SET TAGS ('dbx_business_glossary_term' = 'Agency Committed Date Indicator');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `is_agency_committed` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `is_critical_path` SET TAGS ('dbx_business_glossary_term' = 'Critical Path Indicator');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Category');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_category` SET TAGS ('dbx_value_regex' = 'pre_clinical|clinical|regulatory|commercial');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_code` SET TAGS ('dbx_value_regex' = '^RM-[A-Z0-9]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_description` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|delayed|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Development Phase');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `planned_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `priority_designation` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Priority Designation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `probability_of_success_pct` SET TAGS ('dbx_business_glossary_term' = 'Probability of Success Percentage');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `regulatory_strategy_notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `review_cycle` SET TAGS ('dbx_business_glossary_term' = 'Agency Review Cycle');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `review_cycle` SET TAGS ('dbx_value_regex' = 'standard|priority|rolling|accelerated');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `revised_planned_date` SET TAGS ('dbx_business_glossary_term' = 'Revised Planned Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `scenario_label` SET TAGS ('dbx_business_glossary_term' = 'Scenario Planning Label');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `scenario_label` SET TAGS ('dbx_value_regex' = 'base_case|optimistic|pessimistic|risk_adjusted');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `variance_days` SET TAGS ('dbx_business_glossary_term' = 'Milestone Schedule Variance (Days)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone` ALTER COLUMN `veeva_vault_doc_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_author_employee_id` FOREIGN KEY (`author_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ADD CONSTRAINT `fk_regulatory_labeling_document_template_id` FOREIGN KEY (`template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` SET TAGS ('dbx_subdomain' = 'protocol_governance');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Author Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Approval Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'Draft|Under Review|Approved|Superseded|Withdrawn|Archived');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Document Approver Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'Document Change Summary');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_business_glossary_term' = 'Document Confidentiality Classification');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_value_regex' = 'Restricted|Confidential|Internal|Public');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `ctd_section` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `distribution_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Site Distribution Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Document File Format');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'PDF|Word|XML|HTML|eCTD');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `document_title` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_approval_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `health_authority_approval_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `ib_edition_number` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure (IB) Edition Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `icf_update_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Update Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Approved or Proposed Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Region');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `region` SET TAGS ('dbx_value_regex' = 'North America|Europe|Asia Pacific|Latin America|Middle East Africa|Global');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'Periodic Review Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `rsi_flag` SET TAGS ('dbx_business_glossary_term' = 'Reference Safety Information (RSI) Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Pre-clinical|Post-marketing');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`labeling_document` ALTER COLUMN `veeva_vault_lifecycle_state` SET TAGS ('dbx_value_regex' = 'Draft|In Review|Approved|Superseded|Obsolete');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_ecm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_parent_submission_id` FOREIGN KEY (`parent_submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_prepared_by_employee_id` FOREIGN KEY (`prepared_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Icsr Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `agency_acknowledgment_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `agency_reference_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `argus_safety_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_value_regex' = 'RELATED|NOT_RELATED|POSSIBLY_RELATED|UNASSESSABLE');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `ctis_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trials Information System (CTIS) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `dibd` SET TAGS ('dbx_business_glossary_term' = 'Development International Birth Date (DIBD)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `expedited_report_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Expedited Report Timeline (Days)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `is_follow_up` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `listedness_assessment` SET TAGS ('dbx_value_regex' = 'LISTED|UNLISTED|UNKNOWN');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `regulatory_action_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'IND_SAFETY_REPORT|DSUR|PSUR_PBRER|SUSAR|IND_ANNUAL_REPORT|CIOMS');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `seriousness_criteria` SET TAGS ('dbx_value_regex' = 'FATAL|LIFE_THREATENING|HOSPITALIZATION|DISABILITY|CONGENITAL_ANOMALY|MEDICALLY_SIGNIFICANT');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `submission_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`safety_report_submission` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_parent_cta_clinical_trial_authorization_id` FOREIGN KEY (`parent_cta_clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `parent_cta_clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Clinical Trial Authorization (CTA) ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Authorization Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_type` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `authorization_type` SET TAGS ('dbx_value_regex' = 'initial|substantial_modification|renewal|extension|withdrawal');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `conditions_attached` SET TAGS ('dbx_business_glossary_term' = 'CTA Conditions Attached Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `conditions_description` SET TAGS ('dbx_business_glossary_term' = 'CTA Conditions Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `cta_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ctd_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ctis_trial_number` SET TAGS ('dbx_business_glossary_term' = 'EU Clinical Trials Information System (CTIS) Trial ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'NCA Decision Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'NCA Decision Outcome');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'authorized|conditionally_authorized|refused|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ethics_committee_opinion` SET TAGS ('dbx_value_regex' = 'favorable|favorable_with_conditions|unfavorable|pending|not_required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `ethics_opinion_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Opinion Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `gdpr_data_transfer_mechanism` SET TAGS ('dbx_value_regex' = 'adequacy_decision|standard_contractual_clauses|binding_corporate_rules|derogation|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|in_preparation|gap_identified|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `member_state_code` SET TAGS ('dbx_business_glossary_term' = 'Member State / Country Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `member_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `modification_scope` SET TAGS ('dbx_business_glossary_term' = 'Substantial Modification Scope');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `national_portal_reference` SET TAGS ('dbx_business_glossary_term' = 'National Regulatory Portal Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_value_regex' = 'EU_CTR_536_2014|EU_CTD|national_regulation|ICH_E6|ISO_14155|other');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `suspension_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Suspension Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'CTA Suspension Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `trial_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `trial_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase IIa|Phase IIb|Phase III');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Validation Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'CTA Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'CTA Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ADD CONSTRAINT `fk_regulatory_strategy_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` SET TAGS ('dbx_subdomain' = 'protocol_governance');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Lead ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `agency_interaction_plan` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `strategy_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `strategy_code` SET TAGS ('dbx_value_regex' = '^REG-STR-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `competitive_landscape_notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `ctd_ectd_format_required` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document / Electronic Common Technical Document (CTD/eCTD) Format Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|regional');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_scientific_advice_planned` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `health_authority_scientific_advice_planned` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Indication Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `pediatric_investigation_plan_required` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Investigation Plan (PIP) Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `planned_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `planned_ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Investigational New Drug (IND) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `planned_nda_bla_maa_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Planned New Drug Application / Biologics License Application / Marketing Authorization Application (NDA/BLA/MAA) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `prime_designation` SET TAGS ('dbx_business_glossary_term' = 'Priority Medicines (PRIME) Designation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `rems_required` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `submission_sequence_strategy` SET TAGS ('dbx_value_regex' = 'simultaneous|sequential_lead_first|rolling|staggered');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `target_agencies` SET TAGS ('dbx_business_glossary_term' = 'Target Regulatory Agencies');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `target_agencies` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`strategy` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_regulatory_contact_employee_id` FOREIGN KEY (`regulatory_contact_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ADD CONSTRAINT `fk_regulatory_commitment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Commitment Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Contact Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Associated Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `accelerated_approval_condition` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Condition Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `agency_commitment_number` SET TAGS ('dbx_business_glossary_term' = 'Agency-Assigned Commitment Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `agency_commitment_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Product Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `commitment_category` SET TAGS ('dbx_business_glossary_term' = 'Commitment Category (Post-Marketing Requirement / Post-Marketing Commitment)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `commitment_category` SET TAGS ('dbx_value_regex' = 'pmr|pmc|condition_of_approval|accelerated_approval_condition|other');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Completion Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `ctd_module` SET TAGS ('dbx_value_regex' = 'module_1|module_2|module_3|module_4|module_5');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `deferral_reason` SET TAGS ('dbx_business_glossary_term' = 'Commitment Deferral Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Approved Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `is_binding` SET TAGS ('dbx_business_glossary_term' = 'Is Binding Commitment Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `is_pediatric` SET TAGS ('dbx_business_glossary_term' = 'Is Pediatric Study Commitment Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `last_report_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Last Progress Report Submitted Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `milestone_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `milestone_description` SET TAGS ('dbx_business_glossary_term' = 'Commitment Milestone Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `next_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Progress Report Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Commitment Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `original_due_date` SET TAGS ('dbx_business_glossary_term' = 'Original Commitment Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Commitment Priority Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Drug Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `release_reason` SET TAGS ('dbx_business_glossary_term' = 'Commitment Release Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `rems_program_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Program Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `rems_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|one_time|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Contact Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Commitment Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`commitment` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_regulatory_contact_employee_id` FOREIGN KEY (`regulatory_contact_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ADD CONSTRAINT `fk_regulatory_special_designation_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Contact Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Associated Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Decision Letter Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_letter_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `agency_reference_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `annual_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Annual Designation Report Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `denial_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Denial Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `denial_reason` SET TAGS ('dbx_business_glossary_term' = 'Designation Denial Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `designation_conditions` SET TAGS ('dbx_business_glossary_term' = 'Designation Conditions and Obligations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `designation_type` SET TAGS ('dbx_business_glossary_term' = 'Special Designation Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `fee_waiver_applicable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Fee Waiver Applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `grant_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Grant Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Target Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `market_exclusivity_years` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Designation Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `request_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Request Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `tax_credit_applicable` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Tax Credit Applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`special_designation` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_agency_meeting_id` FOREIGN KEY (`agency_meeting_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`agency_meeting`(`agency_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_prior_action_item_regulatory_action_item_id` FOREIGN KEY (`prior_action_item_regulatory_action_item_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_action_item`(`regulatory_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_regulatory_correspondence_id` FOREIGN KEY (`regulatory_correspondence_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`correspondence`(`correspondence_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ADD CONSTRAINT `fk_regulatory_regulatory_action_item_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `prior_action_item_regulatory_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `regulatory_correspondence_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Correspondence Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `action_item_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Item Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `action_item_number` SET TAGS ('dbx_value_regex' = '^RAI-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `action_item_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|closed|overdue|cancelled');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_acknowledgement_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_mandated_due_date` SET TAGS ('dbx_business_glossary_term' = 'Agency-Mandated Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_mandated_due_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `agency_submission_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_email` SET TAGS ('dbx_business_glossary_term' = 'Assigned Owner Email Address');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `assigned_owner_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `finding_classification` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `review_cycle` SET TAGS ('dbx_value_regex' = 'initial|follow_up|final|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Action Item Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_action_item` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_regulatory_contact_employee_id` FOREIGN KEY (`regulatory_contact_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Contact Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `regulatory_contact_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `conditional_approval` SET TAGS ('dbx_business_glossary_term' = 'Conditional Approval Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Scope');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `ctd_module_scope` SET TAGS ('dbx_value_regex' = 'full|abridged|hybrid|bibliographic');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `dosage_form` SET TAGS ('dbx_business_glossary_term' = 'Registered Dosage Form');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|VNeeS');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Registration Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Registered Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `last_annual_report_date` SET TAGS ('dbx_business_glossary_term' = 'Last Annual Report Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `last_variation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Variation Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_business_glossary_term' = 'Local Agent Contact Information');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_contact` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_business_glossary_term' = 'Local Agent / Marketing Authorization Holder Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `local_agent_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `market_exclusivity_expiry` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Registration Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Registered Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `registration_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|withdrawn|pending|cancelled');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `registration_type` SET TAGS ('dbx_value_regex' = 'national|mutual_recognition|decentralized|centralized|bilateral');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `reimbursement_status` SET TAGS ('dbx_value_regex' = 'reimbursed|not_reimbursed|partial|pending|under_review');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'Registered Strength');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `submission_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `submission_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`country_registration` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ADD CONSTRAINT `fk_regulatory_procedure_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ADD CONSTRAINT `fk_regulatory_procedure_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ADD CONSTRAINT `fk_regulatory_procedure_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ADD CONSTRAINT `fk_regulatory_procedure_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` SET TAGS ('dbx_subdomain' = 'protocol_governance');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_id` SET TAGS ('dbx_business_glossary_term' = 'Procedure Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `assessment_report_type` SET TAGS ('dbx_value_regex' = 'EPAR|PAR|Assessment_Report|Review_Memo|None');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `clock_stop_allowed` SET TAGS ('dbx_business_glossary_term' = 'Clock Stop Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `ctd_modules_required` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Modules Required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `data_exclusivity_period_years` SET TAGS ('dbx_business_glossary_term' = 'Data Exclusivity Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `dossier_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|eCTD_v3|eCTD_v4');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Procedure Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `electronic_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `expedited_pathway_available` SET TAGS ('dbx_business_glossary_term' = 'Expedited Pathway Available Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Procedure Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Submission Fee Currency Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `local_agent_required` SET TAGS ('dbx_business_glossary_term' = 'Local Agent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `local_agent_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `market_exclusivity_period_years` SET TAGS ('dbx_business_glossary_term' = 'Market Exclusivity Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `mutual_recognition_agreement_applicable` SET TAGS ('dbx_business_glossary_term' = 'Mutual Recognition Agreement (MRA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `orphan_designation_applicable` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `pediatric_plan_required` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Investigation Plan (PIP) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `post_approval_variation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Post-Approval Variation Procedure');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `pre_submission_meeting_available` SET TAGS ('dbx_business_glossary_term' = 'Pre-Submission Meeting Available Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedural_requirements` SET TAGS ('dbx_business_glossary_term' = 'Procedural Requirements Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `rapporteur_required` SET TAGS ('dbx_business_glossary_term' = 'Rapporteur Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `reference_member_state_required` SET TAGS ('dbx_business_glossary_term' = 'Reference Member State Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `region_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Region Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `region_name` SET TAGS ('dbx_value_regex' = 'North America|Europe|Asia Pacific|Latin America|Middle East Africa|Global');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `region_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `rems_applicable` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `rolling_review_allowed` SET TAGS ('dbx_business_glossary_term' = 'Rolling Review Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `standard_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Standard Submission Fee Amount');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `standard_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|under_revision');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `submission_fee_applicable` SET TAGS ('dbx_business_glossary_term' = 'Submission Fee Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Subtype');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `procedure_type` SET TAGS ('dbx_value_regex' = 'centralized|decentralized|mutual_recognition|national|abbreviated|hybrid');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `validation_criteria` SET TAGS ('dbx_business_glossary_term' = 'Submission Validation Criteria');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`procedure` ALTER COLUMN `veeva_vault_procedure_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Procedure Reference ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_ctd_dossier_id` FOREIGN KEY (`ctd_dossier_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ctd_dossier`(`ctd_dossier_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_prepared_by_employee_id` FOREIGN KEY (`prepared_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_primary_submission_veeva_vault_version_id` FOREIGN KEY (`primary_submission_veeva_vault_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ADD CONSTRAINT `fk_regulatory_submission_content_unit_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ctd_dossier_id` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Dossier ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `primary_submission_veeva_vault_version_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Version ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Approved Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `cdisc_standard` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Standard');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `cdisc_standard` SET TAGS ('dbx_value_regex' = 'SDTM|ADaM|SEND|define-xml|none');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `cdisc_version` SET TAGS ('dbx_business_glossary_term' = 'CDISC Standard Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `checksum_algorithm` SET TAGS ('dbx_value_regex' = 'MD5|SHA-256|SHA-1');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `checksum_value` SET TAGS ('dbx_business_glossary_term' = 'File Checksum Value');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ctd_section_code` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ctd_section_code` SET TAGS ('dbx_value_regex' = '^[1-5](.[0-9]{1,2}){0,4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `dtd_version` SET TAGS ('dbx_business_glossary_term' = 'Document Type Definition (DTD) Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Lifecycle Operation');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `ectd_operation` SET TAGS ('dbx_value_regex' = 'new|replace|append|delete');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size (Bytes)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `leaf_identifier` SET TAGS ('dbx_business_glossary_term' = 'eCTD Leaf ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `prior_leaf_identifier` SET TAGS ('dbx_business_glossary_term' = 'Prior eCTD Leaf ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `target_agency_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `validation_error_message` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|warning|not_validated|pending');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`submission_content_unit` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_rems_administrator_employee_id` FOREIGN KEY (`rems_administrator_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ADD CONSTRAINT `fk_regulatory_rems_program_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_program_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Program ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Application ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_administrator_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Rems Administrator Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_administrator_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_administrator_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_administrator_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `assessment_schedule` SET TAGS ('dbx_business_glossary_term' = 'REMS Assessment Schedule');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `assessment_schedule` SET TAGS ('dbx_value_regex' = '18_months|3_years|7_years|annual|biennial|as_required');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `compliance_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Compliance Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `etasu_description` SET TAGS ('dbx_business_glossary_term' = 'Elements to Assure Safe Use (ETASU) Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `eu_risk_minimization_description` SET TAGS ('dbx_business_glossary_term' = 'EU Risk Minimization Measure Description');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `eu_risk_minimization_type` SET TAGS ('dbx_business_glossary_term' = 'EU Risk Minimization Measure Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `eu_risk_minimization_type` SET TAGS ('dbx_value_regex' = 'dhpc|educational_material|controlled_access|pregnancy_prevention|patient_alert_card|none');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `goal_compliance_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Goal Compliance Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `has_communication_plan` SET TAGS ('dbx_business_glossary_term' = 'Communication Plan Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `has_etasu` SET TAGS ('dbx_business_glossary_term' = 'Elements to Assure Safe Use (ETASU) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `has_medication_guide` SET TAGS ('dbx_business_glossary_term' = 'Medication Guide Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Approved Indication');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `inspection_readiness_flag` SET TAGS ('dbx_business_glossary_term' = 'REMS Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `lab_monitoring_required` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Monitoring Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `last_assessment_fda_response_date` SET TAGS ('dbx_business_glossary_term' = 'Last REMS Assessment FDA Response Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `last_assessment_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Last REMS Assessment Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `last_modification_date` SET TAGS ('dbx_business_glossary_term' = 'Last REMS Program Modification Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `modification_reason` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Modification Reason');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `next_assessment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next REMS Assessment Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `patient_enrollment_required` SET TAGS ('dbx_business_glossary_term' = 'Patient Enrollment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `pharmacy_certification_required` SET TAGS ('dbx_business_glossary_term' = 'Pharmacy Certification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `prescriber_certification_required` SET TAGS ('dbx_business_glossary_term' = 'Prescriber Certification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational/Approved Product Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'active|suspended|withdrawn|under_review|pending_approval');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_type` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `program_type` SET TAGS ('dbx_value_regex' = 'medication_guide|communication_plan|etasu|medication_guide_and_communication_plan|full_rems');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_contact_email` SET TAGS ('dbx_business_glossary_term' = 'REMS Program Regulatory Contact Email');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `rems_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`rems_program` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ADD CONSTRAINT `fk_regulatory_intelligence_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ADD CONSTRAINT `fk_regulatory_intelligence_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ADD CONSTRAINT `fk_regulatory_intelligence_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ADD CONSTRAINT `fk_regulatory_intelligence_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `intelligence_id` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `action_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Completed Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Due Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `capture_date` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Capture Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `intelligence_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Category');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `cdisc_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'CDISC Standards Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `comment_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Public Comment Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `document_status_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Document Status Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `document_status_type` SET TAGS ('dbx_value_regex' = 'draft|final|revised|withdrawn|superseded');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Document Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impact_level` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Impact Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impact_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|informational');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impact_scope` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Impact Scope');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impact_scope` SET TAGS ('dbx_value_regex' = 'global|regional|country_specific|product_specific|study_specific');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impact_summary` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Impact Summary');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `impacted_trial_phases` SET TAGS ('dbx_business_glossary_term' = 'Impacted Clinical Trial Phases');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `is_public_comment_opportunity` SET TAGS ('dbx_business_glossary_term' = 'Public Comment Opportunity Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `keywords` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Keywords');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Notes');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Priority Level');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'urgent|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Document Publication Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `recommended_actions` SET TAGS ('dbx_business_glossary_term' = 'Recommended Regulatory Actions');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Reference Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^RI-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `related_application_number` SET TAGS ('dbx_business_glossary_term' = 'Related Regulatory Application Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Review Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `source_name` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Source Name');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `source_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Source Type');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `source_url` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Source URL');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `intelligence_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `therapeutic_area` SET TAGS ('dbx_business_glossary_term' = 'Impacted Therapeutic Area');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Intelligence Title');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`intelligence` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ADD CONSTRAINT `fk_regulatory_regulatory_engagement_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ADD CONSTRAINT `fk_regulatory_regulatory_engagement_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ADD CONSTRAINT `fk_regulatory_regulatory_engagement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` SET TAGS ('dbx_association_edges' = 'regulatory.health_authority,program.clinical_program');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `regulatory_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Engagement - Regulatory Engagement Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `regulatory_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Engagement - Clinical Program Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Engagement - Health Authority Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `agency_interaction_plan` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT (European Union Drug Regulating Authorities Clinical Trials) Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Number');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,6}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `lead_agency_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `primary_regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Start Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_engagement` ALTER COLUMN `target_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Target Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ADD CONSTRAINT `fk_regulatory_protocol_ethics_coverage_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ADD CONSTRAINT `fk_regulatory_protocol_ethics_coverage_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ADD CONSTRAINT `fk_regulatory_protocol_ethics_coverage_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` SET TAGS ('dbx_subdomain' = 'protocol_governance');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` SET TAGS ('dbx_association_edges' = 'regulatory.ind_application,compliance.ethics_submission');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `protocol_ethics_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Ethics Coverage - Protocol Ethics Coverage Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `protocol_ethics_coverage_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Ethics Coverage - Ethics Submission Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Ethics Coverage - Ind Application Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `ethics_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`protocol_ethics_coverage` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ADD CONSTRAINT `fk_regulatory_label_approval_country_registration_id` FOREIGN KEY (`country_registration_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`country_registration`(`country_registration_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ADD CONSTRAINT `fk_regulatory_label_approval_labeling_document_id` FOREIGN KEY (`labeling_document_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`labeling_document`(`labeling_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ADD CONSTRAINT `fk_regulatory_label_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` SET TAGS ('dbx_subdomain' = 'approval_tracking');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` SET TAGS ('dbx_association_edges' = 'regulatory.labeling_document,regulatory.country_registration');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `label_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Label Approval - Label Approval Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `country_registration_id` SET TAGS ('dbx_business_glossary_term' = 'Label Approval - Country Registration Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `labeling_document_id` SET TAGS ('dbx_business_glossary_term' = 'Label Approval - Labeling Document Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Label Approval Status');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Applicable Country Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `current_approved_flag` SET TAGS ('dbx_business_glossary_term' = 'Current Approved Label Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Label Effective Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `health_authority_approval_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `health_authority_approval_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `labeling_version` SET TAGS ('dbx_business_glossary_term' = 'Approved Labeling Version');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`label_approval` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Label Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ADD CONSTRAINT `fk_regulatory_binder_document_inclusion_labeling_document_id` FOREIGN KEY (`labeling_document_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`labeling_document`(`labeling_document_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ADD CONSTRAINT `fk_regulatory_binder_document_inclusion_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ADD CONSTRAINT `fk_regulatory_binder_document_inclusion_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` SET TAGS ('dbx_association_edges' = 'regulatory.labeling_document,document.regulatory_binder');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `binder_document_inclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Inclusion - Binder Document Inclusion Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `labeling_document_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Inclusion - Labeling Document Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Inclusion - Regulatory Binder Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Inclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Language Code');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_document_inclusion` ALTER COLUMN `redaction_required` SET TAGS ('dbx_business_glossary_term' = 'Redaction Required Flag');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ADD CONSTRAINT `fk_regulatory_dossier_ethics_reference_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ADD CONSTRAINT `fk_regulatory_dossier_ethics_reference_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ADD CONSTRAINT `fk_regulatory_dossier_ethics_reference_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` SET TAGS ('dbx_association_edges' = 'regulatory.nda_bla_application,compliance.ethics_approval');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `dossier_ethics_reference_id` SET TAGS ('dbx_business_glossary_term' = 'Dossier Ethics Reference - Dossier Ethics Reference Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Dossier Ethics Reference - Ethics Approval Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Dossier Ethics Reference - Nda Bla Application Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Date Added to Dossier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `ethics_committee_name` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Name (Dossier Reference)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `ethics_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`dossier_ethics_reference` ALTER COLUMN `submission_module_reference` SET TAGS ('dbx_business_glossary_term' = 'CTD Module Reference');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ADD CONSTRAINT `fk_regulatory_substantial_modification_submission_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ADD CONSTRAINT `fk_regulatory_substantial_modification_submission_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ADD CONSTRAINT `fk_regulatory_substantial_modification_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` SET TAGS ('dbx_association_edges' = 'regulatory.protocol_amendment,regulatory.clinical_trial_authorization');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `substantial_modification_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Substantial Modification Submission - Substantial Modification Submission Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Substantial Modification Submission - Clinical Trial Authorization Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Substantial Modification Submission - Regulatory Protocol Amendment Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Modification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Modification Decision Outcome');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`substantial_modification_submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Modification Submission Date');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ADD CONSTRAINT `fk_regulatory_binder_content_inclusion_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ADD CONSTRAINT `fk_regulatory_binder_content_inclusion_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ADD CONSTRAINT `fk_regulatory_binder_content_inclusion_submission_content_unit_id` FOREIGN KEY (`submission_content_unit_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission_content_unit`(`submission_content_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` SET TAGS ('dbx_subdomain' = 'submission_management');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` SET TAGS ('dbx_association_edges' = 'regulatory.submission_content_unit,document.regulatory_binder');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ALTER COLUMN `binder_content_inclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Content Inclusion - Binder Content Inclusion Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Content Inclusion - Regulatory Binder Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ALTER COLUMN `submission_content_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Content Inclusion - Submission Content Unit Id');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`binder_content_inclusion` ALTER COLUMN `ctd_section_code` SET TAGS ('dbx_business_glossary_term' = 'CTD Section Code (Binder-Specific)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ADD CONSTRAINT `fk_regulatory_regulatory_inspection_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ADD CONSTRAINT `fk_regulatory_regulatory_inspection_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ADD CONSTRAINT `fk_regulatory_regulatory_inspection_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_domain' = 'regulatory');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_subdomain' = 'authority_relations');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_subdomain' = 'regulatory_inspection');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` SET TAGS ('dbx_canonical_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Identifier');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_canonical' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `inspected_entity_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `inspected_entity_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `inspected_entity_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `inspected_entity_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `lead_inspector_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`regulatory`.`regulatory_inspection` ALTER COLUMN `lead_inspector_name` SET TAGS ('dbx_pii_name' = 'true');
