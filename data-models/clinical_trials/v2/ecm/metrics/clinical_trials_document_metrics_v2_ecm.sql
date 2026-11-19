-- Metric views for domain: document | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_access_log`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Document access audit KPIs tracking access patterns, anomalies, and regulatory inspection context"
  source: "`clinical_trials_ecm`.`document`.`access_log`"
  dimensions:
    - name: "Access Action"
      display_name: "Access Action"
      expr: access_action
      comment: "Type of access action performed (view, download, print, export)"
    - name: "Access Result"
      display_name: "Access Result"
      expr: access_result
      comment: "Result of the access attempt (success, denied, error)"
    - name: "Access Channel"
      display_name: "Access Channel"
      expr: access_channel
      comment: "Channel through which document was accessed (web, mobile, API)"
    - name: "Access Device Type"
      display_name: "Access Device Type"
      expr: access_device_type
      comment: "Type of device used for access (desktop, tablet, mobile)"
    - name: "User Role"
      display_name: "User Role"
      expr: user_role
      comment: "Role of the user accessing the document"
    - name: "User Organization"
      display_name: "User Organization"
      expr: user_organization
      comment: "Organization of the user accessing the document"
    - name: "Document Type"
      display_name: "Document Type"
      expr: document_type
      comment: "Type of document accessed"
    - name: "Document Status at Access"
      display_name: "Document Status at Access"
      expr: document_status_at_access
      comment: "Status of the document at the time of access"
    - name: "Document Confidentiality Level"
      display_name: "Document Confidentiality Level"
      expr: document_confidentiality_level
      comment: "Confidentiality classification of the accessed document"
    - name: "TMF Zone"
      display_name: "TMF Zone"
      expr: tmf_zone
      comment: "Trial Master File zone of the accessed document"
    - name: "Regulatory Authority"
      display_name: "Regulatory Authority"
      expr: regulatory_authority
      comment: "Regulatory authority context for the access"
    - name: "Access Year"
      display_name: "Access Year"
      expr: DATE_TRUNC('year', access_timestamp)
      comment: "Year of document access"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Access Month"
      display_name: "Access Month"
      expr: DATE_TRUNC('month', access_timestamp)
      comment: "Month of document access"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Anomalous Access"
      display_name: "Is Anomalous Access"
      expr: is_anomalous_access
      comment: "Boolean flag indicating whether access was flagged as anomalous"
    - name: "Inspection Context"
      display_name: "Inspection Context"
      expr: inspection_context
      comment: "Boolean flag indicating whether access occurred during regulatory inspection"
    - name: "Justification Required"
      display_name: "Justification Required"
      expr: justification_required
      comment: "Boolean flag indicating whether access justification was required"
    - name: "Justification Provided"
      display_name: "Justification Provided"
      expr: justification_provided
      comment: "Boolean flag indicating whether access justification was provided"
  measures:
    - name: "Total Access Events"
      display_name: "Total Access Events"
      expr: COUNT(1)
      comment: "Total number of document access events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Users"
      display_name: "Unique Users"
      expr: COUNT(DISTINCT employee_id)
      comment: "Number of unique users who accessed documents"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Documents Accessed"
      display_name: "Unique Documents Accessed"
      expr: COUNT(DISTINCT tmf_document_id)
      comment: "Number of unique documents accessed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Access Success Rate"
      display_name: "Access Success Rate"
      expr: SUM(CAST(CASE WHEN access_result = 'success' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of access attempts that were successful"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Anomalous Access Rate"
      display_name: "Anomalous Access Rate"
      expr: SUM(CAST(CASE WHEN is_anomalous_access = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of access events flagged as anomalous"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Download Count"
      display_name: "Download Count"
      expr: SUM(CAST(CASE WHEN access_action = 'download' THEN 1 ELSE 0 END AS INT))
      comment: "Total number of document download events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Print Count"
      display_name: "Print Count"
      expr: SUM(CAST(CASE WHEN access_action = 'print' THEN 1 ELSE 0 END AS INT))
      comment: "Total number of document print events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Print Copies"
      display_name: "Total Print Copies"
      expr: SUM(CAST(print_copy_count AS DOUBLE))
      comment: "Total number of printed copies across all print events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Inspection Context Access Rate"
      display_name: "Inspection Context Access Rate"
      expr: SUM(CAST(CASE WHEN inspection_context = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of access events occurring during regulatory inspection"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Justification Compliance Rate"
      display_name: "Justification Compliance Rate"
      expr: SUM(CAST(CASE WHEN justification_required = TRUE AND justification_provided = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN justification_required = TRUE THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of required justifications that were provided"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Access Per User"
      display_name: "Avg Access Per User"
      expr: COUNT(1) / NULLIF(COUNT(DISTINCT employee_id), 0)
      comment: "Average number of access events per unique user"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Access Per Document"
      display_name: "Avg Access Per Document"
      expr: COUNT(1) / NULLIF(COUNT(DISTINCT tmf_document_id), 0)
      comment: "Average number of access events per unique document"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_inspection_readiness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Inspection readiness KPIs tracking regulatory inspection preparedness, gap counts, and remediation status"
  source: "`clinical_trials_ecm`.`document`.`inspection_readiness`"
  dimensions:
    - name: "Readiness Status"
      display_name: "Readiness Status"
      expr: readiness_status
      comment: "Current inspection readiness status (ready, not ready, in progress)"
    - name: "Inspection Type"
      display_name: "Inspection Type"
      expr: inspection_type
      comment: "Type of regulatory inspection (routine, for-cause, pre-approval)"
    - name: "Inspecting Authority"
      display_name: "Inspecting Authority"
      expr: inspecting_authority
      comment: "Regulatory authority conducting the inspection (FDA, EMA, MHRA, etc.)"
    - name: "Inspection Outcome"
      display_name: "Inspection Outcome"
      expr: inspection_outcome
      comment: "Outcome of the inspection (NAI, VAI, OAI, pending)"
    - name: "TMF Scope"
      display_name: "TMF Scope"
      expr: tmf_scope
      comment: "Scope of TMF covered by readiness assessment"
    - name: "Tier"
      display_name: "Tier"
      expr: tier
      comment: "Priority tier for inspection readiness (Tier 1, Tier 2, Tier 3)"
    - name: "Notification Year"
      display_name: "Notification Year"
      expr: DATE_TRUNC('year', inspection_notification_date)
      comment: "Year of inspection notification"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Notification Month"
      display_name: "Notification Month"
      expr: DATE_TRUNC('month', inspection_notification_date)
      comment: "Month of inspection notification"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Boolean flag indicating whether corrective and preventive actions are required"
    - name: "Sponsor Notified"
      display_name: "Sponsor Notified"
      expr: sponsor_notified
      comment: "Boolean flag indicating whether sponsor has been notified of inspection"
  measures:
    - name: "Total Readiness Assessments"
      display_name: "Total Readiness Assessments"
      expr: COUNT(1)
      comment: "Total number of inspection readiness assessments performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Readiness Score"
      display_name: "Avg Readiness Score"
      expr: AVG(CAST(readiness_score AS DOUBLE))
      comment: "Average inspection readiness score across all assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Critical Gaps"
      display_name: "Total Critical Gaps"
      expr: SUM(CAST(critical_gaps_count AS DOUBLE))
      comment: "Total number of critical gaps identified across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Major Gaps"
      display_name: "Total Major Gaps"
      expr: SUM(CAST(major_gaps_count AS DOUBLE))
      comment: "Total number of major gaps identified across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Minor Gaps"
      display_name: "Total Minor Gaps"
      expr: SUM(CAST(minor_gaps_count AS DOUBLE))
      comment: "Total number of minor gaps identified across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Missing Documents"
      display_name: "Total Missing Documents"
      expr: SUM(CAST(missing_documents_count AS DOUBLE))
      comment: "Total number of missing documents identified across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Overdue Documents"
      display_name: "Total Overdue Documents"
      expr: SUM(CAST(overdue_documents_count AS DOUBLE))
      comment: "Total number of overdue documents identified across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Open Findings"
      display_name: "Total Open Findings"
      expr: SUM(CAST(open_findings_count AS DOUBLE))
      comment: "Total number of open inspection findings across all readiness assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Gap Rate"
      display_name: "Critical Gap Rate"
      expr: SUM(CAST(critical_gaps_count AS DOUBLE)) / NULLIF(SUM(CAST(critical_gaps_count AS DOUBLE)) + SUM(CAST(major_gaps_count AS DOUBLE)) + SUM(CAST(minor_gaps_count AS DOUBLE)), 0)
      comment: "Percentage of critical gaps relative to total gaps identified"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required Rate"
      expr: SUM(CAST(CASE WHEN capa_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of readiness assessments requiring corrective and preventive actions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "NAI Outcome Rate"
      display_name: "NAI Outcome Rate"
      expr: SUM(CAST(CASE WHEN inspection_outcome = 'NAI' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN inspection_outcome IS NOT NULL AND inspection_outcome != 'pending' THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of completed inspections with No Action Indicated outcome"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Inspection"
      display_name: "Avg Days to Inspection"
      expr: AVG(DATEDIFF(actual_inspection_start_date, inspection_notification_date))
      comment: "Average number of days between inspection notification and actual inspection start"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_regulatory_binder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory submission binder KPIs tracking completeness, submission timelines, and agency action outcomes"
  source: "`clinical_trials_ecm`.`document`.`regulatory_binder`"
  dimensions:
    - name: "Binder Status"
      display_name: "Binder Status"
      expr: binder_status
      comment: "Current status of the regulatory binder (draft, in review, submitted, approved)"
    - name: "Binder Type"
      display_name: "Binder Type"
      expr: binder_type
      comment: "Type of regulatory binder (IND, NDA, BLA, MAA, CTA)"
    - name: "Target Agency"
      display_name: "Target Agency"
      expr: target_agency
      comment: "Regulatory agency targeted for submission (FDA, EMA, PMDA, etc.)"
    - name: "Submission Category"
      display_name: "Submission Category"
      expr: submission_category
      comment: "Category of regulatory submission (clinical, CMC, nonclinical)"
    - name: "CTD Module"
      display_name: "CTD Module"
      expr: ctd_module
      comment: "Common Technical Document module (Module 1-5)"
    - name: "Review Pathway"
      display_name: "Review Pathway"
      expr: review_pathway
      comment: "Regulatory review pathway (standard, priority, accelerated, breakthrough)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area for the regulatory submission"
    - name: "Agency Action Type"
      display_name: "Agency Action Type"
      expr: agency_action_type
      comment: "Type of agency action taken (approval, complete response, information request)"
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Year of regulatory submission"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month of regulatory submission"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is eCTD Format"
      display_name: "Is eCTD Format"
      expr: is_ectd_format
      comment: "Boolean flag indicating whether submission is in electronic Common Technical Document format"
    - name: "Is Inspection Ready"
      display_name: "Is Inspection Ready"
      expr: is_inspection_ready
      comment: "Boolean flag indicating whether binder meets inspection readiness criteria"
  measures:
    - name: "Total Binders"
      display_name: "Total Binders"
      expr: COUNT(1)
      comment: "Total number of regulatory binders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submitted Binders"
      display_name: "Submitted Binders"
      expr: SUM(CAST(CASE WHEN submission_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Total number of binders that have been submitted to regulatory agencies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Binders"
      display_name: "Approved Binders"
      expr: SUM(CAST(CASE WHEN approval_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Total number of binders that have received regulatory approval"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Completeness Pct"
      display_name: "Avg Completeness %"
      expr: AVG(CAST(completeness_percentage AS DOUBLE))
      comment: "Average completeness percentage across all regulatory binders"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Document Count"
      display_name: "Total Document Count"
      expr: SUM(CAST(document_count AS DOUBLE))
      comment: "Total number of documents across all regulatory binders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Documents Per Binder"
      display_name: "Avg Documents Per Binder"
      expr: AVG(CAST(document_count AS DOUBLE))
      comment: "Average number of documents per regulatory binder"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: SUM(CAST(CASE WHEN approval_date IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN submission_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of submitted binders that received regulatory approval"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Submission"
      display_name: "Avg Days to Submission"
      expr: AVG(DATEDIFF(submission_date, created_timestamp))
      comment: "Average number of days from binder creation to regulatory submission"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to Approval"
      display_name: "Avg Days to Approval"
      expr: AVG(DATEDIFF(approval_date, submission_date))
      comment: "Average number of days from submission to regulatory approval"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "eCTD Adoption Rate"
      display_name: "eCTD Adoption Rate"
      expr: SUM(CAST(CASE WHEN is_ectd_format = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of binders using electronic Common Technical Document format"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Inspection Ready Rate"
      display_name: "Inspection Ready Rate"
      expr: SUM(CAST(CASE WHEN is_inspection_ready = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of binders that meet inspection readiness criteria"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "On Time Submission Rate"
      display_name: "On Time Submission Rate"
      expr: SUM(CAST(CASE WHEN submission_date <= planned_submission_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN planned_submission_date IS NOT NULL AND submission_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of binders submitted on or before planned submission date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_signature`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Electronic signature KPIs tracking signature completion rates, cycle times, and regulatory compliance"
  source: "`clinical_trials_ecm`.`document`.`signature`"
  dimensions:
    - name: "Signature Status"
      display_name: "Signature Status"
      expr: signature_status
      comment: "Current status of the electronic signature (pending, signed, voided, expired)"
    - name: "Signature Type"
      display_name: "Signature Type"
      expr: signature_type
      comment: "Type of electronic signature (approval, review, acknowledgement, consent)"
    - name: "Signature Method"
      display_name: "Signature Method"
      expr: method
      comment: "Method used for electronic signature (digital certificate, biometric, password)"
    - name: "Signature Meaning"
      display_name: "Signature Meaning"
      expr: meaning
      comment: "Meaning or purpose of the signature (authorship, review, approval)"
    - name: "Signer Role"
      display_name: "Signer Role"
      expr: signer_role
      comment: "Role of the person signing the document"
    - name: "Signer Organization"
      display_name: "Signer Organization"
      expr: signer_organization
      comment: "Organization of the person signing the document"
    - name: "TMF Zone"
      display_name: "TMF Zone"
      expr: tmf_zone
      comment: "Trial Master File zone for the signed document"
    - name: "Workflow Step Name"
      display_name: "Workflow Step Name"
      expr: workflow_step_name
      comment: "Name of the workflow step requiring signature"
    - name: "Requested Year"
      display_name: "Requested Year"
      expr: DATE_TRUNC('year', requested_timestamp)
      comment: "Year the signature was requested"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Requested Month"
      display_name: "Requested Month"
      expr: DATE_TRUNC('month', requested_timestamp)
      comment: "Month the signature was requested"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Inspection Readiness"
      display_name: "Inspection Readiness"
      expr: inspection_readiness_flag
      comment: "Boolean flag indicating whether signed document meets inspection readiness criteria"
    - name: "Regulatory Submission Applicable"
      display_name: "Regulatory Submission Applicable"
      expr: is_regulatory_submission_applicable
      comment: "Boolean flag indicating whether signature is for regulatory submission document"
  measures:
    - name: "Total Signature Requests"
      display_name: "Total Signature Requests"
      expr: COUNT(1)
      comment: "Total number of electronic signature requests"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Signed Count"
      display_name: "Signed Count"
      expr: SUM(CAST(CASE WHEN signature_status = 'signed' THEN 1 ELSE 0 END AS INT))
      comment: "Total number of completed signatures"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Signature Completion Rate"
      display_name: "Signature Completion Rate"
      expr: SUM(CAST(CASE WHEN signature_status = 'signed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of signature requests that have been completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Signature Cycle Time Days"
      display_name: "Avg Signature Cycle Time (Days)"
      expr: AVG(DATEDIFF(signed_timestamp, requested_timestamp))
      comment: "Average number of days from signature request to completion"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Voided Signature Rate"
      display_name: "Voided Signature Rate"
      expr: SUM(CAST(CASE WHEN signature_status = 'voided' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of signatures that have been voided"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Expired Signature Rate"
      display_name: "Expired Signature Rate"
      expr: SUM(CAST(CASE WHEN signature_status = 'expired' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of signature requests that expired before completion"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reminder Sent"
      display_name: "Total Reminders Sent"
      expr: SUM(CAST(reminder_sent_count AS DOUBLE))
      comment: "Total number of signature reminders sent across all requests"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Reminders Per Request"
      display_name: "Avg Reminders Per Request"
      expr: AVG(CAST(reminder_sent_count AS DOUBLE))
      comment: "Average number of reminders sent per signature request"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Overdue Signature Rate"
      display_name: "Overdue Signature Rate"
      expr: SUM(CAST(CASE WHEN signature_status = 'pending' AND due_date < CURRENT_DATE THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN signature_status = 'pending' THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of pending signatures that are past their due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Submission Signature Rate"
      display_name: "Regulatory Submission Signature Rate"
      expr: SUM(CAST(CASE WHEN is_regulatory_submission_applicable = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of signatures applicable to regulatory submissions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_tmf_completeness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Trial Master File completeness KPIs tracking inspection readiness, artifact filing rates, and zone-level completeness across studies and sites"
  source: "`clinical_trials_ecm`.`document`.`tmf_completeness`"
  parameters:
    - name: p_target_completeness_pct
      data_type: DECIMAL
      default: 95.0
  dimensions:
    - name: "Assessment Type"
      display_name: "Assessment Type"
      expr: assessment_type
      comment: "Type of TMF completeness assessment (scheduled, ad-hoc, pre-inspection)"
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Current status of the completeness assessment"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: study_phase
      comment: "Clinical study phase at time of assessment"
    - name: "Inspection Readiness Risk"
      display_name: "Inspection Readiness Risk"
      expr: inspection_readiness_risk
      comment: "Risk level for inspection readiness (low, medium, high, critical)"
    - name: "TMF Scope"
      display_name: "TMF Scope"
      expr: tmf_scope
      comment: "Scope of TMF assessment (study-level, site-level, global)"
    - name: "Completeness Trend"
      display_name: "Completeness Trend"
      expr: completeness_trend
      comment: "Trend direction of completeness over time (improving, declining, stable)"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of completeness assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter of completeness assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of completeness assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Inspection Ready"
      display_name: "Is Inspection Ready"
      expr: is_inspection_ready
      comment: "Boolean flag indicating whether TMF meets inspection readiness criteria"
    - name: "Remediation Required"
      display_name: "Remediation Required"
      expr: remediation_action_required
      comment: "Boolean flag indicating whether remediation actions are required"
  measures:
    - name: "Total Assessments"
      display_name: "Total Assessments"
      expr: COUNT(1)
      comment: "Total number of TMF completeness assessments performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Completeness Pct"
      display_name: "Avg Overall Completeness %"
      expr: AVG(CAST(overall_completeness_pct AS DOUBLE))
      comment: "Average overall TMF completeness percentage across all assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Expected Artifacts"
      display_name: "Total Expected Artifacts"
      expr: SUM(CAST(expected_artifact_count AS DOUBLE))
      comment: "Total number of expected TMF artifacts across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Filed Artifacts"
      display_name: "Total Filed Artifacts"
      expr: SUM(CAST(filed_artifact_count AS DOUBLE))
      comment: "Total number of filed TMF artifacts across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Missing Artifacts"
      display_name: "Total Missing Artifacts"
      expr: SUM(CAST(missing_artifact_count AS DOUBLE))
      comment: "Total number of missing TMF artifacts across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Overdue Artifacts"
      display_name: "Total Overdue Artifacts"
      expr: SUM(CAST(overdue_artifact_count AS DOUBLE))
      comment: "Total number of overdue TMF artifacts across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Critical Gaps"
      display_name: "Total Critical Gaps"
      expr: SUM(CAST(critical_document_gap_count AS DOUBLE))
      comment: "Total number of critical document gaps identified across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Filing Rate"
      display_name: "Filing Rate"
      expr: SUM(CAST(filed_artifact_count AS DOUBLE)) / NULLIF(SUM(CAST(expected_artifact_count AS DOUBLE)), 0)
      comment: "Overall filing rate calculated as filed artifacts divided by expected artifacts"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Inspection Ready Rate"
      display_name: "Inspection Ready Rate"
      expr: SUM(CAST(CASE WHEN is_inspection_ready = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of assessments that meet inspection readiness criteria"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Zone 1 Completeness Pct"
      display_name: "Avg Zone 1 Completeness %"
      expr: AVG(CAST(zone_1_completeness_pct AS DOUBLE))
      comment: "Average completeness percentage for TMF Zone 1 (Trial Management)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Zone 2 Completeness Pct"
      display_name: "Avg Zone 2 Completeness %"
      expr: AVG(CAST(zone_2_completeness_pct AS DOUBLE))
      comment: "Average completeness percentage for TMF Zone 2 (Central Trial Documents)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Zone 3 Completeness Pct"
      display_name: "Avg Zone 3 Completeness %"
      expr: AVG(CAST(zone_3_completeness_pct AS DOUBLE))
      comment: "Average completeness percentage for TMF Zone 3 (Regulatory)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Zone 4 Completeness Pct"
      display_name: "Avg Zone 4 Completeness %"
      expr: AVG(CAST(zone_4_completeness_pct AS DOUBLE))
      comment: "Average completeness percentage for TMF Zone 4 (Ethics Committee/IRB)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Zone 5 Completeness Pct"
      display_name: "Avg Zone 5 Completeness %"
      expr: AVG(CAST(zone_5_completeness_pct AS DOUBLE))
      comment: "Average completeness percentage for TMF Zone 5 (Site Management)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Remediation Required Rate"
      display_name: "Remediation Required Rate"
      expr: SUM(CAST(CASE WHEN remediation_action_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of assessments requiring remediation actions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`document_workflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Document workflow KPIs tracking approval cycle times, rejection rates, SLA compliance, and workflow efficiency"
  source: "`clinical_trials_ecm`.`document`.`workflow`"
  dimensions:
    - name: "Workflow Type"
      display_name: "Workflow Type"
      expr: workflow_type
      comment: "Type of document workflow (approval, review, distribution, archival)"
    - name: "Workflow Status"
      display_name: "Workflow Status"
      expr: workflow_status
      comment: "Current status of the workflow (in progress, completed, rejected, cancelled)"
    - name: "Document Type"
      display_name: "Document Type"
      expr: document_type
      comment: "Type of document being processed in the workflow"
    - name: "Priority Level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level of the workflow (low, medium, high, critical)"
    - name: "TMF Zone"
      display_name: "TMF Zone"
      expr: tmf_zone
      comment: "Trial Master File zone for the document"
    - name: "Current Step Name"
      display_name: "Current Step Name"
      expr: current_step_name
      comment: "Name of the current workflow step"
    - name: "Step Assignee Role"
      display_name: "Step Assignee Role"
      expr: step_assignee_role
      comment: "Role of the person assigned to the current workflow step"
    - name: "Initiated Year"
      display_name: "Initiated Year"
      expr: DATE_TRUNC('year', initiated_timestamp)
      comment: "Year the workflow was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Initiated Month"
      display_name: "Initiated Month"
      expr: DATE_TRUNC('month', initiated_timestamp)
      comment: "Month the workflow was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "GCP Critical Document"
      display_name: "GCP Critical Document"
      expr: gcp_critical_document_flag
      comment: "Boolean flag indicating whether document is GCP-critical"
    - name: "Inspection Readiness"
      display_name: "Inspection Readiness"
      expr: inspection_readiness_flag
      comment: "Boolean flag indicating whether document meets inspection readiness criteria"
    - name: "Regulatory Submission"
      display_name: "Regulatory Submission"
      expr: regulatory_submission_flag
      comment: "Boolean flag indicating whether document is part of regulatory submission"
    - name: "SLA Breach"
      display_name: "SLA Breach"
      expr: sla_breach_indicator
      comment: "Boolean flag indicating whether workflow has breached SLA"
    - name: "Escalation Flag"
      display_name: "Escalation Flag"
      expr: escalation_flag
      comment: "Boolean flag indicating whether workflow has been escalated"
  measures:
    - name: "Total Workflows"
      display_name: "Total Workflows"
      expr: COUNT(1)
      comment: "Total number of document workflows"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Workflows"
      display_name: "Completed Workflows"
      expr: SUM(CAST(CASE WHEN workflow_status = 'completed' THEN 1 ELSE 0 END AS INT))
      comment: "Total number of completed workflows"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Cycle Time Days"
      display_name: "Avg Cycle Time (Days)"
      expr: AVG(DATEDIFF(actual_completion_date, initiated_timestamp))
      comment: "Average number of days from workflow initiation to completion"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Rejections"
      display_name: "Total Rejections"
      expr: SUM(CAST(rejection_count AS DOUBLE))
      comment: "Total number of workflow rejections across all workflows"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rejection Rate"
      display_name: "Rejection Rate"
      expr: SUM(CAST(CASE WHEN rejection_count > 0 THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of workflows that experienced at least one rejection"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SLA Breach Rate"
      display_name: "SLA Breach Rate"
      expr: SUM(CAST(CASE WHEN sla_breach_indicator = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of workflows that breached service level agreement"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Escalation Rate"
      expr: SUM(CAST(CASE WHEN escalation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of workflows that required escalation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Completion Rate"
      display_name: "Completion Rate"
      expr: SUM(CAST(CASE WHEN workflow_status = 'completed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of workflows that have been completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Steps Per Workflow"
      display_name: "Avg Steps Per Workflow"
      expr: AVG(CAST(total_steps AS DOUBLE))
      comment: "Average number of steps per workflow"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Current Step Sequence"
      display_name: "Avg Current Step Sequence"
      expr: AVG(CAST(current_step_sequence AS DOUBLE))
      comment: "Average current step sequence number across active workflows"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Workflow Progress Rate"
      display_name: "Workflow Progress Rate"
      expr: AVG(CAST(current_step_sequence AS DOUBLE) / NULLIF(CAST(total_steps AS DOUBLE), 0))
      comment: "Average progress rate calculated as current step divided by total steps"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "GCP Critical Document Rate"
      display_name: "GCP Critical Document Rate"
      expr: SUM(CAST(CASE WHEN gcp_critical_document_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0)
      comment: "Percentage of workflows processing GCP-critical documents"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
