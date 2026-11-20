-- Metric views for domain: document | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`document_regulatory_binder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Metrics summarizing regulatory binder health and readiness."
  source: "`clinical_trials_mvm`.`document`.`regulatory_binder`"
  dimensions:
    - name: "target_agency"
      display_name: "Target Agency"
      expr: target_agency
      comment: "Regulatory agency targeted by the binder"
    - name: "therapeutic_area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area of the submission"
    - name: "binder_type"
      display_name: "Binder Type"
      expr: binder_type
      comment: "Type of regulatory binder"
    - name: "binder_status"
      display_name: "Binder Status"
      expr: binder_status
      comment: "Current status of the binder"
    - name: "submission_year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Year of submission"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Binders"
      display_name: "Total binders"
      expr: COUNT(1)
      comment: "Total number of regulatory binders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Completeness %', \"format\": {\"type\": \"percentage\", \"decimal_places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      display_name: "Avg completeness %', \"format\": {\"type\": \"percentage\", \"decimal Places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      expr: AVG(CAST(completeness_percentage AS DOUBLE))
      comment: "Average completeness percentage across binders"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`document_signature`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Signature workflow performance indicators."
  source: "`clinical_trials_mvm`.`document`.`signature`"
  dimensions:
    - name: "signature_status"
      display_name: "Signature Status"
      expr: signature_status
      comment: "Current status of the signature"
    - name: "signer_role"
      display_name: "Signer Role"
      expr: signer_role
      comment: "Role of the signer"
    - name: "signer_organization"
      display_name: "Signer Organization"
      expr: signer_organization
      comment: "Organization of the signer"
    - name: "created_date"
      display_name: "Created Date"
      expr: DATE_TRUNC('day', created_timestamp)
      comment: "Date the signature record was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Signatures"
      display_name: "Total signatures"
      expr: COUNT(1)
      comment: "Total number of signatures captured"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Signatures"
      display_name: "Completed signatures"
      expr: SUM(CASE WHEN signature_status = 'Completed' THEN 1 ELSE 0 END)
      comment: "Count of completed signatures"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Signature %', \"format\": {\"type\": \"percentage\", \"decimal_places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      display_name: "Completed signature %', \"format\": {\"type\": \"percentage\", \"decimal Places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      expr: (AGG(`Completed Signatures`) / NULLIF(AGG(`Total Signatures`),0)) * 100
      comment: "Percentage of signatures that are completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`document_sop`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key performance indicators for Standard Operating Procedures (SOP) documents."
  source: "`clinical_trials_mvm`.`document`.`document_sop`"
  dimensions:
    - name: "applicable_region"
      display_name: "Applicable Region"
      expr: applicable_region
      comment: "Geographic region applicable to the SOP"
    - name: "sop_category"
      display_name: "Sop Category"
      expr: sop_category
      comment: "Category of SOP"
    - name: "sop_status"
      display_name: "Sop Status"
      expr: sop_status
      comment: "Current status of SOP"
    - name: "approval_year"
      display_name: "Approval Year"
      expr: DATE_TRUNC('year', approval_date)
      comment: "Year of SOP approval"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "approval_month"
      display_name: "Approval Month"
      expr: DATE_TRUNC('month', approval_date)
      comment: "Month of SOP approval"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total SOPs"
      display_name: "Total sops"
      expr: COUNT(1)
      comment: "Total number of SOP records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Inspection Ready SOPs"
      display_name: "Inspection ready sops"
      expr: SUM(CASE WHEN inspection_ready THEN 1 ELSE 0 END)
      comment: "Count of SOPs marked inspection ready"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Inspection Ready %', \"format\": {\"type\": \"percentage\", \"decimal_places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      display_name: "Inspection ready %', \"format\": {\"type\": \"percentage\", \"decimal Places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      expr: (AGG(`Inspection Ready SOPs`) / NULLIF(AGG(`Total SOPs`),0)) * 100
      comment: "Percentage of SOPs that are inspection ready"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`document_workflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational metrics for document-related workflows."
  source: "`clinical_trials_mvm`.`document`.`workflow`"
  dimensions:
    - name: "workflow_type"
      display_name: "Workflow Type"
      expr: workflow_type
      comment: "Type of workflow"
    - name: "priority_level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level assigned to the workflow"
    - name: "workflow_status"
      display_name: "Workflow Status"
      expr: workflow_status
      comment: "Current status of the workflow"
    - name: "initiated_year"
      display_name: "Initiated Year"
      expr: DATE_TRUNC('year', initiated_timestamp)
      comment: "Year the workflow was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Workflows"
      display_name: "Total workflows"
      expr: COUNT(1)
      comment: "Total number of workflow instances"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalated Workflows"
      display_name: "Escalated workflows"
      expr: SUM(CASE WHEN escalation_flag THEN 1 ELSE 0 END)
      comment: "Count of workflows that escalated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Rate %', \"format\": {\"type\": \"percentage\", \"decimal_places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      display_name: "Escalation rate %', \"format\": {\"type\": \"percentage\", \"decimal Places\": {\"type\": \"exact\", \"places\": 2}}}, {"
      expr: (AGG(`Escalated Workflows`) / NULLIF(AGG(`Total Workflows`),0)) * 100
      comment: "Escalation rate of workflows"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
