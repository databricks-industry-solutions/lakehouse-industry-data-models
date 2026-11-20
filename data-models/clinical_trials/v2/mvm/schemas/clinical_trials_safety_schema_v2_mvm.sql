-- Schema for Domain: safety | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:48

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`safety` COMMENT 'Manages adverse events (AE), serious adverse events (SAE), suspected unexpected serious adverse reactions (SUSAR), and safety signal detection. Owns MedDRA coding (SOC/PT/LLT), CTCAE severity grading, causality assessments, expedited regulatory reporting';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`adverse_event` (
    `adverse_event_id` BIGINT COMMENT 'Unique surrogate identifier for each adverse event record in the lakehouse Silver layer. Serves as the primary key for the adverse_event data product and is the SSOT reference for all AE occurrences across studies and subjects.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Safety-by-arm analyses are mandatory for DSMB unblinded reviews and regulatory benefit-risk assessments. AE incidence rates per treatment arm are a core clinical trial safety reporting requirement.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: Regulatory requirement: when processing an AE, safety reviewers must confirm the subject held valid informed consent under an approved ICF at time of event onset.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Dose-response safety analyses require linking AEs to the specific dosing regimen at event onset.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Source data verification (SDV) and ALCOA audit trail require tracing each adverse event back to the specific eCRF AE form it was collected on.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: Pharmacovigilance causality assessment and DSUR/PBRER generation require direct linkage from AE to the IMP product master.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the adverse event was reported. Used for site-level safety monitoring and CRA oversight.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: GxP regulations (21 CFR 312, EMA GMP) require batch-level traceability from adverse events for product quality investigations and potential recalls.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: AE regulatory reporting (ICSRs, expedited reports) requires the protocol version in effect at event onset. ICH E2B(R3) and FDA MedWatch submissions reference protocol version.',
    `study_id` BIGINT COMMENT 'FK to study.study.study_id — Critical for study-level safety analysis — AEs must join to study for DSUR preparation, aggregate safety tables, and cross-study signal detection.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: AE records require the subjects authoritative randomization record for causality assessment, ICSR narrative population, and expedited reporting obligation determination.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: AEs are reported at specific subject visits. Linking adverse_event to subject_visit_data enables visit-level data completeness review, SDV tracking, and lock/freeze status',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) who experienced the adverse event. Core party reference linking the AE to the enrolled participant.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: AEs are collected at specific study visits; SDTM AE domain requires AEVISIT mapping. Safety reviewers and data managers trace AE onset to the reporting visit for source data',
    `adverse_severity_codelist_term_id` BIGINT COMMENT 'Reference to datamanagement.codelist_term.codelist_term_id.',
    `adverse_outcome_codelist_term_id` BIGINT COMMENT 'Reference to datamanagement.codelist_term.codelist_term_id.',
    `adverse_action_taken_codelist_term_id` BIGINT COMMENT 'Reference to datamanagement.codelist_term.codelist_term_id.',
    `action_taken` STRING COMMENT 'Action taken with study treatment (verbatim/submission value); see action_taken_ct_term_id for controlled terminology reference. Valid values are `none|dose_reduced|dose_interrupted|drug_withdrawn|not_applicable|unknown`',
    `ae_status` STRING COMMENT 'Current lifecycle status of the adverse event record, reflecting whether the event is still active, has resolved, or resulted in death. Drives workflow routing in the source system and expedited reporting decisions.. Valid values are `ongoing|resolved|resolved_with_sequelae|fatal|unknown`',
    `ae_term_verbatim` STRING COMMENT 'The exact verbatim text of the adverse event as reported by the investigator or subject on the eCRF, prior to MedDRA coding. Preserved for ALCOA+ compliance and audit trail integrity.',
    `ae_verbatim_term` STRING COMMENT 'Verbatim (as-reported) term before coding, retained as source of truth.',
    `argus_case_number` STRING COMMENT 'Externally-known case identifier assigned by the source system upon initial AE entry. This is the business-facing identifier used in regulatory submissions, safety narratives, and cross-system reconciliation with the source system of record.',
    `awareness_date` DATE COMMENT 'The date on which the sponsor (or CRO acting on behalf of the sponsor) first became aware of the adverse event. This is the clock-start date for regulatory expedited reporting timelines per ICH E2A.',
    `causality_assessment` STRING COMMENT 'Investigators assessment of the causal relationship between the investigational product and the adverse event. Determines whether the event qualifies as a suspected adverse reaction and drives SUSAR classification and expedited reporting.. Valid values are `unrelated|unlikely|possible|probable|definite|not_assessable`',
    `coding_dictionary` STRING COMMENT 'Coding dictionary used to code the verbatim term (e.g. MedDRA, WHODrug).',
    `coding_dictionary_version` STRING COMMENT 'Version of the coding dictionary used to code the verbatim term.',
    `concomitant_medication_related` BOOLEAN COMMENT 'Indicates whether the adverse event may be related to concomitant medications taken by the subject, as assessed by the investigator. Supports differential causality analysis and confounding factor assessment.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this adverse event record was first created in the source system (the source system Supports audit trail requirements under 21 CFR Part 11 and ICH E6(R2) ALCOA+ principles.',
    `ctcae_grade` BIGINT COMMENT 'Severity grade assigned per the National Cancer Institute Common Terminology Criteria for Adverse Events (CTCAE), ranging from 1 (mild) to 5 (death). The primary severity measure used in oncology and other therapeutic areas for safety reporting and',
    `dsmb_reported` BOOLEAN COMMENT 'Indicates whether this adverse event has been reported to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for independent safety review. Supports DSMB/DMC meeting preparation and safety oversight documentation.',
    `edc_subject_sequence_number` STRING COMMENT 'The AE sequence number assigned within the EDC system (Medidata Rave eCRF) for the subject, used to reconcile the safety database record with the source eCRF entry during SDV and data review.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record is the most current version of the adverse event. Used to filter the latest state of each AE without requiring a MAX(version_number) query, supporting efficient reporting and analytics.',
    `is_expected` BOOLEAN COMMENT 'Indicates whether the adverse event is listed in the current Investigators Brochure (IB) or product labeling as an expected/anticipated reaction. Unexpected serious adverse reactions trigger SUSAR reporting obligations.',
    `is_serious` BOOLEAN COMMENT 'Indicates whether the adverse event meets the regulatory definition of a Serious Adverse Event (SAE) per ICH E2A criteria (death, life-threatening, hospitalization, disability, congenital anomaly, or other medically important condition).',
    `is_susar` BOOLEAN COMMENT 'Indicates whether this adverse event has been classified as a Suspected Unexpected Serious Adverse Reaction (SUSAR), requiring expedited regulatory reporting to health authorities (FDA, EMA, MHRA, etc.) within defined timelines (7 or 15 calendar days).',
    `is_teae` BOOLEAN COMMENT 'Indicates whether the adverse event is treatment-emergent, defined as an event that first occurred or worsened in severity after the first dose of investigational product.',
    `meddra_llt_code` STRING COMMENT 'MedDRA Lowest Level Term (LLT) numeric code assigned during medical coding, representing the most granular level of the MedDRA hierarchy closest to the verbatim term.',
    `meddra_llt_name` STRING COMMENT 'MedDRA Lowest Level Term (LLT) text description corresponding to the LLT code. Used in safety listings, narratives, and regulatory submissions.',
    `meddra_pt_name` STRING COMMENT 'MedDRA Preferred Term (PT) text description. The standardized medical term used in all regulatory submissions, DSMB/DMC reports, and safety narratives.',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class (SOC) numeric code representing the highest level of the MedDRA hierarchy. Used for aggregate safety tabulations by body system in CSRs and regulatory submissions.',
    `meddra_soc_name` STRING COMMENT 'MedDRA System Organ Class (SOC) text description. Used in safety tabulations, listings, and figures in the Clinical Study Report (CSR).',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for coding this adverse event (e.g., 26.0). Required for regulatory submissions to ensure reproducibility of coded terms across dictionary versions.',
    `medical_history_related` BOOLEAN COMMENT 'Indicates whether the adverse event is considered related to or a continuation of a pre-existing medical history condition, as assessed by the investigator. Supports pre-existing condition confounding analysis.',
    `narrative` STRING COMMENT 'Free-text medical narrative describing the clinical course of the adverse event, including relevant medical history, treatment, and outcome. Required for SAE/SUSAR regulatory submissions and DSMB/DMC safety reviews.',
    `onset_date` DATE COMMENT 'The date on which the adverse event first began, as reported by the investigator. This is the principal real-world event date used for duration calculations, expedited reporting timelines, and TEAE determination.',
    `outcome` STRING COMMENT 'Outcome of adverse event (verbatim/submission value); see outcome_ct_term_id for controlled terminology reference. Valid values are `recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown`',
    `regulatory_report_due_date` DATE COMMENT 'The deadline by which an expedited safety report (e.g., SUSAR, IND Safety Report) must be submitted to the relevant health authority. Calculated from the date of first awareness per ICH E2A timelines (7-day for fatal/life-threatening, 15-day for other',
    `regulatory_report_submitted_date` DATE COMMENT 'The actual date on which the expedited safety report was submitted to the health authority. Used to calculate compliance with regulatory reporting timelines and track submission performance KPIs.',
    `report_type` STRING COMMENT 'Indicates whether this record represents the initial AE report, a follow-up update with new clinical information, or the final report upon event resolution. Supports version history tracking as the clinical picture evolves.. Valid values are `initial|follow_up|final`',
    `resolution_date` DATE COMMENT 'The date on which the adverse event resolved or returned to baseline. Null if the event is ongoing. Used to calculate AE duration and determine outcome status.',
    `seriousness_criteria` STRING COMMENT 'Specific ICH E2A seriousness criterion or criteria met by this SAE (e.g., death, life-threatening, hospitalization required, persistent disability, congenital anomaly, medically significant). Multiple criteria may apply.',
    `severity` STRING COMMENT 'Severity or intensity of adverse event (verbatim/submission value); see severity_ct_term_id for controlled terminology reference. Valid values are `mild|moderate|severe|life_threatening|fatal`',
    `study_day_onset` BIGINT COMMENT 'The study day (relative to first dose date) on which the adverse event began. Calculated per CDISC convention (Day 1 = first dose date). Used in time-to-event analyses and safety exposure-adjusted incidence calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this adverse event record was most recently modified in the source system. Supports change tracking, audit trail compliance, and incremental data loading in the Databricks Silver layer.',
    `verbatim_term` STRING COMMENT 'STRING',
    `verbatim_term_ae` STRING COMMENT 'description',
    `version_number` BIGINT COMMENT 'Sequential version number of this AE record, incremented with each follow-up update. Version 1 is the initial report; subsequent versions capture evolving clinical information. Enables temporal evolution tracking across the AE lifecycle.',
    CONSTRAINT pk_adverse_event PRIMARY KEY(`adverse_event_id`)
) COMMENT 'Core master record for every adverse event (AE) reported during a clinical trial, capturing onset date, resolution date, severity grade per CTCAE, seriousness flag, expectedness, relationship to investigational product, action taken, outcome, and';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` (
    `serious_adverse_event_id` BIGINT COMMENT 'Unique surrogate identifier for the Serious Adverse Event record in the Databricks Silver Layer. Primary key for this transactional entity. Role: TRANSACTION_HEADER.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the parent Adverse Event (AE) record from which this SAE was escalated. Every SAE must be linked to a parent AE record in the safety domain.',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: serious_adverse_event carries redundant MedDRA coding fields (meddra_llt_code, meddra_pt_code, meddra_soc_code, meddra_version) that are authoritatively stored in ae_meddra_coding.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Unblinded SAE line listings for DSMB reviews require treatment arm attribution. Regulatory benefit-risk submissions require SAE rates by arm.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU/EEA SAEs must be reported to competent authorities under the specific CTA via EudraVigilance.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: SAE regulatory reporting (expedited 7/15-day reports) requires confirmation that the subject had valid informed consent.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: SAE regulatory submissions require dose at time of event. Dose-escalation stopping rules depend on SAE rates by dosing regimen.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: SAE reconciliation between the safety database and EDC requires identifying the specific eCRF SAE form.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: SAE expedited reporting to health authorities (FDA, EMA) requires precise IMP identification including formulation and strength.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: FDA requires SAEs to be reported under the specific IND governing the study. The SAE record must reference the IND for 15-day expedited reporting clock tracking, annual IND safety',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the SAE was reported. Used for site-level safety monitoring and CRA follow-up.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: SAEs require IRB/IEC notification per ICH E6(R2) 4.11.1. The SAE record must reference the specific irb_iec_approval active at time of event to document which approval was notified and',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.laboratory_lab_result. Business justification: SAE expedited reports (CIOMS/MedWatch, ICH E2B) require direct reference to the lab result that triggered or supported the SAE determination (e.g., elevated ALT for',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: SAE regulatory expedited reports (ICH E2A/E2B) require the specific IMP batch number for batch recall decisions and health authority submissions.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Regulatory agencies (FDA, EMA) require SAE narratives to document whether a protocol deviation contributed to the SAE.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SAE expectedness assessment and 7/15-day reporting timelines are protocol-version-specific. Regulatory SAE submissions to FDA/EMA require the protocol version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which the SAE occurred. Used for regulatory reporting and safety signal aggregation across the study.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: SAE aggregate reporting and site risk tiering require linking SAEs to the study_site record, which holds per-protocol SAE counts, monitoring visit data, and risk tier.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: SAE regulatory submissions (CIOMS I, MedWatch) require the subjects treatment arm from the authoritative randomization record.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: SAE data is captured via eCRF at a specific subject visit; safety data managers reconcile SAE source data against subject_visit_data records during DBL and regulatory',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: SAEs meeting expedited reporting criteria (7-day/15-day) are packaged into regulatory submissions.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: SAE reports are ICH E6 GCP essential documents that must be filed in the TMF. Regulatory inspectors verify SAE documentation in the TMF.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the study subject (patient/participant) who experienced the SAE. Serves as the PARTY_REFERENCE for this transaction header per canonical attribute rules.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.withdrawal. Business justification: SAEs frequently cause subject withdrawal. The SAE record must reference the withdrawal for complete case documentation, CSR subject disposition tables, and regulatory submissions requiring',
    `action_taken` STRING COMMENT 'The action taken with the investigational product in response to the SAE (e.g., dose reduced, drug withdrawn, dose interrupted). This is a key regulatory field in ICSR submissions and clinical study reports.. Valid values are `dose_reduced|drug_withdrawn|dose_interrupted|not_applicable|unknown`',
    `argus_case_number` STRING COMMENT 'Externally-known unique case identifier assigned by the source system upon SAE intake. This is the BUSINESS_IDENTIFIER used for cross-system traceability, regulatory submissions, and sponsor communications.',
    `blinding_status` STRING COMMENT 'Indicates whether the SAE case is currently blinded (treatment assignment unknown) or unblinded (treatment assignment revealed for safety reporting purposes). Unblinding may be required for SUSAR reporting to regulatory authorities.. Valid values are `blinded|unblinded|not_applicable`',
    `causality_assessment` STRING COMMENT 'The investigators assessment of the causal relationship between the investigational product and the SAE. This is a critical regulatory field used to determine whether the event qualifies as a Suspected Unexpected Serious Adverse Reaction (SUSAR).. Valid values are `related|not_related|possibly_related|probably_related|unknown`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when the SAE record was first created in the source system Serves as the RECORD_AUDIT_CREATED field per canonical transaction header requirements. Conforms to 21 CFR Part 11 audit trail requirements.',
    `ctcae_grade` BIGINT COMMENT 'The CTCAE severity grade assigned to the SAE, ranging from 1 (mild) to 5 (death). Grade 3 = severe, Grade 4 = life-threatening, Grade 5 = death. Used for oncology and other therapeutic area safety assessments.',
    `dsmb_reported` BOOLEAN COMMENT 'Indicates whether this SAE was reported to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for independent safety review. Required for studies with an active DSMB/DMC charter.',
    `expectedness` STRING COMMENT 'Indicates whether the SAE is expected (listed in the Investigators Brochure or product labeling) or unexpected (not listed or differing in nature/severity). Unexpected + serious + related = SUSAR, triggering expedited regulatory reporting.. Valid values are `expected|unexpected|unknown`',
    `follow_up_number` BIGINT COMMENT 'Sequential number indicating which follow-up report this record represents (0 = initial report, 1 = first follow-up, 2 = second follow-up, etc.). Used to track the evolution of the SAE case over time as new information becomes available.',
    `initial_report_date` DATE COMMENT 'The date on which the SAE was first reported to the sponsor or CRO by the investigational site. This is Day 0 for calculating regulatory reporting timelines (e.g., 7-day or 15-day expedited reporting clock).',
    `irb_iec_notification_date` DATE COMMENT 'The date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was notified of the SAE. Required under GCP and local regulations to ensure ongoing ethical oversight of the study.',
    `is_susar` BOOLEAN COMMENT 'Indicates whether this SAE has been classified as a Suspected Unexpected Serious Adverse Reaction (SUSAR), requiring expedited regulatory reporting to health authorities (e.g., FDA 7/15-day reporting, EMA reporting).',
    `narrative` STRING COMMENT 'The full medical narrative describing the SAE, including clinical course, relevant medical history, concomitant medications, investigational product details, and the investigators assessment.',
    `onset_date` DATE COMMENT 'The date on which the serious adverse event first began or was first observed by the subject or investigator. This is the principal BUSINESS_EVENT_TIMESTAMP (date precision) for the SAE transaction.',
    `outcome` STRING COMMENT 'The clinical outcome of the serious adverse event at the time of the most recent report. recovered_with_sequelae indicates the subject recovered but with lasting effects. fatal must align with seriousness_death = true.. Valid values are `recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown`',
    `regulatory_report_due_date` DATE COMMENT 'The calculated deadline by which the expedited regulatory report (e.g., IND Safety Report, SUSAR notification) must be submitted to the relevant health authority.',
    `report_type` STRING COMMENT 'Classifies the type of safety report generated for this SAE. expedited = 7/15-day SUSAR or IND safety report; periodic = included in DSUR/PSUR; spontaneous = post-marketing spontaneous report; literature = identified from published literature.. Valid values are `expedited|periodic|spontaneous|literature`',
    `reporting_authority` STRING COMMENT 'The health authority or regulatory body to which the SAE/SUSAR report was submitted (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). May contain multiple authorities if reported to more than one.',
    `resolution_date` DATE COMMENT 'The date on which the serious adverse event resolved, stabilized, or the subject died. Null if the event is ongoing at the time of reporting.',
    `sae_status` STRING COMMENT 'Current lifecycle status of the SAE case in the source system initial = first report received; follow_up = additional information received; closed = case fully resolved and closed; nullified = case determined not to meet SAE criteria and voided.. Valid values are `initial|follow_up|closed|nullified`',
    `sae_term` STRING COMMENT 'The verbatim (as-reported) description of the serious adverse event as recorded by the investigator or site staff in the source document or eCRF. This is the raw, uncoded term prior to MedDRA coding.',
    `seriousness_congenital_anomaly` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of resulting in a congenital anomaly or birth defect in the offspring of the subject.',
    `seriousness_death` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of resulting in death of the subject. One of the six ICH E2A seriousness criteria that must be captured individually.',
    `seriousness_disability` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of resulting in persistent or significant disability or incapacity.',
    `seriousness_hospitalization` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of requiring inpatient hospitalization or prolongation of existing hospitalization.',
    `seriousness_life_threatening` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of being immediately life-threatening (i.e., the subject was at immediate risk of death at the time of the event).',
    `seriousness_medically_important` BOOLEAN COMMENT 'Indicates whether the SAE meets the regulatory seriousness criterion of being an other medically important condition — events that may not be immediately life-threatening but may jeopardize the subject or require intervention to prevent one of the other',
    `source_document_reference` STRING COMMENT 'Reference identifier for the source document (e.g., hospital discharge summary, death certificate, medical records) that supports the SAE report. Used for SDV and audit trail purposes per ALCOA+ principles.',
    `sponsor_receipt_date` DATE COMMENT 'The date on which the sponsor (or CRO acting on behalf of the sponsor) received the complete minimum information required to process the SAE. This date starts the regulatory reporting clock per ICH E2A.',
    `subject_number` STRING COMMENT 'The protocol-assigned subject identifier (e.g., site-subject number) for the patient who experienced the SAE. Restricted as it can be used to identify an individual participant in combination with study data.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when the SAE record was most recently modified in the source system Serves as the RECORD_AUDIT_UPDATED field per canonical transaction header requirements. Required for 21 CFR Part 11 audit trail compliance.',
    CONSTRAINT pk_serious_adverse_event PRIMARY KEY(`serious_adverse_event_id`)
) COMMENT 'Transactional record for Serious Adverse Events (SAEs) that meet regulatory seriousness criteria (death, life-threatening, hospitalization, disability, congenital anomaly, or other medically important condition).';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`susar` (
    `susar_id` BIGINT COMMENT 'Unique surrogate identifier for the SUSAR record in the Databricks Silver Layer. Primary key for this transactional entity. Entity role: TRANSACTION_HEADER — a discrete regulatory safety event with a defined lifecycle, expedited reporting obligations, and',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: A SUSAR is a specific type of adverse event that is both serious and unexpected. Every SUSAR originates from an underlying adverse event record.',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: susar carries redundant MedDRA coding fields (meddra_llt_code, meddra_pt_code, meddra_soc_code, meddra_version) that duplicate the authoritative ae_meddra_coding record.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: SUSAR line listings submitted to health authorities and DSMB require treatment arm attribution for unblinded safety reviews.',
    `causality_assessment_id` BIGINT COMMENT 'Foreign key linking to safety.causality_assessment. Business justification: susar carries a causality_assessment string field that duplicates the structured causality_assessment record.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: SUSARs in EU trials are reported under specific CTAs to EMA/national competent authorities per EU Clinical Trials Regulation.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: SUSAR regulatory submissions require confirmation of subject consent validity.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: SUSAR reports require dose at onset for health authority submissions. The susar.dose_at_onset is a denormalized field that should be replaced by FK to dosing_regimen.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: SUSARs must be formally submitted to ethics committees (IRB/IEC) within 7-15 days per ICH E2A. The ethics_submission record tracks this mandatory notification.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: SUSAR reporting timelines (7-day/15-day) and applicable health authorities are defined by the sponsors regulatory strategy.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: SUSAR regulatory reporting (7/15-day clock) to health authorities requires authoritative IMP identification.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: SUSARs must be reported under the specific IND for FDA expedited safety reporting.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the SUSAR occurred. Used for site-level safety monitoring, regulatory notifications, and investigator communications.',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: When a SUSAR is identified, the sponsor must notify the specific IRB/IEC approval under which subjects are enrolled per ICH E6(R2) 4.11 and 21 CFR 312.32.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: SUSARs submitted to EudraVigilance and health authorities (EU CT Regulation, ICH E2A) must include the IMP batch/lot number.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SUSAR reporting to EudraVigilance and FDA requires the protocol version. EU CTR Article 42 and 21 CFR 312.32 mandate protocol reference in SUSAR submissions.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: SUSARs are expedited safety reports submitted to health authorities and compiled into regulatory binders for CTA/IND submissions.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this SUSAR occurred. Links the SUSAR to the sponsoring study for regulatory reporting and safety surveillance.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: SUSARs require investigator and IRB/IEC notification at the study-site level. Linking susar to study_site drives per-site SUSAR notification workflows and enables study-site-level SUSAR',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: SUSAR causality and expectedness determination requires the subjects authoritative treatment assignment from the randomization system.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: SUSARs originate from eCRF visit data; regulatory inspectors verify SUSAR source data against subject_visit_data records during GCP inspections.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: SUSARs require expedited regulatory submission (7-day fatal/life-threatening, 15-day others).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: SUSAR expedited reports are essential TMF documents (DIA TMF Reference Model Zone 1, Section 11).',
    `trial_subject_id` BIGINT COMMENT 'Reference to the study subject (patient) who experienced the SUSAR. Links to the subject master record for patient-level safety surveillance and regulatory reporting.',
    `ae_term` STRING COMMENT 'Verbatim description of the adverse event as reported by the investigator or subject, prior to MedDRA coding. Preserved for source data verification (SDV) and coding audit trail per ALCOA+ principles.',
    `argus_case_reference` BIGINT COMMENT 'System-generated case identifier from the source system the operational system of record for adverse event and SUSAR management. Used to trace the SUSAR back to its source case in Argus.',
    `awareness_date` DATE COMMENT 'Date on which the sponsor (or CRO acting on behalf of the sponsor) first became aware of the SUSAR. This date starts the regulatory reporting clock for 7-day and 15-day expedited reporting obligations under ICH E2A.',
    `blind_break_date` DATE COMMENT 'Date on which the treatment blind was broken for this subject. Populated only when blind_broken is True. Required for audit trail and regulatory documentation of unblinding events.',
    `blind_broken` BOOLEAN COMMENT 'Indicates whether the treatment blind was broken for this subject in order to perform the causality assessment for this SUSAR. A blind break is a significant event requiring documentation and regulatory notification.',
    `blind_status` STRING COMMENT 'Blinding status of the study at the time of SUSAR reporting. Indicates whether the study was blinded, and if so, whether the blind was broken for this subject to determine treatment assignment for causality assessment.. Valid values are `blinded|unblinded|open_label`',
    `case_number` STRING COMMENT 'Externally-known alphanumeric case number assigned by the sponsor or CRO for this SUSAR, used in all regulatory submissions and correspondence. Serves as the BUSINESS_IDENTIFIER for this transaction.. Valid values are `^[A-Z0-9-]{5,30}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the SUSAR record was first created in the source system Serves as the RECORD_AUDIT_CREATED field for this transaction header, supporting ALCOA+ data integrity requirements.',
    `ctcae_grade` BIGINT COMMENT 'CTCAE severity grade assigned to the adverse reaction (1=Mild, 2=Moderate, 3=Severe, 4=Life-threatening, 5=Death). Used for safety signal detection, DSMB/DMC reviews, and regulatory reporting.',
    `deadline_15day` DATE COMMENT 'Calculated deadline for 15-day expedited reporting to regulatory authorities for non-fatal/non-life-threatening SUSARs. Derived from the reporting clock start date plus 15 calendar days per ICH E2A and FDA 21 CFR 312.32.',
    `deadline_7day` DATE COMMENT 'Calculated deadline for 7-day expedited reporting to regulatory authorities for fatal or life-threatening SUSARs. Derived from the reporting clock start date plus 7 calendar days per ICH E2A and FDA 21 CFR 312.32.',
    `dsmb_notification_date` DATE COMMENT 'Date on which the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) was notified of this SUSAR. Populated only when dsmb_notified is True.',
    `dsmb_notified` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) was notified of this SUSAR. Required for studies with an active DSMB/DMC per ICH E6(R2) and study protocol.',
    `eudravigilance_number` STRING COMMENT 'Unique case identifier assigned by the EudraVigilance system upon submission of the SUSAR to the EMA. Used for tracking and referencing the case in EU regulatory correspondence and EudraVigilance database.',
    `expectedness_assessment` STRING COMMENT 'Assessment of whether the serious adverse reaction is unexpected — i.e., not listed or not consistent with the nature, severity, or frequency described in the current Investigators Brochure (IB).. Valid values are `unexpected|expected`',
    `fatal_date` DATE COMMENT 'Date of subject death if the outcome of the SUSAR is fatal. Triggers the 7-day expedited reporting clock and is required for death narratives in regulatory submissions.',
    `follow_up_number` BIGINT COMMENT 'Sequential number of the follow-up report for this SUSAR case (e.g., 1 for first follow-up, 2 for second). Zero or null for initial reports. Tracks the version history of regulatory submissions for this case.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was notified of this SUSAR. Populated only when irb_iec_notified is True.',
    `irb_iec_notified` BOOLEAN COMMENT 'Indicates whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was notified of this SUSAR as required by GCP and local regulations.',
    `narrative` STRING COMMENT 'Medical narrative summarizing the SUSAR case, including patient demographics, event description, clinical course, causality assessment, and outcome. Required component of all expedited regulatory reports per ICH E2A.',
    `onset_date` DATE COMMENT 'Date on which the subject first experienced the serious adverse reaction. This is the principal real-world event time (BUSINESS_EVENT_TIMESTAMP) for the SUSAR and is the anchor for all regulatory reporting clocks per ICH E2A.',
    `outcome` STRING COMMENT 'Clinical outcome of the serious adverse reaction at the time of reporting. Required for regulatory submissions and DSMB/DMC safety reviews. Tracks resolution status of the event.. Valid values are `recovered|recovering|not_recovered|fatal|unknown|sequelae`',
    `reporting_clock_start_date` DATE COMMENT 'The date from which the regulatory reporting clock begins for this SUSAR. Typically the sponsor awareness date, but may be adjusted based on the date of unblinding or receipt of minimum reportable information per ICH E2A.',
    `reporting_status` STRING COMMENT 'Current lifecycle state of the SUSAR regulatory reporting workflow. Tracks progression from initial draft through submission to regulatory authority acknowledgement and case closure. Serves as the LIFECYCLE_STATUS for this transaction.. Valid values are `draft|submitted|acknowledged|closed|withdrawn`',
    `route_of_administration` STRING COMMENT 'Route by which the investigational product was administered (e.g., oral, intravenous, subcutaneous). Required for regulatory case narratives and pharmacovigilance signal assessment.',
    `seriousness_criteria` STRING COMMENT 'ICH E2A seriousness criterion met by this adverse reaction that qualifies it as a Serious Adverse Event (SAE). [ENUM-REF-CANDIDATE: death|life_threatening|hospitalization|disability|congenital_anomaly|medically_significant — promote to reference product]',
    `submission_report_type` STRING COMMENT 'Indicates whether this SUSAR submission is an initial report, a follow-up report with additional information, or a final report closing the case. Regulatory authorities require tracking of report versions per ICH E2A.. Valid values are `initial|follow_up|final`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the SUSAR record in the source system Serves as the RECORD_AUDIT_UPDATED field for this transaction header, supporting audit trail and data integrity requirements.',
    CONSTRAINT pk_susar PRIMARY KEY(`susar_id`)
) COMMENT 'Transactional record for Suspected Unexpected Serious Adverse Reactions (SUSARs) — SAEs that are both unexpected (not in the Investigator Brochure) and causally related to the investigational product.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` (
    `ae_meddra_coding_id` BIGINT COMMENT 'Unique surrogate identifier for each MedDRA coding record assigned to an adverse event. Primary key for the ae_meddra_coding data product in the safety domain.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the parent adverse event record for which this MedDRA coding assignment was made. Links the coding record back to the originating AE in the source system',
    `discrepancy_query_id` BIGINT COMMENT 'Foreign key linking to datamanagement.discrepancy_query. Business justification: MedDRA coding discrepancies generate EDC queries that must be resolved before database lock.',
    `ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: MedDRA coding traceability requires identifying which specific eCRF field contained the verbatim AE term that was coded.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which the adverse event and its MedDRA coding were recorded. Supports study-level aggregate safety reporting.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: MedDRA coding is performed on AE verbatim terms captured in subject visit eCRF data.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) who experienced the adverse event being coded. Enables subject-level safety queries and MedDRA-coded AE listings.',
    `argus_case_reference` STRING COMMENT 'The case identifier from the source system that corresponds to this MedDRA coding record. Serves as the source system business key for traceability back to the originating safety case in the system of record.',
    `argus_event_reference` STRING COMMENT 'The event-level identifier from the source system for the specific adverse event record within a case that this MedDRA coding applies to. Enables precise traceability to the source system event record.',
    `coded_date` DATE COMMENT 'Calendar date on which the MedDRA code was assigned to the verbatim adverse event term. Used for coding timeliness metrics and regulatory submission audit trails.',
    `coded_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone) at which the MedDRA code was assigned. Provides granular audit trail for 21 CFR Part 11 electronic records compliance. Sourced from the source system system timestamp.',
    `coding_comment` STRING COMMENT 'Free-text comment entered by the coder to document coding rationale, ambiguities, or special considerations for this MedDRA assignment. Supports coding consistency reviews and regulatory inspection readiness.',
    `coding_method` STRING COMMENT 'Indicates how the MedDRA code was assigned: auto for system-generated auto-coding by the source system manual for coder-assigned coding, auto_confirmed for auto-coded and confirmed by a coder, recoded for a previously coded term that was. Valid values are `auto|manual|auto_confirmed|recoded`',
    `coding_status` STRING COMMENT 'Current workflow status of the MedDRA coding assignment. pending indicates awaiting coding, coded indicates a code has been assigned, confirmed indicates QC-approved, rejected indicates coding was rejected and requires rework, under_review. Valid values are `pending|coded|confirmed|rejected|under_review`',
    `confirmed_date` DATE COMMENT 'Date on which the MedDRA coding assignment was confirmed (QC-approved) by a second reviewer or coding supervisor. Null if coding has not yet been confirmed. Supports dual-coder QC workflows.',
    `ctcae_grade` BIGINT COMMENT 'Severity grade assigned to the adverse event using the NCI Common Terminology Criteria for Adverse Events (CTCAE) scale (1=Mild, 2=Moderate, 3=Severe, 4=Life-threatening, 5=Death).',
    `ctcae_version` STRING COMMENT 'Version of the NCI CTCAE grading scale used for severity assessment (e.g., 5.0, 4.03). Required for regulatory submissions to ensure consistent severity grading interpretation across study sites and time periods.. Valid values are `^[0-9]+.[0-9]+$`',
    `dictionary_language` STRING COMMENT 'Three-letter ISO 639-2 language code of the MedDRA dictionary used for coding (e.g., ENG for English, JPN for Japanese). Relevant for multi-regional studies where local language MedDRA versions may be used (e.g., PMDA submissions in Japan).. Valid values are `^[A-Z]{3}$`',
    `effective_from_date` DATE COMMENT 'Date from which this MedDRA coding record version is considered effective. Used in conjunction with is_current_version and effective_to_date to implement SCD Type 2 versioning for coding history tracking.',
    `hlgt_code` STRING COMMENT 'Eight-digit MedDRA numeric code for the High Level Group Term (HLGT), which sits between the HLT and SOC in the MedDRA hierarchy. Used for broad safety grouping in regulatory submissions.. Valid values are `^[0-9]{8}$`',
    `hlgt_name` STRING COMMENT 'Descriptive text of the MedDRA High Level Group Term (HLGT) corresponding to hlgt_code. Supports broad-level safety grouping in aggregate analyses and CSR appendices.',
    `hlt_code` STRING COMMENT 'Eight-digit MedDRA numeric code for the High Level Term (HLT) in the MedDRA hierarchy above the PT. Used for grouping related PTs in aggregate safety analyses and signal detection.. Valid values are `^[0-9]{8}$`',
    `hlt_name` STRING COMMENT 'Descriptive text of the MedDRA High Level Term (HLT) corresponding to hlt_code. Supports mid-level grouping in safety tabulations and DSMB/DMC review packages.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record represents the current (active) MedDRA coding assignment for the associated adverse event. Set to false for superseded coding records retained for historical audit trail.',
    `is_sae` BOOLEAN COMMENT 'Indicates whether the adverse event associated with this MedDRA coding record meets the regulatory definition of a Serious Adverse Event (SAE) per ICH E2A criteria (death, life-threatening, hospitalization, disability, congenital anomaly, or other',
    `is_susar` BOOLEAN COMMENT 'Indicates whether this adverse event has been classified as a Suspected Unexpected Serious Adverse Reaction (SUSAR), requiring expedited regulatory reporting (7-day or 15-day) to health authorities. Sourced from the source system case classification.',
    `llt_code` STRING COMMENT 'Eight-digit MedDRA numeric code for the Lowest Level Term (LLT) assigned to the verbatim adverse event term. The LLT is the most granular level of the MedDRA hierarchy and is the primary coding target. Sourced from the source system MedDRA dictionary.. Valid values are `^[0-9]{8}$`',
    `llt_name` STRING COMMENT 'Descriptive text of the MedDRA Lowest Level Term (LLT) corresponding to llt_code. Provides the human-readable label for the most granular MedDRA coding level. Sourced from the source system MedDRA dictionary.',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for this coding assignment (e.g., 26.0, 26.1). Critical for regulatory submissions as coding must reference the specific MedDRA version in use at the time of the submission.. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `previous_pt_code` STRING COMMENT 'The MedDRA PT code that was previously assigned before a recoding event. Populated only when coding_method = recoded. Enables before/after comparison for coding change impact analysis and regulatory audit.. Valid values are `^[0-9]{8}$`',
    `previous_soc_code` STRING COMMENT 'The MedDRA SOC code that was previously assigned before a recoding event. Populated only when coding_method = recoded. Enables assessment of whether a recoding changed the SOC-level classification, which may affect regulatory safety tables.. Valid values are `^[0-9]{8}$`',
    `primary_soc_flag` BOOLEAN COMMENT 'Indicates whether this SOC assignment is the primary (true) or secondary (false) SOC for the PT. MedDRA PTs may be linked to multiple SOCs; the primary SOC is used for standard regulatory safety tables. Sourced from the source system',
    `pt_code` STRING COMMENT 'Eight-digit MedDRA numeric code for the Preferred Term (PT) to which the LLT maps. The PT is the primary level used for regulatory reporting, safety queries, and signal detection. Sourced from the source system. Valid values are `^[0-9]{8}$`',
    `pt_name` STRING COMMENT 'Descriptive text of the MedDRA Preferred Term (PT) corresponding to pt_code. Used as the standard term in regulatory submissions, CIOMS forms, and safety narratives.',
    `recoding_reason` STRING COMMENT 'Free-text justification provided by the coder when a previously assigned MedDRA code is revised (coding_method = recoded). Required for audit trail integrity and regulatory inspection readiness. Null when coding_method is not recoded.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp at which this MedDRA coding record was first created in the data lakehouse Silver layer. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp at which this MedDRA coding record was last modified in the data lakehouse Silver layer. Tracks the most recent update for change detection, incremental processing, and audit trail compliance.',
    `soc_code` STRING COMMENT 'Eight-digit MedDRA numeric code for the System Organ Class (SOC), the highest level of the MedDRA hierarchy. SOC is the primary axis for organizing adverse events in regulatory safety tables (e.g., Table 14.3.1 in ICH E3 CSR).. Valid values are `^[0-9]{8}$`',
    `soc_name` STRING COMMENT 'Descriptive text of the MedDRA System Organ Class (SOC) corresponding to soc_code. Used as the primary grouping header in all regulatory safety tabulations, PSUR/PBRER narratives, and DSMB reports.',
    `verbatim_term` STRING COMMENT 'The exact, unmodified adverse event term as reported by the investigator or subject in the source document or eCRF prior to MedDRA coding. Preserved for ALCOA+ compliance and audit trail. Sourced from the source system verbatim field.',
    CONSTRAINT pk_ae_meddra_coding PRIMARY KEY(`ae_meddra_coding_id`)
) COMMENT 'Stores the MedDRA coding assignment for each adverse event, capturing the verbatim term reported, the coded Lowest Level Term (LLT), Preferred Term (PT), High Level Term (HLT), High Level Group Term (HLGT), and System Organ Class (SOC).';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` (
    `causality_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for each causality assessment record in the Silver layer lakehouse. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the adverse event record for which this causality assessment is being performed. Links the assessment to the parent AE in the source system',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: causality_assessment evaluates the relationship between an AE and the IMP. The MedDRA-coded term is essential context for causality assessors to evaluate temporal relationship',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Causality assessments are arm-specific — the treatment arm determines which investigational product and dose the subject received. Unblinded causality reviews for DSMB require arm context.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: Causality assessment requires authoritative dispensing data (exact dose, formulation, timing) per ICH E2A guidelines.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Causality assessment requires the exact dosing regimen (dose level, frequency, escalation step) to evaluate temporal relationship and dose-response.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Causality assessments require enrollment population context (safety population flag, ITT flag, randomization date) for regulatory reporting stratification in CSRs.',
    `investigational_product_id` BIGINT COMMENT 'Reference to the investigational product (drug, biologic, or device) being assessed for causal relationship to the adverse event.',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Causality assessments evaluate AE-drug relationships using lab evidence (e.g., liver function tests, renal markers).',
    `prior_assessment_causality_assessment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the immediately preceding causality assessment record that this revision supersedes. Null for original (first) assessments. Enables full revision chain reconstruction.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Causality assessors must evaluate whether a protocol deviation (wrong dose, wrong timing) is an alternative explanation for the AE rather than the investigational product.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study protocol under which the adverse event occurred and this causality assessment was conducted.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject was enrolled and the adverse event was reported.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Causality assessment explicitly evaluates temporal relationship between treatment and AE onset, requiring the authoritative randomization record.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: Causality assessments use eCRF visit data (concomitant medications, medical history, lab results).',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: PBRER Section 16 and DSUR require causality assessments aggregated by treatment arm.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) for whom the adverse event and causality assessment applies.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Causality assessments are performed at specific visits (e.g., end-of-treatment, unscheduled safety visit).',
    `alternative_explanation` STRING COMMENT 'Free-text description of alternative causes considered by the assessor (e.g., concomitant medications, underlying disease, concurrent procedures). Documents the differential diagnosis reasoning supporting the causality determination.',
    `argus_case_number` STRING COMMENT 'The case number assigned by the source system to the parent safety case containing this causality assessment. Enables direct traceability back to the source system for audit and regulatory purposes.',
    `argus_workflow_state` STRING COMMENT 'The workflow routing state of the causality assessment within the source system at the time of data extraction (e.g., Open, Closed, Submitted, Archived). Supports reconciliation between the lakehouse Silver layer and the source system.',
    `assessment_date` DATE COMMENT 'The calendar date on which the causality assessment was performed or last confirmed by the assessor. Used to track compliance with expedited reporting timelines (e.g., 7-day/15-day clock).',
    `assessment_number` STRING COMMENT 'Externally-known business identifier for this causality assessment record, typically generated by the source system (e.g., CA-2024-00123). Used for cross-system traceability and regulatory correspondence.',
    `assessment_status` STRING COMMENT 'Current workflow state of the causality assessment record within the source system Tracks progression from initial draft through regulatory submission. Superseded indicates a newer revision exists.. Valid values are `draft|submitted|confirmed|revised|superseded|withdrawn`',
    `assessor_role` STRING COMMENT 'The professional role of the individual performing the causality assessment. Distinguishes between the Principal Investigator (PI) site-level assessment and the Sponsor Medical Monitors independent assessment, as required by ICH E2A and GCP guidelines.. Valid values are `investigator|sponsor_medical_monitor|independent_reviewer|dsmb_member|regulatory_authority`',
    `causality_category` STRING COMMENT 'The assessors determination of the causal relationship between the investigational product and the adverse event. Standard WHO/ICH causality categories used in the source system and regulatory submissions.. Valid values are `unrelated|unlikely|possible|probable|definite|not_assessable`',
    `causality_category_code` STRING COMMENT 'Standardized short code for the causality category used in CDISC SDTM AE domain submissions and the source system exports (UN=Unrelated, UL=Unlikely, PO=Possible, PR=Probable, DE=Definite, NA=Not Assessable).. Valid values are `UN|UL|PO|PR|DE|NA`',
    `concomitant_medication_flag` BOOLEAN COMMENT 'Indicates whether this causality assessment pertains to a concomitant medication (True) rather than the primary investigational product (False). Enables differentiation of IP-related versus concomitant drug-related assessments within the same AE case.',
    `concomitant_medication_name` STRING COMMENT 'Name of the concomitant medication being assessed for causal relationship when concomitant_medication_flag is True. Populated from WHO Drug Dictionary (WHO-DD) preferred drug name.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this causality assessment record was first created in the source system (the source system Supports ALCOA+ audit trail requirements and regulatory inspection readiness.',
    `dechallenge_result` STRING COMMENT 'Outcome observed when the investigational product was withdrawn (dechallenged) following the adverse event. A positive dechallenge (AE resolved or improved upon withdrawal) supports a causal relationship. Captured per ICH E2A causality criteria.. Valid values are `positive|negative|not_applicable|unknown`',
    `dsmb_review_date` DATE COMMENT 'The date on which the DSMB/DMC formally reviewed this causality assessment during a scheduled or ad hoc safety review meeting.',
    `dsmb_reviewed` BOOLEAN COMMENT 'Indicates whether this causality assessment was reviewed by the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) as part of a formal safety review. Supports DSMB/DMC meeting documentation and regulatory oversight.',
    `expectedness` STRING COMMENT 'Determination of whether the adverse event is listed in the current Investigators Brochure (IB) or Reference Safety Information (RSI) as a known effect of the investigational product. Drives SUSAR classification and expedited reporting obligations.. Valid values are `expected|unexpected|unknown`',
    `expedited_report_required` BOOLEAN COMMENT 'Indicates whether this causality assessment triggers an obligation for expedited regulatory reporting (7-day or 15-day report) to health authorities such as FDA, EMA, or PMDA based on SUSAR classification.',
    `is_revised` BOOLEAN COMMENT 'Indicates whether this causality assessment is a revision of a previously submitted assessment. True when the assessor has changed their causality determination after initial submission, triggering regulatory follow-up reporting obligations.',
    `rationale_narrative` STRING COMMENT 'Free-text clinical narrative provided by the assessor explaining the reasoning behind the causality determination. Includes consideration of temporal relationship, biological plausibility, dechallenge/rechallenge results, and alternative explanations.',
    `rechallenge_result` STRING COMMENT 'Outcome observed when the investigational product was re-administered (rechallenged) after the adverse event resolved. A positive rechallenge (AE recurred) provides strong evidence of causal relationship. Captured per ICH E2A causality criteria.. Valid values are `positive|negative|not_applicable|unknown`',
    `report_due_date` DATE COMMENT 'Calculated deadline date by which the expedited regulatory report (SUSAR/IND safety report) must be submitted to health authorities. Derived from the date of first awareness plus the applicable reporting timeline.',
    `reporting_timeline_days` BIGINT COMMENT 'The applicable expedited reporting timeline in calendar days from the date of first awareness of the SUSAR (typically 7 days for fatal/life-threatening or 15 days for other serious unexpected reactions). Drives compliance monitoring.',
    `revision_number` BIGINT COMMENT 'Sequential revision version number for this causality assessment. Starts at 1 for the original assessment and increments with each revision. Enables audit trail tracking of assessment changes over the case lifecycle.',
    `signal_detection_flag` BOOLEAN COMMENT 'Indicates whether this causality assessment has been flagged for inclusion in pharmacovigilance signal detection analysis within the source system Supports aggregate safety review and cumulative causality trend monitoring.',
    `source_record_reference` STRING COMMENT 'The native record identifier from the source system (the source system case assessment ID or Medidata Rave record ID) for this causality assessment. Enables bidirectional traceability between the lakehouse Silver layer and the operational system.',
    `sponsor_causality_category` STRING COMMENT 'The Sponsor Medical Monitors independent causality determination, captured separately from the investigators assessment. When sponsor_causality_override is True,. Valid values are `unrelated|unlikely|possible|probable|definite|not_assessable`',
    `sponsor_causality_override` BOOLEAN COMMENT 'Indicates whether the Sponsor Medical Monitors causality determination differs from (overrides) the Investigators assessment. When True, both assessments are retained and the sponsors determination governs regulatory reporting obligations per ICH E2A.',
    `susar_flag` BOOLEAN COMMENT 'Indicates whether this adverse event has been classified as a Suspected Unexpected Serious Adverse Reaction (SUSAR) based on the combination of seriousness, causality (at least possible), and unexpectedness criteria.',
    `temporal_relationship` STRING COMMENT 'Assessment of whether the timing between investigational product administration and adverse event onset is consistent with a causal relationship. A key criterion in WHO and ICH causality assessment frameworks.. Valid values are `compatible|incompatible|unknown`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this causality assessment record was most recently modified in the source system. Tracks the latest change for audit trail compliance and Silver layer incremental load processing.',
    `who_dd_drug_code` STRING COMMENT 'WHO Drug Dictionary standardized drug code for the product (investigational or concomitant) being assessed. Enables cross-study signal detection and regulatory pharmacovigilance reporting.',
    CONSTRAINT pk_causality_assessment PRIMARY KEY(`causality_assessment_id`)
) COMMENT 'Records the investigator and sponsor medical monitor causality assessments for each adverse event relative to the investigational product and concomitant medications.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`narrative` (
    `narrative_id` BIGINT COMMENT 'Unique surrogate identifier for the safety narrative record in the Databricks Silver Layer. Primary key for this data product.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Safety narratives are written for SAEs and SUSARs, which are adverse events. While safety_narrative already has icsr_id → icsr → adverse_event, a direct adverse_event_id FK is essential',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: narrative carries six redundant MedDRA fields (meddra_llt_code, meddra_pt_code, meddra_pt_term, meddra_soc_code, meddra_soc_term, meddra_version) that are authoritatively stored in',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: Narratives reference the specific eCRF form (AE/SAE form) from which safety event data was collected.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Safety narratives require enrollment context (randomization date, first dose date, population flags) for case chronology and regulatory report completeness per ICH E2B ICSR requirements.',
    `icsr_id` BIGINT COMMENT 'Reference to the parent safety case (SAE or SUSAR) for which this narrative is authored. Links to the safety case master record in the source system',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: Regulatory case narratives per ICH E2B(R3) and FDA guidance must identify the site where the event occurred. safety_narrative has no site FK despite describing site-specific events.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Safety narratives for ICSRs and SAEs must reference the protocol version under which the event occurred. ICH E2B(R3) narrative format requires protocol reference.',
    `safety_narrative_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Safety narratives are formal ICSR components filed as TMF documents. Medical writers and pharmacovigilance teams need to link the narrative record to its TMF-filed version for audit',
    `serious_adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.serious_adverse_event. Business justification: The narrative product description explicitly states it stores clinical narratives for SAEs and SUSARs.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this safety narrative was generated.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: Safety narratives are authored using source eCRF visit data; medical writers and safety physicians reference subject_visit_data to verify accuracy of event descriptions',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.susar. Business justification: The narrative product description explicitly states it stores clinical narratives for SAEs and SUSARs.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) associated with this safety narrative. Links to the subject master record.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Safety narratives must reference specific visit context where AE was reported/assessed.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.withdrawal. Business justification: Safety narratives for cases where the subject withdrew must reference the withdrawal record.',
    `ae_onset_date` DATE COMMENT 'Date on which the adverse event first began, as reported by the investigator or subject. Critical for calculating reporting timelines and for CDISC SDTM AE domain mapping.',
    `ae_outcome` STRING COMMENT 'Coded outcome of the adverse event at the time of narrative authoring or case closure. Aligns with ICH E2B(R3) outcome codes and CDISC SDTM AE.AEOUT controlled terminology.. Valid values are `recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown`',
    `ae_resolution_date` DATE COMMENT 'Date on which the adverse event resolved or stabilized. Null if the event is ongoing at the time of narrative authoring. Used to determine event duration and outcome status.',
    `approval_date` DATE COMMENT 'Date on which the medical monitor formally approved the final version of the safety narrative for regulatory submission. Represents the final lifecycle milestone before submission.',
    `argus_case_number` STRING COMMENT 'The externally-known case number assigned by the source system to the adverse event case. Used as the primary business identifier for cross-system traceability and regulatory submissions.',
    `authoring_date` DATE COMMENT 'Date on which the safety narrative was initially authored or drafted. Supports ALCOA+ audit trail requirements and version history tracking.',
    `case_summary` STRING COMMENT 'High-level executive summary of the safety case, synthesizing the patient description, event, treatment, and outcome into a concise paragraph suitable for inclusion in the ICSR narrative field of E2B(R3) submissions.',
    `case_type` STRING COMMENT 'Classification of the safety case for which this narrative is written. SAE = Serious Adverse Event; SUSAR = Suspected Unexpected Serious Adverse Reaction; AE = Adverse Event; AESI = Adverse Event of Special Interest.. Valid values are `SAE|SUSAR|AE|AESI`',
    `causality_assessment` STRING COMMENT 'Medical monitors or investigators assessment of the causal relationship between the investigational product and the adverse event. Used in regulatory reporting and signal detection.. Valid values are `related|not_related|possibly_related|probably_related|unassessable`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this safety narrative record was first created in the system. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record requirements.',
    `ctcae_grade` BIGINT COMMENT 'Common Terminology Criteria for Adverse Events (CTCAE) severity grade assigned to the adverse event (1=Mild, 2=Moderate, 3=Severe, 4=Life-threatening, 5=Death). Used for safety signal detection and regulatory reporting.',
    `ctcae_version` STRING COMMENT 'Version of the NCI Common Terminology Criteria for Adverse Events used for severity grading in this narrative (e.g., 5.0). Ensures consistency in grading across study sites and regulatory submissions.. Valid values are `^[0-9]+.[0-9]+$`',
    `dsmb_review_date` DATE COMMENT 'Date on which the DSMB or DMC reviewed this safety case. Populated only when dsmb_reviewed is True. Used to track safety oversight compliance.',
    `dsmb_reviewed` BOOLEAN COMMENT 'Indicates whether this safety case and its narrative have been reviewed by the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC). True if reviewed; False if not yet presented to the DSMB/DMC.',
    `e2b_message_reference` STRING COMMENT 'Unique message identifier assigned to the ICSR transmission in E2B(R3) XML format as submitted via eCTD to health authorities. Enables traceability between the narrative record and the regulatory submission artifact.',
    `event_description` STRING COMMENT 'Detailed narrative describing the onset, nature, severity, and clinical course of the adverse event or serious adverse event, including signs, symptoms, and diagnostic findings. Core narrative section for ICSR submissions.',
    `expedited_report_due_date` DATE COMMENT 'Regulatory deadline by which the expedited safety report (ICSR) must be submitted to health authorities. Calculated from the date of first awareness per ICH E2A (7-day for fatal/life-threatening; 15-day for other serious unexpected).',
    `expedited_report_submitted_date` DATE COMMENT 'Actual date on which the expedited safety report (ICSR) was submitted to the relevant health authority via eCTD/E2B(R3) format. Used to verify compliance with regulatory reporting timelines.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether the narrative was authored under blinded conditions (True) or after unblinding of treatment assignment (False). Critical for maintaining study integrity in double-blind trials; blinded narratives must not reveal treatment allocation.',
    `medical_monitor_commentary` STRING COMMENT 'Clinical commentary and causality assessment provided by the medical monitor, including their opinion on the relationship between the investigational product and the adverse event, and any recommendations for protocol amendments or safety actions.',
    `medical_monitor_name` STRING COMMENT 'Full name of the medical monitor or safety physician who reviewed and approved the safety narrative. Required for regulatory audit trail and ICSR submission accountability.',
    `narrative_status` STRING COMMENT 'Current workflow status of the safety narrative document. Tracks progression from initial authoring through medical monitor review and approval to regulatory submission. superseded indicates a newer version has replaced this record.. Valid values are `draft|under_review|approved|submitted|superseded`',
    `outcome_description` STRING COMMENT 'Narrative section describing the resolution or current status of the adverse event, including recovery details, sequelae, or death information. Corresponds to the outcome field in E2B(R3) regulatory submissions.',
    `regulatory_authority_notified` STRING COMMENT 'Pipe-delimited list of regulatory authorities to which this safety report was submitted (e.g., FDA|EMA|PMDA|MHRA). Supports multi-jurisdictional compliance tracking.',
    `report_type` STRING COMMENT 'Indicates whether this narrative supports an initial expedited report, a follow-up report with updated information, or a final report closing the case. Drives regulatory submission timelines under ICH E2A.. Valid values are `initial|follow_up|final`',
    `review_date` DATE COMMENT 'Date on which the medical monitor or safety physician completed their clinical review of the narrative. Distinct from the authoring date; marks the transition from draft to reviewed status.',
    `seriousness_criteria` STRING COMMENT 'Pipe-delimited list of ICH E2A seriousness criteria met by the adverse event (e.g., death|life_threatening|hospitalization|disability|congenital_anomaly|medically_significant). Determines expedited reporting obligations.',
    `source_document_reference` STRING COMMENT 'Reference identifier or path to the source documents (e.g., hospital records, lab reports, investigator notes) used to author this narrative, as stored in Veeva Vault eTMF. Supports SDV and audit trail requirements.',
    `subject_description` STRING COMMENT 'Structured narrative section describing the patients relevant medical history, demographics (age, sex, weight), concomitant medications, and pre-existing conditions relevant to the adverse event. Contains protected health information (PHI).',
    `treatment_description` STRING COMMENT 'Narrative section describing the investigational product(s) and concomitant medications administered, including dose, route, frequency, start and stop dates, and any dose modifications or interruptions relevant to the adverse event.',
    `unblinding_date` DATE COMMENT 'Date on which the treatment assignment was unblinded for this subject in the context of this safety case. Populated only when is_blinded transitions to False. Relevant for causality re-assessment post-unblinding.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this safety narrative record was most recently modified. Supports ALCOA+ audit trail, version control, and 21 CFR Part 11 electronic record requirements.',
    `version` BIGINT COMMENT 'Sequential version number of the safety narrative document, incremented each time the narrative is revised. Version 1 is the initial draft; subsequent versions reflect amendments or follow-up updates.',
    CONSTRAINT pk_narrative PRIMARY KEY(`narrative_id`)
) COMMENT 'Stores the structured clinical narrative for SAEs and SUSARs, including case summary, patient description, event description, treatment details, outcome, and medical monitor commentary.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`icsr` (
    `icsr_id` BIGINT COMMENT 'Unique surrogate identifier for the Individual Case Safety Report (ICSR) record in the Databricks Silver Layer. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the source adverse event or serious adverse event record in the safety.adverse_event product from which this ICSR was generated.',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: icsr carries redundant MedDRA fields (meddra_pt_code, meddra_soc_code, meddra_version) that are authoritatively stored in ae_meddra_coding.',
    `causality_assessment_id` BIGINT COMMENT 'Foreign key linking to safety.causality_assessment. Business justification: An ICSR must document the causality assessment (relatedness to IMP) as a core regulatory requirement per ICH E2A guidelines. icsr has no direct FK to causality_assessment.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU ICSRs are submitted to EudraVigilance under the specific CTA. The ICSR must reference the CTA for CTIS reporting compliance, member-state notification tracking, and',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: ICSRs require drug administration details (dose, route, dates) directly from the dispensing record for E2B submission.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Each ICSR is filed to fulfill a specific regulatory reporting obligation. icsr.reporting_obligation_type is a STRING that should be normalized to a FK.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: ICSRs are generated from data captured on specific eCRF forms. Regulatory submissions require traceability from the ICSR back to the source data collection instrument; health',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: ICSR E2B submissions require enrollment date, randomization date, first dose date as mandatory data elements per ICH E2B R3 specification.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: ICSRs are submitted to specific health authorities. Linking icsr to health_authority normalizes the regulatory_agency field and enables ICSR submission tracking by authority',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: ICSR (E2B) regulatory submissions require precise IMP identification including formulation, strength, and route.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: ICSRs are filed under specific IND applications per FDA 21 CFR 312.32 requirements.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: ICSRs are submitted for a specific investigational product. Protocol-level IP context (IND number, mechanism of action, development phase) is required for ICH E2B(R3) ICSR',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: ICSRs submitted to FDA (MedWatch), EMA (EudraVigilance), and other authorities must identify the reporting site per ICH E2B(R3).',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: ICH E2B(R3) ICSR format mandates batch/lot number as a required drug characterization field in electronic submissions to health authorities.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: ICSRs submitted to health authorities via EudraVigilance and FDA FAERS require protocol reference. ICH E2B(R3) ICSR format includes protocol identifier fields.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Expedited ICSRs (15-day/7-day safety reports) are compiled into regulatory binders for health authority submissions (FDA, EMA).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this ICSR, linking the safety report to the sponsoring trial.',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.susar. Business justification: An ICSR (Individual Case Safety Report) is the formal regulatory submission for a SUSAR. icsr.is_susar flag exists but no direct FK to the susar record.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) who experienced the adverse event triggering this ICSR.',
    `acknowledgement_date` DATE COMMENT 'The date on which the regulatory agency formally acknowledged receipt of the ICSR submission. For electronic submissions via EudraVigilance or FDA gateway, this is the date of the automated acknowledgement message (ACK).',
    `acknowledgement_number` STRING COMMENT 'The unique reference number or message ID returned by the regulatory agency in the acknowledgement (ACK) message confirming receipt of the ICSR. Used for reconciliation and proof of submission.',
    `applicable_deadline_date` DATE COMMENT 'The operative regulatory deadline date for this specific ICSR, reflecting the applicable reporting window (7-day or 15-day) based on the seriousness criteria and expectedness of the adverse event. Used for compliance monitoring.',
    `argus_case_number` STRING COMMENT 'The unique case identifier assigned by the source system to the source safety case from which this ICSR was generated. Used for traceability back to the system of record.',
    `awareness_date` DATE COMMENT 'The date on which the sponsor or CRO first became aware of the adverse event that triggered this ICSR. This is the regulatory clock start date (Day 0) from which all expedited reporting deadlines (7-day and 15-day) are calculated per ICH E2A.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this ICSR record was first created in the source system and ingested into the Databricks Silver Layer. Supports audit trail and ALCOA+ data integrity requirements.',
    `deadline_15day_date` DATE COMMENT 'The calculated calendar date by which a serious unexpected adverse reaction (non-fatal/non-life-threatening SUSAR) must be submitted to the regulatory agency, computed as awareness_date + 15 calendar days per ICH E2A.',
    `deadline_7day_date` DATE COMMENT 'The calculated calendar date by which a fatal or life-threatening unexpected SUSAR must be submitted to the regulatory agency, computed as awareness_date + 7 calendar days per ICH E2A.',
    `delay_reason` STRING COMMENT 'Free-text explanation documenting the reason why the ICSR was not submitted within the applicable regulatory deadline. Required for late submissions to support CAPA processes and regulatory inspection readiness.',
    `dsmb_notified` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) was notified of this ICSR. Required for studies with an active DSMB charter.',
    `irb_iec_notification_date` DATE COMMENT 'The date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was formally notified of this ICSR. Used for compliance tracking against GCP notification requirements.',
    `irb_iec_notified` BOOLEAN COMMENT 'Indicates whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) overseeing the study was notified of this ICSR, as required by GCP and applicable regulations.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record represents the most current version of the ICSR. True for the latest version; False for superseded versions retained for audit history.',
    `is_fatal` BOOLEAN COMMENT 'Indicates whether the adverse event associated with this ICSR resulted in the death of the subject. Fatal cases trigger the 7-day expedited reporting clock per ICH E2A.',
    `is_life_threatening` BOOLEAN COMMENT 'Indicates whether the adverse event associated with this ICSR was life-threatening (i.e., the subject was at immediate risk of death). Life-threatening cases trigger the 7-day expedited reporting clock per ICH E2A.',
    `is_on_time` BOOLEAN COMMENT 'Indicates whether the ICSR was submitted to the regulatory agency on or before the applicable regulatory deadline date. True = compliant submission; False = late submission. Key KPI for regulatory compliance monitoring.',
    `is_susar` BOOLEAN COMMENT 'Indicates whether this ICSR relates to a Suspected Unexpected Serious Adverse Reaction (SUSAR). SUSARs require expedited reporting to regulatory authorities and ethics committees under ICH E2A and EU CTR 536/2014.',
    `narrative` STRING COMMENT 'The structured free-text clinical narrative summarizing the adverse event, patient information, treatment details, and outcome as included in the ICSR submission. Corresponds to ICH E2B(R3) H.1 narrative section.',
    `rejection_reason` STRING COMMENT 'The reason provided by the regulatory agency when an ICSR submission is rejected (e.g., data validation failure, duplicate case, missing mandatory fields). Populated only when submission_status = rejected.',
    `report_number` STRING COMMENT 'The externally-known, unique regulatory report identifier assigned to this ICSR submission (e.g., the E2B message identifier or MedWatch report number). Used by health authorities to track and acknowledge the submission.',
    `report_type` STRING COMMENT 'Indicates whether this ICSR is an initial submission, a follow-up update with new information, or a nullification (withdrawal) of a previously submitted report. Aligns with ICH E2B(R3) A.1.6.. Valid values are `initial|follow-up|nullification`',
    `report_version` BIGINT COMMENT 'Sequential version number of this ICSR record. Version 1 is the initial report; subsequent versions represent follow-up or amended submissions for the same case.',
    `sender_identifier` STRING COMMENT 'The unique identifier of the organization or individual sending the ICSR to the regulatory agency, as defined in ICH E2B(R3) A.3.1. Typically the sponsor or CRO EudraVigilance/FDA sender ID.',
    `submission_date` DATE COMMENT 'The actual calendar date on which the ICSR was transmitted to the regulatory agency. Used to calculate days-to-submission and determine on-time compliance against the applicable deadline.',
    `submission_method` STRING COMMENT 'The technical format or channel used to transmit the ICSR to the regulatory agency. E2B XML is the standard electronic format per ICH E2B(R3); MedWatch and CIOMS I are paper/PDF formats used for specific agencies or fallback scenarios.. Valid values are `E2B(R3) XML|E2B(R2) XML|MedWatch|CIOMS I|Gateway|Manual`',
    `submission_status` STRING COMMENT 'Current workflow state of the ICSR submission lifecycle. Tracks progression from internal drafting through regulatory acknowledgement or rejection.. Valid values are `draft|pending|submitted|acknowledged|rejected|nullified`',
    `submission_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone) at which the ICSR was electronically transmitted to the regulatory agency gateway. Provides audit-grade precision beyond the submission date for 21 CFR Part 11 compliance.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this ICSR record was most recently modified in the source system or the Databricks Silver Layer. Supports change tracking and ALCOA+ data integrity requirements.',
    CONSTRAINT pk_icsr PRIMARY KEY(`icsr_id`)
) COMMENT 'Individual Case Safety Report (ICSR) — the formal regulatory submission record for expedited safety reporting to health authorities (FDA, EMA, PMDA, MHRA).';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`signal` (
    `signal_id` BIGINT COMMENT 'Unique surrogate identifier for the safety signal record in the Databricks Silver Layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Safety signals are detected for a specific investigational product (pipeline asset).',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Safety signals are often arm-specific (active vs. placebo). Signal detection and evaluation reports require treatment arm context. DSMB unblinded signal reviews require protocol arm attribution.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Safety signals meeting regulatory notification thresholds must be reported to specific health authorities (e.g., FDA, EMA).',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: Signal detection and management is product-centric; pharmacovigilance teams aggregate signals by IMP for DSUR Section 16 and PBRER.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Safety signals are IP-specific. The protocol-level investigational_product provides mechanism of action, therapeutic class, and IND context needed for signal evaluation and',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Safety signals are frequently panel-specific (hepatic panel, renal panel, hematology panel).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Safety signal management reports reference the protocol version. Protocol amendments may be triggered by signals.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this safety signal. Links the signal to the study protocol under which the signal was detected.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Safety signals are detected and evaluated at treatment-arm level (active vs. placebo disproportionality).',
    `argus_signal_reference` STRING COMMENT 'Native signal identifier assigned by the source system signal detection and evaluation module. Used for traceability back to the source system of record.',
    `benefit_risk_summary` STRING COMMENT 'Narrative summary of the benefit-risk assessment conducted as part of signal evaluation. Captures the medical monitors or safety committees conclusion on whether the signal alters the overall benefit-risk profile of the investigational product.',
    `case_count` BIGINT COMMENT 'Total number of adverse event cases contributing to the safety signal at the time of detection or most recent evaluation. Represents the volume of evidence supporting the signal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this safety signal record was first created in the system. Supports audit trail requirements and data lineage tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `data_reviewed_summary` STRING COMMENT 'Summary of the data sources and datasets reviewed during signal evaluation, including case narratives, aggregate safety data, literature, and clinical trial data from Medidata Rave or SAS Drug Development outputs.',
    `signal_description` STRING COMMENT 'Detailed narrative describing the nature of the safety signal, including the observed drug-event association, population affected, and clinical context. Supports medical monitor review and regulatory reporting.',
    `detection_date` DATE COMMENT 'Date on which the safety signal was first identified or flagged, either by automated detection algorithms in the source system or by a medical monitor during clinical review. Critical for regulatory reporting timelines.',
    `detection_method` STRING COMMENT 'Method used to detect the safety signal. Includes quantitative pharmacovigilance methods such as Proportional Reporting Ratio (PRR), Reporting Odds Ratio (ROR), Bayesian Confidence Propagation Neural Network (BCPNN), disproportionality analysis, clinical',
    `dsmb_recommendation` STRING COMMENT 'Formal recommendation issued by the DSMB/DMC following their review of the safety signal. Drives sponsor and investigator actions regarding study continuation, protocol modification, or suspension.. Valid values are `continue|modify_protocol|suspend|terminate|increase_monitoring|no_action`',
    `dsmb_review_date` DATE COMMENT 'Date on which the DSMB/DMC reviewed this safety signal. Null if not yet reviewed or not referred. Used to track DSMB meeting schedules and signal review timelines.',
    `evaluation_completion_date` DATE COMMENT 'Date on which the formal evaluation of the safety signal was completed and a final disposition was reached. Null if evaluation is still in progress.',
    `evaluation_cycle_number` BIGINT COMMENT 'Sequential cycle number for the current evaluation of this safety signal. Supports multiple evaluation cycles as new data emerges (e.g., Cycle 1 = initial evaluation, Cycle 2 = re-evaluation after new cases).',
    `evaluation_due_date` DATE COMMENT 'Target due date for completing the signal evaluation, based on signal priority and applicable regulatory timelines (e.g., 30 days for high-priority signals per EMA GVP Module IX). Used for SLA tracking and escalation.',
    `evaluation_plan` STRING COMMENT 'Narrative description of the planned approach for evaluating the safety signal, including data sources to be reviewed, analyses to be conducted, and timelines. Documented in the source system evaluation module.',
    `evaluation_start_date` DATE COMMENT 'Date on which formal evaluation of the safety signal was initiated. Used to track evaluation timelines against regulatory and internal SOP requirements.',
    `final_disposition` STRING COMMENT 'Final outcome of the signal evaluation process. Indicates whether the signal was validated as a new risk, validated as a change in known risk, refuted as not a true signal, requires further monitoring, or requires no action.. Valid values are `validated_new_risk|validated_change_in_risk|refuted|requires_further_monitoring|no_action_needed`',
    `is_dsmb_referred` BOOLEAN COMMENT 'Indicates whether this safety signal has been referred to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for independent review. True = referred; False = not referred.',
    `is_expedited_reporting_required` BOOLEAN COMMENT 'Indicates whether this safety signal triggers expedited regulatory reporting obligations (e.g., 7-day or 15-day IND safety report to FDA, or SUSAR report to EMA). True = expedited reporting required; False = routine reporting.',
    `is_susar_related` BOOLEAN COMMENT 'Indicates whether this safety signal is associated with one or more Suspected Unexpected Serious Adverse Reactions (SUSARs). True = SUSAR-related; False = not SUSAR-related. Relevant for expedited regulatory reporting obligations.',
    `meddra_pt_code` STRING COMMENT 'MedDRA Preferred Term (PT) code representing the primary adverse event term associated with the safety signal. Standardized coding per MedDRA hierarchy for regulatory submissions and signal tracking.. Valid values are `^[0-9]{8}$`',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class (SOC) code for the primary adverse event term associated with the safety signal. Used for signal categorization and aggregate safety reporting.. Valid values are `^[0-9]{8}$`',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for coding the adverse event terms associated with this safety signal (e.g., 26.1). Required for regulatory submissions to ensure coding consistency.. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `number` STRING COMMENT 'Human-readable, externally-known business identifier for the safety signal (e.g., SIG-2024-00123). Used in regulatory correspondence, DSMB/DMC reports, and cross-functional communications.. Valid values are `^SIG-[0-9]{4}-[0-9]{5}$`',
    `priority` STRING COMMENT 'Priority level assigned to the safety signal based on clinical seriousness, signal strength, and potential public health impact. Drives evaluation timelines and resource allocation.. Valid values are `critical|high|medium|low`',
    `regulatory_action_recommended` STRING COMMENT 'Regulatory action recommended as a result of signal evaluation. Options include label update (update Investigator Brochure or product label), Direct Healthcare Professional Communication (DHPC), study suspension, protocol amendment, risk minimization',
    `regulatory_action_status` STRING COMMENT 'Current implementation status of the recommended regulatory action. Tracks whether the recommended action (e.g., label update, protocol amendment) has been initiated, completed, or determined not required.. Valid values are `pending|in_progress|completed|not_required`',
    `regulatory_report_due_date` DATE COMMENT 'Deadline by which the regulatory safety report (e.g., IND safety report, SUSAR report) must be submitted to the relevant health authority (FDA, EMA, MHRA, PMDA, etc.) based on the signals seriousness and expectedness.',
    `signal_status` STRING COMMENT 'Current lifecycle status of the safety signal in the evaluation workflow. Tracks progression from initial detection through evaluation to final disposition.. Valid values are `new|under_evaluation|validated|refuted|ongoing_monitoring|closed`',
    `strength_lower_ci` DECIMAL(10,4) COMMENT 'Lower bound of the 95% confidence interval for the signal strength metric value. A lower CI > 1 (for PRR/ROR) or > 0 (for IC) typically indicates a statistically significant signal.',
    `strength_metric_name` STRING COMMENT 'Name of the quantitative disproportionality metric used to measure signal strength (e.g., PRR - Proportional Reporting Ratio, ROR - Reporting Odds Ratio, BCPNN IC - Information Component, EBGM - Empirical Bayes Geometric Mean).. Valid values are `PRR|ROR|BCPNN_ic|EBGM|chi_squared|none`',
    `strength_value` DECIMAL(10,4) COMMENT 'Numeric value of the signal strength metric (e.g., PRR = 3.45, ROR = 4.12, IC = 2.1). Used to quantify the degree of disproportionate reporting and support signal validation decisions.',
    `title` STRING COMMENT 'Concise human-readable title describing the safety signal (e.g., Potential hepatotoxicity signal with Study Drug X). Used in dashboards, DSMB/DMC agendas, and regulatory submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this safety signal record was most recently modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_signal PRIMARY KEY(`signal_id`)
) COMMENT 'Master record for identified safety signals and their full evaluation lifecycle. Captures signal description, detection method (disproportionality analysis, PRR, ROR, BCPNN, clinical review, literature), detection date, data source, signal strength';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` (
    `signal_evaluation_id` BIGINT COMMENT 'Unique surrogate identifier for each signal evaluation record in the Databricks Silver Layer. Primary key for the signal_evaluation data product. Entity role: TRANSACTION_HEADER — captures the formal evaluation workflow lifecycle for a detected safety',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Signal evaluations are often arm-specific (e.g., signal in active arm only). Protocol arm context is needed for benefit-risk assessment reports.',
    `causality_assessment_id` BIGINT COMMENT 'Foreign key linking to safety.causality_assessment. Business justification: signal_evaluation has a causality_assessment string field that duplicates structured causality data.',
    `dsmb_review_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_review. Business justification: signal_evaluation tracks the formal evaluation workflow for a safety signal, which may be referred to the DSMB/DMC for review.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: Signal evaluations assess whether a signal affects a specific study endpoint (e.g., a safety endpoint triggers the signal). Benefit-risk assessment reports require endpoint context.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Signal evaluations resulting in regulatory notifications must reference the specific health authority notified.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: Signal evaluations are frequently initiated using interim analysis data packages — the interim analysis provides case counts, statistical context, and unblinded data for signal',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Signal evaluations assess benefit-risk for a specific investigational product.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Signal evaluations determine if protocol amendments are required (signal_evaluation.protocol_amendment_required flag). The evaluation must reference the current protocol version.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Signal evaluations requiring protocol changes trigger protocol amendments (protocol_amendment_required flag on signal_evaluation).',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: Signal evaluations are conducted by reviewing specific SDTM dataset versions (AE, exposure, lab domains).',
    `signal_id` BIGINT COMMENT 'Reference to the parent safety signal record that triggered this evaluation. A single signal may have multiple evaluation cycles as new data emerges.',
    `statistical_endpoint_id` BIGINT COMMENT 'Foreign key linking to biostatistics.statistical_endpoint. Business justification: Signal evaluations assess whether a detected safety signal affects a specific statistical endpoint.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this signal evaluation. Links the evaluation to the specific trial protocol under which the signal was detected.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Signal evaluations resulting in regulatory action generate formal submissions. Linking signal_evaluation to its submission replaces the denormalized expedited_report_submitted_date and',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Signal evaluation reports are formal GVP Module IX documents filed in the TMF. Each completed signal evaluation cycle produces a report that must be traceable in the TMF for regulatory',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Signal evaluations assess whether a safety signal is arm-specific, which is a core regulatory requirement for signal management (ICH E2E).',
    `argus_signal_evaluation_number` STRING COMMENT 'Externally-known business identifier for this signal evaluation as assigned by the source system Used for cross-system traceability and regulatory correspondence. Serves as the BUSINESS_IDENTIFIER for this TRANSACTION_HEADER.',
    `benefit_risk_assessment_summary` STRING COMMENT 'Narrative summary of the benefit-risk assessment conducted during this evaluation cycle, documenting the clinical judgment on the balance between therapeutic benefit and identified safety risk.',
    `benefit_risk_conclusion` STRING COMMENT 'Formal conclusion of the benefit-risk assessment for this evaluation cycle. Drives downstream regulatory action decisions.. Valid values are `favorable|unfavorable|inconclusive|requires_further_evaluation`',
    `case_count_reviewed` BIGINT COMMENT 'Total number of adverse event cases reviewed during this signal evaluation cycle. Provides a quantitative measure of the evidence base examined.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this signal evaluation record was first created in the system. RECORD_AUDIT_CREATED for TRANSACTION_HEADER role. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `data_sources_reviewed` STRING COMMENT 'Description of the data sources reviewed during this evaluation, such as clinical trial databases, spontaneous report databases (FAERS, EudraVigilance), published literature, and DSMB/DMC reports.',
    `dsmb_dmc_recommendation` STRING COMMENT 'Formal recommendation issued by the DSMB or DMC following their independent review of the referred signal evaluation. Populated only when a DSMB/DMC review has been completed.. Valid values are `continue|modify_protocol|suspend|terminate|no_recommendation`',
    `dsmb_dmc_referral_date` DATE COMMENT 'Date on which the signal evaluation was formally referred to the DSMB or DMC for independent safety review. Populated only when is_dsmb_dmc_referral is True.',
    `evaluation_completion_date` DATE COMMENT 'Date on which the formal signal evaluation was completed and conclusions were finalized. Marks the end of the evaluation lifecycle for this cycle.',
    `evaluation_cycle_number` BIGINT COMMENT 'Sequential cycle number for this evaluation of the signal (e.g., 1 for initial evaluation, 2 for re-evaluation after new data). Supports tracking of iterative evaluation rounds for the same signal.',
    `evaluation_initiated_date` DATE COMMENT 'The date on which the formal signal evaluation process was initiated. Serves as the principal BUSINESS_EVENT_TIMESTAMP for this transaction, marking the start of the regulatory evaluation clock.',
    `evaluation_outcome` STRING COMMENT 'Final outcome determination of the signal evaluation cycle. Indicates whether the signal was confirmed as a new safety finding, refuted by the evidence, or requires ongoing monitoring.. Valid values are `signal_confirmed|signal_refuted|signal_ongoing|new_signal_identified|no_action_required`',
    `evaluation_plan_description` STRING COMMENT 'Narrative description of the evaluation plan, including the scope of data to be reviewed, analytical approach, and objectives for this evaluation cycle.',
    `evaluation_status` STRING COMMENT 'Current lifecycle state of the signal evaluation workflow. Tracks progression from initiation through completion. LIFECYCLE_STATUS for TRANSACTION_HEADER role.. Valid values are `initiated|in_progress|pending_review|completed|closed|superseded`',
    `expedited_report_due_date` DATE COMMENT 'Regulatory deadline by which the expedited safety report (e.g., SUSAR) must be submitted to the relevant authority. Calculated from the awareness date per ICH E2A timelines (7 or 15 calendar days).',
    `expedited_reporting_required` BOOLEAN COMMENT 'Indicates whether this signal evaluation triggers an expedited regulatory reporting obligation (e.g., SUSAR 7-day or 15-day report). True = expedited reporting required.',
    `health_authority_query_reference` STRING COMMENT 'Reference number assigned by a regulatory authority (FDA, EMA, MHRA, etc.) for any formal query or request for information related to this signal evaluation. Enables traceability of regulatory correspondence.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record represents the current active version of the signal evaluation. True = current version; False = superseded version. Supports slowly changing dimension (SCD) pattern in the Silver Layer.',
    `is_dsmb_dmc_referral` BOOLEAN COMMENT 'Indicates whether this signal evaluation has been referred to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for independent review. True = referred; False = not referred.',
    `is_susar` BOOLEAN COMMENT 'Indicates whether the safety signal under evaluation has been classified as a Suspected Unexpected Serious Adverse Reaction (SUSAR), triggering specific expedited reporting obligations under ICH E2A.',
    `meddra_pt_code` STRING COMMENT 'MedDRA Preferred Term code representing the primary adverse event or medical concept under evaluation. Used for standardized coding and regulatory reporting alignment.. Valid values are `^[0-9]{8}$`',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class code for the primary adverse event under evaluation. Supports aggregate safety reporting by organ system.. Valid values are `^[0-9]{8}$`',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for coding the signal evaluation (e.g., 26.0). Ensures reproducibility and regulatory traceability of coding decisions.. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `protocol_amendment_required` BOOLEAN COMMENT 'Indicates whether this signal evaluation has resulted in a recommendation to amend the study protocol (e.g., dose modification, additional safety monitoring, exclusion criteria update).',
    `regulatory_action_justification` STRING COMMENT 'Narrative justification for the recommended regulatory action, documenting the clinical and scientific rationale supporting the recommendation.',
    `regulatory_action_recommended` STRING COMMENT 'Formal regulatory action recommended as an outcome of this signal evaluation. Options include label update, Direct Healthcare Professional Communication (DHPC), study suspension, protocol amendment, Risk Management Plan (RMP) update, or urgent safety',
    `risk_minimization_measure` STRING COMMENT 'Risk minimization measure recommended or implemented as a result of this signal evaluation. Supports Risk Management Plan (RMP) updates and regulatory commitments.. Valid values are `routine_pharmacovigilance|additional_monitoring|rmp_update|educational_material|restricted_access|none`',
    `signal_detection_method` STRING COMMENT 'Statistical or clinical methodology used to detect the safety signal prior to this evaluation. Examples include disproportionality analysis (PRR, ROR), data mining algorithms, or clinical case series review.. Valid values are `disproportionality_analysis|clinical_review|data_mining|literature_review|regulatory_request|dsmb_dmc_referral`',
    `signal_source` STRING COMMENT 'Origin of the safety signal that triggered this evaluation. Identifies whether the signal arose from spontaneous adverse event reports, clinical trial data, published literature, a regulatory authority communication, or DSMB/DMC review.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this signal evaluation record was last modified. RECORD_AUDIT_UPDATED for TRANSACTION_HEADER role. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `version` BIGINT COMMENT 'Version number of this evaluation record, incremented each time the evaluation is updated or revised. Supports audit trail and version control per ALCOA+ principles.',
    CONSTRAINT pk_signal_evaluation PRIMARY KEY(`signal_evaluation_id`)
) COMMENT 'Transactional record capturing the formal evaluation workflow for a safety signal, including evaluation plan, data reviewed, benefit-risk assessment, regulatory action recommended (label update, DHPC, study suspension, protocol amendment), evaluation';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` (
    `dsmb_review_id` BIGINT COMMENT 'Unique surrogate identifier for each DSMB/DMC review record in the safety governance system. Primary key for the dsmb_review data product.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: DSMB reviews are conducted on a defined analysis population (e.g., safety population, all-treated).',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: DSMB reviews operate under a specific blinding configuration defining the committees unblinded access level.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: A DSMB review is conducted under a specific charter version that defines stopping rules, alpha spending, and quorum requirements.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: DSMB reviews are conducted on data packages prepared at a specific database lock.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: DSMB data packages are prepared according to the DMP which defines data standards and review procedures.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.epoch. Business justification: DSMB reviews are triggered by epoch milestones (e.g., end of treatment epoch, interim analysis epoch). The study_phase_reviewed attribute on dsmb_review is a denormalization of epoch context.',
    `health_authority_id` BIGINT COMMENT 'Reference to the safety oversight committee (DSMB, DMC, IDMC, or internal SRC) that conducted this review. Links to the committee master record.',
    `interim_analysis_id` BIGINT COMMENT 'Reference to the formal interim analysis record associated with this DSMB/DMC review, if applicable. Links safety governance to the statistical interim analysis conducted per the Statistical Analysis Plan (the source system).',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: DSMB reviews assess benefit-risk for a specific investigational product. Protocol-level IP context (mechanism of action, development phase, IND number) is required for DSMB',
    `primary_dsmb_tmf_document_id` BIGINT COMMENT 'Document identifier for the official DSMB/DMC meeting minutes stored in the electronic Trial Master File (eTMF) system (Veeva Vault). Provides traceability to the formal meeting record.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: DSMB reviews are conducted against a specific protocol version. The DSMB charter references the protocol.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: DSMB reviews are conducted against a specific randomization scheme version governing blinding level, stratification, and allocation.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.dsmb_meeting. Business justification: safety.dsmb_review and biostatistics.dsmb_meeting represent the same real-world DSMB event from safety and statistical perspectives respectively.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: DSMB data packages are prepared from specific SDTM dataset versions. The dsmb_review must reference the dataset version reviewed for audit trail and reproducibility; DSMB charters',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: dsmb_review has safety_signal_identified (BOOLEAN) and safety_signal_description (STRING) but no FK to the safety_signal record.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this DSMB/DMC review was conducted. Links the safety oversight record to the parent study master.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: DSMB reviews requiring regulatory notification generate formal submissions. Linking dsmb_review to its regulatory submission enables tracking of sponsor regulatory responses to DSMB',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: DSMB charters mandate arm-level safety review — cumulative SAE counts, stopping rules, and benefit-risk assessments are evaluated per treatment arm.',
    `argus_safety_case_ref` STRING COMMENT 'Reference identifier linking this DSMB/DMC review to related safety cases or aggregate safety reports in the source system Enables cross-referencing between safety governance decisions and individual case safety reports.',
    `charter_version` STRING COMMENT 'Version identifier of the DSMB/DMC charter document in effect at the time of this review (e.g., v1.0, v2.1). Ensures traceability to the governing charter under which the review was conducted.. Valid values are `^vd+.d+$`',
    `closed_session_held` BOOLEAN COMMENT 'Indicates whether a closed (confidential, unblinded) session was held during the DSMB/DMC meeting, attended only by committee members and the unblinded statistician (True = closed session held; False = no closed session).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DSMB/DMC review record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `data_cutoff_date` DATE COMMENT 'The date through which clinical data was included in the unblinded safety data package reviewed by the DSMB/DMC. Defines the temporal scope of the safety data under review.',
    `data_package_version` STRING COMMENT 'Version identifier of the unblinded safety data package provided to the DSMB/DMC for this review. Ensures traceability between the committees recommendation and the exact data snapshot reviewed.',
    `implementation_date` DATE COMMENT 'Date on which the sponsor implemented the DSMB/DMC recommendation (e.g., date study was suspended, protocol amendment was issued, or continuation was confirmed). Used for regulatory timeline compliance tracking.',
    `is_independent` BOOLEAN COMMENT 'Indicates whether the committee is fully independent of the sponsor and investigator team (True = independent; False = internal/non-independent). Independence is a key regulatory requirement for unblinded safety reviews.',
    `meeting_date` DATE COMMENT 'Calendar date on which the DSMB/DMC review meeting was held. This is the principal business event date for the review record and is used for regulatory timeline tracking.',
    `meeting_number` BIGINT COMMENT 'Sequential ordinal number of this DSMB/DMC meeting within the study (e.g., 1 = first meeting, 2 = second meeting). Used to track the progression of safety oversight across the study lifecycle.',
    `meeting_type` STRING COMMENT 'Classification of the DSMB/DMC meeting format and trigger. Scheduled = pre-planned per charter; Ad hoc = convened outside regular schedule; Emergency = triggered by urgent safety signal; Teleconference = remote meeting; Written review = asynchronous. Valid values are `scheduled|ad_hoc|emergency|teleconference|written_review`',
    `members_present_count` BIGINT COMMENT 'Number of DSMB/DMC committee members who attended and participated in this review meeting. Used to verify quorum compliance and document meeting validity.',
    `next_review_date` DATE COMMENT 'Date of the next scheduled DSMB/DMC review meeting as recommended by the committee or defined in the charter. Used for proactive scheduling and safety oversight continuity planning.',
    `open_session_held` BOOLEAN COMMENT 'Indicates whether an open (non-confidential) session was held during the DSMB/DMC meeting, typically attended by the sponsor and investigators (True = open session held; False = closed session only).',
    `protocol_amendment_required` BOOLEAN COMMENT 'Indicates whether the DSMB/DMC recommendation requires a protocol amendment to be submitted to the IRB/IEC and regulatory authorities (True = amendment required; False = no amendment required). Triggers the protocol amendment workflow.',
    `quorum_achieved` BOOLEAN COMMENT 'Indicates whether the required quorum of DSMB/DMC members was present for the meeting to be valid per the committee charter (True = quorum met; False = quorum not met). Meetings without quorum may require rescheduling or written ratification.',
    `recommendation` STRING COMMENT 'The formal recommendation issued by the DSMB/DMC following the review. Continue = proceed without changes; Continue with modification = proceed with protocol or safety monitoring amendments; Suspend = temporary halt pending further review; Terminate =. Valid values are `continue|continue_with_modification|suspend|terminate|pause_enrollment|other`',
    `recommendation_rationale` STRING COMMENT 'Narrative explanation provided by the DSMB/DMC justifying the formal recommendation. Documents the safety findings, benefit-risk assessment, and reasoning that led to the committees decision.',
    `regulatory_notification_date` DATE COMMENT 'Date on which the regulatory authority was notified of the DSMB/DMC recommendation or safety findings. Populated only when regulatory_notification_required is True. Used for compliance with expedited reporting timelines.',
    `regulatory_notification_due_date` DATE COMMENT 'Deadline by which the regulatory authority must be notified per applicable regulations (e.g., 7-day or 15-day reporting window). Enables proactive compliance monitoring and escalation.',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether the DSMB/DMC recommendation or safety findings from this review require expedited regulatory notification to health authorities (True = notification required; False = no notification required).',
    `review_status` STRING COMMENT 'Current lifecycle status of the DSMB/DMC review record. Scheduled = meeting planned but not yet held; In progress = meeting underway or deliberations ongoing; Completed = recommendation issued and documented; Cancelled = meeting cancelled; Postponed =. Valid values are `scheduled|in_progress|completed|cancelled|postponed`',
    `safety_signal_identified` BOOLEAN COMMENT 'Indicates whether the DSMB/DMC identified a new or emerging safety signal during this review that requires further investigation or monitoring (True = signal identified; False = no new signal).',
    `sponsor_response` STRING COMMENT 'The sponsors formal response to the DSMB/DMC recommendation. Accepted = sponsor will implement as recommended; Accepted with modification = sponsor accepts intent but modifies implementation; Rejected = sponsor disagrees and provides counter-rationale. Valid values are `accepted|accepted_with_modification|rejected|under_review|pending`',
    `sponsor_response_rationale` STRING COMMENT 'Narrative explanation of the sponsors response to the DSMB/DMC recommendation, particularly required when the sponsor rejects or modifies the recommendation. Documents the sponsors benefit-risk reasoning.',
    `stopping_rule_description` STRING COMMENT 'Description of the specific pre-specified stopping rule that was triggered, if applicable (e.g., Futility boundary crossed at IA2, Excess SAE rate in treatment arm exceeds 15%). Populated only when stopping_rule_triggered is True.',
    `stopping_rule_triggered` BOOLEAN COMMENT 'Indicates whether a pre-specified stopping rule defined in the DSMB charter or Statistical Analysis Plan (the source system) was triggered at this review (True = stopping rule met; False = no stopping rule triggered). Critical for regulatory audit trail.',
    `study_phase_reviewed` STRING COMMENT 'Clinical development phase of the study at the time of the DSMB/DMC review. Determines the regulatory framework and risk thresholds applicable to the safety assessment.. Valid values are `Phase_I|Phase_II|Phase_III|Phase_IV|Phase_I_II|Phase_II_III`',
    `subjects_enrolled_count` BIGINT COMMENT 'Total number of subjects enrolled in the study at the time of the DSMB/DMC data cutoff. Provides context for the safety data volume reviewed and is a key metric in the committees benefit-risk assessment.',
    `subjects_exposed_count` BIGINT COMMENT 'Number of subjects who received at least one dose of investigational product at the time of the data cutoff. Used for exposure-adjusted safety rate calculations in the DSMB/DMC review.',
    `unblinded_statistician_present` BOOLEAN COMMENT 'Indicates whether the independent unblinded statistician was present at the DSMB/DMC meeting to present the unblinded safety data package (True = present; False = not present). Required for valid closed-session deliberations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this DSMB/DMC review record. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_dsmb_review PRIMARY KEY(`dsmb_review_id`)
) COMMENT 'Master record for Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) safety governance, covering both committee definition and individual review meetings.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` (
    `dsmb_recommendation_id` BIGINT COMMENT 'Unique surrogate identifier for each formal DSMB/DMC recommendation record in the safety domain. Entity role: TRANSACTION_HEADER — represents a discrete formal recommendation event issued by the DSMB/DMC following a safety review meeting.',
    `affected_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: DSMB stopping rules and arm-suspension recommendations target specific treatment arms.',
    `dsmb_review_id` BIGINT COMMENT 'Reference to the parent DSMB/DMC safety review meeting that generated this recommendation. A single review meeting may produce one or more recommendations.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.dsmb_meeting. Business justification: A DSMB recommendation is a direct output of a specific DSMB meeting. Linking recommendation to meeting enables TMF completeness checks, minutes reconciliation, and traceability of',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: DSMB recommendations mandate protocol amendments (dsmb_recommendation.protocol_amendment_required flag). The recommendation must reference the protocol version it applies to.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sap. Business justification: DSMB recommendations frequently mandate SAP revisions (e.g., stopping rules, sample size re-estimation).',
    `signal_evaluation_id` BIGINT COMMENT 'Foreign key linking to safety.signal_evaluation. Business justification: dsmb_recommendation is issued following a DSMB review that may have evaluated a safety signal.',
    `signal_id` BIGINT COMMENT 'Reference to the specific safety signal or aggregate safety finding in the source system that prompted or informed this DSMB/DMC recommendation. Nullable when the recommendation arises from routine scheduled review rather than a specific signal.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this DSMB/DMC recommendation was issued. Links the recommendation to the study protocol and sponsor context.',
    `tmf_document_id` BIGINT COMMENT 'Document identifier in Veeva Vault eTMF for the official DSMB/DMC recommendation letter or minutes filed in the Trial Master File. Ensures regulatory-compliant document traceability per ICH E6(R2) Section 8.',
    `affected_subject_population` STRING COMMENT 'Description of the subject population subgroup to which this recommendation applies (e.g., all enrolled subjects, subjects in a specific age cohort, subjects with a particular comorbidity). Supports targeted safety actions.',
    `argus_safety_case_number` STRING COMMENT 'Case number assigned in the source system to the safety case or aggregate safety report associated with this DSMB/DMC recommendation. Enables traceability between the recommendation and the underlying pharmacovigilance case management record.',
    `benefit_risk_summary` STRING COMMENT 'Concise summary of the DSMB/DMC benefit-risk assessment that underpins the recommendation, capturing the committees evaluation of the investigational products benefit profile relative to observed safety risks at the time of review.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this DSMB recommendation record was first captured in the data platform. Supports ALCOA+ data integrity requirements and audit trail compliance.',
    `dissenting_opinion` STRING COMMENT 'Narrative capturing any dissenting opinion(s) from DSMB/DMC members who did not agree with the majority recommendation. Documented for regulatory transparency and governance purposes when vote_outcome is split or majority.',
    `follow_up_review_date` DATE COMMENT 'Target date for the follow-up DSMB/DMC review meeting required to assess the outcome of actions taken in response to this recommendation. Populated when follow_up_review_required is True.',
    `follow_up_review_required` BOOLEAN COMMENT 'Indicates whether this recommendation requires a follow-up DSMB/DMC review meeting to assess implementation effectiveness or monitor evolving safety data. Drives scheduling of unscheduled interim reviews.',
    `implementation_date` DATE COMMENT 'Date on which the sponsor implemented the actions required by the DSMB/DMC recommendation (e.g., protocol amendment effective date, dose modification start date, study suspension date). Critical for regulatory compliance tracking.',
    `implementation_deadline` DATE COMMENT 'Regulatory or charter-mandated deadline by which the sponsor must implement the DSMB/DMC recommendation. Supports compliance monitoring and escalation workflows.',
    `informed_consent_update_required` BOOLEAN COMMENT 'Indicates whether this DSMB/DMC recommendation necessitates an update to the Informed Consent Form (ICF) to reflect new safety information. Triggers re-consent workflow in Clinpal eConsent system.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the IRB/IEC was formally notified of this DSMB/DMC recommendation. Required for audit trail and compliance verification against ICH E6(R2) and applicable regulations.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether this DSMB/DMC recommendation requires notification to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) overseeing the study. Required for significant safety findings and protocol changes.',
    `is_current_version` BOOLEAN COMMENT 'Boolean flag indicating whether this record represents the current active version of the recommendation. Set to False for superseded or amended versions retained for audit trail purposes.',
    `issue_date` DATE COMMENT 'Calendar date on which the DSMB/DMC formally issued this recommendation to the sponsor following the safety review meeting. This is the principal real-world business event date for the recommendation lifecycle.',
    `protocol_amendment_required` BOOLEAN COMMENT 'Indicates whether this DSMB/DMC recommendation requires a formal protocol amendment to be submitted to regulatory authorities and IRB/IEC for approval before implementation.',
    `rationale` STRING COMMENT 'Detailed narrative explanation of the scientific, clinical, and safety evidence basis for the DSMB/DMC recommendation. Includes reference to interim efficacy data, safety data, benefit-risk assessment, and any stopping rules triggered.',
    `recommendation_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to this recommendation, typically formatted as a sequential reference within the study (e.g., REC-2024-001). Used for regulatory correspondence, sponsor communications, and TMF filing.',
    `recommendation_status` STRING COMMENT 'Current lifecycle state of the DSMB/DMC recommendation from initial issuance through sponsor acceptance or rejection and final closure. Drives workflow routing in the source system and the source system',
    `recommendation_type` STRING COMMENT 'Formal classification of the DSMB/DMC recommendation issued following the safety review. Drives sponsor response obligations and regulatory notification requirements.. Valid values are `continue_unchanged|protocol_amendment_required|dose_modification|study_suspension|early_termination|other`',
    `recommendation_version` BIGINT COMMENT 'Version number of this recommendation record, incremented when the recommendation is amended or superseded. Supports version control and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `regulatory_agencies_notified` STRING COMMENT 'Comma-separated list of health authority agencies notified of this recommendation (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Supports multi-jurisdictional regulatory compliance tracking.',
    `regulatory_notification_date` DATE COMMENT 'Actual date on which the sponsor submitted the required regulatory notification to health authorities regarding this DSMB/DMC recommendation. Used to verify compliance with expedited reporting timelines.',
    `regulatory_notification_deadline` DATE COMMENT 'Regulatory deadline by which the sponsor must notify health authorities of this DSMB/DMC recommendation and any resulting study actions. Typically 7 or 15 calendar days depending on jurisdiction and recommendation type.',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether this DSMB/DMC recommendation triggers a mandatory regulatory notification obligation to health authorities (e.g., FDA, EMA, MHRA). True for recommendations involving study suspension, early termination, or significant safety findings.',
    `review_type` STRING COMMENT 'Classification of the DSMB/DMC review that generated this recommendation, distinguishing between planned interim analyses, unscheduled safety reviews triggered by emerging signals, annual reviews, and final study reviews.. Valid values are `scheduled_interim|unscheduled_interim|annual|final|ad_hoc`',
    `sponsor_response` STRING COMMENT 'Formal response of the study sponsor to the DSMB/DMC recommendation, indicating whether the recommendation has been accepted, rejected, or partially accepted. Drives implementation and regulatory notification workflows.. Valid values are `accepted|rejected|partially_accepted|under_review|pending`',
    `sponsor_response_date` DATE COMMENT 'Date on which the sponsor formally communicated their response (acceptance, rejection, or partial acceptance) to the DSMB/DMC recommendation. Used to calculate response timeliness against regulatory and charter obligations.',
    `sponsor_response_rationale` STRING COMMENT 'Narrative explanation provided by the sponsor for their response to the DSMB/DMC recommendation, particularly required when the recommendation is rejected or only partially accepted. Documented in the TMF.',
    `stopping_rule_description` STRING COMMENT 'Description of the specific pre-specified stopping rule that was triggered, including the boundary type (efficacy, futility, safety), the statistical threshold, and the observed test statistic or safety metric that crossed the boundary.',
    `stopping_rule_triggered` BOOLEAN COMMENT 'Indicates whether a pre-specified stopping rule defined in the Statistical Analysis Plan (the source system) or DSMB charter was formally triggered as the basis for this recommendation. True when a boundary (efficacy, futility, or safety) was crossed.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to this DSMB recommendation record. Required for change tracking, audit trail, and data lineage in the Silver Layer lakehouse.',
    `vote_outcome` STRING COMMENT 'Outcome of the DSMB/DMC committee vote that produced this recommendation, indicating whether the decision was unanimous, by majority, or resulted in a split vote. Relevant for regulatory transparency and committee governance documentation.. Valid values are `unanimous|majority|split|no_vote_required`',
    CONSTRAINT pk_dsmb_recommendation PRIMARY KEY(`dsmb_recommendation_id`)
) COMMENT 'Transactional record for formal DSMB/DMC recommendations issued following a safety review meeting. Captures recommendation type (continue unchanged, protocol amendment required, dose modification, study suspension, early termination), rationale, sponsor';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`dsur` (
    `dsur_id` BIGINT COMMENT 'Unique surrogate identifier for the Development Safety Update Report record in the lakehouse silver layer. Primary key for this entity.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: DSURs report cumulative safety data (SAE counts, subject exposure) for a defined analysis population (typically the safety population).',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: DSURs are prepared per investigational product/pipeline asset. Linking enables DSUR tracking across development phases by pipeline asset.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: DSURs in EU trials are filed under specific CTAs per EMA requirements.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: DSUR reporting periods are anchored to a specific database lock event. The data_lock_date on dsur corresponds to a formal database_lock_event record.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: The DSUR is prepared according to the DMP which defines data collection standards, coding conventions, and data quality criteria.',
    `dsmb_recommendation_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_recommendation. Business justification: A DSUR (Development Safety Update Report) must document DSMB/DMC recommendations as a regulatory requirement per ICH E2F.',
    `dsmb_review_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_review. Business justification: A DSUR (Development Safety Update Report) references the DSMB review conducted during the reporting period.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: DSURs are submitted to specific primary health authorities. Linking to health_authority normalizes the primary_health_authority field and enables DSUR submission tracking by',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: DSUR is fundamentally organized around the investigational product per ICH E2F. dsur.investigational_product_name and investigational_product_code are denormalized; FK to imp_master enables',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: DSURs are filed under specific IND applications as part of IND annual reporting requirements.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: DSURs are IP-level periodic safety reports per ICH E2F. The protocol-level investigational_product provides IND number, development phase, and regulatory approval status needed',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: DSURs are submitted per protocol per ICH E2F. The DSUR must reference the protocol version and development phase. Regulatory submissions require protocol reference.',
    `reconciliation_id` BIGINT COMMENT 'Foreign key linking to datamanagement.reconciliation. Business justification: DSUR preparation requires confirmed data reconciliation for the reporting period.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: DSURs are submitted to health authorities and included in regulatory binders (IND annual reports, CTA annual safety reports).',
    `safety_report_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.safety_report_submission. Business justification: DSURs are periodic safety reports filed as regulatory safety report submissions.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sap. Business justification: DSURs are authored using statistical methodology defined in the SAP. Regulatory agencies (EMA, FDA) require DSURs to reference the SAP version governing safety data summaries.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: DSURs are generated from SDTM datasets for the reporting period. ICH E2F requires the DSUR to document the data sources used; linking to the specific SDTM dataset version supports',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: DSURs are filed as formal regulatory submissions (eCTD sequences). Linking the DSUR to its regulatory submission record enables dossier traceability, submission timeline tracking, and',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: DSURs (Development Safety Update Reports) are periodic safety reports required by ICH E2F and are essential TMF documents.',
    `approved_timestamp` TIMESTAMP COMMENT 'The date and time at which this DSUR was formally approved by the sponsors qualified medical officer or pharmacovigilance responsible person, as recorded in the document management system.',
    `argus_periodic_report_reference` STRING COMMENT 'The internal report identifier assigned by the source system periodic reporting module, used to trace this DSUR back to its source system record.',
    `benefit_risk_conclusion` STRING COMMENT 'The sponsors overall benefit-risk conclusion for the investigational product based on the cumulative safety data reviewed in this DSUR, as required by ICH E2F.. Valid values are `favorable|unfavorable|inconclusive|under_review`',
    `benefit_risk_summary` STRING COMMENT 'Narrative text summarizing the sponsors benefit-risk assessment for the reporting period, including key safety findings, emerging signals, and overall conclusions as documented in the DSUR.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this DSUR record was first created in the system, providing the audit trail creation anchor per ALCOA+ data integrity principles.',
    `cumulative_sae_count` BIGINT COMMENT 'Total number of serious adverse events (SAEs) reported for the investigational product from program inception through the end of the reporting period, as captured in the source system',
    `cumulative_subject_exposure_count` BIGINT COMMENT 'Total number of subjects exposed to the investigational product from the inception of the development program through the end of the reporting period, representing the cumulative safety exposure denominator.',
    `cumulative_subject_exposure_days` BIGINT COMMENT 'Total patient-days of exposure to the investigational product accumulated across all studies from program inception through the reporting period end date, used as the denominator for incidence rate calculations.',
    `cumulative_susar_count` BIGINT COMMENT 'Total number of SUSARs (Suspected Unexpected Serious Adverse Reactions) reported from program inception through the reporting period end date, a key regulatory safety metric.',
    `data_lock_date` DATE COMMENT 'The database lock date on which safety data was frozen for inclusion in this DSUR. No new safety data is incorporated after this date for the current reporting period.',
    `development_phase` STRING COMMENT 'The clinical development phase of the investigational product at the time of this DSUR (e.g., Phase I, Phase II, Phase III), which contextualizes the safety data and benefit-risk assessment.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `dibd` DATE COMMENT 'The Development International Birth Date — the date of first approval of a Clinical Trial Application (CTA) or equivalent in any country, used as the anchor date for annual DSUR reporting cycles.',
    `dsmb_review_conducted` BOOLEAN COMMENT 'Indicates whether a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) review was conducted during the reporting period, with findings incorporated into this DSUR.',
    `fatal_sae_count` BIGINT COMMENT 'Number of serious adverse events with a fatal outcome reported during the reporting period, a critical safety metric for benefit-risk assessment and DSMB/DMC review.',
    `health_authority_acknowledgement_date` DATE COMMENT 'The date on which the health authority formally acknowledged receipt of the DSUR submission, used for regulatory compliance tracking and audit trail purposes.',
    `health_authority_query_received` BOOLEAN COMMENT 'Indicates whether the health authority issued a query or request for additional information in response to this DSUR submission, triggering a response workflow.',
    `medical_reviewer` STRING COMMENT 'Name or identifier of the qualified medical officer or pharmacovigilance physician who performed the medical review and sign-off of this DSUR prior to submission.',
    `new_safety_signal_identified` BOOLEAN COMMENT 'Indicates whether a new safety signal for the investigational product was identified during the reporting period, triggering additional signal management activities and potential regulatory notifications.',
    `ongoing_study_count` BIGINT COMMENT 'Number of clinical studies with the investigational product that were ongoing during the reporting period, providing context for the scope of the safety data.',
    `period_sae_count` BIGINT COMMENT 'Number of serious adverse events (SAEs) reported during the current annual reporting period, used to assess period-over-period safety trends.',
    `period_subject_exposure_count` BIGINT COMMENT 'Number of subjects exposed to the investigational product during the current annual reporting period only, used to assess period-specific safety signal rates.',
    `period_susar_count` BIGINT COMMENT 'Number of SUSARs reported during the current annual reporting period, used for expedited reporting compliance monitoring and signal detection.',
    `reference_safety_document_type` STRING COMMENT 'Type of reference safety information document used to assess expectedness of adverse reactions in this DSUR (e.g., IB = Investigators Brochure, CCSI = Company Core Safety Information, SmPC = Summary of Product Characteristics, USPI = US Prescribing. Valid values are `IB|CCSI|SmPC|USPI|RSI`',
    `reference_safety_document_version` STRING COMMENT 'Version number or edition of the reference safety document (e.g., Investigators Brochure edition) used as the basis for expectedness assessment in this DSUR.',
    `regulatory_action_taken` STRING COMMENT 'Significant regulatory or safety action taken during the reporting period as a result of safety findings (e.g., protocol amendment, Investigators Brochure update, study suspension).. Valid values are `none|protocol_amendment|ibr_update|study_suspension|study_termination|rmp_update`',
    `report_number` STRING COMMENT 'Externally-known sequential report number assigned to this DSUR (e.g., DSUR-2024-001), used for regulatory tracking and cross-referencing across submissions.',
    `report_status` STRING COMMENT 'Current lifecycle status of the DSUR document, tracking its progression from authoring through regulatory acceptance. [ENUM-REF-CANDIDATE: draft|under_review|approved|submitted|accepted|rejected|withdrawn — promote to reference product]',
    `report_version` STRING COMMENT 'Version number of the DSUR document (e.g., 1.0, 2.0), incremented upon amendments or corrections to a previously submitted report.. Valid values are `^[0-9]+.[0-9]+$`',
    `reporting_period_end_date` DATE COMMENT 'The last date of the annual reporting period covered by this DSUR, marking the data cut-off for safety data included in the report.',
    `reporting_period_start_date` DATE COMMENT 'The first date of the annual reporting period covered by this DSUR, typically the Development International Birth Date (DIBD) anniversary.',
    `submission_date` DATE COMMENT 'The actual date on which this DSUR was submitted to the primary health authority, used for regulatory compliance tracking and on-time submission KPI monitoring.',
    `submission_due_date` DATE COMMENT 'The regulatory deadline by which this DSUR must be submitted to health authorities, typically 60 days after the reporting period end date per ICH E2F.',
    `submission_format` STRING COMMENT 'The electronic or paper format used for the DSUR submission to health authorities (e.g., eCTD = Electronic Common Technical Document, NeeS = Non-eCTD Electronic Submission).. Valid values are `eCTD|NeeS|paper|eCTD_v4`',
    `therapeutic_area` STRING COMMENT 'The clinical therapeutic area or disease indication for which the investigational product is being developed (e.g., Oncology, Cardiology, Neurology), used for safety signal contextualization.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this DSUR record was last modified in the system, supporting audit trail and data lineage tracking per ALCOA+ principles.',
    CONSTRAINT pk_dsur PRIMARY KEY(`dsur_id`)
) COMMENT 'Development Safety Update Report (DSUR) — the annual periodic safety report submitted to health authorities summarizing cumulative safety data for an investigational product across all ongoing studies.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` (
    `ae_follow_up_id` BIGINT COMMENT 'Unique surrogate identifier for each adverse event follow-up record in the Silver layer lakehouse. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Reference to the parent adverse event record for which this follow-up update is being captured. Each follow-up belongs to exactly one adverse event.',
    `ae_meddra_coding_id` BIGINT COMMENT 'Foreign key linking to safety.ae_meddra_coding. Business justification: ae_follow_up carries four redundant MedDRA fields (updated_meddra_pt_code, updated_meddra_pt_name, updated_meddra_soc_code, updated_meddra_soc_name) representing recoding that',
    `causality_assessment_id` BIGINT COMMENT 'Foreign key linking to safety.causality_assessment. Business justification: ae_follow_up has an updated_causality_assessment string field that duplicates structured causality data.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: AE follow-up assessments track dechallenge_result and rechallenge_result, which require direct reference to the specific dispensing record to verify dose, timing, and compliance.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: AE follow-up data is captured on specific eCRF follow-up forms. Linking ae_follow_up to ecrf_form supports SDV workflows, data review, and audit trail requirements for follow-up',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: AE follow-up forms require enrollment context (ITT/PP population flags, enrollment date) for study day calculations and population-specific safety analysis per ICH E9 statistical',
    `icsr_id` BIGINT COMMENT 'Foreign key linking to safety.icsr. Business justification: ae_follow_up captures follow-up information that frequently triggers updated ICSR submissions (follow-up reports).',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site where the adverse event follow-up information was collected.',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: AE follow-up reports are frequently triggered by new lab results showing resolution or worsening of a lab-based AE (e.g., normalizing liver enzymes).',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: AE follow-up reports must reference the IMP batch dispensed at follow-up visits to assess dechallenge/rechallenge outcomes and determine if batch replacement is needed.',
    `narrative_id` BIGINT COMMENT 'Foreign key linking to safety.narrative. Business justification: ae_follow_up has a clinical_details_narrative string field that duplicates structured narrative data.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: AE follow-up reports must reference the protocol version to ensure correct reporting timelines and expectedness assessments. Protocol amendments may change follow-up requirements.',
    `safety_report_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.safety_report_submission. Business justification: AE follow-up reports generate follow-up safety report submissions to health authorities.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: AE follow-up visits routinely trigger new specimen collections to monitor AE resolution (e.g., repeat hepatic panel after liver enzyme elevation).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which the adverse event and this follow-up were reported.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: CRAs track open AE follow-up items per study-site during monitoring visits. Linking ae_follow_up to study_site enables study-site-level open follow-up tracking used in monitoring visit',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: AE follow-up data is collected at specific subject visits in the EDC. Linking ae_follow_up to subject_visit_data supports SDV of follow-up AE information and ensures data',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: AE follow-up reports (15-day and 7-day expedited follow-up ICSRs) are essential TMF documents under ICH E2A.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) who experienced the adverse event being followed up.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: AE follow-up requires subject_visit context for visit-based safety assessments and protocol-defined follow-up windows.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.withdrawal. Business justification: AE follow-up records document subject outcome including withdrawal. Linking ae_follow_up to withdrawal enables safety teams to track whether the subject withdrew during follow-up and',
    `argus_follow_up_case_number` STRING COMMENT 'The follow-up case number assigned by the source system for this follow-up iteration, used to track the follow-up submission within the pharmacovigilance system.',
    `awareness_date` DATE COMMENT 'The date on which the sponsor first became aware of the new follow-up information. Used to calculate regulatory reporting clock for follow-up Individual Case Safety Reports (ICSRs).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this follow-up record was first created in the system, providing the audit trail creation marker per 21 CFR Part 11 and ALCOA+ requirements.',
    `dechallenge_result` STRING COMMENT 'Updated result of dechallenge (withdrawal of the investigational product) as reported in this follow-up — whether the adverse event improved or resolved after stopping the drug. Key input to causality assessment.. Valid values are `positive|negative|not_applicable|unknown`',
    `dsmb_reported` BOOLEAN COMMENT 'Indicates whether the updated adverse event information in this follow-up was reported to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) for safety review.',
    `edc_follow_up_form_reference` STRING COMMENT 'Identifier of the follow-up eCRF (Electronic Case Report Form) entry in Medidata Rave EDC that corresponds to this follow-up record, enabling traceability between the lakehouse and the source EDC system.',
    `expedited_report_required` BOOLEAN COMMENT 'Indicates whether this follow-up triggers an expedited regulatory report (7-day or 15-day ICSR) to health authorities based on updated seriousness, causality, or SUSAR status.',
    `follow_up_date` DATE COMMENT 'The calendar date on which the follow-up information was received or documented by the sponsor or CRO. This is the principal real-world event date for this follow-up record.',
    `follow_up_sequence_number` BIGINT COMMENT 'Sequential number indicating the order of this follow-up relative to other follow-ups for the same adverse event (e.g., 1 = first follow-up, 2 = second follow-up). Supports chronological ordering of clinical updates.',
    `follow_up_status` STRING COMMENT 'Current workflow status of this follow-up record within the source system and the regulatory submission pipeline.. Valid values are `draft|submitted|acknowledged|rejected|superseded`',
    `follow_up_type` STRING COMMENT 'Categorizes the primary nature of the information being updated in this follow-up record (e.g., new clinical details, revised outcome, updated causality assessment).. Valid values are `clinical_update|outcome_update|causality_update|regulatory_update|narrative_update`',
    `hospitalization_end_date` DATE COMMENT 'Date on which the subject was discharged from hospitalization related to the adverse event, as reported or updated in this follow-up. Null if still hospitalized.',
    `hospitalization_start_date` DATE COMMENT 'Date on which the subject was hospitalized due to the adverse event, as reported or updated in this follow-up. Relevant when hospitalization is a seriousness criterion.',
    `investigator_assessment` STRING COMMENT 'Free-text summary of the Principal Investigators (PI) updated clinical assessment of the adverse event as provided in this follow-up, including any revised diagnosis or clinical interpretation.',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the IRB/IEC was notified of the updated adverse event information captured in this follow-up.',
    `irb_iec_notified` BOOLEAN COMMENT 'Indicates whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was notified of the updated adverse event information in this follow-up, as required by GCP.',
    `meddra_version` STRING COMMENT 'Version of the MedDRA dictionary used for coding the adverse event term in this follow-up record (e.g., 26.0, 26.1). Required for regulatory submissions.. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `rechallenge_result` STRING COMMENT 'Updated result of rechallenge (re-administration of the investigational product) as reported in this follow-up — whether the adverse event recurred upon re-exposure. Key input to causality assessment.. Valid values are `positive|negative|not_applicable|unknown`',
    `reporting_deadline_date` DATE COMMENT 'Calculated deadline date by which the follow-up ICSR must be submitted to the applicable regulatory authority, based on the awareness date and applicable reporting timeline (7 or 15 calendar days).',
    `resolution_date` DATE COMMENT 'Updated date on which the adverse event resolved or was determined to have resolved, as reported in this follow-up. Null if the event is ongoing.',
    `source_document_reference` STRING COMMENT 'Reference identifier for the source document (e.g., medical record, hospital discharge summary, lab report) that supports the follow-up information, used for Source Data Verification (SDV) and audit trail purposes.',
    `updated_action_taken` STRING COMMENT 'Revised action taken with the investigational product in response to the adverse event as reported in this follow-up (e.g., dose reduced, drug withdrawn). Aligns with ICH E2B(R3) field C.2.r.4.. Valid values are `dose_reduced|drug_withdrawn|dose_interrupted|not_applicable|unknown`',
    `updated_ae_term_verbatim` STRING COMMENT 'Revised verbatim (as-reported) term for the adverse event as provided by the investigator in this follow-up, prior to MedDRA coding. May differ from the original term if the clinical picture has evolved.',
    `updated_ctcae_grade` STRING COMMENT 'Revised severity grade assigned to the adverse event in this follow-up, per the NCI Common Terminology Criteria for Adverse Events (CTCAE). Grade 1=Mild, 2=Moderate, 3=Severe, 4=Life-threatening, 5=Death.. Valid values are `1|2|3|4|5`',
    `updated_expectedness` STRING COMMENT 'Revised assessment of whether the adverse event is expected (listed in the Investigators Brochure or product labeling) as of this follow-up. Expectedness is a key determinant of SUSAR classification.. Valid values are `expected|unexpected|not_assessable`',
    `updated_is_serious` BOOLEAN COMMENT 'Revised determination of whether the adverse event meets ICH E2A seriousness criteria as of this follow-up. A change from non-serious to serious triggers expedited regulatory reporting obligations.',
    `updated_is_susar` BOOLEAN COMMENT 'Revised determination of whether the adverse event qualifies as a Suspected Unexpected Serious Adverse Reaction (SUSAR) as of this follow-up. A change to SUSAR status triggers expedited 7-day or 15-day reporting obligations.',
    `updated_outcome` STRING COMMENT 'Revised outcome status of the adverse event as reported in this follow-up, reflecting the subjects current clinical condition relative to the event.. Valid values are `recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown`',
    `updated_seriousness_criteria` STRING COMMENT 'Revised seriousness criteria met by the adverse event as of this follow-up (e.g., death, life-threatening, hospitalization, disability, congenital anomaly, medically significant). May be a pipe-delimited list of applicable criteria.',
    `updated_severity` STRING COMMENT 'Updated narrative severity classification of the adverse event as assessed at the time of this follow-up, aligned with ICH E2A severity definitions.. Valid values are `mild|moderate|severe|life_threatening|fatal`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this follow-up record was last modified in the system, supporting audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+.',
    CONSTRAINT pk_ae_follow_up PRIMARY KEY(`ae_follow_up_id`)
) COMMENT 'Transactional record capturing follow-up information updates for an adverse event after the initial report, including updated severity grade, new causality assessment, additional clinical details, outcome update, and resolution date.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` (
    `dsur_signal_summary_id` BIGINT COMMENT 'Unique surrogate identifier for this DSUR-signal summary record',
    `dsur_id` BIGINT COMMENT 'Foreign key linking to the Development Safety Update Report that includes this signal summary',
    `signal_id` BIGINT COMMENT 'Foreign key linking to the safety signal being reported in this DSUR',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DSUR-signal summary record was created in the system, typically during DSUR authoring.',
    `dsmb_review_outcome_in_period` STRING COMMENT 'DSMB/DMC recommendation or outcome related to this signal during the DSUR reporting period, if reviewed. Captures period-specific DSMB guidance.',
    `dsur_narrative_section` STRING COMMENT 'Narrative text summarizing this signals evaluation and status for inclusion in the DSUR document. Authored by pharmacovigilance team during DSUR preparation.',
    `new_vs_ongoing_flag` BOOLEAN COMMENT 'Indicates whether this signal was newly identified during the DSUR reporting period (true) or was ongoing from a previous period (false). Critical for regulatory reporting to distinguish new safety concerns.',
    `period_case_count` BIGINT COMMENT 'Number of adverse event cases contributing to this signal that occurred during the DSUR reporting period. Distinct from the signals cumulative case count.',
    `regulatory_action_in_period` STRING COMMENT 'Description of any regulatory actions taken in response to this signal during the DSUR reporting period (e.g., IB update, protocol amendment, SUSAR reporting, labeling change, study suspension).',
    `reporting_period_signal_status` STRING COMMENT 'Status of the safety signal within this specific DSUR reporting period. Indicates whether the signal was newly detected, ongoing evaluation, closed, refuted, or confirmed during the period.',
    `signal_resolution_date_in_period` DATE COMMENT 'Date on which the signal was resolved (closed, refuted, or confirmed) within this DSUR reporting period. Null if signal remains under evaluation at period end.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this DSUR-signal summary record.',
    CONSTRAINT pk_dsur_signal_summary PRIMARY KEY(`dsur_signal_summary_id`)
) COMMENT 'This association product represents the periodic reporting relationship between a Development Safety Update Report (DSUR) and a safety signal. It captures the signals status, evaluation progress, and regulatory actions within a specific DSUR reporting';

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ADD CONSTRAINT `fk_safety_dsur_signal_summary_dsur_id` FOREIGN KEY (`dsur_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsur`(`dsur_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ADD CONSTRAINT `fk_safety_dsur_signal_summary_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER SCHEMA `clinical_trials_mvm`.`safety` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`safety` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` SET TAGS ('dbx_association_edges' = 'safety.dsur,safety.signal');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `dsur_signal_summary_id` SET TAGS ('dbx_business_glossary_term' = 'DSUR Signal Summary ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `dsmb_review_outcome_in_period` SET TAGS ('dbx_business_glossary_term' = 'DSMB Review Outcome in Period');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `dsur_narrative_section` SET TAGS ('dbx_business_glossary_term' = 'DSUR Narrative Section');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `new_vs_ongoing_flag` SET TAGS ('dbx_business_glossary_term' = 'New vs Ongoing Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `period_case_count` SET TAGS ('dbx_business_glossary_term' = 'Period Case Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `regulatory_action_in_period` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action in Period');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `reporting_period_signal_status` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Signal Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `signal_resolution_date_in_period` SET TAGS ('dbx_business_glossary_term' = 'Signal Resolution Date in Period');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur_signal_summary` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_severity_codelist_term_id` SET TAGS ('dbx_codelist' = 'AESEV');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_severity_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM AE.AESEV');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_outcome_codelist_term_id` SET TAGS ('dbx_codelist' = 'OUT');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_outcome_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM AE.AEOUT');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_action_taken_codelist_term_id` SET TAGS ('dbx_codelist' = 'ACN');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `adverse_action_taken_codelist_term_id` SET TAGS ('dbx_implements' = 'SDTM AE.AEACN');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `action_taken` SET TAGS ('dbx_business_glossary_term' = 'Action Taken with Investigational Product');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `action_taken` SET TAGS ('dbx_value_regex' = 'none|dose_reduced|dose_interrupted|drug_withdrawn|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_status` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_status` SET TAGS ('dbx_value_regex' = 'ongoing|resolved|resolved_with_sequelae|fatal|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_term_verbatim` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Verbatim Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_term_verbatim` SET TAGS ('dbx_verbatim' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_term_verbatim` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_term_verbatim` SET TAGS ('dbx_implements' = 'SDTM AE.AETERM');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_verbatim_term` SET TAGS ('dbx_business_glossary_term' = 'Verbatim Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_verbatim_term` SET TAGS ('dbx_cdisc' = 'verbatim');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_verbatim_term` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ae_verbatim_term` SET TAGS ('dbx_element' = '--TERM');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `argus_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `awareness_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Awareness Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Causality Assessment');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_value_regex' = 'unrelated|unlikely|possible|probable|definite|not_assessable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_dictionary' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_dictionary_version' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `concomitant_medication_related` SET TAGS ('dbx_business_glossary_term' = 'Concomitant Medication Relationship Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `dsmb_reported` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reported Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `edc_subject_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Subject Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Current Version Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `is_expected` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Expectedness Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `is_serious` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `is_susar` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `is_teae` SET TAGS ('dbx_business_glossary_term' = 'Treatment-Emergent Adverse Event (TEAE) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_llt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Lowest Level Term (LLT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_llt_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Lowest Level Term (LLT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_llt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_pt_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_pt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `medical_history_related` SET TAGS ('dbx_business_glossary_term' = 'Medical History Relationship Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `medical_history_related` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `medical_history_related` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `medical_history_related` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `narrative` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Medical Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `onset_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Onset Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `regulatory_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Expedited Report Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `regulatory_report_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Expedited Report Submission Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Report Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'initial|follow_up|final');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `seriousness_criteria` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Seriousness Criteria');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Severity');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'mild|moderate|severe|life_threatening|fatal');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `study_day_onset` SET TAGS ('dbx_business_glossary_term' = 'Study Day of Adverse Event (AE) Onset');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_implements' = 'SDTM AE.AETERM');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_verbatim' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Version Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `action_taken` SET TAGS ('dbx_business_glossary_term' = 'Action Taken with Investigational Product');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `action_taken` SET TAGS ('dbx_value_regex' = 'dose_reduced|drug_withdrawn|dose_interrupted|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `argus_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'SAE Blinding Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_business_glossary_term' = 'Investigator Causality Assessment');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_value_regex' = 'related|not_related|possibly_related|probably_related|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAE Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Severity Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `dsmb_reported` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reported Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `expectedness` SET TAGS ('dbx_business_glossary_term' = 'SAE Expectedness');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `expectedness` SET TAGS ('dbx_value_regex' = 'expected|unexpected|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `follow_up_number` SET TAGS ('dbx_business_glossary_term' = 'SAE Follow-Up Report Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `initial_report_date` SET TAGS ('dbx_business_glossary_term' = 'SAE Initial Report Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `is_susar` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `narrative` SET TAGS ('dbx_business_glossary_term' = 'SAE Case Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `narrative` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `narrative` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `narrative` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `onset_date` SET TAGS ('dbx_business_glossary_term' = 'SAE Onset Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `onset_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `onset_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `onset_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'SAE Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `outcome` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'SAE Report Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'expedited|periodic|spontaneous|literature');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `reporting_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Authority');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'SAE Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_status` SET TAGS ('dbx_business_glossary_term' = 'SAE Report Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_status` SET TAGS ('dbx_value_regex' = 'initial|follow_up|closed|nullified');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_term` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Verbatim Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_term` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_term` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `sae_term` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_congenital_anomaly` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Congenital Anomaly or Birth Defect');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_congenital_anomaly` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_congenital_anomaly` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_congenital_anomaly` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_death` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Death');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_death` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_death` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_death` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_disability` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Disability or Incapacity');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_disability` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_disability` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_disability` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_hospitalization` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Hospitalization');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_hospitalization` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_hospitalization` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_hospitalization` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_life_threatening` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Life-Threatening');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_life_threatening` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_life_threatening` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_life_threatening` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_medically_important` SET TAGS ('dbx_business_glossary_term' = 'Seriousness Criterion: Other Medically Important Condition');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_medically_important` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_medically_important` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `seriousness_medically_important` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAE Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `causality_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Causality Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `ae_term` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Verbatim Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `argus_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `awareness_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Awareness Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `blind_broken` SET TAGS ('dbx_business_glossary_term' = 'Blind Break Indicator');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `blind_status` SET TAGS ('dbx_business_glossary_term' = 'Study Blind Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `blind_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `case_number` SET TAGS ('dbx_business_glossary_term' = 'SUSAR Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `case_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{5,30}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Severity Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `deadline_15day` SET TAGS ('dbx_business_glossary_term' = '15-Day Expedited Reporting Deadline');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `deadline_7day` SET TAGS ('dbx_business_glossary_term' = '7-Day Expedited Reporting Deadline');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `dsmb_notified` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Indicator');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `eudravigilance_number` SET TAGS ('dbx_business_glossary_term' = 'EudraVigilance Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `expectedness_assessment` SET TAGS ('dbx_value_regex' = 'unexpected|expected');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `fatal_date` SET TAGS ('dbx_business_glossary_term' = 'Subject Death Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `follow_up_number` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Report Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Indicator');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `narrative` SET TAGS ('dbx_business_glossary_term' = 'Case Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `onset_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Onset Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Adverse Reaction Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'recovered|recovering|not_recovered|fatal|unknown|sequelae');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `reporting_clock_start_date` SET TAGS ('dbx_business_glossary_term' = 'Expedited Reporting Clock Start Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `reporting_status` SET TAGS ('dbx_business_glossary_term' = 'SUSAR Reporting Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `reporting_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|acknowledged|closed|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `submission_report_type` SET TAGS ('dbx_value_regex' = 'initial|follow_up|final');

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) MedDRA Coding ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `discrepancy_query_id` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Query Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `argus_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `argus_event_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Event ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coded_date` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coded_timestamp` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coding_comment` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Comment');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coding_method` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Method');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coding_method` SET TAGS ('dbx_value_regex' = 'auto|manual|auto_confirmed|recoded');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coding_status` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `coding_status` SET TAGS ('dbx_value_regex' = 'pending|coded|confirmed|rejected|under_review');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `confirmed_date` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Coding Confirmation Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `dictionary_language` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Dictionary Language');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `dictionary_language` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `dictionary_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlgt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA High Level Group Term (HLGT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlgt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlgt_name` SET TAGS ('dbx_business_glossary_term' = 'MedDRA High Level Group Term (HLGT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlgt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA High Level Term (HLT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlt_name` SET TAGS ('dbx_business_glossary_term' = 'MedDRA High Level Term (HLT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `hlt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Current Version Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `is_sae` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `is_susar` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `llt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Lowest Level Term (LLT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `llt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `llt_name` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Lowest Level Term (LLT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `llt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Dictionary Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `previous_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Previous MedDRA Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `previous_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `previous_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Previous MedDRA System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `previous_soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `primary_soc_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary System Organ Class (SOC) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `pt_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `pt_name` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Preferred Term (PT) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `pt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `recoding_reason` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Recoding Reason');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `soc_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `soc_name` SET TAGS ('dbx_business_glossary_term' = 'MedDRA System Organ Class (SOC) Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `soc_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_business_glossary_term' = 'Verbatim Adverse Event Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_prior_assessment_causality_assessment_id` FOREIGN KEY (`prior_assessment_causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `prior_assessment_causality_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Assessment ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `argus_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `argus_workflow_state` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Workflow State');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Causality Assessment Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|confirmed|revised|superseded|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `assessor_role` SET TAGS ('dbx_value_regex' = 'investigator|sponsor_medical_monitor|independent_reviewer|dsmb_member|regulatory_authority');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `causality_category` SET TAGS ('dbx_value_regex' = 'unrelated|unlikely|possible|probable|definite|not_assessable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `causality_category` SET TAGS ('dbx_ct_mapping' = 'leave_unmapped');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `causality_category_code` SET TAGS ('dbx_value_regex' = 'UN|UL|PO|PR|DE|NA');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `causality_category_code` SET TAGS ('dbx_ct_mapping' = 'leave_unmapped');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `concomitant_medication_flag` SET TAGS ('dbx_business_glossary_term' = 'Concomitant Medication Causality Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `concomitant_medication_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `dechallenge_result` SET TAGS ('dbx_value_regex' = 'positive|negative|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `dsmb_review_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `dsmb_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reviewed Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `expectedness` SET TAGS ('dbx_value_regex' = 'expected|unexpected|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `expedited_report_required` SET TAGS ('dbx_business_glossary_term' = 'Expedited Report Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `is_revised` SET TAGS ('dbx_business_glossary_term' = 'Is Revised Assessment Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `rationale_narrative` SET TAGS ('dbx_business_glossary_term' = 'Causality Rationale Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `rationale_narrative` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `rationale_narrative` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `rechallenge_result` SET TAGS ('dbx_value_regex' = 'positive|negative|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `reporting_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Timeline (Days)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `sponsor_causality_category` SET TAGS ('dbx_value_regex' = 'unrelated|unlikely|possible|probable|definite|not_assessable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `sponsor_causality_category` SET TAGS ('dbx_ct_mapping' = 'leave_unmapped');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `sponsor_causality_override` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Causality Override Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `susar_flag` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `temporal_relationship` SET TAGS ('dbx_value_regex' = 'compatible|incompatible|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ALTER COLUMN `who_dd_drug_code` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Drug Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_mvm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `narrative_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Narrative ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Case ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `safety_narrative_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Narrative Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ae_onset_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Onset Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ae_outcome` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ae_outcome` SET TAGS ('dbx_value_regex' = 'recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ae_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Narrative Approval Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `argus_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `authoring_date` SET TAGS ('dbx_business_glossary_term' = 'Narrative Authoring Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_summary` SET TAGS ('dbx_business_glossary_term' = 'Case Summary Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_summary` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_summary` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_summary` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_type` SET TAGS ('dbx_business_glossary_term' = 'Safety Case Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `case_type` SET TAGS ('dbx_value_regex' = 'SAE|SUSAR|AE|AESI');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `causality_assessment` SET TAGS ('dbx_value_regex' = 'related|not_related|possibly_related|probably_related|unassessable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'CTCAE Severity Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `dsmb_review_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `dsmb_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reviewed Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `e2b_message_reference` SET TAGS ('dbx_business_glossary_term' = 'E2B(R3) Message ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `e2b_message_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Description Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `event_description` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `event_description` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `event_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `expedited_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Expedited Regulatory Report Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `expedited_report_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Expedited Report Submission Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Narrative Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `is_blinded` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `medical_monitor_commentary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `medical_monitor_commentary` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `medical_monitor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `medical_monitor_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `medical_monitor_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `narrative_status` SET TAGS ('dbx_business_glossary_term' = 'Narrative Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `narrative_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|submitted|superseded');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `outcome_description` SET TAGS ('dbx_business_glossary_term' = 'Event Outcome Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `outcome_description` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `outcome_description` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `outcome_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'initial|follow_up|final');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Medical Review Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `subject_description` SET TAGS ('dbx_business_glossary_term' = 'Patient Description Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `subject_description` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `subject_description` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `subject_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `treatment_description` SET TAGS ('dbx_business_glossary_term' = 'Treatment Details Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `treatment_description` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `treatment_description` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `treatment_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Narrative Version Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Individual Case Safety Report (ICSR) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `causality_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Causality Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Reporting Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Acknowledgement Receipt Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `acknowledgement_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Acknowledgement Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `applicable_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Reporting Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `argus_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `awareness_date` SET TAGS ('dbx_business_glossary_term' = 'Clock Start Date (Date of First Awareness)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `deadline_15day_date` SET TAGS ('dbx_business_glossary_term' = '15-Day Expedited Reporting Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `deadline_7day_date` SET TAGS ('dbx_business_glossary_term' = '7-Day Expedited Reporting Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `delay_reason` SET TAGS ('dbx_business_glossary_term' = 'Reason for Submission Delay');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `dsmb_notified` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notified Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notified Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `is_fatal` SET TAGS ('dbx_business_glossary_term' = 'Fatal Outcome Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `is_life_threatening` SET TAGS ('dbx_business_glossary_term' = 'Life-Threatening Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `is_on_time` SET TAGS ('dbx_business_glossary_term' = 'On-Time Submission Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `is_susar` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `narrative` SET TAGS ('dbx_business_glossary_term' = 'ICSR Case Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'ICSR Rejection Reason');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'ICSR Report Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'ICSR Report Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'initial|follow-up|nullification');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `report_version` SET TAGS ('dbx_business_glossary_term' = 'ICSR Report Version Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `sender_identifier` SET TAGS ('dbx_business_glossary_term' = 'ICSR Sender Identifier');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Actual ICSR Submission Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'ICSR Submission Method');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'E2B(R3) XML|E2B(R2) XML|MedWatch|CIOMS I|Gateway|Manual');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'ICSR Submission Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_status` SET TAGS ('dbx_value_regex' = 'draft|pending|submitted|acknowledged|rejected|nullified');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'ICSR Submission Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `argus_signal_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Signal ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `benefit_risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Assessment Summary');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `case_count` SET TAGS ('dbx_business_glossary_term' = 'Signal Case Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `data_reviewed_summary` SET TAGS ('dbx_business_glossary_term' = 'Signal Data Reviewed Summary');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `signal_description` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Description');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `detection_date` SET TAGS ('dbx_business_glossary_term' = 'Signal Detection Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Signal Detection Method');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `dsmb_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `dsmb_recommendation` SET TAGS ('dbx_value_regex' = 'continue|modify_protocol|suspend|terminate|increase_monitoring|no_action');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `dsmb_review_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `evaluation_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Completion Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `evaluation_cycle_number` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Cycle Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `evaluation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `evaluation_plan` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Plan');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `evaluation_start_date` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Start Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `final_disposition` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Final Disposition');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `final_disposition` SET TAGS ('dbx_value_regex' = 'validated_new_risk|validated_change_in_risk|refuted|requires_further_monitoring|no_action_needed');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `is_dsmb_referred` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) Referral Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `is_expedited_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Expedited Regulatory Reporting Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `is_susar_related` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Related Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SIG-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Priority');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `regulatory_action_recommended` SET TAGS ('dbx_business_glossary_term' = 'Recommended Regulatory Action');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `regulatory_action_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Implementation Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `regulatory_action_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|not_required');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `signal_status` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `signal_status` SET TAGS ('dbx_value_regex' = 'new|under_evaluation|validated|refuted|ongoing_monitoring|closed');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `strength_lower_ci` SET TAGS ('dbx_business_glossary_term' = 'Signal Strength Lower Confidence Interval');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `strength_metric_name` SET TAGS ('dbx_business_glossary_term' = 'Signal Strength Metric Name');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `strength_metric_name` SET TAGS ('dbx_value_regex' = 'PRR|ROR|BCPNN_ic|EBGM|chi_squared|none');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `strength_metric_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `strength_value` SET TAGS ('dbx_business_glossary_term' = 'Signal Strength Metric Value');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Title');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `causality_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Causality Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Review Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `statistical_endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `argus_signal_evaluation_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Signal Evaluation Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `benefit_risk_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Assessment Summary');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `benefit_risk_conclusion` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Conclusion');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `benefit_risk_conclusion` SET TAGS ('dbx_value_regex' = 'favorable|unfavorable|inconclusive|requires_further_evaluation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `dsmb_dmc_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board / Data Monitoring Committee (DSMB/DMC) Recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `dsmb_dmc_recommendation` SET TAGS ('dbx_value_regex' = 'continue|modify_protocol|suspend|terminate|no_recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `dsmb_dmc_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board / Data Monitoring Committee (DSMB/DMC) Referral Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Completion Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_outcome` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_outcome` SET TAGS ('dbx_value_regex' = 'signal_confirmed|signal_refuted|signal_ongoing|new_signal_identified|no_action_required');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_plan_description` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Plan Description');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_value_regex' = 'initiated|in_progress|pending_review|completed|closed|superseded');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `expedited_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Expedited Regulatory Report Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `expedited_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Expedited Regulatory Reporting Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_query_reference` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Query Reference Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_query_reference` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `health_authority_query_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Current Version Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `is_dsmb_dmc_referral` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board / Data Monitoring Committee (DSMB/DMC) Referral Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `is_susar` SET TAGS ('dbx_business_glossary_term' = 'Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `protocol_amendment_required` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `risk_minimization_measure` SET TAGS ('dbx_value_regex' = 'routine_pharmacovigilance|additional_monitoring|rmp_update|educational_material|restricted_access|none');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `signal_detection_method` SET TAGS ('dbx_value_regex' = 'disproportionality_analysis|clinical_review|data_mining|literature_review|regulatory_request|dsmb_dmc_referral');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Version Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Charter Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Committee ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `primary_dsmb_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Minutes Document ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `primary_dsmb_tmf_document_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `argus_safety_case_ref` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Reference');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `charter_version` SET TAGS ('dbx_business_glossary_term' = 'Committee Charter Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `charter_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `closed_session_held` SET TAGS ('dbx_business_glossary_term' = 'Closed Session Held Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `data_package_version` SET TAGS ('dbx_business_glossary_term' = 'Unblinded Data Package Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `data_package_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Implementation Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `is_independent` SET TAGS ('dbx_business_glossary_term' = 'Committee Independence Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'scheduled|ad_hoc|emergency|teleconference|written_review');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `members_present_count` SET TAGS ('dbx_business_glossary_term' = 'DSMB Members Present Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled DSMB Review Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `open_session_held` SET TAGS ('dbx_business_glossary_term' = 'Open Session Held Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `protocol_amendment_required` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `quorum_achieved` SET TAGS ('dbx_business_glossary_term' = 'Quorum Achieved Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'DSMB Formal Recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'continue|continue_with_modification|suspend|terminate|pause_enrollment|other');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `recommendation_rationale` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation Rationale');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'DSMB Review Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|cancelled|postponed');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `safety_signal_identified` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Identified Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `sponsor_response` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Response to DSMB Recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `sponsor_response` SET TAGS ('dbx_value_regex' = 'accepted|accepted_with_modification|rejected|under_review|pending');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `stopping_rule_triggered` SET TAGS ('dbx_business_glossary_term' = 'Pre-Specified Stopping Rule Triggered');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `study_phase_reviewed` SET TAGS ('dbx_value_regex' = 'Phase_I|Phase_II|Phase_III|Phase_IV|Phase_I_II|Phase_II_III');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `unblinded_statistician_present` SET TAGS ('dbx_business_glossary_term' = 'Unblinded Statistician Present Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_signal_evaluation_id` FOREIGN KEY (`signal_evaluation_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal_evaluation`(`signal_evaluation_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `dsmb_recommendation_id` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Recommendation ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `affected_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Affected Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `affected_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `affected_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `signal_evaluation_id` SET TAGS ('dbx_business_glossary_term' = 'Signal Evaluation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `argus_safety_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `benefit_risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Assessment Summary');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `dissenting_opinion` SET TAGS ('dbx_business_glossary_term' = 'DSMB Dissenting Opinion');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `follow_up_review_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up DSMB Review Target Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `follow_up_review_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up DSMB Review Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Implementation Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `implementation_deadline` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Implementation Deadline');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `informed_consent_update_required` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Update Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Current Version Indicator');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Issue Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `protocol_amendment_required` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Rationale');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `recommendation_number` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `recommendation_status` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `recommendation_type` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `recommendation_type` SET TAGS ('dbx_value_regex' = 'continue_unchanged|protocol_amendment_required|dose_modification|study_suspension|early_termination|other');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `recommendation_version` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Version Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `regulatory_agencies_notified` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `regulatory_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Submission Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'DSMB Review Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'scheduled_interim|unscheduled_interim|annual|final|ad_hoc');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `sponsor_response` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Response to DSMB Recommendation');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `sponsor_response` SET TAGS ('dbx_value_regex' = 'accepted|rejected|partially_accepted|under_review|pending');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `stopping_rule_triggered` SET TAGS ('dbx_business_glossary_term' = 'Stopping Rule Triggered Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `vote_outcome` SET TAGS ('dbx_business_glossary_term' = 'DSMB Vote Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ALTER COLUMN `vote_outcome` SET TAGS ('dbx_value_regex' = 'unanimous|majority|split|no_vote_required');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_dsmb_recommendation_id` FOREIGN KEY (`dsmb_recommendation_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_recommendation`(`dsmb_recommendation_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dsur_id` SET TAGS ('dbx_business_glossary_term' = 'Development Safety Update Report (DSUR) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dsmb_recommendation_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Recommendation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Review Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `safety_report_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Dsur Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'DSUR Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `argus_periodic_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Periodic Report ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `benefit_risk_conclusion` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Conclusion');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `benefit_risk_conclusion` SET TAGS ('dbx_value_regex' = 'favorable|unfavorable|inconclusive|under_review');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `benefit_risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Summary Narrative');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `cumulative_sae_count` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Serious Adverse Event (SAE) Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `cumulative_susar_count` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Suspected Unexpected Serious Adverse Reaction (SUSAR) Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `data_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Data Lock Date (DBL)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dibd` SET TAGS ('dbx_business_glossary_term' = 'Development International Birth Date (DIBD)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `dsmb_review_conducted` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Conducted Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `fatal_sae_count` SET TAGS ('dbx_business_glossary_term' = 'Fatal Serious Adverse Event (SAE) Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_acknowledgement_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_acknowledgement_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_query_received` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Query Received Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_query_received` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `health_authority_query_received` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `medical_reviewer` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `medical_reviewer` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `new_safety_signal_identified` SET TAGS ('dbx_business_glossary_term' = 'New Safety Signal Identified Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `period_sae_count` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Serious Adverse Event (SAE) Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `period_subject_exposure_count` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Subject Exposure Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `period_susar_count` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Suspected Unexpected Serious Adverse Reaction (SUSAR) Count');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `reference_safety_document_type` SET TAGS ('dbx_value_regex' = 'IB|CCSI|SmPC|USPI|RSI');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `regulatory_action_taken` SET TAGS ('dbx_value_regex' = 'none|protocol_amendment|ibr_update|study_suspension|study_termination|rmp_update');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'DSUR Report Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'DSUR Report Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `report_version` SET TAGS ('dbx_business_glossary_term' = 'DSUR Report Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `report_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'DSUR Submission Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `submission_due_date` SET TAGS ('dbx_business_glossary_term' = 'DSUR Submission Due Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `submission_format` SET TAGS ('dbx_value_regex' = 'eCTD|NeeS|paper|eCTD_v4');

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_ae_meddra_coding_id` FOREIGN KEY (`ae_meddra_coding_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_meddra_coding`(`ae_meddra_coding_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_mvm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_narrative_id` FOREIGN KEY (`narrative_id`) REFERENCES `clinical_trials_mvm`.`safety`.`narrative`(`narrative_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` SET TAGS ('dbx_domain' = 'safety');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` SET TAGS ('dbx_subdomain' = 'event_management');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `ae_follow_up_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Follow-Up ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `ae_meddra_coding_id` SET TAGS ('dbx_business_glossary_term' = 'Ae Meddra Coding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `causality_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Causality Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Icsr Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `narrative_id` SET TAGS ('dbx_business_glossary_term' = 'Narrative Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `safety_report_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `argus_follow_up_case_number` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Follow-Up Case Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `awareness_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Awareness Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `dechallenge_result` SET TAGS ('dbx_value_regex' = 'positive|negative|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `dsmb_reported` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reported Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `edc_follow_up_form_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Follow-Up Form ID');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `expedited_report_required` SET TAGS ('dbx_business_glossary_term' = 'Expedited Regulatory Report Required Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_status` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Record Status');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|acknowledged|rejected|superseded');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_type` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Type');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `follow_up_type` SET TAGS ('dbx_value_regex' = 'clinical_update|outcome_update|causality_update|regulatory_update|narrative_update');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `investigator_assessment` SET TAGS ('dbx_business_glossary_term' = 'Investigator Follow-Up Assessment');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notified Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `rechallenge_result` SET TAGS ('dbx_value_regex' = 'positive|negative|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `reporting_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Regulatory Reporting Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Updated Action Taken with Investigational Product');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_action_taken` SET TAGS ('dbx_value_regex' = 'dose_reduced|drug_withdrawn|dose_interrupted|not_applicable|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_ae_term_verbatim` SET TAGS ('dbx_business_glossary_term' = 'Updated Adverse Event (AE) Verbatim Term');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_ctcae_grade` SET TAGS ('dbx_business_glossary_term' = 'Updated Common Terminology Criteria for Adverse Events (CTCAE) Grade');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_ctcae_grade` SET TAGS ('dbx_value_regex' = '1|2|3|4|5');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_expectedness` SET TAGS ('dbx_business_glossary_term' = 'Updated Expectedness Assessment');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_expectedness` SET TAGS ('dbx_value_regex' = 'expected|unexpected|not_assessable');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_is_serious` SET TAGS ('dbx_business_glossary_term' = 'Updated Seriousness Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_is_susar` SET TAGS ('dbx_business_glossary_term' = 'Updated Suspected Unexpected Serious Adverse Reaction (SUSAR) Flag');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_outcome` SET TAGS ('dbx_business_glossary_term' = 'Updated Adverse Event (AE) Outcome');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_outcome` SET TAGS ('dbx_value_regex' = 'recovered|recovering|not_recovered|recovered_with_sequelae|fatal|unknown');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_severity` SET TAGS ('dbx_business_glossary_term' = 'Updated Adverse Event (AE) Severity');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_severity` SET TAGS ('dbx_value_regex' = 'mild|moderate|severe|life_threatening|fatal');

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
