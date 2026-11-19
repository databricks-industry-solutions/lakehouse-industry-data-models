-- Metric views for domain: program | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_budget`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Program budget allocation, utilization, and financial planning KPIs across development phases and functional areas"
  source: "`clinical_trials_ecm`.`program`.`budget`"
  dimensions:
    - name: "Budget Code"
      display_name: "Budget Code"
      expr: budget_code
      comment: "Unique code for the budget"
    - name: "Budget Name"
      display_name: "Budget Name"
      expr: budget_name
      comment: "Name of the budget"
    - name: "Budget Type"
      display_name: "Budget Type"
      expr: budget_type
      comment: "Type of budget (Annual, Project, Phase-specific)"
    - name: "Budget Status"
      display_name: "Budget Status"
      expr: budget_status
      comment: "Current status of the budget (Draft, Approved, Active, Closed)"
    - name: "Fiscal Year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year the budget applies to"
    - name: "Currency Code"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Currency code for the budget"
    - name: "Is Locked"
      display_name: "Is Locked"
      expr: is_locked
      comment: "Whether the budget is locked for changes"
    - name: "Approval Year"
      display_name: "Approval Year"
      expr: YEAR(approval_date)
      comment: "Year the budget was approved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Month"
      display_name: "Approval Month"
      expr: DATE_TRUNC('month', approval_date)
      comment: "Month the budget was approved"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Budgets"
      display_name: "Total Budgets"
      expr: COUNT(1)
      comment: "Total count of program budgets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Approved Amount"
      display_name: "Total Approved Amount"
      expr: SUM(CAST(total_approved_amount AS DOUBLE))
      comment: "Sum of all approved budget amounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Approved Amount"
      display_name: "Average Approved Amount"
      expr: AVG(CAST(total_approved_amount AS DOUBLE))
      comment: "Average approved budget amount per budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Contingency Amount"
      display_name: "Total Contingency Amount"
      expr: SUM(CAST(contingency_amount AS DOUBLE))
      comment: "Sum of all contingency amounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Clinical Ops Budget"
      display_name: "Total Clinical Ops Budget"
      expr: SUM(CAST(clinical_ops_budget_amount AS DOUBLE))
      comment: "Sum of clinical operations budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total CRO Budget"
      display_name: "Total CRO Budget"
      expr: SUM(CAST(cro_budget_amount AS DOUBLE))
      comment: "Sum of CRO budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Biostatistics Budget"
      display_name: "Total Biostatistics Budget"
      expr: SUM(CAST(biostatistics_budget_amount AS DOUBLE))
      comment: "Sum of biostatistics budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Data Management Budget"
      display_name: "Total Data Management Budget"
      expr: SUM(CAST(data_management_budget_amount AS DOUBLE))
      comment: "Sum of data management budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Regulatory Budget"
      display_name: "Total Regulatory Budget"
      expr: SUM(CAST(regulatory_budget_amount AS DOUBLE))
      comment: "Sum of regulatory affairs budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Safety Budget"
      display_name: "Total Safety Budget"
      expr: SUM(CAST(safety_budget_amount AS DOUBLE))
      comment: "Sum of safety budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Lab Budget"
      display_name: "Total Lab Budget"
      expr: SUM(CAST(lab_budget_amount AS DOUBLE))
      comment: "Sum of laboratory budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Contingency Reserve Rate"
      display_name: "Contingency Reserve Rate"
      expr: ROUND(100.0 * SUM(CAST(contingency_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_approved_amount AS DOUBLE)), 0), 2)
      comment: "Contingency amount as a percentage of total approved budget"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CRO Budget Share"
      display_name: "CRO Budget Share"
      expr: ROUND(100.0 * SUM(CAST(cro_budget_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_approved_amount AS DOUBLE)), 0), 2)
      comment: "CRO budget as a percentage of total approved budget"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_clinical_program`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for clinical program portfolio management, development phase progression, and regulatory milestone tracking"
  source: "`clinical_trials_ecm`.`program`.`clinical_program`"
  dimensions:
    - name: "Program Code"
      display_name: "Program Code"
      expr: program_code
      comment: "Unique identifier for the clinical program"
    - name: "Program Name"
      display_name: "Program Name"
      expr: program_name
      comment: "Full name of the clinical program"
    - name: "Development Phase"
      display_name: "Development Phase"
      expr: development_phase
      comment: "Current development phase (Phase 1, Phase 2, Phase 3, Phase 4)"
    - name: "Program Status"
      display_name: "Program Status"
      expr: program_status
      comment: "Current status of the clinical program (Active, On Hold, Terminated, Completed)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area_id
      comment: "Therapeutic area classification for the program"
    - name: "Portfolio Priority"
      display_name: "Portfolio Priority"
      expr: portfolio_priority
      comment: "Strategic priority tier within the portfolio (High, Medium, Low)"
    - name: "Modality"
      display_name: "Modality"
      expr: modality
      comment: "Drug modality (Small Molecule, Biologic, Gene Therapy, etc.)"
    - name: "Program Type"
      display_name: "Program Type"
      expr: program_type
      comment: "Type of clinical program (Registrational, Exploratory, Lifecycle Management)"
    - name: "Start Year"
      display_name: "Start Year"
      expr: YEAR(program_start_date)
      comment: "Year the program was initiated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Start Month"
      display_name: "Start Month"
      expr: DATE_TRUNC('month', program_start_date)
      comment: "Month the program was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Programs"
      display_name: "Total Programs"
      expr: COUNT(1)
      comment: "Total count of clinical programs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Program Budget"
      display_name: "Total Program Budget"
      expr: SUM(CAST(program_budget AS DOUBLE))
      comment: "Sum of all program budgets in program currency"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Program Budget"
      display_name: "Average Program Budget"
      expr: AVG(CAST(program_budget AS DOUBLE))
      comment: "Average budget per clinical program"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Global Study Count"
      display_name: "Total Global Study Count"
      expr: SUM(CAST(global_study_count AS DOUBLE))
      comment: "Sum of all studies across all programs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Studies Per Program"
      display_name: "Average Studies Per Program"
      expr: AVG(CAST(global_study_count AS DOUBLE))
      comment: "Average number of studies per clinical program"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Programs with Breakthrough Designation"
      display_name: "Programs with Breakthrough Designation"
      expr: SUM(CAST(CASE WHEN breakthrough_therapy_designation = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of programs with FDA Breakthrough Therapy designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Programs with Fast Track Designation"
      display_name: "Programs with Fast Track Designation"
      expr: SUM(CAST(CASE WHEN fast_track_designation = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of programs with FDA Fast Track designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Programs with Orphan Drug Designation"
      display_name: "Programs with Orphan Drug Designation"
      expr: SUM(CAST(CASE WHEN orphan_drug_designation = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of programs with Orphan Drug designation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Designation Rate"
      display_name: "Regulatory Designation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN (breakthrough_therapy_designation = TRUE OR fast_track_designation = TRUE OR orphan_drug_designation = TRUE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs with at least one regulatory designation (Breakthrough, Fast Track, or Orphan)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_decision`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Program governance decision tracking including go/no-go decisions, phase transitions, and investment approvals"
  source: "`clinical_trials_ecm`.`program`.`decision`"
  dimensions:
    - name: "Decision Number"
      display_name: "Decision Number"
      expr: number
      comment: "Unique decision number"
    - name: "Decision Title"
      display_name: "Decision Title"
      expr: title
      comment: "Title of the decision"
    - name: "Decision Type"
      display_name: "Decision Type"
      expr: decision_type
      comment: "Type of decision (Go/No-Go, Phase Transition, Budget Approval, Protocol Amendment, etc.)"
    - name: "Decision Outcome"
      display_name: "Decision Outcome"
      expr: outcome
      comment: "Outcome of the decision (Approved, Rejected, Conditional, Deferred)"
    - name: "Decision Status"
      display_name: "Decision Status"
      expr: decision_status
      comment: "Current status of the decision (Pending, Final, Under Review)"
    - name: "Phase From"
      display_name: "Phase From"
      expr: phase_from
      comment: "Development phase before the decision"
    - name: "Phase To"
      display_name: "Phase To"
      expr: phase_to
      comment: "Development phase after the decision"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area the decision applies to"
    - name: "Safety Signal Flag"
      display_name: "Safety Signal Flag"
      expr: safety_signal_flag
      comment: "Whether the decision was influenced by a safety signal"
    - name: "Dissenting Opinion Flag"
      display_name: "Dissenting Opinion Flag"
      expr: dissenting_opinion_flag
      comment: "Whether there was a dissenting opinion"
    - name: "Sponsor Concurrence Flag"
      display_name: "Sponsor Concurrence Flag"
      expr: sponsor_concurrence_flag
      comment: "Whether the sponsor concurred with the decision"
    - name: "Decision Year"
      display_name: "Decision Year"
      expr: YEAR(decision_date)
      comment: "Year the decision was made"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Decision Month"
      display_name: "Decision Month"
      expr: DATE_TRUNC('month', decision_date)
      comment: "Month the decision was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Decisions"
      display_name: "Total Decisions"
      expr: COUNT(1)
      comment: "Total count of program decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Decisions"
      display_name: "Approved Decisions"
      expr: SUM(CAST(CASE WHEN outcome = 'Approved' THEN 1 ELSE 0 END AS INT))
      comment: "Count of approved decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rejected Decisions"
      display_name: "Rejected Decisions"
      expr: SUM(CAST(CASE WHEN outcome = 'Rejected' THEN 1 ELSE 0 END AS INT))
      comment: "Count of rejected decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Conditional Decisions"
      display_name: "Conditional Decisions"
      expr: SUM(CAST(CASE WHEN outcome = 'Conditional' THEN 1 ELSE 0 END AS INT))
      comment: "Count of conditional decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deferred Decisions"
      display_name: "Deferred Decisions"
      expr: SUM(CAST(CASE WHEN outcome = 'Deferred' THEN 1 ELSE 0 END AS INT))
      comment: "Count of deferred decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Signal Decisions"
      display_name: "Safety Signal Decisions"
      expr: SUM(CAST(CASE WHEN safety_signal_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of decisions influenced by safety signals"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Dissenting Opinion Decisions"
      display_name: "Dissenting Opinion Decisions"
      expr: SUM(CAST(CASE WHEN dissenting_opinion_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of decisions with dissenting opinions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Investment Amount"
      display_name: "Total Investment Amount"
      expr: SUM(CAST(investment_amount AS DOUBLE))
      comment: "Sum of investment amounts across all decisions"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Investment Amount"
      display_name: "Average Investment Amount"
      expr: AVG(CAST(investment_amount AS DOUBLE))
      comment: "Average investment amount per decision"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN outcome = 'Approved' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of decisions that were approved"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rejection Rate"
      display_name: "Rejection Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN outcome = 'Rejected' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of decisions that were rejected"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sponsor Concurrence Rate"
      display_name: "Sponsor Concurrence Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sponsor_concurrence_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of decisions with sponsor concurrence"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_governance_meeting`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Governance meeting effectiveness KPIs tracking decision throughput, action item generation, quorum achievement, and escalation rates for governance process optimization."
  source: "`clinical_trials_ecm`.`program`.`governance_meeting`"
  dimensions:
    - name: "Meeting Status"
      display_name: "Meeting Status"
      expr: meeting_status
      comment: "Status of the governance meeting (Scheduled, Completed, Cancelled, Postponed)"
    - name: "Meeting Type"
      display_name: "Meeting Type"
      expr: meeting_type
      comment: "Type of governance meeting (Regular, Ad Hoc, Emergency, Annual Review)"
    - name: "Meeting Format"
      display_name: "Meeting Format"
      expr: meeting_format
      comment: "Format of the meeting (In-Person, Virtual, Hybrid)"
    - name: "Quorum Achieved"
      display_name: "Quorum Achieved"
      expr: quorum_achieved
      comment: "Flag indicating if quorum was achieved for valid decision-making"
    - name: "Escalation Required"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Flag indicating meeting identified issues requiring escalation"
    - name: "Safety Topic Discussed"
      display_name: "Safety Topic Discussed"
      expr: safety_topic_discussed
      comment: "Flag indicating safety topics were discussed in the meeting"
    - name: "Regulatory Implication"
      display_name: "Regulatory Implication Flag"
      expr: regulatory_implication_flag
      comment: "Flag indicating meeting decisions have regulatory implications"
    - name: "Minutes Status"
      display_name: "Minutes Status"
      expr: minutes_status
      comment: "Status of meeting minutes (Draft, Approved, Distributed)"
    - name: "Meeting Year"
      display_name: "Meeting Year"
      expr: YEAR(meeting_date)
      comment: "Year of the governance meeting for annual governance activity tracking"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Meeting Quarter"
      display_name: "Meeting Quarter"
      expr: DATE_TRUNC('quarter', meeting_date)
      comment: "Quarter of the governance meeting for quarterly governance reporting"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Meeting Month"
      display_name: "Meeting Month"
      expr: DATE_TRUNC('month', meeting_date)
      comment: "Month of the governance meeting for monthly governance tracking"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Meetings"
      display_name: "Total Governance Meetings"
      expr: COUNT(DISTINCT governance_meeting_id)
      comment: "Count of distinct governance meetings for governance activity volume"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Completed Meetings"
      display_name: "Completed Meetings"
      expr: SUM(CAST(CASE WHEN meeting_status = 'Completed' THEN 1 ELSE 0 END AS INT))
      comment: "Count of completed governance meetings for governance execution tracking"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Meetings With Quorum"
      display_name: "Meetings Achieving Quorum"
      expr: SUM(CAST(CASE WHEN quorum_achieved = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of meetings achieving quorum for valid decision-making capacity"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Meetings With Escalation"
      display_name: "Meetings Requiring Escalation"
      expr: SUM(CAST(CASE WHEN escalation_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of meetings identifying issues requiring escalation for governance hierarchy engagement"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Meetings With Safety Topics"
      display_name: "Meetings Discussing Safety"
      expr: SUM(CAST(CASE WHEN safety_topic_discussed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of meetings discussing safety topics for safety governance coverage"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Meetings With Regulatory Impact"
      display_name: "Meetings with Regulatory Implications"
      expr: SUM(CAST(CASE WHEN regulatory_implication_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of meetings with regulatory implications for regulatory strategy alignment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Total Decisions Made"
      display_name: "Total Decisions Made"
      expr: SUM(CAST(decision_count AS BIGINT))
      comment: "Sum of decisions made across all meetings for decision throughput"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Total Action Items"
      display_name: "Total Action Items Generated"
      expr: SUM(CAST(action_item_count AS BIGINT))
      comment: "Sum of action items generated across all meetings for follow-up workload"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Total Open Prior Actions"
      display_name: "Total Open Prior Action Items"
      expr: SUM(CAST(open_action_items_from_prior AS BIGINT))
      comment: "Sum of open action items from prior meetings for backlog tracking"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Avg Attendee Count"
      display_name: "Average Attendee Count"
      expr: AVG(CAST(attendee_count AS DOUBLE))
      comment: "Average number of attendees per meeting for participation assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Decisions Per Meeting"
      display_name: "Average Decisions Per Meeting"
      expr: AVG(CAST(decision_count AS DOUBLE))
      comment: "Average number of decisions per meeting for decision efficiency"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Action Items Per Meeting"
      display_name: "Average Action Items Per Meeting"
      expr: AVG(CAST(action_item_count AS DOUBLE))
      comment: "Average number of action items per meeting for workload planning"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Quorum Achievement Rate"
      display_name: "Quorum Achievement Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN quorum_achieved = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(DISTINCT governance_meeting_id), 0), 2)
      comment: "Percentage of meetings achieving quorum for governance effectiveness"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Meeting Escalation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN escalation_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(DISTINCT governance_meeting_id), 0), 2)
      comment: "Percentage of meetings requiring escalation for governance hierarchy engagement"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety Discussion Rate"
      display_name: "Safety Discussion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN safety_topic_discussed = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(DISTINCT governance_meeting_id), 0), 2)
      comment: "Percentage of meetings discussing safety topics for safety governance coverage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Minutes Approval Rate"
      display_name: "Minutes Approval Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN minutes_status = 'Approved' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(DISTINCT governance_meeting_id), 0), 2)
      comment: "Percentage of meetings with approved minutes for documentation compliance"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_kri_reading`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key Risk Indicator performance tracking, threshold breach monitoring, and trend analysis for program oversight"
  source: "`clinical_trials_ecm`.`program`.`kri_reading`"
  dimensions:
    - name: "Reading Reference Code"
      display_name: "Reading Reference Code"
      expr: reading_reference_code
      comment: "Unique reference code for the KRI reading"
    - name: "Reading Status"
      display_name: "Reading Status"
      expr: reading_status
      comment: "Status of the KRI reading (Draft, Confirmed, Under Review)"
    - name: "Threshold Status"
      display_name: "Threshold Status"
      expr: threshold_status
      comment: "Threshold status (Green, Amber, Red)"
    - name: "KRI Category"
      display_name: "KRI Category"
      expr: kri_category
      comment: "Category of the KRI (Quality, Safety, Enrollment, Data Management)"
    - name: "Escalation Level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level for the reading (None, Low, Medium, High, Critical)"
    - name: "Trend Direction"
      display_name: "Trend Direction"
      expr: trend_direction
      comment: "Trend direction (Improving, Stable, Deteriorating)"
    - name: "Action Required Flag"
      display_name: "Action Required Flag"
      expr: action_required_flag
      comment: "Whether action is required based on the reading"
    - name: "Escalation Flag"
      display_name: "Escalation Flag"
      expr: escalation_flag
      comment: "Whether the reading requires escalation"
    - name: "Data Quality Flag"
      display_name: "Data Quality Flag"
      expr: data_quality_flag
      comment: "Whether there are data quality concerns"
    - name: "Reading Year"
      display_name: "Reading Year"
      expr: YEAR(reading_date)
      comment: "Year of the KRI reading"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reading Month"
      display_name: "Reading Month"
      expr: DATE_TRUNC('month', reading_date)
      comment: "Month of the KRI reading"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total KRI Readings"
      display_name: "Total KRI Readings"
      expr: COUNT(1)
      comment: "Total count of KRI readings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Red Threshold Breaches"
      display_name: "Red Threshold Breaches"
      expr: SUM(CAST(CASE WHEN threshold_status = 'Red' THEN 1 ELSE 0 END AS INT))
      comment: "Count of readings in red threshold status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Amber Threshold Warnings"
      display_name: "Amber Threshold Warnings"
      expr: SUM(CAST(CASE WHEN threshold_status = 'Amber' THEN 1 ELSE 0 END AS INT))
      comment: "Count of readings in amber threshold status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Green Threshold Readings"
      display_name: "Green Threshold Readings"
      expr: SUM(CAST(CASE WHEN threshold_status = 'Green' THEN 1 ELSE 0 END AS INT))
      comment: "Count of readings in green threshold status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Required Count"
      display_name: "Escalation Required Count"
      expr: SUM(CAST(CASE WHEN escalation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of readings requiring escalation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Action Required Count"
      display_name: "Action Required Count"
      expr: SUM(CAST(CASE WHEN action_required_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of readings requiring action"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Observed Value"
      display_name: "Average Observed Value"
      expr: AVG(CAST(observed_value AS DOUBLE))
      comment: "Average observed value across all KRI readings"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Target Value"
      display_name: "Average Target Value"
      expr: AVG(CAST(target_value AS DOUBLE))
      comment: "Average target value across all KRI readings"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Variance from Target"
      display_name: "Average Variance from Target"
      expr: AVG(CAST(variance_from_target AS DOUBLE))
      comment: "Average variance from target across all KRI readings"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Consecutive Breaches"
      display_name: "Total Consecutive Breaches"
      expr: SUM(CAST(consecutive_breach_count AS DOUBLE))
      comment: "Sum of consecutive breach counts across all readings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Red Threshold Breach Rate"
      display_name: "Red Threshold Breach Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN threshold_status = 'Red' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of readings in red threshold status"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Escalation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN escalation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of readings requiring escalation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Data Quality Issue Rate"
      display_name: "Data Quality Issue Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN data_quality_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of readings with data quality concerns"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_development_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Program milestone performance KPIs tracking schedule adherence, critical path execution, and go/no-go decision velocity"
  source: "`clinical_trials_ecm`.`program`.`program_development_milestone`"
  dimensions:
    - name: "Milestone Code"
      display_name: "Milestone Code"
      expr: milestone_code
      comment: "Unique code for the milestone"
    - name: "Milestone Name"
      display_name: "Milestone Name"
      expr: milestone_name
      comment: "Name of the program development milestone"
    - name: "Milestone Type"
      display_name: "Milestone Type"
      expr: milestone_type
      comment: "Type of milestone (Regulatory, Clinical, Manufacturing, etc.)"
    - name: "Milestone Status"
      display_name: "Milestone Status"
      expr: milestone_status
      comment: "Current status of the milestone (Planned, In Progress, Completed, Delayed, Cancelled)"
    - name: "Governing Phase"
      display_name: "Governing Phase"
      expr: governing_phase
      comment: "Development phase the milestone belongs to"
    - name: "Priority Level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level of the milestone (Critical, High, Medium, Low)"
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating for milestone achievement (High, Medium, Low)"
    - name: "Is Critical Path"
      display_name: "Is Critical Path"
      expr: is_critical_path
      comment: "Whether the milestone is on the critical path"
    - name: "Is Regulatory Commitment"
      display_name: "Is Regulatory Commitment"
      expr: is_regulatory_commitment
      comment: "Whether the milestone is a regulatory commitment"
    - name: "Planned Year"
      display_name: "Planned Year"
      expr: YEAR(planned_date)
      comment: "Year the milestone is planned"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Planned Month"
      display_name: "Planned Month"
      expr: DATE_TRUNC('month', planned_date)
      comment: "Month the milestone is planned"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Year"
      display_name: "Actual Year"
      expr: YEAR(actual_date)
      comment: "Year the milestone was actually achieved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Actual Month"
      display_name: "Actual Month"
      expr: DATE_TRUNC('month', actual_date)
      comment: "Month the milestone was actually achieved"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Milestones"
      display_name: "Total Milestones"
      expr: COUNT(1)
      comment: "Total count of program development milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Milestones"
      display_name: "Completed Milestones"
      expr: SUM(CAST(CASE WHEN milestone_status = 'Completed' THEN 1 ELSE 0 END AS INT))
      comment: "Count of completed milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Delayed Milestones"
      display_name: "Delayed Milestones"
      expr: SUM(CAST(CASE WHEN milestone_status = 'Delayed' THEN 1 ELSE 0 END AS INT))
      comment: "Count of delayed milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Path Milestones"
      display_name: "Critical Path Milestones"
      expr: SUM(CAST(CASE WHEN is_critical_path = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of milestones on the critical path"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Commitment Milestones"
      display_name: "Regulatory Commitment Milestones"
      expr: SUM(CAST(CASE WHEN is_regulatory_commitment = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of milestones that are regulatory commitments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Schedule Variance Days"
      display_name: "Average Schedule Variance Days"
      expr: AVG(CAST(schedule_variance_days AS DOUBLE))
      comment: "Average schedule variance in days (positive = ahead, negative = behind)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Schedule Variance Days"
      display_name: "Total Schedule Variance Days"
      expr: SUM(CAST(schedule_variance_days AS DOUBLE))
      comment: "Total schedule variance across all milestones in days"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Completion Percentage"
      display_name: "Average Completion Percentage"
      expr: AVG(CAST(completion_percentage AS DOUBLE))
      comment: "Average completion percentage across all milestones"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "On-Time Completion Rate"
      display_name: "On-Time Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN milestone_status = 'Completed' AND schedule_variance_days >= 0 THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN milestone_status = 'Completed' THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of completed milestones that were achieved on or ahead of schedule"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Milestone Delay Rate"
      display_name: "Milestone Delay Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN milestone_status = 'Delayed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of milestones currently delayed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Path Delay Rate"
      display_name: "Critical Path Delay Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_critical_path = TRUE AND milestone_status = 'Delayed' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN is_critical_path = TRUE THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of critical path milestones that are delayed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_resource_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Program resource planning and utilization KPIs tracking FTE allocation, cost forecasts, and resource gap analysis"
  source: "`clinical_trials_ecm`.`program`.`program_resource_plan`"
  dimensions:
    - name: "Plan Code"
      display_name: "Plan Code"
      expr: plan_code
      comment: "Unique code for the resource plan"
    - name: "Plan Name"
      display_name: "Plan Name"
      expr: plan_name
      comment: "Name of the resource plan"
    - name: "Plan Type"
      display_name: "Plan Type"
      expr: plan_type
      comment: "Type of resource plan (Annual, Project, Phase-specific)"
    - name: "Plan Status"
      display_name: "Plan Status"
      expr: plan_status
      comment: "Current status of the plan (Draft, Approved, Active, Closed)"
    - name: "Development Phase"
      display_name: "Development Phase"
      expr: development_phase
      comment: "Development phase the plan applies to"
    - name: "Functional Area"
      display_name: "Functional Area"
      expr: functional_area
      comment: "Functional area (Clinical Operations, Biostatistics, Data Management, etc.)"
    - name: "Resource Category"
      display_name: "Resource Category"
      expr: resource_category
      comment: "Category of resource (Internal, CRO, Vendor, Consultant)"
    - name: "Resource Role"
      display_name: "Resource Role"
      expr: resource_role
      comment: "Role of the resource (CRA, Data Manager, Biostatistician, etc.)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area the plan applies to"
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating for resource availability (High, Medium, Low)"
    - name: "Escalation Flag"
      display_name: "Escalation Flag"
      expr: escalation_flag
      comment: "Whether the plan requires escalation due to resource gaps"
    - name: "Planning Period Start Year"
      display_name: "Planning Period Start Year"
      expr: YEAR(planning_period_start_date)
      comment: "Year the planning period starts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Planning Period Start Month"
      display_name: "Planning Period Start Month"
      expr: DATE_TRUNC('month', planning_period_start_date)
      comment: "Month the planning period starts"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Resource Plans"
      display_name: "Total Resource Plans"
      expr: COUNT(1)
      comment: "Total count of program resource plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned FTE"
      display_name: "Total Planned FTE"
      expr: SUM(CAST(planned_fte_count AS DOUBLE))
      comment: "Sum of planned full-time equivalent headcount"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Forecasted FTE"
      display_name: "Total Forecasted FTE"
      expr: SUM(CAST(forecasted_fte_count AS DOUBLE))
      comment: "Sum of forecasted full-time equivalent headcount"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Actual FTE"
      display_name: "Total Actual FTE"
      expr: SUM(CAST(actual_fte_count AS DOUBLE))
      comment: "Sum of actual full-time equivalent headcount"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Resource Gap FTE"
      display_name: "Total Resource Gap FTE"
      expr: SUM(CAST(resource_gap_fte AS DOUBLE))
      comment: "Sum of resource gap in full-time equivalents"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Planned Cost"
      display_name: "Total Planned Cost"
      expr: SUM(CAST(planned_cost_usd AS DOUBLE))
      comment: "Sum of planned resource costs in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Forecasted Cost"
      display_name: "Total Forecasted Cost"
      expr: SUM(CAST(forecasted_cost_usd AS DOUBLE))
      comment: "Sum of forecasted resource costs in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Planned Hours"
      display_name: "Total Planned Hours"
      expr: SUM(CAST(planned_hours AS DOUBLE))
      comment: "Sum of planned resource hours"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Forecasted Hours"
      display_name: "Total Forecasted Hours"
      expr: SUM(CAST(forecasted_hours AS DOUBLE))
      comment: "Sum of forecasted resource hours"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Planned FTE Per Plan"
      display_name: "Average Planned FTE Per Plan"
      expr: AVG(CAST(planned_fte_count AS DOUBLE))
      comment: "Average planned FTE per resource plan"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Resource Gap FTE"
      display_name: "Average Resource Gap FTE"
      expr: AVG(CAST(resource_gap_fte AS DOUBLE))
      comment: "Average resource gap in FTE per plan"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "FTE Utilization Rate"
      display_name: "FTE Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(actual_fte_count AS DOUBLE)) / NULLIF(SUM(CAST(planned_fte_count AS DOUBLE)), 0), 2)
      comment: "Actual FTE as a percentage of planned FTE"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Resource Gap Rate"
      display_name: "Resource Gap Rate"
      expr: ROUND(100.0 * SUM(CAST(resource_gap_fte AS DOUBLE)) / NULLIF(SUM(CAST(planned_fte_count AS DOUBLE)), 0), 2)
      comment: "Resource gap as a percentage of planned FTE"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Cost Forecast Variance"
      display_name: "Cost Forecast Variance"
      expr: ROUND(100.0 * (SUM(CAST(forecasted_cost_usd AS DOUBLE)) - SUM(CAST(planned_cost_usd AS DOUBLE))) / NULLIF(SUM(CAST(planned_cost_usd AS DOUBLE)), 0), 2)
      comment: "Forecasted cost variance from planned cost as a percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`program_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Program risk portfolio management KPIs tracking risk exposure, mitigation effectiveness, and impact on timelines and budgets"
  source: "`clinical_trials_ecm`.`program`.`risk`"
  dimensions:
    - name: "Risk Identifier"
      display_name: "Risk Identifier"
      expr: identifier
      comment: "Unique identifier for the risk"
    - name: "Risk Title"
      display_name: "Risk Title"
      expr: title
      comment: "Title of the risk"
    - name: "Risk Category"
      display_name: "Risk Category"
      expr: risk_category
      comment: "Category of the risk (Regulatory, Clinical, Operational, Financial, Safety)"
    - name: "Risk Subcategory"
      display_name: "Risk Subcategory"
      expr: subcategory
      comment: "Subcategory of the risk"
    - name: "Risk Status"
      display_name: "Risk Status"
      expr: risk_status
      comment: "Current status of the risk (Open, Mitigated, Closed, Escalated)"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the risk (Critical, High, Medium, Low)"
    - name: "Impact Rating"
      display_name: "Impact Rating"
      expr: impact_rating
      comment: "Impact rating (Very High, High, Medium, Low, Very Low)"
    - name: "Probability Rating"
      display_name: "Probability Rating"
      expr: probability_rating
      comment: "Probability rating (Very High, High, Medium, Low, Very Low)"
    - name: "Residual Impact Rating"
      display_name: "Residual Impact Rating"
      expr: residual_impact_rating
      comment: "Residual impact rating after mitigation"
    - name: "Residual Probability Rating"
      display_name: "Residual Probability Rating"
      expr: residual_probability_rating
      comment: "Residual probability rating after mitigation"
    - name: "Patient Safety Impact Flag"
      display_name: "Patient Safety Impact Flag"
      expr: patient_safety_impact_flag
      comment: "Whether the risk impacts patient safety"
    - name: "Regulatory Impact Flag"
      display_name: "Regulatory Impact Flag"
      expr: regulatory_impact_flag
      comment: "Whether the risk impacts regulatory submissions or compliance"
    - name: "Escalation Required"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Whether the risk requires escalation"
    - name: "Identified Year"
      display_name: "Identified Year"
      expr: YEAR(identified_date)
      comment: "Year the risk was identified"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Identified Month"
      display_name: "Identified Month"
      expr: DATE_TRUNC('month', identified_date)
      comment: "Month the risk was identified"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Risks"
      display_name: "Total Risks"
      expr: COUNT(1)
      comment: "Total count of program risks"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Risks"
      display_name: "Open Risks"
      expr: SUM(CAST(CASE WHEN risk_status = 'Open' THEN 1 ELSE 0 END AS INT))
      comment: "Count of open risks"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Priority Risks"
      display_name: "Critical Priority Risks"
      expr: SUM(CAST(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END AS INT))
      comment: "Count of critical priority risks"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Patient Safety Risks"
      display_name: "Patient Safety Risks"
      expr: SUM(CAST(CASE WHEN patient_safety_impact_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of risks impacting patient safety"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Impact Risks"
      display_name: "Regulatory Impact Risks"
      expr: SUM(CAST(CASE WHEN regulatory_impact_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of risks impacting regulatory submissions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Required Risks"
      display_name: "Escalation Required Risks"
      expr: SUM(CAST(CASE WHEN escalation_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of risks requiring escalation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Risk Score"
      display_name: "Average Risk Score"
      expr: AVG(CAST(score AS DOUBLE))
      comment: "Average risk score (impact × probability)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Residual Risk Score"
      display_name: "Average Residual Risk Score"
      expr: AVG(CAST(residual_risk_score AS DOUBLE))
      comment: "Average residual risk score after mitigation"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Financial Exposure"
      display_name: "Total Financial Exposure"
      expr: SUM(CAST(financial_exposure_usd AS DOUBLE))
      comment: "Sum of financial exposure across all risks in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Financial Exposure"
      display_name: "Average Financial Exposure"
      expr: AVG(CAST(financial_exposure_usd AS DOUBLE))
      comment: "Average financial exposure per risk in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Timeline Impact Days"
      display_name: "Total Timeline Impact Days"
      expr: SUM(CAST(timeline_impact_days AS DOUBLE))
      comment: "Sum of timeline impact across all risks in days"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Timeline Impact Days"
      display_name: "Average Timeline Impact Days"
      expr: AVG(CAST(timeline_impact_days AS DOUBLE))
      comment: "Average timeline impact per risk in days"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Risk Mitigation Effectiveness"
      display_name: "Risk Mitigation Effectiveness"
      expr: ROUND(100.0 * (AVG(CAST(score AS DOUBLE)) - AVG(CAST(residual_risk_score AS DOUBLE))) / NULLIF(AVG(CAST(score AS DOUBLE)), 0), 2)
      comment: "Percentage reduction in risk score after mitigation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
