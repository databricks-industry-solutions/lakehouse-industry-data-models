-- Metric views for domain: site | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_activation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site activation process tracking and timeline metrics for study startup"
  source: "`clinical_trials_ecm`.`site`.`activation`"
  dimensions:
    - name: "Activation Status"
      display_name: "Activation Status"
      expr: activation_status
      comment: "Current status of site activation process"
    - name: "Activation Type"
      display_name: "Activation Type"
      expr: activation_type
      comment: "Type of site activation"
    - name: "Country Code"
      display_name: "Country Code"
      expr: country_code
      comment: "Country code of activating site"
    - name: "SIV Status"
      display_name: "SIV Status"
      expr: siv_status
      comment: "Site initiation visit status"
    - name: "IRB IEC Status"
      display_name: "IRB/IEC Status"
      expr: irb_iec_status
      comment: "Institutional Review Board / Independent Ethics Committee status"
    - name: "CDA Status"
      display_name: "CDA Status"
      expr: cda_status
      comment: "Confidentiality disclosure agreement status"
    - name: "Regulatory Pkg Status"
      display_name: "Regulatory Pkg Status"
      expr: regulatory_pkg_status
      comment: "Regulatory package submission status"
    - name: "Actual Activation Year"
      display_name: "Actual Activation Year"
      expr: DATE_TRUNC('year', actual_activation_date)
      comment: "Year of actual site activation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Activation Quarter"
      display_name: "Actual Activation Quarter"
      expr: DATE_TRUNC('quarter', actual_activation_date)
      comment: "Quarter of actual site activation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Activation Month"
      display_name: "Actual Activation Month"
      expr: DATE_TRUNC('month', actual_activation_date)
      comment: "Month of actual site activation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Activations"
      display_name: "Total Activations"
      expr: COUNT(DISTINCT activation_id)
      comment: "Total number of site activations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Enrollment Target"
      display_name: "Total Planned Enrollment Target"
      expr: SUM(CAST(planned_enrollment_target AS DOUBLE))
      comment: "Total planned enrollment target across activating sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Planned Enrollment Target"
      display_name: "Avg Planned Enrollment Target"
      expr: AVG(CAST(planned_enrollment_target AS DOUBLE))
      comment: "Average planned enrollment target per activating site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days Elapsed"
      display_name: "Avg Days Elapsed"
      expr: AVG(CAST(days_elapsed AS DOUBLE))
      comment: "Average days elapsed in activation process"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_capacity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site capacity and capability assessment metrics for site selection and resource planning"
  source: "`clinical_trials_ecm`.`site`.`capacity`"
  dimensions:
    - name: "Capacity Status"
      display_name: "Capacity Status"
      expr: capacity_status
      comment: "Current capacity status of the site"
    - name: "Capacity Type"
      display_name: "Capacity Type"
      expr: capacity_type
      comment: "Type of capacity assessment"
    - name: "GCP Compliance Status"
      display_name: "GCP Compliance Status"
      expr: gcp_compliance_status
      comment: "Good Clinical Practice compliance status"
    - name: "EDC System Capable"
      display_name: "EDC System Capable"
      expr: CASE WHEN edc_system_capable = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether site has electronic data capture capability"
    - name: "IRT RTSM Capable"
      display_name: "IRT/RTSM Capable"
      expr: CASE WHEN irt_rtsm_capable = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether site has interactive response technology capability"
    - name: "Lab Processing Capable"
      display_name: "Lab Processing Capable"
      expr: CASE WHEN lab_processing_capable = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether site has laboratory processing capability"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of capacity assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter of capacity assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of capacity assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Capacity Assessments"
      display_name: "Total Capacity Assessments"
      expr: COUNT(DISTINCT capacity_id)
      comment: "Total number of site capacity assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Max Concurrent Subjects"
      display_name: "Total Max Concurrent Subjects"
      expr: SUM(CAST(max_concurrent_subjects AS DOUBLE))
      comment: "Total maximum concurrent subjects capacity across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Max Concurrent Subjects"
      display_name: "Avg Max Concurrent Subjects"
      expr: AVG(CAST(max_concurrent_subjects AS DOUBLE))
      comment: "Average maximum concurrent subjects capacity per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Max Concurrent Protocols"
      display_name: "Total Max Concurrent Protocols"
      expr: SUM(CAST(max_concurrent_protocols AS DOUBLE))
      comment: "Total maximum concurrent protocols capacity across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Max Concurrent Protocols"
      display_name: "Avg Max Concurrent Protocols"
      expr: AVG(CAST(max_concurrent_protocols AS DOUBLE))
      comment: "Average maximum concurrent protocols capacity per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Annual Patient Pool"
      display_name: "Total Annual Patient Pool"
      expr: SUM(CAST(annual_patient_pool_size AS DOUBLE))
      comment: "Total annual patient pool size across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Annual Patient Pool"
      display_name: "Avg Annual Patient Pool"
      expr: AVG(CAST(annual_patient_pool_size AS DOUBLE))
      comment: "Average annual patient pool size per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Avg Recruitment Rate Per Month"
      display_name: "Avg Recruitment Rate Per Month"
      expr: AVG(CAST(recruitment_rate_per_month AS DOUBLE))
      comment: "Average monthly recruitment rate across sites"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Screen Failure Rate Pct"
      display_name: "Avg Screen Failure Rate %"
      expr: AVG(CAST(screen_failure_rate_pct AS DOUBLE))
      comment: "Average screen failure rate percentage across sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Dropout Rate Pct"
      display_name: "Avg Dropout Rate %"
      expr: AVG(CAST(dropout_rate_pct AS DOUBLE))
      comment: "Average dropout rate percentage across sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Utilization Pct"
      display_name: "Avg Utilization %"
      expr: AVG(CAST(utilization_pct AS DOUBLE))
      comment: "Average site utilization percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Site Selection Score"
      display_name: "Avg Site Selection Score"
      expr: AVG(CAST(site_selection_score AS DOUBLE))
      comment: "Average site selection score across assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Available Exam Rooms"
      display_name: "Total Available Exam Rooms"
      expr: SUM(CAST(available_exam_rooms AS DOUBLE))
      comment: "Total available exam rooms across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Available Exam Rooms"
      display_name: "Avg Available Exam Rooms"
      expr: AVG(CAST(available_exam_rooms AS DOUBLE))
      comment: "Average available exam rooms per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total CRC Count"
      display_name: "Total CRC Count"
      expr: SUM(CAST(crc_count AS DOUBLE))
      comment: "Total clinical research coordinators across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg CRC Count"
      display_name: "Avg CRC Count"
      expr: AVG(CAST(crc_count AS DOUBLE))
      comment: "Average clinical research coordinators per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Dedicated Research FTE"
      display_name: "Avg Dedicated Research FTE"
      expr: AVG(CAST(dedicated_research_fte AS DOUBLE))
      comment: "Average dedicated research full-time equivalents per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg PI FTE Allocation"
      display_name: "Avg PI FTE Allocation"
      expr: AVG(CAST(pi_fte_allocation AS DOUBLE))
      comment: "Average principal investigator FTE allocation per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Competing Protocols"
      display_name: "Total Competing Protocols"
      expr: SUM(CAST(competing_protocol_count AS DOUBLE))
      comment: "Total competing protocols across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Competing Protocols"
      display_name: "Avg Competing Protocols"
      expr: AVG(CAST(competing_protocol_count AS DOUBLE))
      comment: "Average competing protocols per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_closeout`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site closeout process tracking and completion metrics for study termination"
  source: "`clinical_trials_ecm`.`site`.`closeout`"
  dimensions:
    - name: "Closeout Status"
      display_name: "Closeout Status"
      expr: closeout_status
      comment: "Current status of site closeout process"
    - name: "Closeout Type"
      display_name: "Closeout Type"
      expr: closeout_type
      comment: "Type of site closeout (normal, early termination)"
    - name: "Early Termination Reason"
      display_name: "Early Termination Reason"
      expr: early_termination_reason
      comment: "Reason for early site termination if applicable"
    - name: "GCP Compliance Status"
      display_name: "GCP Compliance Status"
      expr: gcp_compliance_status
      comment: "Good Clinical Practice compliance status at closeout"
    - name: "Drug Accountability Status"
      display_name: "Drug Accountability Status"
      expr: drug_accountability_status
      comment: "Status of drug accountability reconciliation"
    - name: "Final Payment Status"
      display_name: "Final Payment Status"
      expr: final_payment_status
      comment: "Status of final site payment"
    - name: "Completed Year"
      display_name: "Completed Year"
      expr: DATE_TRUNC('year', completed_date)
      comment: "Year of closeout completion"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completed Quarter"
      display_name: "Completed Quarter"
      expr: DATE_TRUNC('quarter', completed_date)
      comment: "Quarter of closeout completion"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completed Month"
      display_name: "Completed Month"
      expr: DATE_TRUNC('month', completed_date)
      comment: "Month of closeout completion"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Closeouts"
      display_name: "Total Closeouts"
      expr: COUNT(DISTINCT closeout_id)
      comment: "Total number of site closeouts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Enrolled"
      display_name: "Total Subjects Enrolled"
      expr: SUM(CAST(subjects_enrolled_count AS DOUBLE))
      comment: "Total subjects enrolled at closed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Completed"
      display_name: "Total Subjects Completed"
      expr: SUM(CAST(subjects_completed_count AS DOUBLE))
      comment: "Total subjects completed at closed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Discontinued"
      display_name: "Total Subjects Discontinued"
      expr: SUM(CAST(subjects_discontinued_count AS DOUBLE))
      comment: "Total subjects discontinued at closed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subject Completion Rate"
      display_name: "Subject Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(subjects_completed_count AS DOUBLE)) / NULLIF(SUM(CAST(subjects_enrolled_count AS DOUBLE)), 0), 2)
      comment: "Percentage of enrolled subjects who completed at closed sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Discontinuation Rate"
      display_name: "Subject Discontinuation Rate"
      expr: ROUND(100.0 * SUM(CAST(subjects_discontinued_count AS DOUBLE)) / NULLIF(SUM(CAST(subjects_enrolled_count AS DOUBLE)), 0), 2)
      comment: "Percentage of enrolled subjects who discontinued at closed sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Protocol Deviations"
      display_name: "Total Protocol Deviations"
      expr: SUM(CAST(protocol_deviations_count AS DOUBLE))
      comment: "Total protocol deviations at closed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Protocol Deviations Per Site"
      display_name: "Avg Protocol Deviations Per Site"
      expr: AVG(CAST(protocol_deviations_count AS DOUBLE))
      comment: "Average protocol deviations per closed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Outstanding Queries"
      display_name: "Total Outstanding Queries"
      expr: SUM(CAST(outstanding_queries_count AS DOUBLE))
      comment: "Total outstanding queries at closeout"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg SDV Completion Pct"
      display_name: "Avg SDV Completion %"
      expr: AVG(CAST(sdv_completion_percentage AS DOUBLE))
      comment: "Average source data verification completion percentage at closeout"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Final Payment Amount"
      display_name: "Total Final Payment Amount"
      expr: SUM(CAST(final_payment_amount AS DOUBLE))
      comment: "Total final payment amount to closed sites"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Final Payment Amount"
      display_name: "Avg Final Payment Amount"
      expr: AVG(CAST(final_payment_amount AS DOUBLE))
      comment: "Average final payment amount per closed site"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_enrollment_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Enrollment performance tracking and forecasting metrics by site and reporting period"
  source: "`clinical_trials_ecm`.`site`.`enrollment_performance`"
  dimensions:
    - name: "Site Number"
      display_name: "Site Number"
      expr: site_number
      comment: "Site identifier for enrollment tracking"
    - name: "Performance Status"
      display_name: "Performance Status"
      expr: performance_status
      comment: "Site enrollment performance status classification"
    - name: "Reporting Period Type"
      display_name: "Reporting Period Type"
      expr: reporting_period_type
      comment: "Type of reporting period (weekly, monthly, quarterly)"
    - name: "GCP Compliance Status"
      display_name: "GCP Compliance Status"
      expr: gcp_compliance_status
      comment: "Good Clinical Practice compliance status"
    - name: "IRB IEC Approval Status"
      display_name: "IRB/IEC Approval Status"
      expr: irb_iec_approval_status
      comment: "Institutional Review Board / Independent Ethics Committee approval status"
    - name: "Reporting Period Start Year"
      display_name: "Reporting Period Start Year"
      expr: DATE_TRUNC('year', reporting_period_start_date)
      comment: "Year of reporting period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Reporting Period Start Quarter"
      display_name: "Reporting Period Start Quarter"
      expr: DATE_TRUNC('quarter', reporting_period_start_date)
      comment: "Quarter of reporting period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Reporting Period Start Month"
      display_name: "Reporting Period Start Month"
      expr: DATE_TRUNC('month', reporting_period_start_date)
      comment: "Month of reporting period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Reporting Periods"
      display_name: "Total Reporting Periods"
      expr: COUNT(DISTINCT enrollment_performance_id)
      comment: "Total number of enrollment performance reporting periods"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Enrolled"
      display_name: "Total Actual Enrolled"
      expr: SUM(CAST(actual_enrolled_count AS DOUBLE))
      comment: "Total actual subjects enrolled in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Enrolled"
      display_name: "Total Planned Enrolled"
      expr: SUM(CAST(planned_enrolled_count AS DOUBLE))
      comment: "Total planned subjects to be enrolled in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Screened"
      display_name: "Total Actual Screened"
      expr: SUM(CAST(actual_screened_count AS DOUBLE))
      comment: "Total actual subjects screened in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Screened"
      display_name: "Total Planned Screened"
      expr: SUM(CAST(planned_screened_count AS DOUBLE))
      comment: "Total planned subjects to be screened in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enrollment Plan Achievement"
      display_name: "Enrollment Plan Achievement"
      expr: ROUND(100.0 * SUM(CAST(actual_enrolled_count AS DOUBLE)) / NULLIF(SUM(CAST(planned_enrolled_count AS DOUBLE)), 0), 2)
      comment: "Percentage of planned enrollment achieved in reporting period"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Screening Plan Achievement"
      display_name: "Screening Plan Achievement"
      expr: ROUND(100.0 * SUM(CAST(actual_screened_count AS DOUBLE)) / NULLIF(SUM(CAST(planned_screened_count AS DOUBLE)), 0), 2)
      comment: "Percentage of planned screening achieved in reporting period"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cumulative Enrolled"
      display_name: "Total Cumulative Enrolled"
      expr: SUM(CAST(cumulative_enrolled_count AS DOUBLE))
      comment: "Total cumulative subjects enrolled to date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Cumulative Screened"
      display_name: "Total Cumulative Screened"
      expr: SUM(CAST(cumulative_screened_count AS DOUBLE))
      comment: "Total cumulative subjects screened to date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Screen Failures"
      display_name: "Total Screen Failures"
      expr: SUM(CAST(screen_failure_count AS DOUBLE))
      comment: "Total screen failures in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Screen Failure Rate"
      display_name: "Avg Screen Failure Rate"
      expr: AVG(CAST(screen_failure_rate AS DOUBLE))
      comment: "Average screen failure rate across sites in reporting period"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Dropouts"
      display_name: "Total Dropouts"
      expr: SUM(CAST(dropout_count AS DOUBLE))
      comment: "Total subject dropouts in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Dropout Rate"
      display_name: "Avg Dropout Rate"
      expr: AVG(CAST(dropout_rate AS DOUBLE))
      comment: "Average dropout rate across sites in reporting period"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Randomized"
      display_name: "Total Randomized"
      expr: SUM(CAST(randomized_count AS DOUBLE))
      comment: "Total subjects randomized in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Completed"
      display_name: "Total Completed"
      expr: SUM(CAST(completed_count AS DOUBLE))
      comment: "Total subjects completed in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Enrollment Rate Per Month"
      display_name: "Avg Enrollment Rate Per Month"
      expr: AVG(CAST(enrollment_rate_per_month AS DOUBLE))
      comment: "Average monthly enrollment rate across sites"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target Achievement Pct"
      display_name: "Avg Target Achievement %"
      expr: AVG(CAST(enrollment_target_achievement_pct AS DOUBLE))
      comment: "Average enrollment target achievement percentage across sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total SAEs"
      display_name: "Total SAEs"
      expr: SUM(CAST(sae_count AS DOUBLE))
      comment: "Total serious adverse events in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Protocol Deviations"
      display_name: "Total Protocol Deviations"
      expr: SUM(CAST(protocol_deviation_count AS DOUBLE))
      comment: "Total protocol deviations in reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Open Queries"
      display_name: "Total Open Queries"
      expr: SUM(CAST(open_query_count AS DOUBLE))
      comment: "Total open data queries in reporting period"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_feasibility_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site feasibility assessment and selection scoring metrics for site qualification"
  source: "`clinical_trials_ecm`.`site`.`feasibility_assessment`"
  dimensions:
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Current status of feasibility assessment"
    - name: "Selection Decision"
      display_name: "Selection Decision"
      expr: selection_decision
      comment: "Final site selection decision (selected, rejected, pending)"
    - name: "Feasibility Score Tier"
      display_name: "Feasibility Score Tier"
      expr: feasibility_score_tier
      comment: "Tier classification of feasibility score"
    - name: "Phase"
      display_name: "Phase"
      expr: phase
      comment: "Clinical trial phase for feasibility assessment"
    - name: "Site Region"
      display_name: "Site Region"
      expr: site_region
      comment: "Geographic region of assessed site"
    - name: "Site Country Code"
      display_name: "Site Country Code"
      expr: site_country_code
      comment: "Country code of assessed site"
    - name: "IRB IEC Status"
      display_name: "IRB/IEC Status"
      expr: irb_iec_status
      comment: "Institutional Review Board / Independent Ethics Committee status"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of feasibility assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter of feasibility assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of feasibility assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Assessments"
      display_name: "Total Assessments"
      expr: COUNT(DISTINCT feasibility_assessment_id)
      comment: "Total number of feasibility assessments conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Feasibility Score"
      display_name: "Avg Feasibility Score"
      expr: AVG(CAST(feasibility_score AS DOUBLE))
      comment: "Average feasibility score across assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Site Infrastructure Score"
      display_name: "Avg Site Infrastructure Score"
      expr: AVG(CAST(site_infrastructure_score AS DOUBLE))
      comment: "Average site infrastructure score across assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Regulatory Compliance Score"
      display_name: "Avg Regulatory Compliance Score"
      expr: AVG(CAST(regulatory_compliance_score AS DOUBLE))
      comment: "Average regulatory compliance score across assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Enrollment Experience Score"
      display_name: "Avg Enrollment Experience Score"
      expr: AVG(CAST(enrollment_experience_score AS DOUBLE))
      comment: "Average enrollment experience score across assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Patient Population"
      display_name: "Total Patient Population"
      expr: SUM(CAST(patient_population_size AS DOUBLE))
      comment: "Total patient population size across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Patient Population"
      display_name: "Avg Patient Population"
      expr: AVG(CAST(patient_population_size AS DOUBLE))
      comment: "Average patient population size per assessed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Total Enrollment Capacity"
      display_name: "Total Enrollment Capacity"
      expr: SUM(CAST(estimated_enrollment_capacity AS DOUBLE))
      comment: "Total estimated enrollment capacity across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Enrollment Capacity"
      display_name: "Avg Enrollment Capacity"
      expr: AVG(CAST(estimated_enrollment_capacity AS DOUBLE))
      comment: "Average estimated enrollment capacity per assessed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Screen Failure Rate"
      display_name: "Avg Screen Failure Rate"
      expr: AVG(CAST(estimated_screen_failure_rate AS DOUBLE))
      comment: "Average estimated screen failure rate across assessed sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Competing Trials"
      display_name: "Total Competing Trials"
      expr: SUM(CAST(competing_trial_count AS DOUBLE))
      comment: "Total competing trials across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Competing Trials"
      display_name: "Avg Competing Trials"
      expr: AVG(CAST(competing_trial_count AS DOUBLE))
      comment: "Average competing trials per assessed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Prior Study Experience"
      display_name: "Total Prior Study Experience"
      expr: SUM(CAST(prior_study_experience_count AS DOUBLE))
      comment: "Total prior study experience count across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Prior Study Experience"
      display_name: "Avg Prior Study Experience"
      expr: AVG(CAST(prior_study_experience_count AS DOUBLE))
      comment: "Average prior study experience count per assessed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Dedicated Research Staff"
      display_name: "Total Dedicated Research Staff"
      expr: SUM(CAST(dedicated_research_staff_count AS DOUBLE))
      comment: "Total dedicated research staff across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Dedicated Research Staff"
      display_name: "Avg Dedicated Research Staff"
      expr: AVG(CAST(dedicated_research_staff_count AS DOUBLE))
      comment: "Average dedicated research staff per assessed site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Site Selection Rate"
      display_name: "Site Selection Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN selection_decision = 'selected' THEN feasibility_assessment_id END) / NULLIF(COUNT(DISTINCT feasibility_assessment_id), 0), 2)
      comment: "Percentage of assessed sites that were selected"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`site_study_site`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core site performance metrics tracking enrollment, screening, and operational efficiency across investigational sites"
  source: "`clinical_trials_ecm`.`site`.`study_site`"
  dimensions:
    - name: "Site Number"
      display_name: "Site Number"
      expr: site_number
      comment: "Unique identifier for the study site"
    - name: "Site Status"
      display_name: "Site Status"
      expr: site_status
      comment: "Current operational status of the site (active, closed, on-hold)"
    - name: "Risk Tier"
      display_name: "Risk Tier"
      expr: risk_tier
      comment: "Risk classification tier for monitoring intensity"
    - name: "GCP Compliance Status"
      display_name: "GCP Compliance Status"
      expr: gcp_compliance_status
      comment: "Good Clinical Practice compliance status"
    - name: "Budget Currency"
      display_name: "Budget Currency"
      expr: budget_currency
      comment: "Currency code for site budget"
    - name: "Enrollment Open Year"
      display_name: "Enrollment Open Year"
      expr: DATE_TRUNC('year', enrollment_open_date)
      comment: "Year when enrollment opened at site"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Open Quarter"
      display_name: "Enrollment Open Quarter"
      expr: DATE_TRUNC('quarter', enrollment_open_date)
      comment: "Quarter when enrollment opened at site"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Open Month"
      display_name: "Enrollment Open Month"
      expr: DATE_TRUNC('month', enrollment_open_date)
      comment: "Month when enrollment opened at site"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Sites"
      display_name: "Total Sites"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Total number of unique study sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Enrolled"
      display_name: "Total Enrolled"
      expr: SUM(CAST(enrolled_count AS DOUBLE))
      comment: "Total number of subjects enrolled across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Screened"
      display_name: "Total Screened"
      expr: SUM(CAST(screened_count AS DOUBLE))
      comment: "Total number of subjects screened across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Screen Failures"
      display_name: "Total Screen Failures"
      expr: SUM(CAST(screen_failure_count AS DOUBLE))
      comment: "Total number of screen failures across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Withdrawn"
      display_name: "Total Withdrawn"
      expr: SUM(CAST(withdrawn_count AS DOUBLE))
      comment: "Total number of subjects withdrawn across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screen Failure Rate"
      display_name: "Screen Failure Rate"
      expr: ROUND(100.0 * SUM(CAST(screen_failure_count AS DOUBLE)) / NULLIF(SUM(CAST(screened_count AS DOUBLE)), 0), 2)
      comment: "Percentage of screened subjects who failed screening"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Enrollment Conversion Rate"
      display_name: "Enrollment Conversion Rate"
      expr: ROUND(100.0 * SUM(CAST(enrolled_count AS DOUBLE)) / NULLIF(SUM(CAST(screened_count AS DOUBLE)), 0), 2)
      comment: "Percentage of screened subjects who were enrolled"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Withdrawal Rate"
      display_name: "Withdrawal Rate"
      expr: ROUND(100.0 * SUM(CAST(withdrawn_count AS DOUBLE)) / NULLIF(SUM(CAST(enrolled_count AS DOUBLE)), 0), 2)
      comment: "Percentage of enrolled subjects who withdrew"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Enrolled Per Site"
      display_name: "Avg Enrolled Per Site"
      expr: AVG(CAST(enrolled_count AS DOUBLE))
      comment: "Average number of subjects enrolled per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Enrollment Target"
      display_name: "Total Enrollment Target"
      expr: SUM(CAST(enrollment_target AS DOUBLE))
      comment: "Total enrollment target across all sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enrollment Target Achievement"
      display_name: "Enrollment Target Achievement"
      expr: ROUND(100.0 * SUM(CAST(enrolled_count AS DOUBLE)) / NULLIF(SUM(CAST(enrollment_target AS DOUBLE)), 0), 2)
      comment: "Percentage of enrollment target achieved"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Budget Amount"
      display_name: "Total Budget Amount"
      expr: SUM(CAST(budget_agreed_amount AS DOUBLE))
      comment: "Total agreed budget amount across sites"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Budget Per Site"
      display_name: "Avg Budget Per Site"
      expr: AVG(CAST(budget_agreed_amount AS DOUBLE))
      comment: "Average budget amount per site"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total SAEs"
      display_name: "Total SAEs"
      expr: SUM(CAST(sae_count AS DOUBLE))
      comment: "Total serious adverse events reported across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Protocol Deviations"
      display_name: "Total Protocol Deviations"
      expr: SUM(CAST(protocol_deviation_count AS DOUBLE))
      comment: "Total protocol deviations across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Open Queries"
      display_name: "Total Open Queries"
      expr: SUM(CAST(open_query_count AS DOUBLE))
      comment: "Total open data queries across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Monitoring Visits"
      display_name: "Total Monitoring Visits"
      expr: SUM(CAST(monitoring_visit_count AS DOUBLE))
      comment: "Total monitoring visits conducted across sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Monitoring Visits Per Site"
      display_name: "Avg Monitoring Visits Per Site"
      expr: AVG(CAST(monitoring_visit_count AS DOUBLE))
      comment: "Average number of monitoring visits per site"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;
