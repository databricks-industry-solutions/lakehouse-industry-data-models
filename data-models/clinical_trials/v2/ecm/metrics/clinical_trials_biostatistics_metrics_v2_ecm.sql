-- Metric views for domain: biostatistics | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_analysis`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core analysis execution metrics tracking analysis completion, cycle time, and output productivity across studies and reporting events."
  source: "`clinical_trials_ecm`.`biostatistics`.`analysis`"
  dimensions:
    - name: "Analysis Category"
      display_name: "Analysis Category"
      expr: analysis_category
      comment: "Type of analysis (efficacy, safety, PK, exploratory)"
    - name: "Analysis Purpose"
      display_name: "Purpose"
      expr: purpose
      comment: "Business purpose of the analysis"
    - name: "Study"
      display_name: "Study ID"
      expr: study_id
      comment: "Study identifier for cross-study analysis tracking"
    - name: "Analysis Year"
      display_name: "Analysis Year"
      expr: DATE_TRUNC('year', created_timestamp)
      comment: "Year the analysis was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Analysis Quarter"
      display_name: "Analysis Quarter"
      expr: DATE_TRUNC('quarter', created_timestamp)
      comment: "Quarter the analysis was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Analysis Month"
      display_name: "Analysis Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Month the analysis was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Analyses"
      display_name: "Total Analyses"
      expr: COUNT(DISTINCT analysis_id)
      comment: "Total number of distinct analyses executed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Analyses CM"
      display_name: "Analyses (Current Month)"
      expr: COUNT(DISTINCT analysis_id)
      comment: "Analyses created in current month"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Analysis Month
          range: current
          semiadditive: last
    - name: "Analyses PM"
      display_name: "Analyses (Prior Month)"
      expr: COUNT(DISTINCT analysis_id)
      comment: "Analyses created in prior month"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Analysis Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Analysis Growth MoM Pct"
      display_name: "Analysis Growth MoM %"
      expr: COUNT(1)
      comment: "Month-over-month growth rate in analysis volume"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Analyses YTD"
      display_name: "Analyses YTD"
      expr: COUNT(DISTINCT analysis_id)
      comment: "Year-to-date cumulative analyses created"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: created_timestamp
          range: cumulative
          semiadditive: last
        - order: Analysis Year
          range: current
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_analysis_population`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Analysis population metrics tracking ITT, PP, safety set definitions, subject counts, and population finalization for regulatory submissions"
  source: "`clinical_trials_ecm`.`biostatistics`.`analysis_population`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Foreign key to the clinical study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Population Type"
      display_name: "Population Type"
      expr: population_type
      comment: "Type of analysis population (ITT, PP, Safety, mITT, Per Protocol)"
    - name: "Population Status"
      display_name: "Population Status"
      expr: population_status
      comment: "Current status of the population definition (Draft, Final, Locked)"
    - name: "Primary Population Flag"
      display_name: "Primary Population Flag"
      expr: primary_population_flag
      comment: "Flag indicating if this is the primary analysis population"
    - name: "Regulatory Primary Flag"
      display_name: "Regulatory Primary Flag"
      expr: regulatory_primary_flag
      comment: "Flag indicating if this is the primary population for regulatory submission"
    - name: "Submission Population Flag"
      display_name: "Submission Population Flag"
      expr: submission_population_flag
      comment: "Flag indicating if this population will be included in regulatory submission"
    - name: "Sensitivity Analysis Flag"
      display_name: "Sensitivity Analysis Flag"
      expr: sensitivity_analysis_flag
      comment: "Flag indicating if this population is for sensitivity analysis"
    - name: "Analysis Phase"
      display_name: "Analysis Phase"
      expr: analysis_phase
      comment: "Phase of analysis (Interim, Final, Post-Hoc)"
    - name: "Blinding Status"
      display_name: "Blinding Status"
      expr: blinding_status
      comment: "Blinding status for the population (Blinded, Unblinded)"
    - name: "Validation Status"
      display_name: "Validation Status"
      expr: validation_status
      comment: "Validation status of the population definition"
  measures:
    - name: "Total Analysis Populations"
      display_name: "Total Analysis Populations"
      expr: COUNT(1)
      comment: "Total number of analysis population definitions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Studies with Populations"
      display_name: "Unique Studies with Populations"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with at least one analysis population defined"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Sample Size"
      display_name: "Total Planned Sample Size"
      expr: SUM(CAST(planned_sample_size AS DOUBLE))
      comment: "Sum of planned sample sizes across all analysis populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Planned Sample Size"
      display_name: "Average Planned Sample Size"
      expr: AVG(CAST(planned_sample_size AS DOUBLE))
      comment: "Average planned sample size per analysis population"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Subjects at DBL"
      display_name: "Total Subjects at DBL"
      expr: SUM(CAST(subject_count_at_dbl AS DOUBLE))
      comment: "Total number of subjects at database lock across all populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Subjects at DBL"
      display_name: "Average Subjects at DBL"
      expr: AVG(CAST(subject_count_at_dbl AS DOUBLE))
      comment: "Average number of subjects at database lock per population"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Interim Subjects"
      display_name: "Total Interim Subjects"
      expr: SUM(CAST(subject_count_interim AS DOUBLE))
      comment: "Total number of subjects at interim analysis across all populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Primary Populations"
      display_name: "Primary Populations"
      expr: COUNT(CASE WHEN primary_population_flag = TRUE THEN 1 END)
      comment: "Number of populations designated as primary analysis populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Primary Populations"
      display_name: "Regulatory Primary Populations"
      expr: COUNT(CASE WHEN regulatory_primary_flag = TRUE THEN 1 END)
      comment: "Number of populations designated as regulatory primary"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Populations"
      display_name: "Submission Populations"
      expr: COUNT(CASE WHEN submission_population_flag = TRUE THEN 1 END)
      comment: "Number of populations included in regulatory submission"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Population Rate"
      display_name: "Submission Population Rate"
      expr: CAST(COUNT(CASE WHEN submission_population_flag = TRUE THEN 1 END) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of populations included in regulatory submission"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Finalized Populations"
      display_name: "Finalized Populations"
      expr: COUNT(CASE WHEN population_status = 'Final' THEN 1 END)
      comment: "Number of populations with finalized definitions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Finalization Rate"
      display_name: "Finalization Rate"
      expr: CAST(COUNT(CASE WHEN population_status = 'Final' THEN 1 END) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of populations with finalized definitions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_database_lock_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Database lock event metrics tracking lock cycle time, query resolution efficiency, and data quality readiness for regulatory submissions."
  source: "`clinical_trials_ecm`.`biostatistics`.`database_lock_event`"
  dimensions:
    - name: "Lock Type"
      display_name: "Lock Type"
      expr: lock_type
      comment: "Type of database lock (interim, final, safety update)"
    - name: "Lock Status"
      display_name: "Lock Status"
      expr: lock_status
      comment: "Current status of the lock event"
    - name: "Lock Scope"
      display_name: "Lock Scope"
      expr: lock_scope
      comment: "Scope of the lock (full study, site subset, interim cohort)"
    - name: "Analysis Type"
      display_name: "Analysis Type"
      expr: analysis_type
      comment: "Type of analysis the lock supports (efficacy, safety, interim)"
    - name: "Lock Year"
      display_name: "Lock Year"
      expr: DATE_TRUNC('year', actual_lock_date)
      comment: "Year the database was locked"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Lock Quarter"
      display_name: "Lock Quarter"
      expr: DATE_TRUNC('quarter', actual_lock_date)
      comment: "Quarter the database was locked"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Lock Month"
      display_name: "Lock Month"
      expr: DATE_TRUNC('month', actual_lock_date)
      comment: "Month the database was locked"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Lock Events"
      display_name: "Total Lock Events"
      expr: COUNT(DISTINCT database_lock_event_id)
      comment: "Total number of database lock events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Locked"
      display_name: "Total Subjects Locked"
      expr: SUM(CAST(subjects_locked_count AS DOUBLE))
      comment: "Total number of subjects locked across all events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Subjects Per Lock"
      display_name: "Avg Subjects Per Lock"
      expr: AVG(CAST(subjects_locked_count AS DOUBLE))
      comment: "Average number of subjects locked per event"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Outstanding Queries"
      display_name: "Total Outstanding Queries"
      expr: SUM(CAST(outstanding_query_count AS DOUBLE))
      comment: "Total outstanding queries at lock time across all events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Outstanding Queries Per Lock"
      display_name: "Avg Outstanding Queries"
      expr: AVG(CAST(outstanding_query_count AS DOUBLE))
      comment: "Average outstanding queries per lock event (data quality indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Lock Cycle Time Days"
      display_name: "Lock Cycle Time (Days)"
      expr: AVG(DATEDIFF(actual_lock_date, planned_lock_date))
      comment: "Average days between planned and actual lock date (schedule adherence)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Lock Rate Pct"
      display_name: "On-Time Lock Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN actual_lock_date <= planned_lock_date THEN database_lock_event_id END) / NULLIF(COUNT(DISTINCT database_lock_event_id), 0)
      comment: "Percentage of locks completed on or before planned date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Coding Complete Rate Pct"
      display_name: "Coding Complete Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN coding_complete = TRUE THEN database_lock_event_id END) / NULLIF(COUNT(DISTINCT database_lock_event_id), 0)
      comment: "Percentage of locks with medical coding complete"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SDV Complete Rate Pct"
      display_name: "SDV Complete Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN sdv_complete = TRUE THEN database_lock_event_id END) / NULLIF(COUNT(DISTINCT database_lock_event_id), 0)
      comment: "Percentage of locks with source data verification complete"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_dsmb_meeting`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "DSMB meeting metrics tracking meeting frequency, quorum achievement, recommendation outcomes, and stopping boundary decisions."
  source: "`clinical_trials_ecm`.`biostatistics`.`dsmb_meeting`"
  dimensions:
    - name: "Meeting Type"
      display_name: "Meeting Type"
      expr: meeting_type
      comment: "Type of DSMB meeting (scheduled, ad-hoc, emergency)"
    - name: "Meeting Status"
      display_name: "Meeting Status"
      expr: meeting_status
      comment: "Status of the meeting (scheduled, completed, cancelled)"
    - name: "Session Type"
      display_name: "Session Type"
      expr: session_type
      comment: "Type of session (open, closed, executive)"
    - name: "Recommendation"
      display_name: "Recommendation"
      expr: recommendation
      comment: "DSMB recommendation outcome (continue, stop for efficacy, stop for futility, modify)"
    - name: "Stopping Boundary Crossed"
      display_name: "Stopping Boundary Crossed"
      expr: CASE WHEN stopping_boundary_crossed = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether a stopping boundary was crossed"
    - name: "Meeting Year"
      display_name: "Meeting Year"
      expr: DATE_TRUNC('year', meeting_date)
      comment: "Year the DSMB meeting was held"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Meeting Quarter"
      display_name: "Meeting Quarter"
      expr: DATE_TRUNC('quarter', meeting_date)
      comment: "Quarter the DSMB meeting was held"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total DSMB Meetings"
      display_name: "Total DSMB Meetings"
      expr: COUNT(DISTINCT dsmb_meeting_id)
      comment: "Total number of DSMB meetings held"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Meeting Duration Minutes"
      display_name: "Avg Meeting Duration (Minutes)"
      expr: AVG(CAST(meeting_duration_minutes AS DOUBLE))
      comment: "Average duration of DSMB meetings in minutes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Quorum Met Rate Pct"
      display_name: "Quorum Met Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN quorum_met = TRUE THEN dsmb_meeting_id END) / NULLIF(COUNT(DISTINCT dsmb_meeting_id), 0)
      comment: "Percentage of meetings where quorum was achieved"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Members Present"
      display_name: "Avg Members Present"
      expr: AVG(CAST(members_present_count AS DOUBLE))
      comment: "Average number of DSMB members present per meeting"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Stopping Boundary Crossed Rate Pct"
      display_name: "Stopping Boundary Crossed Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN stopping_boundary_crossed = TRUE THEN dsmb_meeting_id END) / NULLIF(COUNT(DISTINCT dsmb_meeting_id), 0)
      comment: "Percentage of meetings where a stopping boundary was crossed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Amendment Triggered Rate Pct"
      display_name: "Protocol Amendment Triggered Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN protocol_amendment_triggered = TRUE THEN dsmb_meeting_id END) / NULLIF(COUNT(DISTINCT dsmb_meeting_id), 0)
      comment: "Percentage of meetings that triggered a protocol amendment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unblinding Occurred Rate Pct"
      display_name: "Unblinding Occurred Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN unblinding_occurred = TRUE THEN dsmb_meeting_id END) / NULLIF(COUNT(DISTINCT dsmb_meeting_id), 0)
      comment: "Percentage of meetings where unblinding occurred"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg SAE Count Reviewed"
      display_name: "Avg SAE Count Reviewed"
      expr: AVG(CAST(sae_count_reviewed AS DOUBLE))
      comment: "Average number of serious adverse events reviewed per meeting"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Subjects Enrolled At Review"
      display_name: "Avg Subjects Enrolled At Review"
      expr: AVG(CAST(subjects_enrolled_at_review AS DOUBLE))
      comment: "Average number of subjects enrolled at time of DSMB review"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_interim_analysis`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Interim analysis metrics tracking adaptive trial decision-making, stopping rule triggers, and DSMB recommendation outcomes."
  source: "`clinical_trials_ecm`.`biostatistics`.`interim_analysis`"
  dimensions:
    - name: "Analysis Type"
      display_name: "Analysis Type"
      expr: analysis_type
      comment: "Type of interim analysis (efficacy, futility, safety, adaptive)"
    - name: "Analysis Status"
      display_name: "Analysis Status"
      expr: analysis_status
      comment: "Current status of the interim analysis"
    - name: "Analysis Outcome"
      display_name: "Analysis Outcome"
      expr: analysis_outcome
      comment: "Outcome decision (continue, stop for efficacy, stop for futility, adapt)"
    - name: "DSMB Involved"
      display_name: "DSMB Involved"
      expr: CASE WHEN dsmb_involved = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether DSMB reviewed this interim analysis"
    - name: "Stopping Rule Triggered"
      display_name: "Stopping Rule Triggered"
      expr: CASE WHEN stopping_rule_triggered = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether a stopping rule was triggered"
    - name: "Analysis Year"
      display_name: "Analysis Year"
      expr: DATE_TRUNC('year', actual_analysis_date)
      comment: "Year the interim analysis was conducted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Analysis Quarter"
      display_name: "Analysis Quarter"
      expr: DATE_TRUNC('quarter', actual_analysis_date)
      comment: "Quarter the interim analysis was conducted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Interim Analyses"
      display_name: "Total Interim Analyses"
      expr: COUNT(DISTINCT interim_analysis_id)
      comment: "Total number of interim analyses conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Information Fraction"
      display_name: "Avg Information Fraction"
      expr: AVG(CAST(information_fraction_actual AS DOUBLE))
      comment: "Average information fraction at interim analysis (trial progress indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Avg Conditional Power"
      display_name: "Avg Conditional Power"
      expr: AVG(CAST(conditional_power AS DOUBLE))
      comment: "Average conditional power at interim (probability of success given current data)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Stopping Rule Trigger Rate Pct"
      display_name: "Stopping Rule Trigger Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN stopping_rule_triggered = TRUE THEN interim_analysis_id END) / NULLIF(COUNT(DISTINCT interim_analysis_id), 0)
      comment: "Percentage of interim analyses where a stopping rule was triggered"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sample Size Reestimation Rate Pct"
      display_name: "Sample Size Reestimation Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN sample_size_reestimated = TRUE THEN interim_analysis_id END) / NULLIF(COUNT(DISTINCT interim_analysis_id), 0)
      comment: "Percentage of interim analyses that triggered sample size reestimation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Subjects Enrolled At Cutoff"
      display_name: "Avg Subjects Enrolled"
      expr: AVG(CAST(subjects_enrolled_at_cutoff AS DOUBLE))
      comment: "Average number of subjects enrolled at interim data cutoff"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Events Observed"
      display_name: "Avg Events Observed"
      expr: AVG(CAST(events_observed AS DOUBLE))
      comment: "Average number of events observed at interim analysis"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Event Accrual Rate Pct"
      display_name: "Event Accrual Rate %"
      expr: 100.0 * AVG(CAST(events_observed AS DOUBLE) / NULLIF(CAST(events_planned_total AS DOUBLE), 0))
      comment: "Average percentage of planned events observed at interim (event accrual progress)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_sample_size_calc`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sample size calculation metrics tracking statistical power, enrollment targets, and design assumptions across studies and amendments."
  source: "`clinical_trials_ecm`.`biostatistics`.`sample_size_calc`"
  dimensions:
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: study_phase
      comment: "Clinical trial phase (Phase I, II, III, IV)"
    - name: "Study Design Type"
      display_name: "Study Design Type"
      expr: study_design_type
      comment: "Type of study design (parallel, crossover, factorial)"
    - name: "Hypothesis Type"
      display_name: "Hypothesis Type"
      expr: hypothesis_type
      comment: "Type of hypothesis (superiority, non-inferiority, equivalence)"
    - name: "Primary Endpoint Type"
      display_name: "Primary Endpoint Type"
      expr: primary_endpoint_type
      comment: "Type of primary endpoint (continuous, binary, time-to-event)"
    - name: "Calc Status"
      display_name: "Calculation Status"
      expr: calc_status
      comment: "Status of the sample size calculation"
    - name: "Calc Year"
      display_name: "Calculation Year"
      expr: DATE_TRUNC('year', calc_date)
      comment: "Year the sample size calculation was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Sample Size Calcs"
      display_name: "Total Sample Size Calculations"
      expr: COUNT(DISTINCT sample_size_calc_id)
      comment: "Total number of sample size calculations performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Total Sample Size"
      display_name: "Avg Total Sample Size"
      expr: AVG(CAST(total_sample_size AS DOUBLE))
      comment: "Average total sample size across calculations"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Power"
      display_name: "Avg Power"
      expr: AVG(CAST(power AS DOUBLE))
      comment: "Average statistical power across calculations (typically 0.80 or 0.90)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Avg Alpha Level"
      display_name: "Avg Alpha Level"
      expr: AVG(CAST(alpha_level AS DOUBLE))
      comment: "Average significance level across calculations (typically 0.05)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Dropout Rate"
      display_name: "Avg Dropout Rate"
      expr: AVG(CAST(dropout_rate AS DOUBLE))
      comment: "Average assumed dropout rate across calculations"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Avg Allocation Ratio"
      display_name: "Avg Allocation Ratio"
      expr: AVG(CAST(allocation_ratio AS DOUBLE))
      comment: "Average treatment allocation ratio across calculations"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Effect Size"
      display_name: "Avg Effect Size"
      expr: AVG(CAST(effect_size AS DOUBLE))
      comment: "Average assumed effect size across calculations"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Interim Analysis Planned Rate Pct"
      display_name: "Interim Analysis Planned Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN interim_analysis_planned = TRUE THEN sample_size_calc_id END) / NULLIF(COUNT(DISTINCT sample_size_calc_id), 0)
      comment: "Percentage of calculations with interim analyses planned"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Accrual Period Months"
      display_name: "Avg Accrual Period (Months)"
      expr: AVG(CAST(accrual_period_months AS DOUBLE))
      comment: "Average planned accrual period in months"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_sap`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Statistical Analysis Plan metrics tracking SAP version control, amendment frequency, regulatory alignment, and approval cycle time."
  source: "`clinical_trials_ecm`.`biostatistics`.`sap`"
  dimensions:
    - name: "Version Status"
      display_name: "Version Status"
      expr: version_status
      comment: "Status of the SAP version (draft, final, superseded)"
    - name: "Analysis Type"
      display_name: "Analysis Type"
      expr: analysis_type
      comment: "Type of analysis the SAP covers (primary, interim, final)"
    - name: "Blinding Status"
      display_name: "Blinding Status"
      expr: blinding_status
      comment: "Blinding status of the SAP (blinded, unblinded)"
    - name: "DSMB Review Required"
      display_name: "DSMB Review Required"
      expr: CASE WHEN dsmb_review_required = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether DSMB review is required for this SAP"
    - name: "Approval Year"
      display_name: "Approval Year"
      expr: DATE_TRUNC('year', approval_date)
      comment: "Year the SAP was approved"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Approval Quarter"
      display_name: "Approval Quarter"
      expr: DATE_TRUNC('quarter', approval_date)
      comment: "Quarter the SAP was approved"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total SAPs"
      display_name: "Total SAPs"
      expr: COUNT(DISTINCT sap_id)
      comment: "Total number of Statistical Analysis Plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Amendment Count"
      display_name: "Avg Amendment Count"
      expr: AVG(CAST(amendment_number AS DOUBLE))
      comment: "Average number of amendments per SAP (change control indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Interim Analysis Count"
      display_name: "Avg Interim Analysis Count"
      expr: AVG(CAST(interim_analysis_count AS DOUBLE))
      comment: "Average number of planned interim analyses per SAP"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Sample Size"
      display_name: "Avg Sample Size"
      expr: AVG(CAST(sample_size AS DOUBLE))
      comment: "Average planned sample size across SAPs"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Power Percent"
      display_name: "Avg Power %"
      expr: AVG(CAST(power_percent AS DOUBLE))
      comment: "Average statistical power percentage across SAPs"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Significance Level"
      display_name: "Avg Significance Level"
      expr: AVG(CAST(significance_level AS DOUBLE))
      comment: "Average significance level (alpha) across SAPs"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Current Version Rate Pct"
      display_name: "Current Version Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN is_current_version = TRUE THEN sap_id END) / NULLIF(COUNT(DISTINCT sap_id), 0)
      comment: "Percentage of SAPs that are current versions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "DSMB Review Required Rate Pct"
      display_name: "DSMB Review Required Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN dsmb_review_required = TRUE THEN sap_id END) / NULLIF(COUNT(DISTINCT sap_id), 0)
      comment: "Percentage of SAPs requiring DSMB review"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`biostatistics_tlf_output`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "TLF output production metrics tracking programming productivity, QC cycle time, approval rates, and discrepancy resolution efficiency."
  source: "`clinical_trials_ecm`.`biostatistics`.`tlf_output`"
  dimensions:
    - name: "Output Type"
      display_name: "Output Type"
      expr: output_type
      comment: "Type of output (table, listing, figure)"
    - name: "Output Category"
      display_name: "Output Category"
      expr: output_category
      comment: "Category of output (efficacy, safety, demographics, disposition)"
    - name: "Analysis Type"
      display_name: "Analysis Type"
      expr: analysis_type
      comment: "Type of analysis the output supports"
    - name: "QC Status"
      display_name: "QC Status"
      expr: qc_status
      comment: "Quality control status of the output"
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the output"
    - name: "Blinding Status"
      display_name: "Blinding Status"
      expr: blinding_status
      comment: "Blinding status of the output (blinded, unblinded)"
    - name: "Production Year"
      display_name: "Production Year"
      expr: DATE_TRUNC('year', production_run_timestamp)
      comment: "Year the output was produced"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Production Quarter"
      display_name: "Production Quarter"
      expr: DATE_TRUNC('quarter', production_run_timestamp)
      comment: "Quarter the output was produced"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Production Month"
      display_name: "Production Month"
      expr: DATE_TRUNC('month', production_run_timestamp)
      comment: "Month the output was produced"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total TLF Outputs"
      display_name: "Total TLF Outputs"
      expr: COUNT(DISTINCT tlf_output_id)
      comment: "Total number of TLF outputs produced"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Outputs CM"
      display_name: "Outputs (Current Month)"
      expr: COUNT(DISTINCT tlf_output_id)
      comment: "TLF outputs produced in current month"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Production Month
          range: current
          semiadditive: last
    - name: "Outputs PM"
      display_name: "Outputs (Prior Month)"
      expr: COUNT(DISTINCT tlf_output_id)
      comment: "TLF outputs produced in prior month"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Production Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Output Growth MoM Pct"
      display_name: "Output Growth MoM %"
      expr: COUNT(1)
      comment: "Month-over-month growth rate in TLF output production"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Discrepancies"
      display_name: "Total Discrepancies"
      expr: SUM(CAST(discrepancy_count AS DOUBLE))
      comment: "Total number of discrepancies identified across all outputs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Discrepancies Per Output"
      display_name: "Avg Discrepancies Per Output"
      expr: AVG(CAST(discrepancy_count AS DOUBLE))
      comment: "Average number of discrepancies per output (quality indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "QC Cycle Time Hours"
      display_name: "QC Cycle Time (Hours)"
      expr: AVG((UNIX_TIMESTAMP(qc_completion_timestamp) - UNIX_TIMESTAMP(production_run_timestamp)) / 3600.0)
      comment: "Average hours from production to QC completion"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Approval Cycle Time Hours"
      display_name: "Approval Cycle Time (Hours)"
      expr: AVG((UNIX_TIMESTAMP(approval_timestamp) - UNIX_TIMESTAMP(qc_completion_timestamp)) / 3600.0)
      comment: "Average hours from QC completion to approval"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "First Pass QC Rate Pct"
      display_name: "First Pass QC Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN discrepancy_count = 0 THEN tlf_output_id END) / NULLIF(COUNT(DISTINCT tlf_output_id), 0)
      comment: "Percentage of outputs with zero discrepancies (first-pass quality)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Final Version Rate Pct"
      display_name: "Final Version Rate %"
      expr: 100.0 * COUNT(DISTINCT CASE WHEN is_final_version = TRUE THEN tlf_output_id END) / NULLIF(COUNT(DISTINCT tlf_output_id), 0)
      comment: "Percentage of outputs marked as final version"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
