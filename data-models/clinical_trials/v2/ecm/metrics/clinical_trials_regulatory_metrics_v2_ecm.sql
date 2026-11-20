-- Metric views for domain: regulatory | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_agency_meeting`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory agency meeting metrics tracking meeting outcomes, action item closure, response timeliness, and strategic engagement effectiveness"
  source: "`clinical_trials_ecm`.`regulatory`.`agency_meeting`"
  dimensions:
    - name: "Meeting Type"
      display_name: "Meeting Type"
      expr: meeting_type
      comment: "Type of agency meeting (Type A, Type B, Type C, pre-IND, EOP2, pre-NDA, etc.)"
    - name: "Meeting Status"
      display_name: "Meeting Status"
      expr: meeting_status
      comment: "Current status of the meeting (requested, scheduled, held, cancelled)"
    - name: "Meeting Stage"
      display_name: "Meeting Stage"
      expr: meeting_stage
      comment: "Development stage at which the meeting occurs"
    - name: "Outcome Classification"
      display_name: "Outcome Classification"
      expr: outcome_classification
      comment: "Classification of the meeting outcome (favorable, neutral, unfavorable)"
    - name: "Meeting Format"
      display_name: "Meeting Format"
      expr: meeting_format
      comment: "Format of the meeting (face-to-face, teleconference, written response only)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area discussed in the meeting"
    - name: "Meeting Year"
      display_name: "Meeting Year"
      expr: DATE_TRUNC('year', confirmed_meeting_date)
      comment: "Year of confirmed meeting date for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Meetings"
      display_name: "Total Meetings"
      expr: COUNT(agency_meeting_id)
      comment: "Total count of regulatory agency meetings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Held Meetings"
      display_name: "Held Meetings"
      expr: COUNT(CASE WHEN meeting_status = 'Held' THEN agency_meeting_id END)
      comment: "Count of meetings that have been held"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Action Items"
      display_name: "Total Action Items"
      expr: SUM(CAST(action_items_count AS DOUBLE))
      comment: "Total number of action items generated from all meetings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Action Items"
      display_name: "Open Action Items"
      expr: SUM(CAST(open_action_items_count AS DOUBLE))
      comment: "Total number of open action items not yet closed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Action Item Closure Rate"
      display_name: "Action Item Closure Rate"
      expr: ROUND(100.0 * (SUM(CAST(action_items_count AS DOUBLE)) - SUM(CAST(open_action_items_count AS DOUBLE))) / NULLIF(SUM(CAST(action_items_count AS DOUBLE)), 0), 2)
      comment: "Percentage of action items that have been closed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Action Items Per Meeting"
      display_name: "Avg Action Items Per Meeting"
      expr: AVG(CAST(action_items_count AS DOUBLE))
      comment: "Average number of action items generated per meeting"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Favorable Outcome Rate"
      display_name: "Favorable Outcome Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN outcome_classification = 'Favorable' THEN agency_meeting_id END) / NULLIF(COUNT(CASE WHEN outcome_classification IS NOT NULL THEN agency_meeting_id END), 0), 2)
      comment: "Percentage of meetings with favorable outcome classification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Request to Meeting Days"
      display_name: "Avg Request to Meeting (Days)"
      expr: AVG(DATEDIFF(confirmed_meeting_date, request_date))
      comment: "Average number of days from meeting request to confirmed meeting date"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Agency Response Days"
      display_name: "Avg Agency Response (Days)"
      expr: AVG(DATEDIFF(agency_response_date, confirmed_meeting_date))
      comment: "Average number of days from meeting date to agency response"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Follow-Up Required Rate"
      display_name: "Follow-Up Required Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN follow_up_submission_required = TRUE THEN agency_meeting_id END) / NULLIF(COUNT(agency_meeting_id), 0), 2)
      comment: "Percentage of meetings requiring follow-up submission"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory application portfolio metrics tracking IND/NDA/BLA lifecycle, special designations, approval timelines, and strategic pathway performance"
  source: "`clinical_trials_ecm`.`regulatory`.`application`"
  dimensions:
    - name: "Application Type"
      display_name: "Application Type"
      expr: application_type
      comment: "Type of regulatory application (IND, NDA, BLA, MAA, etc.)"
    - name: "Application Status"
      display_name: "Application Status"
      expr: application_status
      comment: "Current lifecycle status of the application"
    - name: "Lifecycle Phase"
      display_name: "Lifecycle Phase"
      expr: lifecycle_phase
      comment: "Current phase in the regulatory lifecycle"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area or disease category for the application"
    - name: "Fast Track"
      display_name: "Fast Track Designation"
      expr: fast_track_designation
      comment: "Flag indicating FDA Fast Track designation"
    - name: "Breakthrough Therapy"
      display_name: "Breakthrough Therapy"
      expr: breakthrough_therapy
      comment: "Flag indicating FDA Breakthrough Therapy designation"
    - name: "Orphan Drug"
      display_name: "Orphan Drug Designation"
      expr: orphan_drug_designation
      comment: "Flag indicating Orphan Drug designation"
    - name: "Priority Review"
      display_name: "Priority Review"
      expr: priority_review
      comment: "Flag indicating Priority Review status"
    - name: "Accelerated Approval"
      display_name: "Accelerated Approval"
      expr: accelerated_approval
      comment: "Flag indicating Accelerated Approval pathway"
    - name: "Filing Year"
      display_name: "Filing Year"
      expr: DATE_TRUNC('year', initial_filing_date)
      comment: "Year of initial filing for cohort analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Approval Year"
      display_name: "Approval Year"
      expr: DATE_TRUNC('year', approval_date)
      comment: "Year of approval for approval trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Applications"
      display_name: "Total Applications"
      expr: COUNT(application_id)
      comment: "Total count of regulatory applications in the portfolio"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Applications"
      display_name: "Approved Applications"
      expr: COUNT(CASE WHEN approval_date IS NOT NULL THEN application_id END)
      comment: "Count of applications that have received approval"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Applications on Clinical Hold"
      display_name: "Applications on Clinical Hold"
      expr: COUNT(CASE WHEN clinical_hold_status = 'Active' THEN application_id END)
      comment: "Count of applications currently under clinical hold"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fast Track Applications"
      display_name: "Fast Track Applications"
      expr: COUNT(CASE WHEN fast_track_designation = TRUE THEN application_id END)
      comment: "Count of applications with Fast Track designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Breakthrough Therapy Applications"
      display_name: "Breakthrough Therapy Applications"
      expr: COUNT(CASE WHEN breakthrough_therapy = TRUE THEN application_id END)
      comment: "Count of applications with Breakthrough Therapy designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Orphan Drug Applications"
      display_name: "Orphan Drug Applications"
      expr: COUNT(CASE WHEN orphan_drug_designation = TRUE THEN application_id END)
      comment: "Count of applications with Orphan Drug designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Priority Review Applications"
      display_name: "Priority Review Applications"
      expr: COUNT(CASE WHEN priority_review = TRUE THEN application_id END)
      comment: "Count of applications granted Priority Review status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Special Designation Rate"
      display_name: "Special Designation Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN (fast_track_designation = TRUE OR breakthrough_therapy = TRUE OR orphan_drug_designation = TRUE OR priority_review = TRUE) THEN application_id END) / NULLIF(COUNT(application_id), 0), 2)
      comment: "Percentage of applications receiving at least one special regulatory designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Filing to Approval Days"
      display_name: "Avg Filing to Approval (Days)"
      expr: AVG(DATEDIFF(approval_date, initial_filing_date))
      comment: "Average number of days from initial filing to approval for approved applications"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Clinical Hold Rate"
      display_name: "Clinical Hold Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN clinical_hold_date IS NOT NULL THEN application_id END) / NULLIF(COUNT(application_id), 0), 2)
      comment: "Percentage of applications that have experienced a clinical hold at any point"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Post-marketing commitment and requirement tracking metrics measuring completion rates, timeliness, and compliance with agency-mandated obligations"
  source: "`clinical_trials_ecm`.`regulatory`.`commitment`"
  dimensions:
    - name: "Commitment Type"
      display_name: "Commitment Type"
      expr: commitment_type
      comment: "Type of regulatory commitment (PMR, PMC, REMS, pediatric study, etc.)"
    - name: "Commitment Status"
      display_name: "Commitment Status"
      expr: commitment_status
      comment: "Current status of the commitment (pending, ongoing, completed, delayed, released)"
    - name: "Commitment Category"
      display_name: "Commitment Category"
      expr: commitment_category
      comment: "Category classification of the commitment"
    - name: "Priority Level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level assigned to the commitment"
    - name: "Is Binding"
      display_name: "Binding Commitment"
      expr: is_binding
      comment: "Flag indicating whether the commitment is legally binding"
    - name: "Is Pediatric"
      display_name: "Pediatric Commitment"
      expr: is_pediatric
      comment: "Flag indicating whether the commitment is pediatric-related"
    - name: "Accelerated Approval Condition"
      display_name: "Accelerated Approval Condition"
      expr: accelerated_approval_condition
      comment: "Flag indicating whether the commitment is a condition of accelerated approval"
    - name: "Due Year"
      display_name: "Due Year"
      expr: DATE_TRUNC('year', due_date)
      comment: "Year of commitment due date for trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Commitments"
      display_name: "Total Commitments"
      expr: COUNT(commitment_id)
      comment: "Total count of regulatory commitments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Commitments"
      display_name: "Completed Commitments"
      expr: COUNT(CASE WHEN commitment_status = 'Completed' THEN commitment_id END)
      comment: "Count of commitments that have been completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completion Rate"
      display_name: "Completion Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN commitment_status = 'Completed' THEN commitment_id END) / NULLIF(COUNT(commitment_id), 0), 2)
      comment: "Percentage of commitments that have been completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Overdue Commitments"
      display_name: "Overdue Commitments"
      expr: COUNT(CASE WHEN due_date < CURRENT_DATE() AND commitment_status NOT IN ('Completed', 'Released') THEN commitment_id END)
      comment: "Count of commitments past their due date that are not yet completed or released"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Overdue Rate"
      display_name: "Overdue Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN due_date < CURRENT_DATE() AND commitment_status NOT IN ('Completed', 'Released') THEN commitment_id END) / NULLIF(COUNT(CASE WHEN commitment_status NOT IN ('Completed', 'Released') THEN commitment_id END), 0), 2)
      comment: "Percentage of active commitments that are overdue"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Binding Commitments"
      display_name: "Binding Commitments"
      expr: COUNT(CASE WHEN is_binding = TRUE THEN commitment_id END)
      comment: "Count of legally binding commitments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Pediatric Commitments"
      display_name: "Pediatric Commitments"
      expr: COUNT(CASE WHEN is_pediatric = TRUE THEN commitment_id END)
      comment: "Count of pediatric-related commitments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Completion Time Days"
      display_name: "Avg Completion Time (Days)"
      expr: AVG(DATEDIFF(completion_date, approval_date))
      comment: "Average number of days from commitment approval to completion for completed commitments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Completion Rate"
      display_name: "On-Time Completion Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN completion_date <= due_date THEN commitment_id END) / NULLIF(COUNT(CASE WHEN completion_date IS NOT NULL THEN commitment_id END), 0), 2)
      comment: "Percentage of completed commitments that were completed on or before the due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_inspection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory inspection and compliance metrics tracking inspection outcomes, findings severity, CAPA requirements, and response timeliness"
  source: "`clinical_trials_ecm`.`regulatory`.`regulatory_inspection`"
  dimensions:
    - name: "Inspection Type"
      display_name: "Inspection Type"
      expr: inspection_type
      comment: "Type of regulatory inspection (routine, for-cause, pre-approval, surveillance)"
    - name: "Inspection Status"
      display_name: "Inspection Status"
      expr: inspection_status
      comment: "Current status of the inspection (scheduled, in progress, closed)"
    - name: "Inspection Outcome"
      display_name: "Inspection Outcome"
      expr: inspection_outcome
      comment: "Final outcome classification of the inspection (NAI, VAI, OAI)"
    - name: "Inspection Scope"
      display_name: "Inspection Scope"
      expr: inspection_scope
      comment: "Scope or focus area of the inspection"
    - name: "Form 483 Issued"
      display_name: "Form 483 Issued"
      expr: form_483_issued_flag
      comment: "Flag indicating whether FDA Form 483 was issued"
    - name: "Warning Letter Issued"
      display_name: "Warning Letter Issued"
      expr: warning_letter_issued_flag
      comment: "Flag indicating whether a Warning Letter was issued"
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required_flag
      comment: "Flag indicating whether corrective and preventive action is required"
    - name: "Inspection Year"
      display_name: "Inspection Year"
      expr: DATE_TRUNC('year', inspection_start_date)
      comment: "Year of inspection start for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Inspection Quarter"
      display_name: "Inspection Quarter"
      expr: DATE_TRUNC('quarter', inspection_start_date)
      comment: "Quarter of inspection start for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Inspections"
      display_name: "Total Inspections"
      expr: COUNT(regulatory_inspection_id)
      comment: "Total count of regulatory inspections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Findings"
      display_name: "Total Findings"
      expr: SUM(CAST(findings_count AS DOUBLE))
      comment: "Total number of inspection findings across all inspections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Findings"
      display_name: "Critical Findings"
      expr: SUM(CAST(critical_findings_count AS DOUBLE))
      comment: "Total number of critical severity findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Major Findings"
      display_name: "Major Findings"
      expr: SUM(CAST(major_findings_count AS DOUBLE))
      comment: "Total number of major severity findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Findings Per Inspection"
      display_name: "Avg Findings Per Inspection"
      expr: AVG(CAST(findings_count AS DOUBLE))
      comment: "Average number of findings per inspection"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Form 483 Issuance Rate"
      display_name: "Form 483 Issuance Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN form_483_issued_flag = TRUE THEN regulatory_inspection_id END) / NULLIF(COUNT(regulatory_inspection_id), 0), 2)
      comment: "Percentage of inspections resulting in Form 483 issuance"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Warning Letter Rate"
      display_name: "Warning Letter Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN warning_letter_issued_flag = TRUE THEN regulatory_inspection_id END) / NULLIF(COUNT(regulatory_inspection_id), 0), 2)
      comment: "Percentage of inspections resulting in Warning Letter issuance"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN capa_required_flag = TRUE THEN regulatory_inspection_id END) / NULLIF(COUNT(regulatory_inspection_id), 0), 2)
      comment: "Percentage of inspections requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Response Time Days"
      display_name: "Avg Response Time (Days)"
      expr: AVG(DATEDIFF(response_submitted_date, report_received_date))
      comment: "Average number of days from inspection report receipt to response submission"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Overdue Responses"
      display_name: "Overdue Responses"
      expr: COUNT(CASE WHEN response_due_date < CURRENT_DATE() AND response_submitted_date IS NULL THEN regulatory_inspection_id END)
      comment: "Count of inspections with overdue responses not yet submitted"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_program_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory program milestone performance metrics tracking on-time delivery, variance, critical path adherence, and probability-weighted forecasting"
  source: "`clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone`"
  dimensions:
    - name: "Milestone Type"
      display_name: "Milestone Type"
      expr: milestone_type
      comment: "Type of regulatory milestone (submission, approval, meeting, report, etc.)"
    - name: "Milestone Status"
      display_name: "Milestone Status"
      expr: milestone_status
      comment: "Current status of the milestone (planned, in progress, completed, delayed, cancelled)"
    - name: "Milestone Category"
      display_name: "Milestone Category"
      expr: milestone_category
      comment: "Category classification of the milestone"
    - name: "Phase"
      display_name: "Phase"
      expr: phase
      comment: "Development phase associated with the milestone"
    - name: "Is Critical Path"
      display_name: "Critical Path Milestone"
      expr: is_critical_path
      comment: "Flag indicating whether the milestone is on the critical path"
    - name: "Is Agency Committed"
      display_name: "Agency Committed"
      expr: is_agency_committed
      comment: "Flag indicating whether the agency has committed to a date"
    - name: "Priority Designation"
      display_name: "Priority Designation"
      expr: priority_designation
      comment: "Priority designation assigned to the milestone"
    - name: "Planned Year"
      display_name: "Planned Year"
      expr: DATE_TRUNC('year', planned_date)
      comment: "Year of planned milestone date for trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Year"
      display_name: "Actual Year"
      expr: DATE_TRUNC('year', actual_date)
      comment: "Year of actual milestone completion for trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Milestones"
      display_name: "Total Milestones"
      expr: COUNT(regulatory_program_milestone_id)
      comment: "Total count of regulatory program milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Milestones"
      display_name: "Completed Milestones"
      expr: COUNT(CASE WHEN milestone_status = 'Completed' THEN regulatory_program_milestone_id END)
      comment: "Count of milestones that have been completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Milestones"
      display_name: "On-Time Milestones"
      expr: COUNT(CASE WHEN actual_date <= planned_date THEN regulatory_program_milestone_id END)
      comment: "Count of milestones completed on or before the planned date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Delivery Rate"
      display_name: "On-Time Delivery Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN actual_date <= planned_date THEN regulatory_program_milestone_id END) / NULLIF(COUNT(CASE WHEN actual_date IS NOT NULL THEN regulatory_program_milestone_id END), 0), 2)
      comment: "Percentage of completed milestones delivered on or before the planned date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Delayed Milestones"
      display_name: "Delayed Milestones"
      expr: COUNT(CASE WHEN milestone_status = 'Delayed' OR (actual_date > planned_date) THEN regulatory_program_milestone_id END)
      comment: "Count of milestones that are delayed or were completed late"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Path Milestones"
      display_name: "Critical Path Milestones"
      expr: COUNT(CASE WHEN is_critical_path = TRUE THEN regulatory_program_milestone_id END)
      comment: "Count of milestones on the critical path"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Variance Days"
      display_name: "Avg Variance (Days)"
      expr: AVG(CAST(variance_days AS DOUBLE))
      comment: "Average variance in days between planned and actual milestone dates (positive = late, negative = early)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Variance Days"
      display_name: "Total Variance (Days)"
      expr: SUM(CAST(variance_days AS DOUBLE))
      comment: "Total cumulative variance in days across all completed milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Probability of Success"
      display_name: "Avg Probability of Success"
      expr: AVG(CAST(probability_of_success_pct AS DOUBLE))
      comment: "Average probability of success percentage across all milestones"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "At-Risk Milestones"
      display_name: "At-Risk Milestones"
      expr: COUNT(CASE WHEN planned_date < CURRENT_DATE() AND milestone_status NOT IN ('Completed', 'Cancelled') THEN regulatory_program_milestone_id END)
      comment: "Count of milestones past their planned date that are not yet completed or cancelled"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`regulatory_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core regulatory submission metrics tracking submission volume, cycle times, approval rates, and agency performance across therapeutic areas and submission types"
  source: "`clinical_trials_ecm`.`regulatory`.`submission`"
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
