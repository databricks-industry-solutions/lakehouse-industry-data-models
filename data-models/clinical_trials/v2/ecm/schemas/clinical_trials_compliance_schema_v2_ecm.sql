-- Schema for Domain: compliance | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:58

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`compliance` COMMENT 'Manages GCP quality assurance (QA), quality control (QC), internal and external audits, regulatory inspections, CAPA lifecycle, protocol deviation classifications, SOP compliance tracking, and audit readiness.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`audit` (
    `audit_id` BIGINT COMMENT 'Unique surrogate identifier for each GCP audit record within the compliance domain. Primary key for the audit data product sourced from MasterControl audit management module.',
    `checklist_template_id` BIGINT COMMENT 'Reference to the standardized audit checklist template used during fieldwork, as configured in MasterControl. Templates are type-specific (site GCP, vendor, system) and version-controlled per SOP requirements.',
    `employee_id` BIGINT COMMENT 'Reference to the qualified QA professional designated as lead auditor responsible for planning, executing, and reporting the audit. Sourced from the source system records.',
    `follow_up_audit_id` BIGINT COMMENT 'Reference to the subsequent follow-up audit record created to verify CAPA effectiveness. Populated when follow_up_required is True and the follow-up audit has been scheduled or completed.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: GCP/GLP lab facility audits are a named compliance process. Sponsors and CROs conduct periodic audits of central labs to verify accreditation, data integrity, and GCP compliance.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: GCP audits of CRO operations are scoped to the master agreement governing the sponsor-CRO relationship.',
    `primary_audit_organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that commissioned or is subject to this audit. Relevant for sponsor-delegated audits and regulatory inspection readiness.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: GCP audits are scoped to a specific protocol version. Direct FK to protocol enables audit-readiness reports, TMF completeness checks, and regulatory inspection preparation tied to the exact',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Audits are conducted within the context of a sponsor engagement. Account managers use audit outcomes to update relationship health scores and report quality performance to sponsors during',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this audit. Nullable for cross-study or enterprise-level audits (e.g., system or vendor audits not tied to a single protocol).',
    `actual_end_date` DATE COMMENT 'Calendar date on which audit fieldwork actually concluded. Used to compute actual audit duration and assess deviation from planned schedule.',
    `actual_start_date` DATE COMMENT 'Calendar date on which audit fieldwork actually commenced. Compared against planned_start_date to measure schedule adherence and audit program performance.',
    `auditee_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the auditee location. Used for geographic risk stratification, regulatory jurisdiction determination, and cross-border audit planning.. Valid values are `^[A-Z]{3}$`',
    `auditee_name` STRING COMMENT 'Name of the organization, department, site, or system being audited. Provides a human-readable identifier for the audit subject independent of system IDs, supporting audit register reporting.',
    `capa_due_date` DATE COMMENT 'Deadline by which the auditee must submit a Corrective and Preventive Action (CAPA) plan in response to audit findings. Calculated from report_issue_date per sponsor or regulatory requirements.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a formal CAPA plan is required as a result of this audit. Set to True when critical or major findings are identified. Triggers CAPA workflow initiation in MasterControl.',
    `audit_category` STRING COMMENT 'Categorization of the audit by initiating party and trigger: internal (self-initiated QA), external (sponsor or third-party), regulatory_inspection (FDA/EMA/MHRA inspector-led), for_cause (triggered by specific concern or signal), or routine (scheduled. Valid values are `internal|external|regulatory_inspection|for_cause|routine`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the audit record was first created in MasterControl. Supports ALCOA+ data integrity requirements (Attributable, Legible, Contemporaneous, Original, Accurate) and audit trail compliance.',
    `critical_finding_count` BIGINT COMMENT 'Number of critical GCP findings identified during the audit. Critical findings indicate conditions that may directly impact subject safety, data integrity, or regulatory compliance and require immediate CAPA. Sourced from MasterControl finding records.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether a follow-up audit has been determined necessary to verify CAPA effectiveness or re-assess compliance after an unsatisfactory or needs_improvement outcome.',
    `gcp_standard_version` STRING COMMENT 'Version of the ICH GCP guideline applied during this audit (e.g., ICH E6(R2), ICH E6(R3)). Ensures traceability of the regulatory standard in force at the time of audit execution.',
    `location` STRING COMMENT 'Modality of audit execution: on_site (auditor physically present at auditee location), remote (conducted via video conference and electronic document review), or hybrid (combination of both).. Valid values are `on_site|remote|hybrid`',
    `major_finding_count` BIGINT COMMENT 'Number of major GCP findings identified during the audit. Major findings represent significant non-compliance that could affect subject rights, safety, or data reliability but are not immediately life-threatening.',
    `minor_finding_count` BIGINT COMMENT 'Number of minor GCP findings identified during the audit. Minor findings represent isolated deviations that do not significantly impact subject safety or data integrity but require corrective action.',
    `number` STRING COMMENT 'Externally-known, human-readable unique audit reference number assigned by MasterControl at audit creation (e.g., AUD-2024-00123). Used in regulatory correspondence, CAPA linkage, and TMF filing.. Valid values are `^AUD-[0-9]{4}-[0-9]{5}$`',
    `observation_count` BIGINT COMMENT 'Number of audit observations (non-findings) documented during the audit. Observations are areas for improvement that do not constitute formal GCP non-compliance but are noted for quality enhancement.',
    `outcome` STRING COMMENT 'Overall quality determination issued at audit close: satisfactory (no significant findings), needs_improvement (minor findings requiring corrective action), or unsatisfactory (critical/major findings indicating systemic GCP non-compliance).. Valid values are `satisfactory|needs_improvement|unsatisfactory`',
    `plan_version` STRING COMMENT 'Version identifier of the audit plan document used to conduct this audit (e.g., v1.0, v2.1). Supports document control traceability and links to the approved audit plan in Veeva Vault eTMF.. Valid values are `^v[0-9]+.[0-9]+$`',
    `planned_end_date` DATE COMMENT 'Scheduled calendar date on which audit fieldwork is planned to conclude. Used to calculate planned audit duration and monitor schedule adherence.',
    `planned_start_date` DATE COMMENT 'Scheduled calendar date on which audit fieldwork is planned to commence, as documented in the annual audit plan or risk-based audit schedule. Used for resource planning and audit readiness tracking.',
    `regulatory_authority` STRING COMMENT 'Name of the regulatory authority conducting or overseeing the inspection (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Populated for regulatory_inspection category audits; nullable for internal audits.',
    `report_issue_date` DATE COMMENT 'Date on which the final audit report was formally issued to the auditee and sponsor. Triggers the CAPA response timeline and is a key metric for audit cycle time KPIs.',
    `risk_priority_score` BIGINT COMMENT 'Numeric risk prioritization score (typically 1–100) calculated from risk factors such as subject safety criticality, protocol complexity, site performance history, and time since last audit.',
    `risk_tier` STRING COMMENT 'Categorical risk classification derived from risk_priority_score: critical, high, medium, or low. Used for audit frequency determination, resource allocation, and escalation thresholds in the quality management system.. Valid values are `critical|high|medium|low`',
    `scope` STRING COMMENT 'Narrative description of the audit scope, defining the boundaries, processes, systems, or study activities subject to evaluation. Documented in the audit plan and referenced throughout the audit lifecycle.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the sponsor has been formally notified of the audit outcome and findings. Required for sponsor oversight obligations under ICH E6(R2) and FDA guidance on oversight of clinical investigations.',
    `audit_status` STRING COMMENT 'Current lifecycle state of the audit record within MasterControl: planned (scheduled, not yet started), in_progress (fieldwork underway), completed (report issued), cancelled (audit withdrawn), or on_hold (paused pending resolution).. Valid values are `planned|in_progress|completed|cancelled|on_hold`',
    `summary` STRING COMMENT 'Executive summary narrative of the audit outcome, key findings, and overall GCP compliance assessment as documented in the final audit report. Supports audit readiness reviews and regulatory inspection preparation.',
    `title` STRING COMMENT 'Short, descriptive title of the audit as recorded in MasterControl (e.g., GCP Site Audit – Site 1042 – Protocol XYZ-001). Used in audit registers, dashboards, and TMF filing.',
    `tmf_reference_number` STRING COMMENT 'Document reference number assigned to the audit report and supporting documentation filed in the eTMF (Veeva Vault). Enables direct retrieval of audit artifacts during regulatory inspections per DIA TMF Reference Model.',
    `audit_type` STRING COMMENT 'Classification of regulatory inspection by trigger: routine (scheduled surveillance), for_cause (triggered by safety signal or complaint), pre_approval (NDA/BLA/MAA submission review), or post_approval (post-marketing commitment).. Valid values are `routine|for_cause|pre_approval|post_approval`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the audit record in MasterControl. Required for audit trail integrity under 21 CFR Part 11 and ALCOA+ data governance standards.',
    CONSTRAINT pk_audit PRIMARY KEY(`audit_id`)
) COMMENT 'Master record for all internal and external GCP audits conducted across studies, sites, systems, and vendors. Captures audit type (system, process, vendor, site, TMF), scope, lead auditor, planned and actual dates, audit status, sponsoring organization';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` (
    `audit_finding_id` BIGINT COMMENT 'Unique surrogate identifier for each audit finding record in the compliance data product. Primary key for the audit_finding entity.',
    `audit_id` BIGINT COMMENT 'Reference to the parent audit record from which this finding was generated. Links the finding to its originating GCP audit event.',
    `auditor_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: GCP audit finding reports must identify the qualified internal auditor who raised each finding for regulatory inspection readiness and accountability.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: GLP/GCP audits of bioanalytical laboratories specifically review assay validation and method performance. audit_finding has implicated_system as a text field.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the CAPA record triggered by this finding, if applicable. A finding may initiate a formal CAPA lifecycle in MasterControl.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: audit_finding.sop_reference is a free-text string referencing the SOP implicated in the finding.',
    `deviation_classification_id` BIGINT COMMENT 'Foreign key linking to compliance.deviation_classification. Business justification: audit_finding.protocol_deviation_classification is a free-text string that should reference the standardized deviation_classification taxonomy.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this audit finding. Enables study-level quality metrics and regulatory traceability.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site implicated in this finding, if the finding is site-specific. Null for system-level or sponsor-level findings.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Audit findings cite specific TMF documents as evidence of non-compliance. GCP audit reports require traceable references to the exact TMF document reviewed.',
    `audit_report_reference` STRING COMMENT 'Document identifier or version reference of the formal audit report in which this finding was published. Links the finding to the official audit report stored in Veeva Vault eTMF.',
    `auditee_name` STRING COMMENT 'Name of the individual, department, or organizational unit that is the subject of the audit finding. Business-confidential reference for accountability tracking.',
    `auditee_role` STRING COMMENT 'Professional role or function of the auditee (e.g., Principal Investigator, Clinical Research Coordinator, Data Manager, Sponsor Representative). Supports workforce quality analytics.',
    `auditor_organization` STRING COMMENT 'Name of the organization to which the auditor belongs (e.g., internal QA department, sponsor QA team, third-party audit firm). Distinguishes internal from external audit sources.',
    `capa_required_flag` BOOLEAN COMMENT 'Indicates whether this finding mandates the initiation of a formal CAPA process. Critical and major findings typically require CAPA; minor findings and observations may not.',
    `closure_date` DATE COMMENT 'The date on which the QA team formally verified and closed the finding after confirming that the corrective action was implemented and effective. Null if the finding remains open.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this audit finding record was first created in MasterControl and ingested into the Silver Layer. Supports audit trail and ALCOA+ attributability requirements.',
    `data_integrity_impact` STRING COMMENT 'Assessment of whether the finding has a confirmed, potential, or no impact on clinical trial data integrity. Relevant to ALCOA+ principles and regulatory submission reliability.. Valid values are `none|potential|confirmed`',
    `escalation_date` DATE COMMENT 'The date on which the finding was formally escalated. Null if escalation_flag is False. Used to measure escalation timeliness and response.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this finding has been escalated to senior management, the sponsor, or a regulatory authority due to severity, recurrence, or patient safety risk.',
    `finding_category` STRING COMMENT 'Severity classification of the finding per GCP audit standards. Critical: systemic failure with patient safety or data integrity risk. Major: significant GCP deviation. Minor: low-risk procedural gap.. Valid values are `critical|major|minor|observation`',
    `finding_description` STRING COMMENT 'Detailed narrative of the finding as documented by the auditor. Describes the observed deficiency, evidence reviewed, and the specific GCP or regulatory requirement that was not met.',
    `finding_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the finding at the time of audit. Used in audit reports, management responses, and CAPA tracking. Format: AF-{YYYY}-{NNNNNN}.. Valid values are `^AF-[0-9]{4}-[0-9]{6}$`',
    `finding_status` STRING COMMENT 'Current lifecycle state of the finding within the quality management workflow. Tracks progression from identification through resolution and closure verification.. Valid values are `open|in_progress|pending_verification|closed|overdue`',
    `finding_title` STRING COMMENT 'Short, human-readable title summarizing the nature of the finding. Used in audit reports, dashboards, and management communications.',
    `ich_gcp_clause_reference` STRING COMMENT 'Specific clause or section of the ICH E6(R2) GCP guideline that was violated or is relevant to this finding (e.g., 5.18.4, 4.9.0). Enables regulatory traceability and trend analysis by GCP requirement.',
    `identified_date` DATE COMMENT 'The calendar date on which the finding was formally identified and documented during the audit. Represents the principal real-world event date for this transaction record.',
    `implicated_system` STRING COMMENT 'Name of the operational system or application implicated in the finding (e.g., Medidata Rave, the source system Veeva Vault, MasterControl). Relevant for system-level findings distinct from site-level findings.',
    `management_response` STRING COMMENT 'Full text of the auditees formal management response to the finding, including root cause analysis, proposed corrective actions, and preventive measures. Captured verbatim from MasterControl.',
    `patient_safety_impact` STRING COMMENT 'Assessment of whether the finding has a confirmed, potential, or no impact on patient safety. Critical for risk-based quality management and escalation decisions.. Valid values are `none|potential|confirmed`',
    `prior_finding_reference_number` STRING COMMENT 'Reference number of the previously identified finding that this record repeats, if repeat_finding_flag is True. Enables lineage tracking of recurring quality issues.. Valid values are `^AF-[0-9]{4}-[0-9]{6}$`',
    `process_area` STRING COMMENT 'The clinical trial business process area implicated by the finding (e.g., Informed Consent Management, Adverse Event Reporting, Source Data Verification, Randomization, Drug Accountability). Enables process-level quality trending.',
    `qa_reviewer_comment` STRING COMMENT 'QA reviewers assessment of the adequacy of the management response and corrective action. Documents acceptance, rejection, or request for additional information during the closure review cycle.',
    `regulatory_authority` STRING COMMENT 'The primary regulatory authority whose requirements are cited in this finding. Enables jurisdiction-specific compliance reporting and inspection readiness tracking.',
    `regulatory_citation` STRING COMMENT 'Specific regulatory citation from applicable authority (e.g., FDA 21 CFR Part 312.62, EMA Directive 2001/20/EC, EU CTR 536/2014 Article 58) that underpins the finding. Supports regulatory inspection readiness.',
    `repeat_finding_flag` BOOLEAN COMMENT 'Indicates whether this finding is a recurrence of a previously identified and closed finding at the same site, system, or process area. True signals potential systemic quality failure and escalation risk.',
    `response_due_date` DATE COMMENT 'The contractual or procedurally mandated deadline by which the auditee must submit a formal management response to the finding. Typically 14–30 days post-audit report issuance per SOP.',
    `response_received_date` DATE COMMENT 'The actual date on which the auditees formal management response was received by the QA team. Used to calculate response timeliness and SLA compliance.',
    `root_cause_category` STRING COMMENT 'Categorized root cause of the finding as determined during root cause analysis (e.g., training gap, process failure, system error, resource constraint, communication breakdown). Enables systemic quality trend analysis.',
    `sop_version` STRING COMMENT 'Version number of the SOP in effect at the time the finding was identified. Critical for determining whether the deviation was against a current or superseded procedure.',
    `subject_count_affected` BIGINT COMMENT 'Number of study subjects potentially affected by the finding. Used to assess the scope and patient safety impact of the deficiency. Zero for system or process findings with no direct subject impact.',
    `target_closure_date` DATE COMMENT 'The planned date by which the finding is expected to be fully resolved and closed, as agreed between the QA team and the auditee. Distinct from response_due_date which covers only the management response.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this audit finding record. Tracks the last modification for change management, audit trail, and data lineage purposes.',
    `verification_method` STRING COMMENT 'Method used by the QA team to verify that the corrective action for this finding was effectively implemented prior to closure (e.g., document review, on-site visit, remote review, interview, system audit).. Valid values are `document_review|on_site_visit|remote_review|interview|system_audit`',
    CONSTRAINT pk_audit_finding PRIMARY KEY(`audit_finding_id`)
) COMMENT 'Transactional record of individual findings identified during an internal or sponsor-initiated GCP audit. Captures finding reference number, finding category (critical, major, minor, observation), finding description, ICH GCP clause reference, regulatory';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` (
    `inspection_finding_id` BIGINT COMMENT 'Unique surrogate identifier for each individual regulatory inspection finding record in the Databricks Silver Layer. Primary key for this transactional entity.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the CAPA record in MasterControl that was initiated to address this inspection finding. A single CAPA may address multiple findings; this field links the finding to its primary CAPA for lifecycle tracking.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: inspection_finding.sop_reference is a free-text string identifying the SOP implicated in the regulatory finding.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Regulatory inspection findings (FDA Form 483, EMA findings) cite specific lab results as evidence of GCP violations. inspection_finding has data_integrity_impact.',
    `prior_finding_inspection_finding_id` BIGINT COMMENT 'Reference to the earlier inspection finding that this finding repeats or is related to. Populated only when repeat_finding is True. Enables lineage tracking of recurring deficiencies across inspection cycles.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key to the regulatory inspection that is the source of this finding; references regulatory.regulatory_inspection.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) affected by this inspection finding. Enables cross-domain linkage between compliance findings and study-level data.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the inspection finding was identified. Null if the finding applies at the sponsor or CRO level rather than a specific site.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory inspection findings (FDA Form 483, EMA findings) reference specific TMF documents as evidence.',
    `source_regulatory_inspection_id` BIGINT COMMENT 'Foreign key to the regulatory inspection record',
    `finding_regulatory_inspection_id` BIGINT COMMENT 'Reference to regulatory.regulatory_inspection.regulatory_inspection_id.',
    `affected_process_area` STRING COMMENT 'The specific clinical trial process or functional area implicated by the finding (e.g., Informed Consent Management, SAE Reporting, Investigational Product Accountability, Source Data Verification, Protocol Deviation Management).',
    `affected_subject_count` BIGINT COMMENT 'Number of study subjects (patients) directly impacted by the deficiency identified in this inspection finding. Used to assess the scope of subject safety risk and to prioritize remediation efforts.',
    `audit_readiness_flag` BOOLEAN COMMENT 'Indicates whether all required documentation, CAPA evidence, and response materials for this finding have been compiled and are ready for re-inspection or follow-up audit review. Supports inspection readiness programs and executive reporting.',
    `authority` STRING COMMENT 'Regulatory authority that issued the inspection finding (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Determines the applicable response format, deadline, and escalation pathway.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a formal CAPA is required to address this inspection finding. Critical findings and major findings typically mandate a CAPA; other findings may be addressed through a written commitment without a full CAPA.',
    `closure_date` DATE COMMENT 'Date on which the regulatory authority formally accepted the response and closed the inspection finding. Null if the finding remains open or under review. Used for regulatory commitment tracking and audit readiness metrics.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this inspection finding record was first created in the system (MasterControl or Databricks Silver Layer). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `data_integrity_impact` STRING COMMENT 'Assessment of whether the finding compromises the integrity of clinical trial data submitted or to be submitted to regulatory authorities. Confirmed data integrity findings may invalidate study data and affect regulatory submissions.. Valid values are `none|potential|confirmed`',
    `escalation_status` STRING COMMENT 'Indicates whether the inspection finding has escalated to a formal regulatory enforcement action. Warning_letter indicates FDA has issued a Warning Letter. Consent_decree indicates a legal agreement with FDA.. Valid values are `none|warning_letter|consent_decree|import_alert|clinical_hold`',
    `finding_category` STRING COMMENT 'Thematic or process category to which the finding belongs, used for trend analysis and CAPA prioritization (e.g., Informed Consent, Adverse Event Reporting, Protocol Compliance, Data Integrity, Investigational Product Management, Monitoring, Regulatory',
    `finding_classification` STRING COMMENT 'Regulatory severity classification of the inspection finding as assigned by the inspecting authority. Critical indicates a condition that poses significant risk to subject safety or data integrity and may result in a Warning Letter or consent decree.. Valid values are `critical|major|other`',
    `finding_date` DATE COMMENT 'The date on which the regulatory authority formally issued or documented this finding during the inspection. This is the principal real-world event date (TRANSACTION_HEADER: BUSINESS_EVENT_TIMESTAMP at date granularity), distinct from the inspection start',
    `finding_description` STRING COMMENT 'Full narrative description of the inspection finding as documented by the regulatory authority, including the specific deficiency observed, the regulatory standard violated, and any factual basis cited (e.g., verbatim text from FDA Form 483 observation or',
    `finding_number` STRING COMMENT 'Externally-assigned sequential identifier for this finding within the inspection, as issued by the regulatory authority (e.g., FDA Form 483 observation number, EMA GCP inspection finding reference).. Valid values are `^[A-Z0-9-]{3,30}$`',
    `finding_status` STRING COMMENT 'Current lifecycle status of the inspection finding from issuance through resolution. Open indicates the finding has been issued and awaits a formal response. Response_submitted indicates the sponsor/CRO has submitted a written response.. Valid values are `open|response_submitted|under_review|closed|escalated`',
    `finding_title` STRING COMMENT 'Short, human-readable title or headline summarizing the nature of the inspection finding, as recorded in MasterControl. Used for executive dashboards and regulatory commitment registers.',
    `gcp_principle_violated` STRING COMMENT 'The specific ICH GCP principle or section that the finding determines was violated (e.g., ICH E6(R2) 4.8 - Informed Consent, ICH E6(R2) 5.18 - Monitoring, ICH E6(R2) 6.4 - Protocol Amendments).',
    `inspector` STRING COMMENT 'Name of the regulatory inspector or lead inspector who identified and documented this finding. Recorded for correspondence and response addressing purposes. Classified as confidential as it identifies a government official in a regulatory context.',
    `protocol_deviation_related` BOOLEAN COMMENT 'Indicates whether this inspection finding is directly related to a protocol deviation or series of protocol deviations. Enables cross-domain linkage between compliance findings and protocol deviation management.',
    `record_owner` STRING COMMENT 'Name or identifier of the individual (typically a QA manager or Regulatory Affairs lead) responsible for managing the response and resolution of this inspection finding within the sponsor or CRO organization.',
    `regulatory_citation` STRING COMMENT 'Specific regulatory reference cited by the inspecting authority as the basis for the finding (e.g., 21 CFR 312.62(b), ICH E6(R2) Section 4.9.0, EU CTR 536/2014 Article 47). Critical for formal response drafting and legal review.',
    `repeat_finding` BOOLEAN COMMENT 'Indicates whether this finding is a recurrence of a previously identified deficiency at the same site or sponsor level. Repeat findings signal systemic quality failures and may trigger escalated regulatory enforcement action.',
    `response_adequacy_assessment` STRING COMMENT 'The regulatory authoritys assessment of whether the sponsors formal response to the finding is adequate. Adequate results in finding closure. Inadequate or Partially_adequate requires a supplemental response.. Valid values are `adequate|inadequate|partially_adequate|pending_review`',
    `response_due_date` DATE COMMENT 'Formal deadline by which the sponsor or CRO must submit a written response to the regulatory authority. For FDA Form 483 observations, this is typically 15 business days from the last day of inspection.',
    `response_submitted_date` DATE COMMENT 'Actual date on which the formal written response to the inspection finding was submitted to the regulatory authority. Used to calculate response timeliness and compliance with regulatory deadlines.',
    `root_cause_category` STRING COMMENT 'Categorical classification of the root cause to enable trend analysis across findings. Process indicates a procedural gap; Training indicates inadequate staff training; System indicates an EDC, CTMS, or IT system failure; Communication indicates a. Valid values are `process|training|system|communication|resource|oversight`',
    `root_cause_description` STRING COMMENT 'Documented root cause of the deficiency identified in the inspection finding, as determined through the CAPA investigation process. Supports systemic quality improvement and recurrence prevention.',
    `source` STRING COMMENT 'The type of regulatory document in which this finding was formally issued. Form_483 refers to FDA Inspectional Observations. Warning_letter refers to an FDA Warning Letter. EIR refers to an FDA Establishment Inspection Report.. Valid values are `form_483|warning_letter|eir|gcp_inspection_report|establishment_inspection_report|other`',
    `sponsor_response_summary` STRING COMMENT 'Executive summary of the sponsors or CROs formal written response to the inspection finding, including the root cause identified, immediate corrective actions taken, and preventive measures committed.',
    `subject_safety_impact` STRING COMMENT 'Assessment of whether the finding has a direct or potential impact on subject safety. None indicates no subject safety risk. Potential indicates a theoretical risk that has not materialized.. Valid values are `none|potential|confirmed`',
    `supplemental_response_due_date` DATE COMMENT 'Deadline for submission of a supplemental or follow-up response when the initial response was assessed as inadequate or partially adequate by the regulatory authority. Null if no supplemental response is required.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this inspection finding record. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `warning_letter_reference` STRING COMMENT 'Official reference number of the FDA Warning Letter or equivalent regulatory enforcement communication issued in connection with this finding. Populated only when escalation_status is warning_letter.',
    CONSTRAINT pk_inspection_finding PRIMARY KEY(`inspection_finding_id`)
) COMMENT 'Transactional record of individual findings issued by a regulatory authority during a formal inspection. Captures finding number, regulatory citation (e.g., FDA Form 483 observation, EMA GCP non-compliance), finding classification (critical, major';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` (
    `compliance_capa_id` BIGINT COMMENT 'Unique system-generated identifier for the CAPA record. Primary key for the CAPA lifecycle master record sourced from MasterControl CAPA module.',
    `audit_id` BIGINT COMMENT 'Identifier of the internal or external audit that generated the finding triggering this CAPA. Null if the CAPA was not initiated from an audit. Enables audit-to-CAPA traceability.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: capa.sop_reference is a free-text string identifying the SOP associated with the CAPA. Replacing it with a FK to sop.sop_id enables structured linkage between CAPAs and the SOPs they address',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: CAPAs with sponsor_notified_flag=true require routing notifications to the correct sponsor org.',
    `primary_compliance_capa_approved_by_employee_id` BIGINT COMMENT 'Identifier of the QA manager or authorized approver who reviewed and approved the CAPA plan in MasterControl. Required for GCP compliance and electronic signature audit trail per 21 CFR Part 11.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key to the regulatory inspection record',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: CAPAs arising from sponsor-facing quality events are tracked per engagement for account health reporting and governance reviews.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study associated with this CAPA. Links the CAPA to the relevant study protocol for study-level quality tracking and regulatory reporting.',
    `study_site_id` BIGINT COMMENT 'Identifier of the investigational site associated with this CAPA, if site-specific. Null for sponsor-level or cross-site CAPAs. Supports site-level quality performance analytics.',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: CAPAs with training_required_flag=true must specify the exact training curriculum assigned as corrective/preventive action.',
    `actual_completion_date` DATE COMMENT 'Actual calendar date on which all corrective and preventive actions were completed and verified. Null until CAPA is closed. Used to calculate cycle time and on-time closure rate KPIs.',
    `approval_date` DATE COMMENT 'Date on which the CAPA plan was formally approved by the authorized QA approver in MasterControl. Marks the transition from initiation to active execution phase.',
    `capa_type` STRING COMMENT 'Indicates whether the action is corrective (addressing an existing non-conformance), preventive (addressing a potential non-conformance), or both. Drives workflow routing in MasterControl.. Valid values are `corrective|preventive|both`',
    `closure_justification` STRING COMMENT 'Narrative justification provided by the responsible owner and QA approver at the time of CAPA closure, summarizing evidence that all actions were completed and the root cause was resolved. Required for regulatory inspection readiness.',
    `corrective_action_plan` STRING COMMENT 'Detailed description of the corrective actions planned or implemented to address the identified root cause and prevent recurrence of the quality issue. Core CAPA deliverable per GCP requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the CAPA record was first created in the lakehouse silver layer. Supports audit trail, data lineage, and 21 CFR Part 11 electronic records compliance.',
    `data_integrity_impact_flag` BOOLEAN COMMENT 'Indicates whether the quality issue underlying this CAPA had or could have had an impact on clinical data integrity. Triggers data review, potential database query, and regulatory notification workflows.',
    `effectiveness_check_date` DATE COMMENT 'Planned or actual date on which the effectiveness of the implemented corrective and preventive actions will be or was verified. Required by GCP to confirm the CAPA resolved the root cause.',
    `effectiveness_check_description` STRING COMMENT 'Narrative description of the methodology and findings from the effectiveness check, including evidence reviewed and conclusions drawn. Supports regulatory inspection readiness.',
    `effectiveness_check_result` STRING COMMENT 'Outcome of the effectiveness verification assessment confirming whether the implemented CAPA actions successfully resolved the root cause and prevented recurrence. Drives CAPA closure or re-opening decisions.. Valid values are `effective|partially_effective|not_effective|pending`',
    `gcp_impact_assessment` STRING COMMENT 'Assessment of the impact of the underlying quality issue on GCP compliance and data integrity. Drives CAPA priority, escalation, and regulatory reporting decisions. Aligned with FDA and EMA GCP inspection classification standards.. Valid values are `critical|major|minor|no_impact`',
    `immediate_action_taken` STRING COMMENT 'Description of any immediate containment or interim actions taken at the time of CAPA initiation to mitigate the impact of the quality issue before the full corrective action is implemented.',
    `initiation_date` DATE COMMENT 'Calendar date on which the CAPA was formally initiated and entered into MasterControl. Serves as the start of the CAPA lifecycle clock for overdue tracking and regulatory reporting.',
    `mastercontrol_record_number` STRING COMMENT 'Native record identifier assigned by the MasterControl CAPA module. Used for source system traceability, data lineage, and reconciliation between the lakehouse silver layer and the operational system of record.',
    `preventive_action_plan` STRING COMMENT 'Detailed description of the preventive actions planned to eliminate the potential for recurrence of similar quality issues across the organization or study portfolio.',
    `priority` STRING COMMENT 'Risk-based priority level assigned to the CAPA, reflecting the severity and urgency of the underlying quality issue. Drives escalation timelines and resource allocation.. Valid values are `critical|high|medium|low`',
    `problem_description` STRING COMMENT 'Detailed description of the quality issue, non-conformance, or finding that triggered the CAPA. Captures the what happened narrative for audit trail and regulatory inspection purposes.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this CAPA addresses a recurring quality issue that has been the subject of a prior CAPA. True signals a systemic quality problem requiring escalated management attention.',
    `reference_number` STRING COMMENT 'Externally-known, human-readable CAPA reference number assigned by MasterControl upon initiation (e.g., CAPA-2024-00123). Used in audit trails, regulatory submissions, and sponsor communications.. Valid values are `^CAPA-[0-9]{4}-[0-9]{5}$`',
    `regulatory_reportable_flag` BOOLEAN COMMENT 'Indicates whether this CAPA is associated with a finding that requires regulatory reporting to FDA, EMA, MHRA, or other health authority. Drives regulatory submission workflow in Veeva Vault.',
    `responsible_department` STRING COMMENT 'Organizational department or functional area accountable for CAPA execution (e.g., Clinical Operations, Data Management, Regulatory Affairs, Quality Assurance). Used for departmental quality KPI reporting.',
    `root_cause_category` STRING COMMENT 'Standardized category classifying the root cause of the quality issue (e.g., training deficiency, process gap, system failure, communication breakdown, resource constraint). Used for trend analysis and systemic quality improvement.',
    `root_cause_description` STRING COMMENT 'Detailed narrative describing the identified root cause of the quality issue, as determined through root cause analysis (RCA). Supports regulatory inspection readiness and CAPA justification.',
    `source_reference_code` BIGINT COMMENT 'Identifier of the originating record that triggered this CAPA (e.g., audit finding ID, inspection finding ID, protocol deviation ID, or QC failure ID). Enables traceability back to the root triggering event.',
    `source_type` STRING COMMENT 'Category of the triggering event that initiated the CAPA. Classifies whether the CAPA originated from an internal audit, regulatory inspection, protocol deviation, QC failure, self-identified quality issue, complaint, or safety signal.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the study sponsor was formally notified of this CAPA. Null if sponsor_notified_flag is False. Supports sponsor oversight audit trail.',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this CAPA. Required for CRO-managed studies where sponsor oversight obligations apply per ICH E6(R2) GCP.',
    `compliance_capa_status` STRING COMMENT 'Current lifecycle state of the CAPA record. Drives workflow routing, escalation triggers, and regulatory reporting. Overdue is system-set when target completion date is passed without closure.. Valid values are `open|in_progress|closed|overdue|cancelled`',
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the quality issue underlying this CAPA had or could have had a direct impact on subject safety. Triggers expedited review and potential safety reporting obligations.',
    `target_completion_date` DATE COMMENT 'Planned date by which all corrective and preventive actions must be completed and the CAPA closed. Used for overdue status calculation, escalation triggers, and sponsor/regulatory reporting.',
    `title` STRING COMMENT 'Short, descriptive title summarizing the quality issue or finding that triggered the CAPA. Used for identification in dashboards, reports, and audit-readiness reviews.',
    `training_required_flag` BOOLEAN COMMENT 'Indicates whether the corrective or preventive action includes a mandatory training component. When True, triggers training assignment workflow in MasterControl training management module.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the CAPA record was last modified in the lakehouse silver layer. Supports change tracking, audit trail integrity, and 21 CFR Part 11 electronic records compliance.',
    CONSTRAINT pk_compliance_capa PRIMARY KEY(`compliance_capa_id`)
) COMMENT 'Master record for Corrective and Preventive Actions (CAPA) initiated in response to audit findings, inspection findings, protocol deviations, QC failures, or self-identified quality issues.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` (
    `capa_action_item_id` BIGINT COMMENT 'Unique surrogate identifier for each individual action item within a CAPA plan. Primary key for this transactional line record. Entity role: TRANSACTION_LINE — each action item is a discrete line within a parent CAPA plan header, with its own owner, due',
    `capa_action_owner_employee_id` BIGINT COMMENT 'Reference to the individual (employee or contractor) responsible for executing and completing this action item. Serves as the PARTY_REFERENCE for this TRANSACTION_LINE entity.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the parent CAPA plan to which this action item belongs. A single CAPA plan may contain multiple discrete action items tracked independently. Serves as the HEADER_REFERENCE for this TRANSACTION_LINE entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: capa_action_item.related_sop_number is a free-text string referencing the SOP relevant to the action item.',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: Individual CAPA action items with training_required=true must reference the specific training curriculum to be completed.',
    `action_item_number` STRING COMMENT 'Externally-known, human-readable business identifier for this action item within MasterControl (e.g., CAPA-AI-2024-0042). Used in audit trails, regulatory inspection responses, and cross-system references.. Valid values are `^CAPA-AI-[0-9]{4}-[0-9]{4}$`',
    `action_item_status` STRING COMMENT 'Current workflow state of the action item within the CAPA execution lifecycle. Drives CAPA closure eligibility — all action items must reach completed or cancelled before the parent CAPA can be closed. Serves as the LIFECYCLE_STATUS for this entity.. Valid values are `open|in_progress|completed|overdue|cancelled|on_hold`',
    `action_item_type` STRING COMMENT 'Classification of the action item by its nature within the CAPA framework: corrective (addresses the identified nonconformance), preventive (prevents recurrence), effectiveness check (verifies the CAPA resolved the issue), root cause analysis, training',
    `actual_completion_date` DATE COMMENT 'Date on which the action item was actually completed and evidence was submitted. Compared against planned_completion_date to measure CAPA execution timeliness. Null until the action item reaches completed status.',
    `assigned_owner_department` STRING COMMENT 'Organizational department or functional unit of the assigned owner (e.g., Quality Assurance, Data Management, Clinical Operations). Used for workload analysis, departmental CAPA metrics, and escalation routing.',
    `closed_timestamp` TIMESTAMP COMMENT 'Timestamp when this action item was formally closed in MasterControl following successful completion and verification. Null until the item reaches a terminal state (completed or cancelled). Used to calculate cycle time metrics.',
    `comments` STRING COMMENT 'Free-text field for additional notes, progress updates, or contextual information entered by the action item owner or QA reviewer during the execution lifecycle. Supports ongoing communication and audit trail within MasterControl.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this action item record was first created in MasterControl. Serves as the RECORD_AUDIT_CREATED for this entity. Supports ALCOA+ auditability and 21 CFR Part 11 electronic record requirements.',
    `days_open` BIGINT COMMENT 'Number of calendar days this action item has been open, calculated from opened_timestamp to either actual_completion_date (if closed) or the current date (if still open). Used as a KPI for CAPA execution timeliness and audit readiness dashboards.',
    `capa_action_item_description` STRING COMMENT 'Detailed narrative describing the specific action to be taken, including scope, methodology, and expected outcome. Provides the full context required for the assigned owner to execute the action and for auditors to assess adequacy of the response.',
    `due_date_extension_count` BIGINT COMMENT 'Number of times the planned completion date has been extended for this action item. A high extension count is a quality risk indicator and may trigger escalation or QA review. Tracked per MasterControl audit trail requirements.',
    `effectiveness_check_due_date` DATE COMMENT 'Target date by which the effectiveness check for this action item must be completed. Null if effectiveness_check_required is False. Used to schedule and track post-implementation reviews.',
    `effectiveness_check_required` BOOLEAN COMMENT 'Indicates whether a post-completion effectiveness check is required for this action item to confirm the corrective or preventive action achieved its intended outcome. Typically mandated for critical or repeat findings per GCP quality standards.',
    `effectiveness_check_status` STRING COMMENT 'Current status of the post-completion effectiveness check for this action item. Effective confirms the action resolved the root cause; ineffective triggers re-opening of the CAPA or creation of a new CAPA.. Valid values are `not_required|pending|in_progress|effective|ineffective`',
    `escalation_date` DATE COMMENT 'Date on which this action item was formally escalated. Null if escalation_flag is False. Used to measure escalation response time and management accountability.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this action item has been escalated to senior management or QA leadership due to overdue status, repeated extensions, or high risk. Triggers escalation notifications and management review workflows in MasterControl.',
    `evidence_description` STRING COMMENT 'Narrative description of the evidence provided to demonstrate completion of the action item (e.g., Updated SOP-QA-012 v3.0 attached; training records for 12 staff members uploaded). Supports QA verification and regulatory inspection readiness.',
    `evidence_document_reference` STRING COMMENT 'Reference identifier or URL to the supporting evidence document stored in Veeva Vault or MasterControl (e.g., document ID, eTMF reference, SOP version number). Links the action item completion to the formal document management system.',
    `extension_justification` STRING COMMENT 'Narrative explanation provided by the action item owner or QA approver when the planned completion date is extended. Required for audit trail completeness and regulatory inspection readiness. Null if no extension has been granted.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this action item record in MasterControl. Serves as the RECORD_AUDIT_UPDATED for this entity. Required for change tracking and audit trail completeness per 21 CFR Part 11.',
    `mastercontrol_record_number` STRING COMMENT 'Native record identifier assigned by MasterControl to this action item in the source system. Used for cross-system traceability, data lineage, and reconciliation between the Databricks Silver layer and the MasterControl operational system of record.',
    `opened_timestamp` TIMESTAMP COMMENT 'Timestamp when this action item was formally opened and assigned to an owner. Serves as the BUSINESS_EVENT_TIMESTAMP for this TRANSACTION_LINE entity. Distinct from created_timestamp, which reflects system record creation.',
    `planned_completion_date` DATE COMMENT 'Target date by which the action item is expected to be completed, as agreed upon during CAPA planning. Used to calculate overdue status, track CAPA execution timeliness, and report on compliance with committed timelines to sponsors and regulatory bodies.',
    `priority` STRING COMMENT 'Business priority level assigned to this action item, reflecting urgency and risk impact. Critical and high-priority items are subject to expedited review and escalation procedures. Drives resource allocation and monitoring frequency.. Valid values are `critical|high|medium|low`',
    `regulatory_authority` STRING COMMENT 'The regulatory authority to which this action item represents a formal commitment, if regulatory_commitment is True (e.g., FDA, EMA, MHRA). Null if this is an internal CAPA action item without a regulatory commitment dimension.',
    `regulatory_commitment` BOOLEAN COMMENT 'Indicates whether this action item represents a formal commitment made to a regulatory authority (FDA, EMA, MHRA, etc.) during an inspection or in a regulatory submission response.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this action item within the parent CAPA plan (e.g., 1, 2, 3). Enables ordered display and reporting of action items within a CAPA. Serves as the LINE_SEQUENCE for this TRANSACTION_LINE entity.',
    `source_finding_reference` STRING COMMENT 'Reference identifier of the specific audit finding, inspection observation, protocol deviation, or nonconformance that this action item directly addresses (e.g., audit finding number, deviation ID).',
    `title` STRING COMMENT 'Short, descriptive title summarizing the action item (e.g., Revise SOP-QA-012 to include double-check step). Used in dashboards, reports, and inspection-ready summaries within MasterControl.',
    `training_completion_date` DATE COMMENT 'Date on which all required training associated with this action item was completed and documented in MasterControl. Null if training_required is False or training has not yet been completed. Required as part of completion evidence.',
    `training_required` BOOLEAN COMMENT 'Indicates whether completion of this action item requires associated staff training (e.g., training on a revised SOP). When True, training completion records in MasterControl must be linked as evidence before the action item can be verified.',
    `verification_comments` STRING COMMENT 'Free-text comments entered by the QA verifier during the evidence review, including rationale for rejection or conditions for acceptance. Provides the audit trail narrative required for regulatory inspection readiness.',
    `verification_date` DATE COMMENT 'Date on which the QA verifier confirmed the completion evidence was adequate and the action item was satisfactorily executed. Null until verification is completed. Required for regulatory inspection audit trail.',
    `verification_outcome` STRING COMMENT 'Result of the QA verification review of the action item completion evidence. Accepted closes the verification loop; rejected returns the item to the owner for rework; pending_revision indicates partial acceptance with required amendments.. Valid values are `accepted|rejected|pending_revision`',
    `verification_required` BOOLEAN COMMENT 'Indicates whether independent QA verification of completion evidence is required before this action item can be marked as completed. True for high-risk or critical action items per the CAPA procedure. Drives the QA review workflow in MasterControl.',
    CONSTRAINT pk_capa_action_item PRIMARY KEY(`capa_action_item_id`)
) COMMENT 'Transactional record of individual action items within a CAPA plan. Each CAPA may have multiple discrete action items assigned to different owners with independent due dates and completion statuses.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` (
    `protocol_deviation_id` BIGINT COMMENT 'Primary key for protocol_deviation',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: Protocol deviations directly determine per-protocol population exclusions (subject_excluded_from_pp_flag exists on protocol_deviation).',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the associated CAPA record in MasterControl, if a corrective and preventive action has been initiated in response to this deviation.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Protocol deviations must be reconciled and resolved before database lock.',
    `deviation_classification_id` BIGINT COMMENT 'Foreign key linking to compliance.deviation_classification. Business justification: protocol_deviation has deviation_category and deviation_type as free-text strings.',
    `employee_id` BIGINT COMMENT 'Reference to the workforce member (CRA, CRC, QA auditor, or data manager) who first identified and documented the deviation.',
    `estimand_id` BIGINT COMMENT 'Foreign key linking to biostatistics.estimand. Business justification: ICH E9(R1) requires deviations to be assessed against estimand strategies (intercurrent events, missing data).',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Lab results that are missing, out-of-range, or collected outside protocol windows trigger protocol deviations.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Protocol deviations have sponsor_reporting_required and sponsor_reported_date fields requiring direct sponsor org identification.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Protocol deviations are violations of a specific protocol version. Direct FK to protocol enables deviation analysis by protocol version, supports CSR deviation summaries, and is required for',
    `protocol_lab_schedule_id` BIGINT COMMENT 'Foreign key linking to laboratory.protocol_lab_schedule. Business justification: Protocol deviations for missed or incorrect lab assessments are evaluated against the protocol lab schedule.',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to supply.shipment. Business justification: Shipment failures (delayed delivery causing missed dose window, wrong kits shipped) are a documented category of protocol deviations.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: Specimen collection errors (wrong tube, wrong time, insufficient volume) are among the most frequent protocol deviation types.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this deviation occurred. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the protocol deviation was identified or occurred.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the monitoring visit during which this deviation was identified, if applicable. Links to the monitoring visit record for traceability.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Protocol deviations must be documented in the TMF per ICH E6(R2). The deviation record references the specific TMF document (e.g., deviation report, PI notification letter).',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: Protocol deviations frequently trigger mandatory retraining as corrective action.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the study subject (patient) associated with this deviation, if applicable. Nullable for site-level or system-level deviations not tied to a specific subject.',
    `audit_readiness_status` STRING COMMENT 'Indicates the current audit readiness state of this deviation record, confirming that all required documentation, reporting, and CAPA activities are complete and the record is inspection-ready.. Valid values are `ready|not_ready|in_progress|not_applicable`',
    `corrective_action_summary` STRING COMMENT 'Brief summary of the immediate corrective actions taken to address the deviation and prevent recurrence, prior to or independent of a formal CAPA. Captures site-level remediation steps.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the protocol deviation record was first created in the source system (CTMS or EDC). Supports ALCOA+ audit trail requirements.',
    `data_integrity_impact` STRING COMMENT 'Assessment of whether the deviation compromised the integrity, reliability, or interpretability of study data. Informs decisions on data exclusion, sensitivity analyses, or database lock.. Valid values are `no_impact|potential_impact|confirmed_impact|unknown`',
    `detected_by` STRING COMMENT 'The method or source by which the deviation was detected. Indicates whether it was found during CRA monitoring visit, site self-identification, sponsor audit, regulatory inspection, central data review, or subject report.',
    `deviation_category` STRING COMMENT 'Classification of the deviation by severity and regulatory impact. Major deviations directly affect subject safety, data integrity, or regulatory compliance. Minor deviations have minimal impact.. Valid values are `major|minor|important`',
    `deviation_description` STRING COMMENT 'Detailed narrative description of the protocol deviation, including what protocol requirement was not met, the circumstances under which it occurred, and any immediate actions taken. Sourced from the eCRF or CTMS deviation entry.',
    `deviation_ref_number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to the protocol deviation record, typically generated by the CTMS (the source system or EDC (Medidata Rave). Used for cross-system traceability and regulatory correspondence.. Valid values are `^PD-[A-Z0-9]{3,20}-[0-9]{4,10}$`',
    `deviation_status` STRING COMMENT 'Current workflow lifecycle state of the deviation record. Open indicates newly identified; under_review indicates active investigation; resolved indicates corrective action completed; closed indicates fully adjudicated and archived; escalated. Valid values are `open|under_review|resolved|closed|escalated|voided`',
    `deviation_type` STRING COMMENT 'Functional classification of the deviation describing which protocol requirement was violated. Common types include: eligibility, dosing, visit_window, prohibited_medication, consent, randomization, assessments, sample_collection, concomitant_medication',
    `discovery_date` DATE COMMENT 'The date on which the protocol deviation was first identified or discovered, which may differ from the occurrence date. Used to calculate detection lag and assess monitoring effectiveness.',
    `ecrf_form_ref` STRING COMMENT 'Reference to the specific eCRF form or data point in Medidata Rave EDC that is associated with this deviation, enabling direct traceability to the source data record.',
    `include_in_csr_flag` BOOLEAN COMMENT 'Indicates whether this deviation must be listed or summarized in the Clinical Study Report (CSR) per ICH E3 requirements. Major and important deviations are typically included.',
    `irb_iec_reported_date` DATE COMMENT 'The date on which the deviation was formally submitted to the IRB/IEC. Used to verify compliance with reporting timelines and to support audit readiness.',
    `irb_iec_reporting_required` BOOLEAN COMMENT 'Indicates whether this deviation must be reported to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) per applicable regulations and the IRB/IEC-approved protocol.',
    `occurrence_date` DATE COMMENT 'The date on which the protocol deviation actually occurred (i.e., the date the protocol requirement was not met). This is the principal real-world event date per CDISC SDTM DVSTDTC.',
    `pi_notified_date` DATE COMMENT 'The date on which the Principal Investigator (PI) was formally notified of the deviation. Required for GCP compliance and site management accountability.',
    `protocol_requirement_ref` STRING COMMENT 'Specific section, clause, or criterion number within the study protocol that was deviated from (e.g., Section 5.3 Inclusion Criterion 2). Enables precise traceability to the protocol document.',
    `protocol_version` STRING COMMENT 'Version of the study protocol that was in effect at the time the deviation occurred. Critical for determining which protocol requirements were applicable.',
    `regulatory_authority_reported_date` DATE COMMENT 'The date on which the deviation was formally submitted to the applicable regulatory authority (FDA, EMA, PMDA, etc.), where regulatory reporting was required.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this deviation must be reported to a regulatory authority (e.g., FDA, EMA, PMDA) as part of IND safety reporting or clinical trial notification obligations.',
    `repeat_deviation_flag` BOOLEAN COMMENT 'Indicates whether this deviation is a recurrence of a previously identified deviation of the same type at the same site or by the same subject. Used for trend analysis and escalation decisions.',
    `reported_date` DATE COMMENT 'The date on which the deviation was formally reported to the sponsor, IRB/IEC, or regulatory authority as required. Used to assess compliance with reporting timelines.',
    `resolution_date` DATE COMMENT 'The date on which the deviation was resolved and corrective actions were confirmed as complete. Marks the end of the active deviation lifecycle.',
    `root_cause_category` STRING COMMENT 'Categorized root cause of the deviation as determined during investigation. Common categories include: training_gap, communication_failure, process_gap, system_error, oversight, workload, protocol_complexity, subject_non_compliance.',
    `root_cause_description` STRING COMMENT 'Detailed narrative of the identified root cause of the protocol deviation, as documented during the investigation process. Supports CAPA development and trend analysis.',
    `source_system_record_number` STRING COMMENT 'The native record identifier from the originating source system (e.g., Medidata Rave deviation ID or the source system deviation record ID). Enables upstream reconciliation and audit trail.',
    `sponsor_reported_date` DATE COMMENT 'The date on which the deviation was formally communicated to the sponsor. Used to verify compliance with sponsor notification timelines per the Clinical Trial Agreement.',
    `sponsor_reporting_required` BOOLEAN COMMENT 'Indicates whether this deviation must be formally reported to the study sponsor per the Clinical Trial Agreement and sponsor SOPs.',
    `subject_excluded_from_pp_flag` BOOLEAN COMMENT 'Indicates whether this deviation resulted in the exclusion of the subject from the Per Protocol (PP) analysis population, as determined by the biostatistics team per the Statistical Analysis Plan (the source system).',
    `subject_impact_assessment` STRING COMMENT 'Assessment of whether the deviation had an impact on subject safety, rights, or well-being. Used to determine reporting obligations and CAPA urgency.. Valid values are `no_impact|potential_impact|confirmed_impact|unknown`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the protocol deviation record. Supports ALCOA+ audit trail and change tracking requirements.',
    CONSTRAINT pk_protocol_deviation PRIMARY KEY(`protocol_deviation_id`)
) COMMENT 'Transactional record of protocol deviations identified during study conduct. Captures deviation reference number, study and site identifiers, subject identifier (if applicable), deviation category (major, minor, important), deviation type (eligibility';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` (
    `deviation_classification_id` BIGINT COMMENT 'Primary key for deviation_classification',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Deviation classification taxonomy requires traceable approval by a qualified QA employee for GCP inspection readiness and change control governance.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — deviation classifications should be study-specific',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Deviation classification schemes are TA-specific (e.g., oncology dose deviation classifications differ from CNS).',
    `applicable_phase` STRING COMMENT 'Clinical trial phase(s) to which this deviation classification applies (e.g., Phase I, Phase II, Phase III, Phase IV, All). Some deviation types are phase-specific (e.g., first-in-human dose escalation deviations).',
    `approval_date` DATE COMMENT 'Date on which this deviation classification record was formally approved by the QA authority in MasterControl. Part of the 21 CFR Part 11 compliant audit trail for the quality management system.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) plan must be initiated for deviations of this type. Drives CAPA workflow initiation in MasterControl quality management system.',
    `classification_status` STRING COMMENT 'Lifecycle status of this deviation classification record: draft (under review), active (approved and in use), retired (no longer applicable to new studies), or superseded (replaced by a newer version).. Valid values are `draft|active|retired|superseded`',
    `classification_version` STRING COMMENT 'Version number of this deviation classification record (e.g., 1.0, 2.1). Supports version control of the taxonomy in MasterControl, ensuring studies reference the correct classification version at the time of protocol approval.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `comments` STRING COMMENT 'Additional free-text comments or clarifications regarding the application of this deviation classification, including edge cases, sponsor-specific interpretations, or historical context. Maintained by the QA team in MasterControl.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this deviation classification record was first created in MasterControl. Supports ALCOA+ contemporaneous documentation requirements and 21 CFR Part 11 audit trail.',
    `csr_reporting_section` STRING COMMENT 'Section of the Clinical Study Report (CSR) where deviations of this type must be summarized per ICH E3 guidelines (e.g., Section 10.2 — Protocol Deviations, Section 12 — Safety). Guides medical writers and biostatisticians in SAS Drug Development.',
    `data_integrity_impact` STRING COMMENT 'Assessment of the potential impact on study data integrity for deviations of this type: none, potential, or confirmed. Drives data review and query generation priorities in Medidata Rave EDC and informs database lock (DBL) decisions.. Valid values are `none|potential|confirmed`',
    `deviation_category` STRING COMMENT 'High-level classification of the deviation severity: major (significant impact on subject safety or data integrity), minor (minimal impact), or important_protocol_deviation (IPD — deviations that may significantly affect subject safety, rights, or. Valid values are `major|minor|important_protocol_deviation`',
    `deviation_subcategory` STRING COMMENT 'Secondary classification grouping deviation types into functional areas (e.g., Eligibility, Dosing, Visit Schedule, Informed Consent, Laboratory, Randomization, Blinding). Enables granular analytics and trend reporting across studies.',
    `deviation_type_code` STRING COMMENT 'Unique alphanumeric code identifying the specific deviation type within the classification taxonomy (e.g., PD-001, PD-002). Used as the externally-known business identifier for cross-study referencing and regulatory submissions. Managed in MasterControl.. Valid values are `^[A-Z]{2,6}-[0-9]{3,6}$`',
    `deviation_type_name` STRING COMMENT 'Human-readable name of the deviation type (e.g., Missed Study Visit, Incorrect Dose Administration, Eligibility Criteria Violation). Serves as the primary identity label for display in CTMS, EDC, and regulatory reports.',
    `effective_date` DATE COMMENT 'Date from which this deviation classification version becomes effective and applicable to new and ongoing studies. Studies initiated on or after this date must use this classification version.',
    `ema_guidance_reference` STRING COMMENT 'Specific EMA guideline or regulation section applicable to this deviation type (e.g., EMA GCP Guideline CPMP/ICH/135/95, EU CTR 536/2014 Article 54). Supports compliance for EU-based clinical trials.',
    `fda_guidance_reference` STRING COMMENT 'Specific FDA guidance document and section applicable to this deviation type (e.g., FDA Guidance for Industry: Oversight of Clinical Investigations, Section IV). Supports regulatory inspection readiness and audit trail documentation.',
    `frequency_threshold_count` BIGINT COMMENT 'Maximum acceptable number of occurrences of this deviation type at a single site before a systematic issue is declared and escalated per the risk-based monitoring plan. Null if no frequency threshold is defined for this type.',
    `gcp_principle_violated` STRING COMMENT 'Specific ICH GCP principle(s) violated by deviations of this type (e.g., Subject Rights and Safety, Data Integrity, Investigator Responsibilities). Used in QA reporting and regulatory inspection responses to demonstrate GCP compliance awareness.',
    `ich_guidance_reference` STRING COMMENT 'Specific ICH guideline section(s) applicable to this deviation type (e.g., ICH E6(R2) Section 4.5, ICH E8(R1)). Provides the authoritative regulatory basis for the classification and reporting requirements.',
    `inspection_readiness_notes` STRING COMMENT 'Free-text notes providing guidance on how to present and defend deviations of this type during FDA, EMA, or MHRA regulatory inspections. Maintained by the QA team to support audit readiness activities.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether deviations of this type require prompt notification to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) per applicable regulations and sponsor SOPs. Drives site-level compliance workflows in the source system',
    `is_blinding_sensitive` BOOLEAN COMMENT 'Indicates whether deviations of this type involve or risk unblinding of treatment assignment in blinded studies. When True, special handling procedures apply to protect study integrity and prevent unintended unblinding during deviation review.',
    `itt_exclusion_flag` BOOLEAN COMMENT 'Indicates whether deviations of this type may trigger exclusion of the affected subject from the Intent-to-Treat (ITT) analysis population. Typically False for most deviation types; True only for critical eligibility violations.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this deviation classification record was most recently modified in MasterControl. Part of the 21 CFR Part 11 compliant audit trail. Used to detect taxonomy changes that may affect ongoing studies.',
    `mastercontrol_record_number` STRING COMMENT 'Source system record identifier from MasterControl document control system for this deviation classification entry. Enables traceability back to the authoritative quality management system record for audit purposes.',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class (SOC) code associated with this deviation type when the deviation relates to a clinical or safety event. Enables cross-referencing with adverse event coding in the source system for integrated safety analysis.',
    `monitoring_escalation_required` BOOLEAN COMMENT 'Indicates whether identification of this deviation type at a site requires escalation of monitoring intensity (e.g., triggered on-site visit, increased SDV rate) per the risk-based monitoring plan. Drives monitoring plan adjustments in the source system',
    `per_protocol_exclusion_flag` BOOLEAN COMMENT 'Indicates whether deviations of this type automatically trigger exclusion of the affected subject from the Per Protocol (PP) analysis population. Used by biostatisticians in SAS Drug Development when applying the Statistical Analysis Plan (the source',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this deviation type meets the threshold requiring regulatory reporting to the FDA, EMA, or other applicable health authority. When True, deviations of this type must be included in IND annual reports, clinical study reports (CSR), or',
    `reporting_timeframe_days` BIGINT COMMENT 'Maximum number of calendar days within which a deviation of this type must be reported to the applicable regulatory authority or sponsor after identification. Null if no mandatory reporting timeframe applies.',
    `retirement_date` DATE COMMENT 'Date on which this deviation classification version was retired or superseded. Null if the classification is currently active. Studies ongoing at retirement may continue using the prior version per protocol freeze rules.',
    `risk_score` BIGINT COMMENT 'Numeric risk score (typically 1–10) assigned to this deviation type based on its potential impact on subject safety, data integrity, and regulatory compliance.',
    `sdtm_domain_code` STRING COMMENT 'CDISC SDTM domain code associated with this deviation type (typically DV for Protocol Deviations). Used to map deviation records to the correct SDTM submission dataset during regulatory data package preparation in SAS Drug Development.. Valid values are `^[A-Z]{2}$`',
    `sop_reference_code` STRING COMMENT 'Document control code of the governing Standard Operating Procedure (SOP) in MasterControl that defines the handling, reporting, and CAPA requirements for this deviation type (e.g., SOP-QA-0042). Ensures traceability to the quality management system.',
    `sponsor_notification_required` BOOLEAN COMMENT 'Indicates whether deviations of this type require immediate or expedited notification to the study sponsor per ICH GCP and the clinical trial agreement. When True, the CRA or site must notify the sponsor within the defined timeframe.',
    `standard_description_template` STRING COMMENT 'Pre-approved narrative template text for describing deviations of this type in eCRFs, deviation logs, and regulatory submissions. Ensures consistent, ALCOA+-compliant documentation language across studies and sites. Managed in MasterControl.',
    `subject_safety_impact` STRING COMMENT 'Assessment of the potential impact on subject safety for deviations of this type: none (no safety implications), potential (possible safety concern requiring evaluation), or confirmed (known safety impact).. Valid values are `none|potential|confirmed`',
    `superseded_by_code` STRING COMMENT 'Deviation type code of the classification record that replaces this one when status is superseded. Enables forward navigation of the classification version history for regulatory audit trail purposes.',
    `created_by` STRING COMMENT 'User identifier or name of the individual who created this deviation classification record in MasterControl. Supports ALCOA+ attributability requirements and 21 CFR Part 11 audit trail.',
    CONSTRAINT pk_deviation_classification PRIMARY KEY(`deviation_classification_id`)
) COMMENT 'Reference master defining the standardized classification taxonomy for protocol deviations used across all studies. Captures deviation category (major, minor, important protocol deviation), deviation type code, regulatory reporting threshold, standard';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` (
    `compliance_sop_id` BIGINT COMMENT 'Unique surrogate identifier for the Standard Operating Procedure record in the quality management system. Primary key for the sop data product.',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: SOPs define applicable_roles as plain text; linking to job_profile enables automated SOP training assignment when a new employee is assigned a job profile, and supports GCP compliance',
    `superseded_sop_compliance_sop_id` BIGINT COMMENT 'Reference to the sop record that this version supersedes. Supports version lineage navigation and ensures the document control chain of custody is maintained for regulatory inspection.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: SOPs in clinical research are frequently scoped to therapeutic areas (e.g., oncology-specific informed consent SOPs, rare disease patient recruitment SOPs).',
    `regulatory_inspection_id` BIGINT COMMENT 'Reference to regulatory.regulatory_inspection.regulatory_inspection_id.',
    `applicable_roles` STRING COMMENT 'Comma-separated list of job roles or role groups required to be trained on and comply with this SOP (e.g., CRA, CRC, PI, QA Manager, Data Manager). Drives training assignment generation in MasterControl.',
    `approval_date` DATE COMMENT 'Date on which the SOP version received final authorized approval in MasterControl. Distinct from the effective date; the SOP may be approved before it becomes operationally binding to allow training completion.',
    `approver_name` STRING COMMENT 'Full name of the authorized signatory who approved the current version of the SOP. Typically a senior QA or functional head. Required for regulatory inspection readiness and 21 CFR Part 11 electronic signature compliance.',
    `audit_finding_reference` STRING COMMENT 'Reference identifier of the internal or external audit finding that prompted this SOP revision or creation. Supports traceability from audit observations to corrective document updates.',
    `capa_reference_number` STRING COMMENT 'Reference number of any CAPA record in MasterControl that triggered the creation or revision of this SOP version. Links SOP updates to root cause corrective actions identified through audits, inspections, or deviation investigations.',
    `change_control_number` STRING COMMENT 'Reference number of the change control record in MasterControl that authorized the creation or revision of this SOP version. Provides traceability from the SOP to the formal change management process.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the SOP document content, governing who may access and distribute it. Aligns with the organizations information security policy and GDPR/HIPAA data handling requirements.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the SOP record was first created in the quality management system. Supports ALCOA+ audit trail requirements and data lineage tracking in the Silver Layer lakehouse.',
    `deviation_classification_relevance` STRING COMMENT 'Indicates the severity classification of protocol deviations that non-compliance with this SOP would typically generate (critical, major, minor). Used by QA to pre-classify deviation risk and prioritize SOP compliance monitoring.. Valid values are `critical|major|minor|not_applicable`',
    `document_category` STRING COMMENT 'Functional category grouping for the SOP within the document management taxonomy (e.g., Quality Management, Clinical Operations, Data Management, Regulatory Affairs, Safety, Laboratory, Finance).',
    `document_status` STRING COMMENT 'Current lifecycle state of the SOP document within the quality management system workflow. Controls whether the SOP is actionable for training and compliance purposes. approved is the only status permitting operational use.. Valid values are `draft|under_review|approved|retired|superseded`',
    `document_type` STRING COMMENT 'Classification of the document within the quality management system hierarchy. SOPs define mandatory procedures; work instructions provide step-by-step task guidance; policies set organizational rules; guidance documents are advisory.. Valid values are `SOP|work_instruction|policy|guidance|template|form`',
    `effective_date` DATE COMMENT 'Date on which the approved SOP version becomes operationally binding for all applicable staff and sites. Training must be completed by this date. Aligns with the ALCOA+ principle of contemporaneous documentation.',
    `electronic_signature_required` BOOLEAN COMMENT 'Indicates whether this SOP requires electronic signatures for approval in compliance with FDA 21 CFR Part 11 and EU Annex 11 electronic records requirements. When True, wet signatures are not acceptable as the sole approval mechanism.',
    `expiry_date` DATE COMMENT 'Date on which the SOP version is scheduled to expire and must be reviewed, revised, or retired. Typically set to a fixed interval (e.g., 2–3 years) from the effective date per the organizations document control SOP.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether this SOP governs processes that involve personal data subject to GDPR requirements (e.g., patient data handling, consent management, data subject rights). Drives GDPR compliance review during SOP periodic review.',
    `geographic_applicability` STRING COMMENT 'Countries or regions where this SOP is applicable, expressed as ISO 3166-1 alpha-3 country codes or region labels (e.g., USA, GBR, DEU, GLOBAL). Relevant for multi-regional trials where regulatory requirements differ by jurisdiction.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether this SOP governs processes subject to HIPAA Privacy and Security Rules for U.S.-based studies involving protected health information (PHI). Relevant for studies conducted at U.S. sites.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this SOP has been reviewed and confirmed as current and compliant in preparation for a regulatory inspection (FDA, EMA, MHRA, PMDA). Set to True when QA has verified the SOP is up-to-date and all training is complete.',
    `language_code` STRING COMMENT 'ISO 639-1 language code of the SOP document (e.g., en, fr, de, ja). Supports multi-language document management for global trials and ensures site staff receive SOPs in the appropriate language.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the SOP record was most recently updated in the quality management system or the lakehouse Silver Layer. Supports change detection, incremental ETL processing, and audit trail completeness.',
    `mastercontrol_doc_number` STRING COMMENT 'Native document identifier assigned by the MasterControl quality management system. Used for direct cross-reference and deep-linking back to the source system record for audit trail and change control purposes.',
    `owner_department` STRING COMMENT 'Name of the organizational department accountable for authoring, maintaining, and periodically reviewing this SOP (e.g., Quality Assurance, Data Management, Regulatory Affairs). Determines the primary escalation path for SOP-related queries.',
    `owner_role` STRING COMMENT 'Job role or title of the individual responsible for the SOP within the owning department (e.g., QA Manager, Director of Data Management). Used for accountability tracking and escalation in audit findings.',
    `parent_sop_number` STRING COMMENT 'SOP number of the higher-level or governing SOP under which this SOP sits in the document hierarchy (e.g., a site-specific SOP may reference a global SOP as its parent). Supports hierarchical document structure navigation.',
    `process_area` STRING COMMENT 'Primary clinical trial business process area governed by this SOP (e.g., Study Protocol Design, Patient Recruitment, Adverse Event Reporting, Site Monitoring, Data Management, Regulatory Submission). Used for process-level compliance gap analysis.',
    `purpose_description` STRING COMMENT 'Brief statement of the business purpose and objective of the SOP, summarizing what process it governs and why it exists. Sourced from the SOP documents purpose/objective section.',
    `qms_workflow_stage` STRING COMMENT 'Current stage of the SOP within the MasterControl quality management system workflow. More granular than document_status; tracks the specific workflow step the document is in during its lifecycle (e.g., authoring, peer review, QA review, approval',
    `regulatory_basis` STRING COMMENT 'Primary regulatory practice standard(s) that this SOP is designed to satisfy: Good Clinical Practice (GCP), Good Laboratory Practice (GLP), Good Manufacturing Practice (GMP), or applicable combinations.. Valid values are `GCP|GLP|GMP|GCP_GLP|GCP_GMP|GLP_GMP`',
    `regulatory_references` STRING COMMENT 'Free-text or structured list of specific regulatory citations, guidelines, and standards that this SOP implements or references (e.g., ICH E6(R2) Section 5.18, FDA 21 CFR Part 312, EU CTR 536/2014 Article 47).',
    `related_sop_numbers` STRING COMMENT 'Comma-separated list of SOP numbers that are cross-referenced by this SOP (e.g., parent SOPs, companion procedures, referenced work instructions). Supports document dependency mapping and impact analysis during revisions.',
    `review_due_date` DATE COMMENT 'Scheduled date by which the SOP owner must initiate a periodic review to confirm continued applicability and accuracy. May precede the expiry date to allow time for revision and approval before expiry.',
    `revision_summary` STRING COMMENT 'Brief narrative describing the nature and rationale of changes made in this version relative to the superseded version (e.g., Updated to reflect ICH E6(R3) requirements; added remote monitoring guidance). Required for change control documentation.',
    `scope_description` STRING COMMENT 'Narrative description of the scope and applicability of the SOP, including which studies, sites, roles, or geographies it applies to. Sourced from the SOP documents scope section. Critical for determining applicability during inspections.',
    `sop_number` STRING COMMENT 'Externally-known, human-readable document control number assigned to the SOP within MasterControl (e.g., QA-GCP-001). Serves as the business identifier used in audit trails, regulatory submissions, and training records.. Valid values are `^[A-Z]{2,10}-[A-Z]{2,10}-[0-9]{3,6}$`',
    `sox_applicable` BOOLEAN COMMENT 'Indicates whether this SOP governs financial reporting or internal control processes subject to SOX compliance requirements (e.g., finance, procurement, project accounting SOPs). Relevant for publicly-listed sponsors and CROs.',
    `superseded_version_number` STRING COMMENT 'Version number of the immediately preceding SOP version that this current version replaces. Enables version lineage tracing and ensures retired versions are correctly linked in the document control audit trail.. Valid values are `^[0-9]+.[0-9]+$`',
    `title` STRING COMMENT 'Full descriptive title of the SOP as it appears on the document cover page and in the quality management system. Used for search, display, and regulatory filing purposes.',
    `training_completion_deadline_days` BIGINT COMMENT 'Number of calendar days from the SOP effective date within which all applicable staff must complete the required training. Used by MasterControl to auto-calculate individual training due dates and trigger overdue notifications.',
    `training_required` BOOLEAN COMMENT 'Indicates whether completion of a formal training event is mandatory for all applicable staff before they may operate under this SOP. When True, a training assignment must be created in MasterControl for each in-scope role upon SOP approval.',
    `version_number` STRING COMMENT 'Current version identifier of the SOP document (e.g., 1.0, 2.1, 3.0). Incremented upon each approved revision cycle. Used to ensure staff are trained on and referencing the correct version.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_compliance_sop PRIMARY KEY(`compliance_sop_id`)
) COMMENT 'Master record for Standard Operating Procedures (SOPs) managed within the quality management system. Captures SOP number, title, version, effective date, expiry date, SOP owner (department/role), applicable process area, regulatory basis (GCP, GLP, GMP)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` (
    `sop_training_record_id` BIGINT COMMENT 'Unique surrogate identifier for each SOP training record in the MasterControl training management module. Primary key for this transactional entity. Entity role: TRANSACTION_HEADER — captures a discrete training completion event with its own lifecycle.',
    `compliance_capa_id` BIGINT COMMENT 'Identifier of the CAPA record that triggered this retraining event, if applicable. Links training records to quality events such as protocol deviations, audit findings, or inspection observations that required corrective retraining.',
    `compliance_sop_id` BIGINT COMMENT 'Identifier of the SOP document that this training record is associated with. References the controlled SOP document in MasterControl document control module.',
    `electronic_signature_id` BIGINT COMMENT 'The unique identifier of the 21 CFR Part 11-compliant electronic signature applied by the staff member to confirm training completion. Mandatory for GCP-regulated training records. Links to the electronic signature audit trail in MasterControl.',
    `investigational_site_id` BIGINT COMMENT 'Identifier of the investigational site associated with this training record, if the training is site-specific. Null for sponsor/CRO staff training not tied to a specific site.',
    `sop_training_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.sop_training_requirement. Business justification: A training record documents the completion of a training requirement. Linking sop_training_record.sop_training_requirement_id →',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study for which this training is required, if the SOP training is study-specific or protocol-specific. Null for organization-wide SOPs applicable to all studies. Enables study-level training compliance reporting.',
    `trainee_employee_id` BIGINT COMMENT 'Identifier of the staff member (employee, contractor, or investigator) who completed or is required to complete the SOP training. Links to the workforce party record. Satisfies TRANSACTION_HEADER PARTY_REFERENCE category.',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: SOP training records must be associated with the training curriculum they fulfill to support curriculum completion tracking, GCP compliance reporting, and automated curriculum',
    `training_plan_id` BIGINT COMMENT 'Identifier of the training plan or curriculum that mandated this SOP training record. Links to the role-based or study-specific training plan in MasterControl that defines required SOPs for a given staff role or study assignment.',
    `assessment_passed` BOOLEAN COMMENT 'Indicates whether the staff member achieved a passing score on the training assessment. True if assessment_score >= passing_score_threshold; False if below threshold; Null if no assessment was required for this training method.',
    `assessment_score` DECIMAL(5,2) COMMENT 'Numeric score achieved by the staff member on the post-training assessment or quiz, expressed as a percentage (0.00–100.00). Applicable only for training methods that include a formal assessment (e-learning, classroom).',
    `attempt_number` BIGINT COMMENT 'Sequential attempt number for this training record, indicating how many times the staff member has attempted the training or assessment for this SOP version. First attempt = 1.',
    `comments` STRING COMMENT 'Free-text field for additional notes or observations related to this training record, such as trainer observations, special circumstances, or quality notes. Supports audit trail completeness and GCP inspection documentation.',
    `completion_date` DATE COMMENT 'The date on which the staff member completed the SOP training. For read-and-understand, this is the date the staff member signed off. For e-learning, this is the date the module was completed.',
    `completion_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the training was electronically recorded as completed in MasterControl. Supports 21 CFR Part 11 electronic records requirements and ALCOA+ contemporaneous documentation standards.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this training record was first created in the system. Satisfies TRANSACTION_HEADER RECORD_AUDIT_CREATED category. Required for 21 CFR Part 11 audit trail and ALCOA+ contemporaneous documentation.',
    `department` STRING COMMENT 'Organizational department or functional unit of the staff member at the time of training (e.g., Clinical Operations, Data Management, Biostatistics, Quality Assurance). Used for departmental training compliance reporting and gap analysis.',
    `due_date` DATE COMMENT 'The date by which the staff member is required to complete the SOP training. Calculated based on SOP effective date plus the organizations training grace period policy. Used to determine overdue status and drive compliance escalations.',
    `expiry_date` DATE COMMENT 'The date on which this training record expires and retraining or refresher training is required. Applicable for SOPs with periodic recertification requirements (e.g., annual GCP training). Null for SOPs with no expiry requirement.',
    `is_current_version_training` BOOLEAN COMMENT 'Indicates whether this training record corresponds to the currently effective version of the SOP. True if the sop_version matches the current approved version; False if the staff member was trained on a superseded version.',
    `passing_score_threshold` DECIMAL(5,2) COMMENT 'The minimum assessment score percentage required to achieve a passing result for this SOP training (e.g., 80.00%). Enables determination of pass/fail outcome and supports quality metrics on training effectiveness.',
    `signature_timestamp` TIMESTAMP COMMENT 'The precise date and time at which the staff member applied their electronic signature to confirm training completion. Required for 21 CFR Part 11 compliance and ALCOA+ contemporaneous documentation.',
    `sop_category` STRING COMMENT 'Functional category of the SOP being trained on (e.g., Clinical Operations, Data Management, Safety Reporting, Regulatory Affairs, Quality Assurance, Laboratory). Enables category-level compliance reporting and training gap analysis by functional area.',
    `sop_version` STRING COMMENT 'Version number of the SOP document on which the staff member was trained (e.g., 2.0, 3.1). Critical for GCP compliance verification — training must be on the current approved version. Enables identification of staff trained on superseded versions.. Valid values are `^[0-9]+.[0-9]+$`',
    `source_record_number` STRING COMMENT 'The native record identifier from the source operational system (e.g., MasterControl internal training record ID). Enables traceability back to the originating system for audit and reconciliation purposes per ALCOA+ principles.',
    `staff_full_name` STRING COMMENT 'Full name of the staff member who completed or is required to complete the training. Denormalized for audit trail completeness and GCP inspection readiness per ALCOA+ principles. Supports historical record integrity.',
    `staff_role` STRING COMMENT 'The job role or function of the staff member at the time of training (e.g., Clinical Research Associate, Principal Investigator, Data Manager, Biostatistician). Captured at training time for historical accuracy.',
    `trainer_name` STRING COMMENT 'Full name of the qualified trainer who delivered the training. Denormalized for audit trail completeness and GCP inspection readiness. Supports historical record integrity even if trainer record is modified.',
    `training_duration_minutes` BIGINT COMMENT 'The actual time in minutes spent by the staff member completing the training. Captured automatically by e-learning systems or recorded manually for classroom and OJT sessions. Used for training effort reporting and curriculum planning.',
    `training_method` STRING COMMENT 'The instructional delivery method used for this SOP training event. Read-and-understand (R&U) is the most common GCP method; classroom and e-learning are used for complex SOPs; on-the-job training (OJT) is used for procedural skills.. Valid values are `read_and_understand|classroom|e_learning|on_the_job_training|blended`',
    `training_record_number` STRING COMMENT 'Externally-known, human-readable unique identifier for this training record as assigned by MasterControl (e.g., TR-2024-000123). Used for audit trail references, GCP inspection documentation, and regulatory correspondence.. Valid values are `^TR-[0-9]{4}-[0-9]{6}$`',
    `training_status` STRING COMMENT 'Current lifecycle status of this training record indicating whether the staff member has completed, is overdue, has been granted a waiver, is in progress, or has not yet started the required SOP training.. Valid values are `completed|overdue|waived|in_progress|not_started`',
    `training_type` STRING COMMENT 'Classification of the training event indicating whether it is initial training (first time on this SOP), retraining (following a failed assessment or deviation), refresher (periodic recertification), or change-control training (triggered by a new SOP. Valid values are `initial|retraining|refresher|change_control`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this training record was last modified. Satisfies TRANSACTION_HEADER RECORD_AUDIT_UPDATED category. Required for 21 CFR Part 11 audit trail integrity and change tracking.',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the Quality Assurance (QA) manager or authorized approver who granted the training waiver. Required for audit trail and GCP inspection documentation when training_status is waived.',
    `waiver_date` DATE COMMENT 'The date on which the training waiver was formally approved and recorded. Applicable only when training_status is waived. Supports audit trail completeness per ALCOA+ principles.',
    `waiver_reason` STRING COMMENT 'Documented justification for granting a training waiver when training_status is waived. Examples include equivalent prior training, role change making SOP non-applicable, or temporary exemption with documented rationale.',
    CONSTRAINT pk_sop_training_record PRIMARY KEY(`sop_training_record_id`)
) COMMENT 'Transactional record capturing individual staff training completions against required SOPs. Captures staff member identifier, SOP version trained on, training method (read-and-understand, classroom, e-learning, OJT), training completion date, assessment';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` (
    `sop_training_requirement_id` BIGINT COMMENT 'Unique system-generated identifier for the SOP training requirement record. Primary key for this entity.',
    `compliance_sop_id` BIGINT COMMENT 'Reference to the SOP document that this training requirement is based upon. Links to the controlled SOP document record in the document management system.',
    `job_profile_id` BIGINT COMMENT 'Reference to the job role or function for which this SOP training is required. Drives automated training assignment in MasterControl based on role assignment.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Training requirements in GCP-regulated environments are driven by specific regulatory obligations (e.g., ICH E6 GCP requires training on GCP principles, FDA 21 CFR Part 11 requires',
    `org_unit_id` BIGINT COMMENT 'Reference to the organizational department for which this SOP training requirement applies. Null if the requirement is role-based rather than department-based.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this training requirement applies. Null if the requirement is global (not study-specific). Enables study-specific training obligation tracking.',
    `training_plan_id` BIGINT COMMENT 'Foreign key linking to compliance.training_plan. Business justification: A training requirement defines WHAT training is needed; a training plan defines HOW it is delivered.',
    `applicability_scope` STRING COMMENT 'Defines the organizational scope at which this training requirement applies. global = all staff; study_specific = only staff assigned to a particular study; department_specific = only a department; role_specific = only a job role; site_specific. Valid values are `global|study_specific|department_specific|role_specific|site_specific`',
    `approval_date` DATE COMMENT 'Date on which this training requirement was formally approved by the QA or training manager. Part of the electronic approval audit trail required under 21 CFR Part 11.',
    `approved_by` STRING COMMENT 'Name or user identifier of the QA or training manager who approved this training requirement definition in MasterControl. Required for 21 CFR Part 11 electronic signature compliance.',
    `capa_required_on_overdue` BOOLEAN COMMENT 'Indicates whether a formal CAPA must be initiated when this training requirement becomes overdue beyond the grace period. Distinct from escalation_required — CAPA is a formal quality system record with root cause analysis obligations.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this SOP training requirement record was first created in the system. Part of the ALCOA+ audit trail required for GCP and 21 CFR Part 11 compliance.',
    `curriculum_code` STRING COMMENT 'Code identifying the training curriculum or learning path in MasterControl to which this SOP training requirement belongs. Enables grouping of related SOP requirements into structured training programs (e.g., GCP Onboarding Curriculum, Annual Refresher',
    `effective_date` DATE COMMENT 'Date from which this training requirement becomes enforceable. Personnel assigned to the applicable role, department, or study on or after this date are subject to this requirement.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether a compliance escalation notification must be triggered if training is not completed within the grace period. When True, MasterControl generates a CAPA or non-conformance record and notifies the QA manager.',
    `expiry_date` DATE COMMENT 'Date after which this training requirement is no longer enforceable, typically when the SOP is retired or superseded. Null for open-ended requirements. Used to automatically deactivate requirements in MasterControl.',
    `gcp_applicable` BOOLEAN COMMENT 'Indicates whether this training requirement is classified as a GCP training obligation under ICH E6(R2). GCP-applicable requirements are subject to heightened audit scrutiny and must be documented in the Trial Master File (TMF).',
    `geographic_applicability` STRING COMMENT 'ISO 3166-1 alpha-3 country code(s) or region identifier indicating the geographic jurisdiction(s) where this training requirement applies. Supports multi-regional regulatory compliance (e.g., FDA requirements for USA, EMA requirements for EU member',
    `grace_period_days` BIGINT COMMENT 'Number of calendar days after the training due date during which the training may still be completed without triggering a compliance violation or non-conformance. Typically 0–30 days depending on SOP criticality and sponsor requirements.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this SOP training is mandatory (True) or optional/recommended (False) for the assigned role, department, or study. Mandatory training must be completed before study participation or role activation per GCP requirements.',
    `is_study_participation_prerequisite` BOOLEAN COMMENT 'Indicates whether completion of this SOP training is a prerequisite for a staff member to be activated on a clinical study. When True, the system blocks study assignment until training is recorded as complete.',
    `job_function` STRING COMMENT 'The specific job function or functional area for which this training requirement applies (e.g., Clinical Research Associate, Data Manager, Biostatistician, Principal Investigator). Complements role_id with a human-readable functional label for reporting.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this SOP training requirement record was most recently updated. Part of the ALCOA+ audit trail. Any modification must be accompanied by a reason for change per 21 CFR Part 11.',
    `max_attempts_allowed` BIGINT COMMENT 'Maximum number of times a trainee may attempt the training assessment before escalation or remediation is required. Null if unlimited attempts are permitted.',
    `notes` STRING COMMENT 'Free-text field for additional context, special instructions, or clarifications related to this SOP training requirement. May include sponsor-specific instructions, exceptions, or implementation guidance for training coordinators.',
    `passing_score_pct` DECIMAL(5,2) COMMENT 'Minimum percentage score required to pass the training assessment associated with this SOP requirement. Applicable when training_delivery_method includes an assessment component. Null if no scored assessment is required.',
    `phase_applicability` STRING COMMENT 'Specifies the clinical trial phase(s) for which this SOP training requirement is applicable. Enables phase-specific training assignment for staff transitioning between study phases.. Valid values are `phase_1|phase_2|phase_3|phase_4|all_phases`',
    `reason_for_change` STRING COMMENT 'Free-text justification for the most recent modification to this training requirement record. Mandatory for any update per 21 CFR Part 11 audit trail requirements and ALCOA+ data integrity principles.',
    `recurrence_frequency_days` BIGINT COMMENT 'Number of days between required retraining cycles for recurring training types (e.g., 365 for annual). Null for one-time training types such as initial. Used by MasterControl to auto-generate the next training due date.',
    `regulatory_basis` STRING COMMENT 'The specific regulatory citation, guideline, or standard that mandates or supports this training requirement (e.g., ICH E6(R2) Section 2.8, 21 CFR Part 312.53, EU CTR 536/2014 Article 49).',
    `reminder_days_before_due` BIGINT COMMENT 'Number of days before the training due date that an automated reminder notification should be sent to the trainee and their manager. Configurable per SOP criticality to drive proactive compliance.',
    `requirement_code` STRING COMMENT 'Unique business identifier for the SOP training requirement record, used for cross-system referencing and audit trail. Follows the format TRQ-[alphanumeric]. Serves as the externally-known identifier in MasterControl.. Valid values are `^TRQ-[A-Z0-9]{4,12}$`',
    `requirement_status` STRING COMMENT 'Current lifecycle state of the SOP training requirement record. active = currently enforced; inactive = no longer enforced; superseded = replaced by a newer version requirement; draft = under review; pending_approval = awaiting QA sign-off.. Valid values are `active|inactive|superseded|draft|pending_approval`',
    `sop_version` STRING COMMENT 'Version of the SOP document for which this training requirement was defined. Critical for tracking whether personnel have been trained on the current version versus a superseded version.. Valid values are `^[0-9]+.[0-9]+$`',
    `sponsor_required` BOOLEAN COMMENT 'Indicates whether this training requirement was mandated by the study sponsor as a condition of the clinical trial agreement. Sponsor-required training may have additional documentation and audit trail obligations.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication for which this training requirement is relevant (e.g., Oncology, Cardiology, Neurology). Used to filter and assign study-specific SOP training requirements to staff working in a given therapeutic area.',
    `tmf_documentation_required` BOOLEAN COMMENT 'Indicates whether evidence of training completion for this requirement must be filed in the Trial Master File (TMF) or electronic TMF (eTMF) in Veeva Vault. Required for GCP-essential training per ICH E6(R2) Section 8.',
    `training_category` STRING COMMENT 'Functional classification of the SOP training requirement. Used for compliance reporting, training curriculum grouping, and regulatory inspection readiness.',
    `training_delivery_method` STRING COMMENT 'Specifies the required method by which the SOP training must be completed. read_and_understand = staff reads and signs off; instructor_led = classroom or virtual session; elearning = online module; on_the_job = supervised practical. Valid values are `read_and_understand|instructor_led|elearning|on_the_job|assessment_only`',
    `training_material_reference` STRING COMMENT 'Document identifier or URL reference to the training material, curriculum, or assessment associated with this SOP requirement in MasterControl or the eTMF. Enables direct navigation to training content from compliance dashboards.',
    `training_type` STRING COMMENT 'Categorizes the trigger or frequency basis for this training requirement. initial = first-time training upon hire or role assignment; annual = recurring yearly retraining; on_change = triggered by SOP version update; role_assignment = triggered by. Valid values are `initial|annual|on_change|role_assignment|study_assignment`',
    `created_by` STRING COMMENT 'User identifier of the person who created this training requirement record in MasterControl. Part of the ALCOA+ audit trail (Attributable, Legible, Contemporaneous, Original, Accurate) required for GCP compliance.',
    CONSTRAINT pk_sop_training_requirement PRIMARY KEY(`sop_training_requirement_id`)
) COMMENT 'Master record defining which SOPs are required training for which roles, departments, or study assignments. Captures role or job function, SOP identifier, training frequency (initial, annual, on-change), grace period days, and whether training is';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`quality_event` (
    `quality_event_id` BIGINT COMMENT 'Unique system-generated identifier for the quality event record within the MasterControl quality management module. Serves as the primary key for all downstream references to this quality event.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the formal CAPA record initiated in MasterControl as a result of this quality event. Populated only when capa_required is True and the CAPA has been formally opened. Null until CAPA is initiated.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: quality_event.affected_sop_number is a free-text string identifying the SOP implicated in the quality event.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Quality events in clinical trials frequently arise from consent process failures (wrong ICF version used, consent obtained after procedures, missing signatures).',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Quality events arising from database lock failures (outstanding queries, failed QC checks, unauthorized lock) must reference the specific DBL event.',
    `identified_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Quality event management requires tracking the specific employee who identified the event for GCP accountability, trend analysis by identifier role, and inspection readiness.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Quality events are frequently triggered by laboratory data issues — systematic result errors, instrument failures, reagent lot problems. quality_event has affected_data_domain.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Manufacturing batch failures, OOS results, and QP release holds are quality events under GMP.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Quality events with sponsor_notified=true and sponsor_notification_date require a direct FK to the sponsor org for notification routing and sponsor-level quality reporting.',
    `parent_event_quality_event_id` BIGINT COMMENT 'Reference to a prior quality event record that this event is a recurrence of, or a related parent event in a cluster of related quality issues. Populated when recurrence_flag is True or when events are grouped for systemic analysis.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: quality_event.deviation_reference_number is a free-text string referencing a related protocol deviation.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: Specimen collection quality failures (hemolysis, lipemia, inadequate volume) are formal quality events requiring CAPA.',
    `specimen_shipment_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_shipment. Business justification: Temperature excursions during specimen shipment are a named quality event type in clinical trials. specimen_shipment has temperature_excursion_flag.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Quality events are tracked per engagement for account health scoring and governance reporting.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study affected by this quality event. Links the event to the specific protocol under which the quality issue was identified.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the quality event was identified or originated. Null if the event is study-wide or sponsor/CRO-level rather than site-specific.',
    `affected_data_domain` STRING COMMENT 'The CDISC SDTM or clinical data domain affected by the quality event (e.g., AE, CM, LB, VS, DM, DS, EX). Used for data management impact assessment, targeted re-monitoring, and SDTM submission quality review. Null if the event is not data-domain-specific.',
    `affected_process` STRING COMMENT 'The specific clinical trial business process or functional area impacted by the quality event (e.g., informed consent management, adverse event reporting, randomization, data entry, site monitoring, regulatory submission).',
    `audit_readiness_flag` BOOLEAN COMMENT 'Indicates whether this quality event record has been reviewed and confirmed as complete and audit-ready for regulatory inspection or sponsor audit purposes. True: record is audit-ready.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a formal Corrective and Preventive Action (CAPA) has been determined to be required for this quality event. True: CAPA must be initiated in MasterControl. False: event can be resolved without formal CAPA.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the quality event record was first created in MasterControl. Supports 21 CFR Part 11 audit trail requirements and ALCOA+ attributability. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `data_integrity_impact` BOOLEAN COMMENT 'Indicates whether the quality event has compromised or potentially compromised the integrity of clinical trial data in the EDC or source documents. True: data integrity affected. False: no data integrity impact.',
    `error_count` BIGINT COMMENT 'Number of errors, discrepancies, or non-conformances identified within the QC sample reviewed. Used in conjunction with sample_size to compute error rate for quality trending and threshold monitoring.',
    `error_rate` DECIMAL(5,4) COMMENT 'Proportion of errors identified relative to the total sample size (error_count / sample_size). Expressed as a decimal (e.g., 0.0250 = 2.50%). Used for quality threshold monitoring, KPI reporting, and CAPA escalation triggers.',
    `event_description` STRING COMMENT 'Detailed narrative description of the quality event, including what was observed, where it occurred, and the potential impact on subject safety, data integrity, or regulatory compliance.',
    `event_reference_number` STRING COMMENT 'Human-readable, externally-visible reference number assigned to the quality event upon creation in MasterControl. Used in audit trails, regulatory correspondence, and CAPA linkage. Format: QE-YYYY-NNNNNN.. Valid values are `^QE-[0-9]{4}-[0-9]{6}$`',
    `event_status` STRING COMMENT 'Current lifecycle status of the quality event within the MasterControl workflow. Open: newly identified, awaiting triage. Under Review: QA/QC team actively investigating. Pending CAPA: CAPA determination made, awaiting CAPA initiation.. Valid values are `open|under_review|pending_capa|closed|cancelled`',
    `event_type` STRING COMMENT 'Classification of the quality event by its nature. Drives routing, escalation rules, and CAPA determination logic. Values: data_quality_issue (EDC/eCRF data errors), process_non_compliance (GCP/SOP deviation), system_failure (EDC, CTMS, or IRT system. Valid values are `data_quality_issue|process_non_compliance|system_failure|vendor_quality_issue|qc_review_finding`',
    `identification_source` STRING COMMENT 'The activity or mechanism through which the quality event was detected. Drives root cause analysis and process improvement analytics. [ENUM-REF-CANDIDATE',
    `identified_date` DATE COMMENT 'Calendar date on which the quality event was first identified or detected. This is the principal real-world event date per ALCOA+ contemporaneous documentation requirements. Distinct from the record creation timestamp.',
    `immediate_action_taken` STRING COMMENT 'Description of any immediate containment or corrective actions taken at the time of quality event identification, prior to formal CAPA initiation. Examples: data query raised in EDC, site notified, process halted.',
    `irb_iec_reportable` BOOLEAN COMMENT 'Indicates whether this quality event must be reported to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) overseeing the study. True: IRB/IEC notification required. False: not required.',
    `protocol_deviation_category` STRING COMMENT 'Classification of the quality event as a protocol deviation per ICH E6(R2) and sponsor requirements. Major: deviation that may affect subject safety or data integrity. Minor: deviation with minimal impact.. Valid values are `major|minor|not_applicable`',
    `qc_outcome` STRING COMMENT 'Overall outcome of the QC review activity that generated this quality event. Pass: quality threshold met, no significant issues. Fail: quality threshold exceeded, formal action required.. Valid values are `pass|fail|conditional_pass`',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this quality event represents a recurrence of a previously identified and closed quality event of the same type at the same site or study. True: recurrence identified. False: first occurrence.',
    `regulatory_authority_notified` STRING COMMENT 'Name of the regulatory authority (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada) notified of this quality event, if applicable. Null if regulatory_reportability is not_reportable. Supports regulatory submission tracking and inspection readiness.',
    `regulatory_reportability` STRING COMMENT 'Assessment of whether this quality event requires reporting to a regulatory authority (FDA, EMA, MHRA, etc.) or to the sponsor. Reportable: must be submitted to regulatory body. Not Reportable: no regulatory notification required.. Valid values are `reportable|not_reportable|under_assessment`',
    `resolution_date` DATE COMMENT 'Date on which the quality event was formally resolved and closed in MasterControl. Populated when event_status transitions to closed. Used to calculate time-to-resolution KPIs and assess compliance with quality SLA targets.',
    `resolution_description` STRING COMMENT 'Narrative description of how the quality event was resolved, including actions taken, verification of effectiveness, and confirmation that the issue has been addressed.',
    `review_date` DATE COMMENT 'Date on which the QA reviewer formally assessed and triaged the quality event in MasterControl. Used to measure triage cycle time and compliance with internal quality SLA targets for event review.',
    `reviewed_by` STRING COMMENT 'Name or user identifier of the Quality Assurance (QA) professional who reviewed and assessed the quality event in MasterControl. Supports 21 CFR Part 11 electronic signature audit trail and GCP oversight accountability.',
    `root_cause_category` STRING COMMENT 'High-level categorization of the root cause identified during quality event investigation. Used for systemic quality trending, SOP improvement prioritization, and CAPA effectiveness analysis.',
    `root_cause_description` STRING COMMENT 'Detailed narrative of the root cause identified through investigation of the quality event. Captured by the QA investigator following root cause analysis. Supports CAPA development and regulatory inspection readiness.',
    `sample_size` BIGINT COMMENT 'Total number of records, data points, or items reviewed during the QC activity that identified this quality event. Used to calculate error rate and assess the statistical significance of the finding. Applicable when the event originates from a QC review.',
    `severity` STRING COMMENT 'Risk-based severity classification of the quality event per GCP quality standards. Critical: may impact subject safety or data integrity requiring immediate action. Major: significant GCP deviation with potential regulatory impact.. Valid values are `critical|major|minor|observation`',
    `sponsor_notification_date` DATE COMMENT 'Date on which the study sponsor was formally notified of this quality event. Populated when sponsor_notified is True. Used to verify compliance with contractual and regulatory notification timelines.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this quality event. True: sponsor notification sent. False: sponsor not yet notified. Required for CRO-sponsor quality agreement compliance and sponsor oversight obligations under ICH',
    `subject_safety_impact` BOOLEAN COMMENT 'Indicates whether the quality event has a direct or potential impact on the safety of enrolled study subjects. True: subject safety may be or has been affected. False: no subject safety impact identified.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to the quality event record in MasterControl. Required for audit trail completeness under 21 CFR Part 11 and ICH E6(R2). Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    CONSTRAINT pk_quality_event PRIMARY KEY(`quality_event_id`)
) COMMENT 'Transactional record capturing quality events identified through QC reviews, self-inspections, routine quality monitoring, or proactive quality surveillance activities.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` (
    `risk_assessment_id` BIGINT COMMENT 'Unique system-generated identifier for each quality risk assessment record within the compliance domain. Serves as the primary key for the risk_assessment data product.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Risk assessments can be scoped to audits (pre-audit risk assessment, post-audit risk evaluation).',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_capa. Business justification: Risk assessments with capa_required_flag=true should link to the resulting CAPA. A risk assessment that identifies unacceptable risk triggers a CAPA for remediation.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Risk assessments are conducted per SOPs and can assess SOP compliance or be governed by a specific SOP.',
    `depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: Depot qualification risk assessments evaluate cold chain capability, geographic coverage, and GMP compliance.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: IMP-specific risk assessments cover stability risks, cold chain requirements, controlled substance handling, and biological product safety.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Risk-based monitoring requires formal risk assessments of laboratory facilities as part of vendor qualification and ongoing oversight.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Risk assessments with sponsor_notified_flag=true require a direct FK to the sponsor org for notification workflows and sponsor-level risk reporting.',
    `primary_risk_owner_employee_id` BIGINT COMMENT 'FK to workforce.employee',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key to the regulatory inspection associated with this risk assessment.',
    `risk_id` BIGINT COMMENT 'Foreign key linking to program.program_risk. Business justification: GCP compliance risk assessments are often triggered by or linked to program-level strategic risks.',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: ICH E6 R2 risk-based monitoring requires that identified safety signals directly inform quality risk assessments. Risk management plans are updated when signals are detected.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Risk assessments are scoped to sponsor engagements for account-level risk reporting and governance reviews.',
    `approval_date` DATE COMMENT 'Date on which the risk assessment was formally approved by the authorized QA signatory. Required for regulatory audit trail and 21 CFR Part 11 electronic records compliance.',
    `assessment_date` DATE COMMENT 'The date on which the risk assessment was formally conducted and documented. Represents the principal business event date for this record. Used for trend analysis and review frequency tracking.',
    `assessment_status` STRING COMMENT 'Current lifecycle state of the risk assessment record in MasterControl: draft (being authored), in_review (under QA/sponsor review), approved (formally accepted), active (monitoring in progress), closed (risk resolved or accepted), cancelled (assessment. Valid values are `draft|in_review|approved|active|closed|cancelled`',
    `capa_required_flag` BOOLEAN COMMENT 'Indicates whether a formal Corrective and Preventive Action (CAPA) record must be initiated as a result of this risk assessment. Typically set to True when residual risk rating is critical or high, or when identified gaps meet CAPA threshold criteria.',
    `control_measures_description` STRING COMMENT 'Narrative description of the existing or planned quality control and risk mitigation measures applied to reduce the identified risk (e.g., enhanced SDV, targeted monitoring, additional training, SOP updates, EDC edit checks). Sourced from MasterControl.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk assessment record was first created in the source system (MasterControl). Supports audit trail requirements under 21 CFR Part 11 and ICH E6(R2) for electronic records.',
    `data_integrity_impact_flag` BOOLEAN COMMENT 'Indicates whether the identified risk has a potential or actual impact on clinical data integrity (ALCOA+ principles: Attributable, Legible, Contemporaneous, Original, Accurate). Triggers enhanced data review and potential database lock delay.',
    `gcp_impact_flag` BOOLEAN COMMENT 'Indicates whether the identified risk has a direct impact on Good Clinical Practice (GCP) compliance. Drives escalation to QA leadership and potential regulatory notification obligations.',
    `identified_gaps` STRING COMMENT 'Narrative description of quality gaps, process deficiencies, or compliance vulnerabilities identified during the risk assessment (e.g., missing SDV documentation, incomplete ICF versions, delayed SAE reporting).',
    `inherent_detectability_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the ability to detect the risk before it causes harm, prior to control measures. Used in FMEA-style risk scoring (Risk Priority Number = Likelihood × Impact × Detectability).',
    `inherent_impact_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the severity of impact on patient safety, data integrity, or regulatory compliance if the risk materializes before controls are applied. Component of the inherent risk score calculation.',
    `inherent_likelihood_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the probability of the risk occurring before any control measures are applied. Component of the inherent risk score calculation per ICH Q9 risk estimation methodology.',
    `inherent_risk_rating` STRING COMMENT 'Qualitative risk rating derived from the inherent risk score before controls: critical, high, medium, or low. Used for risk prioritization, escalation thresholds, and sponsor/QA reporting dashboards.. Valid values are `critical|high|medium|low`',
    `inherent_risk_score` DECIMAL(5,2) COMMENT 'Composite numeric risk score calculated before control measures are applied, typically derived from likelihood, impact, and detectability scores (e.g., product or weighted sum). Establishes the baseline risk level for prioritization.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this risk assessment was conducted specifically in preparation for a regulatory inspection (FDA, EMA, MHRA, PMDA, or sponsor audit). Enables filtering of inspection-readiness assessments for pre-inspection reporting.',
    `mastercontrol_record_number` STRING COMMENT 'The native record identifier assigned by MasterControl (the system of record for this data product) to the risk assessment document. Enables direct traceability back to the source system for audit and reconciliation purposes.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this risk assessment, based on the defined review frequency. Supports proactive risk monitoring and inspection readiness. Calculated from assessment_date and review_frequency_days.',
    `reference_number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to the risk assessment record in MasterControl (e.g., RA-2024-00123). Used for cross-system traceability, audit trails, and regulatory inspection readiness.. Valid values are `^RA-[A-Z0-9]{4,20}$`',
    `regulatory_authority` STRING COMMENT 'The primary regulatory authority whose standards and guidelines govern this risk assessment (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Determines applicable GCP framework and reporting obligations.',
    `remediation_plan` STRING COMMENT 'Documented plan for addressing identified gaps and reducing residual risk, including specific actions, responsible parties, and target timelines. Distinct from CAPA (which is a formal corrective/preventive action record); this is the risk-level',
    `remediation_status` STRING COMMENT 'Current status of remediation activities for identified gaps: not_started, in_progress, completed, or overdue. Supports inspection readiness dashboards and QA oversight reporting.. Valid values are `not_started|in_progress|completed|overdue`',
    `remediation_target_date` DATE COMMENT 'Target completion date for the remediation actions identified in the risk assessment. Used for tracking remediation progress and escalation when overdue.',
    `residual_detectability_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the ability to detect the risk after control measures are in place. Component of the residual risk score calculation.',
    `residual_impact_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the severity of impact after control measures have been applied. Used to calculate the residual risk score.',
    `residual_likelihood_score` BIGINT COMMENT 'Numeric score (typically 1–5) representing the probability of the risk occurring after control measures have been applied. Used to calculate the residual risk score.',
    `residual_risk_rating` STRING COMMENT 'Qualitative risk rating after control measures are applied: critical, high, medium, or low. Drives risk acceptance decisions, escalation to DSMB/DMC, and CAPA initiation. A residual rating of critical or high typically triggers mandatory CAPA.. Valid values are `critical|high|medium|low`',
    `residual_risk_score` DECIMAL(5,2) COMMENT 'Composite numeric risk score calculated after control measures are applied. Represents the remaining risk exposure. Compared against risk acceptance thresholds to determine if further mitigation is required.',
    `review_frequency_days` BIGINT COMMENT 'Defined interval in calendar days between periodic re-assessments of this risk (e.g., 30, 60, 90, 180 days). Drives scheduling of next_review_date and ensures ongoing risk monitoring per ICH Q9 principles.',
    `risk_acceptance_decision` STRING COMMENT 'Formal decision on whether the residual risk level is acceptable: accepted (risk within tolerance), not_accepted (requires further mitigation or CAPA), or conditionally_accepted (accepted with defined monitoring conditions).. Valid values are `accepted|not_accepted|conditionally_accepted`',
    `risk_category` STRING COMMENT 'High-level classification of the risk domain being assessed: data_integrity (ALCOA+ violations, EDC issues), patient_safety (adverse event under-reporting, protocol deviations), regulatory_compliance (GCP, ICH, FDA/EMA non-compliance), or operational. Valid values are `data_integrity|patient_safety|regulatory_compliance|operational`',
    `risk_description` STRING COMMENT 'Detailed narrative describing the identified risk, including the potential failure mode, root cause hypothesis, and potential impact on study quality, patient safety, or regulatory compliance. Sourced from MasterControl risk assessment form.',
    `risk_owner_department` STRING COMMENT 'Organizational department of the risk owner (e.g., Quality Assurance, Data Management, Clinical Operations, Regulatory Affairs). Used for departmental risk reporting and workload analysis.',
    `risk_subcategory` STRING COMMENT 'More granular classification within the risk category (e.g., Source Data Verification, Informed Consent Process, SAE Reporting Timeliness, Protocol Deviation Management). Enables detailed risk trending and root cause analysis.',
    `scope` STRING COMMENT 'Defines the level at which the risk assessment was conducted: study-level (entire protocol), site-level (specific investigational site), process-level (e.g., data management, consent), system-level (e.g., EDC, CTMS), or inspection-readiness. Valid values are `study|site|process|system|inspection_readiness`',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this risk assessment and its findings, as required by the Clinical Trial Agreement and GCP obligations. Relevant for high/critical risk ratings.',
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the identified risk has a potential or actual impact on the safety of study subjects/patients. Triggers mandatory escalation to the Principal Investigator (PI), DSMB/DMC, and sponsor safety team.',
    `title` STRING COMMENT 'Descriptive title summarizing the subject and scope of the risk assessment (e.g., Site-Level GCP Compliance Risk Assessment – Site 1042 Q3 2024). Used for identification and reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this risk assessment record in the source system. Required for change tracking, audit trail compliance, and Silver layer incremental load processing.',
    CONSTRAINT pk_risk_assessment PRIMARY KEY(`risk_assessment_id`)
) COMMENT 'Master record for quality risk assessments conducted at study, site, process, system, or inspection-readiness level to support risk-based quality management (RBQM).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` (
    `regulatory_commitment_id` BIGINT COMMENT 'Unique surrogate identifier for each regulatory commitment record in the system. Primary key for the regulatory_commitment data product.',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_capa. Business justification: Regulatory commitments made to authorities (FDA, EMA) often require formal CAPA implementation.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: regulatory_commitment.sop_reference is a free-text string identifying the SOP associated with the commitment.',
    `dsmb_review_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_review. Business justification: DSMB reviews with stopping rule triggers or safety concerns requiring regulatory notification generate regulatory commitments.',
    `inspection_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.inspection_finding. Business justification: Regulatory commitments frequently arise from specific inspection findings issued by regulatory authorities.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: Interim analysis results — especially stopping rule triggers or safety signals — generate regulatory commitments to health authorities.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: A regulatory commitment is a specific promise made to an authority, often in response to a defined regulatory obligation.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Regulatory commitments have sponsor_notified_flag and sponsor_notification_date but no FK to sponsor org.',
    `owner_employee_id` BIGINT COMMENT 'Identifier of the individual (employee or contractor) accountable for delivering the committed action. Links to the workforce record for the designated commitment owner.',
    `primary_commitment_regulatory_inspection_id` BIGINT COMMENT 'FK to canonical regulatory inspection',
    `primary_regulatory_approved_by_employee_id` BIGINT COMMENT 'Identifier of the Quality Assurance (QA) or Regulatory Affairs approver who reviewed and authorized this commitment record before submission to the regulatory authority.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Regulatory commitments arising from inspections/audits on CRO-sponsor work are tracked per engagement for governance reporting and sponsor relationship management.',
    `actual_completion_date` DATE COMMENT 'The date on which the committed action was actually completed and verified. Compared against committed_completion_date to determine on-time performance and overdue status.',
    `authority_acknowledgement_date` DATE COMMENT 'Date on which the regulatory authority formally acknowledged or accepted the commitment response or closure evidence. Marks the external closure of the commitment from the agency perspective.',
    `authority_closure_status` STRING COMMENT 'Status of the regulatory authoritys review of the commitment response. Indicates whether the agency has accepted the response, rejected it, requested additional information, or has it pending review.. Valid values are `accepted|rejected|pending_review|additional_info_requested`',
    `closure_justification` STRING COMMENT 'Narrative justification documenting the basis for closing this regulatory commitment, including evidence of completion and rationale for determining the committed action has been fully satisfied.',
    `commitment_description` STRING COMMENT 'Detailed narrative description of the regulatory commitment as formally communicated to the regulatory authority. Captures the full scope of what was committed, including context from the originating finding or query.',
    `commitment_reference_number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to the regulatory commitment (e.g., RC-2024-00123). Used in correspondence with regulatory authorities and in audit trails.. Valid values are `^RC-[0-9]{4}-[0-9]{5}$`',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the regulatory commitment. Tracks progression from open through in-progress, completed, overdue, cancelled, or pending verification by the regulatory authority.. Valid values are `open|in_progress|completed|overdue|cancelled|pending_verification`',
    `commitment_title` STRING COMMENT 'Short, human-readable title summarizing the regulatory commitment. Used in dashboards, reports, and regulatory correspondence for quick identification.',
    `commitment_type` STRING COMMENT 'Categorical classification of the nature of the commitment (e.g., procedural change, training, system enhancement, documentation update, process improvement, labeling revision). Supports portfolio-level analysis of commitment categories.',
    `committed_action` STRING COMMENT 'Specific action(s) formally committed to the regulatory authority in response to the originating finding or query. Describes what the organization has pledged to do, distinct from the broader commitment description.',
    `committed_completion_date` DATE COMMENT 'The date formally committed to the regulatory authority by which the action will be completed. This is the externally-binding deadline communicated in the regulatory response letter or inspection response.',
    `created_timestamp` TIMESTAMP COMMENT 'System-generated timestamp recording when this regulatory commitment record was first created in the data platform. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+.',
    `data_integrity_impact_flag` BOOLEAN COMMENT 'Indicates whether the originating finding involves a data integrity concern (e.g., ALCOA+ violations, EDC audit trail issues, source data discrepancies). Triggers additional data review and regulatory notification obligations.',
    `effectiveness_check_date` DATE COMMENT 'Date on which the effectiveness check was or is scheduled to be performed to verify that the committed action has resolved the underlying issue.',
    `effectiveness_check_required_flag` BOOLEAN COMMENT 'Indicates whether a post-completion effectiveness check is required to verify that the committed action has achieved its intended outcome and prevented recurrence.',
    `effectiveness_check_result` STRING COMMENT 'Outcome of the effectiveness check performed after completion of the committed action. Determines whether the commitment has been fully resolved or requires further action.. Valid values are `effective|partially_effective|not_effective|pending`',
    `finding_category` STRING COMMENT 'Classification of the severity of the originating inspection finding that triggered this commitment, aligned with GCP inspection grading standards (Critical, Major, Minor, Observation). Informs risk prioritization.. Valid values are `critical|major|minor|observation`',
    `gcp_requirement_reference` STRING COMMENT 'Reference to the specific GCP guideline, regulation, or standard that was cited in the originating regulatory finding (e.g., ICH E6(R2) Section 5.18, 21 CFR 312.62). Enables compliance gap analysis.',
    `initiation_date` DATE COMMENT 'The date on which this regulatory commitment record was formally initiated in the system, corresponding to the date the organization acknowledged the regulatory obligation.',
    `mastercontrol_record_number` STRING COMMENT 'Identifier of the corresponding record in MasterControl quality management system, where the commitment may be tracked as part of the document control, CAPA, or audit management workflow.',
    `originating_action_reference` STRING COMMENT 'The official reference number or identifier of the regulatory action that generated this commitment (e.g., FDA Warning Letter reference number, inspection report number, agency query tracking number).',
    `originating_action_type` STRING COMMENT 'Classification of the regulatory action that gave rise to this commitment. Distinguishes between inspection findings, FDA Warning Letters, Complete Response Letters (CRL), agency queries, Untitled Letters, and consent decrees.. Valid values are `inspection_finding|warning_letter|complete_response_letter|agency_query|untitled_letter|consent_decree`',
    `priority` STRING COMMENT 'Priority level assigned to the regulatory commitment based on patient safety impact, regulatory risk, and agency expectations. Drives escalation and resource allocation decisions.. Valid values are `critical|high|medium|low`',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this commitment relates to a recurring finding that has been previously identified and committed upon. Recurrent findings carry heightened regulatory risk and may trigger escalated agency scrutiny.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority to which this commitment was made (e.g., FDA, EMA, PMDA). Determines applicable regulatory framework, reporting timelines, and submission requirements.',
    `regulatory_response_due_date` DATE COMMENT 'The deadline by which the organization must submit a formal written response to the regulatory authority regarding this commitment. Distinct from the committed_completion_date, which is the action delivery date.',
    `regulatory_response_submitted_date` DATE COMMENT 'The date on which the formal written response was submitted to the regulatory authority. Used to confirm timely submission and calculate response latency.',
    `responsible_department` STRING COMMENT 'Organizational department or functional unit accountable for fulfilling the regulatory commitment (e.g., Quality Assurance, Clinical Operations, Regulatory Affairs). Supports departmental performance reporting.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the study sponsor was formally notified of this regulatory commitment. Supports sponsor oversight tracking and contractual compliance.',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of this regulatory commitment. Required for sponsor oversight obligations under GCP and sponsor-CRO agreements.',
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the originating finding or the commitment has a direct or potential impact on subject safety. Triggers expedited handling and escalation to the Data Safety Monitoring Board (DSMB) or sponsor safety team.',
    `updated_timestamp` TIMESTAMP COMMENT 'System-generated timestamp recording the most recent modification to this regulatory commitment record. Required for audit trail integrity and change tracking per 21 CFR Part 11.',
    `veeva_vault_document_number` STRING COMMENT 'Identifier of the associated document record in Veeva Vault (eTMF or regulatory submissions module), such as the inspection response letter, commitment evidence package, or regulatory correspondence. Supports document traceability.',
    CONSTRAINT pk_regulatory_commitment PRIMARY KEY(`regulatory_commitment_id`)
) COMMENT 'Master record tracking formal commitments made to regulatory authorities (FDA, EMA, PMDA) in response to inspection findings, warning letters, or agency queries.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`obligation` (
    `obligation_id` BIGINT COMMENT 'Primary key for obligation',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Regulatory obligations (e.g., pediatric investigation plans, post-marketing commitments) are scoped to development programs.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: obligation.sop_reference is a free-text string identifying the SOP that implements or addresses the compliance obligation.',
    `responsible_org_unit_id` BIGINT COMMENT 'Foreign key linking to workforce.org_unit. Business justification: Regulatory obligations must be assigned to specific org units for compliance dashboard reporting, escalation routing, and GCP inspection readiness.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Regulatory obligations are frequently TA-scoped (e.g., pediatric regulations for oncology, rare disease reporting requirements).',
    `applicable_study_phase` STRING COMMENT 'Clinical trial phase(s) to which this obligation applies (Phase I through Phase IV, All phases, or Not Applicable for non-phase-specific obligations such as GCP training requirements).. Valid values are `Phase_I|Phase_II|Phase_III|Phase_IV|All|Not_Applicable`',
    `applicable_study_type` STRING COMMENT 'Type of clinical study to which this obligation applies (interventional, observational, expanded access, compassionate use, or registry). Certain obligations (e.g., IND reporting) apply only to interventional studies, while privacy obligations apply. Valid values are `interventional|observational|expanded_access|compassionate_use|registry`',
    `approval_date` DATE COMMENT 'Date on which this obligation record was formally approved by the designated approver. Required for 21 CFR Part 11 compliant electronic records and audit trail documentation.',
    `obligation_category` STRING COMMENT 'Business process category to which this obligation belongs, enabling grouping for audit scope planning and compliance monitoring. Examples include safety_reporting (SAE/SUSAR timelines), data_integrity (ALCOA+ requirements), informed_consent (ICF',
    `cdisc_domain_reference` STRING COMMENT 'Reference to the applicable CDISC SDTM or ADaM domain that this obligation governs (e.g., SDTM AE domain, ADaM ADAE dataset). Relevant for data integrity and submission obligations, linking compliance requirements to specific data standards.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this obligation record was first created in the compliance management system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `data_integrity_relevance` STRING COMMENT 'Assessment of the degree to which this obligation relates to data integrity requirements (ALCOA+ principles: Attributable, Legible, Contemporaneous, Original, Accurate, Complete, Consistent, Enduring, Available).. Valid values are `critical|high|medium|low|not_applicable`',
    `obligation_description` STRING COMMENT 'Full narrative description of the compliance obligation, including the specific regulatory or contractual requirement, the expected action, and the conditions under which it applies.',
    `effective_date` DATE COMMENT 'Date from which this obligation became or becomes enforceable. For regulatory obligations, this aligns with the regulations effective date or the organizations adoption date.',
    `gcp_clause_reference` STRING COMMENT 'Specific ICH GCP E6(R2) clause or section number that this obligation maps to (e.g., ICH E6(R2) 5.17.1, ICH E6(R2) 4.8.2). Enables direct mapping between internal obligations and GCP requirements for audit finding classification and inspection',
    `inspection_readiness_priority` STRING COMMENT 'Priority tier assigned to this obligation for inspection readiness planning: tier_1 (highest priority, routinely inspected by FDA/EMA/PMDA), tier_2 (frequently reviewed), tier_3 (lower frequency but still in scope).. Valid values are `tier_1|tier_2|tier_3`',
    `jurisdiction` STRING COMMENT 'Geographic or regulatory jurisdiction(s) to which this obligation applies, expressed as ISO 3166-1 alpha-3 country codes or a named regulatory region (e.g., USA, GBR, JPN, EU). Supports multi-jurisdictional compliance mapping for global studies.',
    `last_reviewed_date` DATE COMMENT 'Date on which this obligation was most recently reviewed for continued accuracy, regulatory alignment, and applicability. Used to identify overdue reviews and ensure the obligation register remains current ahead of inspections.',
    `mastercontrol_record_number` STRING COMMENT 'System-of-record identifier from MasterControl for this obligation document or record. Enables direct cross-reference to the source document control system for audit trail retrieval, electronic signature verification, and training linkage.',
    `monitoring_frequency` STRING COMMENT 'How frequently compliance with this obligation must be monitored or assessed (e.g., continuous for real-time safety reporting obligations, annual for SOP review obligations, per_event for SAE reporting triggers).',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this obligation. Calculated from last_reviewed_date plus review_cycle_months. Triggers review workflow in MasterControl and compliance calendar alerts.',
    `non_compliance_consequence` STRING COMMENT 'Description of the regulatory, legal, or operational consequences of failing to meet this obligation (e.g., Warning Letter, Clinical Hold, Study Suspension, Financial Penalty, Data Exclusion from Submission).',
    `penalty_description` STRING COMMENT 'Specific description of financial or administrative penalties associated with non-compliance (e.g., Up to EUR 20 million or 4% of global annual turnover under GDPR, Civil monetary penalties under 21 CFR Part 17).',
    `privacy_regulation_flag` BOOLEAN COMMENT 'Indicates whether this obligation is driven by or intersects with a patient data privacy regulation (GDPR, HIPAA, or equivalent). When True, additional data protection impact assessment and privacy controls are required.',
    `reference_number` STRING COMMENT 'Externally-known, human-readable unique code assigned to this obligation (e.g., OBL-2024-0042). Used in audit reports, inspection readiness packages, and CAPA linkage to cite the specific standing requirement.',
    `regulatory_authority` STRING COMMENT 'The governing body or regulatory authority that issued or enforces this obligation (e.g., FDA, EMA, PMDA, MHRA, TGA, Health Canada). Determines the jurisdictional scope and applicable inspection authority.',
    `regulatory_citation` STRING COMMENT 'Specific citation to the authoritative source document, including section, article, or clause number (e.g., ICH E6(R2) Section 5.17, 21 CFR Part 312.32(c), EU CTR 536/2014 Article 42, GDPR Article 83).',
    `reporting_timeline_days` BIGINT COMMENT 'Number of calendar days within which the required action or report must be completed from the triggering event (e.g., 7 days for fatal/life-threatening SUSARs, 15 days for non-fatal SUSARs, 30 days for annual IND safety reports).',
    `review_cycle_months` BIGINT COMMENT 'Number of months between scheduled periodic reviews of this obligation to assess continued applicability, regulatory changes, and alignment with current SOPs (e.g., 12 for annual review, 6 for semi-annual). Drives the compliance calendar in MasterControl.',
    `secondary_responsible_function` STRING COMMENT 'Secondary organizational function that shares accountability or provides support for fulfilling this obligation (e.g., Legal, IT, Finance). Captures cross-functional obligations where primary ownership is shared.',
    `source_document_reference` STRING COMMENT 'Reference to the authoritative source document from which this obligation is derived, such as a Veeva Vault document ID, eTMF document number, or external regulatory publication reference (e.g., Federal Register citation, EMA guideline document number).',
    `source_type` STRING COMMENT 'Categorizes the origin of the obligation: regulatory (government-mandated law or regulation), contractual (sponsor or CRO contract clause), sponsor (sponsor-specific quality standard beyond regulation), internal_policy (company SOP or policy), or. Valid values are `regulatory|contractual|sponsor|internal_policy|guideline`',
    `sponsor_contractual_reference` STRING COMMENT 'Reference to the specific sponsor contract, Clinical Trial Agreement (CTA), or Master Service Agreement (MSA) clause that establishes this obligation when source_type is contractual or sponsor.',
    `obligation_status` STRING COMMENT 'Current lifecycle status of the obligation record: active (currently enforceable), superseded (replaced by a newer version), retired (no longer applicable), draft (under development), or under_review (being assessed for regulatory change impact).. Valid values are `active|superseded|retired|draft|under_review`',
    `subject_safety_relevance` STRING COMMENT 'Assessment of the degree to which non-compliance with this obligation could directly impact clinical trial subject safety. Critical obligations (e.g., SAE reporting, SUSAR notification) require immediate escalation upon non-compliance.. Valid values are `critical|high|medium|low|not_applicable`',
    `superseded_by_reference` STRING COMMENT 'Reference number of the obligation that replaced this one when status is superseded. Enables forward navigation in the obligation version chain for regulatory change impact analysis.',
    `superseded_date` DATE COMMENT 'Date on which this obligation was superseded, retired, or replaced by a newer version. Null for currently active obligations. Supports historical audit trail and version lineage tracking.',
    `timeline_basis` STRING COMMENT 'Specifies the basis for calculating the reporting timeline: whether days are calendar or business days, and the triggering event from which the clock starts (e.g., from_awareness for SAE reporting, from_database_lock for CSR submission).. Valid values are `calendar_days|business_days|from_awareness|from_event|from_database_lock|from_study_end`',
    `title` STRING COMMENT 'Short, descriptive title of the compliance obligation (e.g., Adverse Event Reporting within 15 Days, Annual IND Safety Report Submission). Used as the primary display label in compliance dashboards and audit readiness trackers.',
    `training_curriculum_reference` STRING COMMENT 'Reference to the MasterControl training curriculum or course code required to demonstrate competency for this obligation (e.g., TRN-GCP-001, TRN-SAE-003). Populated when training_required_flag is True.',
    `training_required_flag` BOOLEAN COMMENT 'Indicates whether personnel must complete specific training to fulfill this obligation. When True, a training curriculum must be assigned in MasterControl and completion tracked prior to study participation.',
    `obligation_type` STRING COMMENT 'Indicates whether the obligation is mandatory (must comply unconditionally), conditional (applies only under specified circumstances), recommended (best practice guidance), or prohibited (action that must not occur).. Valid values are `mandatory|conditional|recommended|prohibited`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this obligation record. Supports change tracking, audit trail requirements under 21 CFR Part 11, and version history management in MasterControl.',
    `version_number` STRING COMMENT 'Version identifier of this obligation record (e.g., 1.0, 2.1). Incremented when the obligation text, scope, or requirements are updated following regulatory changes or internal policy revisions. Supports version-controlled compliance documentation.',
    CONSTRAINT pk_obligation PRIMARY KEY(`obligation_id`)
) COMMENT 'Reference master defining the regulatory and contractual compliance obligations applicable to the organization across jurisdictions and study types. Captures obligation reference, obligation source (ICH GCP, FDA 21 CFR Part 11, EU CTR 536/2014, GDPR';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` (
    `ethics_committee_id` BIGINT COMMENT 'Unique surrogate identifier for the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) record in the lakehouse silver layer.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to the clinical development program for which this ethics committee engagement was established',
    `country_id` BIGINT COMMENT 'add column country_id (BIGINT) with FK to study.country.country_id — ethics committees operate within specific countries',
    `parent_ethics_committee_id` BIGINT COMMENT 'Self-referencing FK on ethics_committee (parent_ethics_committee_id)',
    `accreditation_body` STRING COMMENT 'Name of the organization that granted accreditation to this ethics committee (e.g., AAHRPP, UKAS, DAkkS, NATA). Used to validate the committees standing for regulatory submissions and sponsor qualification checks.',
    `accreditation_expiry_date` DATE COMMENT 'Date on which the current accreditation certificate expires. Triggers renewal workflows and alerts to prevent use of an expired committee for new study submissions. Null if accreditation is perpetual or not applicable.',
    `accreditation_number` STRING COMMENT 'Official accreditation certificate number issued by the accrediting body. Referenced in regulatory submissions, TMF documentation, and sponsor qualification audits to verify committee standing.',
    `accreditation_status` STRING COMMENT 'Current accreditation status of the ethics committee with the relevant accrediting body (e.g., AAHRPP for U.S. IRBs, national competent authority for EU IECs). Determines eligibility to provide ethical oversight for sponsored clinical trials.. Valid values are `accredited|provisional|expired|not_accredited|under_review`',
    `annual_renewal_required` BOOLEAN COMMENT 'Indicates whether ongoing studies require annual continuing review and renewal of ethics approval from this committee. True = annual renewal mandatory; False = approval is indefinite until amendment or closure. Drives renewal reminder workflows in CTMS.',
    `chair_name` STRING COMMENT 'Full name of the current chairperson of the ethics committee. Required for regulatory correspondence, submission cover letters, and TMF documentation. Classified as confidential as it identifies a named individual in a professional capacity.',
    `city` STRING COMMENT 'City in which the ethics committee office is physically located. Used for geographic reporting, site feasibility assessments, and regulatory jurisdiction mapping.',
    `committee_category` STRING COMMENT 'Operational category of the ethics committee: institutional (affiliated with a hospital or university), independent (standalone commercial IRB/IEC), central (single IRB/IEC covering multiple sites), national (government-mandated national body). Valid values are `institutional|independent|central|national|regional`',
    `committee_code` STRING COMMENT 'Unique business-facing alphanumeric code assigned to the IRB/IEC, used as the externally-known identifier in CTMS, eTMF, and regulatory submissions (e.g., IRB-MAYO-001). Serves as the BUSINESS_IDENTIFIER for this master-party entity.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `committee_type` STRING COMMENT 'Classification of the oversight body: IRB (Institutional Review Board, U.S.-centric), IEC (Independent Ethics Committee, international), DSMB (Data Safety Monitoring Board), DMC (Data Monitoring Committee), or Ethics_Board (generic national/regional. Valid values are `IRB|IEC|DSMB|DMC|Ethics_Board`',
    `contact_email` STRING COMMENT 'Official email address for submitting applications, amendments, and correspondence to the ethics committee. Serves as the PRIMARY_CONTACT for this master-party entity. Classified as confidential PII as it is an organizational contact email.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Official telephone number for the ethics committee office, used for urgent safety communications, protocol deviation notifications, and SAE reporting. Classified as confidential organizational contact data.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the ethics committee master record was first created in the system, in ISO 8601 format with timezone offset. Serves as the RECORD_AUDIT_CREATED for this master-party entity.',
    `ctms_record_number` STRING COMMENT 'Unique record identifier for this ethics committee in the source system (Clinical Trial Management System), enabling cross-system reconciliation and data lineage tracking between the lakehouse silver layer and the operational system of record.',
    `engagement_end_date` DATE COMMENT 'The date on which this ethics committees oversight of the clinical program was formally concluded or terminated. Null if the engagement is still active.',
    `engagement_start_date` DATE COMMENT 'The date on which this ethics committee was formally engaged to provide oversight for the clinical program. Marks the beginning of the regulatory relationship for this program-committee pairing.',
    `engagement_status` STRING COMMENT 'Current lifecycle status of this program-committee engagement. Tracks whether the committee is actively reviewing the program, suspended, or the engagement has been formally closed.',
    `expedited_review_available` BOOLEAN COMMENT 'Indicates whether this ethics committee offers an expedited review pathway for minimal-risk studies or protocol amendments, allowing approval without convening a full committee meeting.',
    `fwa_number` STRING COMMENT 'OHRP-issued Federalwide Assurance number for U.S. institutions, confirming commitment to protect human research subjects (format: FWA followed by 8 digits). Required for federally funded research and referenced in IND/NDA submissions to FDA.. Valid values are `^FWAd{8}$`',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether GDPR (General Data Protection Regulation) applies to submissions and data processed under this ethics committees jurisdiction. True = GDPR requirements apply (EU/EEA-based committee); False = non-EU jurisdiction.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether HIPAA (Health Insurance Portability and Accountability Act) privacy and security rules apply to research conducted under this ethics committees oversight. True = HIPAA applies (U.S.-based committee); False = non-U.S. jurisdiction.',
    `icf_template_required` BOOLEAN COMMENT 'Indicates whether this ethics committee mandates use of its own Informed Consent Form (ICF) template rather than the sponsors template. True = committee-specific ICF template required; False = sponsor template acceptable with committee approval.',
    `institution_name` STRING COMMENT 'Name of the parent institution or organization to which this ethics committee is affiliated (e.g., Mayo Clinic, University of Oxford, Charité – Universitätsmedizin Berlin). Distinguishes institutional IRBs/IECs from independent/central committees.',
    `is_central_irb` BOOLEAN COMMENT 'Indicates whether this ethics committee serves as a central IRB/IEC providing oversight for multiple investigational sites under a single review, as permitted by the NIH Single IRB Policy and 21st Century Cures Act.',
    `jurisdiction_description` STRING COMMENT 'Free-text description of the geographic or institutional jurisdiction covered by the ethics committee (e.g., State of Minnesota, USA, European Union member states, Federal Republic of Germany).',
    `language_code` STRING COMMENT 'BCP 47 language tag representing the primary language in which submissions must be prepared for this ethics committee (e.g., en, de, fr, ja). Drives ICF translation requirements and document preparation workflows.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `mailing_address` STRING COMMENT 'Full mailing address of the ethics committee office, used for formal regulatory correspondence, submission packages, and TMF documentation. Classified as confidential organizational contact data.',
    `meeting_frequency` STRING COMMENT 'Frequency at which the full ethics committee convenes for protocol review meetings. Informs submission timing strategy and study startup timeline planning. Expedited review may be available between scheduled meetings.. Valid values are `weekly|biweekly|monthly|bimonthly|quarterly|as_needed`',
    `ethics_committee_name` STRING COMMENT 'Official registered name of the IRB or IEC body as it appears on accreditation certificates and regulatory submissions (e.g., Mayo Clinic Institutional Review Board). Serves as the IDENTITY_LABEL for this master-party entity.',
    `notes` STRING COMMENT 'Free-text field for capturing additional operational notes, special submission requirements, known committee preferences, or historical context relevant to working with this ethics committee. Not used for structured data.',
    `oversight_scope` STRING COMMENT 'Defines the specific protocols, studies, or investigational sites within the clinical program that this ethics committee is responsible for reviewing and overseeing. Belongs to the engagement, not to either entity alone.',
    `primary_contact` STRING COMMENT 'The designated contact person at the ethics committee who is responsible for communications related to this specific clinical program. Distinct from the general committee contact_email on the ethics_committee master record, as this is program-specific.',
    `registration_number` STRING COMMENT 'Official government or regulatory registration number for the IRB or IEC (e.g., OHRP-assigned IRB registration number in the format IRB00XXXXXX, or EU national competent authority registration).',
    `regulatory_authority` STRING COMMENT 'Primary regulatory authority under whose framework this ethics committee operates and is recognized (e.g., FDA for U.S. IRBs under 21 CFR Part 56, EMA for EU IECs under EU CTR 536/2014). Determines applicable GCP standards and submission requirements.',
    `requires_local_pi_signature` BOOLEAN COMMENT 'Indicates whether this ethics committee requires the local Principal Investigator (PI) to co-sign the ethics application or ICF submission. True = local PI signature mandatory; False = sponsor or CRO signature sufficient. Affects site activation workflows.',
    `review_turnaround_days` BIGINT COMMENT 'Standard number of calendar days the ethics committee requires to complete initial protocol review from submission date. Used in study timeline planning, site feasibility assessments, and KPI tracking for enrollment readiness.',
    `sae_reporting_timeframe_days` BIGINT COMMENT 'Number of calendar days within which Serious Adverse Events (SAEs) and SUSARs must be reported to this ethics committee following identification. Varies by committee and jurisdiction; drives safety reporting workflow configuration in the source system',
    `state_province` STRING COMMENT 'State, province, or sub-national administrative region where the ethics committee is located. Relevant for U.S. state-level IRB regulations and Canadian provincial health research ethics requirements.',
    `ethics_committee_status` STRING COMMENT 'Current operational lifecycle status of the ethics committee. active indicates the committee is fully operational and accepting submissions; suspended indicates temporary halt of operations; dissolved indicates permanent closure.. Valid values are `active|inactive|suspended|dissolved|pending_accreditation`',
    `submission_method` STRING COMMENT 'Preferred or required method for submitting protocol applications, amendments, and safety reports to this ethics committee: electronic (via online portal or eTMF), paper (physical documents), or hybrid (combination).. Valid values are `electronic|paper|hybrid`',
    `submission_portal_url` STRING COMMENT 'URL of the ethics committees electronic submission portal or online application system. Used by CRAs and regulatory affairs teams to route submissions and track application status.. Valid values are `^https?://.+`',
    `submission_strategy` STRING COMMENT 'The agreed or required approach for submitting protocol amendments, safety reports, and annual reviews to this ethics committee for this specific program. May differ by committee and program based on regulatory jurisdiction and committee preferences.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the ethics committee master record was last modified, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_record_number` STRING COMMENT 'Unique record identifier for this ethics committee in Veeva Vault eTMF, used to cross-reference TMF documents, ethics approval letters, and correspondence stored in the document management system.',
    CONSTRAINT pk_ethics_committee PRIMARY KEY(`ethics_committee_id`)
) COMMENT 'Master record for each IRB or IEC body providing ethical oversight for clinical trials, capturing committee name, type, jurisdiction, and accreditation status';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` (
    `ethics_submission_id` BIGINT COMMENT 'Unique surrogate identifier for each ethics submission record in the lakehouse silver layer. Primary key for this entity.',
    `consent_icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: Ethics submissions formally submit specific ICF versions for IRB/IEC review. Linking ethics_submission to consent_icf_version normalizes the denormalized icf_version_submitted',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) to which this submission is directed. Links to the ethics committee master record.',
    `investigator_brochure_safety_id` BIGINT COMMENT 'Foreign key linking to safety.investigator_brochure_safety. Business justification: IB updates (especially SUSAR-triggered amendments) require IRB/IEC submission. ethics_submission already stores investigator_brochure_version as a denormalized text field.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor on whose behalf this ethics submission is made.',
    `parent_submission_ethics_submission_id` BIGINT COMMENT 'Reference to the original or preceding ethics submission that this record amends or continues. Enables lineage tracking across the full submission history for a study.',
    `primary_amended_ethics_submission_id` BIGINT COMMENT 'Self-referencing FK on ethics_submission (amended_ethics_submission_id)',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) named on this ethics submission. The PI is the party responsible for the conduct of the study at the site.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Ethics submissions are made on behalf of sponsors within a specific engagement. Tracking submissions per engagement enables sponsor portfolio oversight, ethics approval status reporting in',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ethics submission is made. Links to the study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Ethics submissions are triggered by protocol amendments (substantial modifications requiring IRB/IEC resubmission).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this ethics submission. Applicable when the submission is site-specific (e.g., local IRB/IEC review).',
    `approval_expiry_date` DATE COMMENT 'Date on which the current IRB or IEC approval expires, triggering the need for a continuing review submission to maintain authorization for study conduct.',
    `conditions_of_approval` STRING COMMENT 'Free-text description of any conditions, stipulations, or modifications required by the IRB or IEC as part of a conditional approval decision. Must be addressed before study initiation or continuation.',
    `continuing_review_due_date` DATE COMMENT 'Date by which the next continuing review submission must be filed with the IRB or IEC to maintain uninterrupted approval. Calculated from the approval expiry date minus any required lead time.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ethics submission record was first created in the system. Supports ALCOA+ data integrity principles and audit trail requirements.',
    `decision_date` DATE COMMENT 'Date on which the IRB or IEC issued its formal decision (approval, conditional approval, rejection, or other outcome) on this submission.',
    `decision_outcome` STRING COMMENT 'The formal decision rendered by the IRB or IEC on this submission. Drives downstream study activation, amendment implementation, and regulatory reporting.. Valid values are `approved|conditionally_approved|rejected|deferred|withdrawn|not_required`',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this ethics submission record and its associated documentation are complete and ready for regulatory inspection review. Used in audit readiness dashboards.',
    `irb_iec_name` STRING COMMENT 'Full legal name of the IRB or IEC receiving this submission. Retained directly on the record for reporting and audit trail purposes independent of the master reference.',
    `irb_iec_reference_number` STRING COMMENT 'Reference or tracking number assigned by the IRB or IEC upon receipt of the submission. Used for all correspondence and follow-up with the ethics committee.',
    `pi_name` STRING COMMENT 'Full name of the Principal Investigator (PI) as listed on the ethics submission. Retained directly on the record for audit trail and regulatory correspondence.',
    `protocol_version` STRING COMMENT 'Version identifier of the study protocol included in this submission package (e.g., v1.0, v2.1). Critical for linking the submission to the exact protocol document reviewed.',
    `receipt_confirmed_date` DATE COMMENT 'Date on which the IRB or IEC formally acknowledged receipt of the submission package. Marks the start of the review clock for regulatory timeline tracking.',
    `regulatory_authority` STRING COMMENT 'The national or regional regulatory authority whose requirements govern this ethics submission. Determines applicable reporting timelines and documentation standards.',
    `response_due_date` DATE COMMENT 'Date by which the sponsor or investigator must respond to IRB or IEC queries, conditions, or requests for additional information following a conditional approval or deferral.',
    `response_submitted_date` DATE COMMENT 'Date on which the sponsor or investigator submitted a formal response to IRB or IEC queries or conditions of approval.',
    `review_deadline_date` DATE COMMENT 'Target date by which the IRB or IEC is expected to complete its review and issue a decision, based on regulatory timelines or committee meeting schedules.',
    `review_type` STRING COMMENT 'Classification of the review procedure applied by the IRB or IEC (e.g., full board convened review, expedited review for minimal-risk studies, exempt determination). Determines regulatory timelines and quorum requirements.. Valid values are `full_board|expedited|exempt|administrative`',
    `subject_enrollment_authorized` BOOLEAN COMMENT 'Indicates whether this ethics approval authorizes the enrollment of new subjects at the site. False for submissions that do not grant or maintain enrollment authorization (e.g., pending conditions).',
    `submission_category` STRING COMMENT 'Detailed categorization of the submission content beyond the submission type, enabling granular tracking of what changed or was reported. [ENUM-REF-CANDIDATE',
    `submission_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction in which this ethics submission is filed. Determines applicable regulatory framework (e.g., FDA, EMA, PMDA, Health Canada).. Valid values are `^[A-Z]{3}$`',
    `submission_date` DATE COMMENT 'The date on which the submission package was formally transmitted to the IRB or IEC. This is the principal real-world business event date for this transaction.',
    `submission_method` STRING COMMENT 'The channel or mechanism used to transmit the submission package to the IRB or IEC (e.g., electronic portal, paper, email). Relevant for 21 CFR Part 11 compliance and audit trail.. Valid values are `electronic|paper|portal|email`',
    `submission_notes` STRING COMMENT 'Free-text field for capturing additional context, cover letter summary, or operational notes related to this ethics submission that are not captured in structured fields.',
    `submission_number` STRING COMMENT 'Externally-known, human-readable reference number assigned to this submission package (e.g., IRB-2024-0042-A01). Used for tracking across systems and correspondence with the ethics committee.',
    `submission_status` STRING COMMENT 'Current lifecycle state of the ethics submission package from preparation through final ethics committee decision. Drives workflow and compliance tracking.',
    `submission_type` STRING COMMENT 'Classification of the submission package by its purpose in the IRB/IEC review lifecycle. [ENUM-REF-CANDIDATE: initial_review|amendment|continuing_review|safety_report|closure|waiver_request|expedited_review|deviation_report — promote to reference product]',
    `tmf_document_reference` STRING COMMENT 'Reference identifier for the ethics submission package as filed in the electronic Trial Master File (eTMF) in Veeva Vault. Enables cross-system traceability for inspection readiness.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this ethics submission record. Supports ALCOA+ data integrity principles and change tracking for GCP compliance.',
    `veeva_vault_document_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF for the submission package. Provides direct linkage to the source document management system for audit and inspection purposes.',
    `waiver_granted` BOOLEAN COMMENT 'Indicates whether the IRB or IEC granted a waiver of informed consent or waiver of documentation of informed consent as part of this submission decision.',
    CONSTRAINT pk_ethics_submission PRIMARY KEY(`ethics_submission_id`)
) COMMENT 'Tracks each formal submission package sent to an IRB or IEC for a specific study, including initial review, amendments, and continuing review submissions';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` (
    `ethics_approval_id` BIGINT COMMENT 'Unique surrogate identifier for the ethics approval record in the lakehouse silver layer. Primary key for this entity.',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: Ethics approvals authorize a specific ICF version for use in subject enrollment.',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the IRB or IEC body that issued this approval decision. Links to the ethics committee master record.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: An ethics approval is the formal decision resulting from an ethics submission. Every approval originates from a specific submission package.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Ethics approvals carry a denormalized sponsor_name field. A proper FK to sponsor org enables sponsor portfolio-level ethics approval tracking, renewal management, and regulatory',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Ethics approvals are granted for a specific protocol version — a core GCP requirement. Direct FK to protocol enables protocol-version-level approval status tracking, supports site activation',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ethics approval was issued. Links the approval to the study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Ethics approvals are granted for specific protocol amendments. Direct FK to study_protocol_amendment enables amendment-level approval status tracking, supports site',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which this ethics approval applies. Null if the approval is a central/multi-site approval covering all sites.',
    `superseded_ethics_approval_id` BIGINT COMMENT 'Self-referencing FK on ethics_approval (superseded_ethics_approval_id)',
    `approval_conditions` STRING COMMENT 'Free-text description of any conditions, stipulations, or modifications required by the IRB/IEC as part of a conditional approval. Null for unconditional approvals.',
    `approval_letter_date` DATE COMMENT 'The date printed on the official ethics approval letter issued by the IRB/IEC. May differ from decision_date if the letter is issued after the meeting.',
    `approval_reference_number` STRING COMMENT 'Externally-known unique reference number assigned by the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) to this approval decision. Used for regulatory correspondence and audit trail.',
    `approval_status` STRING COMMENT 'Current lifecycle status of the ethics approval decision. Approved indicates unconditional approval; approved_with_conditions requires sponsor/PI to satisfy stated conditions; deferred means the committee requires additional information before deciding',
    `approval_type` STRING COMMENT 'Categorises the review pathway used by the IRB/IEC: full board review, expedited review, exempt determination, central ethics committee review, or local site-level review.. Valid values are `full_board|expedited|exempt|central|local`',
    `conditions_met_date` DATE COMMENT 'The date on which the sponsor or PI confirmed that all IRB/IEC-stipulated conditions for a conditional approval were satisfied, enabling the study to proceed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ethics approval record was first created in the system, conforming to ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) data integrity principles.',
    `ctms_record_number` STRING COMMENT 'Record identifier in the source system where this ethics approval is tracked for site activation and monitoring workflows.',
    `decision_date` DATE COMMENT 'The date on which the IRB/IEC formally issued its approval decision. This is the principal real-world event date for this transaction.',
    `disapproval_reason` STRING COMMENT 'Free-text reason provided by the IRB/IEC when the submission was disapproved or deferred. Null for approved submissions.',
    `effective_date` DATE COMMENT 'The date from which the ethics approval is binding and the study or amendment may commence at the site. May differ from decision_date if conditions must be met first.',
    `expiry_date` DATE COMMENT 'The date on which the ethics approval expires and must be renewed for the study to continue. Null for approvals with no defined expiry. Drives renewal workflow triggers.',
    `gdpr_applicable_flag` BOOLEAN COMMENT 'Indicates whether GDPR data protection requirements apply to this ethics approval, relevant for studies conducted in EU/EEA jurisdictions.',
    `hipaa_applicable_flag` BOOLEAN COMMENT 'Indicates whether HIPAA privacy rule requirements apply to this ethics approval, relevant for studies conducted in the United States.',
    `icf_approval_date` DATE COMMENT 'The date on which the specific ICF version was approved by the IRB/IEC. May differ from the overall protocol decision_date when ICF and protocol are reviewed separately.',
    `icf_version_approved` STRING COMMENT 'Version identifier of the Informed Consent Form (ICF) that was reviewed and approved as part of this ethics submission. Null if the submission did not include an ICF.',
    `irb_iec_country` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the country where the IRB/IEC is registered and operates.. Valid values are `^[A-Z]{3}$`',
    `irb_iec_name` STRING COMMENT 'Full legal name of the IRB or IEC that issued this approval. Retained as a denormalized reference for reporting and regulatory submissions.',
    `irb_iec_registration_number` STRING COMMENT 'Official registration or accreditation number of the IRB/IEC as assigned by the relevant regulatory authority (e.g., FDA OHRP registration number, EMA ethics committee identifier).',
    `pi_name` STRING COMMENT 'Full name of the Principal Investigator (PI) named on the ethics approval. Retained as a denormalized field for regulatory correspondence and inspection readiness.',
    `protocol_version` STRING COMMENT 'Version identifier of the study protocol document that was reviewed and approved. Enables tracking of which protocol version holds active ethics approval.',
    `quorum_met_flag` BOOLEAN COMMENT 'Indicates whether the required quorum of IRB/IEC members was present at the review meeting, as required for a valid approval decision.',
    `regulatory_authority_notification_date` DATE COMMENT 'Date on which the regulatory authority was notified of the IRB/IEC approval decision. Null if regulatory_authority_notified_flag is False.',
    `regulatory_authority_notified_flag` BOOLEAN COMMENT 'Indicates whether the relevant regulatory authority (e.g., FDA, EMA, MHRA) was notified of the IRB/IEC approval decision as required by applicable regulations.',
    `renewal_due_date` DATE COMMENT 'The date by which a renewal submission must be received by the IRB/IEC to maintain continuous approval. Typically calculated from expiry_date minus the committees required lead time.',
    `review_meeting_date` DATE COMMENT 'The date of the IRB/IEC board meeting at which this submission was formally reviewed and voted upon.',
    `submission_date` DATE COMMENT 'The date on which the sponsor or Principal Investigator (PI) submitted the protocol, amendment, or ICF to the IRB/IEC for review.',
    `submission_type` STRING COMMENT 'Classifies the type of submission reviewed by the IRB/IEC: initial protocol review, protocol amendment, annual renewal, safety report, Informed Consent Form (ICF) revision, or other.. Valid values are `initial|amendment|renewal|safety_report|icf_revision|other`',
    `tmf_document_reference` STRING COMMENT 'Reference identifier for the ethics approval letter and supporting documents stored in the Electronic Trial Master File (eTMF) in Veeva Vault. Enables direct navigation to source documents.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this ethics approval record. Supports audit trail and data lineage requirements per ALCOA+ principles.',
    `veeva_vault_document_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF where the original signed ethics approval letter is archived. Supports 21 CFR Part 11 electronic records compliance.',
    `vote_abstain_count` BIGINT COMMENT 'Number of IRB/IEC board members who abstained from voting at the review meeting.',
    `vote_against_count` BIGINT COMMENT 'Number of IRB/IEC board members who voted against approval at the review meeting.',
    `vote_in_favor_count` BIGINT COMMENT 'Number of IRB/IEC board members who voted in favor of approval at the review meeting. Supports audit trail and quorum verification.',
    `vulnerable_population_flag` BOOLEAN COMMENT 'Indicates whether the approved study involves vulnerable populations (e.g., minors, pregnant women, prisoners, cognitively impaired individuals) requiring additional IRB/IEC safeguards.',
    `waiver_of_consent_flag` BOOLEAN COMMENT 'Indicates whether the IRB/IEC granted a waiver or alteration of the informed consent requirement as part of this approval.',
    CONSTRAINT pk_ethics_approval PRIMARY KEY(`ethics_approval_id`)
) COMMENT 'Records the formal approval decision issued by an IRB or IEC for a study protocol, ICF, or amendment including approval conditions and expiry dates';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` (
    `continuing_review_id` BIGINT COMMENT 'Unique surrogate identifier for each continuing review record in the Databricks Silver Layer. Primary key for this entity.',
    `document_icf_version_id` BIGINT COMMENT 'Foreign key linking to document.document_icf_version. Business justification: Continuing review assesses whether the current ICF version remains adequate for ongoing subject protection.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: A continuing review renews or extends an existing ethics approval. The review references the original approval being continued.',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the IRB or IEC responsible for conducting this continuing review and granting approval.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: A continuing review is formally submitted to the IRB/IEC as an ethics submission package.',
    `previous_continuing_review_id` BIGINT COMMENT 'Self-referencing FK on continuing_review (previous_continuing_review_id)',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) responsible for the study at the site level, who signs and submits the continuing review application to the IRB/IEC.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Annual continuing reviews reference the current approved protocol version. Direct FK to protocol supports renewal tracking against protocol amendments, enables identification of reviews',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this continuing review is being conducted. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this continuing review, where applicable for site-specific IRB/IEC submissions.',
    `approval_expiry_date` DATE COMMENT 'Date on which the IRB/IEC approval granted by this continuing review expires. Study activities must cease or a new continuing review must be approved before this date.',
    `approval_start_date` DATE COMMENT 'Date from which the IRB/IEC approval granted by this continuing review becomes effective, authorizing continued conduct of the study.',
    `capa_required_flag` BOOLEAN COMMENT 'Indicates whether the IRB/IEC decision or conditions of approval require initiation of a CAPA in MasterControl to address identified deficiencies.',
    `completed_subject_count` BIGINT COMMENT 'Number of subjects who have completed all study procedures as of the continuing review submission date.',
    `conditions_of_approval` STRING COMMENT 'Narrative description of any conditions, stipulations, or modifications required by the IRB/IEC as part of an approval with conditions decision. Null if unconditional approval.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this continuing review record was first created in the system, supporting ALCOA+ audit trail requirements.',
    `decision_date` DATE COMMENT 'Date on which the IRB/IEC issued its formal decision (approval, deferral, disapproval, or suspension) for this continuing review.',
    `disapproval_reason` STRING COMMENT 'Narrative explanation provided by the IRB/IEC for a disapproval, deferral, or suspension decision. Required for regulatory documentation and CAPA initiation.',
    `enrolled_subject_count` BIGINT COMMENT 'Total number of subjects enrolled in the study at the time of this continuing review submission. Key metric for IRB/IEC risk-benefit assessment.',
    `icf_update_required` BOOLEAN COMMENT 'Indicates whether the IRB/IEC has determined that the Informed Consent Form must be revised and re-consented as a condition of this continuing review approval.',
    `irb_iec_decision` STRING COMMENT 'Formal decision rendered by the IRB/IEC following review of the continuing review application. Distinct from review_status as it captures the specific regulatory outcome.. Valid values are `approved|approved_with_conditions|deferred|disapproved|suspended|terminated`',
    `mastercontrol_record_number` STRING COMMENT 'Identifier of the corresponding record in MasterControl QMS, used for document control, audit trail, and electronic signature management of the continuing review workflow.',
    `next_review_due_date` DATE COMMENT 'Calculated deadline by which the next continuing review submission must be received by the IRB/IEC to maintain uninterrupted approval. Typically one year from approval date unless a shorter interval is specified.',
    `pi_signature_date` DATE COMMENT 'Date on which the Principal Investigator signed the continuing review application, certifying accuracy and completeness per ALCOA+ principles.',
    `protocol_deviation_count` BIGINT COMMENT 'Total number of protocol deviations recorded since the previous continuing review period. Informs IRB/IEC assessment of GCP compliance and study conduct quality.',
    `protocol_version` STRING COMMENT 'Version number of the study protocol in effect at the time of this continuing review submission.',
    `regulatory_authority_notification_required` BOOLEAN COMMENT 'Indicates whether the outcome of this continuing review (e.g., suspension or termination) requires notification to a regulatory authority such as FDA, EMA, or MHRA.',
    `review_interval_days` BIGINT COMMENT 'Number of days between the current approval and the required next continuing review, as specified by the IRB/IEC. Standard is 365 days but may be shortened based on risk level.',
    `review_meeting_date` DATE COMMENT 'Date on which the IRB/IEC convened or conducted the review of this continuing review application, whether full board or expedited.',
    `review_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned by the IRB/IEC or the sponsor/CRO to uniquely reference this continuing review submission. Used in regulatory correspondence and TMF filing.',
    `review_status` STRING COMMENT 'Current lifecycle status of the continuing review record. Tracks progression from initial submission through IRB/IEC decision. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|approved_with_conditions|deferred|disapproved|suspended|withdrawn —',
    `review_type` STRING COMMENT 'Classification of the continuing review procedure. Annual reviews occur on a scheduled cycle; interim reviews are triggered by safety events or protocol amendments; expedited reviews apply to minimal-risk studies; full board reviews require convened. Valid values are `annual|interim|expedited|full_board|administrative`',
    `risk_benefit_assessment` STRING COMMENT 'IRB/IEC determination of whether the risk-benefit ratio of the study remains acceptable for continued conduct, based on accumulated safety and efficacy data.. Valid values are `favorable|unfavorable|requires_modification|inconclusive`',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of the IRB/IEC decision for this continuing review.',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the sponsor has been formally notified of the IRB/IEC decision from this continuing review, as required by GCP and sponsor oversight obligations.',
    `study_phase` STRING COMMENT 'Clinical development phase of the study at the time of this continuing review. Influences IRB/IEC review frequency and risk assessment criteria.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `study_status_at_review` STRING COMMENT 'Operational status of the clinical study at the time of this continuing review submission. Determines the scope of IRB/IEC oversight required.. Valid values are `ongoing|enrollment_complete|follow_up_only|closed_to_enrollment|suspended|terminated`',
    `submission_date` DATE COMMENT 'Date on which the continuing review application package was formally submitted to the IRB/IEC. Serves as the principal business event date for this transaction.',
    `submission_method` STRING COMMENT 'Method by which the continuing review application was submitted to the IRB/IEC (electronic via eTMF/portal, paper, or hybrid). Relevant for 21 CFR Part 11 compliance tracking.. Valid values are `electronic|paper|hybrid`',
    `tmf_document_reference` STRING COMMENT 'Reference identifier for the continuing review submission package and approval letter filed in the electronic Trial Master File (eTMF) in Veeva Vault, per TMF Reference Model Zone 6.',
    `unanticipated_problem_count` BIGINT COMMENT 'Number of unanticipated problems involving risks to subjects or others reported since the last review period. Includes SUSARs and other unexpected safety findings.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this continuing review record, supporting audit trail and data lineage requirements.',
    `veeva_vault_document_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF for the continuing review approval letter and associated submission documents. Enables direct traceability to the source regulatory document.',
    `withdrawn_subject_count` BIGINT COMMENT 'Number of subjects who withdrew consent or were withdrawn from the study prior to completion as of the submission date.',
    CONSTRAINT pk_continuing_review PRIMARY KEY(`continuing_review_id`)
) COMMENT 'Manages the periodic continuing review process required by IRBs/IECs to ensure ongoing ethical conduct of a study';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` (
    `ethics_correspondence_id` BIGINT COMMENT 'Unique surrogate identifier for each ethics committee correspondence record in the Databricks Silver Layer.',
    `consent_icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: Ethics correspondence frequently references specific ICF versions (queries about ICF content, approval of ICF amendments, requests for ICF revisions).',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) that is the recipient or sender of this correspondence.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: Ethics correspondence (queries, responses, clarifications) is typically associated with a specific ethics submission.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Ethics committee correspondence references specific protocol versions (queries, clarifications, responses).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ethics correspondence was generated.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Ethics committee correspondence is frequently triggered by protocol amendments (queries about amendment rationale, requests for clarification).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this ethics correspondence, if site-specific.',
    `approval_date` DATE COMMENT 'The date on which the IRB/IEC formally approved the submission associated with this correspondence. Critical for determining study start eligibility.',
    `approval_expiry_date` DATE COMMENT 'The date on which the IRB/IEC approval associated with this correspondence expires, triggering a continuing review submission requirement.',
    `approval_status` STRING COMMENT 'The IRB/IEC decision outcome associated with this correspondence, where applicable (e.g., approved, approved with conditions, deferred, disapproved).. Valid values are `approved|approved_with_conditions|deferred|disapproved|pending|not_applicable`',
    `closure_date` DATE COMMENT 'The date on which this correspondence item was formally closed, indicating all required actions and responses have been completed.',
    `communication_channel` STRING COMMENT 'The medium through which the correspondence was transmitted (e.g., email, postal mail, fax, electronic submission portal, hand delivery).. Valid values are `email|postal_mail|fax|electronic_portal|hand_delivery`',
    `conditions_of_approval` STRING COMMENT 'Description of any conditions or stipulations attached to the IRB/IEC approval, which must be satisfied before or during study conduct.',
    `correspondence_category` STRING COMMENT 'High-level category grouping the correspondence by subject matter: safety (SAE/SUSAR notifications), regulatory, protocol-related, consent-related, or administrative.. Valid values are `safety|regulatory|protocol|consent|administrative`',
    `correspondence_date` DATE COMMENT 'The principal real-world date on which the correspondence was formally issued, sent, or received — the business event date as recorded on the document.',
    `correspondence_reference_number` STRING COMMENT 'Externally-known unique alphanumeric reference number assigned to this correspondence item, used for tracking across systems such as Veeva Vault eTMF and the source system',
    `correspondence_status` STRING COMMENT 'Current lifecycle state of the correspondence item, tracking its workflow from draft through closure. [ENUM-REF-CANDIDATE: draft|sent|received|acknowledged|pending_response|closed|cancelled — 7 candidates stripped; promote to reference product]',
    `correspondence_summary` STRING COMMENT 'A concise narrative summary of the content, purpose, and key points of the correspondence, enabling quick review without accessing the full document.',
    `correspondence_type` STRING COMMENT 'Classification of the correspondence by its business purpose: initial protocol submission, amendment submission, query from IRB/IEC, clarification response, safety notification, approval acknowledgement, or adverse event report.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction in which the IRB/IEC operates, supporting multi-regional regulatory compliance tracking.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this ethics correspondence record was first created in the system, supporting audit trail and ALCOA+ data integrity requirements.',
    `direction` STRING COMMENT 'Indicates whether the correspondence was sent by the sponsor/CRO to the IRB/IEC (outbound) or received from the IRB/IEC (inbound).. Valid values are `outbound|inbound`',
    `irb_iec_reference_number` STRING COMMENT 'The reference or tracking number assigned by the IRB/IEC to this correspondence or submission, used for cross-referencing with the ethics committees own records.',
    `protocol_version` STRING COMMENT 'The version identifier of the study protocol to which this correspondence pertains, enabling traceability to the specific protocol iteration under review.',
    `query_description` STRING COMMENT 'Detailed description of the query or clarification request raised by the IRB/IEC or sponsor, applicable when correspondence_type is query or clarification_response.',
    `received_date` DATE COMMENT 'The date on which the correspondence was received by the intended recipient. Used for response timeline tracking and regulatory compliance.',
    `recipient_name` STRING COMMENT 'Full name of the individual or committee to whom the correspondence is addressed (e.g., IRB/IEC Chair, Ethics Committee Secretary).',
    `recipient_organization` STRING COMMENT 'Name of the IRB/IEC or organization to which the correspondence is addressed.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority whose jurisdiction governs this ethics correspondence (e.g., FDA, EMA, MHRA), relevant for multi-regional studies. [ENUM-REF-CANDIDATE: FDA|EMA|MHRA|PMDA|TGA|Health_Canada|OHRP|other — 8 candidates stripped; promote to reference',
    `regulatory_reportable_flag` BOOLEAN COMMENT 'Indicates whether this correspondence involves a matter that must be reported to a regulatory authority (e.g., FDA, EMA) in addition to the IRB/IEC.',
    `response_due_date` DATE COMMENT 'The deadline by which a response to this correspondence is required, based on regulatory or contractual timelines (e.g., IRB/IEC query response window).',
    `response_overdue_flag` BOOLEAN COMMENT 'Indicates whether the required response to this correspondence has not been received by the response_due_date, triggering escalation workflows.',
    `response_received_date` DATE COMMENT 'The actual date on which a response to this correspondence was received, enabling SLA and compliance tracking against response_due_date.',
    `response_summary` STRING COMMENT 'Summary of the response provided to a query or clarification request, capturing the key points of the reply for audit trail and TMF documentation purposes.',
    `sender_name` STRING COMMENT 'Full name of the individual or organization that authored and sent this correspondence (e.g., Principal Investigator, Sponsor Medical Monitor, CRO Regulatory Affairs).',
    `sender_organization` STRING COMMENT 'Name of the organization from which the correspondence originated (e.g., sponsor company, CRO name, investigational site institution).',
    `sender_role` STRING COMMENT 'The functional role of the sender within the clinical trial organizational structure (e.g., Principal Investigator (PI), sponsor representative, CRO regulatory affairs).. Valid values are `principal_investigator|sponsor_representative|cro_regulatory|medical_monitor|site_coordinator|irb_iec_secretary`',
    `sent_date` DATE COMMENT 'The date on which the correspondence was dispatched to the IRB/IEC or sponsor. Distinct from correspondence_date (document date) and received_date.',
    `subject_line` STRING COMMENT 'The formal subject or title of the correspondence as it appears on the document, used for identification and search.',
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the content of this correspondence has a direct or potential impact on subject safety, requiring expedited handling.',
    `submission_type` STRING COMMENT 'Classifies the nature of the submission associated with this correspondence: initial protocol submission, continuing review, protocol amendment, safety report, deviation report, or study closure.. Valid values are `initial|continuing_review|amendment|safety_report|deviation_report|closure`',
    `tmf_document_reference` STRING COMMENT 'Reference to the corresponding document stored in the electronic Trial Master File (eTMF) in Veeva Vault, enabling traceability between this record and the source document.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this ethics correspondence record was last modified, supporting audit trail and change tracking per ALCOA+ and 21 CFR Part 11.',
    `veeva_vault_document_number` STRING COMMENT 'The unique document identifier in Veeva Vault eTMF where the original correspondence document is stored, enabling direct system cross-reference.',
    CONSTRAINT pk_ethics_correspondence PRIMARY KEY(`ethics_correspondence_id`)
) COMMENT 'Captures all formal written communications between the sponsor/CRO and ethics committees including queries, clarifications, and notifications';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` (
    `vulnerable_population_id` BIGINT COMMENT 'Unique surrogate identifier for a vulnerable population protection record within the compliance domain. Serves as the primary key for this entity.',
    `capacity_assessment_id` BIGINT COMMENT 'Reference to the formal cognitive capacity assessment record conducted for this subject to determine consent capacity. Links to the consent.capacity_assessment product.',
    `consent_icf_version_id` BIGINT COMMENT 'Reference to the specific ICF version used for this vulnerable population subject, which must include population-specific language, assent forms, and LAR consent provisions as applicable. Links to the consent.consent_icf_version product.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: vulnerable_population.irb_iec_approval_number is a free-text reference to the IRB/IEC approval governing the vulnerable population protections.',
    `lar_representative_id` BIGINT COMMENT 'Reference to the LAR record associated with this vulnerable population subject. Links to the consent domain LAR representative product for tracking guardian/parent/legal representative details.',
    `parent_vulnerable_population_id` BIGINT COMMENT 'Self-referencing FK on vulnerable_population (parent_vulnerable_population_id)',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Vulnerable population protections (pediatric, pregnant, cognitively impaired subjects) are defined in and governed by a specific protocol version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this vulnerable population protection record applies. Links to the study master data product.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the vulnerable population is enrolled or monitored. Enables site-level compliance tracking and inspection readiness.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject identified as belonging to a vulnerable population. Links to the subject master data product for individual-level tracking.',
    `additional_safeguards_description` STRING COMMENT 'Narrative description of any additional ethical safeguards, protections, or monitoring measures implemented beyond standard GCP requirements for this vulnerable population subject.',
    `assent_required` BOOLEAN COMMENT 'Indicates whether subject assent (in addition to LAR consent) is required for this vulnerable population subject, typically applicable to pediatric subjects with sufficient cognitive capacity to understand participation.',
    `capacity_assessment_required` BOOLEAN COMMENT 'Indicates whether a formal cognitive capacity assessment is required to determine the subjects ability to provide informed consent. Primarily applicable to cognitively impaired and elderly populations. Links to the consent.capacity_assessment product.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this vulnerable population protection record was first created in the system. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic record compliance.',
    `dsmb_oversight_required` BOOLEAN COMMENT 'Indicates whether DSMB/DMC oversight is specifically required for the vulnerable population cohort within this study, in addition to or separate from overall study DSMB oversight. Ensures independent safety review for high-risk vulnerable populations.',
    `enhanced_monitoring_required` BOOLEAN COMMENT 'Indicates whether enhanced or increased frequency monitoring is required for this vulnerable population subject beyond the standard site monitoring plan. Triggers additional CRA visit scheduling and SDV requirements in the source system',
    `enrollment_end_date` DATE COMMENT 'Date on which enrollment of subjects from this vulnerable population category was closed or completed at the study or site level. Null if enrollment is ongoing.',
    `enrollment_justification` STRING COMMENT 'Documented scientific and ethical justification for enrolling subjects from this vulnerable population, including why the research cannot be conducted in non-vulnerable populations and how the study addresses the specific health needs of this group.',
    `enrollment_start_date` DATE COMMENT 'Date on which enrollment of subjects from this vulnerable population category commenced at the study or site level. Must be on or after IRB/IEC approval date and all required safeguards being in place.',
    `gdpr_special_category_flag` BOOLEAN COMMENT 'Indicates whether data collected from this vulnerable population subject constitutes GDPR Article 9 special category data (health data, genetic data, biometric data).',
    `hipaa_phi_flag` BOOLEAN COMMENT 'Indicates whether Protected Health Information (PHI) under HIPAA is involved in data collection for this vulnerable population subject. Triggers HIPAA-compliant data handling, de-identification, and authorization requirements for U.S.-based sites.',
    `impairment_type` STRING COMMENT 'Specific type of cognitive or decisional impairment affecting the subjects consent capacity (e.g., dementia, intellectual disability, acute psychiatric condition, traumatic brain injury). Applicable when population_category is cognitively_impaired.',
    `independent_advocate_name` STRING COMMENT 'Name of the independent advocate or patient representative assigned to this vulnerable population subject. Populated when independent_advocate_required is True.',
    `independent_advocate_required` BOOLEAN COMMENT 'Indicates whether an independent patient advocate or subject representative (independent of the research team) is required to be present during the consent process for this vulnerable subject.',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the IRB or IEC granted approval for enrollment of this vulnerable population category. Must precede first subject enrollment per GCP requirements.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether specific IRB/IEC approval is required for enrollment of this vulnerable population category beyond the standard study approval. Certain vulnerable populations (e.g., prisoners, neonates) require additional ethics committee review per 21',
    `irb_iec_expiry_date` DATE COMMENT 'Date on which the IRB/IEC approval for this vulnerable population enrollment expires. Triggers renewal workflow in MasterControl to ensure continuous compliance coverage.',
    `lar_consent_required` BOOLEAN COMMENT 'Indicates whether consent from a Legally Authorized Representative (LAR) is required because the subject lacks capacity to provide independent informed consent. Applicable to pediatric, cognitively impaired, and other incapacitated populations.',
    `mastercontrol_record_number` STRING COMMENT 'Identifier of the corresponding quality management record in MasterControl for this vulnerable population protection record. Enables traceability between the compliance data product and the document control system for SOP compliance, training, and CAPA',
    `monitoring_frequency` STRING COMMENT 'Frequency of enhanced monitoring visits required for this vulnerable population subject. Applicable when enhanced_monitoring_required is True. Drives CRA scheduling in the source system. Valid values are `weekly|biweekly|monthly|quarterly|per_protocol|not_applicable`',
    `pediatric_age_band` STRING COMMENT 'ICH E11-defined age band classification for pediatric subjects. Applicable only when population_category is pediatric. Drives age-appropriate dosing, formulation, and consent/assent requirements.. Valid values are `neonate|infant|toddler|child|adolescent|not_applicable`',
    `population_category` STRING COMMENT 'Primary classification of the vulnerable population type as defined by ICH E6(R2) and applicable regulations. Drives the specific ethical safeguards, consent requirements, and regulatory reporting obligations applicable to this subject.',
    `population_subcategory` STRING COMMENT 'Further granular classification within the primary population category (e.g., neonates, infants, adolescents within pediatric; first trimester, third trimester within pregnant; mild, moderate, severe within cognitively impaired).',
    `pregnancy_trimester` STRING COMMENT 'Trimester classification for pregnant subjects at time of enrollment or identification. Applicable only when population_category is pregnant. Relevant for teratogenicity risk assessment, fetal safety monitoring, and regulatory reporting under ICH S5.. Valid values are `first|second|third|postpartum|not_applicable`',
    `protection_status` STRING COMMENT 'Current lifecycle status of the ethical protection and safeguard record for this vulnerable population subject. Active indicates safeguards are in force; under_review indicates a triggered reassessment; suspended indicates enrollment or. Valid values are `active|under_review|closed|suspended|waived`',
    `protocol_section_reference` STRING COMMENT 'Reference to the specific section(s) of the study protocol that address vulnerable population inclusion criteria, special safeguards, and ethical considerations. Enables traceability between this protection record and the governing protocol document.',
    `record_number` STRING COMMENT 'Human-readable, externally referenceable identifier for this vulnerable population protection record, used in regulatory submissions, audit trails, and TMF cross-referencing. Format: VP-{StudyCode}-{Sequence}.. Valid values are `^VP-[A-Z0-9]{4,10}-[0-9]{4,8}$`',
    `regulatory_authority_notification_required` BOOLEAN COMMENT 'Indicates whether the applicable regulatory authority (FDA, EMA, PMDA, etc.) must be notified of the enrollment of this vulnerable population category, beyond standard IND/CTA reporting.',
    `regulatory_authority_notified_date` DATE COMMENT 'Date on which the applicable regulatory authority was notified of the enrollment of this vulnerable population subject or cohort. Populated when regulatory_authority_notification_required is True.',
    `risk_benefit_assessment_documented` BOOLEAN COMMENT 'Indicates whether a documented risk-benefit assessment specific to this vulnerable population category has been completed and filed in the TMF. Required by ICH E6(R2) and applicable regulations before enrollment of vulnerable subjects.',
    `risk_level` STRING COMMENT 'Regulatory risk classification for the research procedures applied to this vulnerable population subject, as assessed by the IRB/IEC. Determines permissibility of enrollment under 21 CFR Part 46 Subparts B/C/D and OHRP guidance.. Valid values are `minimal|minor_increase_over_minimal|greater_than_minimal|not_assessed`',
    `safety_reporting_expedited` BOOLEAN COMMENT 'Indicates whether expedited adverse event and SAE reporting timelines apply to this vulnerable population subject due to heightened safety concerns. When True, AE/SAE events for this subject are subject to accelerated reporting to the source system and',
    `tmf_document_reference` STRING COMMENT 'Reference to the TMF document identifier in Veeva Vault eTMF for the vulnerable population protection documentation, including IRB/IEC approvals, risk-benefit assessments, and special safeguard records. Supports inspection readiness and audit trail.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this vulnerable population protection record was most recently modified. Supports ALCOA+ audit trail requirements and change tracking for regulatory inspection readiness.',
    CONSTRAINT pk_vulnerable_population PRIMARY KEY(`vulnerable_population_id`)
) COMMENT 'Tracks special ethical protections and safeguards applied to studies enrolling vulnerable populations including pediatric, pregnant, and cognitively impaired subjects';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` (
    `irb_reliance_id` BIGINT COMMENT 'Unique surrogate identifier for the IRB reliance agreement record in the lakehouse silver layer.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: IRB reliance agreements (sIRB arrangements under NIH policy) are often established at the program level covering all studies.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: irb_reliance.irb_approval_number is a free-text reference to the IRB approval associated with the reliance agreement.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: IRB reliance agreements are established under the master agreement framework between sponsor and CRO.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: IRB reliance agreements (single IRB under 21st Century Cures Act) are executed for a specific protocol.',
    `reviewing_ethics_committee_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_committee. Business justification: irb_reliance stores the reviewing IRB identity as three free-text fields (name, registration_number, fwa_number).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this reliance agreement was established. Null for master reliance agreements covering multiple studies.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: IRB reliance agreements are updated when protocol amendments occur. Direct FK to study_protocol_amendment supports amendment-driven reliance agreement revision tracking',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical trial site (relying institution site) covered by this reliance agreement, linking to the site master record in the CTMS.',
    `superseded_irb_reliance_id` BIGINT COMMENT 'Self-referencing FK on irb_reliance (superseded_irb_reliance_id)',
    `agreement_number` STRING COMMENT 'Externally-known reference number assigned to the single-IRB reliance or authorization agreement, used for cross-institutional tracking and regulatory correspondence.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the reliance agreement: draft (under preparation), pending_execution (awaiting signatures), active (fully executed and in force), suspended (temporarily halted), terminated (ended before expiry), or expired (past effective end. Valid values are `draft|pending_execution|active|suspended|terminated|expired`',
    `agreement_type` STRING COMMENT 'Classification of the reliance agreement: single-IRB reliance under the Common Rule, authorization agreement, master reliance covering multiple studies, study-specific reliance, or NIH-mandated IRB reliance.. Valid values are `single_irb_reliance|authorization_agreement|master_reliance|study_specific_reliance|nih_irb_reliance`',
    `amendment_date` DATE COMMENT 'Date on which the most recent amendment to the reliance agreement was executed and became effective.',
    `continuing_review_due_date` DATE COMMENT 'Date by which the next continuing review must be submitted to the reviewing IRB to maintain active approval status under this reliance agreement. Applicable for studies not exempt from continuing review.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the IRB reliance agreement record was first created in the system, supporting audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `effective_date` DATE COMMENT 'Date on which the reliance agreement becomes legally binding and the reviewing IRB assumes oversight responsibility for the relying institution(s).',
    `execution_date` DATE COMMENT 'Date on which all required parties signed and fully executed the reliance agreement, establishing its legal validity.',
    `exempt_category` STRING COMMENT 'Specific exemption category (1–6 under the Revised Common Rule) assigned by the reviewing IRB if the research qualifies as exempt from full IRB oversight. Null for non-exempt research.',
    `expiration_date` DATE COMMENT 'Date on which the reliance agreement ceases to be in force. Null for open-ended agreements. Triggers renewal workflow when approaching.',
    `fda_regulated_flag` BOOLEAN COMMENT 'Indicates whether the research covered by this reliance agreement is subject to FDA regulations (e.g., IND or IDE studies), which may impose additional IRB requirements beyond the Common Rule.',
    `gdpr_applicable_flag` BOOLEAN COMMENT 'Indicates whether GDPR data protection requirements apply to the reliance agreement, relevant when the relying institution or reviewing IRB operates within the European Economic Area.',
    `hipaa_applicable_flag` BOOLEAN COMMENT 'Indicates whether HIPAA Privacy Rule requirements apply to the research covered by this reliance agreement, relevant for U.S.-based studies involving protected health information.',
    `ind_number` STRING COMMENT 'FDA-assigned IND application number for the investigational product under study, required for FDA-regulated research covered by this reliance agreement.',
    `initial_approval_date` DATE COMMENT 'Date on which the reviewing IRB granted initial approval for the protocol at the relying institution under this reliance agreement.',
    `inspection_ready_flag` BOOLEAN COMMENT 'Indicates whether the reliance agreement documentation is complete and inspection-ready per GCP and regulatory authority requirements (FDA, EMA, MHRA). Set to True when all required documents are filed in the eTMF.',
    `irb_submission_number` STRING COMMENT 'Submission tracking number assigned by the reviewing IRB for the initial protocol submission or reliance request, used to cross-reference IRB correspondence and approval letters.',
    `last_continuing_review_date` DATE COMMENT 'Date of the most recent continuing review approval granted by the reviewing IRB for the protocol covered under this reliance agreement.',
    `multi_site_flag` BOOLEAN COMMENT 'Indicates whether this reliance agreement covers multiple clinical trial sites (True) or a single site (False), relevant for NIH-mandated single IRB requirements for multi-site studies.',
    `nih_funded_flag` BOOLEAN COMMENT 'Indicates whether the study covered by this reliance agreement is funded by the National Institutes of Health (NIH), triggering mandatory single IRB requirements under the NIH sIRB policy.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, special conditions, or operational notes related to the reliance agreement that are not captured in structured fields.',
    `pi_contact_email` STRING COMMENT 'Email address of the Principal Investigator at the relying institution, used for reliance agreement notifications, amendment communications, and IRB correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `pi_name` STRING COMMENT 'Full name of the Principal Investigator at the relying institution site who is conducting research under the oversight of the reviewing IRB per this reliance agreement.',
    `reliance_scope` STRING COMMENT 'Defines the scope of oversight transferred to the reviewing IRB: full study oversight, specific procedures only, specific sites only, or amendments only.. Valid values are `full_study|specific_procedures|specific_sites|amendments_only`',
    `relying_institution_fwa_number` STRING COMMENT 'OHRP-issued Federal Wide Assurance number for the relying institution, confirming its commitment to the Common Rule and eligibility to enter into a reliance agreement.',
    `relying_institution_name` STRING COMMENT 'Full legal name of the institution that cedes IRB oversight to the reviewing IRB under this reliance agreement. For multi-site agreements, this may represent the primary relying institution.',
    `review_type` STRING COMMENT 'Category of IRB review applicable to the protocol under this reliance agreement: full board review, expedited review, exempt determination, or not human subjects research determination.. Valid values are `full_board|expedited|exempt|not_human_subjects`',
    `termination_date` DATE COMMENT 'Date on which the reliance agreement was formally terminated prior to its scheduled expiration date, if applicable.',
    `termination_reason` STRING COMMENT 'Reason for termination of the reliance agreement when status is terminated or expired. Captures whether termination was due to study completion, mutual agreement, IRB withdrawal, institution withdrawal, regulatory action, or sponsor termination.. Valid values are `study_completion|mutual_agreement|irb_withdrawal|institution_withdrawal|regulatory_action|sponsor_termination`',
    `tmf_section_reference` STRING COMMENT 'TMF Reference Model section code where the reliance agreement document is filed (e.g., 06.02 for IRB/IEC correspondence), supporting inspection readiness and eTMF completeness.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the IRB reliance agreement record, supporting audit trail requirements and change tracking per 21 CFR Part 11.',
    `veeva_vault_document_number` STRING COMMENT 'Document identifier in Veeva Vault eTMF where the executed reliance agreement and associated correspondence are archived, enabling direct TMF cross-reference.',
    CONSTRAINT pk_irb_reliance PRIMARY KEY(`irb_reliance_id`)
) COMMENT 'Records single-IRB reliance agreements and authorization agreements between reviewing IRBs and relying institutions under the Common Rule';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`compliance`.`training_plan` (
    `training_plan_id` BIGINT COMMENT 'Primary key for training_plan',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_capa. Business justification: Training plans can be initiated as part of a CAPA (training_required_flag on CAPA). The training_plan has capa_reference_number (STRING) which is a denormalized reference.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Training plans are often created to support specific SOPs. The training_plan has sop_reference_number (STRING) which is a denormalized reference to an SOP.',
    `org_unit_id` BIGINT COMMENT 'Identifier of the department or functional area responsible for owning and maintaining this training plan.',
    `primary_superseded_training_plan_id` BIGINT COMMENT 'Self-referencing FK on training_plan (superseded_training_plan_id)',
    `study_protocol_id` BIGINT COMMENT 'Identifier of the clinical study protocol to which this training plan is specifically linked, if study-specific.',
    `approval_date` DATE COMMENT 'Date on which the current version of the training plan was formally approved by the designated authority.',
    `approved_by` STRING COMMENT 'Name of the quality assurance or management authority who approved the current version of the training plan.',
    `assessment_method` STRING COMMENT 'Method used to evaluate trainee competency upon completion, such as written quiz, practical demonstration, direct observation, attestation, portfolio review, or interview.',
    `completion_deadline_days` BIGINT COMMENT 'Number of calendar days from assignment date within which the trainee must complete the training plan to remain compliant.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the training plan record was first created in the system, supporting audit trail requirements per 21 CFR Part 11.',
    `curriculum_description` STRING COMMENT 'Detailed narrative description of the training plan curriculum, including learning objectives, topics covered, and expected competency outcomes.',
    `document_management_reference` STRING COMMENT 'Unique identifier within MasterControl or the document management system where the training plan document is stored and version-controlled.',
    `effective_from_date` DATE COMMENT 'Date from which the training plan becomes effective and enforceable for assigned personnel.',
    `effective_until_date` DATE COMMENT 'Date on which the training plan expires or ceases to be valid. Nullable for open-ended plans.',
    `gcp_compliance_required` BOOLEAN COMMENT 'Indicates whether successful completion of this training plan is mandatory for GCP compliance certification of personnel.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this training plan is critical for regulatory inspection readiness and must be current for all assigned personnel.',
    `language` STRING COMMENT 'Primary language in which the training plan content is delivered, using ISO 639-1 language code format.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the training plan record, maintaining change audit trail for regulatory compliance.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic review of the training plan to ensure continued relevance and regulatory alignment.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the training plan, ensuring proactive compliance management.',
    `number_of_modules` BIGINT COMMENT 'Total count of individual training modules or courses included within this training plan.',
    `passing_score_percent` DECIMAL(5,2) COMMENT 'Minimum assessment score percentage required to successfully complete the training plan and achieve certification.',
    `plan_code` STRING COMMENT 'Externally-known unique business identifier code for the training plan, used for cross-referencing in MasterControl and regulatory submissions.',
    `plan_owner_name` STRING COMMENT 'Full name of the individual responsible for maintaining, reviewing, and approving the training plan content.',
    `plan_type` STRING COMMENT 'Classification of the training plan by its purpose or trigger, such as role-based competency, study-specific protocol training, SOP compliance, regulatory requirement, onboarding, or remedial/CAPA-driven training.',
    `recertification_interval_months` BIGINT COMMENT 'Number of months after which personnel must recertify or retake the training to maintain qualification and GCP compliance.',
    `regulatory_framework` STRING COMMENT 'Primary regulatory framework or authority that mandates this training plan (ICH GCP, FDA, EMA, PMDA, Health Canada, MHRA).',
    `retirement_date` DATE COMMENT 'Date on which the training plan was formally retired and is no longer assignable to personnel, though historical records are retained.',
    `retirement_reason` STRING COMMENT 'Business justification for retiring the training plan, such as superseded by new version, regulatory change, or process elimination.',
    `risk_level` STRING COMMENT 'Risk classification of the training plan based on the criticality of the associated process or role to patient safety and data integrity.',
    `sponsor_required` BOOLEAN COMMENT 'Indicates whether this training plan is mandated by a pharmaceutical or biotech sponsor as part of study delegation requirements.',
    `training_plan_status` STRING COMMENT 'Current lifecycle state of the training plan indicating whether it is in draft, actively assigned, suspended, retired, under review, or archived.',
    `target_audience` STRING COMMENT 'Description of the intended audience for this training plan, such as clinical research associates, data managers, principal investigators, or site coordinators.',
    `therapeutic_area` STRING COMMENT 'Clinical therapeutic area or disease indication to which the training plan is applicable (e.g., oncology, cardiology, neurology).',
    `title` STRING COMMENT 'Human-readable title or name of the training plan describing its scope and purpose.',
    `total_training_hours` DECIMAL(5,1) COMMENT 'Estimated total number of hours required to complete all modules and assessments within the training plan.',
    `training_modality` STRING COMMENT 'Delivery method for the training content, such as instructor-led classroom, e-learning, blended approach, self-study, on-the-job, or webinar.',
    `version_number` STRING COMMENT 'Version identifier of the training plan document, incremented upon each approved revision to maintain audit trail per GCP requirements.',
    CONSTRAINT pk_training_plan PRIMARY KEY(`training_plan_id`)
) COMMENT 'Master reference table for training_plan. Referenced by training_plan_id.';

ALTER SCHEMA `clinical_trials_ecm`.`compliance` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_ecm`.`compliance` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_checklist_template_id` FOREIGN KEY (`checklist_template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_follow_up_audit_id` FOREIGN KEY (`follow_up_audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_primary_audit_organization_id` FOREIGN KEY (`primary_audit_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `checklist_template_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Checklist Template ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Auditor ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `follow_up_audit_id` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Audit ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `primary_audit_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `actual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Audit End Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Audit Start Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `auditee_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `auditee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `capa_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `audit_category` SET TAGS ('dbx_value_regex' = 'internal|external|regulatory_inspection|for_cause|routine');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Audit Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `gcp_standard_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Standard Version');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Audit Location Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `location` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^AUD-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Audit Outcome');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'satisfactory|needs_improvement|unsatisfactory');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Audit Plan Version');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `plan_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Audit End Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Audit Start Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `report_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Report Issue Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `risk_priority_score` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Audit Priority Score');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Audit Risk Tier');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Audit Scope');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `summary` SET TAGS ('dbx_business_glossary_term' = 'Audit Summary');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Audit Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `tmf_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'routine|for_cause|pre_approval|post_approval');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_auditor_employee_id` FOREIGN KEY (`auditor_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_deviation_classification_id` FOREIGN KEY (`deviation_classification_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`deviation_classification`(`deviation_classification_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditor_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditor_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditor_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `deviation_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Deviation Classification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditee_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `auditee_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `capa_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Closure Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_description` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_reference_number` SET TAGS ('dbx_value_regex' = '^AF-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|pending_verification|closed|overdue');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `finding_title` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `ich_gcp_clause_reference` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation Good Clinical Practice (ICH GCP) Clause Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Identified Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `management_response` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `patient_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `prior_finding_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Audit Finding Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `prior_finding_reference_number` SET TAGS ('dbx_value_regex' = '^AF-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'Affected Process Area');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `qa_reviewer_comment` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Reviewer Comment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Management Response Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `response_received_date` SET TAGS ('dbx_business_glossary_term' = 'Management Response Received Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `sop_version` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Version');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Closure Verification Method');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`audit_finding` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'document_review|on_site_visit|remote_review|interview|system_audit');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_prior_finding_inspection_finding_id` FOREIGN KEY (`prior_finding_inspection_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_source_regulatory_inspection_id` FOREIGN KEY (`source_regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_finding_regulatory_inspection_id` FOREIGN KEY (`finding_regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `prior_finding_inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Finding ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `prior_finding_inspection_finding_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Closure Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'none|warning_letter|consent_decree|import_alert|clinical_hold');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_classification` SET TAGS ('dbx_value_regex' = 'critical|major|other');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_value_regex' = 'open|response_submitted|under_review|closed|escalated');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `gcp_principle_violated` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Principle Violated');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `inspector` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `inspector` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `protocol_deviation_related` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Related Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `repeat_finding` SET TAGS ('dbx_business_glossary_term' = 'Repeat Finding Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `response_adequacy_assessment` SET TAGS ('dbx_value_regex' = 'adequate|inadequate|partially_adequate|pending_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'process|training|system|communication|resource|oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Source Document');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'form_483|warning_letter|eir|gcp_inspection_report|establishment_inspection_report|other');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`inspection_finding` ALTER COLUMN `warning_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Warning Letter Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_primary_compliance_capa_approved_by_employee_id` FOREIGN KEY (`primary_compliance_capa_approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ADD CONSTRAINT `fk_compliance_compliance_capa_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `primary_compliance_capa_approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'CAPA Approved By ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `primary_compliance_capa_approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `primary_compliance_capa_approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `primary_compliance_capa_approved_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Actual Completion Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `capa_type` SET TAGS ('dbx_value_regex' = 'corrective|preventive|both');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `closure_justification` SET TAGS ('dbx_business_glossary_term' = 'CAPA Closure Justification');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `effectiveness_check_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `effectiveness_check_description` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Result');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_value_regex' = 'effective|partially_effective|not_effective|pending');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `gcp_impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `gcp_impact_assessment` SET TAGS ('dbx_value_regex' = 'critical|major|minor|no_impact');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Initiation Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'CAPA Priority');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `recurrence_flag` SET TAGS ('dbx_business_glossary_term' = 'CAPA Recurrence Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^CAPA-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `source_reference_code` SET TAGS ('dbx_business_glossary_term' = 'CAPA Source Reference ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'CAPA Source Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `compliance_capa_status` SET TAGS ('dbx_business_glossary_term' = 'CAPA Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `compliance_capa_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|closed|overdue|cancelled');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Target Completion Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'CAPA Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_capa` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ADD CONSTRAINT `fk_compliance_capa_action_item_capa_action_owner_employee_id` FOREIGN KEY (`capa_action_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ADD CONSTRAINT `fk_compliance_capa_action_item_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ADD CONSTRAINT `fk_compliance_capa_action_item_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ADD CONSTRAINT `fk_compliance_capa_action_item_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Action Item ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Owner ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_owner_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `action_item_number` SET TAGS ('dbx_business_glossary_term' = 'CAPA Action Item Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `action_item_number` SET TAGS ('dbx_value_regex' = '^CAPA-AI-[0-9]{4}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `action_item_status` SET TAGS ('dbx_business_glossary_term' = 'CAPA Action Item Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `action_item_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|completed|overdue|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `action_item_type` SET TAGS ('dbx_business_glossary_term' = 'CAPA Action Item Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Action Item Closed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Action Item Comments');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `capa_action_item_description` SET TAGS ('dbx_business_glossary_term' = 'Action Item Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `effectiveness_check_required` SET TAGS ('dbx_business_glossary_term' = 'Effectiveness Check Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `effectiveness_check_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_progress|effective|ineffective');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `evidence_description` SET TAGS ('dbx_business_glossary_term' = 'Completion Evidence Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `extension_justification` SET TAGS ('dbx_business_glossary_term' = 'Due Date Extension Justification');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `opened_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Action Item Opened Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Action Item Priority');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `regulatory_commitment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Action Item Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Action Item Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `verification_outcome` SET TAGS ('dbx_value_regex' = 'accepted|rejected|pending_revision');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`capa_action_item` ALTER COLUMN `verification_required` SET TAGS ('dbx_business_glossary_term' = 'Verification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_deviation_classification_id` FOREIGN KEY (`deviation_classification_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`deviation_classification`(`deviation_classification_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_ecm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Identifier');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Deviation Classification Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Detected By Personnel ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `estimand_id` SET TAGS ('dbx_business_glossary_term' = 'Estimand Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_lab_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Lab Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `audit_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|not_ready|in_progress|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'no_impact|potential_impact|confirmed_impact|unknown');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `detected_by` SET TAGS ('dbx_business_glossary_term' = 'Deviation Detection Method');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|important');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_ref_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_ref_number` SET TAGS ('dbx_value_regex' = '^PD-[A-Z0-9]{3,20}-[0-9]{4,10}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_value_regex' = 'open|under_review|resolved|closed|escalated|voided');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `discovery_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Discovery Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `ecrf_form_ref` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `include_in_csr_flag` SET TAGS ('dbx_business_glossary_term' = 'Include in Clinical Study Report (CSR) Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `irb_iec_reported_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Reported Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `irb_iec_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reporting Required');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Occurrence Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `pi_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notification Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_requirement_ref` SET TAGS ('dbx_business_glossary_term' = 'Protocol Requirement Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Reporting Required');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Reported Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `source_system_record_number` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `subject_excluded_from_pp_flag` SET TAGS ('dbx_business_glossary_term' = 'Subject Excluded from Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `subject_impact_assessment` SET TAGS ('dbx_value_regex' = 'no_impact|potential_impact|confirmed_impact|unknown');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`protocol_deviation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ADD CONSTRAINT `fk_compliance_deviation_classification_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ADD CONSTRAINT `fk_compliance_deviation_classification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ADD CONSTRAINT `fk_compliance_deviation_classification_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Deviation Classification Identifier');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `applicable_phase` SET TAGS ('dbx_business_glossary_term' = 'Applicable Clinical Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Classification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_business_glossary_term' = 'Classification Record Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_value_regex' = 'draft|active|retired|superseded');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `classification_version` SET TAGS ('dbx_business_glossary_term' = 'Classification Version Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `classification_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Classification Comments');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `csr_reporting_section` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Reporting Section');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Level');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_category` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|important_protocol_deviation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Subcategory');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_type_code` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_type_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_type_name` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `deviation_type_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Classification Effective Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `ema_guidance_reference` SET TAGS ('dbx_business_glossary_term' = 'European Medicines Agency (EMA) Guidance Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `fda_guidance_reference` SET TAGS ('dbx_business_glossary_term' = 'U.S. Food and Drug Administration (FDA) Guidance Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `frequency_threshold_count` SET TAGS ('dbx_business_glossary_term' = 'Deviation Frequency Threshold Count');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `gcp_principle_violated` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Principle Violated');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `ich_guidance_reference` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation (ICH) Guidance Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `inspection_readiness_notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Readiness Notes');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `is_blinding_sensitive` SET TAGS ('dbx_business_glossary_term' = 'Blinding Sensitive Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `itt_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Exclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `monitoring_escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `per_protocol_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Exclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `reporting_timeframe_days` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Timeframe (Days)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Classification Retirement Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Deviation Risk Score');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `sdtm_domain_code` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `sdtm_domain_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `sop_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Reference Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `sponsor_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `standard_description_template` SET TAGS ('dbx_business_glossary_term' = 'Standard Deviation Description Template');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Level');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `superseded_by_code` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Deviation Type Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`deviation_classification` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ADD CONSTRAINT `fk_compliance_compliance_sop_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ADD CONSTRAINT `fk_compliance_compliance_sop_superseded_sop_compliance_sop_id` FOREIGN KEY (`superseded_sop_compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ADD CONSTRAINT `fk_compliance_compliance_sop_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ADD CONSTRAINT `fk_compliance_compliance_sop_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` SET TAGS ('dbx_subdomain' = 'training_documentation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_sop_compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `applicable_roles` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Roles');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'SOP Approver Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `audit_finding_reference` SET TAGS ('dbx_business_glossary_term' = 'SOP Audit Finding Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `capa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `change_control_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Change Control Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'SOP Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `deviation_classification_relevance` SET TAGS ('dbx_business_glossary_term' = 'SOP Protocol Deviation Classification Relevance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `deviation_classification_relevance` SET TAGS ('dbx_value_regex' = 'critical|major|minor|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|retired|superseded');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'SOP|work_instruction|policy|guidance|template|form');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Effective Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `geographic_applicability` SET TAGS ('dbx_business_glossary_term' = 'SOP Geographic Applicability');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `inspection_readiness_flag` SET TAGS ('dbx_business_glossary_term' = 'SOP Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `mastercontrol_doc_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `owner_department` SET TAGS ('dbx_business_glossary_term' = 'SOP Owner Department');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `owner_role` SET TAGS ('dbx_business_glossary_term' = 'SOP Owner Role');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Process Area');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `purpose_description` SET TAGS ('dbx_business_glossary_term' = 'SOP Purpose Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `qms_workflow_stage` SET TAGS ('dbx_business_glossary_term' = 'Quality Management System (QMS) Workflow Stage');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `qms_workflow_stage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'SOP Regulatory Basis');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_value_regex' = 'GCP|GLP|GMP|GCP_GLP|GCP_GMP|GLP_GMP');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_references` SET TAGS ('dbx_business_glossary_term' = 'SOP Regulatory Reference Citations');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `revision_summary` SET TAGS ('dbx_business_glossary_term' = 'SOP Revision Summary');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'SOP Scope Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}-[A-Z]{2,10}-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `sox_applicable` SET TAGS ('dbx_business_glossary_term' = 'Sarbanes-Oxley Act (SOX) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Version Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `training_completion_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Completion Deadline (Days)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`compliance_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_electronic_signature_id` FOREIGN KEY (`electronic_signature_id`) REFERENCES `clinical_trials_ecm`.`document`.`signature`(`signature_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_sop_training_requirement_id` FOREIGN KEY (`sop_training_requirement_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`sop_training_requirement`(`sop_training_requirement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_trainee_employee_id` FOREIGN KEY (`trainee_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ADD CONSTRAINT `fk_compliance_sop_training_record_training_plan_id` FOREIGN KEY (`training_plan_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`training_plan`(`training_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` SET TAGS ('dbx_subdomain' = 'training_documentation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `sop_training_record_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `sop_training_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Training Requirement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainee_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Staff Member ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainee_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainee_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainee_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `assessment_passed` SET TAGS ('dbx_business_glossary_term' = 'Assessment Passed Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `assessment_score` SET TAGS ('dbx_business_glossary_term' = 'Training Assessment Score');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Training Attempt Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Training Record Comments');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Training Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `is_current_version_training` SET TAGS ('dbx_business_glossary_term' = 'Current Version Training Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `sop_category` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `sop_version` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Version');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `sop_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `source_record_number` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `staff_full_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `staff_full_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `staff_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Training Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_method` SET TAGS ('dbx_value_regex' = 'read_and_understand|classroom|e_learning|on_the_job_training|blended');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_record_number` SET TAGS ('dbx_value_regex' = '^TR-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_status` SET TAGS ('dbx_value_regex' = 'completed|overdue|waived|in_progress|not_started');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `training_type` SET TAGS ('dbx_value_regex' = 'initial|retraining|refresher|change_control');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_record` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Reason');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ADD CONSTRAINT `fk_compliance_sop_training_requirement_training_plan_id` FOREIGN KEY (`training_plan_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`training_plan`(`training_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` SET TAGS ('dbx_subdomain' = 'training_documentation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `sop_training_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Training Requirement ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Role ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Department ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `training_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Training Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `applicability_scope` SET TAGS ('dbx_value_regex' = 'global|study_specific|department_specific|role_specific|site_specific');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `capa_required_on_overdue` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required on Overdue Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `curriculum_code` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `gcp_applicable` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Training Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `is_study_participation_prerequisite` SET TAGS ('dbx_business_glossary_term' = 'Is Study Participation Prerequisite Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `max_attempts_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Attempts Allowed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Training Requirement Notes');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `passing_score_pct` SET TAGS ('dbx_business_glossary_term' = 'Passing Score Percentage');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `phase_applicability` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase Applicability');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `phase_applicability` SET TAGS ('dbx_value_regex' = 'phase_1|phase_2|phase_3|phase_4|all_phases');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `requirement_code` SET TAGS ('dbx_business_glossary_term' = 'Training Requirement Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `requirement_code` SET TAGS ('dbx_value_regex' = '^TRQ-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `requirement_status` SET TAGS ('dbx_business_glossary_term' = 'Training Requirement Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `requirement_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|draft|pending_approval');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `sop_version` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Version');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `sop_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `sponsor_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `tmf_documentation_required` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Documentation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `training_delivery_method` SET TAGS ('dbx_value_regex' = 'read_and_understand|instructor_led|elearning|on_the_job|assessment_only');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`sop_training_requirement` ALTER COLUMN `training_type` SET TAGS ('dbx_value_regex' = 'initial|annual|on_change|role_assignment|study_assignment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_identified_by_employee_id` FOREIGN KEY (`identified_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_ecm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_parent_event_quality_event_id` FOREIGN KEY (`parent_event_quality_event_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identified_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Identified By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identified_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identified_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identified_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `parent_event_quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Quality Event ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `specimen_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `affected_data_domain` SET TAGS ('dbx_business_glossary_term' = 'Affected Clinical Data Domain');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `affected_process` SET TAGS ('dbx_business_glossary_term' = 'Affected Business Process');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `error_count` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Error Count');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `error_rate` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Error Rate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_value_regex' = '^QE-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'open|under_review|pending_capa|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'data_quality_issue|process_non_compliance|system_failure|vendor_quality_issue|qc_review_finding');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identification_source` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Identification Source');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Identified Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `irb_iec_reportable` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `protocol_deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `qc_outcome` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Outcome');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `qc_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional_pass');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `regulatory_reportability` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportability Assessment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `regulatory_reportability` SET TAGS ('dbx_value_regex' = 'reportable|not_reportable|under_assessment');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Resolution Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By (QA Reviewer)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Sample Size');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Severity');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`quality_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_ecm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_ecm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_primary_risk_owner_employee_id` FOREIGN KEY (`primary_risk_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_ecm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `primary_risk_owner_employee_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `primary_risk_owner_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|active|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `capa_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `gcp_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Impact Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `inherent_risk_rating` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^RA-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `remediation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|overdue');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `residual_risk_rating` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `review_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency (Days)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `risk_acceptance_decision` SET TAGS ('dbx_value_regex' = 'accepted|not_accepted|conditionally_accepted');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `risk_category` SET TAGS ('dbx_value_regex' = 'data_integrity|patient_safety|regulatory_compliance|operational');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Scope');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'study|site|process|system|inspection_readiness');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`risk_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_ecm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_primary_commitment_regulatory_inspection_id` FOREIGN KEY (`primary_commitment_regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_primary_regulatory_approved_by_employee_id` FOREIGN KEY (`primary_regulatory_approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ADD CONSTRAINT `fk_compliance_regulatory_commitment_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Review Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Owner ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `primary_regulatory_approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `primary_regulatory_approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `primary_regulatory_approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `primary_regulatory_approved_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `authority_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Acknowledgement Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `authority_closure_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Closure Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `authority_closure_status` SET TAGS ('dbx_value_regex' = 'accepted|rejected|pending_review|additional_info_requested');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `closure_justification` SET TAGS ('dbx_business_glossary_term' = 'Commitment Closure Justification');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_description` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_reference_number` SET TAGS ('dbx_value_regex' = '^RC-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|completed|overdue|cancelled|pending_verification');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_title` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_value_regex' = 'effective|partially_effective|not_effective|pending');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `finding_category` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `finding_category` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `gcp_requirement_reference` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Requirement Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Initiation Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `originating_action_reference` SET TAGS ('dbx_business_glossary_term' = 'Originating Regulatory Action Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `originating_action_type` SET TAGS ('dbx_business_glossary_term' = 'Originating Regulatory Action Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `originating_action_type` SET TAGS ('dbx_value_regex' = 'inspection_finding|warning_letter|complete_response_letter|agency_query|untitled_letter|consent_decree');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Commitment Priority');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`regulatory_commitment` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_responsible_org_unit_id` FOREIGN KEY (`responsible_org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` SET TAGS ('dbx_subdomain' = 'quality_oversight');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Identifier');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `responsible_org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Org Unit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `applicable_study_phase` SET TAGS ('dbx_value_regex' = 'Phase_I|Phase_II|Phase_III|Phase_IV|All|Not_Applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `applicable_study_type` SET TAGS ('dbx_value_regex' = 'interventional|observational|expanded_access|compassionate_use|registry');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `cdisc_domain_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Domain Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `data_integrity_relevance` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `gcp_clause_reference` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Clause Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `inspection_readiness_priority` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `non_compliance_consequence` SET TAGS ('dbx_business_glossary_term' = 'Non-Compliance Consequence');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Obligation Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `reporting_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Reporting Timeline (Days)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle (Months)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'Obligation Source Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `source_type` SET TAGS ('dbx_value_regex' = 'regulatory|contractual|sponsor|internal_policy|guideline');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `sponsor_contractual_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `obligation_status` SET TAGS ('dbx_value_regex' = 'active|superseded|retired|draft|under_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `subject_safety_relevance` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `timeline_basis` SET TAGS ('dbx_value_regex' = 'calendar_days|business_days|from_awareness|from_event|from_database_lock|from_study_end');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Obligation Title');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `obligation_type` SET TAGS ('dbx_value_regex' = 'mandatory|conditional|recommended|prohibited');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`obligation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ADD CONSTRAINT `fk_compliance_ethics_committee_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ADD CONSTRAINT `fk_compliance_ethics_committee_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ADD CONSTRAINT `fk_compliance_ethics_committee_parent_ethics_committee_id` FOREIGN KEY (`parent_ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program Ethics Engagement - Clinical Program Id');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `parent_ethics_committee_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `accreditation_body` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Body Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `accreditation_status` SET TAGS ('dbx_value_regex' = 'accredited|provisional|expired|not_accredited|under_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `annual_renewal_required` SET TAGS ('dbx_business_glossary_term' = 'Annual Renewal Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_business_glossary_term' = 'Committee Chair Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_category` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_category` SET TAGS ('dbx_value_regex' = 'institutional|independent|central|national|regional');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_code` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_type` SET TAGS ('dbx_value_regex' = 'IRB|IEC|DSMB|DMC|Ethics_Board');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `ctms_record_number` SET TAGS ('dbx_business_glossary_term' = 'CTMS Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_end_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_start_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `expedited_review_available` SET TAGS ('dbx_business_glossary_term' = 'Expedited Review Available Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `fwa_number` SET TAGS ('dbx_business_glossary_term' = 'Federalwide Assurance (FWA) Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `fwa_number` SET TAGS ('dbx_value_regex' = '^FWAd{8}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'GDPR Applicability Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'HIPAA Applicability Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `icf_template_required` SET TAGS ('dbx_business_glossary_term' = 'ICF Template Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `institution_name` SET TAGS ('dbx_business_glossary_term' = 'Parent Institution Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `institution_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `is_central_irb` SET TAGS ('dbx_business_glossary_term' = 'Central IRB/IEC Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Language Code');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `mailing_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `mailing_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `meeting_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|bimonthly|quarterly|as_needed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `ethics_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Notes');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `primary_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Registration Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Governing Regulatory Authority');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_business_glossary_term' = 'Local PI Signature Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `ethics_committee_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|dissolved|pending_accreditation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_value_regex' = '^https?://.+');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_committee` ALTER COLUMN `veeva_vault_record_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_investigator_brochure_safety_id` FOREIGN KEY (`investigator_brochure_safety_id`) REFERENCES `clinical_trials_ecm`.`safety`.`investigator_brochure_safety`(`investigator_brochure_safety_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_parent_submission_ethics_submission_id` FOREIGN KEY (`parent_submission_ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_primary_amended_ethics_submission_id` FOREIGN KEY (`primary_amended_ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `investigator_brochure_safety_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `parent_submission_ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Ethics Submission ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `primary_amended_ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Amended Ethics Submission Id');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `primary_amended_ethics_submission_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Decision Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Decision Outcome');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'approved|conditionally_approved|rejected|deferred|withdrawn|not_required');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_reference_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Assigned Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `receipt_confirmed_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Receipt Confirmation Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Response Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `review_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Review Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|administrative');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `subject_enrollment_authorized` SET TAGS ('dbx_business_glossary_term' = 'Subject Enrollment Authorization Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_category` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|portal|email');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_number` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `tmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_submission` ALTER COLUMN `waiver_granted` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Granted Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_superseded_ethics_approval_id` FOREIGN KEY (`superseded_ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `superseded_ethics_approval_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_conditions` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Conditions');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Letter Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|central|local');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `conditions_met_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Conditions Met Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `ctms_record_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Decision Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `disapproval_reason` SET TAGS ('dbx_business_glossary_term' = 'Ethics Disapproval Reason');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Effective Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `gdpr_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `hipaa_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `icf_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `icf_version_approved` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Approved');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_country` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Country');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_registration_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Registration Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `quorum_met_flag` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Quorum Met Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `renewal_due_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Renewal Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `review_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'initial|amendment|renewal|safety_report|icf_revision|other');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `tmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_abstain_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote Abstain Count');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_against_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote Against Count');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_in_favor_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote In Favor Count');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_approval` ALTER COLUMN `waiver_of_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Informed Consent Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_document_icf_version_id` FOREIGN KEY (`document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_previous_continuing_review_id` FOREIGN KEY (`previous_continuing_review_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`continuing_review`(`continuing_review_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ADD CONSTRAINT `fk_compliance_continuing_review_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `previous_continuing_review_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `capa_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Decision Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `disapproval_reason` SET TAGS ('dbx_business_glossary_term' = 'Disapproval or Deferral Reason');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `icf_update_required` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Update Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `irb_iec_decision` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Decision');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `irb_iec_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|deferred|disapproved|suspended|terminated');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `next_review_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Continuing Review Due Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `protocol_deviation_count` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Count Since Last Review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `regulatory_authority_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Review Interval (Days)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Continuing Review Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Continuing Review Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'Continuing Review Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'annual|interim|expedited|full_board|administrative');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `risk_benefit_assessment` SET TAGS ('dbx_business_glossary_term' = 'Risk-Benefit Assessment Outcome');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `risk_benefit_assessment` SET TAGS ('dbx_value_regex' = 'favorable|unfavorable|requires_modification|inconclusive');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `study_status_at_review` SET TAGS ('dbx_business_glossary_term' = 'Study Status at Time of Review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `study_status_at_review` SET TAGS ('dbx_value_regex' = 'ongoing|enrollment_complete|follow_up_only|closed_to_enrollment|suspended|terminated');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `tmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`continuing_review` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ADD CONSTRAINT `fk_compliance_ethics_correspondence_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|deferred|disapproved|pending|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `communication_channel` SET TAGS ('dbx_value_regex' = 'email|postal_mail|fax|electronic_portal|hand_delivery');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `correspondence_category` SET TAGS ('dbx_value_regex' = 'safety|regulatory|protocol|consent|administrative');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `direction` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Direction');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `direction` SET TAGS ('dbx_value_regex' = 'outbound|inbound');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `irb_iec_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `recipient_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `sender_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `sender_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `sender_role` SET TAGS ('dbx_value_regex' = 'principal_investigator|sponsor_representative|cro_regulatory|medical_monitor|site_coordinator|irb_iec_secretary');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `subject_line` SET TAGS ('dbx_business_glossary_term' = 'Correspondence Subject Line');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'initial|continuing_review|amendment|safety_report|deviation_report|closure');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `tmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`ethics_correspondence` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_capacity_assessment_id` FOREIGN KEY (`capacity_assessment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`capacity_assessment`(`capacity_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_lar_representative_id` FOREIGN KEY (`lar_representative_id`) REFERENCES `clinical_trials_ecm`.`consent`.`lar_representative`(`lar_representative_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_parent_vulnerable_population_id` FOREIGN KEY (`parent_vulnerable_population_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`vulnerable_population`(`vulnerable_population_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ADD CONSTRAINT `fk_compliance_vulnerable_population_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `vulnerable_population_id` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `capacity_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Cognitive Capacity Assessment ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `capacity_assessment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `lar_representative_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `parent_vulnerable_population_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `additional_safeguards_description` SET TAGS ('dbx_business_glossary_term' = 'Additional Ethical Safeguards Description');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `assent_required` SET TAGS ('dbx_business_glossary_term' = 'Assent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Cognitive Capacity Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `capacity_assessment_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `dsmb_oversight_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Oversight Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `enhanced_monitoring_required` SET TAGS ('dbx_business_glossary_term' = 'Enhanced Monitoring Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `enrollment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Enrollment End Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `enrollment_justification` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Enrollment Justification');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `enrollment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Enrollment Start Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `gdpr_special_category_flag` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Special Category Data Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `hipaa_phi_flag` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Protected Health Information (PHI) Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `impairment_type` SET TAGS ('dbx_business_glossary_term' = 'Cognitive Impairment Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `independent_advocate_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `independent_advocate_required` SET TAGS ('dbx_business_glossary_term' = 'Independent Advocate Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `irb_iec_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `lar_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Legally Authorized Representative (LAR) Consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Enhanced Monitoring Frequency');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|quarterly|per_protocol|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `pediatric_age_band` SET TAGS ('dbx_value_regex' = 'neonate|infant|toddler|child|adolescent|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `pediatric_age_band` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `population_category` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `population_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Subcategory');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `pregnancy_trimester` SET TAGS ('dbx_value_regex' = 'first|second|third|postpartum|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `protection_status` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Protection Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `protection_status` SET TAGS ('dbx_value_regex' = 'active|under_review|closed|suspended|waived');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `record_number` SET TAGS ('dbx_business_glossary_term' = 'Vulnerable Population Record Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `record_number` SET TAGS ('dbx_value_regex' = '^VP-[A-Z0-9]{4,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `regulatory_authority_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `regulatory_authority_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notification Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `risk_benefit_assessment_documented` SET TAGS ('dbx_business_glossary_term' = 'Risk-Benefit Assessment Documented Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Research Risk Level');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'minimal|minor_increase_over_minimal|greater_than_minimal|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `safety_reporting_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Safety Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `tmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`vulnerable_population` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_reviewing_ethics_committee_id` FOREIGN KEY (`reviewing_ethics_committee_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ADD CONSTRAINT `fk_compliance_irb_reliance_superseded_irb_reliance_id` FOREIGN KEY (`superseded_irb_reliance_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`irb_reliance`(`irb_reliance_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` SET TAGS ('dbx_subdomain' = 'ethical_review');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `irb_reliance_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) Reliance Agreement ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `reviewing_ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewing Ethics Committee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `superseded_irb_reliance_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Status');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_execution|active|suspended|terminated|expired');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'single_irb_reliance|authorization_agreement|master_reliance|study_specific_reliance|nih_irb_reliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Amendment Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Effective Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Execution Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `exempt_category` SET TAGS ('dbx_business_glossary_term' = 'Common Rule Exempt Category');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Expiration Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `fda_regulated_flag` SET TAGS ('dbx_business_glossary_term' = 'FDA Regulated Research Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `gdpr_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `hipaa_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `initial_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB Initial Approval Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `inspection_ready_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `multi_site_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-Site Reliance Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `nih_funded_flag` SET TAGS ('dbx_business_glossary_term' = 'NIH Funded Study Flag');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Notes');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Contact Email');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `reliance_scope` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Scope');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `reliance_scope` SET TAGS ('dbx_value_regex' = 'full_study|specific_procedures|specific_sites|amendments_only');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `relying_institution_fwa_number` SET TAGS ('dbx_business_glossary_term' = 'Relying Institution Federal Wide Assurance (FWA) Number');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `relying_institution_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'IRB Review Type');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|not_human_subjects');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Termination Date');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Reliance Agreement Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'study_completion|mutual_agreement|irb_withdrawal|institution_withdrawal|regulatory_action|sponsor_termination');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `tmf_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`irb_reliance` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ADD CONSTRAINT `fk_compliance_training_plan_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ADD CONSTRAINT `fk_compliance_training_plan_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ADD CONSTRAINT `fk_compliance_training_plan_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ADD CONSTRAINT `fk_compliance_training_plan_primary_superseded_training_plan_id` FOREIGN KEY (`primary_superseded_training_plan_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`training_plan`(`training_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ADD CONSTRAINT `fk_compliance_training_plan_study_protocol_id` FOREIGN KEY (`study_protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` SET TAGS ('dbx_subdomain' = 'training_documentation');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `training_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Training Plan Identifier');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `primary_superseded_training_plan_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `document_management_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `plan_owner_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `plan_owner_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`compliance`.`training_plan` ALTER COLUMN `training_plan_status` SET TAGS ('dbx_business_glossary_term' = 'Status');
