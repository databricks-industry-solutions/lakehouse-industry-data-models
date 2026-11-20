-- Schema for Domain: site | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:03:00

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`site` COMMENT 'Manages investigational sites including feasibility assessment, site selection, activation, PI qualifications, CRC assignments, IRB/IEC approval records, site performance metrics, monitoring visit scheduling, and close-out.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`investigational_site` (
    `investigational_site_id` BIGINT COMMENT 'Unique surrogate identifier for each investigational site record in the clinical research enterprise. Primary key for the master site record referenced by all study-site associations, feasibility assessments, and capacity records.',
    `local_lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Sites with local labs must reference the qualified lab_facility for specimen processing, local safety lab results, and site activation checklists.',
    `principal_investigator_id` BIGINT COMMENT 'FK to site.principal_investigator',
    `activation_date` DATE COMMENT 'Date on which the investigational site was formally activated and authorized to begin enrolling subjects into clinical trials. Marks the completion of all site initiation activities including IRB/IEC approval, regulatory submissions, and staff training.',
    `address_line1` STRING COMMENT 'Primary street address line of the investigational site facility. Required for regulatory submissions, site visit logistics, and TMF documentation.',
    `address_line2` STRING COMMENT 'Secondary address line for the investigational site (suite, floor, building, department). Supplements the primary address for precise facility location identification.',
    `city` STRING COMMENT 'City in which the investigational site is located. Used for geographic distribution analysis, patient recruitment planning, and regulatory submissions.',
    `closeout_date` DATE COMMENT 'Date on which the investigational site was formally closed out, completing all study-related activities, resolving outstanding data queries, and returning or destroying unused investigational product. Triggers archival obligations per GCP.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the investigational site is located. Determines applicable regulatory authority (FDA, EMA, PMDA, MHRA, TGA, Health Canada), GCP guidelines, and data privacy regulations (GDPR, HIPAA).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the investigational site master record was first created in the system of record (the source system Supports ALCOA+ data integrity principles and audit trail requirements under 21 CFR Part 11.',
    `duns_number` STRING COMMENT 'Dun & Bradstreet Data Universal Numbering System (DUNS) nine-digit identifier for the investigational site organization. Used for sponsor contracting, grant management, and financial due diligence.. Valid values are `^[0-9]{9}$`',
    `edc_system` STRING COMMENT 'Electronic Data Capture (EDC) system deployed at the investigational site for eCRF data entry and clinical data management. Determines site training requirements, data integration pathways, and 21 CFR Part 11 compliance approach.. Valid values are `medidata_rave|oracle_clinical_one|veeva_vault_edcr|other|none`',
    `eudract_site_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) site-level identifier assigned for EU-regulated clinical trials. Required for EMA regulatory submissions and EU CTR 536/2014 compliance reporting.',
    `facility_type` STRING COMMENT 'Classification of the investigational site by facility category, indicating the type of healthcare or research institution. Drives feasibility scoring, site selection criteria, and therapeutic area alignment assessments.. Valid values are `academic_medical_center|community_hospital|private_clinic|research_institute|outpatient_center|other`',
    `fax_number` STRING COMMENT 'Fax number for the investigational site, used for transmission of regulatory documents, IRB/IEC correspondence, and sponsor communications where electronic submission is not available.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `fda_fei_number` STRING COMMENT 'U.S. Food and Drug Administration (FDA) Facility Establishment Identifier (FEI) number assigned to the investigational site. Required for FDA-regulated clinical trials and referenced in IND applications and NDA/BLA submissions.. Valid values are `^[0-9]{7,10}$`',
    `gcp_certification_expiry_date` DATE COMMENT 'Date on which the investigational sites current GCP certification expires. Triggers renewal workflow and site eligibility review. Sites with expired GCP certification are ineligible for new study activations.',
    `gcp_certification_status` STRING COMMENT 'Current Good Clinical Practice (GCP) certification status of the investigational site, reflecting compliance with ICH E6(R2) training and audit requirements. Sites must maintain active GCP certification to participate in sponsor-funded clinical trials.. Valid values are `certified|expired|pending_renewal|not_certified`',
    `gcp_compliance_status` STRING COMMENT 'Current GCP compliance status of the investigational site based on the most recent monitoring visit, audit, or inspection findings. Drives risk-based monitoring intensity, CAPA requirements, and site eligibility for new study assignments.. Valid values are `compliant|minor_findings|major_findings|critical_findings|under_review`',
    `has_dedicated_research_staff` BOOLEAN COMMENT 'Indicates whether the investigational site employs dedicated clinical research staff (e.g., Clinical Research Coordinators (CRCs), research nurses) exclusively for clinical trial conduct, as opposed to relying solely on general clinical staff.',
    `has_local_laboratory` BOOLEAN COMMENT 'Indicates whether the investigational site has an on-site clinical laboratory certified to process and analyze clinical trial specimens. Relevant for protocol feasibility, sample logistics planning, and central vs. local lab decisions.',
    `has_pharmacy` BOOLEAN COMMENT 'Indicates whether the investigational site has an on-site pharmacy capable of receiving, storing, dispensing, and accounting for investigational medicinal products (IMPs) per GCP and regulatory requirements.',
    `iras_number` STRING COMMENT 'UK Integrated Research Application System (IRAS) project identifier assigned to the site for studies conducted under MHRA oversight. Required for UK clinical trial regulatory submissions.',
    `irb_iec_name` STRING COMMENT 'Name of the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) responsible for ethical oversight of clinical research conducted at this investigational site. Required for regulatory submissions and TMF documentation.',
    `irb_iec_registration_number` STRING COMMENT 'Official registration or accreditation number of the IRB/IEC overseeing the investigational site. Required for FDA OHRP registration verification and EU CTR ethics committee identification.',
    `last_audit_date` DATE COMMENT 'Date of the most recent quality assurance (QA) audit conducted at the investigational site by the sponsor, CRO, or regulatory authority. Used to track audit frequency and compliance with quality management plans.',
    `last_monitoring_visit_date` DATE COMMENT 'Date of the most recent on-site or remote monitoring visit conducted by a Clinical Research Associate (CRA) at the investigational site. Used to track monitoring frequency compliance and schedule next visit per the monitoring plan.',
    `max_enrollment_capacity` BIGINT COMMENT 'Maximum number of subjects the investigational site can enroll and manage concurrently across all active clinical trials. Used for site capacity planning, feasibility assessments, and enrollment forecasting in the source system',
    `next_monitoring_visit_date` DATE COMMENT 'Planned date for the next monitoring visit at the investigational site, as scheduled in the CTMS monitoring plan. Supports CRA workload planning and ensures compliance with risk-based monitoring visit frequency requirements.',
    `number_of_exam_rooms` BIGINT COMMENT 'Total number of dedicated examination or procedure rooms available at the investigational site for clinical trial subject visits. Informs site capacity assessments and feasibility scoring.',
    `open_capa_count` BIGINT COMMENT 'Number of currently open Corrective and Preventive Actions (CAPAs) assigned to the investigational site resulting from monitoring visits, audits, or regulatory inspections. A key GCP compliance KPI tracked in MasterControl.',
    `operational_status` STRING COMMENT 'Current lifecycle status of the investigational site within the clinical research enterprise. Drives site eligibility for new study assignments, monitoring visit scheduling, and regulatory reporting.. Valid values are `active|inactive|pending_activation|closed|suspended|in_feasibility`',
    `phone_number` STRING COMMENT 'Primary telephone number for the investigational site facility. Used for CRA monitoring visit coordination, sponsor communications, and emergency contact during study conduct.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the investigational site. Used for geographic catchment area analysis, patient recruitment radius calculations, and regulatory address verification.',
    `site_code` STRING COMMENT 'Sponsor- or CRO-assigned alphanumeric code uniquely identifying the investigational site within the clinical trial management system (CTMS). Used as the operational business key across Medidata Rave, the source system and the source system for site. Valid values are `^[A-Z0-9]{3,20}$`',
    `site_email` STRING COMMENT 'Primary institutional email address for the investigational site. Used for sponsor and CRO communications, regulatory correspondence, and eTMF document distribution.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `site_name` STRING COMMENT 'Official legal or operating name of the investigational site facility (e.g., hospital, clinic, research center). Used for regulatory submissions, TMF documentation, and sponsor communications.',
    `site_tier` STRING COMMENT 'Sponsor or CRO-assigned tier classification reflecting the sites strategic importance, historical performance, enrollment capacity, and GCP compliance track record.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    `source_system_code` STRING COMMENT 'Native identifier for this investigational site record in the originating operational system of record (e.g., the source system site ID). Enables traceability from the Silver Layer lakehouse record back to the source system for lineage and reconciliation.',
    `state_province` STRING COMMENT 'State, province, or administrative region where the investigational site is located. Used for regulatory jurisdiction determination, IRB/IEC assignment, and geographic enrollment analytics.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the investigational site location (e.g., America/New_York, Europe/London). Used for scheduling monitoring visits, adverse event reporting timestamps, and cross-regional data reconciliation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the investigational site master record. Supports change tracking, data lineage, and ALCOA+ audit trail requirements under 21 CFR Part 11 and ICH E6(R2).',
    CONSTRAINT pk_investigational_site PRIMARY KEY(`investigational_site_id`)
) COMMENT 'Master record for each investigational site participating in clinical trials. Captures site identity, physical address, facility type, therapeutic area specializations, GCP certification status, regulatory registration numbers (e.g., FDA FEI, DUNS), site';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`site_contact` (
    `site_contact_id` BIGINT COMMENT 'Unique surrogate identifier for each site contact record within the Clinical Trial Management System (CTMS). Primary key for the site_contact entity.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site with which this contact is associated. Links the contact to the parent site record in the CTMS.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: site_contact tracks all personnel at an investigational site, including Principal Investigators (is_pi: BOOLEAN flag).',
    `contact_status` STRING COMMENT 'Current lifecycle status of the site contact record within the CTMS staff roster. Drives access provisioning, delegation log validity, and monitoring visit eligibility.. Valid values are `active|inactive|pending|terminated|on_leave`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the site contact is based. Used for regulatory jurisdiction determination, GDPR/HIPAA applicability, and multi-regional trial management.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when the site contact record was first created in the source CTMS system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_contact_code` STRING COMMENT 'External identifier for this contact as assigned by the source Clinical Trial Management System (the source system Used for cross-system reconciliation and audit traceability.',
    `ctms_user_code` STRING COMMENT 'Username or user identifier assigned to the site contact within the CTMS (the source system Supports access control, audit trail, and activity tracking for site staff within the trial management platform.',
    `cv_document_ref` STRING COMMENT 'Reference to the site contacts current curriculum vitae (CV) stored in the eTMF. The CV is a mandatory essential document for PI and Sub-Investigators per ICH E6(R2) and must be on file prior to site initiation.',
    `delegation_end_date` DATE COMMENT 'Date on which the site contacts delegation of authority for trial tasks was revoked or expired. Null if delegation is currently active. Used for audit trail and regulatory inspection documentation.',
    `delegation_log_ref` STRING COMMENT 'Reference identifier linking this site contact to the site delegation of authority log, which documents the specific trial tasks delegated to this individual by the Principal Investigator (PI). Mandatory per GCP and eTMF requirements.',
    `delegation_start_date` DATE COMMENT 'Date from which the site contact is authorized to perform delegated trial tasks as documented in the site delegation of authority log. Defines the effective start of the contacts trial responsibilities.',
    `department` STRING COMMENT 'Institutional department or clinical unit within the investigational site where the contact is based (e.g., Oncology, Cardiology, Clinical Research Unit). Supports site staff organization and monitoring visit planning.',
    `edc_system_access` BOOLEAN COMMENT 'Indicates whether the site contact has been provisioned with access to the Electronic Data Capture (EDC) system (e.g., Medidata Rave) for electronic Case Report Form (eCRF) data entry or review.',
    `edc_user_code` STRING COMMENT 'Username or user identifier assigned to the site contact within the EDC system (e.g., Medidata Rave). Required for audit trail attribution of eCRF data entries per 21 CFR Part 11 and ALCOA+ principles.',
    `email` STRING COMMENT 'Primary professional email address of the site contact. Used for study communications, monitoring visit notifications, and eTMF correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `end_date` DATE COMMENT 'Date on which the site contacts association with the investigational site was terminated or concluded. Null if the contact is currently active. Used for staff roster management and audit trail.',
    `fax_number` STRING COMMENT 'Fax number associated with the site contact, used for regulatory document transmission and IRB/IEC correspondence where electronic submission is not available.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `financial_disclosure_date` DATE COMMENT 'Date on which the site contact submitted their financial disclosure form to the sponsor. Required for regulatory compliance tracking and NDA/BLA submission readiness.',
    `financial_disclosure_status` STRING COMMENT 'Status of the site contacts financial disclosure form submission, required by FDA regulations for investigators to disclose financial interests that may affect study integrity. Mandatory for NDA/BLA submissions.. Valid values are `submitted|pending|not_required|expired`',
    `first_name` STRING COMMENT 'Given (first) name of the site contact individual. Used for staff roster management, correspondence, and delegation log identification.',
    `gcp_training_date` DATE COMMENT 'Date on which the site contact most recently completed GCP training. Used to determine training currency and trigger renewal reminders in compliance with ICH E6(R2) requirements.',
    `gcp_training_expiry_date` DATE COMMENT 'Date on which the site contacts current GCP training certification expires. Drives compliance alerts and site staff qualification monitoring within the CTMS and document management systems.',
    `gcp_training_provider` STRING COMMENT 'Name of the organization or platform that delivered the GCP training (e.g., CITI Program, TransCelerate, sponsor-provided training). Supports audit trail and regulatory inspection readiness.',
    `gcp_training_status` STRING COMMENT 'Current status of the site contacts Good Clinical Practice (GCP) training certification. GCP training is a mandatory regulatory requirement for all site staff involved in clinical trial conduct per ICH E6(R2).. Valid values are `current|expired|not_trained|in_progress`',
    `human_subjects_training_expiry_date` DATE COMMENT 'Expiration date of the site contacts human subjects research protection training certification. Drives compliance monitoring and renewal alerts.',
    `human_subjects_training_status` STRING COMMENT 'Status of the site contacts human subjects research protection training (e.g., CITI Human Subjects training). Required by OHRP and IRB regulations for all personnel involved in human subjects research.. Valid values are `current|expired|not_trained|in_progress`',
    `irb_iec_approval_ref` STRING COMMENT 'Reference to the IRB/IEC approval document that covers this site contacts participation in the trial, particularly relevant for PI and Sub-Investigator roles. Links to the eTMF approval record.',
    `is_pi` BOOLEAN COMMENT 'Indicates whether this site contact holds the role of Principal Investigator (PI) for the study at this site. The PI bears overall responsibility for the conduct of the clinical trial at the site per GCP guidelines.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this individual is the designated primary contact for the investigational site. The primary contact receives all official study communications, monitoring visit notifications, and regulatory correspondence.',
    `language_preference` STRING COMMENT 'Preferred language of the site contact for study communications, expressed as an IETF BCP 47 language tag (e.g., en-US, fr-FR, de-DE). Supports localized communication in trials.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_name` STRING COMMENT 'Family (last) name of the site contact individual. Used in combination with first_name for full identification on delegation logs, monitoring reports, and regulatory submissions.',
    `license_expiry_date` DATE COMMENT 'Expiration date of the site contacts professional medical or pharmacy license. Triggers renewal alerts to ensure continued regulatory compliance and site qualification validity.',
    `license_number` STRING COMMENT 'Professional medical or pharmacy license number of the site contact. Required for PI and Sub-Investigator qualification verification and regulatory submission documentation.',
    `license_state` STRING COMMENT 'State or jurisdiction in which the site contact holds their professional medical or pharmacy license. Used for regulatory compliance verification during site qualification.',
    `mobile_phone` STRING COMMENT 'Mobile phone number of the site contact for after-hours urgent communications, including SAE reporting and emergency site escalations.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `notes` STRING COMMENT 'Free-text field for additional contextual information about the site contact, such as special qualifications, communication preferences, or operational notes captured by the Clinical Research Associate (CRA) during site monitoring.',
    `phone` STRING COMMENT 'Primary professional phone number of the site contact. Used for urgent safety communications, monitoring visit coordination, and SAE follow-up.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `professional_title` STRING COMMENT 'Professional credential or academic title of the site contact (e.g., MD, PhD, PharmD, RN). Required for delegation log entries and regulatory qualification documentation per GCP guidelines.',
    `role_type` STRING COMMENT 'Functional role of the contact at the investigational site. Determines delegation authority, GCP training requirements, and access rights within the CTMS. [ENUM-REF-CANDIDATE: PI|Sub-Investigator|CRC|Pharmacist|Lab Contact|Study Coordinator|Regulatory',
    `specialty` STRING COMMENT 'Medical or scientific specialty of the site contact (e.g., Oncology, Neurology, Cardiology). Relevant for Principal Investigator (PI) and Sub-Investigator qualification assessments during site feasibility and selection.',
    `start_date` DATE COMMENT 'Date on which the site contact was first associated with the investigational site for clinical trial activities. Marks the beginning of the contacts active involvement in the study at this site.',
    `termination_reason` STRING COMMENT 'Reason for the termination or deactivation of the site contacts association with the site. Required for audit trail completeness and regulatory inspection readiness, particularly for for-cause terminations.. Valid values are `resigned|transferred|study_completed|for_cause|leave_of_absence|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when the site contact record was most recently modified in the source CTMS system. Supports change tracking, audit trail, and data lineage requirements per 21 CFR Part 11.',
    CONSTRAINT pk_site_contact PRIMARY KEY(`site_contact_id`)
) COMMENT 'Site contact - site owns its own contact; distinct from sponsor_contact and subject_contact.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`principal_investigator` (
    `principal_investigator_id` BIGINT COMMENT 'Unique surrogate identifier for the Principal Investigator (PI) master record in the Clinical Trial Management System (CTMS). Serves as the primary key for all downstream joins and regulatory traceability.',
    `board_certification` STRING COMMENT 'Name of the specialty board certification held by the PI (e.g., American Board of Internal Medicine - Oncology). Validates clinical expertise required by the study protocol.',
    `board_certification_expiry_date` DATE COMMENT 'Date on which the PIs board certification expires. Monitored to ensure ongoing qualification compliance during study conduct.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the PI master record was first created in the system. Supports ALCOA+ data integrity principles and audit trail requirements under 21 CFR Part 11.',
    `ctms_investigator_code` STRING COMMENT 'Source system investigator identifier from the source system Used for cross-system reconciliation and data lineage tracing between the lakehouse silver layer and the operational CTMS.',
    `cv_version_date` DATE COMMENT 'Date of the most recent version of the PIs curriculum vitae (CV) on file. The CV is a required TMF document demonstrating the PIs qualifications per ICH E6(R2).',
    `debarment_check_date` DATE COMMENT 'Date on which the most recent FDA debarment check was performed for this PI. Periodic re-checks are required per sponsor SOPs.',
    `debarment_check_status` STRING COMMENT 'Result of the FDA debarment check confirming the PI is not listed on the FDA Debarment List under 21 CFR Part 312.70. Mandatory pre-study qualification step.. Valid values are `not_checked|cleared|debarred|pending`',
    `delegation_log_current` BOOLEAN COMMENT 'Indicates whether the PIs delegation of authority log is current and up-to-date in the eTMF. A delegation log documents tasks delegated to sub-investigators and CRCs per ICH E6(R2).',
    `disqualification_date` DATE COMMENT 'Date on which the PI was disqualified from conducting clinical trials, either by a regulatory authority or by the sponsor. Nullable for active investigators.',
    `disqualification_reason` STRING COMMENT 'Narrative description of the reason for PI disqualification, if applicable. Populated only when lifecycle_status is disqualified. Required for regulatory audit trail.',
    `email` STRING COMMENT 'Primary professional email address for the PI used for regulatory correspondence, system access provisioning, and CTMS notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `eudract_investigator_number` STRING COMMENT 'European Clinical Trials Database (EudraCT / CTIS) identifier assigned to the PI for EU-based clinical trial registrations under EU CTR 536/2014.',
    `fda_investigator_number` STRING COMMENT 'FDA-assigned investigator identifier, if applicable, used in IND applications and regulatory submissions to uniquely identify the PI in FDA systems.',
    `financial_disclosure_date` DATE COMMENT 'Date on which the PIs financial disclosure form (FDA Form 3454 or 3455) was most recently submitted. Required for NDA/BLA/MAA regulatory submissions.',
    `financial_disclosure_status` STRING COMMENT 'Status of the PIs financial disclosure filing (FDA Form 3454/3455) required under 21 CFR Part 54. Discloses financial interests that could affect study objectivity.. Valid values are `not_required|pending|submitted|accepted|expired`',
    `first_name` STRING COMMENT 'Legal given name of the Principal Investigator as it appears on medical licensure and FDA Form 1572.',
    `form_1572_date` DATE COMMENT 'Date on which the most recent FDA Form 1572 was signed and submitted for this PI. Used for regulatory compliance tracking and TMF completeness verification.',
    `form_1572_status` STRING COMMENT 'Current submission status of the FDA Form 1572 (Statement of Investigator) for this PI. The Form 1572 is a regulatory commitment by the PI to conduct the study per GCP and the approved protocol.. Valid values are `not_submitted|submitted|accepted|expired|superseded`',
    `gcp_training_date` DATE COMMENT 'Date on which the PI most recently completed ICH Good Clinical Practice (GCP) training. Required for regulatory compliance and site initiation visit (SIV) clearance.',
    `gcp_training_expiry_date` DATE COMMENT 'Date on which the PIs current GCP training certification expires. Triggers re-training workflow in MasterControl to maintain continuous compliance.',
    `gcp_training_provider` STRING COMMENT 'Name of the organization or platform that delivered the GCP training (e.g., CITI Program, TransCelerate, NIH). Used for audit trail and regulatory inspection readiness.',
    `inspection_history_flag` BOOLEAN COMMENT 'Indicates whether the PI has been subject to a prior FDA, EMA, MHRA, or other regulatory authority inspection. Used in risk-based site selection and monitoring planning.',
    `institution_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the PIs primary institution is located. Determines applicable regulatory framework (FDA, EMA, PMDA, TGA, Health Canada, MHRA).. Valid values are `^[A-Z]{3}$`',
    `institution_name` STRING COMMENT 'Name of the primary academic or medical institution with which the PI is affiliated (e.g., Johns Hopkins Hospital, Mayo Clinic). Used for site identification and regulatory submissions.',
    `irb_iec_approval_status` STRING COMMENT 'Current IRB/IEC approval status for the PI at their primary investigational site. Tracks whether the PI is authorized to conduct human subjects research under the approved protocol.. Valid values are `not_submitted|pending|approved|conditionally_approved|rejected|expired`',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory inspection (FDA, EMA, MHRA, PMDA, TGA, or Health Canada) at a site where this PI was the Principal Investigator.',
    `last_inspection_outcome` STRING COMMENT 'Outcome classification of the most recent regulatory inspection involving this PI. FDA classifications: No Action Indicated (NAI), Voluntary Action Indicated (VAI), Official Action Indicated (OAI).. Valid values are `no_action_indicated|voluntary_action_indicated|official_action_indicated|pending`',
    `last_name` STRING COMMENT 'Legal family name of the Principal Investigator as it appears on medical licensure and FDA Form 1572.',
    `lifecycle_status` STRING COMMENT 'Current operational status of the PI within the organizations investigator registry. Drives eligibility for new study assignments and regulatory reporting.. Valid values are `active|inactive|suspended|pending_qualification|disqualified|retired`',
    `medical_license_expiry_date` DATE COMMENT 'Date on which the PIs medical license expires. Triggers renewal alerts in CTMS to ensure continuous licensure compliance throughout study conduct.',
    `medical_license_number` STRING COMMENT 'State or national medical license number issued to the PI by the relevant medical licensing authority. Required for FDA Form 1572 and site qualification documentation.',
    `medical_license_state` STRING COMMENT 'Two-letter U.S. state code (or equivalent jurisdiction code) where the PIs medical license is issued and active. Used to validate practice authority at the investigational site.. Valid values are `^[A-Z]{2}$`',
    `npi_number` STRING COMMENT '10-digit National Provider Identifier (NPI) assigned by CMS to the PI. Used for U.S.-based regulatory submissions, billing reconciliation, and provider identity verification.. Valid values are `^[0-9]{10}$`',
    `orcid_number` STRING COMMENT 'Globally unique ORCID identifier for the PI, enabling unambiguous researcher identification across publications, regulatory submissions, and clinical trial registries.. Valid values are `^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$`',
    `phone` STRING COMMENT 'Primary professional contact phone number for the PI, used for urgent safety communications and site monitoring coordination.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `pi_type` STRING COMMENT 'Classification of the investigator role within the study hierarchy. Distinguishes the PI with full regulatory accountability from sub-investigators and coordinating investigators.. Valid values are `principal_investigator|sub_investigator|coordinating_investigator|national_coordinating_investigator`',
    `prior_study_count` BIGINT COMMENT 'Total number of clinical studies the PI has previously conducted as Principal Investigator. Used as a key metric in site feasibility assessments and sponsor qualification reviews.',
    `professional_title` STRING COMMENT 'Academic or professional degree designation of the PI (e.g., MD, PhD, PharmD). Used to verify minimum qualification requirements per protocol and regulatory submissions.',
    `protocol_training_complete` BOOLEAN COMMENT 'Indicates whether the PI has completed all required protocol-specific training for their currently assigned studies. Managed via MasterControl training management module.',
    `qualification_date` DATE COMMENT 'Date on which the PI was formally qualified and approved by the sponsor or CRO to conduct clinical trials. Marks the start of the PIs active lifecycle in the investigator registry.',
    `specialty` STRING COMMENT 'Primary medical or scientific specialty of the PI (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for protocol feasibility matching and site selection scoring.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the PI master record. Supports change tracking, audit trail compliance, and incremental data pipeline processing per 21 CFR Part 11.',
    `years_of_experience` BIGINT COMMENT 'Total number of years the PI has been conducting clinical trials. Used in site feasibility scoring and sponsor qualification assessments.',
    CONSTRAINT pk_principal_investigator PRIMARY KEY(`principal_investigator_id`)
) COMMENT 'Master record for Principal Investigators (PIs) conducting clinical trials. Captures PI credentials, medical license numbers, specialty, board certifications, GCP training history, FDA Form 1572 submission status, financial disclosure status, debarment';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` (
    `feasibility_assessment_id` BIGINT COMMENT 'Unique system-generated identifier for the site feasibility assessment record. Primary key for this entity.',
    `assessed_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Feasibility assessments are conducted by CRAs or clinical operations staff; GCP documentation requires identifying who performed the assessment.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Program-level site feasibility reporting aggregates assessments across all studies in a program to support portfolio-level site selection strategy and program planning decisions.',
    `confidentiality_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.confidentiality_agreement. Business justification: Feasibility assessment data (patient population, competing trials, site capabilities) is confidential sponsor information.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site being evaluated for feasibility.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Feasibility assessments formally evaluate a specific lab facilitys capability (lab_capabilities_available flag).',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Feasibility assessments are sponsor-commissioned deliverables. The sponsoring organizations identity is required to route results, apply sponsor-specific selection criteria, and',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Feasibility assessments evaluate site suitability for a specific investigational compound.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) proposed for this site and study during the feasibility evaluation.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Feasibility assessments evaluate a site against a specific protocol version — protocol complexity, visit burden, and eligibility criteria drive feasibility scoring.',
    `sample_size_calc_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sample_size_calc. Business justification: Feasibility assessments are conducted against a specific enrollment target derived from the sample size calculation.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this feasibility assessment is being conducted.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Feasibility assessments evaluate site expertise against a specific therapeutic area.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Feasibility questionnaires and assessment reports are TMF artifacts (DIA Zone 2, pre-study documentation).',
    `assessment_date` DATE COMMENT 'The date on which the feasibility assessment questionnaire was initiated or formally submitted by the site. Principal business event date for this transaction.',
    `assessment_number` STRING COMMENT 'Externally-known business identifier for the feasibility assessment, used in CTMS and sponsor communications (e.g., FA-2024-0042). Unique within a study.',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the feasibility assessment workflow within the CTMS. Tracks progression from initial draft through sponsor review to final decision.. Valid values are `draft|submitted|under_review|completed|cancelled`',
    `competing_trial_count` BIGINT COMMENT 'Number of currently active or planned clinical trials at the site that compete for the same patient population or therapeutic area. High competing trial load may reduce enrollment capacity.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this feasibility assessment record was first created in the source system. Supports audit trail requirements under GCP and 21 CFR Part 11.',
    `decision_date` DATE COMMENT 'Date on which the sponsor or CRO made the final site selection decision (selected, not selected, or on hold) based on this feasibility assessment.',
    `dedicated_research_staff_count` BIGINT COMMENT 'Number of dedicated clinical research staff (Clinical Research Coordinators (CRCs), research nurses, data entry staff) available at the site to support this study.',
    `edc_access_available` BOOLEAN COMMENT 'Indicates whether the site has the necessary IT infrastructure, internet connectivity, and hardware to access the studys Electronic Data Capture (EDC) system (e.g., Medidata Rave).',
    `enrollment_experience_score` DECIMAL(5,2) COMMENT 'Sub-score component reflecting the sites historical enrollment performance, patient population access, and therapeutic area experience. Contributes to the composite feasibility score.',
    `estimated_enrollment_capacity` BIGINT COMMENT 'The sites self-reported estimate of the number of eligible subjects it can enroll for this specific study over the planned enrollment period. Core metric for site selection decisions.',
    `estimated_screen_failure_rate` DECIMAL(5,2) COMMENT 'Sites estimated percentage of screened subjects expected to fail eligibility criteria for this study. Used to adjust enrollment projections and calculate required screening numbers.',
    `feasibility_score` DECIMAL(5,2) COMMENT 'Composite numeric score (typically 0–100) assigned to the site based on weighted evaluation of all feasibility criteria including enrollment potential, infrastructure, and experience. Used for comparative site ranking.',
    `feasibility_score_tier` STRING COMMENT 'Categorical tier classification derived from the feasibility score (e.g., High ≥ 75, Medium 50–74, Low < 50). Used for rapid site prioritization and sponsor reporting.. Valid values are `high|medium|low`',
    `gcp_training_current` BOOLEAN COMMENT 'Indicates whether the sites Principal Investigator and key study staff hold current GCP training certifications as required by ICH E6(R2) and applicable regulatory authorities.',
    `imaging_capabilities_available` BOOLEAN COMMENT 'Indicates whether the site has the required imaging infrastructure (e.g., MRI, CT, PET) specified in the study protocol for efficacy or safety assessments.',
    `irb_iec_status` STRING COMMENT 'Current status of the sites Institutional Review Board (IRB) or Independent Ethics Committee (IEC) relationship at the time of feasibility assessment. Active IRB/IEC is a prerequisite for site activation.. Valid values are `active|pending|not_established|expired`',
    `lab_capabilities_available` BOOLEAN COMMENT 'Indicates whether the site has on-site or contracted laboratory capabilities required by the study protocol (e.g., local lab processing, sample storage, cold chain management).',
    `patient_population_size` BIGINT COMMENT 'Estimated number of patients in the sites catchment area who match the studys target indication and could potentially be eligible for enrollment.',
    `pharmacy_capabilities_available` BOOLEAN COMMENT 'Indicates whether the site has an investigational drug pharmacy with appropriate storage, dispensing, and accountability capabilities as required by the study protocol.',
    `phase` STRING COMMENT 'The regulatory phase of the clinical trial (Phase I through Phase IV) for which the site is being assessed. Influences the complexity and infrastructure requirements evaluated.. Valid values are `Phase I|Phase II|Phase III|Phase IV`',
    `prior_study_experience_count` BIGINT COMMENT 'Number of prior clinical studies the site has conducted in the same therapeutic area or indication. Reflects site expertise and GCP compliance track record.',
    `questionnaire_response_notes` STRING COMMENT 'Free-text field capturing additional site comments, clarifications, or qualitative responses provided by the site during the feasibility questionnaire completion.',
    `questionnaire_version` STRING COMMENT 'Version identifier of the feasibility questionnaire template used for this assessment (e.g., v2.1). Ensures traceability of assessment criteria across protocol amendments.',
    `regulatory_compliance_score` DECIMAL(5,2) COMMENT 'Sub-score component reflecting the sites GCP compliance history, inspection findings, audit outcomes, and regulatory standing. Derived from CTMS compliance tracking data.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the sponsor or CRO representative who reviewed and approved the feasibility assessment and made the site selection decision.',
    `selection_decision` STRING COMMENT 'Final site selection outcome derived from this feasibility assessment. Indicates whether the site was selected, not selected, placed on hold, or awaiting decision.. Valid values are `selected|not_selected|on_hold|pending`',
    `site_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the investigational site is located. Used for regional enrollment planning and regulatory jurisdiction determination.. Valid values are `^[A-Z]{3}$`',
    `site_infrastructure_score` DECIMAL(5,2) COMMENT 'Sub-score component of the overall feasibility score reflecting the sites physical and technical infrastructure readiness (EDC, lab, pharmacy, imaging). Scored on a standardized scale.',
    `site_region` STRING COMMENT 'Geographic region classification of the investigational site (e.g., North America, Europe, Asia-Pacific). Used for regional enrollment tracking and sponsor reporting.',
    `source_system_record_code` STRING COMMENT 'The native primary key or record identifier of this feasibility assessment in the originating source system (the source system or the source system Enables lineage tracing and reconciliation.',
    `sponsor_comments` STRING COMMENT 'Free-text comments entered by the sponsor or CRO reviewer following evaluation of the feasibility questionnaire. Documents rationale for selection decisions or follow-up requirements.',
    `submission_date` DATE COMMENT 'Date on which the completed feasibility questionnaire was formally submitted by the site to the sponsor or CRO for review.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this feasibility assessment record. Supports audit trail and data integrity requirements under GCP and 21 CFR Part 11.',
    CONSTRAINT pk_feasibility_assessment PRIMARY KEY(`feasibility_assessment_id`)
) COMMENT 'Records the site feasibility evaluation conducted prior to site selection for a specific study. Captures feasibility questionnaire responses, estimated enrollment capacity, patient population availability, competing trial load, infrastructure readiness';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`selection` (
    `selection_id` BIGINT COMMENT 'Unique surrogate identifier for the site selection decision record. Primary key for the site_selection data product in the Databricks Silver Layer.',
    `activation_id` BIGINT COMMENT 'Reference to the site activation record that was initiated as a result of this selection decision. Null until the site transitions from selected to activation workflow. Establishes the selection-to-activation traceability chain.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) assigned as the primary monitor for this site-study pairing at the time of selection. Supports monitoring planning and workload management.',
    `feasibility_assessment_id` BIGINT COMMENT 'Reference to the prior feasibility assessment record that informed this site selection decision, establishing traceability from feasibility to selection.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site being evaluated and selected or rejected for participation in the study.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) proposed or confirmed for this study-site pairing at the time of selection. The PIs qualifications are a key selection criterion per GCP.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Site selection decisions are made against a specific protocol version; protocol_version is a plain-text denormalization.',
    `sample_size_calc_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sample_size_calc. Business justification: Site selection assigns target_enrollment_count and enrollment_rate_per_month to each site based on the studys sample size calculation.',
    `site_selection_committee_id` BIGINT COMMENT 'Reference to the selection committee or governance body that reviewed and approved or rejected this site selection decision.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this site selection decision was made. Links the selection event to the governing protocol.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_selection records the formal site selection decision for a study-site pairing. study_site is the canonical association entity representing the full lifecycle of that pairing.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Site selection documentation (selection rationale, committee decisions) is a TMF artifact (DIA Zone 2). The existing tmf_document_reference is a plain string.',
    `activation_target_date` DATE COMMENT 'Planned date by which the selected site should complete all activation requirements and be ready to enroll the first subject. Used for study timeline management and milestone tracking.',
    `competing_trial_count` BIGINT COMMENT 'Number of other active clinical trials running concurrently at this site at the time of selection. Used to assess site capacity and potential enrollment competition.',
    `conditional_requirements` STRING COMMENT 'Description of conditions that must be met before a conditionally selected site can proceed to activation (e.g., additional staff training, equipment procurement, IRB approval). Populated when selection_status is conditionally_selected.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the investigational site is located. Used for regulatory jurisdiction determination and multi-regional trial management.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this site selection record was first created in the source system. Used for audit trail and data lineage per ALCOA+ principles.',
    `ctms_site_record_code` STRING COMMENT 'The source system record identifier from the source system for this site selection record, enabling traceability and reconciliation between the Silver Layer and the operational CTMS.',
    `selection_date` DATE COMMENT 'The calendar date on which the formal site selection decision was made and approved by the selection committee. This is the principal business event date for this transaction.',
    `decision_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the site selection decision was formally recorded in the CTMS system, supporting 21 CFR Part 11 audit trail requirements.',
    `enrollment_rate_per_month` DECIMAL(5,2) COMMENT 'Projected number of subjects the site is expected to enroll per calendar month, based on feasibility assessment data. Used for study timeline planning and site performance forecasting.',
    `feasibility_score` DECIMAL(5,2) COMMENT 'Composite numeric score derived from the feasibility assessment, summarizing the sites overall suitability for the study. Higher scores indicate greater suitability. Used as a key input to the selection decision.',
    `first_patient_in_target_date` DATE COMMENT 'Target date for enrolling the first subject (First Patient In / FPI) at this site. A key study milestone used for enrollment planning and sponsor KPI reporting.',
    `gcp_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether the site has been confirmed as GCP-compliant at the time of selection, based on prior audit history, inspection records, and training verification.',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) granted approval for the study at this site. Null if approval has not yet been obtained at time of selection.',
    `irb_iec_status` STRING COMMENT 'Status of the IRB (Institutional Review Board) or IEC (Independent Ethics Committee) approval at the time of site selection. Tracks whether ethics oversight is in place or pending.. Valid values are `not_submitted|submitted|approved|pending|waived|not_required`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this site selection record. Supports change tracking and audit trail requirements per ALCOA+ and 21 CFR Part 11.',
    `notes` STRING COMMENT 'Free-text field for additional comments, observations, or contextual information recorded by the selection committee or CRA that do not fit into structured fields. Supports comprehensive documentation per ALCOA+ principles.',
    `number` STRING COMMENT 'Externally-known business identifier for this site selection decision record, used in CTMS, eTMF, and sponsor communications (e.g., SS-PROT001-00042). Serves as the human-readable reference number.. Valid values are `^SS-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `patient_population_size` BIGINT COMMENT 'Estimated number of eligible patients in the sites catchment area who meet the studys inclusion/exclusion criteria, as assessed during feasibility. A primary driver of the selection decision.',
    `pi_qualification_verified` BOOLEAN COMMENT 'Indicates whether the Principal Investigators (PI) qualifications, CV, and GCP training have been verified and confirmed as adequate for this study at the time of selection, per ICH E6(R2) requirements.',
    `prior_audit_finding` BOOLEAN COMMENT 'Indicates whether the site has any prior significant audit findings or regulatory inspection observations that were considered as part of the selection decision. Supports risk-based site selection.',
    `rationale` STRING COMMENT 'Narrative justification for the site selection decision, documenting the business and scientific reasons the site was chosen or rejected. Required for TMF documentation and sponsor oversight.',
    `region` STRING COMMENT 'Sponsor-defined geographic region grouping for the site (e.g., North America, Europe, Asia-Pacific). Used for regional enrollment tracking, CRA assignment, and operational reporting.',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether a regulatory submission (e.g., IND amendment, CTA, or national competent authority notification) is required before this site can be activated. Drives regulatory workflow initiation.',
    `rejection_reason_code` STRING COMMENT 'Standardized code indicating the primary reason a site was not selected. Populated only when selection_status is rejected or withdrawn. [ENUM-REF-CANDIDATE',
    `rejection_reason_detail` STRING COMMENT 'Free-text elaboration of the rejection reason, providing additional context beyond the standardized rejection_reason_code. Populated only when the site is rejected or withdrawn.',
    `sponsor_approval_date` DATE COMMENT 'Date on which the sponsor formally approved the site selection decision. Null if sponsor approval is not required or has not yet been received.',
    `sponsor_approval_required` BOOLEAN COMMENT 'Indicates whether the sponsor must provide explicit written approval before this site selection decision is finalized. Relevant for CRO-managed studies where sponsor sign-off is a contractual requirement.',
    `sponsor_site_number` STRING COMMENT 'Sponsor-assigned alphanumeric identifier for the site within the context of this specific study, used in EDC, RTSM, and regulatory submissions. Distinct from the internal site_id.',
    `selection_status` STRING COMMENT 'Current lifecycle status of the site selection decision. Drives workflow transitions from feasibility through activation. [ENUM-REF-CANDIDATE: selected|rejected|pending_review|conditionally_selected|withdrawn|on_hold — promote to reference product]',
    `target_enrollment_count` BIGINT COMMENT 'The planned number of subjects to be enrolled at this site as agreed at the time of selection. Used for enrollment planning, site performance benchmarking, and resource allocation.',
    `selection_type` STRING COMMENT 'Categorizes the nature of the site selection: whether the site is a newly added site, a replacement for a terminated site, a backup site held in reserve, or an expansion site added to increase enrollment capacity.. Valid values are `new_site|replacement_site|backup_site|expansion_site`',
    `visit_conducted` BOOLEAN COMMENT 'Indicates whether a formal site selection visit (also known as a pre-study site visit or PSSV) was conducted at this site prior to the selection decision, as recommended by ICH E6(R2).',
    `visit_date` DATE COMMENT 'Date on which the site selection visit (pre-study site visit / PSSV) was conducted. Null if no visit was conducted or if the visit is pending.',
    CONSTRAINT pk_selection PRIMARY KEY(`selection_id`)
) COMMENT 'Records the formal site selection decision for a study-site pairing, including selection rationale, selection committee approval, selection date, rejection reasons (if applicable), and the transition from feasibility to activation.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`study_site` (
    `study_site_id` BIGINT COMMENT 'Unique surrogate identifier for the study-site association record in the Databricks Silver Layer. Primary key for this entity.',
    `central_lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Each study_site is assigned a central laboratory for specimen analysis. This drives specimen shipment routing, lab kit ordering, result reporting, and eTMF documentation.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Each study_site in EU member states is governed by a specific CTA for that country.',
    `employee_id` BIGINT COMMENT 'Reference to the primary Clinical Research Associate (CRA) assigned to monitor this site for this study. The CRA conducts Source Data Verification (SDV) and GCP compliance oversight on behalf of the sponsor or CRO.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site master record. Links to the site entity representing the physical or organizational research location.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) assigned to lead clinical research activities at this site for this study. The PI is responsible for the conduct of the trial per ICH E6(R2) GCP.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: In site-stratified randomization, each study_site is assigned a specific randomization list in the IRT/RTSM system.',
    `study_id` BIGINT COMMENT 'FK to study.study.study_id — Critical for study-site relationship — study_site is the association entity linking studies to sites, must have direct FK to study for enrollment tracking and site activation workflows.',
    `budget_agreed_amount` DECIMAL(18,2) COMMENT 'Total agreed budget amount for this sites participation in the study, as specified in the Clinical Trial Agreement. Covers per-patient fees, overhead, and procedure costs. Managed in the source system accounting.',
    `budget_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the agreed site budget amount (e.g., USD, EUR, GBP, JPY). Required for multi-currency financial reporting and reconciliation in the source system. Valid values are `^[A-Z]{3}$`',
    `capacity_subjects` BIGINT COMMENT 'Maximum number of subjects the site has declared capacity to enroll and manage concurrently for this study, based on staff resources, facilities, and patient population. Used in feasibility assessment and enrollment planning.',
    `cda_execution_date` DATE COMMENT 'Date on which the Confidential Disclosure Agreement (CDA) between the sponsor/CRO and the site was fully executed. A prerequisite milestone in the site activation workflow before protocol sharing.',
    `contract_execution_date` DATE COMMENT 'Date on which the Clinical Trial Agreement (CTA) or Clinical Site Agreement between the sponsor/CRO and the site institution was fully executed. A mandatory activation milestone before site initiation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this study-site association record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `drug_shipment_auth_date` DATE COMMENT 'Date on which authorization was granted to ship investigational medicinal product (IMP) to this site. A critical activation milestone managed via RTSM/IRT (e.g., Medidata RTSM). Shipment cannot proceed without IRB approval and regulatory clearance.',
    `edc_provisioning_date` DATE COMMENT 'Date on which the site was provisioned and granted access to the Electronic Data Capture (EDC) system (e.g., Medidata Rave) for this study. Required before site staff can enter subject data into eCRFs.',
    `enrolled_count` BIGINT COMMENT 'Actual number of subjects who have been enrolled (consented and randomized or assigned to treatment) at this site to date. Updated from EDC/RTSM data feeds. Used for real-time enrollment performance monitoring.',
    `enrollment_close_date` DATE COMMENT 'Date on which enrollment of new subjects at this site was formally closed, either due to target achievement, sponsor decision, or protocol amendment. Marks transition to enrollment_complete status.',
    `enrollment_open_date` DATE COMMENT 'Date on which the site was authorized to begin enrolling subjects into the study. Marks the transition to enrolling status. Used for site performance analytics and FPFV (First Patient First Visit) tracking.',
    `enrollment_target` BIGINT COMMENT 'Planned number of subjects to be enrolled at this site for this study, as agreed between the sponsor/CRO and the site during feasibility and site selection. Used for site performance tracking and enrollment forecasting.',
    `fpfv_date` DATE COMMENT 'Date of the first subjects first protocol-specified visit at this site. A critical KPI milestone in clinical trial management used to measure site activation speed and study startup performance.',
    `gcp_compliance_status` STRING COMMENT 'Current GCP compliance status of the site for this study based on monitoring visit findings, audit results, and CAPA resolution. Drives risk-based monitoring intensity and escalation decisions.. Valid values are `compliant|minor_findings|major_findings|critical_findings|suspended`',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the IRB or IEC granted initial approval for the study protocol at this site. Milestone tracked in CTMS and eTMF for regulatory compliance.',
    `irb_iec_approval_number` STRING COMMENT 'Official approval reference number issued by the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) authorizing the conduct of this study at this site. Required before any subject enrollment can begin.',
    `irb_iec_expiry_date` DATE COMMENT 'Date on which the current IRB/IEC approval expires. Sites must obtain renewal before this date to continue enrollment. Triggers automated alerts in CTMS for renewal tracking.',
    `last_monitoring_visit_date` DATE COMMENT 'Date of the most recent monitoring visit (on-site or remote) conducted at this site for this study. Used to calculate time since last visit and trigger overdue monitoring alerts in CTMS.',
    `lplv_date` DATE COMMENT 'Date of the last subjects last protocol-specified visit at this site. Marks the end of active subject participation and triggers site close-out activities. Key milestone for study timeline management.',
    `monitoring_visit_count` BIGINT COMMENT 'Total number of monitoring visits (on-site and remote) conducted at this site for this study to date. Used for site oversight reporting and resource planning.',
    `next_monitoring_visit_date` DATE COMMENT 'Planned date for the next monitoring visit at this site for this study. Scheduled in CTMS based on risk tier, enrollment activity, and monitoring plan requirements.',
    `open_query_count` BIGINT COMMENT 'Number of currently open data queries (discrepancies or clarification requests) raised against eCRF data submitted by this site in the EDC system. A key data quality KPI for site performance management.',
    `protocol_deviation_count` BIGINT COMMENT 'Cumulative number of protocol deviations recorded at this site for this study. Includes both minor and major deviations. Used for site quality oversight, regulatory reporting, and CAPA management.',
    `protocol_number` STRING COMMENT 'Sponsor-assigned protocol identifier for the study associated with this site. Denormalized here for operational convenience and regulatory traceability without requiring a join to the study entity.',
    `regulatory_approval_date` DATE COMMENT 'Date on which the national competent authority (e.g., FDA, EMA, MHRA, PMDA) granted approval or authorization for this site to conduct the study. Required in certain jurisdictions before site activation.',
    `regulatory_submission_date` DATE COMMENT 'Date on which the required regulatory submission (e.g., IND amendment, national competent authority notification) was made for this site to participate in the study. Applicable for sites in jurisdictions requiring site-level regulatory approval.',
    `rejection_reason` STRING COMMENT 'Documented reason why a candidate site was not selected or was subsequently withdrawn from the study. Populated only when site_status transitions to a rejected or withdrawn state. Supports feasibility learning and sponsor reporting.',
    `risk_tier` STRING COMMENT 'Risk-based monitoring tier assigned to this site for this study, reflecting overall site risk profile based on enrollment performance, GCP compliance history, data quality, and PI experience. Determines monitoring visit frequency and SDV scope.. Valid values are `high|medium|low`',
    `sae_count` BIGINT COMMENT 'Total number of Serious Adverse Events (SAEs) reported from subjects enrolled at this site for this study. Used for safety signal monitoring and site-level safety oversight. Sourced from the source system',
    `screen_failure_count` BIGINT COMMENT 'Number of subjects who were screened but did not meet eligibility criteria and were not enrolled. Used to calculate screen failure rate, a key site performance metric for feasibility planning.',
    `screened_count` BIGINT COMMENT 'Total number of subjects who have undergone screening procedures at this site, regardless of eligibility outcome. Used to calculate screen failure rate and assess site recruitment efficiency.',
    `selection_date` DATE COMMENT 'Date on which the site was formally selected by the sponsor or CRO for participation in the study, following feasibility assessment and committee review.',
    `selection_rationale` STRING COMMENT 'Narrative justification for selecting this site for the study, including patient population access, PI expertise, infrastructure capability, and prior performance. Captured during the site selection committee review.',
    `site_closeout_date` DATE COMMENT 'Date on which the formal site close-out visit was completed and the site was officially closed for this study. Triggers archival of site documents in eTMF and final reconciliation activities.',
    `site_number` STRING COMMENT 'Sponsor-assigned alphanumeric site number unique within the study protocol. Used in EDC, RTSM, and regulatory submissions to identify the site within the trial context. Typically formatted as a 3–10 character code (e.g., US001, DE002).. Valid values are `^[A-Z0-9]{3,10}$`',
    `site_status` STRING COMMENT 'Current lifecycle status of the site within this study. Drives operational workflows in CTMS: candidate (under feasibility review), selected (approved for activation), initiated (Site Initiation Visit completed), enrolling (actively recruiting subjects). Valid values are `candidate|selected|initiated|enrolling|enrollment_complete|closed`',
    `siv_date` DATE COMMENT 'Date on which the Site Initiation Visit (SIV) was conducted by the CRA. The SIV confirms site readiness, trains site staff on the protocol and EDC system, and is a key activation milestone before first subject enrollment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this study-site association record. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `withdrawn_count` BIGINT COMMENT 'Number of enrolled subjects who withdrew consent or were discontinued from the study at this site. Tracked for safety reporting, ITT/PP population analysis, and site performance assessment.',
    CONSTRAINT pk_study_site PRIMARY KEY(`study_site_id`)
) COMMENT 'Association entity representing the full lifecycle relationship between a specific study (protocol) and an investigational site, from selection through activation to closeout.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`activation` (
    `activation_id` BIGINT COMMENT 'Unique surrogate identifier for the site activation workflow record in the Databricks Silver Layer. Primary key for this entity.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Site activation in EU trials cannot proceed without a valid CTA for that member state.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Site activation execution is governed by a specific SOP (ICH E6 R2 §5.2). CRAs and CTAs must reference the current SOP version when verifying essential documents, GCP training, and regulatory',
    `edc_study_build_id` BIGINT COMMENT 'Foreign key linking to datamanagement.edc_study_build. Business justification: Site activation tracks edc_access_provisioned_date and edc_access_status but not which build version was provisioned.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) assigned as the primary monitor for this site activation. The CRA is responsible for conducting the SIV and overseeing activation milestones.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Site activation is contingent on ethics approval being in place. The activation record must reference the ethics approval that authorized site opening.',
    `feasibility_assessment_id` BIGINT COMMENT 'Foreign key linking to site.feasibility_assessment. Business justification: Activation follows directly from feasibility assessment and site selection. The activation table has a denormalized feasibility_score field that originates from the',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site undergoing activation. Identifies the physical or organizational unit being onboarded for the study.',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to safety.investigator_brochure_safety. Business justification: Site activation requires confirmation that the current IB version has been provided to the investigator, a GCP essential document requirement per ICH E6(R2) 8.2.10.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: site_activation tracks IRB/IEC approval milestones (irb_iec_submission_date, irb_iec_approval_date, irb_iec_status, irb_iec_approval_expiry_date) as part of the activation workflow.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Site activation checklists require lab facility qualification confirmation as a prerequisite milestone before first patient enrollment.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding and overseeing the clinical study for which this site is being activated.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) responsible for conducting the clinical trial at this site. The PI is accountable for GCP compliance and subject safety.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Site activation is tied to a specific protocol version (protocol_receipt_date/status fields exist).',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Site activation milestone tracking requires confirming the IRT/RTSM randomization scheme is configured and accessible before first patient enrollment authorization.',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: Site activation requires confirmation of the governing regulatory approval (e.g., national competent authority decision).',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Activation cost budget tracking: site activation activities (SIV, regulatory submissions, EDC provisioning) consume startup budget.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this site is being activated. Links the activation workflow to the parent study protocol.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_activation tracks the end-to-end activation workflow milestones for a specific study-site pairing.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Site activation packages (activation letter, SIV confirmation) are mandatory TMF Zone 5 artifacts.',
    `actual_activation_date` DATE COMMENT 'The date on which the site was formally activated and cleared to enroll subjects. Corresponds to the completion of all mandatory activation milestones.',
    `cda_execution_date` DATE COMMENT 'The date on which the Confidentiality Disclosure Agreement (CDA) / Non-Disclosure Agreement (NDA) was fully executed between the sponsor/CRO and the investigational site. First milestone in the activation workflow.',
    `cda_status` STRING COMMENT 'Current status of the Confidentiality Disclosure Agreement (CDA) milestone within the site activation workflow.. Valid values are `not_started|sent|executed|waived|expired`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the investigational site is located. Used for regulatory jurisdiction determination and regional reporting.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this site activation record was first created in the system. Supports audit trail requirements under ICH E6(R2) GCP and 21 CFR Part 11 electronic records compliance.',
    `ctms_activation_record_code` STRING COMMENT 'The externally-known activation record identifier as assigned by the source system Used for cross-system traceability and source reconciliation.',
    `days_elapsed` BIGINT COMMENT 'Number of calendar days elapsed from the initiation of the activation workflow (CDA execution or site selection confirmation) to the current date or actual activation date. Used as a key performance indicator (KPI) for activation cycle time.',
    `drug_shipment_auth_date` DATE COMMENT 'The date on which authorization was granted to ship investigational medicinal product (IMP) to the site. Requires completion of all prerequisite activation milestones including IRB/IEC approval and investigator agreement execution.',
    `drug_shipment_auth_status` STRING COMMENT 'Current status of the investigational medicinal product (IMP) shipment authorization milestone for this site activation.. Valid values are `not_authorized|authorized|on_hold|revoked`',
    `edc_access_provisioned_date` DATE COMMENT 'The date on which site staff were granted access to the Electronic Data Capture (EDC) system (e.g., Medidata Rave) for this study, enabling electronic Case Report Form (eCRF) data entry.',
    `edc_access_status` STRING COMMENT 'Current status of EDC system access provisioning for site staff as part of the site activation workflow.. Valid values are `not_provisioned|provisioned|suspended|revoked`',
    `essential_docs_verified` BOOLEAN COMMENT 'Indicates whether all essential documents required for site activation (as defined in ICH E6(R2) Appendix) have been collected, verified, and filed in the Trial Master File (TMF) or eTMF.',
    `financial_agreement_executed` BOOLEAN COMMENT 'Indicates whether the site budget and payment agreement (Clinical Trial Agreement financial schedule) has been fully executed between the sponsor/CRO and the site institution, a prerequisite for site activation.',
    `fpfv_date` DATE COMMENT 'The date on which the first subject at this site completed their first protocol-mandated visit. A key clinical operations milestone marking the start of active enrollment at the site.',
    `gcp_training_completed` BOOLEAN COMMENT 'Indicates whether the site staff (PI and CRC) have completed mandatory Good Clinical Practice (GCP) training as required prior to site activation and subject enrollment.',
    `investigator_agreement_date` DATE COMMENT 'The date on which the Clinical Trial Agreement (CTA) or Investigator Agreement was fully executed between the sponsor/CRO and the Principal Investigator (PI) or site institution.',
    `investigator_agreement_status` STRING COMMENT 'Current status of the Investigator Agreement / Clinical Trial Agreement (CTA) milestone in the site activation workflow.. Valid values are `not_started|in_negotiation|executed|terminated|expired`',
    `irb_iec_approval_date` DATE COMMENT 'The date on which the IRB or IEC granted formal approval for the study to proceed at this site. A mandatory regulatory milestone before subject enrollment can begin.',
    `irb_iec_approval_expiry_date` DATE COMMENT 'The date on which the current IRB/IEC approval expires and renewal is required to continue subject enrollment at the site.',
    `irb_iec_status` STRING COMMENT 'Current status of the IRB/IEC review and approval milestone for this site activation. Tracks the ethical review lifecycle from submission through approval or rejection.. Valid values are `not_submitted|submitted|approved|deferred|disapproved|expired`',
    `irb_iec_submission_date` DATE COMMENT 'The date on which the study protocol and informed consent documents were submitted to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) for ethical review and approval.',
    `notes` STRING COMMENT 'Free-text field for capturing qualitative notes, issues, or comments related to the site activation workflow, including reasons for delays, hold conditions, or special circumstances noted by the CRA or project manager.',
    `on_hold_reason` STRING COMMENT 'Describes the reason the site activation workflow has been placed on hold, if applicable. Populated when activation_status is on_hold. Examples include sponsor decision, regulatory query, or site resource unavailability.',
    `planned_enrollment_target` BIGINT COMMENT 'The number of subjects the site is expected to enroll in the study as agreed during site selection and activation planning. Used for capacity planning and performance tracking.',
    `protocol_receipt_date` DATE COMMENT 'The date on which the investigational site confirmed receipt of the study protocol and related documents from the sponsor or CRO.',
    `protocol_receipt_status` STRING COMMENT 'Current status of the protocol receipt milestone in the site activation workflow, indicating whether the site has confirmed receipt of the study protocol.. Valid values are `not_started|sent|confirmed|waived`',
    `regulatory_pkg_approval_date` DATE COMMENT 'The date on which the health authority granted approval or clearance for the regulatory submission package, permitting the study to proceed at this site.',
    `regulatory_pkg_status` STRING COMMENT 'Current status of the regulatory package submission milestone in the site activation workflow.. Valid values are `not_started|submitted|approved|pending_query|waived`',
    `regulatory_pkg_submission_date` DATE COMMENT 'The date on which the regulatory submission package (including essential documents such as investigator brochure, protocol, and site-specific regulatory forms) was submitted to the applicable health authority.',
    `siv_completed_date` DATE COMMENT 'The date on which the Site Initiation Visit (SIV) was successfully completed. Completion of the SIV is a prerequisite for site activation and subject enrollment.',
    `siv_scheduled_date` DATE COMMENT 'The planned date for the Site Initiation Visit (SIV), during which the Clinical Research Associate (CRA) trains site staff on the protocol, EDC system, and GCP requirements.',
    `siv_status` STRING COMMENT 'Current status of the Site Initiation Visit (SIV) milestone within the site activation workflow.. Valid values are `not_scheduled|scheduled|completed|rescheduled|cancelled`',
    `activation_status` STRING COMMENT 'Current lifecycle state of the site activation workflow. Tracks overall progress from initiation through full activation or termination. [ENUM-REF-CANDIDATE: pending|in_progress|activated|on_hold|cancelled|closed — promote to reference product if',
    `target_activation_date` DATE COMMENT 'The planned date by which the site is expected to be fully activated and ready to enroll the first patient. Used for milestone tracking and timeline management in CTMS.',
    `activation_type` STRING COMMENT 'Categorizes the nature of the activation workflow — whether this is a new site being onboarded, a previously closed site being re-activated, a replacement for a terminated site, or an expansion site added mid-study.. Valid values are `new_site|re_activation|replacement_site|expansion_site`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this site activation record was last modified. Supports audit trail and data lineage requirements under ICH E6(R2) GCP, ALCOA+ principles, and FDA 21 CFR Part 11.',
    CONSTRAINT pk_activation PRIMARY KEY(`activation_id`)
) COMMENT 'Tracks the end-to-end site activation workflow milestones from site selection through first patient first visit (FPFV). Captures completion dates and status for each activation task: confidentiality agreement execution, protocol receipt, IRB/IEC';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` (
    `irb_iec_approval_id` BIGINT COMMENT 'Unique surrogate identifier for each IRB/IEC approval record within the Clinical Trial Management System (CTMS). Serves as the primary key for this entity.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU/EEA trials require a valid CTA before IRB/IEC approval is actionable for site activation.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: The site.irb_iec_approval (CTMS-recorded local approval) and compliance.ethics_approval (QMS formal approval record) represent the same regulatory event from different system',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the approving ethics committee (IRB or IEC) master record. The committee master data is owned by the ethics domain.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: An IRB/IEC approval is the outcome of an ethics submission. Linking the approval record to the originating submission enables end-to-end ethics workflow traceability (submission',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site for which this IRB/IEC approval applies. Each approval is specific to a study-site combination.',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to safety.investigator_brochure_safety. Business justification: IRB/IEC approvals reference the specific IB version reviewed and approved. When a SUSAR-triggered IB amendment occurs, the IRB/IEC must re-approve the new version.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: IRB/IEC approvals are granted for a specific protocol version — a core regulatory requirement (ICH E6 GCP).',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments require re-submission to IRB/IEC for approval. The irb_iec_approval record for an amendment review must reference the specific protocol_amendment that',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this IRB/IEC approval was obtained. Links the approval record to the study master data.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: IRB/IEC approvals are frequently amendment-specific — each protocol amendment requires separate ethics committee review and approval.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: irb_iec_approval records IRB/IEC approvals for a specific study-site combination. study_site is the canonical association entity for the study-site pairing.',
    `approval_conditions` STRING COMMENT 'Free-text description of any conditions, stipulations, or required modifications attached to a conditional approval. Must be resolved and documented before full approval is granted. Null if no conditions were imposed.',
    `approval_date` DATE COMMENT 'The date on which the IRB or IEC formally granted approval for the study to proceed at this site. This is the principal real-world event date for the approval lifecycle. Site activation cannot proceed before this date.',
    `approval_letter_received_date` DATE COMMENT 'The date on which the site or sponsor received the official IRB/IEC approval letter. May differ from the approval_date if there is a postal or administrative delay.',
    `approval_number` STRING COMMENT 'The official approval reference number or identifier issued by the IRB or IEC for this study-site combination. Used for regulatory submissions and site documentation.',
    `approval_status` STRING COMMENT 'Current lifecycle status of the IRB/IEC approval record: pending (submission received, awaiting decision), approved (full approval granted), conditionally_approved (approved with conditions to be resolved), suspended (approval temporarily halted). Valid values are `pending|approved|conditionally_approved|suspended|withdrawn|expired`',
    `approval_type` STRING COMMENT 'Categorizes the nature of the approval: initial (first approval for the study-site), amendment (approval of a protocol or ICF amendment), continuing_review (periodic re-approval), renewal (expiration-driven renewal), or waiver (waiver of specific. Valid values are `initial|amendment|continuing_review|renewal|waiver`',
    `approved_icf_date` DATE COMMENT 'The date of the approved ICF version. Used together with approved_icf_version to confirm the exact ICF document authorized for subject consent at this site.',
    `approved_icf_version` STRING COMMENT 'The specific version number of the Informed Consent Form (ICF) approved by the IRB/IEC for use at this site. Subjects must be consented using only the IRB/IEC-approved ICF version.',
    `committee_type` STRING COMMENT 'Classifies the type of ethics committee that issued the approval: IRB (Institutional Review Board, U.S.), IEC (Independent Ethics Committee, international), REC (Research Ethics Committee, UK), HREC (Human Research Ethics Committee, Australia), or EC. Valid values are `IRB|IEC|REC|HREC|EC`',
    `conditions_resolved_date` DATE COMMENT 'The date on which all conditions attached to a conditional IRB/IEC approval were formally resolved and confirmed by the ethics committee. Null if no conditions were imposed or if conditions remain outstanding.',
    `continuing_review_due_date` DATE COMMENT 'The deadline by which the continuing review submission must be received by the IRB/IEC to ensure uninterrupted approval. Typically set 30-60 days before the expiration date to allow processing time.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this IRB/IEC approval record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_approval_record_code` STRING COMMENT 'The native record identifier for this IRB/IEC approval in the the source system source system. Used for data lineage, reconciliation, and cross-system traceability.',
    `expiration_date` DATE COMMENT 'The date on which the current IRB/IEC approval expires. Enrollment and study activities must cease at this site if a renewal is not obtained before this date. Critical for continuing review scheduling.',
    `gcp_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has confirmed that the study will be conducted in accordance with GCP guidelines as part of the approval. Relevant for regulatory inspections and audit readiness.',
    `local_language_icf_approved` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has approved a local-language translation of the ICF for use at this site. Required for sites where the subject population is not primarily English-speaking.',
    `local_language_icf_version` STRING COMMENT 'Version identifier of the local-language ICF approved by the IRB/IEC. Null if no local-language ICF was required or approved.',
    `max_enrollment_approved` BIGINT COMMENT 'The maximum number of subjects that the IRB/IEC has approved for enrollment at this site under this approval. Enrollment must not exceed this number without a new amendment approval.',
    `notes` STRING COMMENT 'Free-text field for additional comments, observations, or contextual information related to this IRB/IEC approval record that are not captured in structured fields. Used by CRAs and CRCs for operational notes.',
    `pediatric_enrollment_approved` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has specifically approved enrollment of pediatric subjects at this site. Requires additional parental consent and assent documentation per applicable regulations.',
    `regulatory_authority_notified` BOOLEAN COMMENT 'Indicates whether the relevant regulatory authority (e.g., FDA, EMA, MHRA) has been notified of the IRB/IEC approval as required by applicable regulations. Supports regulatory submission tracking.',
    `regulatory_notification_date` DATE COMMENT 'The date on which the regulatory authority was notified of the IRB/IEC approval decision. Null if notification is not required or has not yet been sent.',
    `reinstatement_date` DATE COMMENT 'The date on which a previously suspended IRB/IEC approval was reinstated, allowing study activities to resume at the site. Null if the approval was never suspended or has not yet been reinstated.',
    `review_meeting_date` DATE COMMENT 'The date on which the IRB or IEC convened to review the submission for this study-site. Relevant for full-board reviews; may be null for expedited reviews.',
    `review_type` STRING COMMENT 'Indicates the type of review conducted by the ethics committee: full_board (convened meeting review), expedited (review by one or more members per 21 CFR 56.110), exempt (qualifies for exemption per 45 CFR 46.104), or administrative (non-substantive. Valid values are `full_board|expedited|exempt|administrative`',
    `submission_date` DATE COMMENT 'The date on which the study documentation package (protocol, ICF, investigator brochure, etc.) was formally submitted to the IRB or IEC for review. Marks the start of the review clock.',
    `suspension_date` DATE COMMENT 'The date on which the IRB or IEC suspended the approval for this study-site. Enrollment and study procedures must halt upon suspension. Null if the approval has never been suspended.',
    `suspension_reason` STRING COMMENT 'Free-text description of the reason for suspension of the IRB/IEC approval. Supports safety signal investigation, CAPA tracking, and regulatory reporting. Null if the approval has not been suspended.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this IRB/IEC approval record was most recently modified. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `vulnerable_population_approved` BOOLEAN COMMENT 'Indicates whether the IRB/IEC approval explicitly covers enrollment of vulnerable populations (e.g., minors, pregnant women, prisoners, cognitively impaired individuals). Requires additional safeguards per applicable regulations.',
    `waiver_of_consent_approved` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has granted a waiver or alteration of the informed consent requirement for this study-site. Applicable in specific circumstances such as emergency research.',
    `withdrawal_date` DATE COMMENT 'The date on which the IRB/IEC approval was formally withdrawn or revoked. Null if the approval has not been withdrawn.',
    CONSTRAINT pk_irb_iec_approval PRIMARY KEY(`irb_iec_approval_id`)
) COMMENT 'Records IRB (Institutional Review Board) and IEC (Independent Ethics Committee) approvals for a study-site combination. Captures submission date, approval date, approval number, expiration date, continuing review due date, approved protocol version';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` (
    `regulatory_submission_site_id` BIGINT COMMENT 'Unique surrogate identifier for each site-level regulatory submission record in the Clinical Trial Management System (CTMS). Serves as the primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Site-level regulatory submissions are made under a parent regulatory application (IND, MAA, etc.).',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Site-level regulatory submissions in EU member states are made as part of or in response to a CTA application.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) responsible for preparing, tracking, and following up on this site-level regulatory submission. The CRA is the primary liaison between the site and the sponsor/CRO for regulatory documentation.',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) that reviewed and approved this site submission. Captures the specific ethics body overseeing human subject protection at this site.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site that is the subject of this regulatory submission. Identifies the specific site within the CTMS.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Site-level regulatory submissions (e.g., FDA Form 1572, financial disclosures) often reference or depend on the IRB/IEC approval status.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Site-level regulatory submissions (IND amendments, CTA submissions, ethics notifications) fulfill specific regulatory obligations with defined timelines.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) named on this site-level regulatory submission. The PI is the individual responsible for the conduct of the clinical trial at the site, as declared on FDA Form 1572 or equivalent.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Regulatory submissions (CTAs, IND amendments) reference a specific protocol version — a named regulatory requirement. protocol_version is a plain-text denormalization.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Site-level regulatory submissions (e.g., country-specific CTA packages) are compiled into regulatory binders for agency submission.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this site-level regulatory submission was made. Links the submission to the governing study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Regulatory submissions to health authorities (e.g., CTA variations) are amendment-driven. amendment_number is a plain-text denormalization.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: regulatory_submission_site tracks site-level regulatory submissions required for trial conduct at a specific study-site.',
    `tmf_document_id` BIGINT COMMENT 'The document identifier assigned by the eTMF system (e.g., Veeva Vault) to the regulatory submission document. Enables direct cross-reference between the CTMS submission record and the corresponding document stored in the eTMF.',
    `approval_date` DATE COMMENT 'The calendar date on which the regulatory authority or ethics committee granted approval or authorization for the site to conduct the clinical trial. Null if submission has not yet been approved.',
    `approval_reference` STRING COMMENT 'The official reference number, protocol number, or tracking identifier issued by the regulatory authority or ethics committee upon approval of the site submission. Used for regulatory correspondence and audit trail.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code identifying the country in which the site is located and to whose regulatory jurisdiction this submission pertains (e.g., USA, GBR, JPN, AUS, CAN).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory submission record was first created in the CTMS or data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `document_title` STRING COMMENT 'The formal title of the regulatory submission document as filed with the regulatory authority or ethics committee (e.g., FDA Form 1572 - Statement of Investigator, IRB Initial Review Application). Supports document management and eTMF indexing.',
    `expiry_date` DATE COMMENT 'The date on which the regulatory approval or authorization for this site expires and must be renewed. Particularly relevant for IRB/IEC approvals which typically require annual renewal. Null for approvals with no defined expiry.',
    `financial_disclosure_type` STRING COMMENT 'Indicates the type of FDA financial disclosure form submitted for the investigator at this site: FDA Form 3454 (certification of no disclosable financial interest) or FDA Form 3455 (disclosure of financial interest).. Valid values are `FDA_3454_No_Disclosable_Interest|FDA_3455_Disclosable_Interest|Not_Applicable`',
    `financial_interest_disclosed` BOOLEAN COMMENT 'Indicates whether the investigator has disclosed a financial interest or arrangement that could affect the reliability of the clinical data, as required by 21 CFR Part 54.',
    `gcp_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether the investigator and site have confirmed compliance with Good Clinical Practice (GCP) guidelines as part of this submission (e.g., as declared on FDA Form 1572). Required for regulatory submissions under ICH E6(R2).',
    `icf_version` STRING COMMENT 'The version of the Informed Consent Form (ICF) that was submitted to and approved by the IRB/IEC as part of this regulatory submission. Tracks which ICF version is authorized for use at the site.',
    `local_language_icf` BOOLEAN COMMENT 'Indicates whether the ICF submitted for IRB/IEC approval is in the local language of the site country, as required for patient comprehension and regulatory compliance in non-English-speaking countries.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, internal comments, or operational notes related to this regulatory submission that are not captured in structured fields. Used by CRAs and regulatory affairs staff for tracking follow-up actions.',
    `regulatory_authority` STRING COMMENT 'The regulatory body or ethics committee to which this site-level submission was directed (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada, IRB, IEC, or local health authority). Determines applicable regulatory framework and review timelines.',
    `regulatory_timeline_days` BIGINT COMMENT 'The number of calendar days from submission date to approval date, representing the actual regulatory review cycle time for this submission. Used for site activation performance analytics and benchmarking against regulatory authority standard timelines.',
    `response_date` DATE COMMENT 'The actual date on which the site or sponsor submitted a formal response to regulatory authority or ethics committee queries or conditions. Used to track responsiveness and compliance with regulatory timelines.',
    `response_due_date` DATE COMMENT 'The deadline by which the site or sponsor must respond to regulatory authority or ethics committee queries, conditions, or requests for additional information arising from the review of this submission.',
    `review_comments` STRING COMMENT 'Narrative comments or conditions provided by the regulatory authority or ethics committee as part of their review decision. Captures required modifications, conditions of approval, or reasons for deferral or rejection.',
    `review_outcome` STRING COMMENT 'The formal outcome of the regulatory authoritys or ethics committees review of this submission. Distinct from submission_status in that it captures the specific decision rendered (e.g., approved with conditions, deferred pending additional information).. Valid values are `Approved|Approved_with_Conditions|Deferred|Rejected|Not_Applicable`',
    `sponsor_notification_date` DATE COMMENT 'The date on which the sponsor was formally notified of the regulatory submission outcome. Supports sponsor oversight tracking and compliance with ICH E6(R2) notification requirements.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of the regulatory submission outcome (approval, rejection, or conditions). Required under ICH E6(R2) for sponsor oversight of site regulatory compliance.',
    `submission_category` STRING COMMENT 'High-level category of the submission indicating whether it is an initial submission, a periodic renewal, a protocol amendment, a site closure notification, or a safety report submission to the ethics committee or regulatory authority.. Valid values are `Initial|Renewal|Amendment|Closure|Safety_Report|Other`',
    `submission_date` DATE COMMENT 'The calendar date on which the site-level regulatory submission was formally submitted to the regulatory authority or ethics committee. Serves as the principal business event date for this transaction.',
    `submission_method` STRING COMMENT 'The method by which the regulatory submission was transmitted to the regulatory authority or ethics committee (e.g., electronic portal, paper, email). Relevant for 21 CFR Part 11 electronic records compliance and audit trail.. Valid values are `Electronic|Paper|Portal|Email|Other`',
    `submission_number` STRING COMMENT 'Externally-known unique reference number assigned to this site-level regulatory submission, as tracked in the CTMS or eTMF (e.g., Veeva Vault document number or regulatory authority tracking number). Used for cross-system traceability.',
    `submission_portal_reference` STRING COMMENT 'The tracking or confirmation number issued by the regulatory authoritys electronic submission portal (e.g., FDA ESG, EMA CTIS, MHRA IRAS) upon receipt of the submission. Provides external confirmation of receipt.',
    `submission_status` STRING COMMENT 'Current lifecycle state of the site-level regulatory submission. Tracks progression from draft preparation through regulatory authority review to final disposition (approved, rejected, withdrawn, or superseded by an amendment).',
    `submission_type` STRING COMMENT 'Classification of the site-level regulatory submission. Includes FDA Form 1572 (Statement of Investigator), FDA Form 3454/3455 (Financial Disclosure), IRB/IEC applications, local health authority notifications, and country-specific site authorization',
    `submission_version` STRING COMMENT 'Version identifier for this submission document, used to track amendments and resubmissions (e.g., v1.0, v2.0, Amendment 1). Supports version control of regulatory documents in the eTMF.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory submission record was last modified in the CTMS or data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_regulatory_submission_site PRIMARY KEY(`regulatory_submission_site_id`)
) COMMENT 'Tracks site-level regulatory submissions required for trial conduct, including FDA Form 1572 (Statement of Investigator), financial disclosure forms (FDA Form 3454/3455), local health authority notifications, and country-specific site authorization';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`initiation_visit` (
    `initiation_visit_id` BIGINT COMMENT 'Unique surrogate identifier for the Site Initiation Visit (SIV) record in the Databricks Silver Layer. Primary key for this entity.',
    `activation_id` BIGINT COMMENT 'Foreign key linking to site.site_activation. Business justification: site_initiation_visit records the SIV event, which is a key milestone within the site activation workflow.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: CRAs verify CTA validity as a mandatory SIV checklist item in EU trials.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: SIV conduct is governed by a dedicated SOP covering protocol training, EDC setup, and IP handling. Regulatory inspectors verify that SIVs were conducted per the current SOP version.',
    `edc_study_build_id` BIGINT COMMENT 'Foreign key linking to datamanagement.edc_study_build. Business justification: SIV training and go-live confirmation requires documenting which EDC study build version was active and trained on at the site.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) assigned by the sponsor or CRO to conduct the Site Initiation Visit. The CRA is the primary party responsible for delivering the SIV.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: SIV authorization of first patient enrollment requires confirmed ethics approval.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site at which the Site Initiation Visit is conducted. Links to the site master record in the CTMS.',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to safety.investigator_brochure_safety. Business justification: SIV checklists confirm the investigator has received and reviewed the current IB version, a standard GCP requirement per ICH E6(R2).',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: site_initiation_visit records irb_iec_approval_number and irb_iec_approval_date as reference fields.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: SIV agendas include lab-specific training: specimen handling, kit usage, courier procedures, and processing instructions — all tied to the assigned central lab_facility.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) at the investigational site who attended or was represented at the Site Initiation Visit. The PI is the primary party responsible for the conduct of the trial at the site.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SIV protocol training is version-specific — investigators are trained on a specific protocol version, which must be documented in the TMF and delegation log.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this Site Initiation Visit is being conducted. Links the SIV to the parent study entity.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments requiring re-training trigger amendment-driven SIVs (re-initiation visits).',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_initiation_visit records the SIV event conducted by the CRA prior to first patient enrollment at a specific study-site.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The SIV report is a mandatory TMF artifact (DIA Zone 5, artifact 05.01). The existing tmf_document_reference is a plain string denormalization.',
    `action_item_count` BIGINT COMMENT 'Total number of action items identified and documented during the Site Initiation Visit. Used to track outstanding items that must be resolved before or shortly after first patient enrollment.',
    `actual_visit_date` DATE COMMENT 'The actual calendar date on which the Site Initiation Visit was conducted. May differ from the scheduled date due to rescheduling. This is the principal real-world event date for the SIV.',
    `attendee_count` BIGINT COMMENT 'Total number of site staff and sponsor/CRO personnel who attended the Site Initiation Visit. Used to assess adequacy of training coverage and for visit report documentation.',
    `attendee_names` STRING COMMENT 'Comma-separated list of names of all personnel who attended the Site Initiation Visit, including site staff (PI, CRC, pharmacist, etc.) and sponsor/CRO representatives (CRA, project manager). Documented in the SIV report for TMF filing.',
    `cancellation_reason` STRING COMMENT 'Free-text description of the reason for cancellation or rescheduling of the Site Initiation Visit, when applicable. Populated only when visit_status is cancelled or rescheduled. Used for root cause analysis and site management.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this Site Initiation Visit record was first created in the system. Supports audit trail requirements per ALCOA+ and 21 CFR Part 11.',
    `edc_training_completed` BOOLEAN COMMENT 'Indicates whether Electronic Data Capture (EDC) system training (e.g., Medidata Rave) was completed during the Site Initiation Visit. Site staff must be trained on eCRF completion prior to first patient enrollment.',
    `first_patient_enrollment_authorized` BOOLEAN COMMENT 'Indicates whether the Site Initiation Visit has resulted in formal authorization for the site to enroll the first patient (First Patient First Visit - FPFV). This flag drives site activation status in the CTMS.',
    `first_patient_enrollment_authorized_date` DATE COMMENT 'The date on which the site was formally authorized to enroll the first patient following successful completion of the Site Initiation Visit. Key milestone for site activation and study timeline tracking.',
    `gcp_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether GCP compliance requirements were reviewed and confirmed as met at the site during the Site Initiation Visit, including staff training records, facility adequacy, and regulatory documentation.',
    `icf_process_training_completed` BOOLEAN COMMENT 'Indicates whether training on the Informed Consent Form (ICF) process and procedures was completed during the SIV. Ensures site staff understand the requirements for obtaining valid informed consent from study subjects.',
    `ip_handling_training_completed` BOOLEAN COMMENT 'Indicates whether training on Investigational Product (IP) receipt, storage, dispensing, accountability, and return/destruction procedures was completed during the SIV.',
    `open_action_item_count` BIGINT COMMENT 'Number of action items from the Site Initiation Visit that remain unresolved/open at the time of record update. A non-zero value may indicate a site activation risk.',
    `protocol_training_completed` BOOLEAN COMMENT 'Indicates whether the study protocol training topic was covered and completed during the Site Initiation Visit. Protocol training is a mandatory SIV agenda item per GCP requirements.',
    `regulatory_authority_approval_obtained` BOOLEAN COMMENT 'Indicates whether the required national or regional regulatory authority approval (e.g., IND from FDA, CTA from EMA/MHRA) was confirmed as obtained prior to the Site Initiation Visit. A prerequisite for site activation.',
    `rtsm_training_completed` BOOLEAN COMMENT 'Indicates whether Randomization and Trial Supply Management (RTSM) / Interactive Response Technology (IRT) system training was completed during the SIV. Required for sites to perform patient randomization and manage investigational product supply.',
    `safety_reporting_training_completed` BOOLEAN COMMENT 'Indicates whether training on safety and Adverse Event (AE) / Serious Adverse Event (SAE) reporting procedures was completed during the SIV. Mandatory per GCP to ensure timely and accurate safety reporting.',
    `scheduled_visit_date` DATE COMMENT 'The planned calendar date on which the Site Initiation Visit is scheduled to occur, as recorded in the CTMS. Used for resource planning and site activation timeline tracking.',
    `siv_number` STRING COMMENT 'Externally-known business identifier for the SIV, typically generated by the CTMS (the source system and referenced in the Trial Master File (TMF). Used for cross-system traceability and regulatory audit purposes.. Valid values are `^SIV-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `siv_signoff_by` STRING COMMENT 'Name or identifier of the sponsor or CRO representative who provided formal sign-off on the Site Initiation Visit, confirming all objectives were met and the site is activated.',
    `siv_signoff_date` DATE COMMENT 'The date on which the Site Initiation Visit received formal sign-off from the sponsor or CRO representative, confirming site readiness for first patient enrollment.',
    `siv_signoff_status` STRING COMMENT 'Indicates the formal sign-off status of the Site Initiation Visit by the sponsor or CRO. Sign-off confirms that all SIV objectives were met and the site is authorized to enroll the first patient. Distinct from visit_status.. Valid values are `pending|signed_off|rejected|waived`',
    `source_system_record_code` STRING COMMENT 'The native primary key or record identifier of this SIV record in the originating operational system (e.g., the source system visit ID). Enables reverse traceability from the lakehouse back to the system of record.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this Site Initiation Visit record was most recently modified. Supports audit trail requirements and change tracking per ALCOA+ and 21 CFR Part 11.',
    `visit_end_time` TIMESTAMP COMMENT 'The precise date and time at which the Site Initiation Visit concluded. Used together with visit_start_time to calculate visit duration and assess adequacy of training time.',
    `visit_notes` STRING COMMENT 'Free-text field capturing additional observations, comments, or contextual information recorded by the CRA during or after the Site Initiation Visit. Supplements the structured visit report.',
    `visit_report_completion_date` DATE COMMENT 'The date on which the CRA completed and finalized the Site Initiation Visit report. Regulatory guidelines typically require visit reports to be completed within a defined number of days post-visit (e.g., 10 business days). Filed in the eTMF.',
    `visit_report_due_date` DATE COMMENT 'The contractually or procedurally defined deadline by which the SIV report must be completed and filed in the eTMF. Used to monitor CRA compliance with SOP timelines.',
    `visit_start_time` TIMESTAMP COMMENT 'The precise date and time at which the Site Initiation Visit commenced on the day of the visit. Used for duration calculation and audit trail purposes per ALCOA+ principles.',
    `visit_status` STRING COMMENT 'Current lifecycle status of the Site Initiation Visit. Tracks progression from scheduling through completion or cancellation. Used for CTMS workflow management and site activation tracking.. Valid values are `scheduled|completed|cancelled|rescheduled|in_progress`',
    `visit_type` STRING COMMENT 'Indicates whether the Site Initiation Visit was conducted on-site at the investigational site, remotely (e.g., via video conference), or as a hybrid combination. Relevant for regulatory acceptability and risk-based monitoring frameworks.. Valid values are `on_site|remote|hybrid`',
    CONSTRAINT pk_initiation_visit PRIMARY KEY(`initiation_visit_id`)
) COMMENT 'Records the Site Initiation Visit (SIV) event conducted by the CRA prior to first patient enrollment. Captures visit date, CRA assigned, attendees, training topics covered (protocol, EDC, RTSM, safety reporting, ICF process), action items identified';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` (
    `enrollment_performance_id` BIGINT COMMENT 'Unique surrogate identifier for each enrollment performance record at the study-site-reporting period level. Primary key for this data product in the Databricks Silver Layer.',
    `agreement_investigator_grant_id` BIGINT COMMENT 'Foreign key linking to agreement.investigator_grant. Business justification: Enrollment performance records (actual enrolled counts per period) drive payment milestone triggers defined in the investigator grant (per-patient fees, planned_subject_count',
    `finance_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to finance.finance_billing_milestone. Business justification: Enrollment milestone billing trigger: enrollment milestones (first patient in, 50% enrollment, last patient in) are standard billing milestone triggers in clinical trial',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site at which enrollment performance is being measured. Links to the site master record in the CTMS.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: enrollment_performance tracks irb_iec_approval_status and irb_iec_approval_expiry_date as part of the performance reporting context.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Enrollment performance reports are protocol-version-specific — screen failure rates and enrollment targets can change with amendments. protocol_number is a plain-text denormalization.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: Enrollment performance metrics (screen failure rate, dropout rate, deviation count, open queries) are primary inputs to site-level risk assessments under risk-based monitoring',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which enrollment performance is being tracked. Links to the study master record in the CTMS.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: enrollment_performance tracks actual vs. planned enrollment at the study-site level over time.',
    `active_subject_count` BIGINT COMMENT 'The number of subjects currently active (enrolled and not yet completed or discontinued) at this site as of the end of the reporting period. Reflects current site workload and capacity utilization.',
    `actual_enrolled_count` BIGINT COMMENT 'The actual number of subjects enrolled (randomized or consented per protocol definition) at this site during the reporting period. Sourced from Medidata Rave EDC and the source system randomization data.',
    `actual_screened_count` BIGINT COMMENT 'The actual number of subjects who underwent screening procedures at this site during the reporting period, as captured in the EDC (Medidata Rave) and reconciled with CTMS.',
    `completed_count` BIGINT COMMENT 'The number of subjects who completed all protocol-required study procedures and visits at this site during the reporting period. Used for PP population analysis and study close-out planning.',
    `cumulative_dropout_count` BIGINT COMMENT 'The total number of enrolled subjects who have discontinued participation at this site from study activation through the end of the current reporting period. Used for retention analysis and ITT/PP population tracking.',
    `cumulative_enrolled_count` BIGINT COMMENT 'The total number of subjects enrolled at this site from study activation through the end of the current reporting period. Primary metric for tracking progress toward the sites enrollment target.',
    `cumulative_screened_count` BIGINT COMMENT 'The total number of subjects screened at this site from study activation through the end of the current reporting period. Enables longitudinal enrollment trend analysis and forecasting.',
    `data_source` STRING COMMENT 'Indicates the originating system from which this enrollment performance record was sourced or integrated. Supports data lineage tracking and reconciliation between CTMS and EDC systems.. Valid values are `ctms|edc|manual|integrated`',
    `dropout_count` BIGINT COMMENT 'The number of enrolled subjects who discontinued participation (withdrew consent, were lost to follow-up, or were discontinued by investigator) during the reporting period. Impacts ITT and PP population sizes.',
    `dropout_rate` DECIMAL(5,2) COMMENT 'The proportion of enrolled subjects who dropped out during the reporting period, expressed as a percentage (dropout_count / actual_enrolled_count × 100). Stored as a raw business metric from CTMS; used for retention risk assessment and site performance',
    `enrollment_rate_per_month` DECIMAL(8,2) COMMENT 'The average number of subjects enrolled per calendar month at this site during the reporting period. Sourced from CTMS enrollment tracking; used for enrollment forecasting and site performance benchmarking.',
    `enrollment_target_achievement_pct` DECIMAL(5,2) COMMENT 'The percentage of the sites total enrollment target achieved cumulatively as of the end of the reporting period (cumulative_enrolled_count / site_enrollment_target × 100). Stored as a raw business metric from CTMS for site performance dashboards.',
    `enrollment_variance` BIGINT COMMENT 'The difference between actual enrolled subjects and planned enrolled subjects for the reporting period (actual_enrolled_count - planned_enrolled_count). Negative values indicate under-enrollment; positive values indicate over-enrollment.',
    `gcp_compliance_status` STRING COMMENT 'The current GCP compliance status of the site as assessed by the most recent monitoring visit or audit. Drives risk-based monitoring decisions and regulatory escalation. Sourced from the source system monitoring records.. Valid values are `compliant|minor_findings|major_findings|critical_findings|suspended`',
    `icf_signed_count` BIGINT COMMENT 'The number of subjects who signed the Informed Consent Form (ICF) at this site during the reporting period. ICF signature is the first step in the enrollment process and is tracked separately from screening and randomization per GCP requirements.',
    `irb_iec_approval_expiry_date` DATE COMMENT 'The date on which the current IRB/IEC approval for this study at this site expires. Sites must obtain renewal before this date to continue enrollment. Tracked in Veeva Vault regulatory module.',
    `irb_iec_approval_status` STRING COMMENT 'Current approval status of the study at this site from the governing Institutional Review Board (IRB) or Independent Ethics Committee (IEC). Sites may not enroll subjects without valid IRB/IEC approval.. Valid values are `approved|pending|expired|suspended|withdrawn`',
    `last_monitoring_visit_date` DATE COMMENT 'The date of the most recent on-site or remote monitoring visit conducted by the CRA at this site. Used to assess monitoring frequency compliance and identify sites overdue for monitoring.',
    `next_monitoring_visit_date` DATE COMMENT 'The date of the next scheduled monitoring visit at this site, as planned in the CTMS. Used for CRA workload planning and ensuring monitoring frequency meets the risk-based monitoring plan.',
    `open_query_count` BIGINT COMMENT 'The number of unresolved data queries (discrepancies or missing data flags) raised against this sites eCRF data in the EDC system as of the end of the reporting period. A key data quality indicator for site performance.',
    `performance_status` STRING COMMENT 'Current enrollment performance status of the site for the reporting period, indicating whether the site is meeting, exceeding, or falling short of its planned enrollment targets. Drives CRA escalation and site management actions in the CTMS.. Valid values are `on_track|at_risk|behind|ahead|closed|suspended`',
    `planned_completion_date` DATE COMMENT 'The originally planned date by which the site was expected to complete enrollment of its assigned target, as defined in the site enrollment plan or study protocol timeline.',
    `planned_enrolled_count` BIGINT COMMENT 'The target number of subjects planned to be enrolled (randomized or consented per protocol definition) at this site during the reporting period. Derived from the site-level enrollment plan agreed with the sponsor.',
    `planned_screened_count` BIGINT COMMENT 'The number of subjects planned to be screened at this site during the reporting period, as defined in the site enrollment plan or feasibility agreement. Baseline for screen failure rate analysis.',
    `projected_completion_date` DATE COMMENT 'The forecasted date by which the site is expected to complete enrollment of its assigned target, based on current enrollment rate. Updated each reporting period in the CTMS for timeline management.',
    `protocol_deviation_count` BIGINT COMMENT 'The number of protocol deviations recorded at this site during the reporting period. Includes both major and minor deviations as classified per the study deviation management plan. Sourced from CTMS deviation tracking.',
    `randomized_count` BIGINT COMMENT 'The number of subjects who were randomized (assigned to a treatment arm via RTSM/IVRS) at this site during the reporting period. Distinct from enrolled count in studies where enrollment precedes randomization.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The date and time when this enrollment performance record was first created in the data platform. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this enrollment performance record was most recently updated in the data platform. Supports audit trail requirements and change tracking per 21 CFR Part 11.',
    `reporting_period_end_date` DATE COMMENT 'The last calendar date of the enrollment performance reporting period. Together with reporting_period_start_date, defines the window for all enrollment metrics in this record.',
    `reporting_period_start_date` DATE COMMENT 'The first calendar date of the enrollment performance reporting period (e.g., start of a monthly or weekly reporting window). Used to define the temporal boundary for all enrollment metrics in this record.',
    `reporting_period_type` STRING COMMENT 'Granularity of the reporting period for this enrollment performance record. Determines the cadence at which site-level enrollment metrics are aggregated and reviewed.. Valid values are `weekly|monthly|quarterly|annual|custom`',
    `sae_count` BIGINT COMMENT 'The number of Serious Adverse Events (SAEs) reported at this site during the reporting period. Sourced from the source system Used to assess site safety profile and trigger risk-based monitoring escalation.',
    `screen_failure_count` BIGINT COMMENT 'The number of subjects who were screened but did not meet eligibility criteria and were therefore not enrolled during the reporting period. A key metric for site feasibility and protocol amendment decisions.',
    `screen_failure_rate` DECIMAL(5,2) COMMENT 'The proportion of screened subjects who failed screening, expressed as a percentage (screen_failure_count / actual_screened_count × 100). Stored as a raw business metric captured from CTMS; used to assess site eligibility criteria adherence and protocol',
    `site_capacity` BIGINT COMMENT 'The maximum number of subjects the site can concurrently manage based on staff, facilities, and resources, as assessed during site feasibility. Used to evaluate whether the site is operating within capacity.',
    `site_enrollment_target` BIGINT COMMENT 'The total number of subjects the site is contracted or planned to enroll over the full duration of the study, as agreed in the site initiation agreement or enrollment plan. Denominator for cumulative enrollment progress percentage.',
    `site_number` STRING COMMENT 'The sponsor- or CRO-assigned unique site identifier code for the investigational site. Used as the externally-known business identifier for the site in regulatory submissions and CTMS reporting.',
    CONSTRAINT pk_enrollment_performance PRIMARY KEY(`enrollment_performance_id`)
) COMMENT 'Tracks actual vs. planned enrollment performance at the study-site level over time. Captures reporting period, planned enrollment target, actual subjects screened, subjects enrolled, screen failure count, screen failure rate, dropout count, and cumulative';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`capacity` (
    `capacity_id` BIGINT COMMENT 'Unique surrogate identifier for the site capacity record. Primary key for the site_capacity data product in the Databricks Silver Layer.',
    `assessed_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Site capacity assessments are performed by CRAs or clinical operations staff. ICH E6 GCP requires documented accountability for capacity assessments used in site selection decisions.',
    `feasibility_assessment_id` BIGINT COMMENT 'Reference to the site feasibility assessment record that generated or last updated this capacity profile. Links to the feasibility assessment entity.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site for which this capacity record applies. Links to the site master entity in the CTMS.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Site capacity assessments evaluate therapeutic area expertise as a primary dimension for program-level site selection and resource planning.',
    `active_subject_count` BIGINT COMMENT 'Current number of subjects actively enrolled and on-study across all protocols at the site at the time of the capacity assessment. Used to calculate current capacity utilization.',
    `annual_patient_pool_size` BIGINT COMMENT 'Estimated number of patients seen annually at the site who could potentially qualify for clinical trial enrollment across therapeutic areas. A key input to enrollment feasibility planning and site selection scoring.',
    `approved_by` STRING COMMENT 'Name or identifier of the sponsor or CRO representative who formally approved this capacity record for use in site selection and enrollment planning.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time at which this capacity record was formally approved by the authorized sponsor or CRO representative. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `assessment_date` DATE COMMENT 'Calendar date on which the site capacity was formally assessed or declared. Used to determine the currency of the capacity data for site selection scoring.',
    `available_exam_rooms` BIGINT COMMENT 'Number of examination rooms at the site that are available and dedicated or allocable to clinical trial activities. Directly constrains the number of concurrent subject visits that can be conducted.',
    `competing_protocol_count` BIGINT COMMENT 'Number of active or pending clinical trial protocols currently running at the site that compete for the same patient population, staff resources, or infrastructure. A key input to site selection scoring and workload balancing.',
    `crc_count` BIGINT COMMENT 'Number of Clinical Research Coordinators (CRCs) currently assigned to or available at the site for trial coordination activities. Used in workload balancing and site selection scoring.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this site capacity record was first created in the system. Supports audit trail and data lineage requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `dedicated_research_fte` DECIMAL(5,2) COMMENT 'Total full-time equivalent (FTE) headcount of staff dedicated to clinical research activities at the site, including Clinical Research Coordinators (CRCs), research nurses, and sub-investigators. Expressed as a decimal (e.g., 2.5 FTE).',
    `dropout_rate_pct` DECIMAL(5,2) COMMENT 'Historical percentage of enrolled subjects who withdrew or were discontinued from trials at this site prior to study completion. Used in enrollment planning to account for subject attrition.',
    `ecg_capability` BOOLEAN COMMENT 'Indicates whether the site has on-site 12-lead ECG capability for cardiac safety assessments required by many clinical trial protocols.',
    `econsent_capable` BOOLEAN COMMENT 'Indicates whether the site is equipped and approved to administer electronic Informed Consent Forms (eICF) using an eConsent platform such as Clinpal, in compliance with applicable regulatory requirements.',
    `edc_system_capable` BOOLEAN COMMENT 'Indicates whether the site has the technical infrastructure and trained staff to use an Electronic Data Capture (EDC) system such as Medidata Rave for electronic Case Report Form (eCRF) data entry.',
    `effective_from_date` DATE COMMENT 'Date from which this capacity record is considered valid and applicable for site selection and enrollment planning purposes.',
    `effective_until_date` DATE COMMENT 'Date until which this capacity record remains valid. Null indicates the record is open-ended and currently active. Populated when a new version supersedes this record or the site closes.',
    `gcp_compliance_status` STRING COMMENT 'Current GCP compliance status of the site as determined by the most recent monitoring visit or audit. compliant indicates no findings; minor_findings indicates observations requiring corrective action; major_findings indicates significant. Valid values are `compliant|minor_findings|major_findings|critical_findings|not_assessed`',
    `imaging_capability` BOOLEAN COMMENT 'Indicates whether the site has on-site medical imaging capability (e.g., MRI, CT, PET, X-ray, ultrasound) relevant to clinical trial endpoint assessments. Sites without imaging may require referral to external imaging centers.',
    `irb_iec_approval_capacity` BIGINT COMMENT 'Maximum number of concurrent protocols for which the sites IRB/IEC has granted or is willing to grant approval. Regulatory constraint on the sites operational capacity.',
    `irt_rtsm_capable` BOOLEAN COMMENT 'Indicates whether the site staff are trained and equipped to use an IRT/RTSM system (such as Medidata RTSM) for subject randomization and investigational product dispensing.',
    `lab_processing_capable` BOOLEAN COMMENT 'Indicates whether the site has on-site laboratory processing capability for clinical trial samples (e.g., centrifugation, aliquoting, storage). Sites without this capability must rely on central or local reference laboratories.',
    `lab_sample_processing_capacity` BIGINT COMMENT 'Maximum number of clinical trial samples the on-site laboratory can process per day. Null if the site does not have on-site laboratory processing capability. Used to assess feasibility for high-frequency sampling protocols.',
    `last_monitoring_visit_date` DATE COMMENT 'Date of the most recent on-site monitoring visit conducted by a Clinical Research Associate (CRA). Used to assess the currency of the GCP compliance status and schedule the next monitoring visit.',
    `max_concurrent_protocols` BIGINT COMMENT 'Maximum number of distinct clinical trial protocols the site can run simultaneously without compromising GCP compliance or subject safety. Used for workload balancing across the site portfolio.',
    `max_concurrent_subjects` BIGINT COMMENT 'Maximum number of trial subjects the site can actively manage simultaneously across all concurrent protocols, as declared or assessed. This is the principal capacity metric used in site selection scoring and enrollment planning.',
    `notes` STRING COMMENT 'Free-text field for CRA or site management notes regarding specific capacity constraints, caveats, or contextual information not captured in structured fields (e.g., planned staff changes, facility renovations, seasonal patient volume variations).',
    `pharmacy_cold_chain_capable` BOOLEAN COMMENT 'Indicates whether the site pharmacy has validated cold chain storage capability (e.g., 2–8°C refrigeration or -20°C / -80°C freezer storage) for temperature-sensitive investigational medicinal products.',
    `pharmacy_storage_capacity_units` BIGINT COMMENT 'Number of discrete storage units (e.g., refrigerator slots, freezer compartments, or shelf units) available in the site pharmacy for investigational medicinal product (IMP) storage. Constrains the number of concurrent protocols requiring pharmacy support.',
    `pi_fte_allocation` DECIMAL(4,2) COMMENT 'Proportion of the Principal Investigators time (expressed as FTE) allocated to clinical research activities at this site. A PI with 0.5 FTE allocation is available 50% of their working time for trial oversight.',
    `recruitment_rate_per_month` DECIMAL(6,2) COMMENT 'Historical average number of subjects recruited per month by this site across prior clinical trials, based on CTMS enrollment data. Used as a predictive input for enrollment planning and site selection scoring.',
    `screen_failure_rate_pct` DECIMAL(5,2) COMMENT 'Historical percentage of screened subjects who failed to meet eligibility criteria and were not enrolled, based on prior trial data at this site. A high screen failure rate reduces effective enrollment capacity.',
    `site_selection_score` DECIMAL(5,2) COMMENT 'Composite numeric score (typically 0–100) assigned to the site based on capacity, feasibility, and performance metrics for use in site selection ranking. Calculated by the CTMS or feasibility scoring model.',
    `capacity_status` STRING COMMENT 'Current lifecycle status of this site capacity record. draft indicates an initial assessment in progress; active indicates the current approved capacity profile; under_review indicates a reassessment is in progress; suspended indicates the site is. Valid values are `draft|active|under_review|suspended|archived`',
    `capacity_type` STRING COMMENT 'Indicates whether the capacity figures were self-declared by the site (Principal Investigator or Site Coordinator), independently assessed by the CRA/CRO during a feasibility visit, or negotiated and agreed between the sponsor and site.. Valid values are `declared|assessed|negotiated`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this site capacity record was most recently modified. Supports audit trail and change tracking requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `utilization_pct` DECIMAL(5,2) COMMENT 'Percentage of the sites maximum concurrent subject capacity currently in use, calculated as (active_subject_count / max_concurrent_subjects) * 100. Expressed as a decimal percentage (e.g., 75.50 for 75.5%).',
    `version` BIGINT COMMENT 'Monotonically incrementing version number for this site capacity record, enabling historical tracking of capacity changes over time. Version 1 represents the initial assessment.',
    CONSTRAINT pk_capacity PRIMARY KEY(`capacity_id`)
) COMMENT 'Captures the declared and assessed operational capacity of an investigational site for concurrent trial participation. Tracks maximum concurrent subjects, available examination rooms, dedicated research staff FTE, pharmacy storage capacity, lab processing';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`site_agreement` (
    `site_agreement_id` BIGINT COMMENT 'Reference to the original site agreement record from which this amendment was derived. Null for original agreements (amendment_number = 0). Enables amendment lineage tracking and supersession chain reconstruction.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Master Site Agreements (MSAs) and Confidential Disclosure Agreements are negotiated at the program level, covering all studies within a program.',
    `confidentiality_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.confidentiality_agreement. Business justification: A CDA is a prerequisite for site agreement negotiation and execution. site_agreement.cda_execution_date is a denormalized date field; a proper FK to',
    `finance_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to finance.finance_billing_milestone. Business justification: Site payment schedule alignment: site agreements define payment_schedule_type tied to billing milestones (startup, per-patient, closeout).',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site that is party to this agreement. Links to the site master record in the CTMS, enabling site-level performance and compliance reporting.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: site_agreement tracks irb_iec_approval_required (flag) and irb_iec_approval_date as part of the agreement terms.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Individual site agreements (CTAs, CDAs) are governed by the master preferred provider agreement between CRO and sponsor.',
    `negotiation_owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Site agreements require a designated negotiation owner (contracts manager or CRA manager) accountable for the negotiation process.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Clinical trial agreements and CDAs are executed to fulfill specific regulatory obligations (ICH E6 R2, GDPR data processing agreements, financial disclosure requirements).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity that is the contracting party on the sponsor side of this agreement. Supports multi-sponsor portfolio management.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: Site agreements (CTAs) are signed by the Principal Investigator. The existing pi_name text field is a denormalized representation.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Clinical trial agreements (CTAs/CTUs) define scope and budget tied to a specific protocol version. Protocol amendments can trigger contract renegotiation.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Site budget negotiation and variance reporting: site agreements define per-patient fees and total budget amounts that must be reconciled against the study_budget for budget vs.',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: Site agreements are executed as flow-down instruments under a parent study contract.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this site agreement is executed. A single site may have separate agreements per study. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_agreement tracks site-level contractual agreements (CTA, CDA, budget) for a specific study-site combination. study_site is the canonical association entity for the study-site pairing.',
    `tmf_document_id` BIGINT COMMENT 'Reference identifier of the executed agreement document as stored in the Electronic Trial Master File (eTMF) in Veeva Vault. Enables direct navigation from the CTMS record to the source document for inspection readiness.',
    `agreement_number` STRING COMMENT 'Externally-known, human-readable reference number assigned to the site agreement (e.g., CTA-2024-0042). Used for cross-system tracking, regulatory correspondence, and audit trails. Sourced from the source system or Veeva Vault contract management module.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the site agreement. Tracks progression from initial drafting through negotiation, execution, and eventual expiry or termination. Drives workflow routing in Veeva Vault and the source system',
    `agreement_type` STRING COMMENT 'Classification of the site-level agreement. CTA (Clinical Trial Agreement) is the primary investigational site contract; CDA (Confidential Disclosure Agreement) governs pre-trial information sharing; Budget Amendment captures renegotiated financial terms. Valid values are `CTA|CDA|Budget Amendment|Site Budget Agreement|Letter of Intent`',
    `amendment_number` BIGINT COMMENT 'Sequential amendment version number for this agreement record. A value of 0 indicates the original agreement; values ≥1 indicate successive amendments. Enables version tracking of negotiated changes over the study lifecycle.',
    `closeout_fee` DECIMAL(18,2) COMMENT 'Fixed fee payable to the investigational site upon study close-out to cover archival, final monitoring visit support, and regulatory document finalization activities. Expressed in the currency defined by currency_code.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations under the agreement remain in force after the agreements expiration or termination. Particularly relevant for CDA (Confidential Disclosure Agreement) components.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when this site agreement record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `cro_entity` STRING COMMENT 'Name of the Contract Research Organization (CRO) acting as the contracting party on behalf of the sponsor, if applicable. Captures the legal entity name when the CRO executes the agreement under delegated authority.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to all financial terms within this site agreement (e.g., USD, EUR, GBP). Ensures consistent financial reporting across multi-country trials.. Valid values are `^[A-Z]{3}$`',
    `data_privacy_addendum` BOOLEAN COMMENT 'Indicates whether a data privacy addendum (DPA) or data processing agreement is included as part of or annexed to this site agreement, addressing GDPR, HIPAA, or other applicable data protection obligations for patient data.',
    `effective_date` DATE COMMENT 'Date on which the site agreement becomes legally binding and operative. Marks the start of the contractual relationship between the sponsor/CRO and the investigational site. Aligns with MASTER_AGREEMENT EFFECTIVE_FROM category.',
    `execution_date` DATE COMMENT 'Date on which all required parties signed and fully executed the site agreement. May differ from the effective date when agreements are backdated or have a future effective date. Critical for regulatory inspection readiness.',
    `expiration_date` DATE COMMENT 'Date on which the site agreement is scheduled to expire or cease to be operative. Nullable for open-ended agreements. Triggers renewal workflow alerts in Veeva Vault. Aligns with MASTER_AGREEMENT EFFECTIVE_UNTIL category.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code identifying the jurisdiction whose laws govern the interpretation and enforcement of this site agreement. Critical for multi-national trial legal compliance and dispute resolution.. Valid values are `^[A-Z]{3}$`',
    `indemnification_clause` BOOLEAN COMMENT 'Indicates whether the site agreement includes an indemnification clause protecting the investigational site and PI from third-party claims arising from the sponsors negligence. Standard in CTA templates but may be absent in certain jurisdictions.',
    `insurance_coverage_required` BOOLEAN COMMENT 'Indicates whether the agreement mandates that the sponsor or CRO maintain clinical trial insurance coverage for the duration of the study at this site. Regulatory requirement in many jurisdictions.',
    `insurance_policy_number` STRING COMMENT 'Reference number of the clinical trial insurance policy covering this site agreement. Populated when insurance_coverage_required is True. Used for regulatory inspection documentation.',
    `ip_ownership_clause` BOOLEAN COMMENT 'Indicates whether the site agreement contains an intellectual property ownership clause specifying that all study data, inventions, and results generated at the site are owned by the sponsor. Standard in CTA templates.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether IRB (Institutional Review Board) or IEC (Independent Ethics Committee) approval is a condition precedent to the agreement becoming operative.',
    `legal_review_completed` BOOLEAN COMMENT 'Indicates whether the sponsors or CROs legal team has completed their review and approved the final agreement text prior to execution. Part of the quality control workflow tracked in Veeva Vault.',
    `legal_review_date` DATE COMMENT 'Date on which the legal review of the site agreement was completed and sign-off was granted. Populated when legal_review_completed is True. Supports audit trail requirements under 21 CFR Part 11.',
    `negotiation_start_date` DATE COMMENT 'Date on which formal contract negotiation commenced between the sponsor/CRO and the investigational site. Used to calculate cycle time KPIs for site activation performance reporting in CTMS.',
    `notes` STRING COMMENT 'Free-text field for capturing supplementary notes, special conditions, deviations from standard templates, or negotiation context relevant to this site agreement. Supports audit trail and institutional knowledge retention.',
    `overhead_rate_pct` DECIMAL(5,2) COMMENT 'Institutional overhead or indirect cost rate (expressed as a percentage) applied on top of direct site costs as negotiated in the site budget agreement. Typically charged by academic medical centers or hospital institutions.',
    `payment_schedule_type` STRING COMMENT 'Defines the payment trigger mechanism agreed upon in the site budget agreement. Determines how and when invoices are generated and processed in the source system Payable.. Valid values are `Milestone|Per Visit|Per Patient|Monthly|Quarterly`',
    `payment_terms_days` BIGINT COMMENT 'Number of days from invoice receipt within which payment must be remitted to the investigational site, as stipulated in the site agreement (e.g., Net 30, Net 45, Net 60). Drives accounts payable processing in the source system',
    `per_patient_fee` DECIMAL(18,2) COMMENT 'Agreed fee payable to the investigational site for each evaluable patient who completes the study per protocol. Core financial term in the site budget agreement. Expressed in the currency defined by currency_code.',
    `publication_rights_clause` BOOLEAN COMMENT 'Indicates whether the site agreement includes a publication rights clause defining the investigators right to publish study results and the sponsors right to review manuscripts prior to submission. Relevant for academic site agreements.',
    `site_signature_date` DATE COMMENT 'Date on which the authorized representative of the investigational site (e.g., PI or institutional official) signed the agreement. May differ from the sponsor/CRO signature date in multi-party execution workflows.',
    `sponsor_signature_date` DATE COMMENT 'Date on which the authorized representative of the sponsor or CRO signed the agreement. The later of site_signature_date and sponsor_signature_date typically defines the execution_date.',
    `startup_fee` DECIMAL(18,2) COMMENT 'One-time fixed fee payable to the investigational site upon activation to cover site initiation activities such as staff training, IRB/IEC submission preparation, and regulatory document collection. Expressed in the currency defined by currency_code.',
    `termination_date` DATE COMMENT 'Date on which the site agreement was early-terminated prior to its scheduled expiration. Populated only when agreement_status is Terminated. Supports regulatory close-out documentation.',
    `termination_reason` STRING COMMENT 'Categorized reason for early termination of the site agreement. Required for regulatory reporting and site performance analytics. Populated only when agreement_status is Terminated.. Valid values are `Mutual Consent|Sponsor Decision|Site Decision|Regulatory Action|Protocol Termination|For Cause`',
    `total_budget_amount` DECIMAL(18,2) COMMENT 'Total contracted budget value for this site agreement, inclusive of all per-patient fees, procedures, overhead, and any fixed fees. Expressed in the currency defined by currency_code.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when this site agreement record was last modified. Supports change tracking, audit trail requirements under 21 CFR Part 11, and data lineage in the Databricks Silver Layer.',
    CONSTRAINT pk_site_agreement PRIMARY KEY(`site_agreement_id`)
) COMMENT 'Tracks site-level contractual agreements including Clinical Trial Agreements (CTA), Confidential Disclosure Agreements (CDA), and site-specific budget agreements.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` (
    `site_cra_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for each CRA-to-study-site assignment record in the Clinical Trial Management System (CTMS). Serves as the primary key for this entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: CRA monitoring assignments are executed under a governing monitoring SOP (ICH E6 R2 §5.18). The SOP version in effect at assignment start determines monitoring approach, SDV rates, and visit',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Monitoring cost allocation: CRA assignments drive monitoring travel and labor costs charged to specific cost centers.',
    `cra_qualification_id` BIGINT COMMENT 'Foreign key linking to workforce.cra_qualification. Business justification: CRA assignment to a site requires verification of the CRAs qualification record (therapeutic area experience, sponsor qualifications, monitoring visit count).',
    `delivery_preference_id` BIGINT COMMENT 'Foreign key linking to sponsor.delivery_preference. Business justification: CRA monitoring assignments must be configured to sponsor-specific delivery preferences: monitoring strategy (risk-based vs.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site to which the CRA is assigned for monitoring coverage. Identifies the physical or virtual site conducting the clinical trial.',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the study-level monitoring plan document that governs the monitoring activities for this assignment. Links to the monitoring plan record in the CTMS or eTMF.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization for whom the CRA monitoring assignment is being performed. Supports sponsor-level reporting and contractual obligation tracking.',
    `primary_site_employee_id` BIGINT COMMENT 'Reference to the CRA employee record in the workforce domain (the source system the individual CRA responsible for monitoring activities at the assigned site.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: A site-level CRA assignment is the operational instantiation of a study-level workforce assignment.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this CRA assignment is made. Links the assignment to a specific investigational study protocol managed in the CTMS.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_cra_assignment records the assignment of CRAs to study-site combinations for monitoring. study_site is the canonical association entity for the study-site pairing.',
    `tertiary_site_cro_oversight_manager_employee_id` BIGINT COMMENT 'Reference to the workforce record of the CRO line manager or clinical operations manager responsible for overseeing this CRA assignment. Supports management hierarchy, escalation routing, and performance review.',
    `approval_date` DATE COMMENT 'The date on which this CRA assignment was formally approved by the responsible manager or clinical operations lead. Required for GCP compliance and audit trail documentation.',
    `assignment_notes` STRING COMMENT 'Free-text field for capturing operational notes, special instructions, or contextual information relevant to this CRA-site assignment (e.g., site-specific access requirements, language considerations, sponsor preferences).',
    `assignment_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the CRA assignment record as generated by the CTMS (e.g., CRA-ASGN-2024-00123). Used for cross-system reference, audit trails, and operational communication.. Valid values are `^CRA-ASGN-[A-Z0-9]{4,20}$`',
    `assignment_reason` STRING COMMENT 'The business reason for creating or modifying this CRA assignment. Supports operational reporting and root cause analysis for assignment changes. [ENUM-REF-CANDIDATE',
    `assignment_status` STRING COMMENT 'Current lifecycle state of the CRA assignment. pending = approved but not yet started; active = currently monitoring; on_hold = temporarily suspended; completed = assignment concluded per plan; cancelled = terminated before completion. Valid values are `pending|active|on_hold|completed|cancelled|transferred`',
    `assignment_type` STRING COMMENT 'Categorizes the role of the CRA within the site monitoring coverage model. primary indicates the main responsible monitor; backup covers absence; co_monitor indicates joint monitoring; lead designates a senior oversight role; remote indicates. Valid values are `primary|backup|co_monitor|lead|remote`',
    `confidentiality_agreement_signed` BOOLEAN COMMENT 'Indicates whether the assigned CRA has signed the required confidentiality or non-disclosure agreement (NDA) for this study prior to accessing study data. True = signed; False = pending. Regulatory and sponsor compliance requirement.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this CRA assignment record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_assignment_ref` STRING COMMENT 'The native assignment identifier or record number from the source the source system system. Enables traceability back to the operational system of record for reconciliation and audit purposes.',
    `delegation_log_entry_confirmed` BOOLEAN COMMENT 'Indicates whether the CRAs monitoring responsibilities have been formally documented on the sites delegation of authority log, as required by GCP. True = confirmed on delegation log; False = pending confirmation.',
    `end_date` DATE COMMENT 'The date on which the CRAs monitoring responsibility for the assigned study-site combination is scheduled to conclude or was actually concluded. Null for open-ended active assignments.',
    `estimated_travel_days_per_visit` DECIMAL(4,1) COMMENT 'The estimated number of travel days required per monitoring visit for this CRA-site assignment. Used for resource capacity planning, travel cost estimation, and CRA workload calculation.',
    `gcp_training_current` BOOLEAN COMMENT 'Indicates whether the assigned CRA holds a current, valid GCP training certification at the time of assignment. True = GCP training is current and valid; False = training expired or not on file. Regulatory compliance requirement per ICH E6(R2).',
    `gcp_training_expiry_date` DATE COMMENT 'The date on which the assigned CRAs GCP training certification expires. Used to proactively manage compliance and ensure no lapse in qualified monitoring coverage.',
    `geographic_territory` STRING COMMENT 'The geographic territory or region to which this CRA assignment belongs (e.g., Northeast US, Western Europe, APAC). Used for territory-based workload planning, travel budgeting, and CRA deployment optimization.',
    `handover_date` DATE COMMENT 'The date on which monitoring responsibility was formally transferred from the predecessor CRA to the current CRA. Relevant for assignment transfers and ensures no monitoring coverage gap.',
    `handover_visit_completed` BOOLEAN COMMENT 'Indicates whether a formal handover monitoring visit was conducted between the outgoing and incoming CRA at the site. True = handover visit completed; False = not yet completed or not applicable.',
    `last_monitoring_visit_date` DATE COMMENT 'The date of the most recent monitoring visit (on-site or remote) conducted by this CRA at the assigned site under this assignment. Used for visit scheduling, overdue visit tracking, and site oversight reporting.',
    `monitoring_approach` STRING COMMENT 'Defines the monitoring methodology applied by the CRA for this assignment. on_site = traditional in-person SDV; remote = off-site data review; hybrid = combination; centralized = statistical/data-driven central monitoring per risk-based monitoring. Valid values are `on_site|remote|hybrid|centralized`',
    `next_monitoring_visit_date` DATE COMMENT 'The date of the next planned monitoring visit (on-site or remote) for this CRA-site assignment as scheduled in the CTMS. Drives visit scheduling workflows and resource planning.',
    `open_action_items_count` BIGINT COMMENT 'The current number of unresolved monitoring action items or follow-up items outstanding for this CRA-site assignment. Supports site oversight, escalation management, and GCP compliance tracking.',
    `planned_end_date` DATE COMMENT 'The originally planned end date for the CRA assignment at the time of creation. Enables comparison against actual end date to track assignment duration variances and resource planning accuracy.',
    `protocol_training_completed` BOOLEAN COMMENT 'Indicates whether the assigned CRA has completed the required study protocol-specific training prior to initiating monitoring activities at the site. True = training completed; False = pending. Regulatory requirement per GCP.',
    `protocol_training_date` DATE COMMENT 'The date on which the CRA completed the study protocol-specific training required for this assignment. Supports audit trail and regulatory inspection readiness.',
    `risk_tier` STRING COMMENT 'The risk classification of the assigned site as assessed under the risk-based monitoring (RBM) framework. Determines monitoring intensity, visit frequency, and SDV scope for this assignment. high = intensive monitoring required.. Valid values are `high|medium|low`',
    `sdv_rate_pct` DECIMAL(5,2) COMMENT 'The agreed or actual percentage of critical data fields subject to Source Data Verification (SDV) for this CRA-site assignment, as defined in the monitoring plan. Reflects risk-based monitoring (RBM) strategy. Valid range: 0.00 to 100.00.',
    `start_date` DATE COMMENT 'The date on which the CRAs monitoring responsibility for the assigned study-site combination becomes effective. Used for coverage planning and workload scheduling.',
    `termination_reason` STRING COMMENT 'The reason for ending or cancelling the CRA assignment before or at its planned conclusion. Populated only when assignment_status is completed, cancelled, or transferred.',
    `territory_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code representing the primary country of the CRAs assigned territory (e.g., USA, GBR, DEU). Supports geographic reporting and regulatory jurisdiction tracking.. Valid values are `^[A-Z]{3}$`',
    `total_visits_completed` BIGINT COMMENT 'The cumulative count of monitoring visits (on-site and remote) completed by this CRA at the assigned site under this assignment. Used for performance tracking and monitoring coverage reporting.',
    `travel_required` BOOLEAN COMMENT 'Indicates whether overnight or significant travel is required for the CRA to conduct on-site monitoring visits at this assigned site. True = travel required; False = local or remote only. Used for travel budget planning and CRA logistics.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this CRA assignment record was most recently modified. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `visit_frequency_planned` STRING COMMENT 'The planned frequency of on-site or remote monitoring visits for this CRA-site assignment as defined in the monitoring plan. Drives visit scheduling and resource forecasting in the CTMS.. Valid values are `weekly|biweekly|monthly|quarterly|as_needed|per_protocol`',
    `workload_allocation_pct` DECIMAL(5,2) COMMENT 'The percentage of the CRAs total available working capacity allocated to this specific study-site assignment. Used for workload balancing across multiple concurrent assignments. Valid range: 0.00 to 100.00.',
    CONSTRAINT pk_site_cra_assignment PRIMARY KEY(`site_cra_assignment_id`)
) COMMENT 'Records the assignment of Clinical Research Associates (CRAs) to study-site combinations for monitoring coverage. Captures CRA identity reference (FK to workforce domain), assignment start/end dates, assignment type (primary, backup, co-monitor)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`closeout` (
    `closeout_id` BIGINT COMMENT 'Unique surrogate identifier for the site close-out record. Primary key for the site_closeout data product in the Databricks Silver Layer.',
    `activation_id` BIGINT COMMENT 'Foreign key linking to site.activation. Business justification: Closeout is the lifecycle bookend to activation for a study-site. Linking closeout directly to the activation record enables lifecycle duration analytics (activation_date to closeout',
    `agreement_investigator_grant_id` BIGINT COMMENT 'Foreign key linking to agreement.investigator_grant. Business justification: Site closeout tracks final_payment_status and final_payment_amount. Final payment reconciliation requires reference to the investigator grant to verify all per-patient fees',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU site closeout requires formal notification to the health authority and closure of the CTA for that member state.',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.capa. Business justification: Site closeout activities include verification that all open CAPAs are resolved or transferred. Early terminations are often CAPA-driven.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Site closeout requires data lock confirmation before final payment and archival. The dbl_contribution_date on site_closeout is a denormalized reference to the DBL event.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) responsible for conducting the close-out visit and completing the close-out checklist at this site.',
    `final_site_payment_id` BIGINT COMMENT 'Foreign key linking to finance.site_payment. Business justification: Closeout financial reconciliation: site_closeout tracks final_payment_status and final_payment_amount.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site undergoing formal close-out. Identifies the specific study site within the CTMS.',
    `ip_accountability_log_id` BIGINT COMMENT 'Foreign key linking to monitoring.ip_accountability_log. Business justification: Site closeout requires confirmed drug accountability as a regulatory prerequisite (ICH E6, 21 CFR Part 312).',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: Closeout requires IRB/IEC notification (irb_iec_notification_status, irb_iec_notification_date fields exist).',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Site closeout activities — final payment processing, drug accountability sign-off, regulatory authority notifications, and essential document archival — are executed under direct sponsor',
    `reconciliation_id` BIGINT COMMENT 'Foreign key linking to datamanagement.reconciliation. Business justification: Site closeout requires data reconciliation completion as a prerequisite for final sign-off, final payment release, and TMF completeness.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: The closeout visit IS a monitoring_visit (type=closeout). Linking enables CRA management to confirm the closeout visit report is filed, all findings resolved, and final payment',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this site close-out is being conducted. Links the close-out record to the parent study entity.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: site_closeout records the formal close-out process for a study-site upon completion or early termination. study_site is the parent association entity for the study-site lifecycle.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The closeout visit report is a mandatory TMF artifact (DIA Reference Model Zone 5). Linking site_closeout to its TMF document supports essential_doc_archival_status tracking, TMF',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: Site closeout completion requires the closeout visit report to be approved and filed in the eTMF.',
    `capa_reference_number` STRING COMMENT 'Reference number of the CAPA record in MasterControl, if a CAPA was initiated as a result of close-out findings. Null if no CAPA is required.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) plan is required at this site based on findings identified during the close-out visit or cumulative monitoring. Triggers CAPA workflow in MasterControl.',
    `completed_date` DATE COMMENT 'Date on which all close-out activities were formally completed and the site was officially closed. Marks the end of the site lifecycle for this study.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this site close-out record was first created in the CTMS close-out workflow. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `drug_accountability_completed_date` DATE COMMENT 'Date on which investigational medicinal product (IMP) accountability reconciliation was formally completed and signed off at the site.',
    `drug_accountability_status` STRING COMMENT 'Current status of investigational medicinal product (IMP) accountability reconciliation at the site. Confirms that all dispensed, returned, and destroyed drug quantities are fully accounted for per GCP requirements.. Valid values are `pending|in_progress|completed|discrepancy_identified|waived`',
    `early_termination_reason` STRING COMMENT 'Free-text description of the reason for early termination of the site, if applicable. Populated only when closeout_type is early_termination. Supports regulatory reporting and sponsor decision documentation.',
    `essential_doc_archival_date` DATE COMMENT 'Date on which all essential documents were confirmed as archived at the investigational site, satisfying ICH E6(R2) Section 8 requirements.',
    `essential_doc_archival_status` STRING COMMENT 'Status of archival of all essential documents required by ICH E6(R2) Section 8 at the investigational site. Confirms that the sites Trial Master File (TMF) is complete and archived per regulatory requirements.. Valid values are `pending|in_progress|completed|deficiency_noted`',
    `final_payment_amount` DECIMAL(18,2) COMMENT 'Monetary value of the final payment disbursed to the investigational site at close-out, denominated in the contract currency. Represents the net amount after reconciliation of all advances and prior payments.',
    `final_payment_date` DATE COMMENT 'Date on which the final payment to the investigational site was processed and confirmed, closing all financial obligations under the site budget agreement.',
    `final_payment_status` STRING COMMENT 'Status of the final financial payment to the investigational site upon close-out, covering all outstanding per-subject fees, procedure fees, and close-out visit fees per the site budget agreement.. Valid values are `not_due|pending|invoiced|paid|disputed`',
    `gcp_compliance_status` STRING COMMENT 'Overall GCP compliance assessment for the site at close-out, based on findings from the close-out visit and cumulative monitoring history. Informs the sites eligibility for future studies.. Valid values are `compliant|minor_findings|major_findings|critical_findings`',
    `imp_return_date` DATE COMMENT 'Date on which unused investigational medicinal product (IMP) was returned to the sponsor/depot or destroyed on-site per the drug destruction protocol.',
    `imp_return_status` STRING COMMENT 'Status of the return or on-site destruction of unused investigational medicinal product (IMP) at the site. Distinct from drug accountability reconciliation — this tracks the physical disposition of remaining IMP stock.. Valid values are `not_required|pending|in_progress|completed|destroyed_on_site`',
    `initiated_date` DATE COMMENT 'Date on which the formal site close-out process was officially initiated in the CTMS, typically following LSLV confirmation and sponsor authorization.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was formally notified of study completion or early termination at this site.',
    `irb_iec_notification_status` STRING COMMENT 'Status of the formal notification to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) regarding study completion or early termination at this site, as required by GCP and applicable regulations.. Valid values are `not_required|pending|submitted|acknowledged`',
    `lslv_date` DATE COMMENT 'Date of the last protocol-required visit for the last subject enrolled at this site. LSLV is a critical clinical milestone that triggers the initiation of the close-out process and database lock activities.',
    `notes` STRING COMMENT 'Free-text field for CRA or study manager notes regarding the close-out process, including any outstanding issues, special circumstances, or follow-up actions required after the close-out visit.',
    `number` STRING COMMENT 'Externally-known business identifier for this close-out event, typically generated by the CTMS close-out workflow (e.g., CO-2024-0042). Used for cross-system referencing and regulatory correspondence.',
    `outstanding_queries_count` BIGINT COMMENT 'Number of unresolved data queries (discrepancies) remaining in the EDC system at the time of close-out visit. A non-zero value indicates data cleaning is incomplete and may delay database lock contribution.',
    `payment_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the final site payment (e.g., USD, EUR, GBP). Ensures consistent financial reporting across multi-currency global trials.. Valid values are `^[A-Z]{3}$`',
    `pi_acknowledgement_date` DATE COMMENT 'Date on which the Principal Investigator (PI) formally acknowledged the close-out letter and confirmed all site obligations were fulfilled.',
    `pi_acknowledgement_received` BOOLEAN COMMENT 'Indicates whether the Principal Investigator (PI) has formally acknowledged receipt of the close-out letter and confirmed completion of all close-out obligations, as required by ICH E6(R2).',
    `protocol_deviations_count` BIGINT COMMENT 'Total number of protocol deviations recorded at this site during the study. Summarized at close-out for site performance assessment and inclusion in the Clinical Study Report (CSR).',
    `regulatory_authority_notification_date` DATE COMMENT 'Date on which the applicable regulatory authority was formally notified of the site close-out.',
    `regulatory_authority_notification_status` STRING COMMENT 'Status of notification to applicable regulatory authorities (e.g., FDA, EMA, MHRA) regarding site close-out, as required under applicable IND/CTA regulations.. Valid values are `not_required|pending|submitted|acknowledged`',
    `sdv_completion_percentage` DECIMAL(5,2) COMMENT 'Percentage of critical and non-critical data fields that have been source data verified (SDV) at the site as of the close-out visit. Reflects data quality and monitoring completeness per the monitoring plan.',
    `site_file_transfer_date` DATE COMMENT 'Date on which the sites investigator file and essential documents were successfully transferred to the sponsor or CRO central archive.',
    `site_file_transfer_status` STRING COMMENT 'Status of the transfer of the sites investigator file and essential documents to the sponsor or CRO archive. Applicable when physical or electronic records must be transferred from the site to a central repository.. Valid values are `not_required|pending|in_progress|completed|failed`',
    `closeout_status` STRING COMMENT 'Current lifecycle state of the site close-out process as tracked in the CTMS close-out workflow. Drives downstream regulatory notification and payment release actions.. Valid values are `planned|in_progress|completed|cancelled`',
    `subjects_completed_count` BIGINT COMMENT 'Number of subjects who completed all protocol-required visits and procedures at this site. Used to calculate site completion rate and assess protocol adherence.',
    `subjects_discontinued_count` BIGINT COMMENT 'Number of subjects who discontinued from the study prior to completing all protocol-required activities at this site. Includes withdrawals, screen failures post-enrollment, and protocol deviations leading to discontinuation.',
    `subjects_enrolled_count` BIGINT COMMENT 'Total number of subjects who were enrolled (consented and randomized or assigned to treatment) at this site during the study. Used for final enrollment reconciliation at close-out.',
    `closeout_type` STRING COMMENT 'Classification of the reason driving the site close-out. Distinguishes between normal study completion, early termination for safety or operational reasons, and sponsor-initiated decisions.. Valid values are `planned_completion|early_termination|protocol_amendment|sponsor_decision`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this site close-out record in the CTMS. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `visit_date` DATE COMMENT 'Date on which the Clinical Research Associate (CRA) conducted the formal close-out monitoring visit at the investigational site. This is the principal real-world event date for the close-out transaction.',
    CONSTRAINT pk_closeout PRIMARY KEY(`closeout_id`)
) COMMENT 'Records the formal site close-out process for a study-site upon completion or early termination. Captures close-out visit date, last subject last visit (LSLV) date, database lock contribution date, drug accountability reconciliation status, essential';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` (
    `ib_site_distribution_id` BIGINT COMMENT 'Primary key for the ib_site_distribution association',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site that received this IB version distribution',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to the specific Investigator Brochure safety version that was distributed',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: Investigator Brochure distribution to a site requires PI acknowledgment of receipt (receipt_confirmed_by field exists).',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — IB distribution to a site must be traceable to a specific study',
    `distribution_date` DATE COMMENT 'Date on which this IB version was distributed to the investigational site. Required for GCP compliance and TMF completeness verification.',
    `distribution_method` STRING COMMENT 'Method by which the IB version was transmitted to the investigational site (e.g., Veeva Vault notification, email, courier). Captured per distribution event as method may vary by site capability.',
    `ib_version_at_distribution` STRING COMMENT 'The version number of the IB as distributed to this site (e.g., 2.0, 3.1). Denormalized here to provide an audit-safe snapshot of the version label at the time of distribution, independent of any subsequent version record updates.',
    `investigator_notification_date` DATE COMMENT 'Date on which Principal Investigators (PIs) at active study sites were notified of this new IB version. ICH E6(R2) requires sponsors to notify investigators of IB updates promptly. Tracked for GCP compliance.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the sites local IRB/IEC was notified of this IB version update. Tracked per site because each site has its own IRB/IEC with independent notification obligations and timelines.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether the sites IRB/IEC must be notified of this IB update per local regulatory requirements. Determined per site per IB version, as requirements vary by jurisdiction and amendment type.',
    `receipt_confirmed_by` STRING COMMENT 'Name or identifier of the site personnel (typically the Principal Investigator or site coordinator) who confirmed receipt of this IB version.',
    `receipt_confirmed_date` DATE COMMENT 'Date on which the investigational site confirmed receipt of this IB version. Required for GCP essential document tracking and site readiness verification.',
    CONSTRAINT pk_ib_site_distribution PRIMARY KEY(`ib_site_distribution_id`)
) COMMENT 'This association product represents the IB Distribution Log event between investigational_site and investigator_brochure_safety. It captures the GCP-mandated record of each Investigator Brochure version distributed to each investigational site, including';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` (
    `sponsor_site_qualification_id` BIGINT COMMENT 'Primary key for the sponsor_site_qualification association',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site being qualified within the sponsors network',
    `organization_id` BIGINT COMMENT 'Foreign key linking to the sponsor organization that owns and manages this site qualification record',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — sponsor site qualification should reference the study context',
    `disqualification_reason` STRING COMMENT 'Free-text or coded reason for disqualification if site_qualification_status is DISQUALIFIED or SUSPENDED. Null for active/qualified sites. Belongs to the relationship — a site may be disqualified by one sponsor for sponsor-specific reasons.',
    `historical_study_count` BIGINT COMMENT 'Total number of clinical studies this site has conducted for this sponsor over the lifetime of the relationship. Belongs to the relationship — the same sites study count differs per sponsor.',
    `last_qualification_review_date` DATE COMMENT 'Date of the most recent periodic re-qualification review conducted by the sponsor for this site. Sponsors periodically re-assess site qualification status; this date drives re-qualification scheduling.',
    `preferred_site_tier` STRING COMMENT 'Sponsor-assigned tier classification for this site within their preferred site network. Distinct from the sites global site_tier — a site may be Tier 1 for one sponsor and Tier 3 for another based on therapeutic area fit and historical performance.',
    `preferred_therapeutic_area` STRING COMMENT 'The therapeutic area(s) for which this sponsor preferentially engages this site, based on the sites specialization and the sponsors pipeline focus. May be a subset of the sites full therapeutic_area_specializations.',
    `qualification_date` DATE COMMENT 'Date on which the site was formally qualified by this sponsor following completion of site qualification visit and document review. Distinct from relationship_start_date (initial contact) — this marks formal approval.',
    `relationship_start_date` DATE COMMENT 'Date on which the sponsor formally established a working relationship with this investigational site. Used to calculate relationship tenure and for sponsor portfolio reporting.',
    `site_performance_rating` STRING COMMENT 'Sponsors aggregate performance rating for this site based on enrollment delivery, data quality, protocol compliance, and regulatory inspection outcomes across all studies conducted under this sponsor.',
    `site_qualification_status` STRING COMMENT 'Current qualification status of the investigational site within this sponsors network. Drives whether the site is eligible to be selected for new studies under this sponsor.',
    CONSTRAINT pk_sponsor_site_qualification PRIMARY KEY(`sponsor_site_qualification_id`)
) COMMENT 'This association product represents the formal qualification and relationship contract between an investigational_site and a sponsor organization. It captures the operational record of a sponsors qualification, rating, and preferred-network designation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`pi_qualification` (
    `pi_qualification_id` BIGINT COMMENT 'Primary key for the pi_qualification association',
    `organization_id` BIGINT COMMENT 'Foreign key linking to the Sponsor Organization that is granting or managing the PI qualification.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to the Principal Investigator being qualified by the sponsor organization.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — PI qualification should reference the study for which the PI is qualified',
    `approved_therapeutic_areas` STRING COMMENT 'Comma-delimited list or structured value of therapeutic areas (e.g., Oncology, Cardiology) for which this sponsor has approved this PI to serve as investigator.',
    `debarment_check_date` DATE COMMENT 'Date on which this sponsor most recently performed an FDA debarment check for this PI. Sponsors conduct their own independent debarment verifications; this date is specific to the sponsor-PI relationship and differs from the PI master records global',
    `historical_study_count` BIGINT COMMENT 'Total number of clinical studies this PI has conducted specifically for this sponsor organization. Distinct from the PI master records global prior_study_count, which spans all sponsors. Used by sponsors for investigator selection and risk assessment.',
    `pi_performance_rating` STRING COMMENT 'Sponsors internal performance rating for this PI based on past study conduct, protocol compliance, data quality, and site management. This rating is sponsor-specific and confidential; a PI may have different ratings from different sponsors.',
    `qualification_date` DATE COMMENT 'Date on which the sponsor formally approved and qualified this PI for study participation. Specific to the sponsor-PI pairing; a PI may have different qualification dates with different sponsors.',
    `qualification_status` STRING COMMENT 'Current status of the sponsors qualification approval for this PI. Drives eligibility to be assigned to studies under this sponsors portfolio. Cannot reside on the PI master record because a PI may be ACTIVE with one sponsor and SUSPENDED with another',
    CONSTRAINT pk_pi_qualification PRIMARY KEY(`pi_qualification_id`)
) COMMENT 'This association product represents the Qualification relationship between a Principal Investigator and a Sponsor Organization. It captures the formal regulatory approval process by which a sponsor certifies a PI as eligible to conduct studies under their';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`staff_roster` (
    `staff_roster_id` BIGINT COMMENT 'Primary key for the site_staff_roster association',
    `employee_id` BIGINT COMMENT 'Foreign key linking this staff assignment record to the employee assigned to the site.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking this staff assignment record to the investigational site where the employee is assigned.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — staff roster at a site should reference the study for which staff are rostered',
    `assignment_end_date` DATE COMMENT 'The date on which the employees assignment to this investigational site ended or is scheduled to end. A null value indicates an active, open-ended assignment. Used for historical roster queries and transition planning.',
    `assignment_start_date` DATE COMMENT 'The date on which the employees assignment to this investigational site became effective. Used for regulatory compliance tracking, delegation of authority validity, and workforce scheduling.',
    `delegation_log_ref` STRING COMMENT 'Reference identifier linking this staff-site assignment to the corresponding entry in the sites Delegation of Authority (DoA) log — a regulatory document required by ICH GCP that records which tasks each staff member is authorized to perform at the site.',
    `gcp_training_current` BOOLEAN COMMENT 'Indicates whether the employees GCP training is confirmed current and valid for this specific site assignment at the time of the last compliance check. This is a site-assignment-level compliance flag, distinct from the employees general gcp_certified',
    `role_at_site` STRING COMMENT 'The GCP-defined functional role the employee performs at this specific investigational site. Distinct from the employees general gcp_role, as a staff member may serve different roles across different site assignments (e.g., CRA at one site, Site Manager',
    CONSTRAINT pk_staff_roster PRIMARY KEY(`staff_roster_id`)
) COMMENT 'This association product represents the Role-based assignment between investigational_site and employee. It captures the operational record of each staff member assigned to an investigational site, including their functional role, assignment period, GCP';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`specialization` (
    `specialization_id` BIGINT COMMENT 'Primary key for the site_specialization association',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site that holds this therapeutic area specialization.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — site specialization should be traceable to a study context when relevant',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to the therapeutic area in which the site is specialized.',
    `active_study_count_in_ta` BIGINT COMMENT 'Current number of active clinical studies the site is running within this therapeutic area at the time of last assessment. Used by feasibility teams to evaluate site capacity and workload for new study placement in this TA.',
    `certification_status` STRING COMMENT 'Current certification or qualification status of the site for conducting clinical trials within this specific therapeutic area. Distinct from the site-level GCP certification; this is TA-specific and belongs to the relationship record.',
    `last_assessed_date` DATE COMMENT 'Date on which the sites specialization profile for this therapeutic area was most recently reviewed and updated by clinical operations. Drives reassessment workflows and data freshness governance.',
    `specialization_level` STRING COMMENT 'Categorical rating of the investigational sites depth of expertise and capability within this specific therapeutic area, as assessed by clinical operations. Belongs to the site-TA pairing, not to the site or TA alone.',
    `therapeutic_area_specializations` STRING COMMENT 'Comma-separated list of therapeutic area specializations for which the investigational site has demonstrated clinical expertise and patient population access (e.g., Oncology, Cardiology, Neurology, Infectious Disease).',
    `years_of_experience` BIGINT COMMENT 'Number of years the investigational site has been conducting clinical trials within this therapeutic area. Belongs to the site-TA pairing as it reflects accumulated experience in the specific combination, not a property of the site or TA in isolation.',
    CONSTRAINT pk_specialization PRIMARY KEY(`specialization_id`)
) COMMENT 'This association product represents the Specialization Role between investigational_site and therapeutic_area. It captures the operational qualification profile of an investigational site within a specific therapeutic area, as assessed and maintained by';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`program_site_participation` (
    `program_site_participation_id` BIGINT COMMENT 'Primary key for the program_site_participation association',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to the clinical development program in which the site participates.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to the investigational site participating in the clinical program.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — program_site_participation links a site to a program but should also reference the study for operational context',
    `active_study_count` BIGINT COMMENT 'Number of studies within this clinical program that the investigational site is currently actively running. A derived-but-stored operational metric used by site managers and program leads for capacity planning and portfolio oversight.',
    `first_study_start_date` DATE COMMENT 'Date on which the investigational site first activated and began enrolling subjects under any study within this clinical program. Belongs to the site-program relationship, not to either master entity alone, as the same site may have different first',
    `historical_enrollment_count` BIGINT COMMENT 'Cumulative number of subjects enrolled by this investigational site across all studies within this clinical program to date. A program-level performance metric that belongs to the site-program relationship, not to the site master (which would aggregate',
    `participation_status` STRING COMMENT 'Current lifecycle status of the investigational sites participation within this clinical program. Reflects whether the site is actively running studies under the program, pending activation, or has completed or terminated its engagement.',
    `preferred_site_flag` BOOLEAN COMMENT 'Sponsor or CRO designation indicating whether this investigational site is classified as a preferred or strategic site for future studies within this clinical program.',
    CONSTRAINT pk_program_site_participation PRIMARY KEY(`program_site_participation_id`)
) COMMENT 'This association product represents the Program Site Participation between investigational_site and clinical_program. It captures the operational engagement of an investigational site within a clinical development program — a recognized portfolio strategy';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`signal_review` (
    `signal_review_id` BIGINT COMMENT 'Primary key for the site_signal_review association',
    `signal_id` BIGINT COMMENT 'Foreign key linking to the safety signal that is the subject of this site-level review.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — signal_review at a site must reference the study context',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to the investigational study site being evaluated in the context of this safety signal review.',
    `action_required` STRING COMMENT 'Site-specific regulatory or operational action mandated as a result of this signal review at this site. May differ from the study-level regulatory_action_recommended on safety_signal. Belongs to the site-signal intersection.',
    `action_taken_date` DATE COMMENT 'Date on which the site-specific action required was implemented or confirmed at this investigational site. Belongs to the site-signal intersection, not to either entity alone.',
    `review_date` DATE COMMENT 'Date on which the site-level review of this safety signal was conducted by the medical monitor or safety team. Belongs to the review event, not to the site or signal independently.',
    `site_risk_assessment` STRING COMMENT 'Narrative risk assessment specific to this sites patient population, investigator practices, and local case profile for this signal. Distinct from the study-level benefit_risk_summary on safety_signal. Belongs to the site-signal intersection.',
    `site_specific_case_count` BIGINT COMMENT 'Number of adverse event cases at this specific investigational site that contribute to the safety signal. Distinct from the aggregate case_count on safety_signal, which spans all sites and data sources. Belongs to the site-signal intersection.',
    CONSTRAINT pk_signal_review PRIMARY KEY(`signal_review_id`)
) COMMENT 'This association product represents the Site Signal Review event between study_site and safety_signal. It captures the operational process by which a medical monitor or safety team evaluates a specific safety signal in the context of a specific';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`depot_assignment` (
    `depot_assignment_id` BIGINT COMMENT 'Primary key for the site_depot_assignment association',
    `depot_id` BIGINT COMMENT 'Foreign key linking this supply assignment to the depot that is designated as the supply source for the investigational site.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking this supply assignment to the investigational site that receives IMP from the assigned depot.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — depot_assignment links a site to a depot but lacks study context, making it ambiguous across multi-study sites',
    `effective_from_date` DATE COMMENT 'The date from which this depot-to-site supply assignment becomes active and the depot is authorised to ship IMP to the site. Marks the start of the valid supply routing window.',
    `primary_depot_flag` BOOLEAN COMMENT 'Indicates whether this depot is the primary (true) or a backup/secondary (false) supply source for the investigational site under this assignment. A site may have one primary depot and one or more backup depots active simultaneously.',
    `supply_route_type` STRING COMMENT 'Classifies the logistics routing model used for IMP delivery from the depot to the investigational site under this assignment (e.g., DIRECT_TO_SITE, HUB_AND_SPOKE, CROSS_DOCK, COURIER_DIRECT). Drives shipment planning and carrier selection.',
    CONSTRAINT pk_depot_assignment PRIMARY KEY(`depot_assignment_id`)
) COMMENT 'This association product represents the supply assignment (role) between an investigational_site and a depot. It captures the formal clinical supply routing decision that designates which depot(s) serve each investigational site, including whether the';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`authorization` (
    `authorization_id` BIGINT COMMENT 'Primary key for the site_authorization association',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking this site authorization record to the Clinical Trial Authorization under which the site is authorized to conduct the trial.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking this site authorization record to the specific investigational site covered by the authorization.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — site authorization must reference the study it authorizes the site for',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: Clinical trial authorization at a site is study-specific - the CTA authorizes conduct of a specific study at a specific site.',
    `enrollment_authorized_count` BIGINT COMMENT 'The maximum number of subjects the competent authority has authorized this specific site to enroll under this CTA. This per-site cap is set at authorization time and may differ from the sites operational max_enrollment_capacity.',
    `notification_date` DATE COMMENT 'The date on which the investigational site was formally notified of its inclusion, status change, or authorization decision under this CTA. Used by regulatory operations to track compliance with notification timelines required by national regulations.',
    `site_specific_conditions` STRING COMMENT 'Narrative description of any conditions, restrictions, or obligations attached by the national competent authority that apply exclusively to this investigational site under this CTA.',
    `status_at_site` STRING COMMENT 'The current authorization status of the CTA as it applies specifically to this investigational site. A site may be suspended under a CTA while other sites under the same CTA remain active, so this status is independent of the overall CTA',
    CONSTRAINT pk_authorization PRIMARY KEY(`authorization_id`)
) COMMENT 'This association product represents the Contract between investigational_site and clinical_trial_authorization. It captures the site-level regulatory authorization record that links a specific investigational site to a Clinical Trial Authorization issued';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` (
    `site_selection_committee_id` BIGINT COMMENT 'Primary key for site_selection_committee',
    `compliance_sop_id` BIGINT COMMENT 'Identifier of the governing SOP document that defines the committees operational processes, decision workflows, and documentation requirements.',
    `organization_id` BIGINT COMMENT 'Identifier of the pharmaceutical or biotech sponsor organization that the committee serves or is aligned with.',
    `parent_site_selection_committee_id` BIGINT COMMENT 'Self-referencing FK on site_selection_committee (parent_site_selection_committee_id)',
    `chairperson_email` STRING COMMENT 'Primary email address of the committee chairperson for official communications regarding site selection activities.',
    `chairperson_name` STRING COMMENT 'Full name of the individual serving as chairperson of the site selection committee, responsible for leading deliberations and final recommendations.',
    `charter_effective_date` DATE COMMENT 'Date when the current committee charter became effective, establishing the committees authority and operating procedures.',
    `charter_expiry_date` DATE COMMENT 'Date when the current committee charter expires and requires renewal or re-authorization. Nullable for open-ended charters.',
    `charter_version` STRING COMMENT 'Version number of the committee charter document that defines the committees scope, authority, and operating procedures.',
    `committee_code` STRING COMMENT 'Externally-known unique business identifier code for the site selection committee, used across CTMS and regulatory correspondence.',
    `committee_type` STRING COMMENT 'Classification of the committee by its organizational scope and permanence. Standing committees are permanent; ad hoc are formed for specific studies.',
    `conflict_of_interest_policy` STRING COMMENT 'Reference to the conflict of interest policy that committee members must adhere to when evaluating sites, ensuring unbiased selection decisions.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the primary country jurisdiction under which the committee operates, if regionally scoped.',
    `created_date` TIMESTAMP COMMENT 'Timestamp when this committee record was first created in the system.',
    `dissolution_date` DATE COMMENT 'Date when the committee was formally dissolved or deactivated. Null for currently active committees.',
    `diversity_requirement_flag` BOOLEAN COMMENT 'Indicates whether the committee enforces patient population diversity requirements in site selection to ensure representative enrollment.',
    `escalation_authority` STRING COMMENT 'Name or role of the governance body or individual to whom the committee escalates contested or high-risk site selection decisions.',
    `feasibility_scoring_model` STRING COMMENT 'Name or identifier of the quantitative scoring model applied during site feasibility assessments (e.g., weighted scorecard, risk-based model).',
    `formation_date` DATE COMMENT 'Date when the site selection committee was formally established and authorized to begin operations.',
    `gcp_compliance_required` BOOLEAN COMMENT 'Indicates whether the committee mandates verified GCP compliance as a prerequisite for site selection consideration.',
    `irb_approval_required` BOOLEAN COMMENT 'Indicates whether the committee requires evidence of IRB/IEC approval or conditional approval before a site can be selected.',
    `language` STRING COMMENT 'ISO 639-1 two-letter code for the primary language used in committee deliberations and documentation.',
    `last_meeting_date` DATE COMMENT 'Date of the most recent committee meeting, used for tracking activity and ensuring the committee remains operationally current.',
    `last_modified_date` TIMESTAMP COMMENT 'Timestamp when this committee record was last updated in the system.',
    `max_sites_per_review` BIGINT COMMENT 'Maximum number of candidate sites the committee can evaluate in a single review cycle, reflecting operational capacity constraints.',
    `meeting_frequency` STRING COMMENT 'Standard cadence at which the committee convenes to review site feasibility assessments and make selection decisions.',
    `member_count` BIGINT COMMENT 'Total number of current voting and non-voting members serving on the site selection committee.',
    `minimum_enrollment_target` BIGINT COMMENT 'Minimum patient enrollment capacity threshold that a site must demonstrate during feasibility to be considered by the committee.',
    `site_selection_committee_name` STRING COMMENT 'Human-readable name of the site selection committee, typically reflecting the therapeutic area or program it serves.',
    `next_scheduled_meeting_date` DATE COMMENT 'Date of the next planned committee meeting for site selection review activities.',
    `notes` STRING COMMENT 'Free-text notes or remarks about the committee, including special mandates, historical context, or operational considerations.',
    `pi_qualification_criteria` STRING COMMENT 'Summary description of the minimum qualifications, experience, and credentials required of a Principal Investigator for site approval by this committee.',
    `quorum_threshold` BIGINT COMMENT 'Minimum number of voting members required to be present for the committee to make binding site selection decisions.',
    `region` STRING COMMENT 'Geographic region of responsibility for the committees site selection activities.',
    `risk_assessment_framework` STRING COMMENT 'Name or identifier of the risk-based quality management framework used by the committee to evaluate site-level risks during selection.',
    `selection_criteria_version` STRING COMMENT 'Version identifier of the standardized site selection criteria framework currently used by the committee for evaluating investigational sites.',
    `site_selection_committee_status` STRING COMMENT 'Current lifecycle status of the site selection committee indicating its operational readiness to conduct site evaluations.',
    `therapeutic_area` STRING COMMENT 'Primary therapeutic area or disease indication that the committee focuses on for site selection decisions (e.g., oncology, cardiology, neurology).',
    `total_sites_approved` BIGINT COMMENT 'Cumulative count of investigational sites that have been approved for selection by this committee since its formation.',
    `total_sites_reviewed` BIGINT COMMENT 'Cumulative count of investigational sites that have been formally reviewed by this committee since its formation.',
    `voting_method` STRING COMMENT 'Decision-making methodology used by the committee to approve or reject site candidates during selection deliberations.',
    CONSTRAINT pk_site_selection_committee PRIMARY KEY(`site_selection_committee_id`)
) COMMENT 'Master reference table for site_selection_committee. Referenced by committee_id.';

ALTER SCHEMA `clinical_trials_ecm`.`site` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`site` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ADD CONSTRAINT `fk_site_investigational_site_local_lab_facility_id` FOREIGN KEY (`local_lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ADD CONSTRAINT `fk_site_investigational_site_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` SET TAGS ('dbx_contact_owner' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `local_lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Local Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Site Address Line 1');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line1` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line1` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Site Address Line 2');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line2` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line2` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Site City');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `city` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `closeout_date` SET TAGS ('dbx_business_glossary_term' = 'Site Close-Out Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Site Country Code');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `country_code` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_ref' = 'ISO3166;standard_element:country_code;owns_own_contact');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `duns_number` SET TAGS ('dbx_business_glossary_term' = 'Data Universal Numbering System (DUNS) Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `duns_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `edc_system` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `edc_system` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|veeva_vault_edcr|other|none');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `eudract_site_number` SET TAGS ('dbx_standard_ref' = 'CDISC_SDTM;standard_element:TS.SITE_EUDRACT;registry_identifier');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `facility_type` SET TAGS ('dbx_value_regex' = 'academic_medical_center|community_hospital|private_clinic|research_institute|outpatient_center|other');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_business_glossary_term' = 'Site Fax Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fax_number` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fda_fei_number` SET TAGS ('dbx_business_glossary_term' = 'FDA Facility Establishment Identifier (FEI) Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fda_fei_number` SET TAGS ('dbx_value_regex' = '^[0-9]{7,10}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `fda_fei_number` SET TAGS ('dbx_standard_ref' = 'FDA;standard_element:FEI;registry_identifier');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `gcp_certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `gcp_certification_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `gcp_certification_status` SET TAGS ('dbx_value_regex' = 'certified|expired|pending_renewal|not_certified');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|minor_findings|major_findings|critical_findings|under_review');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `has_dedicated_research_staff` SET TAGS ('dbx_business_glossary_term' = 'Has Dedicated Research Staff Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `has_local_laboratory` SET TAGS ('dbx_business_glossary_term' = 'Has Local Laboratory Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `has_pharmacy` SET TAGS ('dbx_business_glossary_term' = 'Has On-Site Pharmacy Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `iras_number` SET TAGS ('dbx_business_glossary_term' = 'Integrated Research Application System (IRAS) Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `iras_number` SET TAGS ('dbx_standard_ref' = 'HRA;standard_element:IRAS;registry_identifier');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `irb_iec_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Registration Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `irb_iec_registration_number` SET TAGS ('dbx_standard_ref' = 'FDA_21CFR56;standard_element:IRB_REGISTRATION');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Quality Audit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `last_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `max_enrollment_capacity` SET TAGS ('dbx_business_glossary_term' = 'Maximum Enrollment Capacity');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `max_enrollment_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `number_of_exam_rooms` SET TAGS ('dbx_business_glossary_term' = 'Number of Examination Rooms');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `open_capa_count` SET TAGS ('dbx_business_glossary_term' = 'Open Corrective and Preventive Action (CAPA) Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `operational_status` SET TAGS ('dbx_business_glossary_term' = 'Site Operational Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `operational_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending_activation|closed|suspended|in_feasibility');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Site Phone Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Site Postal Code');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `postal_code` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `postal_code` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_business_glossary_term' = 'Site Email Address');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_name` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_tier` SET TAGS ('dbx_business_glossary_term' = 'Site Tier Classification');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `site_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Site Identifier');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'Site State or Province');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `state_province` SET TAGS ('dbx_owns_own_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Site Time Zone');

ALTER TABLE `clinical_trials_ecm`.`site`.`investigational_site` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ADD CONSTRAINT `fk_site_site_contact_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ADD CONSTRAINT `fk_site_site_contact_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_ownership' = 'self_owned');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_cross_domain_duplicate_resolved' = 'distinct_contact');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` SET TAGS ('dbx_owner_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `site_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_business_glossary_term' = 'Site Contact Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|on_leave');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_ref' = 'ISO3166;standard_element:country_code');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `ctms_contact_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Contact ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `ctms_contact_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) User ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `cv_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Vitae (CV) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `delegation_log_ref` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Reference');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `department` SET TAGS ('dbx_business_glossary_term' = 'Site Department');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `edc_system_access` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Access Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System User ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Site Contact End Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_business_glossary_term' = 'Contact Fax Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `fax_number` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `financial_disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Disclosure Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `financial_disclosure_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `financial_disclosure_status` SET TAGS ('dbx_value_regex' = 'submitted|pending|not_required|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `financial_disclosure_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Contact First Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:HumanName.given');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `gcp_training_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `gcp_training_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `gcp_training_provider` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Provider');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `gcp_training_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `gcp_training_status` SET TAGS ('dbx_value_regex' = 'current|expired|not_trained|in_progress');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `human_subjects_training_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Human Subjects Research Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `human_subjects_training_status` SET TAGS ('dbx_business_glossary_term' = 'Human Subjects Research Training Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `human_subjects_training_status` SET TAGS ('dbx_value_regex' = 'current|expired|not_trained|in_progress');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `irb_iec_approval_ref` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Reference');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `is_pi` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Indicator');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Preferred Communication Language');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Last Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:HumanName.family');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Medical License Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Medical License Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_credential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `license_state` SET TAGS ('dbx_business_glossary_term' = 'Medical License State / Jurisdiction');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Mobile Phone Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Site Contact Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `professional_title` SET TAGS ('dbx_business_glossary_term' = 'Professional Title / Credential');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `role_type` SET TAGS ('dbx_business_glossary_term' = 'Site Contact Role Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `specialty` SET TAGS ('dbx_business_glossary_term' = 'Medical Specialty');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Site Contact Start Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Site Contact Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'resigned|transferred|study_completed|for_cause|leave_of_absence|other');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_contact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `ctms_investigator_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Investigator ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `cv_version_date` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Vitae (CV) Version Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `debarment_check_status` SET TAGS ('dbx_value_regex' = 'not_checked|cleared|debarred|pending');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `delegation_log_current` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Current Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `disqualification_date` SET TAGS ('dbx_business_glossary_term' = 'PI Disqualification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `disqualification_reason` SET TAGS ('dbx_business_glossary_term' = 'PI Disqualification Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Email Address');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `eudract_investigator_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT Investigator ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `eudract_investigator_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `eudract_investigator_number` SET TAGS ('dbx_PII;standard_ref' = 'EudraCT;standard_element:investigator_number');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `eudract_investigator_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `eudract_investigator_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `fda_investigator_number` SET TAGS ('dbx_business_glossary_term' = 'FDA Investigator ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `fda_investigator_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `fda_investigator_number` SET TAGS ('dbx_PII;standard_ref' = 'FDA;standard_element:investigator_number');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `fda_investigator_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `fda_investigator_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `financial_disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Disclosure Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `financial_disclosure_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `financial_disclosure_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|accepted|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `financial_disclosure_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) First Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `first_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `first_name` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:HumanName.given');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `form_1572_date` SET TAGS ('dbx_business_glossary_term' = 'FDA Form 1572 Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `form_1572_status` SET TAGS ('dbx_business_glossary_term' = 'FDA Form 1572 Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `form_1572_status` SET TAGS ('dbx_value_regex' = 'not_submitted|submitted|accepted|expired|superseded');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `gcp_training_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `gcp_training_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `gcp_training_provider` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Provider');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `inspection_history_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection History Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `institution_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `institution_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_value_regex' = 'not_submitted|pending|approved|conditionally_approved|rejected|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Outcome');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_value_regex' = 'no_action_indicated|voluntary_action_indicated|official_action_indicated|pending');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Last Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_name` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:HumanName.family');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_qualification|disqualified|retired');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_expiry_date` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_expiry_date` SET TAGS ('dbx_pii_credential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_expiry_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_number` SET TAGS ('dbx_pii_credential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_state` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_state` SET TAGS ('dbx_pii_credential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `medical_license_state` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `npi_number` SET TAGS ('dbx_business_glossary_term' = 'National Provider Identifier (NPI) Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `npi_number` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `npi_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `npi_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `npi_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `orcid_number` SET TAGS ('dbx_business_glossary_term' = 'Open Researcher and Contributor Identifier (ORCID) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `orcid_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `orcid_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `orcid_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `orcid_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Phone Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_PII;standard_ref' = 'FHIR;standard_element:ContactPoint.value');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `pi_type` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `pi_type` SET TAGS ('dbx_value_regex' = 'principal_investigator|sub_investigator|coordinating_investigator|national_coordinating_investigator');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `professional_title` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Professional Title');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `protocol_training_complete` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Complete Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `qualification_date` SET TAGS ('dbx_business_glossary_term' = 'PI Qualification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `specialty` SET TAGS ('dbx_business_glossary_term' = 'Medical Specialty');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`principal_investigator` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Clinical Research Experience');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_assessed_by_employee_id` FOREIGN KEY (`assessed_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_confidentiality_agreement_id` FOREIGN KEY (`confidentiality_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`confidentiality_agreement`(`confidentiality_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessed By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `confidentiality_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calc Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Assessment Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Assessment Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|completed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Decision Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `edc_access_available` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Access Available');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `estimated_enrollment_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `feasibility_score_tier` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `gcp_training_current` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Current');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_value_regex' = 'active|pending|not_established|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `lab_capabilities_available` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Capabilities Available');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `questionnaire_response_notes` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Questionnaire Response Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `questionnaire_version` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Questionnaire Version');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `selection_decision` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Decision');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `selection_decision` SET TAGS ('dbx_value_regex' = 'selected|not_selected|on_hold|pending');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `site_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `site_region` SET TAGS ('dbx_business_glossary_term' = 'Site Geographic Region');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `sponsor_comments` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Review Comments');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Questionnaire Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`feasibility_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_activation_id` FOREIGN KEY (`activation_id`) REFERENCES `clinical_trials_ecm`.`site`.`activation`(`activation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_feasibility_assessment_id` FOREIGN KEY (`feasibility_assessment_id`) REFERENCES `clinical_trials_ecm`.`site`.`feasibility_assessment`(`feasibility_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_site_selection_committee_id` FOREIGN KEY (`site_selection_committee_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_selection_committee`(`site_selection_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `selection_id` SET TAGS ('dbx_business_glossary_term' = 'Site Selection ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `activation_id` SET TAGS ('dbx_business_glossary_term' = 'Site Activation ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calc Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `site_selection_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Selection Committee ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `activation_target_date` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Target Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `conditional_requirements` SET TAGS ('dbx_business_glossary_term' = 'Conditional Selection Requirements');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Site Country Code');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `ctms_site_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Site Record ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `selection_date` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `decision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Selection Decision Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `enrollment_rate_per_month` SET TAGS ('dbx_business_glossary_term' = 'Projected Enrollment Rate Per Month');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `feasibility_score` SET TAGS ('dbx_business_glossary_term' = 'Site Feasibility Score');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `first_patient_in_target_date` SET TAGS ('dbx_business_glossary_term' = 'First Patient In (FPI) Target Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `gcp_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Confirmed');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_value_regex' = 'not_submitted|submitted|approved|pending|waived|not_required');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SS-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `patient_population_size` SET TAGS ('dbx_business_glossary_term' = 'Eligible Patient Population Size');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `pi_qualification_verified` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Qualification Verified');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `prior_audit_finding` SET TAGS ('dbx_business_glossary_term' = 'Prior Audit Finding Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Rationale');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Site Rejection Reason Code');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `rejection_reason_detail` SET TAGS ('dbx_business_glossary_term' = 'Site Rejection Reason Detail');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `sponsor_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `selection_status` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `selection_type` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `selection_type` SET TAGS ('dbx_value_regex' = 'new_site|replacement_site|backup_site|expansion_site');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `visit_conducted` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Visit Conducted Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `visit_date` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`selection` ALTER COLUMN `visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_central_lab_facility_id` FOREIGN KEY (`central_lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` SET TAGS ('dbx_stub_domain_cleanup' = 'applied');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `central_lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Central Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `budget_agreed_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Site Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `budget_agreed_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `budget_currency` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `budget_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `capacity_subjects` SET TAGS ('dbx_business_glossary_term' = 'Site Subject Capacity');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `capacity_subjects` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `cda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Confidential Disclosure Agreement (CDA) Execution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `contract_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Agreement (CTA) Execution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `drug_shipment_auth_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Drug Shipment Authorization Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `edc_provisioning_date` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Provisioning Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Enrolled Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `fpfv_date` SET TAGS ('dbx_business_glossary_term' = 'First Patient First Visit (FPFV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|minor_findings|major_findings|critical_findings|suspended');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `irb_iec_approval_number` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `irb_iec_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `last_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `lplv_date` SET TAGS ('dbx_business_glossary_term' = 'Last Patient Last Visit (LPLV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `open_query_count` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Site Rejection Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Site Risk Tier');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `sae_count` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `screened_count` SET TAGS ('dbx_business_glossary_term' = 'Screened Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `selection_date` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `selection_rationale` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Rationale');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `site_closeout_date` SET TAGS ('dbx_business_glossary_term' = 'Site Close-Out Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `site_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `site_status` SET TAGS ('dbx_value_regex' = 'candidate|selected|initiated|enrolling|enrollment_complete|closed');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `siv_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`study_site` ALTER COLUMN `withdrawn_count` SET TAGS ('dbx_business_glossary_term' = 'Withdrawn Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_edc_study_build_id` FOREIGN KEY (`edc_study_build_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`edc_study_build`(`edc_study_build_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_feasibility_assessment_id` FOREIGN KEY (`feasibility_assessment_id`) REFERENCES `clinical_trials_ecm`.`site`.`feasibility_assessment`(`feasibility_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `activation_id` SET TAGS ('dbx_business_glossary_term' = 'Site Activation ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `edc_study_build_id` SET TAGS ('dbx_business_glossary_term' = 'Edc Study Build Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `feasibility_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Feasibility Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Activation Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `actual_activation_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Site Activation Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `cda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Disclosure Agreement (CDA) Execution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `cda_status` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Disclosure Agreement (CDA) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `cda_status` SET TAGS ('dbx_value_regex' = 'not_started|sent|executed|waived|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `ctms_activation_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Activation Record ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `days_elapsed` SET TAGS ('dbx_business_glossary_term' = 'Activation Days Elapsed');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `drug_shipment_auth_date` SET TAGS ('dbx_business_glossary_term' = 'Drug Shipment Authorization Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `drug_shipment_auth_status` SET TAGS ('dbx_business_glossary_term' = 'Drug Shipment Authorization Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `drug_shipment_auth_status` SET TAGS ('dbx_value_regex' = 'not_authorized|authorized|on_hold|revoked');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `edc_access_provisioned_date` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Access Provisioned Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `edc_access_status` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Access Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `edc_access_status` SET TAGS ('dbx_value_regex' = 'not_provisioned|provisioned|suspended|revoked');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `essential_docs_verified` SET TAGS ('dbx_business_glossary_term' = 'Essential Documents Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `financial_agreement_executed` SET TAGS ('dbx_business_glossary_term' = 'Financial Agreement Executed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `fpfv_date` SET TAGS ('dbx_business_glossary_term' = 'First Patient First Visit (FPFV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `gcp_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `investigator_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Investigator Agreement Execution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `investigator_agreement_status` SET TAGS ('dbx_value_regex' = 'not_started|in_negotiation|executed|terminated|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_status` SET TAGS ('dbx_value_regex' = 'not_submitted|submitted|approved|deferred|disapproved|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `irb_iec_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `on_hold_reason` SET TAGS ('dbx_business_glossary_term' = 'Activation On-Hold Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `protocol_receipt_status` SET TAGS ('dbx_value_regex' = 'not_started|sent|confirmed|waived');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `regulatory_pkg_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Package Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `regulatory_pkg_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Package Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `regulatory_pkg_status` SET TAGS ('dbx_value_regex' = 'not_started|submitted|approved|pending_query|waived');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `regulatory_pkg_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Package Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `siv_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Completed Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `siv_scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Scheduled Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `siv_status` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `siv_status` SET TAGS ('dbx_value_regex' = 'not_scheduled|scheduled|completed|rescheduled|cancelled');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `activation_status` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `target_activation_date` SET TAGS ('dbx_business_glossary_term' = 'Target Site Activation Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `activation_type` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `activation_type` SET TAGS ('dbx_value_regex' = 'new_site|re_activation|replacement_site|expansion_site');

ALTER TABLE `clinical_trials_ecm`.`site`.`activation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_conditions` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Conditions');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_letter_received_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Letter Received Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|conditionally_approved|suspended|withdrawn|expired');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'initial|amendment|continuing_review|renewal|waiver');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approved_icf_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Informed Consent Form (ICF) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approved_icf_version` SET TAGS ('dbx_business_glossary_term' = 'Approved Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `approved_icf_version` SET TAGS ('dbx_standard_ref' = 'ICH_E6R2;standard_element:4.8_ICF');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `committee_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `committee_type` SET TAGS ('dbx_value_regex' = 'IRB|IEC|REC|HREC|EC');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `conditions_resolved_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Conditions Resolved Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `ctms_approval_record_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Approval Record ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiration Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `gcp_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Confirmed');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `local_language_icf_approved` SET TAGS ('dbx_business_glossary_term' = 'Local Language Informed Consent Form (ICF) Approved');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `local_language_icf_approved` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `local_language_icf_version` SET TAGS ('dbx_business_glossary_term' = 'Local Language Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `local_language_icf_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `max_enrollment_approved` SET TAGS ('dbx_business_glossary_term' = 'Maximum Enrollment Approved by IRB/IEC');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `pediatric_enrollment_approved` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Enrollment Approved by IRB/IEC');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `regulatory_authority_notified` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notified of IRB/IEC Approval');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `regulatory_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Reinstatement Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `review_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|administrative');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Submission Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `suspension_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Suspension Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Suspension Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `vulnerable_population_approved` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Enrollment Approved');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `waiver_of_consent_approved` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Informed Consent Approved');

ALTER TABLE `clinical_trials_ecm`.`site`.`irb_iec_approval` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Approval Reference Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_ref' = 'ISO3166;standard_element:country_code');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `document_title` SET TAGS ('dbx_business_glossary_term' = 'Submission Document Title');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `financial_disclosure_type` SET TAGS ('dbx_value_regex' = 'FDA_3454_No_Disclosable_Interest|FDA_3455_Disclosable_Interest|Not_Applicable');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `financial_disclosure_type` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `financial_interest_disclosed` SET TAGS ('dbx_business_glossary_term' = 'Financial Interest Disclosed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `financial_interest_disclosed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `gcp_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `icf_version` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `icf_version` SET TAGS ('dbx_standard_ref' = 'ICH_E6R2;standard_element:4.8_ICF');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `local_language_icf` SET TAGS ('dbx_business_glossary_term' = 'Local Language Informed Consent Form (ICF) Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `local_language_icf` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Submission Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `regulatory_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Timeline (Days)');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `review_outcome` SET TAGS ('dbx_value_regex' = 'Approved|Approved_with_Conditions|Deferred|Rejected|Not_Applicable');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `submission_category` SET TAGS ('dbx_value_regex' = 'Initial|Renewal|Amendment|Closure|Safety_Report|Other');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'Electronic|Paper|Portal|Email|Other');

ALTER TABLE `clinical_trials_ecm`.`site`.`regulatory_submission_site` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_activation_id` FOREIGN KEY (`activation_id`) REFERENCES `clinical_trials_ecm`.`site`.`activation`(`activation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_edc_study_build_id` FOREIGN KEY (`edc_study_build_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`edc_study_build`(`edc_study_build_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `initiation_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `activation_id` SET TAGS ('dbx_business_glossary_term' = 'Site Activation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `edc_study_build_id` SET TAGS ('dbx_business_glossary_term' = 'Edc Study Build Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `action_item_count` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Action Item Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `actual_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Site Initiation Visit (SIV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `actual_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `attendee_count` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Attendee Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `attendee_names` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Attendee Names');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `attendee_names` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `attendee_names` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `attendee_names` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Cancellation Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `edc_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `first_patient_enrollment_authorized` SET TAGS ('dbx_business_glossary_term' = 'First Patient Enrollment Authorized Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `first_patient_enrollment_authorized_date` SET TAGS ('dbx_business_glossary_term' = 'First Patient Enrollment Authorization Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `gcp_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `icf_process_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Process Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `ip_handling_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Handling Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `open_action_item_count` SET TAGS ('dbx_business_glossary_term' = 'Open Site Initiation Visit (SIV) Action Item Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `protocol_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `regulatory_authority_approval_obtained` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Approval Obtained Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `rtsm_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `safety_reporting_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Safety and Adverse Event (AE/SAE) Reporting Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `scheduled_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Site Initiation Visit (SIV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `scheduled_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_number` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_number` SET TAGS ('dbx_value_regex' = '^SIV-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_by` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Signed Off By');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_by` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_by` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Sign-Off Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_status` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Sign-Off Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `siv_signoff_status` SET TAGS ('dbx_value_regex' = 'pending|signed_off|rejected|waived');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_end_time` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) End Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_notes` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_report_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Report Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Report Due Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_start_time` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Start Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|rescheduled|in_progress');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`initiation_visit` ALTER COLUMN `visit_type` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_agreement_investigator_grant_id` FOREIGN KEY (`agreement_investigator_grant_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`investigator_grant`(`investigator_grant_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `agreement_investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Investigator Grant Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Finance Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `actual_enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrolled Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `actual_screened_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Screened Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `completed_count` SET TAGS ('dbx_business_glossary_term' = 'Completed Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `cumulative_dropout_count` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Subject Dropout Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `cumulative_enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Enrolled Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `cumulative_screened_count` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Screened Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'ctms|edc|manual|integrated');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `dropout_count` SET TAGS ('dbx_business_glossary_term' = 'Subject Dropout Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `dropout_rate` SET TAGS ('dbx_business_glossary_term' = 'Subject Dropout Rate');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `enrollment_target_achievement_pct` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Target Achievement Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|minor_findings|major_findings|critical_findings|suspended');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `icf_signed_count` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Signed Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `irb_iec_approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `irb_iec_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|expired|suspended|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `last_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `open_query_count` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `performance_status` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Performance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `performance_status` SET TAGS ('dbx_value_regex' = 'on_track|at_risk|behind|ahead|closed|suspended');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `planned_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Enrollment Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `planned_enrolled_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Enrolled Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `planned_screened_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Screened Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `projected_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Projected Enrollment Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `randomized_count` SET TAGS ('dbx_business_glossary_term' = 'Randomized Subject Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `reporting_period_type` SET TAGS ('dbx_value_regex' = 'weekly|monthly|quarterly|annual|custom');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `sae_count` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `site_capacity` SET TAGS ('dbx_business_glossary_term' = 'Site Subject Capacity');

ALTER TABLE `clinical_trials_ecm`.`site`.`enrollment_performance` ALTER COLUMN `site_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ADD CONSTRAINT `fk_site_capacity_assessed_by_employee_id` FOREIGN KEY (`assessed_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ADD CONSTRAINT `fk_site_capacity_feasibility_assessment_id` FOREIGN KEY (`feasibility_assessment_id`) REFERENCES `clinical_trials_ecm`.`site`.`feasibility_assessment`(`feasibility_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ADD CONSTRAINT `fk_site_capacity_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ADD CONSTRAINT `fk_site_capacity_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_id` SET TAGS ('dbx_business_glossary_term' = 'Site Capacity ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessed By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Capacity Record Approved By');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Capacity Record Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `available_exam_rooms` SET TAGS ('dbx_business_glossary_term' = 'Available Examination Rooms');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `crc_count` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Coordinator (CRC) Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `dedicated_research_fte` SET TAGS ('dbx_business_glossary_term' = 'Dedicated Research Staff Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `dropout_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Historical Subject Dropout Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `ecg_capability` SET TAGS ('dbx_business_glossary_term' = 'Electrocardiogram (ECG) Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `econsent_capable` SET TAGS ('dbx_business_glossary_term' = 'Electronic Informed Consent (eConsent) Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `edc_system_capable` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Capacity Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `effective_until_date` SET TAGS ('dbx_business_glossary_term' = 'Capacity Effective Until Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|minor_findings|major_findings|critical_findings|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `imaging_capability` SET TAGS ('dbx_business_glossary_term' = 'Medical Imaging Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `irb_iec_approval_capacity` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approved Protocol Capacity');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `irb_iec_approval_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `irt_rtsm_capable` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology / Randomization and Trial Supply Management (IRT/RTSM) Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `lab_processing_capable` SET TAGS ('dbx_business_glossary_term' = 'On-Site Laboratory Processing Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `lab_sample_processing_capacity` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Sample Processing Capacity (Samples per Day)');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `lab_sample_processing_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `last_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `max_concurrent_protocols` SET TAGS ('dbx_business_glossary_term' = 'Maximum Concurrent Protocols');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `max_concurrent_subjects` SET TAGS ('dbx_business_glossary_term' = 'Maximum Concurrent Subjects');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Capacity Assessment Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `pharmacy_cold_chain_capable` SET TAGS ('dbx_business_glossary_term' = 'Pharmacy Cold Chain Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `pharmacy_storage_capacity_units` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `pi_fte_allocation` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) FTE Allocation');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `recruitment_rate_per_month` SET TAGS ('dbx_business_glossary_term' = 'Historical Subject Recruitment Rate (Per Month)');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `screen_failure_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Historical Screen Failure Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_status` SET TAGS ('dbx_business_glossary_term' = 'Capacity Record Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_status` SET TAGS ('dbx_value_regex' = 'draft|active|under_review|suspended|archived');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_type` SET TAGS ('dbx_business_glossary_term' = 'Capacity Declaration Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_type` SET TAGS ('dbx_value_regex' = 'declared|assessed|negotiated');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `capacity_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `utilization_pct` SET TAGS ('dbx_business_glossary_term' = 'Capacity Utilization Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`capacity` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Capacity Record Version');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_confidentiality_agreement_id` FOREIGN KEY (`confidentiality_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`confidentiality_agreement`(`confidentiality_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_negotiation_owner_employee_id` FOREIGN KEY (`negotiation_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ADD CONSTRAINT `fk_site_site_agreement_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `site_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Agreement ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `confidentiality_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Finance Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `negotiation_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `negotiation_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `negotiation_owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'CTA|CDA|Budget Amendment|Site Budget Agreement|Letter of Intent');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `closeout_fee` SET TAGS ('dbx_business_glossary_term' = 'Site Close-Out Fee');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `closeout_fee` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `cro_entity` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Entity');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `data_privacy_addendum` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Addendum Included');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Effective Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Execution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Expiration Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `indemnification_clause` SET TAGS ('dbx_business_glossary_term' = 'Indemnification Clause Included');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `insurance_coverage_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `ip_ownership_clause` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Ownership Clause Included');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `legal_review_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Agreement Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Overhead Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `payment_schedule_type` SET TAGS ('dbx_value_regex' = 'Milestone|Per Visit|Per Patient|Monthly|Quarterly');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms (Days)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `per_patient_fee` SET TAGS ('dbx_business_glossary_term' = 'Per-Patient Fee');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `per_patient_fee` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `publication_rights_clause` SET TAGS ('dbx_business_glossary_term' = 'Publication Rights Clause Included');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `site_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `site_signature_date` SET TAGS ('dbx_pii_signature_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `sponsor_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `sponsor_signature_date` SET TAGS ('dbx_pii_signature_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `startup_fee` SET TAGS ('dbx_business_glossary_term' = 'Site Startup Fee');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `startup_fee` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Termination Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'Mutual Consent|Sponsor Decision|Site Decision|Regulatory Action|Protocol Termination|For Cause');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `total_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_cra_qualification_id` FOREIGN KEY (`cra_qualification_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`cra_qualification`(`cra_qualification_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_delivery_preference_id` FOREIGN KEY (`delivery_preference_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`delivery_preference`(`delivery_preference_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_primary_site_employee_id` FOREIGN KEY (`primary_site_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_tertiary_site_cro_oversight_manager_employee_id` FOREIGN KEY (`tertiary_site_cro_oversight_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `site_cra_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Site Clinical Research Associate (CRA) Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `cra_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Cra Qualification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `delivery_preference_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preference Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Workforce ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `tertiary_site_cro_oversight_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Oversight Manager ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `tertiary_site_cro_oversight_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `tertiary_site_cro_oversight_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Approval Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_value_regex' = '^CRA-ASGN-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'pending|active|on_hold|completed|cancelled|transferred');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'primary|backup|co_monitor|lead|remote');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `confidentiality_agreement_signed` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Signed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `ctms_assignment_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Assignment Reference');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `delegation_log_entry_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Entry Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `gcp_training_current` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Current Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `gcp_training_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `handover_date` SET TAGS ('dbx_business_glossary_term' = 'CRA Handover Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `handover_visit_completed` SET TAGS ('dbx_business_glossary_term' = 'Handover Visit Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `last_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `monitoring_approach` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid|centralized');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `next_monitoring_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Assignment End Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `protocol_training_completed` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `protocol_training_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Site Risk Tier');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `sdv_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `sdv_rate_pct` SET TAGS ('dbx_standard_ref' = 'ICH_E6R2;standard_element:5.18.3_SDV');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Assignment Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `territory_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `total_visits_completed` SET TAGS ('dbx_business_glossary_term' = 'Total Monitoring Visits Completed');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `travel_required` SET TAGS ('dbx_business_glossary_term' = 'Travel Required Flag');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `visit_frequency_planned` SET TAGS ('dbx_business_glossary_term' = 'Planned Monitoring Visit Frequency');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `visit_frequency_planned` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|quarterly|as_needed|per_protocol');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_cra_assignment` ALTER COLUMN `workload_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Workload Allocation Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_activation_id` FOREIGN KEY (`activation_id`) REFERENCES `clinical_trials_ecm`.`site`.`activation`(`activation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_agreement_investigator_grant_id` FOREIGN KEY (`agreement_investigator_grant_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`investigator_grant`(`investigator_grant_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_final_site_payment_id` FOREIGN KEY (`final_site_payment_id`) REFERENCES `clinical_trials_ecm`.`finance`.`site_payment`(`site_payment_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_ip_accountability_log_id` FOREIGN KEY (`ip_accountability_log_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`ip_accountability_log`(`ip_accountability_log_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_ecm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_reconciliation_id` FOREIGN KEY (`reconciliation_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`reconciliation`(`reconciliation_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `closeout_id` SET TAGS ('dbx_business_glossary_term' = 'Site Close-Out ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `activation_id` SET TAGS ('dbx_business_glossary_term' = 'Activation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `agreement_investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Investigator Grant Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_site_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Final Site Payment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `ip_accountability_log_id` SET TAGS ('dbx_business_glossary_term' = 'Ip Accountability Log Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Closeout Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Closeout Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Closeout Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `capa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Completed Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `drug_accountability_status` SET TAGS ('dbx_business_glossary_term' = 'Drug Accountability Reconciliation Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `drug_accountability_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|discrepancy_identified|waived');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `essential_doc_archival_date` SET TAGS ('dbx_business_glossary_term' = 'Essential Document Archival Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `essential_doc_archival_status` SET TAGS ('dbx_business_glossary_term' = 'Essential Document Archival Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `essential_doc_archival_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|deficiency_noted');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Final Site Payment Amount');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Final Site Payment Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_payment_status` SET TAGS ('dbx_business_glossary_term' = 'Final Site Payment Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `final_payment_status` SET TAGS ('dbx_value_regex' = 'not_due|pending|invoiced|paid|disputed');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `gcp_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|minor_findings|major_findings|critical_findings');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `imp_return_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Return/Destruction Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `imp_return_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Return Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `imp_return_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_progress|completed|destroyed_on_site');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `initiated_date` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Initiated Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `irb_iec_notification_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `lslv_date` SET TAGS ('dbx_business_glossary_term' = 'Last Subject Last Visit (LSLV) Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Notes');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Reference Number');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `outstanding_queries_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Data Queries Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `payment_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `pi_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Acknowledgement Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `pi_acknowledgement_received` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Acknowledgement Received');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `regulatory_authority_notification_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `sdv_completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Completion Percentage');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `sdv_completion_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `site_file_transfer_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_progress|completed|failed');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `closeout_status` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `closeout_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `closeout_type` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Type');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `closeout_type` SET TAGS ('dbx_value_regex' = 'planned_completion|early_termination|protocol_amendment|sponsor_decision');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `visit_date` SET TAGS ('dbx_business_glossary_term' = 'Close-Out Visit Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`closeout` ALTER COLUMN `visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ADD CONSTRAINT `fk_site_ib_site_distribution_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ADD CONSTRAINT `fk_site_ib_site_distribution_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ADD CONSTRAINT `fk_site_ib_site_distribution_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ADD CONSTRAINT `fk_site_ib_site_distribution_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_association_edges' = 'site.investigational_site,safety.investigator_brochure_safety');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `ib_site_distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Ib Site Distribution - Ib Site Distribution Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Ib Site Distribution - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Ib Site Distribution - Investigator Brochure Safety Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `distribution_date` SET TAGS ('dbx_business_glossary_term' = 'IB Distribution Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Site IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Required');

ALTER TABLE `clinical_trials_ecm`.`site`.`ib_site_distribution` ALTER COLUMN `receipt_confirmed_date` SET TAGS ('dbx_business_glossary_term' = 'Receipt Confirmation Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ADD CONSTRAINT `fk_site_sponsor_site_qualification_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ADD CONSTRAINT `fk_site_sponsor_site_qualification_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ADD CONSTRAINT `fk_site_sponsor_site_qualification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` SET TAGS ('dbx_association_edges' = 'site.investigational_site,sponsor.organization');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ALTER COLUMN `sponsor_site_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Site Qualification - Sponsor Site Qualification Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Site Qualification - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Site Qualification - Org Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ALTER COLUMN `preferred_site_tier` SET TAGS ('dbx_classification' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`sponsor_site_qualification` ALTER COLUMN `site_qualification_status` SET TAGS ('dbx_operational_status' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ADD CONSTRAINT `fk_site_pi_qualification_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ADD CONSTRAINT `fk_site_pi_qualification_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ADD CONSTRAINT `fk_site_pi_qualification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_association_edges' = 'site.principal_investigator,sponsor.organization');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `pi_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Pi Qualification - Pi Qualification Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Pi Qualification - Org Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Pi Qualification - Principal Investigator Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `debarment_check_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Debarment Check Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `debarment_check_date` SET TAGS ('dbx_regulatory' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `historical_study_count` SET TAGS ('dbx_business_glossary_term' = 'Historical Study Count (Sponsor)');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `pi_performance_rating` SET TAGS ('dbx_business_glossary_term' = 'PI Performance Rating (Sponsor)');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `pi_performance_rating` SET TAGS ('dbx_sensitive' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `qualification_date` SET TAGS ('dbx_regulatory' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`pi_qualification` ALTER COLUMN `qualification_status` SET TAGS ('dbx_regulatory' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ADD CONSTRAINT `fk_site_staff_roster_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ADD CONSTRAINT `fk_site_staff_roster_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ADD CONSTRAINT `fk_site_staff_roster_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` SET TAGS ('dbx_association_edges' = 'site.investigational_site,workforce.employee');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `staff_roster_id` SET TAGS ('dbx_business_glossary_term' = 'Site Staff Roster - Site Staff Roster Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Site Staff Roster - Employee Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Staff Roster - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `delegation_log_ref` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Reference');

ALTER TABLE `clinical_trials_ecm`.`site`.`staff_roster` ALTER COLUMN `gcp_training_current` SET TAGS ('dbx_business_glossary_term' = 'GCP Training Current at Site');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ADD CONSTRAINT `fk_site_specialization_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ADD CONSTRAINT `fk_site_specialization_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ADD CONSTRAINT `fk_site_specialization_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` SET TAGS ('dbx_association_edges' = 'site.investigational_site,program.therapeutic_area');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `specialization_id` SET TAGS ('dbx_business_glossary_term' = 'Site Specialization - Site Specialization Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Specialization - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Site Specialization - Therapeutic Area Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `certification_status` SET TAGS ('dbx_business_glossary_term' = 'TA Certification Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `last_assessed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`specialization` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of TA Experience');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ADD CONSTRAINT `fk_site_program_site_participation_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ADD CONSTRAINT `fk_site_program_site_participation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ADD CONSTRAINT `fk_site_program_site_participation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_association_edges' = 'site.investigational_site,program.clinical_program');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ALTER COLUMN `program_site_participation_id` SET TAGS ('dbx_business_glossary_term' = 'Program Site Participation - Program Site Participation Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program Site Participation - Clinical Program Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Program Site Participation - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`program_site_participation` ALTER COLUMN `participation_status` SET TAGS ('dbx_business_glossary_term' = 'Site Program Participation Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ADD CONSTRAINT `fk_site_signal_review_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_ecm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ADD CONSTRAINT `fk_site_signal_review_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ADD CONSTRAINT `fk_site_signal_review_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_association_edges' = 'site.study_site,safety.safety_signal');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `signal_review_id` SET TAGS ('dbx_business_glossary_term' = 'Site Signal Review - Site Signal Review Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Site Signal Review - Safety Signal Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Signal Review - Study Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `action_required` SET TAGS ('dbx_business_glossary_term' = 'Site-Specific Action Required');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `action_taken_date` SET TAGS ('dbx_business_glossary_term' = 'Site Action Taken Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Site Signal Review Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `site_risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Site-Level Risk Assessment');

ALTER TABLE `clinical_trials_ecm`.`site`.`signal_review` ALTER COLUMN `site_specific_case_count` SET TAGS ('dbx_business_glossary_term' = 'Site-Specific Case Count');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ADD CONSTRAINT `fk_site_depot_assignment_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_ecm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ADD CONSTRAINT `fk_site_depot_assignment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ADD CONSTRAINT `fk_site_depot_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_subdomain' = 'operational_performance');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_association_edges' = 'site.investigational_site,supply.depot');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ALTER COLUMN `depot_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Site Depot Assignment - Site Depot Assignment Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Site Depot Assignment - Depot Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`depot_assignment` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Depot Assignment - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ADD CONSTRAINT `fk_site_authorization_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ADD CONSTRAINT `fk_site_authorization_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ADD CONSTRAINT `fk_site_authorization_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ADD CONSTRAINT `fk_site_authorization_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_subdomain' = 'selection_activation');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_association_edges' = 'site.investigational_site,regulatory.clinical_trial_authorization');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Site Authorization - Site Authorization Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Site Authorization - Clinical Trial Authorization Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Authorization - Investigational Site Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `enrollment_authorized_count` SET TAGS ('dbx_business_glossary_term' = 'Site Enrollment Authorization Limit');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Site Notification Date');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `site_specific_conditions` SET TAGS ('dbx_business_glossary_term' = 'Site-Specific Authorization Conditions');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `site_specific_conditions` SET TAGS ('dbx_regulatory_condition' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `status_at_site` SET TAGS ('dbx_business_glossary_term' = 'Site-Level Authorization Status');

ALTER TABLE `clinical_trials_ecm`.`site`.`authorization` ALTER COLUMN `status_at_site` SET TAGS ('dbx_regulatory_status' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ADD CONSTRAINT `fk_site_site_selection_committee_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ADD CONSTRAINT `fk_site_site_selection_committee_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ADD CONSTRAINT `fk_site_site_selection_committee_parent_site_selection_committee_id` FOREIGN KEY (`parent_site_selection_committee_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_selection_committee`(`site_selection_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` SET TAGS ('dbx_domain' = 'site');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `site_selection_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Site Selection Committee Identifier');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `parent_site_selection_committee_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `chairperson_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `committee_code` SET TAGS ('dbx_business_glossary_term' = 'Committee Id');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `country_code` SET TAGS ('dbx_standard_ref' = 'ISO3166;standard_element:country_code');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `site_selection_committee_name` SET TAGS ('dbx_business_glossary_term' = 'Name');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `site_selection_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`site`.`site_selection_committee` ALTER COLUMN `site_selection_committee_status` SET TAGS ('dbx_business_glossary_term' = 'Status');
