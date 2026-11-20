-- Metric views for domain: regulatory | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`regulatory_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key application KPIs by health authority, therapeutic area and time"
  source: "`clinical_trials_mvm`.`regulatory`.`application`"
  dimensions:
    - name: "application_year"
      display_name: "Application Year"
      expr: DATE_TRUNC('year', initial_filing_date)
      comment: "Year of application filing date (initial_filing_date)"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_applications"
      display_name: "Total Applications"
      expr: COUNT(1)
      comment: "Total number of regulatory applications submitted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "accelerated_approval_count"
      display_name: "Accelerated Approval Applications"
      expr: COUNT(CASE WHEN accelerated_approval THEN 1 END)
      comment: "Count of applications that received accelerated approval designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`regulatory_approval`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Approval performance metrics, including speed of approval"
  source: "`clinical_trials_mvm`.`regulatory`.`approval`"
  joins:
    - name: dim_application
      source: "`clinical_trials_mvm`.`regulatory`.`application`"
      'on': source.application_id = dim_application.application_id
      rely:
        at_most_one_match: true
    - name: dim_health_authority
      source: "`clinical_trials_mvm`.`regulatory`.`health_authority`"
      'on': source.primary_approval_health_authority_id = dim_health_authority.health_authority_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "approval_year"
      display_name: "Approval Year"
      expr: DATE_TRUNC('year', approval_date)
      comment: "Year of approval date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_approvals"
      display_name: "Total Approvals"
      expr: COUNT(1)
      comment: "Total number of regulatory approvals granted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_approval"
      display_name: "Average Days to Approval"
      expr: AVG(DATEDIFF(approval_date, dim_application.initial_filing_date))
      comment: "Average number of days between application filing and approval"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`regulatory_clinical_trial_authorization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPIs for clinical trial authorizations, tracking volume and decision speed"
  source: "`clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`"
  joins:
    - name: dim_health_authority
      source: "`clinical_trials_mvm`.`regulatory`.`health_authority`"
      'on': source.health_authority_id = dim_health_authority.health_authority_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "auth_year"
      display_name: "Auth Year"
      expr: DATE_TRUNC('year', authorization_date)
      comment: "Year of authorization date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_authorizations"
      display_name: "Total Authorizations"
      expr: COUNT(1)
      comment: "Total number of clinical trial authorizations issued"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_decision_lag_days"
      display_name: "Average Decision Lag (Days)"
      expr: AVG(DATEDIFF(decision_date, authorization_date))
      comment: "Average days between authorization and final decision"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`regulatory_safety_report_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Safety reporting KPIs, focusing on volume and expedited handling"
  source: "`clinical_trials_mvm`.`regulatory`.`submission`"
  joins:
    - name: dim_health_authority
      source: "`clinical_trials_mvm`.`regulatory`.`health_authority`"
      'on': source.health_authority_id = dim_health_authority.health_authority_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "total_reports"
      display_name: "Total Safety Reports"
      expr: COUNT(1)
      comment: "Total number of safety report submissions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "expedited_reports"
      display_name: "Expedited Safety Reports"
      expr: COUNT(CASE WHEN is_expedited THEN 1 END)
      comment: "Count of safety reports flagged as expedited"
      format:
        type: number
        decimal_places:
          type: all
    - name: "expedited_report_rate"
      display_name: "Expedited Report Rate"
      expr: (AGG(`expedited_reports`) / NULLIF(AGG(`total_reports`), 0))
      comment: "Proportion of safety reports that are expedited"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`regulatory_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core regulatory submission metrics tracking submission volume, cycle times, approval rates, and agency performance across therapeutic areas and submission types"
  source: "`clinical_trials_mvm`.`regulatory`.`submission`"
  dimensions:
    - name: "Submission Type"
      display_name: "Submission Type"
      expr: submission_type
      comment: "Type of regulatory submission (IND, NDA, BLA, MAA, amendment, etc.)"
    - name: "Submission Status"
      display_name: "Submission Status"
      expr: submission_status
      comment: "Current status of the submission (submitted, under review, approved, rejected, withdrawn)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area or disease category for the submission"
    - name: "Agency Country"
      display_name: "Agency Country"
      expr: agency_country_code
      comment: "Country code of the regulatory agency receiving the submission"
    - name: "Submission Category"
      display_name: "Submission Category"
      expr: submission_category
      comment: "Category classification of the submission"
    - name: "Is Expedited"
      display_name: "Expedited Review"
      expr: is_expedited
      comment: "Flag indicating whether the submission received expedited review status"
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Year of submission date for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Quarter"
      display_name: "Submission Quarter"
      expr: DATE_TRUNC('quarter', submission_date)
      comment: "Quarter of submission date for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month of submission date for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Agency Action Year"
      display_name: "Agency Action Year"
      expr: DATE_TRUNC('year', agency_action_date)
      comment: "Year of agency action date for decision trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Submissions"
      display_name: "Total Submissions"
      expr: COUNT(submission_id)
      comment: "Total count of regulatory submissions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Submissions"
      display_name: "Approved Submissions"
      expr: COUNT(CASE WHEN agency_decision = 'Approved' THEN submission_id END)
      comment: "Count of submissions that received agency approval"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN agency_decision = 'Approved' THEN submission_id END) / NULLIF(COUNT(CASE WHEN agency_decision IS NOT NULL THEN submission_id END), 0), 2)
      comment: "Percentage of submissions that received approval out of all decided submissions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Review Cycle Days"
      display_name: "Avg Review Cycle (Days)"
      expr: AVG(DATEDIFF(agency_action_date, submission_date))
      comment: "Average number of days from submission to agency action decision"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Expedited Submissions"
      display_name: "Expedited Submissions"
      expr: COUNT(CASE WHEN is_expedited = TRUE THEN submission_id END)
      comment: "Count of submissions granted expedited review status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Expedited Rate"
      display_name: "Expedited Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_expedited = TRUE THEN submission_id END) / NULLIF(COUNT(submission_id), 0), 2)
      comment: "Percentage of submissions receiving expedited review designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Resubmissions"
      display_name: "Resubmissions"
      expr: COUNT(CASE WHEN is_resubmission = TRUE THEN submission_id END)
      comment: "Count of submissions that are resubmissions of prior applications"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Resubmission Rate"
      display_name: "Resubmission Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_resubmission = TRUE THEN submission_id END) / NULLIF(COUNT(submission_id), 0), 2)
      comment: "Percentage of submissions that are resubmissions indicating prior rejection or withdrawal"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
