-- Metric views for domain: site | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`site_activation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key activation KPIs for sites"
  source: "`clinical_trials_mvm`.`site`.`activation`"
  dimensions:
    - name: "activation_status"
      display_name: "Activation Status"
      expr: activation_status
      comment: "Current status of the activation"
    - name: "activation_type"
      display_name: "Activation Type"
      expr: activation_type
      comment: "Type/category of activation"
    - name: "country_id"
      display_name: "Country Id"
      expr: country_id
      comment: "Country identifier for the site"
    - name: "activation_year"
      display_name: "Activation Year"
      expr: DATE_TRUNC('year', actual_activation_date)
      comment: "Year of actual activation date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "activation_month"
      display_name: "Activation Month"
      expr: DATE_TRUNC('month', actual_activation_date)
      comment: "Month of actual activation date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_activations"
      display_name: "Total Activations"
      expr: COUNT(1)
      comment: "Total number of activation records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "count_active"
      display_name: "Active Activations"
      expr: COUNT(CASE WHEN activation_status = 'Active' THEN 1 END)
      comment: "Count of activations with status 'Active'"
      format:
        type: number
        decimal_places:
          type: all
    - name: "activation_success_rate"
      display_name: "Activation Success Rate"
      expr: (AGG(`count_active`) / NULLIF(AGG(`total_activations`), 0))
      comment: "Proportion of activations that are active"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`site_closeout`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site closeout process tracking and completion metrics for study termination"
  source: "`clinical_trials_mvm`.`site`.`closeout`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`site_enrollment_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Enrollment performance metrics per site and period"
  source: "`clinical_trials_mvm`.`site`.`enrollment_performance`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "investigational_site_id"
      display_name: "Investigational Site Id"
      expr: investigational_site_id
      comment: "Investigational site identifier"
    - name: "principal_investigator_id"
      display_name: "Principal Investigator Id"
      expr: principal_investigator_id
      comment: "Principal Investigator identifier"
    - name: "reporting_year"
      display_name: "Reporting Year"
      expr: DATE_TRUNC('year', reporting_period_start_date)
      comment: "Reporting year"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "reporting_month"
      display_name: "Reporting Month"
      expr: DATE_TRUNC('month', reporting_period_start_date)
      comment: "Reporting month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_enrolled"
      display_name: "Total Enrolled"
      expr: SUM(CAST(actual_enrolled_count AS DOUBLE))
      comment: "Sum of actual enrolled subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_target"
      display_name: "Planned Enrollment Target"
      expr: SUM(CAST(site_enrollment_target AS DOUBLE))
      comment: "Sum of site enrollment targets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "enrollment_achievement_pct"
      display_name: "Enrollment Achievement %"
      expr: (AGG(`total_enrolled`) / NULLIF(AGG(`total_target`), 0))
      comment: "Ratio of actual enrolled to target"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_dropout_rate"
      display_name: "Average Dropout Rate"
      expr: AVG(CAST(dropout_rate AS DOUBLE))
      comment: "Average dropout rate across sites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_screen_failure_rate"
      display_name: "Average Screen Failure Rate"
      expr: AVG(CAST(screen_failure_rate AS DOUBLE))
      comment: "Average screen failure rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "enrollment_variance_sum"
      display_name: "Enrollment Variance"
      expr: SUM(CAST(enrollment_variance AS DOUBLE))
      comment: "Sum of enrollment variance values"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`site_feasibility_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Feasibility assessment KPIs for site selection"
  source: "`clinical_trials_mvm`.`site`.`feasibility_assessment`"
  dimensions:
    - name: "site_region"
      display_name: "Site Region"
      expr: site_region
      comment: "Geographic region of the site"
    - name: "site_country_code"
      display_name: "Site Country Code"
      expr: site_country_code
      comment: "Country code of the site"
    - name: "phase"
      display_name: "Phase"
      expr: phase
      comment: "Trial phase (e.g., Phase I, II, III)"
    - name: "assessment_year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of feasibility assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "avg_feasibility_score"
      display_name: "Average Feasibility Score"
      expr: AVG(CAST(feasibility_score AS DOUBLE))
      comment: "Mean feasibility score across assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_feasibility_count"
      display_name: "High Feasibility Count"
      expr: COUNT(CASE WHEN feasibility_score >= 80 THEN 1 END)
      comment: "Number of assessments with feasibility score >= 80"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_estimated_capacity"
      display_name: "Average Estimated Capacity"
      expr: AVG(CAST(estimated_enrollment_capacity AS DOUBLE))
      comment: "Mean estimated enrollment capacity"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_regulatory_compliance_score"
      display_name: "Average Regulatory Compliance Score"
      expr: AVG(CAST(regulatory_compliance_score AS DOUBLE))
      comment: "Mean regulatory compliance score"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_infrastructure_score"
      display_name: "Average Infrastructure Score"
      expr: AVG(CAST(site_infrastructure_score AS DOUBLE))
      comment: "Mean site infrastructure score"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`site_study_site`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational KPIs for study sites"
  source: "`clinical_trials_mvm`.`site`.`study_site`"
  dimensions:
    - name: "site_status"
      display_name: "Site Status"
      expr: site_status
      comment: "Current operational status of the site"
    - name: "site_number"
      display_name: "Site Number"
      expr: site_number
      comment: "Site identifier code"
    - name: "country_id"
      display_name: "Country Id"
      expr: country_id
      comment: "Country identifier"
    - name: "enrollment_open_year"
      display_name: "Enrollment Open Year"
      expr: DATE_TRUNC('year', enrollment_open_date)
      comment: "Year enrollment opened"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "enrollment_open_month"
      display_name: "Enrollment Open Month"
      expr: DATE_TRUNC('month', enrollment_open_date)
      comment: "Month enrollment opened"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_target"
      display_name: "Total Enrollment Target"
      expr: SUM(CAST(enrollment_target AS DOUBLE))
      comment: "Sum of enrollment targets across study sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_enrolled"
      display_name: "Total Enrolled"
      expr: SUM(CAST(enrolled_count AS DOUBLE))
      comment: "Sum of enrolled subjects across study sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "enrollment_fill_rate_pct"
      display_name: "Enrollment Fill Rate %"
      expr: (AGG(`total_enrolled`) / NULLIF(AGG(`total_target`), 0))
      comment: "Proportion of enrollment target achieved"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_sae_count"
      display_name: "Total SAE Count"
      expr: SUM(CAST(sae_count AS DOUBLE))
      comment: "Sum of serious adverse events reported"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_protocol_deviation_count"
      display_name: "Total Protocol Deviations"
      expr: SUM(CAST(protocol_deviation_count AS DOUBLE))
      comment: "Sum of protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_open_query_count"
      display_name: "Open Query Count"
      expr: SUM(CAST(open_query_count AS DOUBLE))
      comment: "Total number of open queries"
      format:
        type: number
        decimal_places:
          type: all
$$;
