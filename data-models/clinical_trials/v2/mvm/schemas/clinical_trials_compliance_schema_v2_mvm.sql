-- Schema for Domain: compliance | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:46

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`compliance` COMMENT 'Manages GCP quality assurance (QA), quality control (QC), internal and external audits, regulatory inspections, CAPA lifecycle, protocol deviation classifications, SOP compliance tracking, and audit readiness.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`audit` (
    `audit_id` BIGINT COMMENT 'Unique surrogate identifier for each GCP audit record within the compliance domain. Primary key for the audit data product sourced from MasterControl audit management module.',
    `compliance_sop_id` BIGINT COMMENT 'Reference to the standardized audit checklist template used during fieldwork, as configured in MasterControl. Templates are type-specific (site GCP, vendor, system) and version-controlled per SOP requirements.',
    `follow_up_audit_id` BIGINT COMMENT 'Reference to the subsequent follow-up audit record created to verify CAPA effectiveness. Populated when follow_up_required is True and the follow-up audit has been scheduled or completed.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: Audits target specific investigational sites for GCP compliance verification. Site-level audit scope tracking, audit scheduling, and regulatory inspection readiness require direct',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: GCP/GLP lab facility audits are a named compliance process. Sponsors and CROs conduct periodic audits of central labs to verify accreditation, data integrity, and GCP compliance.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: PI-specific audits assess investigator qualifications, delegation logs, and GCP training.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: GCP audits are scoped to a specific protocol version. Direct FK to protocol enables audit-readiness reports, TMF completeness checks, and regulatory inspection preparation tied to the exact',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this audit. Nullable for cross-study or enterprise-level audits (e.g., system or vendor audits not tied to a single protocol).',
    `actual_end_date` DATE COMMENT 'Calendar date on which audit fieldwork actually concluded. Used to compute actual audit duration and assess deviation from planned schedule.',
    `actual_start_date` DATE COMMENT 'Calendar date on which audit fieldwork actually commenced. Compared against planned_start_date to measure schedule adherence and audit program performance.',
    `audit_status` STRING COMMENT 'Current lifecycle state of the audit record within MasterControl: planned (scheduled, not yet started), in_progress (fieldwork underway), completed (report issued), cancelled (audit withdrawn), or on_hold (paused pending resolution).. Valid values are `planned|in_progress|completed|cancelled|on_hold`',
    `audit_type` STRING COMMENT 'Classification of regulatory inspection by trigger: routine (scheduled surveillance), for_cause (triggered by safety signal or complaint), pre_approval (NDA/BLA/MAA submission review), or post_approval (post-marketing commitment).. Valid values are `routine|for_cause|pre_approval|post_approval`',
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
    `summary` STRING COMMENT 'Executive summary narrative of the audit outcome, key findings, and overall GCP compliance assessment as documented in the final audit report. Supports audit readiness reviews and regulatory inspection preparation.',
    `title` STRING COMMENT 'Short, descriptive title of the audit as recorded in MasterControl (e.g., GCP Site Audit – Site 1042 – Protocol XYZ-001). Used in audit registers, dashboards, and TMF filing.',
    `tmf_reference_number` STRING COMMENT 'Document reference number assigned to the audit report and supporting documentation filed in the eTMF (Veeva Vault). Enables direct retrieval of audit artifacts during regulatory inspections per DIA TMF Reference Model.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the audit record in MasterControl. Required for audit trail integrity under 21 CFR Part 11 and ALCOA+ data governance standards.',
    CONSTRAINT pk_audit PRIMARY KEY(`audit_id`)
) COMMENT 'Master record for all internal and external GCP audits conducted across studies, sites, systems, and vendors. Captures audit type (system, process, vendor, site, TMF), scope, lead auditor, planned and actual dates, audit status, sponsoring organization';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` (
    `audit_finding_id` BIGINT COMMENT 'Unique surrogate identifier for each audit finding record in the compliance data product. Primary key for the audit_finding entity.',
    `audit_id` BIGINT COMMENT 'Reference to the parent audit record from which this finding was generated. Links the finding to its originating GCP audit event.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: GLP/GCP audits of bioanalytical laboratories specifically review assay validation and method performance. audit_finding has implicated_system as a text field.',
    `capa_id` BIGINT COMMENT 'Reference to the CAPA record triggered by this finding, if applicable. A finding may initiate a formal CAPA lifecycle in MasterControl.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: audit_finding.sop_reference is a free-text string referencing the SOP implicated in the finding.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Audit findings can implicate specific lab panels (e.g., unvalidated LBCAT coding, incorrect reference range source, missing CDISC mapping).',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: Audit findings often implicate specific PIs for protocol deviations, delegation failures, or GCP non-compliance.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Audit findings cite specific protocol version requirements (GCP audit reports reference protocol sections).',
    `specimen_shipment_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_shipment. Business justification: Audit findings frequently implicate specific specimen shipments (e.g., temperature excursion not reported, chain of custody documentation gap, IATA compliance failure).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this audit finding. Enables study-level quality metrics and regulatory traceability.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site implicated in this finding, if the finding is site-specific. Null for system-level or sponsor-level findings.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Audit findings cite specific TMF documents as evidence of non-compliance. GCP audit reports require traceable references to the exact TMF document reviewed.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.version. Business justification: Audit findings are raised against a specific document version (e.g., wrong SOP version in use, outdated protocol version at site).',
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
    `subject_count_affected` BIGINT COMMENT 'Number of study subjects potentially affected by the finding. Used to assess the scope and patient safety impact of the deficiency. Zero for system or process findings with no direct subject impact.',
    `target_closure_date` DATE COMMENT 'The planned date by which the finding is expected to be fully resolved and closed, as agreed between the QA team and the auditee. Distinct from response_due_date which covers only the management response.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this audit finding record. Tracks the last modification for change management, audit trail, and data lineage purposes.',
    `verification_method` STRING COMMENT 'Method used by the QA team to verify that the corrective action for this finding was effectively implemented prior to closure (e.g., document review, on-site visit, remote review, interview, system audit).. Valid values are `document_review|on_site_visit|remote_review|interview|system_audit`',
    CONSTRAINT pk_audit_finding PRIMARY KEY(`audit_finding_id`)
) COMMENT 'Transactional record of individual findings identified during an internal or sponsor-initiated GCP audit. Captures finding reference number, finding category (critical, major, minor, observation), finding description, ICH GCP clause reference, regulatory';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` (
    `inspection_finding_id` BIGINT COMMENT 'Unique surrogate identifier for each individual regulatory inspection finding record in the Databricks Silver Layer. Primary key for this transactional entity.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Health authority inspections (FDA, EMA) cite specific AE reporting failures as inspection findings.',
    `application_id` BIGINT COMMENT 'Foreign key to the regulatory inspection record',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: Regulatory inspection findings frequently target bioanalytical assays (FDA 483 observations on method validation, GLP compliance failures).',
    `capa_id` BIGINT COMMENT 'Reference to the CAPA record in MasterControl that was initiated to address this inspection finding. A single CAPA may address multiple findings; this field links the finding to its primary CAPA for lifecycle tracking.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: inspection_finding.sop_reference is a free-text string identifying the SOP implicated in the regulatory finding.',
    `deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Regulatory inspectors cite specific subject deviation records in inspection findings (e.g., enrollment of ineligible subjects, missed required assessments).',
    `eligibility_assessment_id` BIGINT COMMENT 'Foreign key linking to subject.eligibility_assessment. Business justification: Enrollment of ineligible subjects is among the most serious inspection findings. Regulatory inspectors cite specific eligibility assessment records as evidence.',
    `health_authority_id` BIGINT COMMENT 'Foreign key to the regulatory inspection that is the source of this finding; references regulatory.regulatory_inspection.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Regulatory inspection findings can implicate specific lab panels (e.g., FDA 483 observations about unvalidated safety panel methods, EMA findings on CDISC LBCAT coding).',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Regulatory inspection findings (FDA Form 483, EMA findings) cite specific lab results as evidence of GCP violations. inspection_finding has data_integrity_impact.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: Regulatory inspection findings cite PI responsibility under FDA Form 1572. PI disqualification decisions, warning letter responses, and investigator accountability tracking',
    `prior_finding_inspection_finding_id` BIGINT COMMENT 'Reference to the earlier inspection finding that this finding repeats or is related to. Populated only when repeat_finding is True. Enables lineage tracking of recurring deficiencies across inspection cycles.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: inspection_finding already carries a boolean flag `protocol_deviation_related` indicating that a regulatory inspection finding is linked to a protocol deviation.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Regulatory inspectors (FDA, EMA) cite specific protocol version requirements in inspection findings. inspection_finding has study_id but no protocol_id.',
    `serious_adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.serious_adverse_event. Business justification: FDA/EMA inspections frequently cite SAE reporting failures (missed deadlines, incorrect expectedness assessment) as critical findings.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: Regulatory inspection findings can implicate specific specimen collection events (e.g., FDA 483 citing collection outside protocol window, chain of custody documentation',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) affected by this inspection finding. Enables cross-domain linkage between compliance findings and study-level data.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the inspection finding was identified. Null if the finding applies at the sponsor or CRO level rather than a specific site.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Regulatory inspection findings (FDA Form 483, EMA findings) reference specific TMF documents as evidence.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.version. Business justification: Health authority inspection findings cite specific document versions as non-compliant (e.g., outdated ICF version used for consent, wrong protocol version at site).',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`capa` (
    `capa_id` BIGINT COMMENT 'Unique system-generated identifier for the CAPA record. Primary key for the CAPA lifecycle master record sourced from MasterControl CAPA module.',
    `audit_id` BIGINT COMMENT 'Identifier of the internal or external audit that generated the finding triggering this CAPA. Null if the CAPA was not initiated from an audit. Enables audit-to-CAPA traceability.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: CAPAs are raised against bioanalytical assays requiring method revalidation, reagent lot changes, or ISR protocol revisions.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: capa.sop_reference is a free-text string identifying the SOP associated with the CAPA. Replacing it with a FK to sop.sop_id enables structured linkage between CAPAs and the SOPs they address',
    `health_authority_id` BIGINT COMMENT 'Foreign key to the regulatory inspection record',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: CAPAs are raised against specific lab facilities following audit findings or quality events (e.g., LIMS validation gap, specimen handling SOP non-compliance).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: CAPAs triggered by protocol deviations or audit findings are protocol-version specific. compliance_capa has study_id but no protocol_id.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study associated with this CAPA. Links the CAPA to the relevant study protocol for study-level quality tracking and regulatory reporting.',
    `study_site_id` BIGINT COMMENT 'Identifier of the investigational site associated with this CAPA, if site-specific. Null for sponsor-level or cross-site CAPAs. Supports site-level quality performance analytics.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: CAPAs generate corrective documents (updated SOPs, revised procedures) that must be filed in the TMF. GCP requires CAPA documentation to be inspection-ready.',
    `actual_completion_date` DATE COMMENT 'Actual calendar date on which all corrective and preventive actions were completed and verified. Null until CAPA is closed. Used to calculate cycle time and on-time closure rate KPIs.',
    `approval_date` DATE COMMENT 'Date on which the CAPA plan was formally approved by the authorized QA approver in MasterControl. Marks the transition from initiation to active execution phase.',
    `capa_type` STRING COMMENT 'Indicates whether the action is corrective (addressing an existing non-conformance), preventive (addressing a potential non-conformance), or both. Drives workflow routing in MasterControl.. Valid values are `corrective|preventive|both`',
    `closure_justification` STRING COMMENT 'Narrative justification provided by the responsible owner and QA approver at the time of CAPA closure, summarizing evidence that all actions were completed and the root cause was resolved. Required for regulatory inspection readiness.',
    `compliance_capa_status` STRING COMMENT 'Current lifecycle state of the CAPA record. Drives workflow routing, escalation triggers, and regulatory reporting. Overdue is system-set when target completion date is passed without closure.. Valid values are `open|in_progress|closed|overdue|cancelled`',
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
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the quality issue underlying this CAPA had or could have had a direct impact on subject safety. Triggers expedited review and potential safety reporting obligations.',
    `target_completion_date` DATE COMMENT 'Planned date by which all corrective and preventive actions must be completed and the CAPA closed. Used for overdue status calculation, escalation triggers, and sponsor/regulatory reporting.',
    `title` STRING COMMENT 'Short, descriptive title summarizing the quality issue or finding that triggered the CAPA. Used for identification in dashboards, reports, and audit-readiness reviews.',
    `training_required_flag` BOOLEAN COMMENT 'Indicates whether the corrective or preventive action includes a mandatory training component. When True, triggers training assignment workflow in MasterControl training management module.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the CAPA record was last modified in the lakehouse silver layer. Supports change tracking, audit trail integrity, and 21 CFR Part 11 electronic records compliance.',
    CONSTRAINT pk_capa PRIMARY KEY(`capa_id`)
) COMMENT 'Master record for Corrective and Preventive Actions (CAPA) initiated in response to audit findings, inspection findings, protocol deviations, QC failures, or self-identified quality issues.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` (
    `protocol_deviation_id` BIGINT COMMENT 'Primary key for protocol_deviation',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Protocol deviations are classified by treatment arm in CSR deviation tables (ICH E3 Section 10.2). Arm-level deviation counts are required for per-arm safety and efficacy population analyses.',
    `capa_id` BIGINT COMMENT 'Reference to the associated CAPA record in MasterControl, if a corrective and preventive action has been initiated in response to this deviation.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Protocol deviations frequently trigger mandatory retraining as corrective action.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Dosing deviations (wrong dose level, wrong frequency, wrong regimen) are a major deviation category in pharmacovigilance and CSR deviation tables.',
    `eligibility_criterion_id` BIGINT COMMENT 'Foreign key linking to study.eligibility_criterion. Business justification: Eligibility criterion violations are a primary deviation category. ICH E3 CSR Section 10.2 requires listing deviations by the specific inclusion/exclusion criterion violated.',
    `pk_sample_id` BIGINT COMMENT 'Foreign key linking to laboratory.pk_sample. Business justification: PK sample collection outside the sampling window, incorrect processing, or missed collections constitute protocol deviations requiring formal documentation.',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: PI is accountable for protocol adherence per ICH-GCP. Deviation reporting, PI notification tracking, IRB/IEC reporting, and investigator performance assessment require direct PI',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Protocol deviations are violations of a specific protocol version. Direct FK to protocol enables deviation analysis by protocol version, supports CSR deviation summaries, and is required for',
    `protocol_lab_schedule_id` BIGINT COMMENT 'Foreign key linking to laboratory.protocol_lab_schedule. Business justification: Protocol deviations for missed or incorrect lab assessments are evaluated against the protocol lab schedule.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.estimand. Business justification: ICH E9(R1) requires deviations to be assessed against estimand strategies (intercurrent events, missing data).',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to supply.shipment. Business justification: Shipment failures (delayed delivery causing missed dose window, wrong kits shipped) are a documented category of protocol deviations.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: Specimen collection errors (wrong tube, wrong time, insufficient volume) are among the most frequent protocol deviation types.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this deviation occurred. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the protocol deviation was identified or occurred.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Protocol deviations must be documented in the TMF per ICH E6(R2). The deviation record references the specific TMF document (e.g., deviation report, PI notification letter).',
    `trial_subject_id` BIGINT COMMENT 'Reference to the study subject (patient) associated with this deviation, if applicable. Nullable for site-level or system-level deviations not tied to a specific subject.',
    `visit_id` BIGINT COMMENT 'Reference to the monitoring visit during which this deviation was identified, if applicable. Links to the monitoring visit record for traceability.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` (
    `compliance_sop_id` BIGINT COMMENT 'Unique surrogate identifier for the Standard Operating Procedure record in the quality management system. Primary key for the sop data product.',
    `superseded_sop_compliance_sop_id` BIGINT COMMENT 'Reference to the sop record that this version supersedes. Supports version lineage navigation and ensures the document control chain of custody is maintained for regulatory inspection.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`quality_event` (
    `quality_event_id` BIGINT COMMENT 'Unique system-generated identifier for the quality event record within the MasterControl quality management module. Serves as the primary key for all downstream references to this quality event.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Quality events are routinely triggered by AE reporting failures (late submission, incorrect coding, missing causality).',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: Quality events are raised against bioanalytical assays (e.g., QC sample failure, calibration curve rejection, ISR failure exceeding acceptance criteria).',
    `capa_id` BIGINT COMMENT 'Reference to the formal CAPA record initiated in MasterControl as a result of this quality event. Populated only when capa_required is True and the CAPA has been formally opened. Null until CAPA is initiated.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: quality_event.affected_sop_number is a free-text string identifying the SOP implicated in the quality event.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to subject.subject_consent. Business justification: Consent process failures (re-consent not obtained after protocol amendment, expired ICF version used) are a direct source of quality events.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Quality events arising from database lock failures (outstanding queries, failed QC checks, unauthorized lock) must reference the specific DBL event.',
    `deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Subject deviations are a primary source of quality events. quality_event already has protocol_deviation_id (compliance-domain classification) but not subject_deviation_id',
    `dsmb_recommendation_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_recommendation. Business justification: DSMB recommendations (stopping rules triggered, protocol amendments required, informed consent updates) generate quality events in the QMS for implementation tracking.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Quality events are raised against specific lab panels (e.g., reagent lot failure affecting entire panel, method drift detected across panel analytes).',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Quality events are frequently triggered by laboratory data issues — systematic result errors, instrument failures, reagent lot problems. quality_event has affected_data_domain.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Manufacturing batch failures, OOS results, and QP release holds are quality events under GMP.',
    `parent_event_quality_event_id` BIGINT COMMENT 'Reference to a prior quality event record that this event is a recurrence of, or a related parent event in a cluster of related quality issues. Populated when recurrence_flag is True or when events are grouped for systemic analysis.',
    `pk_sample_id` BIGINT COMMENT 'Foreign key linking to laboratory.pk_sample. Business justification: Quality events are raised against PK samples (e.g., insufficient volume, incorrect storage temperature, freeze-thaw cycle exceedance).',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: Quality events at sites require PI notification and response per GCP. PI accountability for data integrity, subject safety, and regulatory compliance tracking require direct PI',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: quality_event.deviation_reference_number is a free-text string referencing a related protocol deviation.',
    `reference_range_id` BIGINT COMMENT 'Foreign key linking to laboratory.reference_range. Business justification: Quality events are raised when reference ranges are found incorrect, outdated, or misapplied (e.g., wrong sex-specific range applied, CTCAE grading threshold error).',
    `sdv_review_id` BIGINT COMMENT 'Foreign key linking to subject.sdv_review. Business justification: SDV review outcomes with high error rates or low coverage percentages are a direct trigger for quality events under risk-based monitoring frameworks.',
    `serious_adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.serious_adverse_event. Business justification: Quality events are triggered by SAE reporting process failures (missed 15-day deadline, incorrect blinding status, incomplete narrative).',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.signal. Business justification: Safety signal detection triggers quality events in the QMS (e.g., signal requiring process review, risk minimization measure implementation).',
    `specimen_aliquot_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_aliquot. Business justification: Quality events are raised against specific aliquots (e.g., temperature excursion in long-term storage, volume below minimum threshold, stability expiry breach).',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: Specimen collection quality failures (hemolysis, lipemia, inadequate volume) are formal quality events requiring CAPA.',
    `specimen_shipment_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_shipment. Business justification: Temperature excursions during specimen shipment are a named quality event type in clinical trials. specimen_shipment has temperature_excursion_flag.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study affected by this quality event. Links the event to the specific protocol under which the quality issue was identified.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the quality event was identified or originated. Null if the event is study-wide or sponsor/CRO-level rather than site-specific.',
    `subject_consent_consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Quality events in clinical trials frequently arise from consent process failures (wrong ICF version used, consent obtained after procedures, missing signatures).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Quality events (e.g., data integrity issues, GCP violations) reference specific TMF documents as the affected or corrective record.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: Quality events in clinical trials are frequently triggered by specific visit-level anomalies (missed assessments, out-of-window visits, data entry errors at visit).',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` (
    `risk_assessment_id` BIGINT COMMENT 'Unique system-generated identifier for each quality risk assessment record within the compliance domain. Serves as the primary key for the risk_assessment data product.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Risk assessments can be scoped to audits (pre-audit risk assessment, post-audit risk evaluation).',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: Risk assessments are conducted for bioanalytical assays (e.g., LLOQ sensitivity risk for sparse PK sampling, ISR failure risk for immunogenicity assays).',
    `capa_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_capa. Business justification: Risk assessments with capa_required_flag=true should link to the resulting CAPA. A risk assessment that identifies unacceptable risk triggers a CAPA for remediation.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Risk assessments are conducted per SOPs and can assess SOP compliance or be governed by a specific SOP.',
    `depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: Depot qualification risk assessments evaluate cold chain capability, geographic coverage, and GMP compliance.',
    `health_authority_id` BIGINT COMMENT 'Foreign key to the regulatory inspection associated with this risk assessment.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: IMP-specific risk assessments cover stability risks, cold chain requirements, controlled substance handling, and biological product safety.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: IP-specific risk assessments (storage, handling, blinding integrity, controlled substance risk) are a GCP and GMP requirement.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Risk-based monitoring requires formal risk assessments of laboratory facilities as part of vendor qualification and ongoing oversight.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Risk assessments are scoped to specific lab panels in clinical operations (e.g., critical safety panels with high risk of missed collections, biomarker panels with complex stability',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: ICH E6 R2 risk-based monitoring requires that identified safety signals directly inform quality risk assessments. Risk management plans are updated when signals are detected.',
    `study_id` BIGINT COMMENT 'Foreign key linking to study.study. Business justification: ICH E6 R2 mandates study-level risk-based monitoring plans with documented risk assessments. risk_assessment has no study_id currently.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Risk assessments reference specific TMF documents as supporting evidence (e.g., protocol, IB, site agreements).',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` (
    `ethics_committee_id` BIGINT COMMENT 'Unique surrogate identifier for the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) record in the lakehouse silver layer.',
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
    `ethics_committee_status` STRING COMMENT 'Current operational lifecycle status of the ethics committee. active indicates the committee is fully operational and accepting submissions; suspended indicates temporary halt of operations; dissolved indicates permanent closure.. Valid values are `active|inactive|suspended|dissolved|pending_accreditation`',
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
    `submission_method` STRING COMMENT 'Preferred or required method for submitting protocol applications, amendments, and safety reports to this ethics committee: electronic (via online portal or eTMF), paper (physical documents), or hybrid (combination).. Valid values are `electronic|paper|hybrid`',
    `submission_portal_url` STRING COMMENT 'URL of the ethics committees electronic submission portal or online application system. Used by CRAs and regulatory affairs teams to route submissions and track application status.. Valid values are `^https?://.+`',
    `submission_strategy` STRING COMMENT 'The agreed or required approach for submitting protocol amendments, safety reports, and annual reviews to this ethics committee for this specific program. May differ by committee and program based on regulatory jurisdiction and committee preferences.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the ethics committee master record was last modified, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_record_number` STRING COMMENT 'Unique record identifier for this ethics committee in Veeva Vault eTMF, used to cross-reference TMF documents, ethics approval letters, and correspondence stored in the document management system.',
    CONSTRAINT pk_ethics_committee PRIMARY KEY(`ethics_committee_id`)
) COMMENT 'Master record for each IRB or IEC body providing ethical oversight for clinical trials, capturing committee name, type, jurisdiction, and accreditation status';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` (
    `ethics_submission_id` BIGINT COMMENT 'Unique surrogate identifier for each ethics submission record in the lakehouse silver layer. Primary key for this entity.',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) to which this submission is directed. Links to the ethics committee master record.',
    `icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: Ethics submissions formally submit specific ICF versions for IRB/IEC review. Linking ethics_submission to consent_icf_version normalizes the denormalized icf_version_submitted',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IB updates (especially SUSAR-triggered amendments) require IRB/IEC submission. ethics_submission already stores investigator_brochure_version as a denormalized text field.',
    `parent_submission_ethics_submission_id` BIGINT COMMENT 'Reference to the original or preceding ethics submission that this record amends or continues. Enables lineage tracking across the full submission history for a study.',
    `primary_amended_ethics_submission_id` BIGINT COMMENT 'Self-referencing FK on ethics_submission (amended_ethics_submission_id)',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) named on this ethics submission. The PI is the party responsible for the conduct of the study at the site.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Ethics submissions are submitted for a specific protocol version. ethics_submission has study_id and study_protocol_amendment_id but no direct protocol_id.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ethics submission is made. Links to the study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Ethics submissions are triggered by protocol amendments (substantial modifications requiring IRB/IEC resubmission).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this ethics submission. Applicable when the submission is site-specific (e.g., local IRB/IEC review).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Ethics submissions and their supporting documents must be filed in the TMF as essential documents. The plain-text tmf_document_reference is a denormalization.',
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
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this ethics submission record. Supports ALCOA+ data integrity principles and change tracking for GCP compliance.',
    `veeva_vault_document_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF for the submission package. Provides direct linkage to the source document management system for audit and inspection purposes.',
    `waiver_granted` BOOLEAN COMMENT 'Indicates whether the IRB or IEC granted a waiver of informed consent or waiver of documentation of informed consent as part of this submission decision.',
    CONSTRAINT pk_ethics_submission PRIMARY KEY(`ethics_submission_id`)
) COMMENT 'Tracks each formal submission package sent to an IRB or IEC for a specific study, including initial review, amendments, and continuing review submissions';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` (
    `ethics_approval_id` BIGINT COMMENT 'Unique surrogate identifier for the ethics approval record in the lakehouse silver layer. Primary key for this entity.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.country. Business justification: Ethics approvals are country-specific regulatory authorizations. ethics_approval has irb_iec_country as a denormalized text field but no FK to study.country.',
    `ethics_committee_id` BIGINT COMMENT 'Reference to the IRB or IEC body that issued this approval decision. Links to the ethics committee master record.',
    `ethics_submission_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_submission. Business justification: An ethics approval is the formal decision resulting from an ethics submission. Every approval originates from a specific submission package.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Ethics approvals are granted for a specific protocol version — a core GCP requirement. Direct FK to protocol enables protocol-version-level approval status tracking, supports site activation',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ethics approval was issued. Links the approval to the study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Ethics approvals are granted for specific protocol amendments. Direct FK to study_protocol_amendment enables amendment-level approval status tracking, supports site',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site for which this ethics approval applies. Null if the approval is a central/multi-site approval covering all sites.',
    `superseded_ethics_approval_id` BIGINT COMMENT 'Self-referencing FK on ethics_approval (superseded_ethics_approval_id)',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Ethics approval letters are essential TMF documents (ICH E6 R2). The ethics_approval.tmf_document_reference plain-text column is a denormalization of this FK.',
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
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this ethics approval record. Supports audit trail and data lineage requirements per ALCOA+ principles.',
    `veeva_vault_document_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF where the original signed ethics approval letter is archived. Supports 21 CFR Part 11 electronic records compliance.',
    `vote_abstain_count` BIGINT COMMENT 'Number of IRB/IEC board members who abstained from voting at the review meeting.',
    `vote_against_count` BIGINT COMMENT 'Number of IRB/IEC board members who voted against approval at the review meeting.',
    `vote_in_favor_count` BIGINT COMMENT 'Number of IRB/IEC board members who voted in favor of approval at the review meeting. Supports audit trail and quorum verification.',
    `vulnerable_population_flag` BOOLEAN COMMENT 'Indicates whether the approved study involves vulnerable populations (e.g., minors, pregnant women, prisoners, cognitively impaired individuals) requiring additional IRB/IEC safeguards.',
    `waiver_of_consent_flag` BOOLEAN COMMENT 'Indicates whether the IRB/IEC granted a waiver or alteration of the informed consent requirement as part of this approval.',
    CONSTRAINT pk_ethics_approval PRIMARY KEY(`ethics_approval_id`)
) COMMENT 'Records the formal approval decision issued by an IRB or IEC for a study protocol, ICF, or amendment including approval conditions and expiry dates';

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER SCHEMA `clinical_trials_mvm`.`compliance` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_mvm`.`compliance` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` SET TAGS ('dbx_subdomain' = 'audit_control');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Actual Completion Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Approval Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `capa_type` SET TAGS ('dbx_value_regex' = 'corrective|preventive|both');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `closure_justification` SET TAGS ('dbx_business_glossary_term' = 'CAPA Closure Justification');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `compliance_capa_status` SET TAGS ('dbx_business_glossary_term' = 'CAPA Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `compliance_capa_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|closed|overdue|cancelled');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `effectiveness_check_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `effectiveness_check_description` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_business_glossary_term' = 'CAPA Effectiveness Check Result');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_value_regex' = 'effective|partially_effective|not_effective|pending');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `gcp_impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Impact Assessment');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `gcp_impact_assessment` SET TAGS ('dbx_value_regex' = 'critical|major|minor|no_impact');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Initiation Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'CAPA Priority');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `recurrence_flag` SET TAGS ('dbx_business_glossary_term' = 'CAPA Recurrence Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^CAPA-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `source_reference_code` SET TAGS ('dbx_business_glossary_term' = 'CAPA Source Reference ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'CAPA Source Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'CAPA Target Completion Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'CAPA Title');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_follow_up_audit_id` FOREIGN KEY (`follow_up_audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` SET TAGS ('dbx_subdomain' = 'audit_control');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Checklist Template ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `follow_up_audit_id` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Audit ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `actual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Audit End Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Audit Start Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled|on_hold');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'routine|for_cause|pre_approval|post_approval');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `auditee_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `auditee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `capa_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Due Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `audit_category` SET TAGS ('dbx_value_regex' = 'internal|external|regulatory_inspection|for_cause|routine');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Audit Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `gcp_standard_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Standard Version');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Audit Location Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `location` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^AUD-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Audit Outcome');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'satisfactory|needs_improvement|unsatisfactory');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Audit Plan Version');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `plan_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `planned_end_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Audit End Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Audit Start Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `report_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Report Issue Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `risk_priority_score` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Audit Priority Score');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Audit Risk Tier');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Audit Scope');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `summary` SET TAGS ('dbx_business_glossary_term' = 'Audit Summary');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Audit Title');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `tmf_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` SET TAGS ('dbx_subdomain' = 'audit_control');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `specimen_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `auditee_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `auditee_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `capa_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Closure Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Category');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_description` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_reference_number` SET TAGS ('dbx_value_regex' = '^AF-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|pending_verification|closed|overdue');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `finding_title` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Title');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `ich_gcp_clause_reference` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation Good Clinical Practice (ICH GCP) Clause Reference');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Identified Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `management_response` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `patient_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `prior_finding_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Audit Finding Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `prior_finding_reference_number` SET TAGS ('dbx_value_regex' = '^AF-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'Affected Process Area');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `qa_reviewer_comment` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Reviewer Comment');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Management Response Due Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `response_received_date` SET TAGS ('dbx_business_glossary_term' = 'Management Response Received Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Closure Verification Method');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'document_review|on_site_visit|remote_review|interview|system_audit');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_prior_finding_inspection_finding_id` FOREIGN KEY (`prior_finding_inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` SET TAGS ('dbx_subdomain' = 'audit_control');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `eligibility_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `prior_finding_inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Finding ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `prior_finding_inspection_finding_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Closure Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'none|warning_letter|consent_decree|import_alert|clinical_hold');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_classification` SET TAGS ('dbx_value_regex' = 'critical|major|other');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_value_regex' = 'open|response_submitted|under_review|closed|escalated');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `gcp_principle_violated` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Principle Violated');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `inspector` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `inspector` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `repeat_finding` SET TAGS ('dbx_business_glossary_term' = 'Repeat Finding Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `response_adequacy_assessment` SET TAGS ('dbx_value_regex' = 'adequate|inadequate|partially_adequate|pending_review');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'process|training|system|communication|resource|oversight');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Source Document');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'form_483|warning_letter|eir|gcp_inspection_report|establishment_inspection_report|other');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_value_regex' = 'none|potential|confirmed');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ALTER COLUMN `warning_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Warning Letter Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` SET TAGS ('dbx_subdomain' = 'study_deviations');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Identifier');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `eligibility_criterion_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criterion Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `pk_sample_id` SET TAGS ('dbx_business_glossary_term' = 'Pk Sample Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_lab_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Lab Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Estimand Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `audit_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|not_ready|in_progress|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Assessment');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_value_regex' = 'no_impact|potential_impact|confirmed_impact|unknown');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `detected_by` SET TAGS ('dbx_business_glossary_term' = 'Deviation Detection Method');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Category');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|important');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_ref_number` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_ref_number` SET TAGS ('dbx_value_regex' = '^PD-[A-Z0-9]{3,20}-[0-9]{4,10}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_status` SET TAGS ('dbx_value_regex' = 'open|under_review|resolved|closed|escalated|voided');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `deviation_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `discovery_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Discovery Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `ecrf_form_ref` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form Reference');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `include_in_csr_flag` SET TAGS ('dbx_business_glossary_term' = 'Include in Clinical Study Report (CSR) Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `irb_iec_reported_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Reported Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `irb_iec_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reporting Required');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Occurrence Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `pi_notified_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Notification Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `protocol_requirement_ref` SET TAGS ('dbx_business_glossary_term' = 'Protocol Requirement Reference');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Reporting Required');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Reported Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Deviation Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `source_system_record_number` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `subject_excluded_from_pp_flag` SET TAGS ('dbx_business_glossary_term' = 'Subject Excluded from Per Protocol (PP) Population Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `subject_impact_assessment` SET TAGS ('dbx_value_regex' = 'no_impact|potential_impact|confirmed_impact|unknown');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ADD CONSTRAINT `fk_compliance_compliance_sop_superseded_sop_compliance_sop_id` FOREIGN KEY (`superseded_sop_compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` SET TAGS ('dbx_subdomain' = 'quality_management');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_sop_compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `applicable_roles` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Roles');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Approval Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'SOP Approver Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `audit_finding_reference` SET TAGS ('dbx_business_glossary_term' = 'SOP Audit Finding Reference');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `capa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `change_control_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Change Control Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'SOP Confidentiality Level');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `deviation_classification_relevance` SET TAGS ('dbx_business_glossary_term' = 'SOP Protocol Deviation Classification Relevance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `deviation_classification_relevance` SET TAGS ('dbx_value_regex' = 'critical|major|minor|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Category');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|retired|superseded');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'SOP|work_instruction|policy|guidance|template|form');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Effective Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `geographic_applicability` SET TAGS ('dbx_business_glossary_term' = 'SOP Geographic Applicability');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `inspection_readiness_flag` SET TAGS ('dbx_business_glossary_term' = 'SOP Inspection Readiness Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Language Code');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `mastercontrol_doc_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `owner_department` SET TAGS ('dbx_business_glossary_term' = 'SOP Owner Department');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `owner_role` SET TAGS ('dbx_business_glossary_term' = 'SOP Owner Role');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Process Area');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `purpose_description` SET TAGS ('dbx_business_glossary_term' = 'SOP Purpose Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `qms_workflow_stage` SET TAGS ('dbx_business_glossary_term' = 'Quality Management System (QMS) Workflow Stage');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `qms_workflow_stage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'SOP Regulatory Basis');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_value_regex' = 'GCP|GLP|GMP|GCP_GLP|GCP_GMP|GLP_GMP');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `regulatory_references` SET TAGS ('dbx_business_glossary_term' = 'SOP Regulatory Reference Citations');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Due Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `revision_summary` SET TAGS ('dbx_business_glossary_term' = 'SOP Revision Summary');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'SOP Scope Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}-[A-Z]{2,10}-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `sox_applicable` SET TAGS ('dbx_business_glossary_term' = 'Sarbanes-Oxley Act (SOX) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Version Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Title');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `training_completion_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Completion Deadline (Days)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`compliance_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_parent_event_quality_event_id` FOREIGN KEY (`parent_event_quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` SET TAGS ('dbx_subdomain' = 'quality_management');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `dsmb_recommendation_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Recommendation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `parent_event_quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Quality Event ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `pk_sample_id` SET TAGS ('dbx_business_glossary_term' = 'Pk Sample Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `reference_range_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `sdv_review_id` SET TAGS ('dbx_business_glossary_term' = 'Sdv Review Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `specimen_aliquot_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Aliquot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `specimen_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `subject_consent_consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `affected_data_domain` SET TAGS ('dbx_business_glossary_term' = 'Affected Clinical Data Domain');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `affected_process` SET TAGS ('dbx_business_glossary_term' = 'Affected Business Process');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `data_integrity_impact` SET TAGS ('dbx_business_glossary_term' = 'Data Integrity Impact Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `error_count` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Error Count');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `error_rate` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Error Rate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_value_regex' = '^QE-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'open|under_review|pending_capa|closed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'data_quality_issue|process_non_compliance|system_failure|vendor_quality_issue|qc_review_finding');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `identification_source` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Identification Source');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Identified Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `irb_iec_reportable` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Reportable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `protocol_deviation_category` SET TAGS ('dbx_value_regex' = 'major|minor|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `qc_outcome` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Outcome');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `qc_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional_pass');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `regulatory_reportability` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportability Assessment');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `regulatory_reportability` SET TAGS ('dbx_value_regex' = 'reportable|not_reportable|under_assessment');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Resolution Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Resolution Description');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By (QA Reviewer)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Sample Size');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Severity');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `subject_safety_impact` SET TAGS ('dbx_business_glossary_term' = 'Subject Safety Impact Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` SET TAGS ('dbx_subdomain' = 'study_deviations');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|active|closed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `capa_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `gcp_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Impact Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `inherent_risk_rating` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `mastercontrol_record_number` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^RA-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `remediation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|overdue');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `residual_risk_rating` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `review_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency (Days)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `risk_acceptance_decision` SET TAGS ('dbx_value_regex' = 'accepted|not_accepted|conditionally_accepted');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `risk_category` SET TAGS ('dbx_value_regex' = 'data_integrity|patient_safety|regulatory_compliance|operational');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Scope');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'study|site|process|system|inspection_readiness');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Title');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ADD CONSTRAINT `fk_compliance_ethics_committee_parent_ethics_committee_id` FOREIGN KEY (`parent_ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` SET TAGS ('dbx_subdomain' = 'ethics_oversight');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `parent_ethics_committee_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `accreditation_body` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Body Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `accreditation_status` SET TAGS ('dbx_value_regex' = 'accredited|provisional|expired|not_accredited|under_review');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `annual_renewal_required` SET TAGS ('dbx_business_glossary_term' = 'Annual Renewal Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_business_glossary_term' = 'Committee Chair Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `chair_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_category` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Category');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_category` SET TAGS ('dbx_value_regex' = 'institutional|independent|central|national|regional');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_code` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Code');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `committee_type` SET TAGS ('dbx_value_regex' = 'IRB|IEC|DSMB|DMC|Ethics_Board');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `ctms_record_number` SET TAGS ('dbx_business_glossary_term' = 'CTMS Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_end_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_start_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `engagement_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `ethics_committee_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|dissolved|pending_accreditation');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `expedited_review_available` SET TAGS ('dbx_business_glossary_term' = 'Expedited Review Available Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `fwa_number` SET TAGS ('dbx_business_glossary_term' = 'Federalwide Assurance (FWA) Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `fwa_number` SET TAGS ('dbx_value_regex' = '^FWAd{8}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'GDPR Applicability Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'HIPAA Applicability Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `icf_template_required` SET TAGS ('dbx_business_glossary_term' = 'ICF Template Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `institution_name` SET TAGS ('dbx_business_glossary_term' = 'Parent Institution Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `institution_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `is_central_irb` SET TAGS ('dbx_business_glossary_term' = 'Central IRB/IEC Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Language Code');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `mailing_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `mailing_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `meeting_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|bimonthly|quarterly|as_needed');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `ethics_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Notes');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `primary_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Registration Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Governing Regulatory Authority');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_business_glossary_term' = 'Local PI Signature Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `requires_local_pi_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `submission_portal_url` SET TAGS ('dbx_value_regex' = '^https?://.+');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ALTER COLUMN `veeva_vault_record_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_parent_submission_ethics_submission_id` FOREIGN KEY (`parent_submission_ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_primary_amended_ethics_submission_id` FOREIGN KEY (`primary_amended_ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` SET TAGS ('dbx_subdomain' = 'ethics_oversight');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Brochure Safety Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `parent_submission_ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Ethics Submission ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `primary_amended_ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Amended Ethics Submission Id');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `primary_amended_ethics_submission_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Decision Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Ethics Committee Decision Outcome');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'approved|conditionally_approved|rejected|deferred|withdrawn|not_required');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `irb_iec_reference_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Assigned Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `receipt_confirmed_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Receipt Confirmation Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Response Due Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `review_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Review Deadline Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `review_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|administrative');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `subject_enrollment_authorized` SET TAGS ('dbx_business_glossary_term' = 'Subject Enrollment Authorization Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_category` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Category');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|portal|email');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_number` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ALTER COLUMN `waiver_granted` SET TAGS ('dbx_business_glossary_term' = 'Consent Waiver Granted Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_superseded_ethics_approval_id` FOREIGN KEY (`superseded_ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` SET TAGS ('dbx_data_type' = 'Master');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` SET TAGS ('dbx_domain' = 'compliance');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` SET TAGS ('dbx_subdomain' = 'ethics_oversight');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `ethics_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `ethics_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `superseded_ethics_approval_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_conditions` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Conditions');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Letter Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Reference Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Status');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'full_board|expedited|exempt|central|local');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `conditions_met_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Conditions Met Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `ctms_record_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Record ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Decision Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `disapproval_reason` SET TAGS ('dbx_business_glossary_term' = 'Ethics Disapproval Reason');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Effective Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `gdpr_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `hipaa_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `icf_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Approval Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `icf_version_approved` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version Approved');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `irb_iec_registration_number` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Registration Number');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `quorum_met_flag` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Quorum Met Flag');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `renewal_due_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Renewal Due Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `review_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Review Meeting Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Date');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Ethics Submission Type');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'initial|amendment|renewal|safety_report|icf_revision|other');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_abstain_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote Abstain Count');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_against_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote Against Count');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `vote_in_favor_count` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Vote In Favor Count');

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ALTER COLUMN `waiver_of_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Informed Consent Flag');
