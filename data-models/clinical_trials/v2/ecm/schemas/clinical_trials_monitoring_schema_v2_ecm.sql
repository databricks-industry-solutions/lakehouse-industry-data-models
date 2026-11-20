-- Schema for Domain: monitoring | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:59

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`monitoring` COMMENT 'Manages CRA monitoring activities including risk-based monitoring (RBM) strategies, on-site and remote monitoring visits (initiation, interim, close-out), source data verification (SDV), monitoring visit reports, query management, protocol deviation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` (
    `monitoring_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the monitoring plan record in the Databricks Silver Layer. Primary key for this entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Monitoring plans are authored against specific SOPs governing CRA conduct, SDV procedures, and GCP requirements.',
    `delivery_preference_id` BIGINT COMMENT 'Foreign key linking to sponsor.delivery_preference. Business justification: Monitoring plans are authored to comply with sponsor delivery preferences (SDV %, monitoring strategy, reporting cadence).',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: The IND is the governing regulatory application defining safety reporting obligations and protocol requirements that monitoring plans must enforce.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Monitoring plans are executed under the terms of the master agreement, which defines quality standards, audit rights, GCP guideline versions, and quality agreement references.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Each monitoring plan has a designated sponsor contact (clinical operations lead or medical monitor) who approves and oversees it.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization commissioning the clinical study and for whom this monitoring plan is developed.',
    `program_strategic_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_plan. Business justification: Monitoring plans are authored in alignment with the program development plan. The program_plan defines regulatory pathway, submission strategy, and study scope that directly drives',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments directly trigger monitoring plan revisions (new SDV scope, visit frequency, critical data elements).',
    `regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: The regulatory strategy defines target agencies, submission timelines, and development phase that directly determine the monitoring approach, RBM strategy, applicable regions, and data',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — monitoring_plan has no FK to study despite being study-specific; it should reference the study it governs',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: ICH E6(R2) requires monitoring plans to document required CRA training. Linking monitoring_plan to training_curriculum formally references the mandated training curriculum',
    `amendment_reason` STRING COMMENT 'Narrative description of the reason for this version amendment, such as protocol changes, regulatory feedback, or lessons learned from interim monitoring data. Required for audit trail and TMF documentation.',
    `applicable_regions` STRING COMMENT 'Comma-separated list of regulatory regions or jurisdictions to which this monitoring plan applies (e.g., USA, EU, JPN, AUS, CAN). Determines which regulatory authority requirements (FDA, EMA, PMDA, TGA, Health Canada) govern monitoring activities.',
    `approval_date` DATE COMMENT 'Date on which the monitoring plan was formally approved by the authorized signatory (e.g., Sponsor, CRO Quality Assurance). Required for regulatory compliance and TMF filing.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual (e.g., Sponsor representative, CRO Quality Assurance lead) who formally approved this version of the monitoring plan. Supports ALCOA+ audit trail requirements.',
    `capa_resolution_days` BIGINT COMMENT 'Maximum number of calendar days within which a Corrective and Preventive Action (CAPA) identified during monitoring must be resolved and closed by the site or sponsor. Defined in the monitoring plan to ensure timely remediation.',
    `centralized_monitoring_included` BOOLEAN COMMENT 'Indicates whether centralized statistical monitoring (e.g., Key Risk Indicator (KRI) dashboards, data trend analysis) is included as a component of the monitoring strategy for this study.',
    `closeout_visit_required` BOOLEAN COMMENT 'Indicates whether a formal Site Close-Out Visit (COV) is mandated for all sites under this monitoring plan upon study completion or site termination.',
    `cra_qualification_requirements` STRING COMMENT 'Description of minimum qualifications, certifications, and experience required for Clinical Research Associates (CRAs) assigned to monitor sites under this plan (e.g., therapeutic area experience, GCP certification, sponsor-specific training).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this monitoring plan record was first created in the system. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic records compliance.',
    `critical_data_elements` STRING COMMENT 'Comma-separated list or narrative description of data fields designated as critical per ICH E6(R2), such as primary efficacy endpoints, informed consent dates, eligibility criteria, and safety data.',
    `critical_processes` STRING COMMENT 'Description of study processes designated as critical per ICH E6(R2), such as randomization, informed consent, Investigational Product (IP) accountability, and Serious Adverse Event (SAE) reporting. These processes receive heightened monitoring focus.',
    `data_privacy_requirements` STRING COMMENT 'Description of applicable data privacy and patient data protection requirements governing monitoring activities under this plan, including GDPR, HIPAA, and local data protection laws relevant to the study regions.',
    `effective_end_date` DATE COMMENT 'Date on which this version of the monitoring plan ceases to be operative, typically upon supersession by a new version or study close-out. Nullable for the currently active version.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the monitoring plan becomes operative and binding for study monitoring activities. Aligns with study initiation or amendment approval date.',
    `escalation_trigger_criteria` STRING COMMENT 'Defined conditions or thresholds that trigger escalation of monitoring intensity, additional site visits, or Corrective and Preventive Action (CAPA) initiation. Examples include KRI breaches, repeated protocol deviations, or SAE under-reporting.',
    `gcp_training_required` BOOLEAN COMMENT 'Indicates whether current Good Clinical Practice (GCP) training certification is a prerequisite for all Clinical Research Associates (CRAs) executing monitoring activities under this plan.',
    `high_risk_visit_frequency_days` BIGINT COMMENT 'Monitoring visit interval in calendar days applicable to sites classified as High risk tier. Typically shorter than the standard interval to ensure heightened oversight.',
    `icf_review_required` BOOLEAN COMMENT 'Indicates whether review of signed Informed Consent Forms (ICFs) for all enrolled subjects is a mandatory component of each monitoring visit under this plan.',
    `interim_visit_frequency_days` BIGINT COMMENT 'Standard interval in calendar days between scheduled interim monitoring visits for an average-risk site. Actual frequency may be adjusted based on site risk tier and Key Risk Indicator (KRI) triggers.',
    `ip_accountability_required` BOOLEAN COMMENT 'Indicates whether Investigational Product (IP) accountability checks (dispensing, return, destruction reconciliation) are mandated as part of on-site monitoring visits under this plan.',
    `kri_tolerance_limits` STRING COMMENT 'Narrative or structured description of the Key Risk Indicator (KRI) thresholds and tolerance limits defined in this monitoring plan. Specifies the upper/lower bounds for metrics such as query rate, protocol deviation rate, and enrollment rate that trigger',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this monitoring plan record was most recently updated. Supports change tracking, audit trail, and version control requirements under 21 CFR Part 11 and ICH E6(R2).',
    `low_risk_visit_frequency_days` BIGINT COMMENT 'Monitoring visit interval in calendar days applicable to sites classified as Low risk tier. Typically longer than the standard interval, reflecting reduced oversight requirements.',
    `missing_data_threshold` DECIMAL(5,2) COMMENT 'Maximum acceptable percentage of missing or incomplete data fields in the Electronic Case Report Form (eCRF) before a site is flagged for corrective action under the centralized monitoring program.',
    `monitoring_approach` STRING COMMENT 'Primary monitoring strategy defined for the study. On-Site involves Clinical Research Associate (CRA) visits to investigational sites; Remote involves off-site review of electronic data; Centralized involves statistical and data-driven oversight; Hybrid. Valid values are `On-Site|Remote|Centralized|Hybrid`',
    `plan_number` STRING COMMENT 'Externally-known unique business identifier for the monitoring plan, typically formatted as MP-[StudyCode]-[SequenceNumber]. Used in Trial Master File (TMF) references and regulatory submissions.. Valid values are `^MP-[A-Z0-9]{3,20}-[0-9]{3}$`',
    `plan_status` STRING COMMENT 'Current lifecycle status of the monitoring plan. Draft indicates work-in-progress; Under Review indicates pending approval; Approved is the active operative version; Superseded indicates replaced by a newer version; Retired indicates no longer applicable.. Valid values are `Draft|Under Review|Approved|Superseded|Retired`',
    `protocol_deviation_threshold` DECIMAL(5,2) COMMENT 'Maximum acceptable protocol deviation rate (expressed as a percentage of total subject visits or data points) before escalation actions are triggered at a site. Defined per the RBM strategy.',
    `query_rate_threshold` DECIMAL(5,2) COMMENT 'Maximum acceptable data query rate (expressed as a percentage of total data points entered) before centralized monitoring flags a site for additional review or on-site visit. Supports Electronic Data Capture (EDC) quality oversight.',
    `rbm_strategy` STRING COMMENT 'Overarching Risk-Based Monitoring (RBM) strategy classification applied to the study. Determines the balance between on-site, remote, and centralized monitoring activities based on study risk profile per ICH E6(R2) and FDA/EMA guidance.. Valid values are `Risk-Based|Traditional|Enhanced|Adaptive`',
    `remote_monitoring_allowed` BOOLEAN COMMENT 'Indicates whether remote (off-site) monitoring activities are permitted under this monitoring plan as a complement or alternative to on-site visits, per the approved RBM strategy.',
    `sdv_percentage_threshold` DECIMAL(5,2) COMMENT 'Minimum percentage of source data records or data points that must be verified per site visit or monitoring cycle, as defined in the Risk-Based Monitoring (RBM) strategy. Expressed as a percentage (0.00–100.00).',
    `sdv_scope` STRING COMMENT 'Defines the breadth of Source Data Verification (SDV) to be performed across the study. 100% SDV requires verification of all data points; Risk-Based SDV targets high-risk data fields; Critical Data Only restricts SDV to protocol-defined critical data. Valid values are `100% SDV|Risk-Based SDV|Critical Data Only|No SDV`',
    `site_initiation_visit_required` BOOLEAN COMMENT 'Indicates whether a formal Site Initiation Visit (SIV) is mandated for all sites under this monitoring plan prior to first patient enrollment.',
    `site_risk_tier_methodology` STRING COMMENT 'Methodology used to assign risk tiers (e.g., High, Medium, Low) to investigational sites. Determines how site-level risk scores are calculated to drive adaptive monitoring frequency and intensity.. Valid values are `Quantitative Score|Qualitative Assessment|Hybrid|Sponsor-Defined`',
    `version_number` STRING COMMENT 'Version identifier of the monitoring plan (e.g., 1.0, 2.0, 2.1). Incremented with each approved amendment to support audit trail and regulatory compliance.. Valid values are `^[0-9]+.[0-9]+$`',
    `visit_report_submission_days` BIGINT COMMENT 'Maximum number of calendar days after a monitoring visit within which the CRA must submit the completed monitoring visit report to the sponsor or CRO. Typically 5–10 business days per GCP standards.',
    CONSTRAINT pk_monitoring_plan PRIMARY KEY(`monitoring_plan_id`)
) COMMENT 'Master entity defining the risk-based monitoring (RBM) strategy for a clinical study. Specifies monitoring approach (on-site, remote, centralized), SDV scope and percentage thresholds, visit frequency rules, critical data/process definitions per ICH';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` (
    `visit_report_id` BIGINT COMMENT 'Unique surrogate identifier for the monitoring visit report record in the Databricks Silver Layer. Primary key for this entity.',
    `consent_icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: GCP ICH E6 R2 requires CRAs to verify the site uses the currently approved ICF version during each monitoring visit.',
    `primary_visit_employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who conducted the monitoring visit and authored this report. Supports accountability and workload tracking.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: A visit_report is the formal document authored by a CRA following a monitoring_visit. Every visit_report belongs to exactly one monitoring_visit.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this monitoring visit report was generated. Links the report to the parent protocol and sponsor.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the monitoring visit was conducted. Enables site-level performance tracking and regulatory oversight.',
    `tmf_document_id` BIGINT COMMENT 'Document identifier assigned by Veeva Vault eTMF when this monitoring visit report is filed as an essential TMF document under Zone 11 of the TMF Reference Model. Enables cross-system traceability between the data lakehouse and the eTMF.',
    `action_items_outstanding_count` BIGINT COMMENT 'Number of action items from previous monitoring visit reports that remain unresolved at the time of this visit. Key indicator of site compliance and follow-up effectiveness.',
    `action_items_raised_count` BIGINT COMMENT 'Total number of action items raised in this monitoring visit report requiring follow-up by the site or sponsor. Drives escalation workflows in the CTMS.',
    `capa_reference_number` STRING COMMENT 'Reference number of the CAPA record initiated in MasterControl as a result of findings from this monitoring visit. Enables cross-system traceability between the visit report and the CAPA management system.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) plan is required as a result of findings identified during this monitoring visit. Triggers CAPA workflow initiation in MasterControl.',
    `cra_signature_timestamp` TIMESTAMP COMMENT 'Timestamp of the CRAs electronic signature on the monitoring visit report, confirming authorship and accuracy of the report content. Required for 21 CFR Part 11 compliant electronic records.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit report record was first created in the system. Supports ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate) and audit trail requirements.',
    `icf_review_conducted` BOOLEAN COMMENT 'Indicates whether the CRA reviewed Informed Consent Form (ICF) processes and documentation for enrolled subjects during this monitoring visit. Critical GCP compliance check.',
    `ip_accountability_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed investigational product (IP) accountability records, including dispensing logs, return records, and storage conditions, during this monitoring visit.',
    `ip_storage_compliant` BOOLEAN COMMENT 'Indicates whether investigational product (IP) storage conditions (temperature, security, labeling) were found to be compliant with protocol and regulatory requirements during this visit.',
    `lab_samples_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed laboratory sample collection, processing, storage, and shipment records during this monitoring visit.',
    `monitoring_approach` STRING COMMENT 'Indicates whether the monitoring visit was conducted on-site at the investigational site, remotely (e.g., via EDC/eTMF access), or as a hybrid combination. Supports Risk-Based Monitoring (RBM) strategy reporting.. Valid values are `On-Site|Remote|Hybrid`',
    `next_visit_recommended_date` DATE COMMENT 'CRAs recommended date for the next monitoring visit based on site risk assessment, enrollment activity, and outstanding issues identified during this visit. Supports monitoring schedule planning in the CTMS.',
    `number` STRING COMMENT 'Externally-known, human-readable identifier for the monitoring visit report as assigned by the Clinical Trial Management System (CTMS) or eTMF. Used for cross-system reference and regulatory traceability (e.g., MVR-2024-0042).',
    `open_queries_count` BIGINT COMMENT 'Number of data queries outstanding (open) in the EDC system at the time of the monitoring visit. Reflects data quality status and site responsiveness.',
    `protocol_deviation_severity` STRING COMMENT 'Highest severity level of protocol deviations identified during this monitoring visit. Determines escalation requirements and regulatory reporting obligations.. Valid values are `None|Minor|Major|Critical`',
    `protocol_deviations_identified` BIGINT COMMENT 'Number of protocol deviations identified at the site during this monitoring visit. Drives CAPA initiation and regulatory reporting obligations.',
    `queries_raised_count` BIGINT COMMENT 'Number of new data queries raised by the CRA during this monitoring visit. Supports EDC query management tracking and site data quality metrics.',
    `queries_resolved_count` BIGINT COMMENT 'Number of previously open data queries resolved during or as a result of this monitoring visit. Tracks site responsiveness and data cleaning progress.',
    `regulatory_documents_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed the sites regulatory binder (including IRB/IEC approvals, investigator CVs, and delegation logs) during this monitoring visit.',
    `report_approved_date` DATE COMMENT 'The date on which the CRA supervisor or Clinical Trial Manager formally approved the monitoring visit report. Marks the report as finalized for eTMF filing.',
    `report_authored_date` DATE COMMENT 'The date on which the CRA completed authoring the monitoring visit report. Regulatory guidelines require reports to be issued within a defined number of days post-visit; this field enables compliance tracking.',
    `report_status` STRING COMMENT 'Current lifecycle status of the monitoring visit report within the authoring and approval workflow. Drives eTMF filing readiness and regulatory completeness checks.. Valid values are `Draft|Pending Review|Approved|Finalized|Superseded`',
    `sdv_coverage_percent` DECIMAL(5,2) COMMENT 'Percentage of eligible data points or subjects for which SDV was completed during this visit. Reflects the Risk-Based Monitoring (RBM) strategy applied and supports regulatory audit readiness.',
    `sdv_discrepancies_found` BIGINT COMMENT 'Number of discrepancies identified between source documents and electronic Case Report Form (eCRF) data entries during SDV activities. Key quality metric for data integrity assessment.',
    `sdv_source_documents_reviewed` BIGINT COMMENT 'Number of source documents reviewed during Source Data Verification (SDV) activities conducted during this monitoring visit. Supports SDV coverage reporting and risk-based monitoring metrics.',
    `site_overall_rating` STRING COMMENT 'CRAs overall qualitative rating of the sites performance and GCP compliance as assessed during this monitoring visit. Used for risk-based monitoring (RBM) strategy adjustments and escalation decisions.. Valid values are `Satisfactory|Needs Improvement|Unsatisfactory|Critical`',
    `subjects_active_count` BIGINT COMMENT 'Number of subjects currently active (on-study) at the site at the time of the monitoring visit. Supports site workload assessment and monitoring frequency planning.',
    `subjects_completed_count` BIGINT COMMENT 'Number of subjects who have completed the study at the site as of the visit date. Used for site performance reporting and study progress tracking.',
    `subjects_discontinued_count` BIGINT COMMENT 'Number of subjects who have discontinued from the study at the site as of the visit date. Supports dropout rate analysis and protocol deviation investigation.',
    `subjects_enrolled_count` BIGINT COMMENT 'Total number of subjects enrolled at the site as of the visit date. Captured in the visit report to track enrollment progress against site targets.',
    `subjects_screened_count` BIGINT COMMENT 'Total number of subjects screened at the site as of the visit date. Used to calculate screen failure rates and assess site recruitment performance.',
    `supervisor_signature_timestamp` TIMESTAMP COMMENT 'Timestamp of the CRA supervisors electronic signature on the monitoring visit report, confirming review and approval. Required for 21 CFR Part 11 compliant electronic records and eTMF filing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this visit report record was last modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `visit_date` DATE COMMENT 'The date on which the monitoring visit was conducted at the investigational site or remotely. For multi-day visits, this is the first day of the visit. Principal real-world event date for this transaction.',
    `visit_end_date` DATE COMMENT 'The date on which the monitoring visit concluded. Populated for multi-day visits to capture total visit duration. Used for resource planning and visit effort reporting.',
    `visit_summary_narrative` STRING COMMENT 'Free-text narrative summary authored by the CRA describing the overall conduct of the monitoring visit, key observations, site status, and general impressions. Core content of the monitoring visit report per GCP requirements.',
    `visit_type` STRING COMMENT 'Classification of the monitoring visit that generated this report. Determines the scope of activities performed and regulatory expectations. [ENUM-REF-CANDIDATE: Site Initiation Visit|Interim Monitoring Visit|Remote Monitoring Visit|Close-Out Visit|For. Valid values are `Site Initiation Visit|Interim Monitoring Visit|Remote Monitoring Visit|Close-Out Visit|For Cause Visit|Co-Monitoring Visit`',
    CONSTRAINT pk_visit_report PRIMARY KEY(`visit_report_id`)
) COMMENT 'Formal monitoring visit report authored by the CRA following each on-site or remote monitoring visit. Captures visit summary narrative, findings, SDV results, protocol deviations identified, outstanding issues, action items raised, and CRA/supervisor';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` (
    `sdv_record_id` BIGINT COMMENT 'Unique surrogate identifier for each Source Data Verification (SDV) record in the Databricks Silver Layer. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Source data verification of AE records is a critical monitoring activity. SDV records for AE fields must reference the specific adverse_event being verified to support data integrity',
    `compliance_capa_id` BIGINT COMMENT 'Reference to a Corrective and Preventive Action (CAPA) record in MasterControl initiated as a result of a systemic SDV discrepancy pattern at the site. Supports quality management and regulatory compliance.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP requires CRAs to verify valid informed consent was obtained before any study procedures during SDV. The sdv_record verifies source documents including the signed ICF.',
    `discrepancy_query_id` BIGINT COMMENT 'Reference to the data query raised in Medidata Rave EDC as a result of the discrepancy identified during SDV. Populated when sdv_outcome is discrepancy_found and a query has been issued.',
    `ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: SDV verifies specific eCRF field values against source documents. ICH E6(R2) requires field-level SDV traceability.',
    `ecrf_form_id` BIGINT COMMENT 'Reference to the specific eCRF form (e.g., Medidata Rave form) containing the data point that was verified during SDV.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who performed the SDV activity. Supports accountability and audit trail requirements under ALCOA+ principles.',
    `field_entry_id` BIGINT COMMENT 'Foreign key linking to datamanagement.field_entry. Business justification: SDV is the process of verifying a specific EDC field_entry value against the source document.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: ICH E6 GCP SDV process: CRAs verify lab result values in the eCRF against the lab-reported source document.',
    `monitoring_action_item_id` BIGINT COMMENT 'Reference to an action item or follow-up task raised in the source system as a result of this SDV finding. Supports escalation workflows and site management accountability.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to a protocol deviation record if the SDV discrepancy resulted in a protocol deviation being raised. Links SDV findings to the protocol deviation tracking workflow in the source system',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: ICH E6 GCP SDV process: CRAs verify specimen collection records (collection time, fasting status, collection method) against eCRF entries.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this SDV record was generated. Links to the study master entity.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the source data and eCRF data point reside. Supports site-level SDV performance tracking in the source system',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: SDV records document verification of data at protocol-defined visits. visit_name is a denormalized reference to study_visit_schedule.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: CRAs performing SDV on randomization-related eCRF fields (randomization number, treatment arm) must cross-reference the subjects actual randomization record.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: SDV records are performed at the subject visit level. Linking sdv_record to subject_visit_data enables reconciliation of SDV completion status at the visit level, supports',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: GCP requires SDV to be traceable to the specific subject visit verified. sdv_record.visit_name is a denormalized plain-text field; a FK to subject_visit enables regulatory SDV',
    `trial_subject_id` BIGINT COMMENT 'Reference to the enrolled study subject whose eCRF data point is being verified against source documents.',
    `visit_procedure_id` BIGINT COMMENT 'Foreign key linking to study.visit_procedure. Business justification: SDV is performed at the procedure/field level. Each SDV record verifies a specific eCRF field mapping to a protocol-defined visit procedure.',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: SDV records are captured during monitoring visits and their results are summarized in the visit_report.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this SDV record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ Contemporaneous principle.',
    `discrepancy_category` STRING COMMENT 'Categorical classification of the discrepancy type when sdv_outcome is discrepancy_found. Supports root cause analysis, CAPA workflows, and site quality trending.. Valid values are `transcription_error|missing_data|date_error|unit_error|coding_error|other`',
    `discrepancy_description` STRING COMMENT 'Narrative description of the discrepancy identified between the eCRF field value and the source document value. Populated only when sdv_outcome is discrepancy_found. Supports query generation and protocol deviation assessment.',
    `ecrf_page_number` STRING COMMENT 'eCRF page reference. Implements CDASH CRF page metadata concept.',
    `is_critical_data_point` BOOLEAN COMMENT 'Indicates whether this eCRF field is designated as a critical data point per the studys Risk-Based Monitoring (RBM) plan or Data Management Plan (DMP). Critical data points are prioritized for SDV under ICH E6(R2) Addendum.',
    `is_sdv_waived` BOOLEAN COMMENT 'Indicates whether SDV was formally waived for this data point per the approved RBM plan or protocol amendment. A waiver must be documented and justified in the monitoring plan. Supports RBM audit trail.',
    `not_verifiable_reason` STRING COMMENT 'Reason why the data point could not be verified against source documents when sdv_outcome is not_verifiable. Supports site follow-up actions and regulatory audit readiness.. Valid values are `source_unavailable|illegible|missing_record|access_denied|other`',
    `rbm_risk_score` DECIMAL(5,2) COMMENT 'Risk-based monitoring risk score. Implements ICH E6(R2) GCP 5.0 risk-based quality management / RBM concept.',
    `regulatory_impact_flag` BOOLEAN COMMENT 'Indicates whether the SDV discrepancy has potential regulatory impact (e.g., affects primary endpoint data, safety data, or regulatory submission data). Triggers escalation to the sponsor and regulatory team.',
    `resolution_date` DATE COMMENT 'The date on which the discrepancy was formally resolved and the resolution status was updated to resolved or closed. Used for monitoring KPI calculations such as query resolution cycle time.',
    `resolution_description` STRING COMMENT 'Narrative explanation of how the discrepancy was resolved, including any eCRF corrections made, source document clarifications obtained, or justifications provided by the site. Supports audit trail under 21 CFR Part 11.',
    `resolution_status` STRING COMMENT 'Current resolution status of the discrepancy identified during SDV: open (discrepancy raised, awaiting resolution), resolved (eCRF corrected or explanation accepted), closed (verified resolved and signed off), or cancelled (discrepancy withdrawn).. Valid values are `open|resolved|closed|cancelled`',
    `sdv_coverage_percentage` DECIMAL(5,2) COMMENT 'The percentage of eligible data points for this subject visit that have been verified as part of this SDV activity. Supports monitoring KPI reporting and RBM coverage tracking at the visit level.',
    `sdv_method` STRING COMMENT 'The SDV sampling strategy applied to this data point: 100% SDV (all data points verified), targeted (specific critical fields), risk-based (driven by RBM algorithm), or triggered (initiated by a specific risk signal or query).. Valid values are `100_percent|targeted|risk_based|triggered`',
    `sdv_outcome` STRING COMMENT 'The result of the SDV activity for this specific data point: verified (eCRF matches source), discrepancy_found (mismatch identified), not_verifiable (source document unavailable or illegible), or pending (SDV not yet completed).. Valid values are `verified|discrepancy_found|not_verifiable|pending`',
    `sdv_performed_timestamp` TIMESTAMP COMMENT 'The date and time at which the CRA performed the SDV activity for this specific data point. Principal business event timestamp. Supports ALCOA+ Contemporaneous principle and 21 CFR Part 11 audit trail.',
    `sdv_reference_number` STRING COMMENT 'Externally-known business identifier for this SDV record, used in monitoring visit reports, audit trails, and regulatory submissions. Generated by the source system. Valid values are `^SDV-[A-Z0-9]{3,10}-[0-9]{6,12}$`',
    `sdv_type` STRING COMMENT 'Source data verification type. Implements ICH E6(R2) GCP 5.18 SDV concept.. Valid values are `on_site|remote|centralized`',
    `source_document_type` STRING COMMENT 'Classification of the source document used for verification (e.g., medical record, lab report, ECG tracing). Supports audit trail and ALCOA+ Original principle.',
    `source_document_value` DECIMAL(18,2) COMMENT 'The value as recorded in the original source document (e.g., medical record, lab report, nurse notes) against which the eCRF field value was verified. Supports ALCOA+ Attributable and Original principles.',
    `source_system_record_reference` STRING COMMENT 'The unique identifier of this SDV record as assigned by the originating system (the source system or Medidata Rave). Supports data lineage, reconciliation, and audit trail between the Silver Layer and the operational system of record.',
    `subject_number` STRING COMMENT 'Subject identifier. PII. Implements SDTM DM.SUBJID / USUBJID subject identifier concept.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this SDV record was last modified. Supports change tracking, audit trail, and incremental data loading in the Databricks Silver Layer.',
    `waiver_justification` STRING COMMENT 'Narrative justification for waiving SDV on this data point, referencing the applicable RBM plan section or risk assessment. Populated only when is_sdv_waived is True.',
    CONSTRAINT pk_sdv_record PRIMARY KEY(`sdv_record_id`)
) COMMENT 'Source Data Verification (SDV) record capturing the verification of individual eCRF data points against source documents at the site. Tracks subject visit, eCRF field or data point verified, SDV outcome (verified, discrepancy found, not verifiable)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` (
    `visit_deviation_finding_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol deviation finding record captured during monitoring or data review activities in the source system',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Protocol deviation findings for late or missing AE/SAE reporting must reference the specific adverse_event.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the associated CAPA workflow record in MasterControl when the deviation severity requires formal corrective and preventive action. Null if no CAPA is required.',
    `compliance_protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: A visit deviation finding identified during CRA monitoring directly generates or maps to the formal protocol_deviation record in compliance.',
    `deviation_classification_id` BIGINT COMMENT 'Foreign key linking to compliance.deviation_classification. Business justification: Deviation findings must be classified per the standardized deviation_classification taxonomy for SDTM DV domain mapping, regulatory reporting, and CSR inclusion decisions.',
    `eligibility_criterion_id` BIGINT COMMENT 'Foreign key linking to study.eligibility_criterion. Business justification: IE criteria violations are among the most serious protocol deviations tracked in visit_deviation_finding.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) responsible for documenting and managing this deviation finding. The CRA is the primary owner of the deviation record in the source system',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Protocol deviation documentation for lab-related violations (e.g., subject continued on study despite lab value meeting stopping criteria, missed mandatory safety lab).',
    `monitoring_action_item_id` BIGINT COMMENT 'Foreign key linking to monitoring.action_item. Business justification: Protocol deviation findings identified during monitoring visits typically generate action items for site remediation.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol deviations identified during monitoring visits are often resolved by a protocol amendment.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the protocol deviation occurred. Enables site-level deviation trending and risk-based monitoring (RBM) analytics.',
    `subject_deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Monitoring-identified deviation findings must be reconciled with subject-level deviation records for CAPA tracking and regulatory reporting (ICH E6 R2).',
    `subject_visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Deviation findings are tied to a specific subject visit (e.g., missed assessment at Visit 3, wrong procedure at screening).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Protocol deviation findings must be documented and filed in the eTMF per ICH GCP. Inspectors require direct traceability from each deviation finding record to its supporting TMF-filed',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) affected by this protocol deviation. Nullable when the deviation is site-level or procedural rather than subject-specific.',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: Protocol deviation findings identified during a monitoring visit are documented in the visit_report.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a formal Corrective and Preventive Action (CAPA) workflow must be initiated for this deviation. Typically True for major deviations and recurring minor deviations. Drives CAPA creation in MasterControl.',
    `classification_type` STRING COMMENT 'Indicates whether the deviation was identified and approved prospectively (before the deviation occurred, as a planned exception) or retrospectively (after the deviation occurred).. Valid values are `prospective|retrospective`',
    `comments` STRING COMMENT 'Free-text field for additional comments, clarifications, or contextual notes related to the deviation finding that do not fit into structured fields. Captured by the CRA or data manager in the source system',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the deviation finding record was first created in the source system Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `data_integrity_impact` BOOLEAN COMMENT 'Indicates whether the protocol deviation compromised the integrity or reliability of the clinical data collected for the affected subject or visit. Impacts subjects inclusion in the Intent-to-Treat (ITT) or Per Protocol (PP) analysis populations.',
    `detection_method` STRING COMMENT 'The method by which the protocol deviation was identified. Supports risk-based monitoring (RBM) effectiveness analysis and helps identify whether centralized monitoring or on-site monitoring is more effective at detecting specific deviation types.. Valid values are `on_site_monitoring|remote_monitoring|data_review|self_reported|audit|dsmb_review`',
    `deviation_description` STRING COMMENT 'Detailed narrative description of the protocol deviation, including what occurred, which protocol section was deviated from, and the specific circumstances.',
    `deviation_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the protocol deviation finding, typically assigned by the CTMS or sponsor. Used in regulatory submissions, IRB/IEC reports, and sponsor communications (e.g., DEV-STUDY001-00042).. Valid values are `^DEV-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `deviation_status` STRING COMMENT 'Current lifecycle status of the deviation finding record within the monitoring workflow. Drives CAPA initiation, sponsor notification, and regulatory reporting workflows in the source system. Valid values are `open|under_review|resolved|closed|escalated|voided`',
    `identification_date` DATE COMMENT 'The calendar date on which the protocol deviation was first identified, either during an on-site monitoring visit, remote monitoring review, or data management query. Used to calculate detection lag and reporting deadline compliance.',
    `identified_by` STRING COMMENT 'Name or role identifier of the person who identified the protocol deviation (e.g., CRA name, data manager, site staff). Supports accountability tracking and ALCOA+ attributability requirements.',
    `impact_assessment` STRING COMMENT 'Narrative assessment of the actual or potential impact of the deviation on subject safety, data integrity, and study validity. Informs the severity classification and determines whether regulatory reporting is required.',
    `irb_iec_report_date` DATE COMMENT 'The date on which the protocol deviation was formally reported to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC). Null if irb_iec_reportable is False or reporting is pending.',
    `irb_iec_reportable` BOOLEAN COMMENT 'IRB/IEC reportability flag. Implements ICH E6(R2) GCP 4.5.1 IRB/IEC reporting concept.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to the deviation finding record. Required for audit trail compliance under 21 CFR Part 11 and ICH E6(R2) electronic records requirements.',
    `occurrence_date` DATE COMMENT 'The calendar date on which the protocol deviation actually occurred at the site. This is the real-world event date, distinct from the identification date. Critical for regulatory reporting timelines and IRB/IEC notification windows.',
    `protocol_section_reference` STRING COMMENT 'The specific section number or clause of the study protocol that was deviated from (e.g., Section 6.3.2 - Visit Window). Enables protocol-level deviation frequency analysis and supports regulatory submission documentation.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this deviation represents a recurrence of a previously identified deviation of the same category at this site. Recurring deviations trigger escalated CAPA requirements and may indicate systemic site quality issues.',
    `regulatory_authority_reportable` BOOLEAN COMMENT 'Regulatory authority reportability flag. Implements ICH E6(R2) GCP 5.20 regulatory reporting concept.',
    `resolution_date` DATE COMMENT 'The date on which the protocol deviation was formally resolved and closed in the source system Null if the deviation is still open or under review. Used to calculate deviation resolution cycle time KPIs.',
    `resolution_description` STRING COMMENT 'Narrative description of the actions taken to resolve the protocol deviation, including immediate corrective actions implemented at the site. Distinct from the formal CAPA plan, this captures the immediate remediation steps.',
    `root_cause` STRING COMMENT 'Narrative description of the identified root cause of the protocol deviation, as determined through investigation by the site or sponsor. Used to drive CAPA development and systemic issue identification across sites.',
    `root_cause_category` STRING COMMENT 'Standardized categorical classification of the deviation root cause to enable cross-site and cross-study trending. Supports risk-based monitoring (RBM) signal detection and CAPA effectiveness analysis.. Valid values are `site_staff_error|subject_non_compliance|system_failure|protocol_ambiguity|sponsor_error|external_factor`',
    `sdtm_dv_category` STRING COMMENT 'Protocol deviation category. Implements SDTM DV.DVCAT (Protocol Deviations domain).',
    `sdtm_dv_term` STRING COMMENT 'Protocol deviation term. Implements SDTM DV.DVTERM (Protocol Deviations domain).',
    `severity` STRING COMMENT 'Regulatory severity classification of the protocol deviation. major deviations may affect subject safety or data integrity and typically require IRB/IEC and sponsor reporting.. Valid values are `major|minor|important_protocol_deviation`',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating operational system (the source system for this deviation finding. Supports data lineage, reconciliation, and audit trail requirements between the Silver Layer lakehouse and the system of record.',
    `sponsor_report_date` DATE COMMENT 'The date on which the protocol deviation was formally reported to the study sponsor. Null if sponsor_reportable is False or reporting is pending. Used to track compliance with sponsor notification timelines.',
    `sponsor_reportable` BOOLEAN COMMENT 'Indicates whether this deviation must be formally reported to the study sponsor per the Clinical Trial Agreement (CTA) and sponsor SOPs. All major deviations and important protocol deviations (IPDs) are typically sponsor-reportable.',
    `subject_number` STRING COMMENT 'Subject identifier. PII. Implements SDTM DM.SUBJID subject identifier concept.',
    `subject_safety_impact` BOOLEAN COMMENT 'Subject safety impact flag. Implements ICH E6(R2) GCP 4.5 subject safety concept.',
    CONSTRAINT pk_visit_deviation_finding PRIMARY KEY(`visit_deviation_finding_id`)
) COMMENT 'Record of each protocol deviation identified at a site during monitoring or data review. Captures deviation category and severity (major, minor, important), description, root cause, affected subject, dates of occurrence and identification, IRB/IEC and';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` (
    `visit_finding_id` BIGINT COMMENT 'Primary key for visit_finding',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: CRAs identify AE reporting compliance findings (unreported AEs, late reporting) during monitoring visits.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Visit findings about consent (subject signed wrong ICF version, consent obtained after procedure) reference a specific subject_consent record.',
    `discrepancy_query_id` BIGINT COMMENT 'The query identifier in the Electronic Data Capture (EDC) system (e.g., Medidata Rave) associated with this finding, where the finding resulted in or is linked to a data query raised against an eCRF entry.',
    `eligibility_criterion_id` BIGINT COMMENT 'Foreign key linking to study.eligibility_criterion. Business justification: Protocol deviations identified during monitoring frequently involve eligibility criteria violations (subjects enrolled despite failing I/E criteria).',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who identified and recorded this finding during the monitoring visit or remote review.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: GCP monitoring finding documentation: CRAs raise findings against specific lab results (e.g., critical value not reported as AE, result not transcribed to eCRF).',
    `monitoring_action_item_id` BIGINT COMMENT 'Reference to the action item record created in the CTMS to track the required corrective steps for this finding. Action items are assigned to site staff or CRA and tracked to closure.',
    `original_finding_visit_finding_id` BIGINT COMMENT 'Reference to the original finding record when this finding is a repeat or recurrence. Enables lineage tracking of recurring issues across multiple monitoring visits at the same site. Null if this is not a repeat finding.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the associated protocol deviation record if this finding resulted in or is linked to a formally documented protocol deviation. Null if the finding does not constitute a protocol deviation.',
    `rand_deviation_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_deviation. Business justification: When a CRA identifies a randomization error during a monitoring visit (wrong kit dispensed, incorrect arm assignment), a visit_finding and a rand_deviation are both created.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the parent monitoring visit during which this finding was identified. Links the finding to its originating visit record in the Clinical Trial Management System (CTMS).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study protocol under which this finding was recorded. Supports cross-site and cross-visit finding analysis at the study level.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the finding was identified. Enables site-level aggregation and trending of findings for risk-based monitoring (RBM) analytics.',
    `subject_deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Visit findings that constitute protocol deviations must link to the subject-level deviation record for subject safety impact analysis and regulatory submission.',
    `temperature_excursion_id` BIGINT COMMENT 'Foreign key linking to supply.temperature_excursion. Business justification: When a CRA identifies an IP storage finding during a monitoring visit, the visit_finding record must reference the specific temperature_excursion record for CAPA traceability and',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Monitoring findings must be traceable to their TMF-filed evidence for GCP inspection readiness. QA teams and inspectors navigate from finding records to filed documents during audits.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the study subject (patient) associated with this finding, where the finding is subject-specific (e.g., missing ICF, unreported AE for a specific subject). Null for site-level or system-level findings not attributable to a specific subject.',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: Individual findings recorded by a CRA are documented within a visit_report. visit_finding already has visit_id → monitoring_visit, but the direct link to visit_report is missing.',
    `closed_date` DATE COMMENT 'The date on which the finding was formally closed in the CTMS following CRA verification of the corrective action. Distinct from resolved_date as closure may require additional sponsor or QA sign-off after resolution.',
    `cra_verification_comment` STRING COMMENT 'Narrative comment entered by the CRA when verifying the adequacy of the sites corrective action. Documents the CRAs assessment of whether the resolution is satisfactory and the finding can be closed.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this finding record was first created in the Clinical Trial Management System (CTMS). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `data_integrity_impact` BOOLEAN COMMENT 'Indicates whether this finding has a direct impact on the integrity of clinical trial data, including eCRF entries, source documents, or audit trails. True findings may affect the reliability of data submitted in regulatory dossiers (IND, NDA, BLA, MAA).',
    `due_date` DATE COMMENT 'Target date by which the site is required to resolve the finding and provide evidence of corrective action. Determined based on finding severity and sponsor/CRO standard operating procedures (SOPs).',
    `escalation_date` DATE COMMENT 'The date on which this finding was escalated beyond the standard CRA-site resolution process. Null if escalation_level is none. Used to track escalation timeliness and sponsor oversight effectiveness.',
    `escalation_level` STRING COMMENT 'Current escalation level of the finding indicating how far up the oversight hierarchy the finding has been escalated. none: no escalation required. cra_manager: escalated to CRA line manager or clinical operations lead.. Valid values are `none|cra_manager|sponsor|regulatory_authority`',
    `finding_category` STRING COMMENT 'High-level classification of the finding domain as observed by the CRA. Categories align with GCP monitoring focus areas: data_integrity (eCRF/EDC discrepancies), informed_consent (ICF process issues), ip_accountability (investigational product handling). Valid values are `data_integrity|informed_consent|ip_accountability|safety_reporting|regulatory_compliance|protocol_deviation`',
    `finding_description` STRING COMMENT 'Detailed narrative description of the finding as documented by the CRA, including the specific observation, the GCP or protocol requirement that was not met, and the context in which the finding was identified.',
    `finding_number` STRING COMMENT 'Externally-visible, human-readable unique reference number assigned to this finding within the Clinical Trial Management System (CTMS). Used in monitoring visit reports, sponsor communications, and regulatory correspondence.. Valid values are `^FND-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `finding_subcategory` STRING COMMENT 'Granular sub-classification within the finding category providing more specific context (e.g., missing source document, late SAE reporting, temperature excursion, unsigned ICF). Supports detailed root cause analysis and CAPA trending.',
    `gcp_reference` STRING COMMENT 'GCP reference. Implements ICH E6(R2) Good Clinical Practice guideline reference.',
    `identified_date` DATE COMMENT 'The calendar date on which the CRA identified and documented this finding during the monitoring visit or remote review. Represents the principal real-world event date for this observation.',
    `monitoring_approach` STRING COMMENT 'The monitoring methodology used when the finding was identified. on_site: CRA physically present at the investigational site. remote: CRA conducting review via electronic access to site data.. Valid values are `on_site|remote|centralized`',
    `preventive_action` STRING COMMENT 'Description of the preventive measures implemented or planned to prevent recurrence of this finding. Captured as part of the CAPA workflow and documented in the monitoring visit report follow-up.',
    `regulatory_impact` BOOLEAN COMMENT 'Indicates whether this finding has potential regulatory impact requiring notification to or action by a regulatory authority (FDA, EMA, MHRA, PMDA, etc.) or ethics committee (IRB/IEC).',
    `repeat_finding` BOOLEAN COMMENT 'Indicates whether this finding is a recurrence of a previously identified finding at the same site for the same category. Repeat findings are a key risk indicator in risk-based monitoring (RBM) and may trigger escalation or CAPA initiation.',
    `resolution_status` STRING COMMENT 'Current workflow state of the finding in its resolution lifecycle. open: finding identified, awaiting site response. in_progress: site has acknowledged and is working on resolution. resolved: corrective action completed and verified by CRA.. Valid values are `open|in_progress|resolved|closed|escalated`',
    `resolved_date` DATE COMMENT 'The actual date on which the finding was resolved and the corrective action was verified as complete by the CRA. Null if the finding has not yet been resolved. Used to calculate resolution cycle time for KPI reporting.',
    `root_cause` STRING COMMENT 'The identified root cause of the finding as determined through investigation by the site or CRA. Documented as part of the CAPA or corrective action process.',
    `sdv_completed` BOOLEAN COMMENT 'Indicates whether the required Source Data Verification (SDV) for this finding has been completed by the CRA. Applicable only when sdv_required is True.',
    `sdv_required` BOOLEAN COMMENT 'Indicates whether Source Data Verification (SDV) is required as part of the corrective action for this finding. True when the finding involves data discrepancies that require verification against original source documents.',
    `severity` STRING COMMENT 'Risk-based severity classification of the finding indicating its potential impact on subject safety, data integrity, or regulatory compliance. Critical: immediate risk to subject safety or data integrity requiring urgent action.. Valid values are `critical|major|minor|observation`',
    `site_response` STRING COMMENT 'Narrative response provided by the site (Principal Investigator or Clinical Research Coordinator) acknowledging the finding and describing the corrective actions taken or planned. Captured in the CTMS and included in the monitoring visit report.',
    `site_response_date` DATE COMMENT 'The date on which the site provided its formal response to the finding. Used to measure site responsiveness and compliance with response timelines defined in the monitoring plan.',
    `subject_number` STRING COMMENT 'Subject identifier. PII. Implements SDTM DM.SUBJID subject identifier concept.',
    `subject_safety_impact` BOOLEAN COMMENT 'Indicates whether this finding has a direct or potential impact on the safety or welfare of study subjects. True findings require immediate escalation per GCP requirements and may trigger safety reporting obligations.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this finding record was most recently modified in the CTMS. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `visit_type` STRING COMMENT 'Type of monitoring visit during which this finding was identified. site_initiation: pre-enrollment site setup visit. interim_monitoring: routine on-site or remote monitoring visit. close_out: end-of-study visit.. Valid values are `site_initiation|interim_monitoring|close_out|remote|for_cause`',
    CONSTRAINT pk_visit_finding PRIMARY KEY(`visit_finding_id`)
) COMMENT 'Individual finding or observation recorded by a CRA during a monitoring visit or remote review. Captures finding category (data integrity, consent, IP accountability, safety reporting, regulatory compliance), severity, description, site response';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` (
    `monitoring_action_item_id` BIGINT COMMENT 'Unique surrogate identifier for the action item record in the Databricks Silver Layer. Primary key generated by the lakehouse ingestion pipeline from the source system',
    `central_monitoring_alert_id` BIGINT COMMENT 'Foreign key linking to monitoring.central_monitoring_alert. Business justification: A monitoring action item can be raised as a direct result of a central monitoring alert (e.g., KRI breach requiring site-level follow-up action).',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the formal CAPA record in MasterControl associated with this action item, when the finding severity warrants a full CAPA workflow. Null for minor action items not escalated to CAPA.',
    `parent_action_item_monitoring_action_item_id` BIGINT COMMENT 'Self-referencing identifier linking this action item to a parent action item when it was created as a sub-task or follow-up from a prior finding. Supports hierarchical action item tracking and recurrence analysis.',
    `primary_monitoring_employee_id` BIGINT COMMENT 'Reference to the responsible party (site staff, CRA, or sponsor representative) accountable for resolving this action item. Drives automated escalation workflows in the source system for overdue items.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the protocol deviation record that triggered this action item, where applicable. Supports traceability between deviations and corrective actions per GCP requirements.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit (initiation, interim, or close-out) during which this action item was identified or formally raised. Null if the action item originated outside a scheduled visit (e.g., remote review or escalation trigger).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this action item was raised. Links the action item to the governing study protocol for regulatory traceability.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the action item was identified. Enables site-level performance tracking and regulatory inspection readiness reporting.',
    `tertiary_monitoring_closure_confirmed_by_user_employee_id` BIGINT COMMENT 'Reference to the CRA, monitor, or sponsor representative who reviewed the closure evidence and formally confirmed the action item as resolved. Supports electronic signature audit trail per 21 CFR Part 11.',
    `trial_subject_id` BIGINT COMMENT 'Foreign key linking to subject.trial_subject. Business justification: Subject-specific action items (missing ICF, SDV discrepancy for a specific subject, unreported AE) are a standard CTMS operational concept.',
    `action_item_number` STRING COMMENT 'Human-readable, externally-visible reference number for the action item as assigned by the source system (e.g., AI-STUDY001-00042). Used in monitoring visit reports, CAPA correspondence, and regulatory inspection documentation.. Valid values are `^AI-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `action_type` STRING COMMENT 'Classifies whether the action item represents a corrective action (addressing an existing finding), preventive action (mitigating future risk), observation (noted but not requiring immediate action), recommendation, or escalation.. Valid values are `corrective|preventive|observation|recommendation|escalation`',
    `monitoring_action_item_category` STRING COMMENT 'Business classification of the action item by the type of finding or compliance gap it addresses. Drives routing logic, escalation thresholds, and regulatory reporting groupings in the source system',
    `closed_date` DATE COMMENT 'The calendar date on which the action item was formally closed following verification of corrective action completion and evidence review. Null for open or in-progress items.',
    `closure_evidence_description` STRING COMMENT 'Narrative description of the evidence provided to confirm resolution of the action item (e.g., updated SOP reference, re-training record, corrected eCRF entry, SDV confirmation). Required for GCP-compliant closure documentation.',
    `closure_evidence_document_ref` STRING COMMENT 'Reference identifier or URL to the supporting document stored in Veeva Vault eTMF that substantiates the closure of this action item (e.g., training certificate, corrected source document scan, updated SOP version).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this action item record was first created in the source system Provides the audit trail creation event per 21 CFR Part 11 electronic records requirements and ALCOA+ contemporaneous documentation standards.',
    `ctms_record_reference` STRING COMMENT 'Native record identifier from the source system for this action item. Preserved in the Silver Layer to enable bidirectional traceability between the lakehouse and the operational system of record.',
    `data_integrity_impact` BOOLEAN COMMENT 'Indicates whether the finding underlying this action item compromises the integrity of clinical trial data (e.g., eCRF entries, source data, audit trail). When True, may require data query issuance in Medidata Rave EDC and notification to data management.',
    `days_overdue` BIGINT COMMENT 'Number of calendar days the action item has been open past its due date (or extended due date if applicable). Populated by the source system automated workflow; zero for on-time or not-yet-due items.',
    `monitoring_action_item_description` STRING COMMENT 'Full narrative description of the monitoring finding, protocol deviation, or compliance gap that necessitated this action item. Includes observed facts, regulatory reference, and expected corrective action per GCP documentation standards (ALCOA+).',
    `due_date` DATE COMMENT 'Target date by which the responsible party must complete and close the action item. Used by the source system automated escalation workflows to flag overdue items and notify CRA supervisors and sponsor representatives.',
    `escalation_date` DATE COMMENT 'Date on which the action item was formally escalated. Null if is_escalated is False. Used to measure escalation response time and regulatory inspection readiness.',
    `escalation_reason` STRING COMMENT 'Narrative explanation of why the action item was escalated, including the triggering condition (e.g., overdue beyond threshold, critical safety implication, repeated non-compliance). Required when is_escalated is True.',
    `extended_due_date` DATE COMMENT 'Revised due date granted after a formal extension request and approval. Null if no extension has been granted. Tracks due date changes for audit trail and SLA compliance reporting.',
    `gcp_reference` STRING COMMENT 'GCP reference. Implements ICH E6(R2) Good Clinical Practice guideline reference.',
    `is_escalated` BOOLEAN COMMENT 'Indicates whether this action item has been formally escalated to a higher authority (e.g., sponsor medical monitor, regulatory affairs, DSMB) due to non-resolution, critical priority, or subject safety risk.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this action item record in the source system Used for incremental data pipeline processing and audit trail completeness per 21 CFR Part 11.',
    `monitoring_visit_type` STRING COMMENT 'Type of monitoring visit during which the action item was identified. Denormalized from the monitoring visit record for reporting efficiency. Supports analysis of finding patterns by visit type (e.g., higher deviation rates at initiation visits).. Valid values are `initiation|interim|close_out|remote|for_cause`',
    `priority` STRING COMMENT 'Priority level assigned to the action item indicating urgency and potential impact on subject safety, data integrity, or regulatory compliance. Critical items trigger immediate escalation workflows in the source system. Valid values are `critical|high|medium|low`',
    `raised_date` DATE COMMENT 'The calendar date on which the action item was formally raised and entered into the source system Serves as the principal business event date for SLA calculation, aging analysis, and regulatory inspection timelines.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this action item represents a recurring finding previously identified at the same site or study. Recurring findings may trigger escalation to a formal CAPA workflow and are tracked for site performance risk scoring.',
    `regulatory_impact` STRING COMMENT 'Assessment of the potential regulatory impact of the finding underlying this action item. Drives prioritization for regulatory submission readiness, inspection preparation, and escalation to regulatory affairs.. Valid values are `none|minor|moderate|significant|critical`',
    `response_date` DATE COMMENT 'Date on which the site formally submitted their response to the action item. Used to measure site responsiveness KPIs and to determine whether the response was received within the required timeframe.',
    `response_text` STRING COMMENT 'Formal written response provided by the site (PI or CRC) acknowledging the action item and describing the planned or completed corrective actions. Captured in the source system as part of the action item resolution workflow.',
    `responsible_party_role` STRING COMMENT 'Functional role category of the party accountable for resolving the action item. Distinguishes between site staff (PI, CRC), CRA, sponsor, or functional team (data management, safety). Used for workload distribution and escalation routing.',
    `source_type` STRING COMMENT 'Identifies the originating activity or process that generated this action item (e.g., on-site monitoring visit, remote monitoring review, SDV finding, protocol deviation, safety signal, audit). Supports risk-based monitoring (RBM) analytics.',
    `monitoring_action_item_status` STRING COMMENT 'Current workflow state of the action item lifecycle in the source system Overdue status is set automatically when the due date passes without closure. Closed status requires documented evidence of resolution.. Valid values are `open|in_progress|overdue|closed|cancelled`',
    `subject_safety_impact` BOOLEAN COMMENT 'Subject safety impact flag. Implements ICH E6(R2) GCP 5.18.4 subject safety concept.',
    `title` STRING COMMENT 'Short, descriptive title summarizing the action item finding or required corrective action. Used as the primary display label in CTMS dashboards, monitoring visit reports, and escalation notifications.',
    `verification_method` STRING COMMENT 'Method used by the CRA or monitor to verify that the corrective action was implemented and the action item can be closed (e.g., SDV, document review, on-site visit, remote review). Supports GCP audit trail requirements.. Valid values are `sdv|document_review|site_visit|remote_review|sponsor_confirmation`',
    CONSTRAINT pk_monitoring_action_item PRIMARY KEY(`monitoring_action_item_id`)
) COMMENT 'Formal action item raised as a result of a monitoring finding, protocol deviation, or escalation trigger. Tracks action description, responsible party (site staff, CRA, or sponsor), due date, priority level, current status (open, in-progress, overdue';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` (
    `risk_indicator_id` BIGINT COMMENT 'Unique surrogate identifier for the centralized monitoring risk indicator (Key Risk Indicator / KRI) record within the Risk-Based Monitoring (RBM) framework.',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: KRIs are defined to monitor compliance with specific regulatory obligations. Linking risk_indicator to obligation enables obligation coverage reporting — confirming each regulatory',
    `kri_id` BIGINT COMMENT 'Foreign key linking to program.program_kri. Business justification: Study/site-level KRIs (risk_indicator) are operationally mapped to program-level KRIs (program_kri) for aggregation into program_kri_readings.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Risk-Based Monitoring (RBM) plans define KRIs per lab panel (e.g., safety panel completion rate, critical value rate by panel).',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the RBM monitoring plan document that defines this KRI, linking the indicator to its governing plan version and associated thresholds.',
    `risk_id` BIGINT COMMENT 'Foreign key linking to program.program_risk. Business justification: Site/study-level risk indicators that breach thresholds are escalated to the program risk register.',
    `service_level_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.service_level_agreement. Business justification: KRIs are frequently mapped 1:1 to SLA thresholds in CRO contracts (e.g., query rate, data entry lag, SDV completion).',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit (on-site or remote) during which this KRI was reviewed or triggered a visit activity. Links centralized monitoring findings to on-site monitoring actions.',
    `statistical_endpoint_id` BIGINT COMMENT 'Foreign key linking to biostatistics.statistical_endpoint. Business justification: KRIs in RBM are defined per statistical endpoint (e.g., missing primary endpoint data rate, primary endpoint query rate).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this Key Risk Indicator (KRI) is defined. Links the KRI to its parent protocol and RBM monitoring plan.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which the KRI value is computed. A single KRI definition may produce one computed record per site, enabling site-level risk scoring within the RBM framework.',
    `alert_status` STRING COMMENT 'Current risk alert status of the KRI for the site, derived by comparing the computed value against amber and red thresholds. Drives site risk scoring and monitoring intensity decisions in the RBM framework.. Valid values are `green|amber|red|not_triggered`',
    `amber_threshold` DECIMAL(18,4) COMMENT 'Numeric threshold value at which the KRI triggers an amber (warning) alert, indicating elevated risk requiring heightened monitoring attention. Defined in the RBM monitoring plan.',
    `calculation_method` STRING COMMENT 'Formal description or formula specifying how the KRI value is computed (e.g., Number of screen failures / Number of subjects screened × 100). Ensures reproducibility and auditability of centralized statistical monitoring (CSM) outputs.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) must be initiated in response to the KRI breach. Drives workflow integration with MasterControl CAPA tracking.',
    `risk_indicator_category` STRING COMMENT 'Business category classifying the domain of risk the KRI monitors. Supports stratified risk reporting across enrollment, data quality, safety, protocol compliance, and Investigational Product (IP) accountability domains.. Valid values are `enrollment|data_quality|safety|protocol_compliance|ip_accountability`',
    `computation_date` DATE COMMENT 'Calendar date on which the KRI value was most recently computed for the site. Used to assess data currency and trigger recomputation schedules in the RBM monitoring plan.',
    `computation_frequency` STRING COMMENT 'Scheduled frequency at which the KRI is recomputed for each site (e.g., weekly for enrollment KRIs, monthly for data quality KRIs). Defined in the RBM monitoring plan.. Valid values are `daily|weekly|monthly|per_visit|ad_hoc`',
    `computation_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the KRI value was computed, including timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `computed_value` DECIMAL(18,4) COMMENT 'Current computed numeric value of the KRI for the associated site, derived from the source system data as of the last computation run. This is the principal quantitative fact of the risk indicator record.',
    `consecutive_breach_count` BIGINT COMMENT 'Number of consecutive computation cycles during which the KRI has remained at or above the amber or red threshold. Used to trigger escalation workflows and CAPA initiation per the RBM monitoring plan.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this KRI record was first created in the system, supporting audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `data_source` STRING COMMENT 'Operational system of record from which the KRI input data is extracted for computation (e.g., Medidata Rave EDC for data quality KRIs, the source system for safety KRIs, the source system for enrollment KRIs).. Valid values are `medidata_rave|oracle_clinical_one|oracle_argus_safety|siebel_ctms|sas_drug_development|manual`',
    `denominator_value` DECIMAL(18,4) COMMENT 'Raw denominator component of the KRI computation (e.g., total subjects screened, total expected data points, total SAEs reported). Stored alongside the numerator to enable independent verification of the computed value.',
    `effective_from` DATE COMMENT 'Date from which this KRI definition became active and applicable to the study and site. Supports versioning of KRI definitions when monitoring plan amendments are issued.',
    `effective_until` DATE COMMENT 'Date on which this KRI definition was superseded or retired. Null for currently active KRI definitions. Supports historical analysis and monitoring plan amendment tracking.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether the current KRI alert status and breach history require formal escalation to the sponsor, Data Safety Monitoring Board (DSMB), or senior management per the RBM escalation procedure.',
    `indicator_description` STRING COMMENT 'Detailed narrative description of what the KRI measures, its business rationale, and how it supports risk detection within the RBM framework.',
    `indicator_name` STRING COMMENT 'Human-readable name of the KRI as defined in the RBM monitoring plan (e.g., Screen Failure Rate, Missing Data Rate, SAE Reporting Timeliness). Used in dashboards, monitoring visit reports, and sponsor communications.',
    `indicator_status` STRING COMMENT 'Current lifecycle status of the KRI definition within the monitoring plan. Active KRIs are computed and monitored; draft KRIs are under review; retired KRIs are no longer in use.. Valid values are `active|inactive|draft|retired`',
    `indicator_type` STRING COMMENT 'Risk indicator type. Implements ICH E6(R2) GCP 5.0 risk-based quality management KRI/QTL concept.. Valid values are `rate|count|percentage|ratio|days`',
    `is_centralized_monitoring` BOOLEAN COMMENT 'Indicates whether this KRI is part of the Centralized Statistical Monitoring (CSM) program, as opposed to a site-level operational indicator. Supports differentiation of CSM KRIs from operational monitoring metrics.',
    `notes` STRING COMMENT 'Free-text field for CRA or data manager annotations regarding the KRI computation, alert status, or remediation context. Supports monitoring visit report narrative and sponsor communication.',
    `numerator_value` DECIMAL(18,4) COMMENT 'Raw numerator component of the KRI computation (e.g., number of screen failures, number of missing data points, number of overdue SAE reports). Stored to support audit and recomputation validation.',
    `prior_computed_value` DECIMAL(18,4) COMMENT 'KRI computed value from the immediately preceding computation cycle for the same site. Enables trend analysis and detection of rapid deterioration or improvement in site risk profile.',
    `red_threshold` DECIMAL(18,4) COMMENT 'Numeric threshold value at which the KRI triggers a red (critical) alert, indicating a significant risk requiring immediate escalation and corrective action per the RBM monitoring plan.',
    `reference_period_end` DATE COMMENT 'End date of the data window used to compute the KRI value. Together with reference_period_start, defines the exact temporal scope of the KRI computation for reproducibility and audit.',
    `reference_period_start` DATE COMMENT 'Start date of the data window used to compute the KRI value (e.g., rolling 30-day window start, or study start date for cumulative KRIs). Defines the temporal scope of the computation.',
    `risk_score_contribution` DECIMAL(5,2) COMMENT 'Weighted contribution of this KRI to the overall site risk score, expressed as a percentage (0–100). Reflects the KRIs relative importance in the composite site risk scoring model.',
    `sdv_impact` STRING COMMENT 'Defines the impact of this KRIs alert status on the Source Data Verification (SDV) strategy for the site. A red alert may trigger targeted or increased SDV; a green status may support reduced SDV per the risk-adaptive monitoring plan.. Valid values are `increase_sdv|decrease_sdv|no_change|trigger_targeted_sdv`',
    `sponsor_defined` BOOLEAN COMMENT 'Indicates whether this KRI was defined by the sponsor (True) or by the CRO as part of its standard RBM methodology (False). Supports differentiation of sponsor-mandated versus CRO-standard risk indicators.',
    `threshold_direction` STRING COMMENT 'Indicates whether the KRI alert is triggered when the computed value exceeds (above) or falls below (below) the defined amber/red thresholds. Critical for correct alert logic in centralized statistical monitoring (CSM).. Valid values are `above|below`',
    `trend_direction` STRING COMMENT 'Directional trend of the KRI value compared to the prior computation cycle. Supports proactive risk management by identifying sites where risk is worsening before threshold breach.. Valid values are `improving|stable|worsening|insufficient_data`',
    `unit_of_measure` STRING COMMENT 'Unit in which the KRI value and thresholds are expressed (e.g., %, days, count, ratio). Ensures consistent interpretation of computed values across sites and studies.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this KRI record, supporting change tracking and audit trail requirements under 21 CFR Part 11.',
    `version_number` STRING COMMENT 'Version identifier of the KRI definition (e.g., v1.0, v2.1), incremented when the calculation method, thresholds, or data source is amended. Supports audit trail and regulatory inspection readiness.. Valid values are `^vd+.d+$`',
    `weight` DECIMAL(5,2) COMMENT 'Numeric weight assigned to this KRI in the composite site risk scoring model, reflecting its relative importance compared to other KRIs in the monitoring plan. Used in weighted risk score calculations.',
    CONSTRAINT pk_risk_indicator PRIMARY KEY(`risk_indicator_id`)
) COMMENT 'Centralized monitoring risk indicator (also known as Key Risk Indicator or KRI) defined within the RBM monitoring plan. Captures indicator name, category (enrollment, data quality, safety, protocol compliance, IP accountability), calculation method';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` (
    `site_risk_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for each periodic site risk assessment record within the Risk-Based Monitoring (RBM) framework.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the associated CAPA record in MasterControl initiated as a result of findings from this risk assessment.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site entity being assessed within the RBM framework.',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_plan. Business justification: A site_risk_assessment is conducted within the framework of a monitoring_plan. The monitoring_plan defines the RBM strategy, KRI tolerance limits, and risk tier methodology that',
    `primary_site_employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) or Risk Manager who conducted this site risk assessment.',
    `reviewer_employee_id` BIGINT COMMENT 'Reference to the senior CRA, Clinical Trial Manager, or Risk Manager who reviewed and approved this risk assessment.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: Site-level monitoring risk assessments are informed by or linked to the broader compliance risk_assessment for the study/site.',
    `risk_id` BIGINT COMMENT 'Foreign key linking to program.program_risk. Business justification: Site risk assessments are a primary input to program-level risk identification. Program risk entries for enrollment, data quality, and site performance risks are directly sourced from',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this site risk assessment is being conducted.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational study site being assessed. Links this risk assessment to the specific site-study combination in the site domain.',
    `tmf_completeness_id` BIGINT COMMENT 'Foreign key linking to document.tmf_completeness. Business justification: RBM risk assessments incorporate TMF completeness as a direct risk factor — missing or overdue TMF documents elevate site risk tier.',
    `ae_reporting_timeliness_percent` DECIMAL(5,2) COMMENT 'Percentage of Adverse Events (AEs) reported within the protocol-defined and regulatory-required timeframes during the assessment period. A critical patient safety KRI.',
    `approval_date` DATE COMMENT 'Date on which the risk assessment was formally approved by the designated reviewer. Required for audit trail and regulatory inspection readiness.',
    `approval_status` STRING COMMENT 'Approval workflow status of this risk assessment. Must be approved by a qualified reviewer before the recommended monitoring intensity adjustments are enacted in the source system. Valid values are `pending|approved|rejected`',
    `assessment_date` DATE COMMENT 'The calendar date on which this periodic site risk assessment was performed. Drives the scheduling of the next assessment cycle.',
    `assessment_number` STRING COMMENT 'Externally-known, human-readable business identifier for this risk assessment record as tracked in the source system Follows the format SRA-{SiteCode}-{Year}-{Sequence}.. Valid values are `^SRA-[A-Z0-9]{4,10}-[0-9]{4}-[0-9]{3}$`',
    `assessment_period_end_date` DATE COMMENT 'End date of the data observation window used to calculate Key Risk Indicators (KRIs) and site performance metrics for this assessment.',
    `assessment_period_start_date` DATE COMMENT 'Start date of the data observation window used to calculate Key Risk Indicators (KRIs) and site performance metrics for this assessment.',
    `assessment_status` STRING COMMENT 'Current workflow lifecycle state of this risk assessment record in the source system Drives approval routing and downstream monitoring intensity decisions.. Valid values are `draft|in_review|approved|rejected|superseded`',
    `assessment_type` STRING COMMENT 'Classification of the risk assessment trigger: initial (first assessment at site activation), periodic (scheduled interval), triggered (unscheduled due to a risk signal or protocol deviation), or close_out (final assessment at study end).. Valid values are `initial|periodic|triggered|close_out`',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) plan is required as a result of this risk assessment. Set to TRUE when critical KRI breaches or major protocol deviations are identified.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this site risk assessment record was first created in the system. Required for audit trail and regulatory inspection readiness per 21 CFR Part 11 and ALCOA+ principles.',
    `critical_kri_breaches_count` BIGINT COMMENT 'Number of KRI breaches classified as critical severity (i.e., exceeding the upper alert threshold). Critical breaches may trigger immediate unscheduled monitoring visits or escalation.',
    `data_entry_lag_days` BIGINT COMMENT 'Average number of days between the date of clinical observation and the date of entry into the Electronic Data Capture (EDC) system (Medidata Rave) during the assessment period. A key KRI for data quality monitoring.',
    `enrollment_rate_percent` DECIMAL(5,2) COMMENT 'Actual subject enrollment as a percentage of the planned enrollment target for the assessment period. Significant under-enrollment is a KRI that may indicate site performance issues.',
    `kri_breaches_count` BIGINT COMMENT 'Total number of individual Key Risk Indicators (KRIs) that exceeded their defined threshold limits during the assessment period. A key input to the overall risk score calculation.',
    `major_protocol_deviation_count` BIGINT COMMENT 'Number of major (significant) protocol deviations recorded at the site during the assessment period. Major deviations may affect subject safety or data integrity and are a high-weight KRI.',
    `next_assessment_due_date` DATE COMMENT 'Scheduled due date for the next periodic site risk assessment, calculated based on the approved monitoring visit frequency and risk tier. Drives scheduling in the source system',
    `outstanding_queries_count` BIGINT COMMENT 'Number of open, unresolved data queries in the EDC system (Medidata Rave) at the end of the assessment period. Reflects site responsiveness and data management performance.',
    `overall_risk_score` DECIMAL(5,2) COMMENT 'Composite numeric risk score for the site calculated from weighted Key Risk Indicator (KRI) values. Higher scores indicate greater risk. Used to determine risk tier classification and adaptive monitoring intensity.',
    `previous_risk_score` DECIMAL(5,2) COMMENT 'Overall risk score from the immediately preceding assessment cycle. Enables trend analysis and score delta calculation to detect improving or deteriorating site performance.',
    `previous_risk_tier` STRING COMMENT 'Risk tier assigned during the immediately preceding assessment cycle. Used to identify tier escalations or de-escalations and trigger CAPA workflows when a site moves to a higher risk tier.. Valid values are `low|medium|high|critical`',
    `protocol_deviation_count` BIGINT COMMENT 'Total number of protocol deviations recorded at the site during the assessment period. Includes both major and minor deviations as classified per the study deviation management plan.',
    `query_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of Electronic Case Report Form (eCRF) fields that generated data queries during the assessment period. High query rates indicate data quality issues and are a primary KRI in the RBM framework.',
    `recommended_monitoring_intensity` STRING COMMENT 'Assessors recommendation for adjusting the monitoring visit frequency and SDV scope based on the current risk tier and KRI findings. Drives adaptive monitoring plan updates in the source system. Valid values are `increased|maintained|decreased`',
    `recommended_sdv_scope_percent` DECIMAL(5,2) COMMENT 'Recommended percentage of eCRF data fields to be subject to Source Data Verification (SDV) in the next monitoring cycle, adjusted based on the current risk tier.',
    `recommended_visit_frequency` STRING COMMENT 'Specific recommended visit frequency for the next monitoring cycle, derived from the risk tier and monitoring intensity recommendation. Used to update the site monitoring schedule in the source system. Valid values are `monthly|bi_monthly|quarterly|semi_annual|annual`',
    `risk_assessment_notes` STRING COMMENT 'Free-text narrative field capturing the assessors qualitative observations, contextual factors, and rationale for the risk score and recommended monitoring adjustments not captured by structured KRI fields.',
    `risk_management_plan_version` STRING COMMENT 'Version identifier of the study-level Risk Management Plan (RMP) under which this assessment was conducted. Ensures traceability of KRI thresholds and scoring methodology to the applicable plan version.',
    `risk_tier` STRING COMMENT 'Categorical risk tier assigned to the site based on the overall risk score thresholds defined in the Risk Management Plan. Directly drives monitoring visit frequency and Source Data Verification (SDV) scope in the source system. Valid values are `low|medium|high|critical`',
    `screen_failure_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of screened subjects who failed to meet eligibility criteria and were not enrolled during the assessment period. Elevated screen failure rates are a KRI for patient recruitment quality.',
    `sdv_completion_percent` DECIMAL(5,2) COMMENT 'Percentage of Source Data Verification (SDV) tasks completed against the planned SDV scope for the assessment period. Reflects monitoring coverage and data integrity assurance.',
    `source_system_record_reference` STRING COMMENT 'Native record identifier from the source system for this risk assessment record. Supports data lineage, reconciliation, and audit trail back to the operational system of record.',
    `subject_dropout_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of enrolled subjects who discontinued participation during the assessment period. High dropout rates are a KRI that may indicate site management or patient engagement issues.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this site risk assessment record. Required for change tracking, audit trail, and data lineage in the Databricks Silver Layer.',
    CONSTRAINT pk_site_risk_assessment PRIMARY KEY(`site_risk_assessment_id`)
) COMMENT 'Periodic risk assessment of an investigational site within the RBM framework. Captures overall site risk score, individual KRI values and threshold breaches, risk tier classification (low, medium, high), assessment date, assessor, recommended monitoring';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` (
    `monitoring_cra_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for the CRA assignment record in the monitoring domain. Primary key for this entity. Entity role: MASTER_AGREEMENT — represents a long-running binding assignment relationship between a CRA and a study site.',
    `cra_qualification_id` BIGINT COMMENT 'Foreign key linking to workforce.cra_qualification. Business justification: GCP ICH E6(R2) requires that only qualified monitors are assigned to sites. Linking cra_assignment to cra_qualification enables regulatory inspection-readiness verification that',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the risk-based monitoring (RBM) plan governing this assignment. Determines visit frequency, SDV scope, and remote vs. on-site monitoring strategy applicable to this CRA-site pairing.',
    `primary_monitoring_cra_employee_id` BIGINT COMMENT 'Reference to the CRA (Clinical Research Associate) employee record assigned to monitor this site-study combination. Sourced from the source system records and linked into the source system',
    `program_resource_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_resource_plan. Business justification: CRA assignments are the operational execution of the program resource plan. Resource planning teams reconcile planned FTE counts in program_resource_plan against actual',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to agreement.rate_card. Business justification: CRA assignments drive billable effort; the applicable rate card determines the billing rate for the CRAs staff grade and role.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: CRA assignments are authorized and scoped under a specific SOW that defines monitoring services, geographic scope, and staffing model.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: The monitoring CRA assignment (site-level) is the operational instantiation of the workforce study assignment (study-level staffing).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which the CRA is assigned monitoring responsibilities. Links the assignment to the study protocol and sponsor context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which the CRA holds monitoring responsibilities under this assignment. Drives site coverage and visit authorization in the source system',
    `subcontract_id` BIGINT COMMENT 'Foreign key linking to agreement.subcontract. Business justification: CRAs are frequently sourced from subcontractors (staffing agencies, regional CROs). The CRA assignment must reference the governing subcontract to ensure flow-down GCP obligations',
    `assignment_date` DATE COMMENT 'The actual business date on which the CRA was formally assigned to the site-study combination by the project manager or line manager. May differ from effective_start_date if there is a future-dated activation.',
    `assignment_notes` STRING COMMENT 'Free-text field for capturing additional context, special instructions, or qualifications relevant to this CRA-site assignment. May include site-specific monitoring considerations, language requirements, or sponsor-specific directives.',
    `assignment_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the CRA assignment record as generated by the source system (e.g., ASSGN-2024-00123). Used for cross-system reference, audit trails, and communication with sponsors and site teams.',
    `assignment_status` STRING COMMENT 'Current lifecycle state of the CRA assignment. pending indicates awaiting activation; active is the operational state; on_hold reflects temporary suspension; transferred indicates handover to another CRA; completed reflects study close-out. Valid values are `pending|active|on_hold|transferred|completed|cancelled`',
    `assignment_type` STRING COMMENT 'Classification of the CRAs role within this site-study assignment. primary indicates the main responsible CRA; backup covers absence; lead oversees a cluster of sites; co_monitor shares responsibilities; regional_lead manages a geographic. Valid values are `primary|backup|lead|co_monitor|regional_lead`',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) has been triggered for this CRA-site assignment due to identified quality issues, protocol deviations, or KRI breaches. When True, a CAPA record should exist in MasterControl.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the assigned site is located. Used for regulatory jurisdiction determination, travel planning, and regional reporting.. Valid values are `^[A-Z]{3}$`',
    `ctms_assignment_ref` STRING COMMENT 'Native assignment record identifier from the source system Preserved for cross-system traceability and reconciliation between the Databricks Silver layer and the operational source system.',
    `effective_end_date` DATE COMMENT 'Date on which the CRAs monitoring responsibilities for this site-study combination formally end. Nullable for open-ended assignments. Populated upon transfer, study close-out, or cancellation. Aligns with MASTER_AGREEMENT EFFECTIVE_UNTIL category.',
    `effective_start_date` DATE COMMENT 'Date on which the CRAs monitoring responsibilities for this site-study combination formally begin. Used for visit authorization windows and workload planning. Aligns with MASTER_AGREEMENT EFFECTIVE_FROM category.',
    `escalation_date` DATE COMMENT 'Date on which the most recent escalation was formally raised for this CRA-site assignment. Populated when escalation_status transitions to escalated. Used for SLA tracking and management reporting.',
    `escalation_status` STRING COMMENT 'Current escalation state for this CRA-site assignment. none indicates no escalation; flagged indicates a potential issue identified; escalated indicates formal escalation to management or sponsor; resolved indicates the escalation has been closed.. Valid values are `none|flagged|escalated|resolved`',
    `gcp_training_current` BOOLEAN COMMENT 'GCP training currency flag. Implements ICH E6(R2) GCP 2.8 investigator/monitor qualification concept.',
    `last_visit_date` DATE COMMENT 'Date of the most recently completed monitoring visit conducted by this CRA at the assigned site under this study. Used to calculate visit overdue status and schedule the next visit.',
    `monitoring_approach` STRING COMMENT 'Primary monitoring methodology authorized for this CRA-site assignment under the risk-based monitoring (RBM) plan. on_site requires physical presence; remote uses EDC and electronic review; hybrid combines both; centralized is performed by a. Valid values are `on_site|remote|hybrid|centralized`',
    `next_planned_visit_date` DATE COMMENT 'Scheduled date for the next monitoring visit by this CRA at the assigned site. Populated by the source system visit scheduling logic based on visit frequency and last visit date. Supports proactive workload planning.',
    `open_action_item_count` BIGINT COMMENT 'Number of currently open action items assigned to the site or CRA under this assignment in the source system Supports escalation workflows and site management oversight.',
    `open_protocol_deviation_count` BIGINT COMMENT 'Number of currently open protocol deviations identified by this CRA at the assigned site that have not yet been resolved or closed. Supports escalation decisions and CAPA tracking.',
    `open_query_count` BIGINT COMMENT 'Number of currently open data queries raised by this CRA against the assigned sites eCRF data in the EDC system (Medidata Rave). Used for site performance monitoring and CRA workload tracking.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CRA assignment record was first created in the system. Supports audit trail, data lineage, and ALCOA+ compliance requirements for clinical trial data integrity.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this CRA assignment record was most recently modified. Supports audit trail, change tracking, and ALCOA+ compliance requirements for clinical trial data integrity.',
    `remote_access_authorized` BOOLEAN COMMENT 'Indicates whether this CRA has been granted remote access authorization to the sites EDC system (Medidata Rave) and source data systems for remote monitoring activities under this assignment.',
    `sdv_scope_pct` DECIMAL(5,2) COMMENT 'Percentage of source data fields subject to Source Data Verification (SDV) for this CRA-site assignment as defined in the monitoring plan. Reflects the risk-based SDV strategy; lower values indicate targeted/risk-based SDV rather than 100% verification.',
    `sdv_strategy` STRING COMMENT 'Qualitative classification of the SDV strategy applied to this assignment. full requires 100% SDV; targeted focuses on specific data fields; risk_based applies adaptive SDV based on KRI signals; critical_data_only limits SDV to primary endpoints. Valid values are `full|targeted|risk_based|critical_data_only`',
    `site_count_assigned` BIGINT COMMENT 'Number of investigational sites assigned to this CRA under the current study at the time of this assignment record. Supports workload benchmarking and capacity management per CRA.',
    `site_initiation_authorized` BOOLEAN COMMENT 'Indicates whether this CRA is authorized to conduct the Site Initiation Visit (SIV) for the assigned site under this study. Authorization is contingent on GCP training currency and protocol training completion.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of this CRA assignment or assignment change. Populated when sponsor_notified is True. Supports audit trail and regulatory compliance.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this CRA assignment or any change to the assignment (e.g., transfer, status change). Supports sponsor oversight and regulatory compliance documentation.',
    `territory_code` STRING COMMENT 'Geographic or organizational territory code assigned to the CRA for this study, as defined in the source system territory management. Used for regional workload balancing, travel planning, and site coverage reporting.',
    `territory_name` STRING COMMENT 'Human-readable name of the geographic or organizational territory associated with this CRA assignment (e.g., Northeast US, Western Europe). Supports territory-based reporting and resource planning.',
    `total_visits_completed` BIGINT COMMENT 'Cumulative count of monitoring visits completed by this CRA at the assigned site under this study assignment. Supports workload reporting, performance evaluation, and site coverage tracking.',
    `transfer_date` DATE COMMENT 'Date on which the CRA assignment was formally transferred to another CRA. Populated when assignment_status transitions to transferred. Used for continuity tracking and audit purposes.',
    `transfer_reason` STRING COMMENT 'Free-text description of the reason for transferring this CRA assignment to another CRA. Populated when assignment_status transitions to transferred. Supports audit trail and continuity documentation per GCP requirements.',
    `visit_frequency_weeks` BIGINT COMMENT 'Target interval in weeks between monitoring visits for this CRA-site assignment as specified in the monitoring plan. Used for visit scheduling, overdue visit detection, and compliance reporting.',
    `workload_allocation_pct` DECIMAL(5,2) COMMENT 'Percentage of the CRAs total monitoring workload capacity allocated to this specific site-study assignment (0.00–100.00). Used for capacity planning, resource utilization reporting, and ensuring no CRA is over-allocated across concurrent assignments.',
    CONSTRAINT pk_monitoring_cra_assignment PRIMARY KEY(`monitoring_cra_assignment_id`)
) COMMENT 'Assignment record linking a CRA to a specific site and study for monitoring responsibilities. Captures assignment dates, type (primary, backup, lead CRA), territory, workload allocation percentage, and status.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` (
    `monitoring_visit_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for the planned monitoring visit schedule record within the source system',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) assigned to conduct this planned monitoring visit.',
    `monitoring_cra_assignment_id` BIGINT COMMENT 'Foreign key linking to monitoring.cra_assignment. Business justification: A visit_schedule is planned for a specific CRA-site-study assignment. The cra_assignment captures the CRA responsible for monitoring a site, and the visit_schedule defines when that',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the monitoring plan from which this scheduled visit is derived, linking the schedule to its governing risk-based monitoring (RBM) strategy.',
    `reconsent_trigger_id` BIGINT COMMENT 'Foreign key linking to consent.reconsent_trigger. Business justification: Protocol amendments or safety updates generate reconsent triggers requiring CRAs to schedule monitoring visits to verify reconsent completion.',
    `rescheduled_from_monitoring_visit_schedule_id` BIGINT COMMENT 'Self-referencing identifier pointing to the original visit schedule record from which this record was rescheduled. Enables audit trail of rescheduling history.',
    `risk_indicator_id` BIGINT COMMENT 'Reference to the risk indicator (KRI) that triggered this visit when scheduling_basis is Risk-Based Trigger. Links the scheduled visit to the specific risk signal that necessitated it.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the actual monitoring visit record created when this scheduled visit is executed. Null until the visit is initiated. Enables traceability from plan to execution.',
    `site_risk_assessment_id` BIGINT COMMENT 'Foreign key linking to monitoring.site_risk_assessment. Business justification: In risk-based monitoring (RBM), visit schedules are dynamically adjusted based on site risk assessments.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this monitoring visit is scheduled.',
    `study_protocol_milestone_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: RBM visit scheduling is explicitly triggered by milestone achievement (enrollment milestones drive monitoring frequency changes).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the monitoring visit is planned.',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why the planned monitoring visit was cancelled. Required when schedule_status is Cancelled. Supports audit and compliance review.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this visit schedule record was first created in the source system Supports audit trail requirements per ALCOA+ and 21 CFR Part 11.',
    `ctms_schedule_ref` STRING COMMENT 'The native record identifier or reference number for this visit schedule as stored in the source system Used for cross-system reconciliation between the lakehouse silver layer and the source CTMS.',
    `effective_from` DATE COMMENT 'The date from which this version of the visit schedule record is considered active and valid. Used for slowly changing dimension (SCD) tracking in the lakehouse silver layer.',
    `effective_until` DATE COMMENT 'The date until which this version of the visit schedule record is considered active. Null for the current active version. Used for SCD tracking in the lakehouse silver layer.',
    `enrollment_trigger_count` BIGINT COMMENT 'The cumulative number of subjects enrolled at the site that triggers this visit when scheduling_basis is Enrollment-Based (e.g., visit triggered after every 5 subjects enrolled).',
    `frequency_interval_days` BIGINT COMMENT 'The number of days between consecutive monitoring visits as defined in the monitoring plan. Drives calendar-based scheduling and CRA workload forecasting. Null for non-calendar-based visits.',
    `is_overdue` BOOLEAN COMMENT 'Indicates whether the planned monitoring visit has passed its window_latest_date without being completed or rescheduled. Used for escalation tracking and site risk assessment.',
    `is_rbm_triggered` BOOLEAN COMMENT 'Indicates whether this visit was triggered by the Risk-Based Monitoring (RBM) system (e.g., KRI breach, centralized monitoring signal) rather than by a pre-set calendar schedule.',
    `notification_due_date` DATE COMMENT 'The date by which the site (Principal Investigator and Clinical Research Coordinator) must be notified of the upcoming monitoring visit, per the monitoring plans advance notice requirements.',
    `notification_sent_date` DATE COMMENT 'The actual date on which the visit notification was sent to the investigational site. Used to verify compliance with advance notice requirements in the monitoring plan.',
    `planned_duration_days` DECIMAL(5,2) COMMENT 'The expected duration of the monitoring visit in days as planned in the monitoring schedule. Used for CRA capacity planning and resource allocation.',
    `planned_visit_date` DATE COMMENT 'The target calendar date on which the monitoring visit is planned to occur, representing the principal business event date for scheduling and CRA workload forecasting.',
    `priority_level` STRING COMMENT 'The priority assigned to this planned monitoring visit for CRA workload management and scheduling. Critical visits (e.g., for-cause, safety-triggered) take precedence over routine interim visits.. Valid values are `Critical|High|Medium|Low`',
    `rescheduling_reason` STRING COMMENT 'Free-text explanation for why the planned monitoring visit was rescheduled. Required when schedule_status is Rescheduled. Supports audit and compliance review.',
    `schedule_number` STRING COMMENT 'Externally-known business identifier for this visit schedule record as assigned in the source system (e.g., VS-2024-0042). Used for cross-system reference and audit trail.',
    `schedule_status` STRING COMMENT 'Current lifecycle state of the planned monitoring visit schedule record within the source system. Valid values are `Planned|Confirmed|In Progress|Completed|Cancelled|Rescheduled`',
    `scheduling_basis` STRING COMMENT 'The basis or rationale used to determine when this visit should occur: Calendar-Based (fixed interval), Risk-Based Trigger (driven by KRI/risk indicator breach), Milestone-Based (linked to study milestone such as first patient enrolled), Enrollment-Based. Valid values are `Calendar-Based|Risk-Based Trigger|Milestone-Based|Enrollment-Based|Regulatory-Required`',
    `sdv_scope` STRING COMMENT 'The Source Data Verification (SDV) scope category for this planned visit: 100% SDV (all data points), Risk-Based SDV (targeted by risk), Critical Data Only (primary endpoints and safety data), or No SDV (remote/centralized monitoring only).. Valid values are `100% SDV|Risk-Based SDV|Critical Data Only|No SDV`',
    `sdv_target_percentage` DECIMAL(5,2) COMMENT 'The planned percentage of source data to be verified during this monitoring visit as defined in the monitoring plan. Reflects the risk-based SDV strategy for this visit.',
    `sponsor_approval_date` DATE COMMENT 'The date on which the sponsor approved this planned monitoring visit schedule. Populated only when sponsor_approved is True.',
    `sponsor_approved` BOOLEAN COMMENT 'Indicates whether the sponsor has reviewed and approved this planned monitoring visit schedule, particularly relevant for risk-based or for-cause visits requiring sponsor authorization.',
    `updated_by` STRING COMMENT 'The username or system account identifier of the user who last modified this visit schedule record in the source system Required for audit trail per 21 CFR Part 11 and ALCOA+ (Attributable).',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this visit schedule record was most recently modified in the source system Supports audit trail requirements per ALCOA+ and 21 CFR Part 11.',
    `version_number` BIGINT COMMENT 'Incremental version number of this visit schedule record, incremented each time the schedule is modified (e.g., rescheduled, scope changed). Supports audit trail and change history per 21 CFR Part 11.',
    `visit_mode` STRING COMMENT 'Indicates whether the planned monitoring visit will be conducted on-site at the investigational site, remotely (e.g., via EDC review), or as a hybrid combining both approaches.. Valid values are `On-Site|Remote|Hybrid`',
    `visit_objectives` STRING COMMENT 'Free-text description of the specific objectives and scope of work planned for this monitoring visit, as defined in the monitoring plan or visit notification (e.g., ICF review, IP accountability, protocol deviation follow-up).',
    `visit_sequence_number` BIGINT COMMENT 'Sequential ordinal number of this planned visit within the sites monitoring schedule for the study (e.g., 1 = first interim visit, 2 = second interim visit). Used for ordering and CRA workload planning.',
    `visit_type` STRING COMMENT 'Classification of the planned monitoring visit by its purpose within the study lifecycle: Site Initiation Visit (SIV), Interim Monitoring Visit, Close-Out Visit, Remote Monitoring Visit, For-Cause Visit, or Pre-Study Visit.. Valid values are `Site Initiation Visit|Interim Monitoring Visit|Close-Out Visit|Remote Monitoring Visit|For-Cause Visit|Pre-Study Visit`',
    `window_earliest_date` DATE COMMENT 'The earliest acceptable date on which the monitoring visit may be conducted while still satisfying the monitoring plan window requirements. Used to define the permissible scheduling window.',
    `window_latest_date` DATE COMMENT 'The latest acceptable date on which the monitoring visit may be conducted while still satisfying the monitoring plan window requirements. Visits beyond this date are considered overdue.',
    `window_tolerance_days` BIGINT COMMENT 'The number of days of allowable deviation on either side of the planned visit date that defines the acceptable scheduling window (e.g., ±14 days). Used to compute window_earliest_date and window_latest_date.',
    `created_by` STRING COMMENT 'The username or system account identifier of the user who created this visit schedule record in the source system Required for audit trail per 21 CFR Part 11 and ALCOA+ (Attributable).',
    CONSTRAINT pk_monitoring_visit_schedule PRIMARY KEY(`monitoring_visit_schedule_id`)
) COMMENT 'Planned monitoring visit schedule for a site within a study, derived from the monitoring plan. Captures planned visit type, planned visit window (earliest and latest acceptable dates), visit frequency interval, basis for scheduling (risk-based trigger';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` (
    `ip_accountability_log_id` BIGINT COMMENT 'Unique surrogate identifier for each Investigational Product (IP) accountability verification record captured during a monitoring visit. Primary key for this entity.',
    `accountability_reconciliation_id` BIGINT COMMENT 'Foreign key linking to supply.accountability_reconciliation. Business justification: The CRAs ip_accountability_log (on-site verification record) and supplys accountability_reconciliation (formal IMP balance record) are complementary GCP documents for',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the CAPA record initiated in MasterControl as a result of IP accountability findings. Populated when capa_required is True.',
    `destruction_record_id` BIGINT COMMENT 'Foreign key linking to supply.destruction_record. Business justification: The ip_accountability_log has a destruction_records_reviewed flag; linking directly to the specific destruction_record reviewed provides the GCP audit trail required for IP',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who performed the IP accountability verification at the site.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: IP accountability logs verify specific investigational products per GCP requirements. ip_name and ip_code are denormalized from investigational_product.',
    `investigator_grant_id` BIGINT COMMENT 'Foreign key linking to agreement.investigator_grant. Business justification: IP accountability findings (discrepancies, storage non-compliance) can trigger grant payment holds or adjustments per investigator grant terms.',
    `kit_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.kit_inventory. Business justification: During monitoring visits, CRAs verify specific kit inventory records against physical stock and dispensing logs.',
    `randomization_kit_assignment_id` BIGINT COMMENT 'Foreign key linking to randomization.kit_assignment. Business justification: IP accountability reconciliation during monitoring visits requires direct comparison of dispensed/returned quantities against kit assignment records.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit during which this IP accountability verification was conducted by the Clinical Research Associate (CRA).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this IP accountability log record applies.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the IP accountability verification was performed.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IP accountability logs are GCP-required records filed in eTMF Zone 7 (Investigational Product).',
    `accountability_finding_severity` STRING COMMENT 'The severity classification of any IP accountability finding identified during the CRA verification. None indicates full compliance; Critical indicates a finding that may impact subject safety or data integrity and requires immediate escalation to the. Valid values are `none|minor|major|critical`',
    `batch_lot_number` STRING COMMENT 'The manufacturing batch or lot number of the investigational product as recorded on the IP label and dispensing records. Critical for traceability and recall management under GCP and GMP requirements.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) is required as a result of IP accountability findings identified during this monitoring visit. When True, a CAPA record must be initiated in MasterControl.',
    `cra_comments` STRING COMMENT 'Free-text comments entered by the CRA regarding the overall IP accountability verification, including observations about site practices, documentation quality, and any additional context not captured in structured fields.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this IP accountability log record was first created in the system, including timezone offset. Supports 21 CFR Part 11 electronic records audit trail requirements.',
    `destruction_records_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed IP destruction certificates or records during the monitoring visit to confirm that destroyed IP quantities are properly documented and authorized.',
    `discrepancy_notes` STRING COMMENT 'Free-text narrative describing the nature of any IP accountability discrepancy identified during the CRA verification, including potential explanations, site staff comments, and initial investigation findings.',
    `discrepancy_quantity` BIGINT COMMENT 'The numeric difference between the calculated IP balance (received minus dispensed minus returned minus destroyed) and the physical quantity on hand. A non-zero value indicates an accountability discrepancy requiring investigation and documentation.',
    `dispensing_log_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed the sites IP dispensing log during the monitoring visit to verify accuracy and completeness of dispensing records against subject randomization and dosing data.',
    `expiry_date` DATE COMMENT 'The expiration date of the investigational product batch/lot as printed on the label. CRA verifies that no expired IP has been dispensed to subjects. Non-compliance is a critical GCP finding.',
    `ip_form` STRING COMMENT 'The pharmaceutical dosage form of the investigational product (e.g., tablet, capsule, injection). Relevant for storage condition verification and dispensing record review.',
    `ip_label_compliance_verified` BOOLEAN COMMENT 'Indicates whether the CRA verified that IP labels comply with applicable regulatory requirements (e.g., correct language, required statements, batch/lot number, expiry date, storage conditions) per the approved labeling.',
    `ip_storage_location` STRING COMMENT 'The physical location identifier or description of where the investigational product is stored at the site (e.g., pharmacy refrigerator unit ID, locked cabinet reference). Verified by the CRA during the monitoring visit.',
    `ip_strength` STRING COMMENT 'The dose strength of the investigational product as labeled (e.g., 100 mg, 5 mg/mL). Used to verify that the correct strength was dispensed per the protocol and randomization assignment.',
    `log_number` STRING COMMENT 'Externally-known business identifier for this IP accountability log record, typically assigned by the Clinical Trial Management System (CTMS) or Electronic Data Capture (EDC) system (e.g., IPAL-2024-00123).',
    `quantity_destroyed` BIGINT COMMENT 'The total quantity of investigational product units destroyed at the site or returned to sponsor for destruction, as documented in the destruction records. Required for full IP accountability reconciliation.',
    `quantity_dispensed` BIGINT COMMENT 'The total quantity of investigational product units dispensed to study subjects at the site, as recorded in the dispensing log. Used in the IP accountability reconciliation calculation.',
    `quantity_on_hand` BIGINT COMMENT 'The physical count of investigational product units remaining in site inventory at the time of the CRA verification visit. Compared against the calculated balance (received minus dispensed minus returned minus destroyed) to identify discrepancies.',
    `quantity_received` BIGINT COMMENT 'The total quantity of investigational product units received at the site from the sponsor or depot, as recorded in the sites IP receipt log. Expressed in the unit of dispensing (e.g., number of tablets, vials, kits).',
    `quantity_returned` BIGINT COMMENT 'The total quantity of investigational product units returned by subjects to the site (unused or partially used), as recorded in the return log. Included in the reconciliation to account for all IP.',
    `quantity_unit` STRING COMMENT 'The unit of measure used for all IP quantity fields (received, dispensed, returned, destroyed, on hand) in this record (e.g., tablet, vial, kit). Ensures consistent interpretation of quantity values across reconciliation.',
    `reconciliation_status` STRING COMMENT 'The outcome status of the IP quantity reconciliation performed by the CRA. Balanced indicates quantities account for all IP; Discrepancy Identified indicates a mismatch requiring investigation. Drives CAPA and escalation workflows.. Valid values are `balanced|discrepancy_identified|pending_review|resolved|escalated`',
    `return_log_reviewed` BOOLEAN COMMENT 'Indicates whether the CRA reviewed the sites IP return log during the monitoring visit to verify that all returned IP units are documented with subject ID, return date, and quantity.',
    `review_period_end_date` DATE COMMENT 'The end date of the period covered by this IP accountability review (i.e., the date up to which IP transactions are being reconciled). Typically corresponds to the current monitoring visit date.',
    `review_period_start_date` DATE COMMENT 'The start date of the period covered by this IP accountability review (i.e., the date from which IP transactions are being reconciled). Typically corresponds to the date of the previous monitoring visit or last accountability check.',
    `rtsm_irt_reconciled` BOOLEAN COMMENT 'Indicates whether the sites physical IP accountability records have been reconciled against the RTSM/IRT system (e.g., Medidata Rave RTSM) dispensing and randomization data. Discrepancies between physical records and RTSM/IRT are a critical GCP finding.',
    `sponsor_notification_date` DATE COMMENT 'The date on which the sponsor was notified of IP accountability findings or discrepancies. Populated when sponsor_notified is True. Used to track timeliness of sponsor communication per GCP requirements.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the sponsor has been notified of IP accountability discrepancies, temperature excursions, or critical findings identified during this verification. Required for critical and major findings under GCP.',
    `storage_condition_verified` BOOLEAN COMMENT 'Indicates whether the CRA verified that the investigational product was stored under the protocol-specified conditions (e.g., temperature range, light protection, humidity) at the time of the monitoring visit.',
    `storage_temperature_max_c` DECIMAL(5,2) COMMENT 'The maximum temperature (in degrees Celsius) recorded in the IP storage area during the period under review, as verified by the CRA from temperature monitoring logs or data loggers. Used to assess compliance with protocol-specified storage conditions.',
    `storage_temperature_min_c` DECIMAL(5,2) COMMENT 'The minimum temperature (in degrees Celsius) recorded in the IP storage area during the period under review, as verified by the CRA from temperature monitoring logs or data loggers. Used to assess compliance with protocol-specified storage conditions.',
    `temperature_excursion_details` STRING COMMENT 'Free-text description of any temperature excursion identified, including the duration, magnitude, affected IP units, and any corrective actions taken by site staff. Populated only when temperature_excursion_occurred is True.',
    `temperature_excursion_occurred` BOOLEAN COMMENT 'Indicates whether a temperature excursion (storage outside the protocol-specified temperature range) was identified during the CRA review of temperature monitoring records. True triggers mandatory sponsor notification and potential IP quarantine.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this IP accountability log record was most recently modified, including timezone offset. Supports 21 CFR Part 11 electronic records audit trail and change tracking requirements.',
    `verification_date` DATE COMMENT 'The date on which the CRA performed the IP accountability verification at the site. This is the principal real-world event date for this record, distinct from the record creation timestamp. Required for GCP compliance documentation.',
    `verification_status` STRING COMMENT 'The current workflow status of this IP accountability log record. Draft indicates the CRA has initiated but not finalized the record; Completed indicates CRA sign-off; Reviewed indicates supervisor review; Approved indicates final approval. Valid values are `draft|completed|reviewed|approved|closed`',
    `verification_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the CRA completed the IP accountability verification, including timezone offset. Supports ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) audit trail requirements under 21 CFR Part 11.',
    CONSTRAINT pk_ip_accountability_log PRIMARY KEY(`ip_accountability_log_id`)
) COMMENT 'Investigational Product (IP) accountability verification record captured during monitoring visits. Records CRA verification of IP receipt, dispensing, return, and destruction records at the site level.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` (
    `escalation_record_id` BIGINT COMMENT 'Unique surrogate identifier for the escalation record within the Databricks Silver Layer. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Escalations triggered by AE reporting failures (unreported SAE, missed expedited reporting deadline) must reference the specific adverse_event for regulatory traceability.',
    `central_monitoring_alert_id` BIGINT COMMENT 'Foreign key linking to monitoring.central_monitoring_alert. Business justification: Escalation records can be triggered by centralized monitoring alerts (CSM alerts) when KRI thresholds are breached and not resolved.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the CAPA record associated with this escalation, when the escalation is driven by an unresolved or overdue CAPA. Managed in MasterControl.',
    `consent_deviation_id` BIGINT COMMENT 'Foreign key linking to consent.consent_deviation. Business justification: Serious consent deviations (subject enrolled without valid consent, wrong ICF version) trigger formal escalation. escalation_record has no FK to consent_deviation.',
    `contract_obligation_id` BIGINT COMMENT 'Foreign key linking to agreement.contract_obligation. Business justification: Monitoring escalations (unresolved critical findings, repeated GCP deviations, sponsor notification triggers) activate specific contract obligations.',
    `governance_id` BIGINT COMMENT 'Foreign key linking to program.program_governance. Business justification: High-severity monitoring escalations (critical GCP findings, subject safety impacts) are reviewed by program governance bodies (steering committee, DSMB).',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to the specific health authority that was or must be notified.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Critical value escalation pathway (regulatory requirement per ICH E6 and sponsor SOPs): when a critical lab value is not acted upon within SLA, an escalation is raised.',
    `monitoring_action_item_id` BIGINT COMMENT 'Reference to the unresolved action item that triggered this escalation, when the escalation is driven by an overdue action item.',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the monitoring plan under which this escalation was raised, linking the escalation to the defined escalation thresholds and procedures.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: When a monitoring escalation is raised, it is formally directed to a named sponsor contact (the sponsors designated escalation point of contact).',
    `primary_escalation_employee_id` BIGINT COMMENT 'Reference to the CRA (Clinical Research Associate) who initiated and raised this escalation record.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the protocol deviation record that triggered this escalation, when the escalation is driven by an unresolved or critical protocol deviation.',
    `reconsent_trigger_id` BIGINT COMMENT 'Foreign key linking to consent.reconsent_trigger. Business justification: Overdue reconsent triggers (subjects not reconsented by deadline after protocol amendment) are escalated per regulatory requirements.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_inspection. Business justification: Escalated GCP findings (subject safety, data integrity) are a primary focus of regulatory inspections.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit (on-site or remote) during which the finding triggering this escalation was identified. Nullable when escalation originates from centralized monitoring or CAPA review rather than a visit.',
    `site_risk_assessment_id` BIGINT COMMENT 'Foreign key linking to monitoring.site_risk_assessment. Business justification: An escalation can be triggered when a site risk assessment reveals the site has moved to a high-risk tier or has critical KRI breaches exceeding thresholds.',
    `sponsor_escalation_id` BIGINT COMMENT 'Foreign key linking to sponsor.escalation. Business justification: A site-level monitoring escalation (critical GCP finding, patient safety issue) triggers a formal sponsor-side escalation record for governance review.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this escalation was raised.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the escalation-triggering finding originated.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Escalated GCP findings (urgent safety measures, clinical holds) require regulatory submissions.',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.susar. Business justification: Escalations for SUSAR reporting non-compliance (site failed to notify within 7/15-day clock) must reference the specific SUSAR.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Escalation records involving subject safety or regulatory reporting must be filed in the eTMF. Inspectors require traceability from escalation records to their filed documents.',
    `trial_subject_id` BIGINT COMMENT 'Foreign key linking to subject.trial_subject. Business justification: Subject-safety escalations (unreported SAEs, ICF violations, subject rights breaches) require direct traceability to the specific subject for regulatory reporting and subject protection',
    `acknowledgement_date` DATE COMMENT 'The date on which the health authority formally acknowledged receipt of the notification. Null until acknowledgement is received. Required for regulatory compliance audit trails.',
    `acknowledgement_reference` STRING COMMENT 'The reference number or tracking ID issued by the health authority upon acknowledgement of the notification submission. Used for follow-up correspondence.',
    `closed_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the escalation record was formally closed in the source system Distinct from resolution_date (day-level) — provides exact closure time for SLA measurement and audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this escalation record was first created in the source system (the source system Supports audit trail requirements under 21 CFR Part 11 and ALCOA+.',
    `data_integrity_impact` BOOLEAN COMMENT 'Indicates whether the escalated finding compromises the integrity of clinical trial data, potentially affecting regulatory submissions (IND, NDA, BLA, MAA) or database lock (DBL) timelines.',
    `days_overdue_at_escalation` BIGINT COMMENT 'Number of calendar days the action item, CAPA, or deviation was overdue at the time the escalation was formally raised. Used for SLA breach analysis and KPI reporting.',
    `escalation_date` DATE COMMENT 'The calendar date on which the escalation was formally raised and submitted in the source system Principal business event date for SLA and timeline calculations.',
    `escalation_description` STRING COMMENT 'Detailed narrative describing the finding, issue, or non-compliance that necessitated the escalation, including context, timeline of prior resolution attempts, and impact on subject safety or data integrity.',
    `escalation_due_date` DATE COMMENT 'Target date by which the escalated issue must be resolved or a response received from the notified party, as defined in the monitoring plan or SOP.',
    `escalation_level` STRING COMMENT 'Hierarchical level of the escalation indicating the parties involved: CRA to Lead CRA, Lead CRA to Sponsor Medical Monitor, Sponsor to IRB/IEC, or Sponsor to Regulatory Authority. Reflects the escalation chain defined in the monitoring plan.. Valid values are `cra_to_lead_cra|lead_cra_to_sponsor_medical_monitor|sponsor_to_irb_iec|sponsor_to_regulatory_authority|management_escalation`',
    `escalation_status` STRING COMMENT 'Current lifecycle state of the escalation record within the source system workflow. Drives SLA tracking and reporting dashboards.. Valid values are `open|in_progress|resolved|closed|cancelled`',
    `escalation_title` STRING COMMENT 'Short, human-readable title summarizing the nature of the escalation, used for display in CTMS dashboards and escalation registers.',
    `escalation_trigger_type` STRING COMMENT 'Classification of the root cause or event that triggered this escalation. Drives routing logic and notification workflows in the source system [ENUM-REF-CANDIDATE. Valid values are `overdue_action_item|overdue_capa|critical_gcp_finding|protocol_deviation|unresolved_query|risk_indicator_breach`',
    `follow_up_due_date` DATE COMMENT 'Target date by which the follow-up verification action must be completed, when follow_up_required is True.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether a follow-up action or verification visit is required after resolution of this escalation to confirm effectiveness of corrective actions.',
    `gcp_finding_category` STRING COMMENT 'Severity classification of the GCP finding that triggered the escalation, aligned with ICH E6(R2) and FDA/EMA inspection classification standards. Critical findings require immediate sponsor or regulatory notification.. Valid values are `critical|major|minor|other`',
    `irb_iec_notification_date` DATE COMMENT 'Date on which the IRB or IEC was formally notified of this escalation. Required for audit trail and regulatory compliance documentation.',
    `irb_iec_notified` BOOLEAN COMMENT 'IRB/IEC notification flag. Implements ICH E6(R2) GCP 4.5.1 IRB/IEC notification concept.',
    `notification_date` DATE COMMENT 'The calendar date on which the formal notification was submitted to this specific health authority. Distinct per authority — a single escalation may notify FDA on day 1 and EMA on day 2.',
    `notification_method` STRING COMMENT 'The channel or mechanism used to deliver the notification to this health authority (e.g., eCTD gateway submission, official email, regulatory portal upload). May differ per authority.',
    `notification_status` STRING COMMENT 'Current lifecycle state of the notification for this specific health authority. Tracks whether the authority has acknowledged receipt, allowing compliance teams to chase outstanding acknowledgements.',
    `notified_parties` STRING COMMENT 'Free-text or structured list of all parties formally notified of this escalation (e.g., Lead CRA, Sponsor Medical Monitor, IRB/IEC, Regulatory Authority, DSMB/DMC). Supports audit trail requirements under ALCOA+.',
    `prior_resolution_attempts` BIGINT COMMENT 'Number of documented resolution attempts made before the issue was formally escalated. Supports root cause analysis and process improvement.',
    `priority` STRING COMMENT 'Priority level assigned to this escalation record, reflecting urgency of resolution. Critical priority triggers immediate sponsor and regulatory notification workflows.. Valid values are `critical|high|medium|low`',
    `regulatory_authority_notified` STRING COMMENT 'Name or code of the regulatory authority (e.g., FDA, EMA, PMDA, MHRA, TGA, Health Canada) formally notified of this escalation, when regulatory_reporting_required is True.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Regulatory reporting required flag. Implements ICH E6(R2) GCP 5.20 regulatory reporting concept.',
    `resolution_date` DATE COMMENT 'The calendar date on which the escalated issue was formally resolved and the escalation record was closed. Null if still open.',
    `resolution_description` STRING COMMENT 'Narrative description of the actions taken and outcome achieved to resolve the escalated issue. Captured upon closure of the escalation record in the source system',
    `resolution_outcome` STRING COMMENT 'Categorical outcome of the escalation resolution process. Drives downstream CAPA creation, site management decisions, and regulatory reporting workflows.. Valid values are `resolved_with_capa|resolved_without_capa|escalated_further|site_terminated|study_suspended|no_action_required`',
    `risk_based_monitoring_flag` BOOLEAN COMMENT 'Indicates whether this escalation was triggered through the risk-based monitoring (RBM) program, as opposed to routine on-site monitoring. Supports RBM effectiveness analytics.',
    `source_system_record_reference` STRING COMMENT 'Native record identifier from the source system for this escalation record, used for data lineage traceability and reconciliation between the source system and the Databricks Silver Layer.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of this escalation. Used for regulatory timeline compliance tracking.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this escalation. Required for critical GCP findings and safety-impacting deviations per ICH E6(R2).',
    `subject_safety_impact` BOOLEAN COMMENT 'Indicates whether the escalated finding has a direct or potential impact on subject safety. When True, triggers expedited notification workflows to the Sponsor Medical Monitor and IRB/IEC.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this escalation record in the source system. Supports change tracking and audit trail requirements under 21 CFR Part 11.',
    CONSTRAINT pk_escalation_record PRIMARY KEY(`escalation_record_id`)
) COMMENT 'Formal escalation record raised when action items, protocol deviations, or CAPAs are not resolved within defined timelines or when critical GCP findings require sponsor or management intervention.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` (
    `visit_checklist_id` BIGINT COMMENT 'Primary key for visit_checklist',
    `checklist_item_id` BIGINT COMMENT 'Reference to the specific checklist item definition (e.g., regulatory binder review, ICF verification, IP accountability) from the template. Each row in',
    `checklist_template_id` BIGINT COMMENT 'Reference to the versioned checklist template (SOP-driven) from which this checklist instance was generated. Supports template versioning and SOP compliance tracking.',
    `consent_icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: Visit checklists include mandatory ICF review items verifying the current approved ICF version is in use at the site.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Visit checklist items are executed per specific SOPs — CRAs must verify SOP compliance during monitoring visits.',
    `monitoring_action_item_id` BIGINT COMMENT 'Reference to the action item record created in the source system as a result of a finding on this checklist item. Enables traceability from checklist finding to resolution.',
    `primary_visit_employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who executed and signed off on this monitoring checklist during the visit.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to a protocol deviation record identified and linked to this checklist item finding. Enables traceability between monitoring checklist findings and formal protocol deviation management.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit during which this checklist was executed. Links the checklist to the parent visit record in the monitoring domain.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this monitoring checklist was completed. Enables study-level aggregation of checklist compliance.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the monitoring visit and checklist execution occurred.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Visit checklists are structured around protocol-defined visit schedules. CRAs use the visit schedule to verify all required procedures were performed and documented at each visit.',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: Monitoring checklists are completed during a visit and their results feed directly into the visit_report.',
    `action_required` BOOLEAN COMMENT 'Indicates whether a follow-up action item has been raised for this checklist item (True) due to a finding or non-compliance. Triggers action item creation workflow in the source system',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) is required for the finding identified on this checklist item. Critical and major findings typically mandate CAPA initiation per GCP and SOP requirements.',
    `checklist_number` STRING COMMENT 'Externally-known business identifier for the checklist record, typically generated by the source system (e.g., CHK-2024-00123). Used for cross-system reference and audit trail.',
    `checklist_status` STRING COMMENT 'Current lifecycle status of the overall monitoring checklist record. Tracks progression from initial creation through CRA sign-off. void indicates the checklist was invalidated (e.g., visit cancelled).. Valid values are `draft|in_progress|completed|signed_off|void`',
    `checklist_version` STRING COMMENT 'Version identifier of the checklist template used for this visit instance (e.g., v3.1). Versioned per SOP updates managed in MasterControl. Ensures the correct template version is applied per effective date.',
    `completion_status` STRING COMMENT 'Per-item completion status recorded by the CRA during the monitoring visit. failed indicates the item was assessed and found non-compliant, triggering a finding or action item.. Valid values are `not_started|in_progress|completed|not_applicable|failed`',
    `cra_comment` STRING COMMENT 'Free-text comment entered by the CRA for this checklist item, capturing observations, context, or follow-up notes that do not constitute a formal finding. Supports inspection readiness and knowledge transfer.',
    `cra_signoff_timestamp` TIMESTAMP COMMENT 'Date and time at which the CRA electronically signed off on this checklist item or the overall checklist, per 21 CFR Part 11 electronic signature requirements. Captures the precise moment of attestation.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this monitoring checklist record was first created in the source system. Supports audit trail, ALCOA+ compliance, and data lineage tracking in the Silver Layer.',
    `finding_description` STRING COMMENT 'Narrative description of the finding or non-compliance identified for this checklist item. Populated by the CRA when completion_status is failed or finding_severity is not none. Supports monitoring visit report generation.',
    `finding_severity` STRING COMMENT 'Severity classification of any finding identified during assessment of this checklist item. Aligns with GCP inspection-readiness severity tiers. none when item is compliant.. Valid values are `critical|major|minor|observation|none`',
    `inspection_ready_flag` BOOLEAN COMMENT 'Indicates whether this checklist record has been reviewed and confirmed as inspection-ready (True) for regulatory authority inspections (FDA, EMA, MHRA, PMDA). Set during quality review cycles.',
    `is_applicable` BOOLEAN COMMENT 'Indicates whether this checklist item is applicable for the specific visit instance (True) or has been marked not applicable (N/A) by the CRA with justification. Supports conditional checklist logic.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this checklist item is mandatory (True) or optional (False) for the given visit type. Mandatory items must be completed for the checklist to be signed off. Drives compliance scoring.',
    `item_category` STRING COMMENT 'Functional category of the checklist item being assessed. Groups items for reporting and compliance tracking. [ENUM-REF-CANDIDATE',
    `item_completed_date` DATE COMMENT 'Date on which the CRA completed the assessment of this specific checklist item. May differ from visit_date for multi-day visits or remote follow-up assessments. Supports ALCOA+ contemporaneous documentation.',
    `item_description` STRING COMMENT 'Detailed description of what the CRA must verify or perform for this checklist item, including acceptance criteria and reference to applicable SOP or regulatory requirement.',
    `item_name` STRING COMMENT 'Human-readable name of the specific checklist item being assessed (e.g., Regulatory Binder Current, ICF Version Verification, IP Accountability Log Review). Sourced from the checklist template.',
    `item_sequence` BIGINT COMMENT 'Ordinal sequence number of this checklist item within its category, defining the display and execution order for the CRA during the monitoring visit. Sourced from the checklist template definition.',
    `not_applicable_reason` STRING COMMENT 'Free-text justification provided by the CRA when marking a checklist item as not applicable (is_applicable = False). Required for mandatory items marked N/A to maintain audit trail per ALCOA+ principles.',
    `rbm_triggered` BOOLEAN COMMENT 'Indicates whether this checklist item was triggered or prioritized by the risk-based monitoring (RBM) strategy (True), as opposed to being a standard routine item. Supports RBM effectiveness reporting.',
    `regulatory_reference` STRING COMMENT 'Regulatory/GCP reference. Implements ICH E6(R2) Good Clinical Practice guideline reference.',
    `sdv_performed` BOOLEAN COMMENT 'Indicates whether Source Data Verification (SDV) was performed as part of this checklist item assessment (True). Relevant for eCRF and data entry checklist items under risk-based monitoring (RBM) strategies.',
    `source_system_record_reference` STRING COMMENT 'Original record identifier from the source system or MasterControl from which this checklist record was sourced. Supports data lineage, reconciliation, and audit trail in the Databricks Silver Layer.',
    `supervisor_review_timestamp` TIMESTAMP COMMENT 'Date and time at which the CRA supervisor or line manager reviewed and approved the completed checklist. Supports quality oversight and two-level sign-off workflows per GCP requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this monitoring checklist record was last modified in the source system. Supports change tracking, audit trail, and incremental data loading in the Databricks Silver Layer.',
    `visit_date` DATE COMMENT 'The actual date on which the monitoring visit and checklist execution occurred. Principal business event date for this checklist record. Used for compliance reporting and visit frequency analysis.',
    `visit_mode` STRING COMMENT 'Modality of the monitoring visit — on-site, remote, or hybrid. Affects which checklist items are applicable and how source data verification (SDV) is conducted under risk-based monitoring (RBM) strategies.. Valid values are `on_site|remote|hybrid`',
    `visit_type` STRING COMMENT 'Type of monitoring visit for which this checklist was used. Determines which checklist items are applicable (e.g., site initiation visits include regulatory binder setup items not present in interim visits).. Valid values are `site_initiation|interim|close_out|remote|for_cause`',
    CONSTRAINT pk_visit_checklist PRIMARY KEY(`visit_checklist_id`)
) COMMENT 'Monitoring checklist template and completion record used by CRAs during visits. Defines checklist items (regulatory binder, ICF, IP accountability, eCRF, safety reporting), item categories, mandatory/optional flags, and captures per-item completion status';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` (
    `central_monitoring_alert_id` BIGINT COMMENT 'Unique surrogate identifier for the central monitoring alert record in the Databricks Silver Layer. Primary key for this entity. Entity role: TRANSACTION_HEADER — represents a discrete business event (alert generation) with a clear lifecycle from',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the Corrective and Preventive Action (CAPA) record opened in MasterControl as a result of this alert. Null when capa_required is False or CAPA has not yet been created.',
    `consent_deviation_id` BIGINT COMMENT 'Foreign key linking to consent.consent_deviation. Business justification: Central monitoring KRIs include consent deviation rates. When a central monitoring alert is triggered by consent-related signals, linking central_monitoring_alert →',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) or central monitoring team member assigned to review and disposition this alert. PARTY_REFERENCE category per TRANSACTION_HEADER role.',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the risk-based monitoring (RBM) plan under which this alert was generated, linking the alert to the governing monitoring strategy and threshold configuration.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Central monitoring alerts requiring sponsor notification must be routed to a named sponsor contact (safety contact or clinical operations lead).',
    `prior_alert_central_monitoring_alert_id` BIGINT COMMENT 'Reference to the most recent prior central_monitoring_alert record for the same KRI and site, enabling trend analysis and repeat breach tracking. Null when is_repeat_alert is False.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to the protocol deviation record raised as a result of this alert when the disposition is PROTOCOL_DEVIATION_RAISED. Null when no protocol deviation is associated.',
    `rand_deviation_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_deviation. Business justification: Centralized monitoring of randomization KRIs (allocation imbalance, IRT error rates, unexpected arm distribution) generates central_monitoring_alerts that must be traceable to',
    `risk_id` BIGINT COMMENT 'Foreign key linking to program.program_risk. Business justification: Central monitoring alerts that breach thresholds are escalated to the program risk register.',
    `risk_indicator_id` BIGINT COMMENT 'Reference to the specific Key Risk Indicator (KRI) or centralized statistical monitoring (CSM) signal that triggered this alert. Null when the alert is manually triggered without a specific KRI linkage.',
    `safety_report_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.safety_report_submission. Business justification: Central monitoring alerts on SAE reporting timeliness KRI breaches or aggregate safety signals directly trigger expedited safety report submissions (IND safety reports',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: Central monitoring alerts triggered by safety signal detection (elevated AE rate for a MedDRA term) must reference the safety_signal driving the alert.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Reference to the monitoring visit (on-site or remote) triggered or linked to this alert as a result of the escalation disposition. Null when no visit has been triggered. Links to the monitoring_visit product.',
    `statistical_endpoint_id` BIGINT COMMENT 'Foreign key linking to biostatistics.statistical_endpoint. Business justification: RBM frameworks (TransCelerate, ICH E6(R2)) generate central monitoring alerts specifically for endpoint-critical data quality issues (e.g., missing primary endpoint data',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this central monitoring alert was generated. Links the alert to the study protocol context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the anomaly or Key Risk Indicator (KRI) threshold breach was detected. Core contextual dimension for risk-based monitoring (RBM) triage.',
    `tmf_completeness_id` BIGINT COMMENT 'Foreign key linking to document.tmf_completeness. Business justification: Central monitoring alerts are triggered by TMF completeness KRI breaches (e.g., missing document rate exceeding threshold).',
    `alert_category` STRING COMMENT 'Broad business domain category of the alert, used for routing, reporting, and escalation prioritization. DATA_QUALITY: data entry or consistency issues. SAFETY: adverse event or safety reporting concerns.. Valid values are `DATA_QUALITY|SAFETY|ENROLLMENT|PROTOCOL_COMPLIANCE|REGULATORY|OPERATIONAL`',
    `alert_generated_timestamp` TIMESTAMP COMMENT 'Date and time when the alert was generated by the centralized statistical monitoring (CSM) system or manually created by a central monitor. This is the principal real-world business event time. BUSINESS_EVENT_TIMESTAMP category.',
    `alert_number` STRING COMMENT 'Human-readable, externally-known business identifier for the alert, formatted as CMA-{YYYY}-{NNNNNN}. Used in communications, reports, and audit trails to uniquely reference an alert across systems. Sourced from the source system. Valid values are `^CMA-[0-9]{4}-[0-9]{6}$`',
    `alert_severity` STRING COMMENT 'Risk-stratified severity level of the alert, driving escalation urgency and response timelines. CRITICAL: immediate action required, potential patient safety or data integrity risk. HIGH: significant risk requiring prompt review within defined SLA.. Valid values are `CRITICAL|HIGH|MEDIUM|LOW`',
    `alert_status` STRING COMMENT 'Current lifecycle state of the alert within the review and disposition workflow. OPEN: generated and awaiting assignment. UNDER_REVIEW: assigned reviewer is actively assessing. ESCALATED: elevated to on-site visit or senior oversight.. Valid values are `OPEN|UNDER_REVIEW|ESCALATED|CLOSED|CANCELLED`',
    `alert_type` STRING COMMENT 'Classification of the alert by the nature of the triggering condition. KRI_THRESHOLD_BREACH: a Key Risk Indicator exceeded its amber or red threshold. DATA_ANOMALY: a data pattern inconsistency detected by the centralized statistical monitoring (CSM). Valid values are `KRI_THRESHOLD_BREACH|DATA_ANOMALY|STATISTICAL_OUTLIER|MANUAL|ENROLLMENT_SIGNAL|SAFETY_SIGNAL`',
    `assignment_date` DATE COMMENT 'Date on which the alert was assigned to a reviewer for investigation. Used to measure assignment SLA compliance from alert generation to assignment.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) must be initiated as a result of this alert. Set to True when disposition is CAPA_INITIATED or when a confirmed critical finding requires systematic remediation.',
    `consecutive_breach_count` BIGINT COMMENT 'Number of consecutive computation cycles in which the triggering KRI has breached its threshold at this site prior to and including this alert. A higher count indicates a persistent risk pattern and informs escalation urgency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this alert record was first created in the Databricks Silver Layer. Distinct from alert_generated_timestamp which captures the business event time. RECORD_AUDIT_CREATED category.',
    `disposition` STRING COMMENT 'Action decision made following review of the alert. ESCALATE_ONSITE_VISIT: alert severity warrants an unscheduled or triggered on-site monitoring visit. REMOTE_FOLLOW_UP: issue to be addressed via remote monitoring or site communication.. Valid values are `ESCALATE_ONSITE_VISIT|REMOTE_FOLLOW_UP|NO_ACTION_REQUIRED|CAPA_INITIATED|PROTOCOL_DEVIATION_RAISED`',
    `escalation_date` DATE COMMENT 'Date on which the alert was formally escalated to a higher oversight level. Null when escalation_required is False. Used to track escalation timeliness and compliance with monitoring plan escalation SLAs.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether this alert has been escalated to a higher level of oversight (e.g., sponsor, Data Safety Monitoring Board (DSMB), or senior management). True when disposition is ESCALATE_ONSITE_VISIT or when severity is CRITICAL.',
    `is_repeat_alert` BOOLEAN COMMENT 'Indicates whether this alert is a recurrence of a previously closed alert for the same KRI and site within the current study. True when a prior alert for the same KRI-site combination was closed and the KRI has breached again, signaling unresolved',
    `kri_code` STRING COMMENT 'Key risk indicator code. Implements ICH E6(R2) GCP 5.0 risk-based monitoring KRI concept.',
    `kri_name` STRING COMMENT 'Human-readable name of the Key Risk Indicator (KRI) that triggered the alert (e.g., Adverse Event Reporting Timeliness, Query Resolution Rate). Denormalized for alert reporting and dashboard display without requiring a join to the risk_indicator',
    `observed_value` DECIMAL(18,4) COMMENT 'The actual computed value of the Key Risk Indicator (KRI) or data signal at the time the alert was generated. Compared against threshold_value to confirm the breach. QUANTITATIVE_RESULT category per TRANSACTION_HEADER non-monetary role.',
    `reference_period_end` DATE COMMENT 'End date of the data analysis window used by the centralized statistical monitoring (CSM) system to compute the KRI value that triggered this alert. Together with reference_period_start, defines the exact data window under review.',
    `reference_period_start` DATE COMMENT 'Start date of the data analysis window used by the centralized statistical monitoring (CSM) system to compute the KRI value that triggered this alert. Defines the temporal scope of the anomaly.',
    `review_completed_date` DATE COMMENT 'Actual date on which the reviewer completed the assessment and recorded a disposition for the alert. Used to calculate review cycle time and SLA compliance.',
    `review_due_date` DATE COMMENT 'Target date by which the assigned reviewer must complete the review and disposition of the alert, as defined by the monitoring plan SLA for the given alert severity level.',
    `review_narrative` STRING COMMENT 'Free-text narrative entered by the reviewer documenting the findings, rationale for the review outcome, and justification for the chosen disposition. Supports audit trail and regulatory inspection readiness per ALCOA+ principles.',
    `review_outcome` STRING COMMENT 'Conclusion reached by the reviewer after investigating the alert. CONFIRMED: the anomaly or KRI breach is genuine and requires action. FALSE_POSITIVE: the alert was triggered in error or the signal is not clinically meaningful.. Valid values are `CONFIRMED|FALSE_POSITIVE|INCONCLUSIVE|PENDING`',
    `source_system_record_reference` STRING COMMENT 'Native record identifier from the originating operational system (the source system or CSM engine) for this alert. Enables lineage tracing and reconciliation between the Silver Layer and the system of record.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of this alert. Null when sponsor_notified is False. Used to verify compliance with sponsor notification SLAs defined in the monitoring plan.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this alert, as required for critical or high-severity alerts under the monitoring plan and sponsor oversight obligations per ICH E6(R2).',
    `threshold_type` STRING COMMENT 'Indicates whether the breached threshold was the amber (warning) or red (action-required) threshold level as defined in the monitoring plan. Drives escalation logic and response SLA.. Valid values are `AMBER|RED`',
    `threshold_value` DECIMAL(18,4) COMMENT 'The amber or red threshold value that was breached at the time the alert was generated. Captured at alert generation time to preserve the threshold configuration in effect, as thresholds may be revised over the study lifecycle.',
    `trigger_source` STRING COMMENT 'System or process that generated the alert. AUTOMATED_CSM: centralized statistical monitoring (CSM) engine. MANUAL_ENTRY: entered directly by a central monitor.. Valid values are `AUTOMATED_CSM|MANUAL_ENTRY|EDC_INTEGRATION|CTMS_RULE|SAFETY_SYSTEM`',
    `unit_of_measure` STRING COMMENT 'Unit in which the observed_value and threshold_value are expressed (e.g., percent, days, count, ratio). Required for correct interpretation of the KRI metric values in alert review and reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this alert record was last modified in the Databricks Silver Layer, capturing status changes, review updates, and disposition entries. RECORD_AUDIT_UPDATED category.',
    CONSTRAINT pk_central_monitoring_alert PRIMARY KEY(`central_monitoring_alert_id`)
) COMMENT 'Automated or manually triggered alert generated by the centralized statistical monitoring (CSM) system when a KRI threshold breach or data anomaly is detected at a site.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` (
    `checklist_item_id` BIGINT COMMENT 'Primary key for checklist_item',
    `monitoring_plan_id` BIGINT COMMENT 'add column monitoring_plan_id (BIGINT) with FK to monitoring.monitoring_plan.monitoring_plan_id — checklist_item references only template and self-ref but should link to the monitoring plan or visit type it belongs to',
    `parent_checklist_item_id` BIGINT COMMENT 'Self-referencing FK on checklist_item (parent_checklist_item_id)',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `applicable_phase` STRING COMMENT 'The clinical trial phase(s) for which this checklist item is applicable, as different phases may have varying monitoring requirements.',
    `approved_date` DATE COMMENT 'Date when this checklist item was formally approved for use in monitoring activities, per quality management review processes.',
    `capa_trigger` BOOLEAN COMMENT 'Flag indicating whether non-compliance on this item automatically initiates a Corrective and Preventive Action (CAPA) workflow.',
    `checklist_item_category` STRING COMMENT 'High-level classification category grouping the checklist item by monitoring focus area such as regulatory compliance, patient safety, or data quality.',
    `checklist_item_code` STRING COMMENT 'Unique business code assigned to the checklist item for identification in monitoring workflows and CTMS systems.',
    `created_date` TIMESTAMP COMMENT 'Timestamp when this checklist item record was first created in the system, supporting audit trail requirements for GCP compliance.',
    `checklist_item_description` STRING COMMENT 'Detailed description of the checklist item explaining the monitoring task, verification requirement, or assessment criteria.',
    `deviation_classification` STRING COMMENT 'Deviation classification. Implements SDTM DV.DVCAT protocol deviation category concept.',
    `effective_from_date` DATE COMMENT 'Date from which this checklist item version becomes effective and available for inclusion in monitoring visit checklists.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether a non-compliant finding on this checklist item automatically triggers an escalation workflow or CAPA initiation.',
    `expected_response` STRING COMMENT 'The expected or compliant response value for this checklist item, used to auto-flag deviations when actual responses differ.',
    `frequency` STRING COMMENT 'How frequently this checklist item should be assessed during the course of monitoring a clinical trial site.',
    `guidance_text` STRING COMMENT 'Instructional guidance or help text provided to CRAs explaining how to properly assess or complete this checklist item during monitoring.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this checklist item must be completed during every applicable monitoring visit or if it can be optionally skipped by the CRA.',
    `item_type` STRING COMMENT 'Classification of the type of monitoring action required: verification (source data check), assessment (judgment-based), confirmation (yes/no), collection (document retrieval), or observation (visual inspection).',
    `last_modified_date` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this checklist item definition, supporting change tracking and version control.',
    `monitoring_method` STRING COMMENT 'The monitoring method for which this checklist item is applicable, supporting risk-based monitoring (RBM) strategies that combine on-site, remote, and centralized approaches.',
    `checklist_item_name` STRING COMMENT 'Human-readable name or title of the checklist item as displayed to Clinical Research Associates (CRAs) during monitoring visits.',
    `region_applicability` STRING COMMENT 'Geographic region or country codes where this checklist item is applicable, supporting multi-regional trial monitoring with jurisdiction-specific requirements.',
    `regulatory_reference` STRING COMMENT 'Regulatory/GCP reference. Implements ICH E6(R2) Good Clinical Practice guideline reference.',
    `requires_documentation` BOOLEAN COMMENT 'Flag indicating whether completion of this checklist item requires supporting documentation or evidence to be attached to the monitoring visit report.',
    `response_type` STRING COMMENT 'Defines the expected response format when a CRA completes this checklist item during a monitoring visit.',
    `retired_date` DATE COMMENT 'Date when this checklist item was retired from active use, maintaining historical reference while preventing inclusion in new monitoring checklists.',
    `risk_category` STRING COMMENT 'Risk classification of the checklist item indicating the severity level if the item is found non-compliant, aligned with risk-based monitoring (RBM) strategy.',
    `sdv_required` BOOLEAN COMMENT 'Indicates whether this checklist item requires source data verification against original patient records or source documents.',
    `section_name` STRING COMMENT 'The section or sub-grouping within the monitoring checklist where this item is organized, enabling structured checklist navigation.',
    `sort_order` BIGINT COMMENT 'Numeric sequence defining the display order of this checklist item within its parent checklist or category grouping.',
    `checklist_item_status` STRING COMMENT 'Current lifecycle status of the checklist item in the master reference table, controlling its availability for use in monitoring visit checklists.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication for which this checklist item is specifically relevant, if not universally applicable across all studies.',
    `version_number` STRING COMMENT 'Version identifier for the checklist item definition, supporting version control as monitoring requirements evolve across protocol amendments.',
    `visit_type_applicability` STRING COMMENT 'Indicates which type of monitoring visit this checklist item applies to: site initiation visit (SIV), interim monitoring visit (IMV), close-out visit (COV), or all visit types.',
    `weight_score` DECIMAL(5,2) COMMENT 'Numeric weighting factor assigned to this checklist item for calculating overall site compliance scores in risk-based monitoring analytics.',
    CONSTRAINT pk_checklist_item PRIMARY KEY(`checklist_item_id`)
) COMMENT 'Master reference table for checklist_item. Referenced by checklist_item_id.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` (
    `monitoring_visit_id` BIGINT COMMENT 'Primary key',
    `monitoring_cra_assignment_id` BIGINT COMMENT 'add column monitoring_cra_assignment_id (BIGINT) with FK to monitoring.monitoring_cra_assignment.monitoring_cra_assignment_id — monitoring_visit must reference the CRA assignment for the visit',
    `monitoring_plan_id` BIGINT COMMENT 'add column monitoring_plan_id (BIGINT) with FK to monitoring.monitoring_plan.monitoring_plan_id — monitoring_visit must reference the monitoring plan governing the visit',
    `site_study_site_id` BIGINT COMMENT 'add column site_study_site_id (BIGINT) with FK to site.study_site.study_site_id — monitoring_visit has zero outbound FKs despite being a core operational entity; it must reference the study_site where the visit occurs',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — monitoring_visit must reference the study it belongs to',
    `action_items_count` BIGINT COMMENT 'Count of action items associated with the monitoring visit',
    `actual_date` DATE COMMENT 'The actual date of the monitoring visit',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was created',
    `findings_summary` STRING COMMENT 'Summary of findings from the monitoring visit',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether follow-up is required for this monitoring visit',
    `planned_date` DATE COMMENT 'Planned date of the monitoring visit.',
    `report_approved_date` DATE COMMENT 'Report approved date of the monitoring visit.',
    `report_submitted_date` DATE COMMENT 'Report submitted date of the monitoring visit.',
    `sdv_completed_flag` BOOLEAN COMMENT 'Indicator for sdv completed flag on the monitoring visit.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `visit_mode` STRING COMMENT 'The visit mode of the monitoring visit.',
    `visit_number` STRING COMMENT 'The visit number of the monitoring visit.',
    `visit_purpose` STRING COMMENT 'The visit purpose of the monitoring visit.',
    `visit_status` STRING COMMENT 'The visit status of the monitoring visit.',
    `visit_type` STRING COMMENT 'The visit type of the monitoring visit.',
    CONSTRAINT pk_monitoring_visit PRIMARY KEY(`monitoring_visit_id`)
) COMMENT 'CRA site monitoring visit, distinct from subject_visit';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` (
    `escalation_record_context_id` BIGINT COMMENT 'description',
    `escalation_record_id` BIGINT COMMENT 'description',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — escalation_record_context links escalation to findings but lacks study context',
    `unblinding_request_id` BIGINT COMMENT 'description',
    `visit_finding_id` BIGINT COMMENT 'description',
    `context_description` STRING COMMENT 'STRING',
    `context_status` STRING COMMENT 'STRING',
    `created_at` TIMESTAMP COMMENT 'Timestamp indicating when the escalation record context was created',
    `created_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `escalation_record_context_status` STRING COMMENT 'STRING',
    CONSTRAINT pk_escalation_record_context PRIMARY KEY(`escalation_record_context_id`)
) COMMENT 'Junction table holding additional foreign key relationships for escalation records that exceed the recommended FK limit, supporting regulatory inspection, unblinding request, and visit finding references.';

ALTER SCHEMA `clinical_trials_ecm`.`monitoring` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`monitoring` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_delivery_preference_id` FOREIGN KEY (`delivery_preference_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`delivery_preference`(`delivery_preference_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_regulatory_strategy_id` FOREIGN KEY (`regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`strategy`(`strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_subdomain' = 'strategy_planning');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_canonical_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_plan_scope' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` SET TAGS ('dbx_distinct_concept' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `delivery_preference_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preference Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Amendment Reason');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `applicable_regions` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Regions');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Approval Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Approved By');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `capa_resolution_days` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Resolution Window (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `centralized_monitoring_included` SET TAGS ('dbx_business_glossary_term' = 'Centralized Monitoring Included Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `closeout_visit_required` SET TAGS ('dbx_business_glossary_term' = 'Site Close-Out Visit Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `cra_qualification_requirements` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Qualification Requirements');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `gcp_training_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `high_risk_visit_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'High-Risk Site Visit Frequency (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `icf_review_required` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `interim_visit_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Interim Monitoring Visit Frequency (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `ip_accountability_required` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `kri_tolerance_limits` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) Tolerance Limits');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `low_risk_visit_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Low-Risk Site Visit Frequency (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `missing_data_threshold` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Threshold (%)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `monitoring_approach` SET TAGS ('dbx_value_regex' = 'On-Site|Remote|Centralized|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_value_regex' = '^MP-[A-Z0-9]{3,20}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'Draft|Under Review|Approved|Superseded|Retired');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `protocol_deviation_threshold` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Threshold (%)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `query_rate_threshold` SET TAGS ('dbx_business_glossary_term' = 'Data Query Rate Threshold (%)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `rbm_strategy` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Strategy');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `rbm_strategy` SET TAGS ('dbx_value_regex' = 'Risk-Based|Traditional|Enhanced|Adaptive');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `remote_monitoring_allowed` SET TAGS ('dbx_business_glossary_term' = 'Remote Monitoring Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `sdv_percentage_threshold` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Percentage Threshold');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `sdv_percentage_threshold` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `sdv_scope` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Scope');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `sdv_scope` SET TAGS ('dbx_value_regex' = '100% SDV|Risk-Based SDV|Critical Data Only|No SDV');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `site_initiation_visit_required` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit (SIV) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `site_risk_tier_methodology` SET TAGS ('dbx_value_regex' = 'Quantitative Score|Qualitative Assessment|Hybrid|Sponsor-Defined');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Version Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_plan` ALTER COLUMN `visit_report_submission_days` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Report Submission Window (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_primary_visit_employee_id` FOREIGN KEY (`primary_visit_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `capa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `cra_signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'CRA Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `cra_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `icf_review_conducted` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Review Conducted Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `ip_accountability_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `ip_storage_compliant` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Storage Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `ip_storage_compliant` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `lab_samples_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Samples Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `monitoring_approach` SET TAGS ('dbx_value_regex' = 'On-Site|Remote|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `protocol_deviation_severity` SET TAGS ('dbx_value_regex' = 'None|Minor|Major|Critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `protocol_deviations_identified` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviations Identified Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `regulatory_documents_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Documents Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'Draft|Pending Review|Approved|Finalized|Superseded');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `sdv_coverage_percent` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Coverage Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `sdv_coverage_percent` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `sdv_discrepancies_found` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Discrepancies Found Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `sdv_source_documents_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Source Documents Reviewed Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `site_overall_rating` SET TAGS ('dbx_value_regex' = 'Satisfactory|Needs Improvement|Unsatisfactory|Critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `supervisor_signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Supervisor Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `supervisor_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `visit_type` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_report` ALTER COLUMN `visit_type` SET TAGS ('dbx_value_regex' = 'Site Initiation Visit|Interim Monitoring Visit|Remote Monitoring Visit|Close-Out Visit|For Cause Visit|Co-Monitoring Visit');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_field_entry_id` FOREIGN KEY (`field_entry_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`field_entry`(`field_entry_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_visit_procedure_id` FOREIGN KEY (`visit_procedure_id`) REFERENCES `clinical_trials_ecm`.`study`.`visit_procedure`(`visit_procedure_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_record_id` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `discrepancy_query_id` SET TAGS ('dbx_business_glossary_term' = 'Data Query ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `field_entry_id` SET TAGS ('dbx_business_glossary_term' = 'Field Entry Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `visit_procedure_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Procedure Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `discrepancy_category` SET TAGS ('dbx_value_regex' = 'transcription_error|missing_data|date_error|unit_error|coding_error|other');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `ecrf_page_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Page Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `ecrf_page_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `is_critical_data_point` SET TAGS ('dbx_business_glossary_term' = 'Critical Data Point Indicator');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `is_sdv_waived` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Waiver Indicator');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `not_verifiable_reason` SET TAGS ('dbx_value_regex' = 'source_unavailable|illegible|missing_record|access_denied|other');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `rbm_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Risk Score');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Resolution Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Resolution Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'open|resolved|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_coverage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Coverage Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_coverage_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_method` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Method');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_method` SET TAGS ('dbx_value_regex' = '100_percent|targeted|risk_based|triggered');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_outcome` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Outcome');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_outcome` SET TAGS ('dbx_value_regex' = 'verified|discrepancy_found|not_verifiable|pending');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_performed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Performed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_reference_number` SET TAGS ('dbx_value_regex' = '^SDV-[A-Z0-9]{3,10}-[0-9]{6,12}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_type` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `sdv_type` SET TAGS ('dbx_value_regex' = 'on_site|remote|centralized');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`sdv_record` ALTER COLUMN `waiver_justification` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Waiver Justification');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_compliance_protocol_deviation_id` FOREIGN KEY (`compliance_protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_deviation_classification_id` FOREIGN KEY (`deviation_classification_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`deviation_classification`(`deviation_classification_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_ecm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_subject_deviation_id` FOREIGN KEY (`subject_deviation_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_deviation`(`subject_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `compliance_protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Deviation Classification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criterion Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `classification_type` SET TAGS ('dbx_business_glossary_term' = 'Deviation Classification Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `classification_type` SET TAGS ('dbx_value_regex' = 'prospective|retrospective');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Deviation Comments');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Deviation Detection Method');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `detection_method` SET TAGS ('dbx_value_regex' = 'on_site_monitoring|remote_monitoring|data_review|self_reported|audit|dsmb_review');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_number` SET TAGS ('dbx_value_regex' = '^DEV-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `deviation_status` SET TAGS ('dbx_value_regex' = 'open|under_review|resolved|closed|escalated|voided');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `identification_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Identification Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `identified_by` SET TAGS ('dbx_business_glossary_term' = 'Deviation Identified By');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `identified_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Deviation Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `irb_iec_report_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Report Submission Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `irb_iec_reportable` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Occurrence Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `recurrence_flag` SET TAGS ('dbx_business_glossary_term' = 'Deviation Recurrence Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `regulatory_authority_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Deviation Root Cause');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'site_staff_error|subject_non_compliance|system_failure|protocol_ambiguity|sponsor_error|external_factor');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `sdtm_dv_category` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Protocol Deviation Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `sdtm_dv_term` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Protocol Deviation Term');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Deviation Severity');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'major|minor|important_protocol_deviation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `sponsor_report_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Report Submission Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `sponsor_reportable` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_deviation_finding` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_ecm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_original_finding_visit_finding_id` FOREIGN KEY (`original_finding_visit_finding_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_finding`(`visit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_rand_deviation_id` FOREIGN KEY (`rand_deviation_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_deviation`(`rand_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_subject_deviation_id` FOREIGN KEY (`subject_deviation_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_deviation`(`subject_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_temperature_excursion_id` FOREIGN KEY (`temperature_excursion_id`) REFERENCES `clinical_trials_ecm`.`supply`.`temperature_excursion`(`temperature_excursion_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `visit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Finding Identifier');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `discrepancy_query_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Query ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criterion Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `original_finding_visit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Original Finding ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `rand_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `subject_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `temperature_excursion_id` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Study Subject ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Closed Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Resolution Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Escalation Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Finding Escalation Level');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'none|cra_manager|sponsor|regulatory_authority');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_value_regex' = 'data_integrity|informed_consent|ip_accountability|safety_reporting|regulatory_compliance|protocol_deviation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `finding_number` SET TAGS ('dbx_business_glossary_term' = 'Finding Reference Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `finding_number` SET TAGS ('dbx_value_regex' = '^FND-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `gcp_reference` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Reference');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Identified Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `monitoring_approach` SET TAGS ('dbx_value_regex' = 'on_site|remote|centralized');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `preventive_action` SET TAGS ('dbx_business_glossary_term' = 'Preventive Action Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `repeat_finding` SET TAGS ('dbx_business_glossary_term' = 'Repeat Finding Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Finding Resolution Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|resolved|closed|escalated');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `resolved_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Resolved Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `sdv_completed` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `sdv_required` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Finding Severity');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `visit_type` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_finding` ALTER COLUMN `visit_type` SET TAGS ('dbx_value_regex' = 'site_initiation|interim_monitoring|close_out|remote|for_cause');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_central_monitoring_alert_id` FOREIGN KEY (`central_monitoring_alert_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert`(`central_monitoring_alert_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_parent_action_item_monitoring_action_item_id` FOREIGN KEY (`parent_action_item_monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_primary_monitoring_employee_id` FOREIGN KEY (`primary_monitoring_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_tertiary_monitoring_closure_confirmed_by_user_employee_id` FOREIGN KEY (`tertiary_monitoring_closure_confirmed_by_user_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ADD CONSTRAINT `fk_monitoring_monitoring_action_item_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` SET TAGS ('dbx_subdomain' = 'issue_resolution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `central_monitoring_alert_id` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `parent_action_item_monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `primary_monitoring_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned To User ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `primary_monitoring_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `primary_monitoring_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `primary_monitoring_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `tertiary_monitoring_closure_confirmed_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Closure Confirmed By User ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `tertiary_monitoring_closure_confirmed_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `tertiary_monitoring_closure_confirmed_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `tertiary_monitoring_closure_confirmed_by_user_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `action_item_number` SET TAGS ('dbx_value_regex' = '^AI-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `action_type` SET TAGS ('dbx_business_glossary_term' = 'Action Item Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `action_type` SET TAGS ('dbx_value_regex' = 'corrective|preventive|observation|recommendation|escalation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_action_item_category` SET TAGS ('dbx_business_glossary_term' = 'Action Item Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Action Item Closed Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `closure_evidence_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Closure Evidence Document Reference');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `ctms_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_action_item_description` SET TAGS ('dbx_business_glossary_term' = 'Action Item Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Action Item Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `extended_due_date` SET TAGS ('dbx_business_glossary_term' = 'Action Item Extended Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `gcp_reference` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Reference');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `is_escalated` SET TAGS ('dbx_business_glossary_term' = 'Action Item Escalation Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_visit_type` SET TAGS ('dbx_value_regex' = 'initiation|interim|close_out|remote|for_cause');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Action Item Priority');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `raised_date` SET TAGS ('dbx_business_glossary_term' = 'Action Item Raised Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Impact Level');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_value_regex' = 'none|minor|moderate|significant|critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `response_date` SET TAGS ('dbx_business_glossary_term' = 'Site Response Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `response_text` SET TAGS ('dbx_business_glossary_term' = 'Site Response Text');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'Action Item Source Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_action_item_status` SET TAGS ('dbx_business_glossary_term' = 'Action Item Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `monitoring_action_item_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|overdue|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Action Item Title');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_action_item` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'sdv|document_review|site_visit|remote_review|sponsor_confirmation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_kri_id` FOREIGN KEY (`kri_id`) REFERENCES `clinical_trials_ecm`.`program`.`kri`(`kri_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_service_level_agreement_id` FOREIGN KEY (`service_level_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`service_level_agreement`(`service_level_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_statistical_endpoint_id` FOREIGN KEY (`statistical_endpoint_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint`(`statistical_endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` SET TAGS ('dbx_subdomain' = 'strategy_planning');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `kri_id` SET TAGS ('dbx_business_glossary_term' = 'Program Kri Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `service_level_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `statistical_endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `alert_status` SET TAGS ('dbx_business_glossary_term' = 'KRI Alert Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `alert_status` SET TAGS ('dbx_value_regex' = 'green|amber|red|not_triggered');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `amber_threshold` SET TAGS ('dbx_business_glossary_term' = 'Amber Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `risk_indicator_category` SET TAGS ('dbx_value_regex' = 'enrollment|data_quality|safety|protocol_compliance|ip_accountability');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `computation_date` SET TAGS ('dbx_business_glossary_term' = 'KRI Computation Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `computation_frequency` SET TAGS ('dbx_business_glossary_term' = 'KRI Computation Frequency');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `computation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|per_visit|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `computation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'KRI Computation Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `computed_value` SET TAGS ('dbx_business_glossary_term' = 'Computed KRI Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `consecutive_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Consecutive Threshold Breach Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|oracle_argus_safety|siebel_ctms|sas_drug_development|manual');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `denominator_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Denominator Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'KRI Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'KRI Effective Until Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Indicator Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Indicator Name');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Indicator Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|retired');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Indicator Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `indicator_type` SET TAGS ('dbx_value_regex' = 'rate|count|percentage|ratio|days');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `is_centralized_monitoring` SET TAGS ('dbx_business_glossary_term' = 'Centralized Statistical Monitoring (CSM) Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'KRI Notes');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `numerator_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Numerator Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `prior_computed_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Computed KRI Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `red_threshold` SET TAGS ('dbx_business_glossary_term' = 'Red Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `reference_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reference Period End Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `reference_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reference Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `sdv_impact` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Impact');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `sdv_impact` SET TAGS ('dbx_value_regex' = 'increase_sdv|decrease_sdv|no_change|trigger_targeted_sdv');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `sponsor_defined` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-Defined KRI Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `threshold_direction` SET TAGS ('dbx_value_regex' = 'above|below');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `trend_direction` SET TAGS ('dbx_business_glossary_term' = 'KRI Trend Direction');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `trend_direction` SET TAGS ('dbx_value_regex' = 'improving|stable|worsening|insufficient_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'KRI Version Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`risk_indicator` ALTER COLUMN `weight` SET TAGS ('dbx_business_glossary_term' = 'KRI Weight');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_primary_site_employee_id` FOREIGN KEY (`primary_site_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_tmf_completeness_id` FOREIGN KEY (`tmf_completeness_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_completeness`(`tmf_completeness_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` SET TAGS ('dbx_subdomain' = 'strategy_planning');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessor ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `primary_site_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `tmf_completeness_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Completeness Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `ae_reporting_timeliness_percent` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Reporting Timeliness Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'Site Risk Assessment Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_value_regex' = '^SRA-[A-Z0-9]{4,10}-[0-9]{4}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|rejected|superseded');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'initial|periodic|triggered|close_out');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `critical_kri_breaches_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Key Risk Indicator (KRI) Breach Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `data_entry_lag_days` SET TAGS ('dbx_business_glossary_term' = 'Data Entry Lag (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `enrollment_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `kri_breaches_count` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) Breach Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `outstanding_queries_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Query Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `overall_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Site Risk Score');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `previous_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Previous Site Risk Score');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `previous_risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Previous Risk Tier Classification');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `previous_risk_tier` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `query_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Query Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `recommended_monitoring_intensity` SET TAGS ('dbx_business_glossary_term' = 'Recommended Monitoring Intensity Adjustment');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `recommended_monitoring_intensity` SET TAGS ('dbx_value_regex' = 'increased|maintained|decreased');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `recommended_sdv_scope_percent` SET TAGS ('dbx_business_glossary_term' = 'Recommended Source Data Verification (SDV) Scope Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `recommended_visit_frequency` SET TAGS ('dbx_business_glossary_term' = 'Recommended Monitoring Visit Frequency');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `recommended_visit_frequency` SET TAGS ('dbx_value_regex' = 'monthly|bi_monthly|quarterly|semi_annual|annual');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `risk_management_plan_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Tier Classification');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `screen_failure_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Screen Failure Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `sdv_completion_percent` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Completion Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `subject_dropout_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Subject Dropout Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`site_risk_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_cra_qualification_id` FOREIGN KEY (`cra_qualification_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`cra_qualification`(`cra_qualification_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_primary_monitoring_cra_employee_id` FOREIGN KEY (`primary_monitoring_cra_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_program_resource_plan_id` FOREIGN KEY (`program_resource_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_resource_plan`(`program_resource_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_rate_card_id` FOREIGN KEY (`rate_card_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`rate_card`(`rate_card_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_subcontract_id` FOREIGN KEY (`subcontract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`subcontract`(`subcontract_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` SET TAGS ('dbx_subdomain' = 'strategy_planning');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `monitoring_cra_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Clinical Research Associate (CRA) Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `cra_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Cra Qualification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `primary_monitoring_cra_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Employee ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `primary_monitoring_cra_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `primary_monitoring_cra_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `primary_monitoring_cra_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `program_resource_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Resource Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `subcontract_id` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Notes');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'pending|active|on_hold|transferred|completed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'CRA Assignment Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'primary|backup|lead|co_monitor|regional_lead');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `ctms_assignment_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Assignment Reference');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'none|flagged|escalated|resolved');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `gcp_training_current` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Current Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `last_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `last_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `monitoring_approach` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid|centralized');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `next_planned_visit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Planned Monitoring Visit Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `next_planned_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `open_query_count` SET TAGS ('dbx_business_glossary_term' = 'Open Data Query Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `remote_access_authorized` SET TAGS ('dbx_business_glossary_term' = 'Remote Monitoring Access Authorization Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `sdv_scope_pct` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Scope Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `sdv_strategy` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Strategy');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `sdv_strategy` SET TAGS ('dbx_value_regex' = 'full|targeted|risk_based|critical_data_only');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `site_count_assigned` SET TAGS ('dbx_business_glossary_term' = 'Assigned Site Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `site_initiation_authorized` SET TAGS ('dbx_business_glossary_term' = 'Site Initiation Visit Authorization Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notification Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'CRA Territory Code');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `territory_name` SET TAGS ('dbx_business_glossary_term' = 'CRA Territory Name');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `territory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `total_visits_completed` SET TAGS ('dbx_business_glossary_term' = 'Total Monitoring Visits Completed');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Transfer Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `transfer_reason` SET TAGS ('dbx_business_glossary_term' = 'Assignment Transfer Reason');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `visit_frequency_weeks` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Frequency (Weeks)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment` ALTER COLUMN `workload_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Workload Allocation Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_ecm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_rescheduled_from_monitoring_visit_schedule_id` FOREIGN KEY (`rescheduled_from_monitoring_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule`(`monitoring_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_risk_indicator_id` FOREIGN KEY (`risk_indicator_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`risk_indicator`(`risk_indicator_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_site_risk_assessment_id` FOREIGN KEY (`site_risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`site_risk_assessment`(`site_risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_protocol_milestone_id` FOREIGN KEY (`study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` SET TAGS ('dbx_subdomain' = 'strategy_planning');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `monitoring_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Schedule ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `monitoring_cra_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Cra Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Reconsent Trigger Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `rescheduled_from_monitoring_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rescheduled From Visit Schedule ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `risk_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Trigger Indicator ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Linked Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `site_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Site Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Visit Cancellation Reason');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `ctms_schedule_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Schedule Reference');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Until Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `enrollment_trigger_count` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Trigger Subject Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `frequency_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Frequency Interval (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `is_overdue` SET TAGS ('dbx_business_glossary_term' = 'Visit Overdue Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `is_rbm_triggered` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Triggered Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `notification_due_date` SET TAGS ('dbx_business_glossary_term' = 'Site Notification Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `notification_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Site Notification Sent Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `planned_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Planned Visit Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `planned_visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Visit Priority Level');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'Critical|High|Medium|Low');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `rescheduling_reason` SET TAGS ('dbx_business_glossary_term' = 'Visit Rescheduling Reason');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_business_glossary_term' = 'Visit Schedule Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Visit Schedule Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'Planned|Confirmed|In Progress|Completed|Cancelled|Rescheduled');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `scheduling_basis` SET TAGS ('dbx_business_glossary_term' = 'Visit Scheduling Basis');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `scheduling_basis` SET TAGS ('dbx_value_regex' = 'Calendar-Based|Risk-Based Trigger|Milestone-Based|Enrollment-Based|Regulatory-Required');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `sdv_scope` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Scope');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `sdv_scope` SET TAGS ('dbx_value_regex' = '100% SDV|Risk-Based SDV|Critical Data Only|No SDV');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `sdv_target_percentage` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Target Percentage');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `sdv_target_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `sponsor_approved` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Approved Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated By User');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `updated_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Version Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `visit_mode` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Mode');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `visit_mode` SET TAGS ('dbx_value_regex' = 'On-Site|Remote|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `visit_type` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `visit_type` SET TAGS ('dbx_value_regex' = 'Site Initiation Visit|Interim Monitoring Visit|Close-Out Visit|Remote Monitoring Visit|For-Cause Visit|Pre-Study Visit');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `window_earliest_date` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Earliest Acceptable Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `window_latest_date` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Latest Acceptable Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `window_tolerance_days` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Tolerance (Days)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit_schedule` ALTER COLUMN `created_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_accountability_reconciliation_id` FOREIGN KEY (`accountability_reconciliation_id`) REFERENCES `clinical_trials_ecm`.`supply`.`accountability_reconciliation`(`accountability_reconciliation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_destruction_record_id` FOREIGN KEY (`destruction_record_id`) REFERENCES `clinical_trials_ecm`.`supply`.`destruction_record`(`destruction_record_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_investigator_grant_id` FOREIGN KEY (`investigator_grant_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`investigator_grant`(`investigator_grant_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_ecm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_randomization_kit_assignment_id` FOREIGN KEY (`randomization_kit_assignment_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`kit_assignment`(`kit_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_accountability_log_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Log ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `accountability_reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `destruction_record_id` SET TAGS ('dbx_business_glossary_term' = 'Destruction Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Grant Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `randomization_kit_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Kit Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `accountability_finding_severity` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Finding Severity');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `accountability_finding_severity` SET TAGS ('dbx_value_regex' = 'none|minor|major|critical');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `batch_lot_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Batch/Lot Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `cra_comments` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Comments');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `destruction_records_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Destruction Records Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `discrepancy_notes` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Discrepancy Notes');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `discrepancy_quantity` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Discrepancy Quantity');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `dispensing_log_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Dispensing Log Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_form` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Dosage Form');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_label_compliance_verified` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Label Compliance Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_storage_location` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Storage Location');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_storage_location` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `ip_strength` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Strength');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `log_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Log Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_destroyed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity Destroyed');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_dispensed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity Dispensed');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_on_hand` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity On Hand');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_received` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity Received');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_returned` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity Returned');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Quantity Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Reconciliation Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'balanced|discrepancy_identified|pending_review|resolved|escalated');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `return_log_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Return Log Reviewed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `review_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Review Period End Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `review_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Review Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `rtsm_irt_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) / Interactive Response Technology (IRT) Reconciled Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_condition_verified` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Storage Condition Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_condition_verified` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Storage Temperature Maximum (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Storage Temperature Minimum (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `temperature_excursion_details` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Temperature Excursion Details');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `temperature_excursion_occurred` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Temperature Excursion Occurred Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Verification Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Verification Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'draft|completed|reviewed|approved|closed');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`ip_accountability_log` ALTER COLUMN `verification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product (IP) Accountability Verification Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_central_monitoring_alert_id` FOREIGN KEY (`central_monitoring_alert_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert`(`central_monitoring_alert_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_consent_deviation_id` FOREIGN KEY (`consent_deviation_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_deviation`(`consent_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_contract_obligation_id` FOREIGN KEY (`contract_obligation_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`contract_obligation`(`contract_obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_governance_id` FOREIGN KEY (`governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_primary_escalation_employee_id` FOREIGN KEY (`primary_escalation_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_ecm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_site_risk_assessment_id` FOREIGN KEY (`site_risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`site_risk_assessment`(`site_risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_sponsor_escalation_id` FOREIGN KEY (`sponsor_escalation_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`escalation`(`escalation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_ecm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` SET TAGS ('dbx_subdomain' = 'issue_resolution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `central_monitoring_alert_id` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `consent_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `contract_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `governance_id` SET TAGS ('dbx_business_glossary_term' = 'Program Governance Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notification - Health Authority Id');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `primary_escalation_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Raised By Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `primary_escalation_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `primary_escalation_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `primary_escalation_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `reconsent_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'Reconsent Trigger Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Readiness Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `site_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Site Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `sponsor_escalation_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Escalation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Escalation Closed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'cra_to_lead_cra|lead_cra_to_sponsor_medical_monitor|sponsor_to_irb_iec|sponsor_to_regulatory_authority|management_escalation');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|resolved|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `escalation_trigger_type` SET TAGS ('dbx_value_regex' = 'overdue_action_item|overdue_capa|critical_gcp_finding|protocol_deviation|unresolved_query|risk_indicator_breach');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `gcp_finding_category` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Finding Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `gcp_finding_category` SET TAGS ('dbx_value_regex' = 'critical|major|minor|other');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `irb_iec_notification_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `prior_resolution_attempts` SET TAGS ('dbx_business_glossary_term' = 'Prior Resolution Attempts Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Escalation Priority');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Escalation Resolution Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_business_glossary_term' = 'Escalation Resolution Outcome');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_value_regex' = 'resolved_with_capa|resolved_without_capa|escalated_further|site_terminated|study_suspended|no_action_required');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `risk_based_monitoring_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_checklist_item_id` FOREIGN KEY (`checklist_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`checklist_item`(`checklist_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_checklist_template_id` FOREIGN KEY (`checklist_template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_monitoring_action_item_id` FOREIGN KEY (`monitoring_action_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_action_item`(`monitoring_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_primary_visit_employee_id` FOREIGN KEY (`primary_visit_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `visit_checklist_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Checklist Identifier');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `monitoring_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `primary_visit_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `action_required` SET TAGS ('dbx_business_glossary_term' = 'Action Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `checklist_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|completed|signed_off|void');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `completion_status` SET TAGS ('dbx_business_glossary_term' = 'Item Completion Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `completion_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|not_applicable|failed');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `cra_signoff_timestamp` SET TAGS ('dbx_business_glossary_term' = 'CRA Sign-Off Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `finding_severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation|none');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `is_applicable` SET TAGS ('dbx_business_glossary_term' = 'Applicable Item Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Item Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `item_category` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `item_name` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Name');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `item_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `item_sequence` SET TAGS ('dbx_business_glossary_term' = 'Item Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `rbm_triggered` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Triggered Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `sdv_performed` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Performed Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `visit_mode` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`visit_checklist` ALTER COLUMN `visit_type` SET TAGS ('dbx_value_regex' = 'site_initiation|interim|close_out|remote|for_cause');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_consent_deviation_id` FOREIGN KEY (`consent_deviation_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_deviation`(`consent_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_prior_alert_central_monitoring_alert_id` FOREIGN KEY (`prior_alert_central_monitoring_alert_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert`(`central_monitoring_alert_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_rand_deviation_id` FOREIGN KEY (`rand_deviation_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_deviation`(`rand_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_risk_indicator_id` FOREIGN KEY (`risk_indicator_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`risk_indicator`(`risk_indicator_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_ecm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_statistical_endpoint_id` FOREIGN KEY (`statistical_endpoint_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint`(`statistical_endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ADD CONSTRAINT `fk_monitoring_central_monitoring_alert_tmf_completeness_id` FOREIGN KEY (`tmf_completeness_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_completeness`(`tmf_completeness_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` SET TAGS ('dbx_subdomain' = 'issue_resolution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `consent_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Reviewer ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `prior_alert_central_monitoring_alert_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Alert ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `rand_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `risk_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `safety_report_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `statistical_endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `tmf_completeness_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Completeness Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_category` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_category` SET TAGS ('dbx_value_regex' = 'DATA_QUALITY|SAFETY|ENROLLMENT|PROTOCOL_COMPLIANCE|REGULATORY|OPERATIONAL');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_generated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Alert Generation Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_number` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Number');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_number` SET TAGS ('dbx_value_regex' = '^CMA-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_severity` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Severity');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_severity` SET TAGS ('dbx_value_regex' = 'CRITICAL|HIGH|MEDIUM|LOW');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_status` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_status` SET TAGS ('dbx_value_regex' = 'OPEN|UNDER_REVIEW|ESCALATED|CLOSED|CANCELLED');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_type` SET TAGS ('dbx_business_glossary_term' = 'Central Monitoring Alert Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `alert_type` SET TAGS ('dbx_value_regex' = 'KRI_THRESHOLD_BREACH|DATA_ANOMALY|STATISTICAL_OUTLIER|MANUAL|ENROLLMENT_SIGNAL|SAFETY_SIGNAL');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Alert Assignment Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `consecutive_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Consecutive KRI Breach Count');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `disposition` SET TAGS ('dbx_business_glossary_term' = 'Alert Disposition');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `disposition` SET TAGS ('dbx_value_regex' = 'ESCALATE_ONSITE_VISIT|REMOTE_FOLLOW_UP|NO_ACTION_REQUIRED|CAPA_INITIATED|PROTOCOL_DEVIATION_RAISED');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Alert Escalation Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `is_repeat_alert` SET TAGS ('dbx_business_glossary_term' = 'Repeat Alert Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `kri_code` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) Code');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `kri_name` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) Name');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `kri_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `observed_value` SET TAGS ('dbx_business_glossary_term' = 'Observed KRI Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `reference_period_end` SET TAGS ('dbx_business_glossary_term' = 'Alert Reference Period End Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `reference_period_start` SET TAGS ('dbx_business_glossary_term' = 'Alert Reference Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `review_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Alert Review Completed Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'Alert Review Due Date');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `review_narrative` SET TAGS ('dbx_business_glossary_term' = 'Alert Review Narrative');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `review_outcome` SET TAGS ('dbx_business_glossary_term' = 'Alert Review Outcome');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `review_outcome` SET TAGS ('dbx_value_regex' = 'CONFIRMED|FALSE_POSITIVE|INCONCLUSIVE|PENDING');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `threshold_type` SET TAGS ('dbx_business_glossary_term' = 'KRI Threshold Type');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `threshold_type` SET TAGS ('dbx_value_regex' = 'AMBER|RED');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `trigger_source` SET TAGS ('dbx_business_glossary_term' = 'Alert Trigger Source');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `trigger_source` SET TAGS ('dbx_value_regex' = 'AUTOMATED_CSM|MANUAL_ENTRY|EDC_INTEGRATION|CTMS_RULE|SAFETY_SYSTEM');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`central_monitoring_alert` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ADD CONSTRAINT `fk_monitoring_checklist_item_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ADD CONSTRAINT `fk_monitoring_checklist_item_parent_checklist_item_id` FOREIGN KEY (`parent_checklist_item_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`checklist_item`(`checklist_item_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ADD CONSTRAINT `fk_monitoring_checklist_item_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_id` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Identifier');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `parent_checklist_item_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_category` SET TAGS ('dbx_business_glossary_term' = 'Category');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_code` SET TAGS ('dbx_business_glossary_term' = 'Code');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_description` SET TAGS ('dbx_business_glossary_term' = 'Description');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_name` SET TAGS ('dbx_business_glossary_term' = 'Name');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `section_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`checklist_item` ALTER COLUMN `checklist_item_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` ADD CONSTRAINT `fk_monitoring_monitoring_visit_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` ADD CONSTRAINT `fk_monitoring_monitoring_visit_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` ADD CONSTRAINT `fk_monitoring_monitoring_visit_site_study_site_id` FOREIGN KEY (`site_study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` ADD CONSTRAINT `fk_monitoring_monitoring_visit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` SET TAGS ('dbx_subdomain' = 'visit_execution');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`monitoring_visit` SET TAGS ('dbx_metric_view_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` ADD CONSTRAINT `fk_monitoring_escalation_record_context_escalation_record_id` FOREIGN KEY (`escalation_record_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`escalation_record`(`escalation_record_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` ADD CONSTRAINT `fk_monitoring_escalation_record_context_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` ADD CONSTRAINT `fk_monitoring_escalation_record_context_unblinding_request_id` FOREIGN KEY (`unblinding_request_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`unblinding_request`(`unblinding_request_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` ADD CONSTRAINT `fk_monitoring_escalation_record_context_visit_finding_id` FOREIGN KEY (`visit_finding_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`visit_finding`(`visit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` SET TAGS ('dbx_domain' = 'monitoring');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`monitoring`.`escalation_record_context` SET TAGS ('dbx_subdomain' = 'issue_resolution');
