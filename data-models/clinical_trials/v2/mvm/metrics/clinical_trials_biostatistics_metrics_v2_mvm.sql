-- Metric views for domain: biostatistics | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_analysis_population`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic view of analysis populations, supporting enrollment monitoring and primary cohort definition."
  source: "`clinical_trials_mvm`.`biostatistics`.`analysis_population`"
  dimensions:
    - name: "analysis_month"
      display_name: "Analysis Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Month when the analysis population record was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_populations"
      display_name: "Total Analysis Populations"
      expr: COUNT(1)
      comment: "Count of analysis population definitions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "sum_subjects_at_dbl"
      display_name: "Sum Subjects at DBL"
      expr: SUM(CAST(subject_count_at_dbl AS DOUBLE))
      comment: "Total subjects counted at database lock across populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_subjects_interim"
      display_name: "Average Subjects at Interim"
      expr: AVG(CAST(subject_count_interim AS DOUBLE))
      comment: "Mean number of subjects available at interim analyses"
      format:
        type: number
        decimal_places:
          type: all
    - name: "count_primary_flag"
      display_name: "Primary Population Flag Count"
      expr: COUNT(CASE WHEN primary_population_flag THEN 1 END)
      comment: "Number of populations marked as primary"
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_primary_populations"
      display_name: "Pct Primary Populations"
      expr: (AGG(`count_primary_flag`) / NULLIF(AGG(`total_populations`), 0))
      comment: "Proportion of analysis populations designated as primary"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_database_lock_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Database lock event metrics tracking lock cycle time, query resolution efficiency, and data quality readiness for regulatory submissions."
  source: "`clinical_trials_mvm`.`biostatistics`.`database_lock_event`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_interim_analysis`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key performance indicators for interim analyses, supporting monitoring of statistical thresholds and stopping decisions."
  source: "`clinical_trials_mvm`.`biostatistics`.`interim_analysis`"
  dimensions:
    - name: "analysis_month"
      display_name: "Analysis Month"
      expr: DATE_TRUNC('month', actual_analysis_date)
      comment: "Month of the interim analysis date (UTC)"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_interim_analyses"
      display_name: "Total Interim Analyses"
      expr: COUNT(1)
      comment: "Count of interim analyses performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_alpha_allocated"
      display_name: "Average Alpha Allocated"
      expr: AVG(CAST(alpha_allocated AS DOUBLE))
      comment: "Mean alpha allocated across interim analyses"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_stopping_triggered"
      display_name: "Stopping Rule Triggered Count"
      expr: COUNT(CASE WHEN stopping_rule_triggered THEN 1 END)
      comment: "Number of interim analyses where a stopping rule was triggered"
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_stopping_triggered"
      display_name: "Pct Stopping Rule Triggered"
      expr: (AGG(`total_stopping_triggered`) / NULLIF(AGG(`total_interim_analyses`), 0))
      comment: "Proportion of interim analyses that triggered a stopping rule"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_sample_size_calc`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Metrics that evaluate the design assumptions and scale of planned clinical studies."
  source: "`clinical_trials_mvm`.`biostatistics`.`sample_size_calc`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Identifier of the study linked to the calculation"
  measures:
    - name: "total_calculations"
      display_name: "Total Sample Size Calculations"
      expr: COUNT(1)
      comment: "Count of sample size calculation records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "sum_planned_sample_size"
      display_name: "Sum Planned Sample Size"
      expr: SUM(CAST(total_sample_size AS DOUBLE))
      comment: "Aggregate planned sample size across calculations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_power"
      display_name: "Average Power"
      expr: AVG(CAST(power AS DOUBLE))
      comment: "Mean statistical power used in calculations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_effect_size"
      display_name: "Average Effect Size"
      expr: AVG(CAST(effect_size AS DOUBLE))
      comment: "Mean effect size assumed in calculations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "count_non_inferiority"
      display_name: "Non-Inferiority Calculations Count"
      expr: COUNT(CASE WHEN non_inferiority_margin IS NOT NULL THEN 1 END)
      comment: "Number of calculations that include a non‑inferiority margin"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "pct_non_inferiority"
      display_name: "Pct Non-Inferiority Calculations"
      expr: (AGG(`count_non_inferiority`) / NULLIF(AGG(`total_calculations`), 0))
      comment: "Proportion of calculations that are for non‑inferiority trials"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_sap`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Statistical Analysis Plan metrics tracking SAP version control, amendment frequency, regulatory alignment, and approval cycle time."
  source: "`clinical_trials_mvm`.`biostatistics`.`sap`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`biostatistics_tlf_output`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "TLF output production metrics tracking programming productivity, QC cycle time, approval rates, and discrepancy resolution efficiency."
  source: "`clinical_trials_mvm`.`biostatistics`.`tlf_output`"
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
