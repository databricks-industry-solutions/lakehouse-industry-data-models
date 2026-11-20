-- Metric views for domain: laboratory | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_assay_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key performance indicators for bioanalytical assay quality and throughput"
  source: "`clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`"
  joins:
    - name: dim_laboratory_lab_facility
      source: "`clinical_trials_mvm`.`laboratory`.`lab_facility`"
      'on': source.lab_facility_id = dim_laboratory_lab_facility.lab_facility_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "assay_type"
      display_name: "Assay Type"
      expr: assay_type
      comment: "Type of assay (e.g., PK, PD)"
  measures:
    - name: "total_assays"
      display_name: "Total Assays"
      expr: COUNT(1)
      comment: "Total number of bioanalytical assays"
      format:
        type: number
        decimal_places:
          type: all
    - name: "accurate_assays"
      display_name: "Accurate Assays"
      expr: COUNT(CASE WHEN accuracy_percent >= 95 THEN 1 END)
      comment: "Assays with accuracy >= 95%"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "assay_accuracy_rate"
      display_name: "Assay Accuracy Rate"
      expr: (AGG(`accurate_assays`) / NULLIF(AGG(`total_assays`),0))
      comment: "Proportion of assays meeting accuracy threshold"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_accuracy_percent"
      display_name: "Average Accuracy Percent"
      expr: AVG(CAST(accuracy_percent AS DOUBLE))
      comment: "Average accuracy percent across assays"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_bioanalytical_result`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bioanalytical PK/PD assay results with concentration measurements, quality control flags, and time-point deviations for pharmacokinetic analysis"
  source: "`clinical_trials_mvm`.`laboratory`.`bioanalytical_result`"
  dimensions:
    - name: "Result Status"
      display_name: "Result Status"
      expr: result_status
      comment: "Status of the bioanalytical result (e.g., final, preliminary, excluded)"
    - name: "Result Category"
      display_name: "Result Category"
      expr: result_category
      comment: "Category of the bioanalytical result (e.g., PK, PD, biomarker)"
    - name: "Matrix Type"
      display_name: "Matrix Type"
      expr: matrix_type
      comment: "Biological matrix type (e.g., plasma, serum, urine)"
    - name: "Exclusion Flag"
      display_name: "Exclusion Flag"
      expr: exclusion_flag
      comment: "Whether the result is excluded from analysis"
    - name: "ISR Flag"
      display_name: "Incurred Sample Reanalysis Flag"
      expr: isr_flag
      comment: "Whether the sample was selected for incurred sample reanalysis"
    - name: "Analysis Month"
      display_name: "Analysis Month"
      expr: DATE_TRUNC('month', analysis_timestamp)
      comment: "Month when the bioanalytical result was analyzed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Collection Month"
      display_name: "Collection Month"
      expr: DATE_TRUNC('month', collection_timestamp)
      comment: "Month when the sample was collected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Bioanalytical Results"
      display_name: "Total Bioanalytical Results"
      expr: COUNT(1)
      comment: "Total number of bioanalytical result records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Analyzed"
      display_name: "Unique Subjects Analyzed"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique subjects with bioanalytical results"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique PK Samples"
      display_name: "Unique PK Samples"
      expr: COUNT(DISTINCT pk_sample_id)
      comment: "Number of unique PK samples analyzed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Numeric Result"
      display_name: "Average Numeric Result"
      expr: AVG(CAST(numeric_result AS DOUBLE))
      comment: "Average numeric result value across all bioanalytical results"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Dilution Factor"
      display_name: "Average Dilution Factor"
      expr: AVG(CAST(dilution_factor AS DOUBLE))
      comment: "Average dilution factor applied to samples"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Time Deviation Hours"
      display_name: "Average Time Deviation (Hours)"
      expr: AVG(CAST(time_deviation_hours AS DOUBLE))
      comment: "Average deviation from nominal time point in hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Exclusion Rate"
      display_name: "Result Exclusion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN exclusion_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of bioanalytical results excluded from analysis"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ISR Rate"
      display_name: "Incurred Sample Reanalysis Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN isr_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of samples selected for incurred sample reanalysis"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Calibration Curve Acceptance Rate"
      display_name: "Calibration Curve Acceptance Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN calibration_curve_accepted = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of results with accepted calibration curves"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_lab_facility`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Laboratory facility capabilities, certifications, and operational capacity for vendor qualification and site selection"
  source: "`clinical_trials_mvm`.`laboratory`.`lab_facility`"
  dimensions:
    - name: "Facility Type"
      display_name: "Facility Type"
      expr: facility_type
      comment: "Type of laboratory facility (e.g., central lab, local lab, specialty lab)"
    - name: "Operational Status"
      display_name: "Operational Status"
      expr: operational_status
      comment: "Current operational status of the facility (e.g., active, inactive, pending)"
    - name: "Qualification Status"
      display_name: "Qualification Status"
      expr: qualification_status
      comment: "Qualification status of the facility for clinical trial work"
    - name: "GCP Certified"
      display_name: "GCP Certified"
      expr: gcp_certified
      comment: "Whether the facility is Good Clinical Practice certified"
    - name: "GLP Certified"
      display_name: "GLP Certified"
      expr: glp_certified
      comment: "Whether the facility is Good Laboratory Practice certified"
    - name: "PK Analysis Capable"
      display_name: "PK Analysis Capable"
      expr: pk_analysis_capable
      comment: "Whether the facility can perform pharmacokinetic analysis"
    - name: "DMPK Analysis Capable"
      display_name: "DMPK Analysis Capable"
      expr: dmpk_analysis_capable
      comment: "Whether the facility can perform drug metabolism and pharmacokinetics analysis"
    - name: "Genomics Capable"
      display_name: "Genomics Capable"
      expr: genomics_capable
      comment: "Whether the facility has genomics analysis capabilities"
    - name: "Country Code"
      display_name: "Country Code"
      expr: country_code
      comment: "Country where the laboratory facility is located"
  measures:
    - name: "Total Lab Facilities"
      display_name: "Total Lab Facilities"
      expr: COUNT(1)
      comment: "Total number of laboratory facilities"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Facilities"
      display_name: "Active Facilities"
      expr: SUM(CAST(CASE WHEN operational_status = 'active' THEN 1 ELSE 0 END AS INT))
      comment: "Number of laboratory facilities with active operational status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Certified Facilities"
      display_name: "GCP Certified Facilities"
      expr: SUM(CAST(CASE WHEN gcp_certified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of facilities with Good Clinical Practice certification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GLP Certified Facilities"
      display_name: "GLP Certified Facilities"
      expr: SUM(CAST(CASE WHEN glp_certified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of facilities with Good Laboratory Practice certification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Specimen Capacity Per Day"
      display_name: "Total Specimen Capacity Per Day"
      expr: SUM(CAST(specimen_capacity_per_day AS DOUBLE))
      comment: "Total daily specimen processing capacity across all facilities"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Turnaround Time Standard Hours"
      display_name: "Average Standard Turnaround Time (Hours)"
      expr: AVG(CAST(turnaround_time_standard_hours AS DOUBLE))
      comment: "Average standard turnaround time for results in hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Turnaround Time Stat Hours"
      display_name: "Average STAT Turnaround Time (Hours)"
      expr: AVG(CAST(turnaround_time_stat_hours AS DOUBLE))
      comment: "Average STAT (urgent) turnaround time for results in hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "PK Capable Facility Rate"
      display_name: "PK Capable Facility Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN pk_analysis_capable = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of facilities capable of pharmacokinetic analysis"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_lab_query`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Laboratory data queries with resolution tracking, SLA compliance, and escalation monitoring for data quality management"
  source: "`clinical_trials_mvm`.`laboratory`.`lab_query`"
  dimensions:
    - name: "Query Status"
      display_name: "Query Status"
      expr: query_status
      comment: "Current status of the laboratory query (e.g., open, closed, cancelled)"
    - name: "Query Type"
      display_name: "Query Type"
      expr: query_type
      comment: "Type of laboratory query (e.g., missing data, out of range, inconsistency)"
    - name: "Query Category"
      display_name: "Query Category"
      expr: query_category
      comment: "Category of the laboratory query"
    - name: "Query Priority"
      display_name: "Query Priority"
      expr: query_priority
      comment: "Priority level of the query (e.g., high, medium, low)"
    - name: "Escalation Flag"
      display_name: "Escalation Flag"
      expr: escalation_flag
      comment: "Whether the query has been escalated"
    - name: "SLA Breach Flag"
      display_name: "SLA Breach Flag"
      expr: sla_breach_flag
      comment: "Whether the query resolution breached service level agreement"
    - name: "Safety Relevance Flag"
      display_name: "Safety Relevance Flag"
      expr: safety_relevance_flag
      comment: "Whether the query has safety implications"
    - name: "Data Correction Flag"
      display_name: "Data Correction Flag"
      expr: data_correction_flag
      comment: "Whether the query resulted in data correction"
    - name: "Raised Month"
      display_name: "Raised Month"
      expr: DATE_TRUNC('month', raised_datetime)
      comment: "Month when the query was raised"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Lab Queries"
      display_name: "Total Lab Queries"
      expr: COUNT(1)
      comment: "Total number of laboratory data queries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Queried"
      display_name: "Unique Subjects Queried"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique subjects with laboratory queries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Query Iteration Count"
      display_name: "Average Query Iteration Count"
      expr: AVG(CAST(query_iteration_count AS DOUBLE))
      comment: "Average number of iterations per query before resolution"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Query Escalation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN escalation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of laboratory queries that were escalated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SLA Breach Rate"
      display_name: "SLA Breach Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sla_breach_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of laboratory queries that breached service level agreement"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety Query Rate"
      display_name: "Safety-Relevant Query Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN safety_relevance_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of laboratory queries with safety implications"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Data Correction Rate"
      display_name: "Data Correction Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN data_correction_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of laboratory queries that resulted in data correction"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_pk_sample`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pharmacokinetic sample collection with time-point adherence, protocol deviation tracking, and sample exclusion management"
  source: "`clinical_trials_mvm`.`laboratory`.`pk_sample`"
  dimensions:
    - name: "Sample Status"
      display_name: "Sample Status"
      expr: sample_status
      comment: "Current status of the PK sample (collected, analyzed, excluded, pending)"
    - name: "Sample Type"
      display_name: "Sample Type"
      expr: sample_type
      comment: "Type of PK sample (plasma, serum, whole blood, etc.)"
    - name: "Processing Status"
      display_name: "Processing Status"
      expr: processing_status
      comment: "Processing status of the PK sample"
    - name: "Sample Exclusion Flag"
      display_name: "Sample Exclusion Flag"
      expr: sample_exclusion_flag
      comment: "Whether the PK sample is excluded from pharmacokinetic analysis"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation Flag"
      expr: protocol_deviation_flag
      comment: "Whether the PK sample collection had a protocol deviation"
    - name: "Pre Dose Flag"
      display_name: "Pre-Dose Flag"
      expr: pre_dose_flag
      comment: "Whether this is a pre-dose baseline PK sample"
    - name: "Within Sampling Window"
      display_name: "Within Sampling Window"
      expr: within_sampling_window
      comment: "Whether the sample was collected within the protocol-defined sampling window"
    - name: "Collection Month"
      display_name: "Collection Month"
      expr: DATE_TRUNC('month', collection_timestamp)
      comment: "Month when the PK sample was collected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total PK Samples"
      display_name: "Total PK Samples"
      expr: COUNT(1)
      comment: "Total number of pharmacokinetic sample collection events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Sampled"
      display_name: "Unique Subjects with PK Samples"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique trial subjects with pharmacokinetic samples collected"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Sample Exclusion Rate"
      display_name: "PK Sample Exclusion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sample_exclusion_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of PK samples excluded from pharmacokinetic analysis due to quality or protocol issues"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Deviation Rate"
      display_name: "PK Sample Protocol Deviation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN protocol_deviation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of PK samples with protocol deviations impacting pharmacokinetic analysis validity"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sampling Window Compliance Rate"
      display_name: "Sampling Window Compliance Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN within_sampling_window = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of PK samples collected within protocol-defined time windows, critical for valid PK parameter estimation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Actual Time Post Dose Hours"
      display_name: "Average Actual Time Post-Dose (Hours)"
      expr: AVG(CAST(actual_time_post_dose_hours AS DOUBLE))
      comment: "Average actual time post-dose in hours when PK samples were collected"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Volume Collected ML"
      display_name: "Average Volume Collected (mL)"
      expr: AVG(CAST(volume_collected_ml AS DOUBLE))
      comment: "Average volume of PK sample collected in milliliters"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Freeze Thaw Cycles"
      display_name: "Average Freeze-Thaw Cycles"
      expr: AVG(CAST(freeze_thaw_cycles AS DOUBLE))
      comment: "Average number of freeze-thaw cycles experienced by PK samples, impacting sample stability"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_reference_range`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Laboratory reference ranges with demographic stratification, CTCAE grade mapping, and version control for clinical interpretation"
  source: "`clinical_trials_mvm`.`laboratory`.`reference_range`"
  dimensions:
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the reference range (e.g., approved, pending, draft)"
    - name: "Sex Applicability"
      display_name: "Sex Applicability"
      expr: sex_applicability
      comment: "Sex for which this reference range applies (e.g., male, female, all)"
    - name: "Age Unit"
      display_name: "Age Unit"
      expr: age_unit
      comment: "Unit of age for the reference range (e.g., years, months)"
    - name: "Specimen Type"
      display_name: "Specimen Type"
      expr: specimen_type
      comment: "Type of specimen for which this reference range applies"
    - name: "Range Source"
      display_name: "Range Source"
      expr: range_source
      comment: "Source of the reference range (e.g., lab-specific, literature, sponsor-defined)"
    - name: "Is Sponsor Defined"
      display_name: "Is Sponsor Defined"
      expr: is_sponsor_defined
      comment: "Whether the reference range is sponsor-defined rather than lab-standard"
    - name: "Is Current Version"
      display_name: "Is Current Version"
      expr: is_current_version
      comment: "Whether this is the current active version of the reference range"
    - name: "CTCAE Version"
      display_name: "CTCAE Version"
      expr: ctcae_version
      comment: "Version of CTCAE (Common Terminology Criteria for Adverse Events) used for grading"
  measures:
    - name: "Total Reference Ranges"
      display_name: "Total Reference Ranges"
      expr: COUNT(1)
      comment: "Total number of laboratory reference range definitions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Lab Analytes"
      display_name: "Unique Lab Analytes"
      expr: COUNT(DISTINCT lab_analyte_id)
      comment: "Number of unique laboratory analytes with reference ranges"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Lab Facilities"
      display_name: "Unique Lab Facilities"
      expr: COUNT(DISTINCT lab_facility_id)
      comment: "Number of unique laboratory facilities with reference ranges"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Age Min"
      display_name: "Average Minimum Age"
      expr: AVG(CAST(age_min AS DOUBLE))
      comment: "Average minimum age for reference range applicability"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Age Max"
      display_name: "Average Maximum Age"
      expr: AVG(CAST(age_max AS DOUBLE))
      comment: "Average maximum age for reference range applicability"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Sponsor Defined Rate"
      display_name: "Sponsor-Defined Reference Range Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_sponsor_defined = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reference ranges that are sponsor-defined rather than lab-standard"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Current Version Rate"
      display_name: "Current Version Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_current_version = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reference ranges that are current active versions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_result_turnaround`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Turnaround and quality metrics for laboratory results"
  source: "`clinical_trials_mvm`.`laboratory`.`lab_result`"
  joins:
    - name: dim_laboratory_lab_facility
      source: "`clinical_trials_mvm`.`laboratory`.`lab_facility`"
      'on': source.lab_facility_id = dim_laboratory_lab_facility.lab_facility_id
      rely:
        at_most_one_match: true
    - name: dim_laboratory_lab_panel
      source: "`clinical_trials_mvm`.`laboratory`.`lab_panel`"
      'on': source.lab_panel_id = dim_laboratory_lab_panel.lab_panel_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "lab_facility_name"
      display_name: "Lab Facility Name"
      expr: dim_laboratory_lab_facility.facility_name
      comment: "Name of the lab facility performing the analysis"
    - name: "lab_panel_name"
      display_name: "Lab Panel Name"
      expr: dim_laboratory_lab_panel.panel_name
      comment: "Name of the lab panel associated with the result"
    - name: "result_status"
      display_name: "Result Status"
      expr: result_status
      comment: "Current status of the lab result"
    - name: "result_unit"
      display_name: "Result Unit"
      expr: result_unit
      comment: "Measurement unit of the result"
    - name: "collection_date"
      display_name: "Collection Date"
      expr: DATE_TRUNC('day', collection_datetime)
      comment: "Date the specimen was collected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "result_reported_date"
      display_name: "Result Reported Date"
      expr: DATE_TRUNC('day', result_reported_datetime)
      comment: "Date the result was reported"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_results"
      display_name: "Total Results"
      expr: COUNT(1)
      comment: "Total number of lab results"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_turnaround_hours"
      display_name: "Average Turnaround Hours"
      expr: AVG((UNIX_TIMESTAMP(result_reported_datetime) - UNIX_TIMESTAMP(collection_datetime)) / 3600.0)
      comment: "Average time from specimen collection to result reporting (hours)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_value_count"
      display_name: "Critical Value Count"
      expr: COUNT(CASE WHEN critical_value_flag THEN 1 END)
      comment: "Number of results flagged as critical"
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_value_rate"
      display_name: "Critical Value Rate"
      expr: (AGG(`critical_value_count`) / NULLIF(AGG(`total_results`),0))
      comment: "Proportion of results that are critical"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "out_of_range_count"
      display_name: "Out‑of‑Range Count"
      expr: COUNT(CASE WHEN out_of_range_flag THEN 1 END)
      comment: "Number of results outside the normal range"
      format:
        type: number
        decimal_places:
          type: all
    - name: "out_of_range_rate"
      display_name: "Out‑of‑Range Rate"
      expr: (AGG(`out_of_range_count`) / NULLIF(AGG(`total_results`),0))
      comment: "Proportion of results out of range"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_specimen_collection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Specimen collection events with protocol compliance, deviation tracking, and sample adequacy assessment for clinical trial quality monitoring"
  source: "`clinical_trials_mvm`.`laboratory`.`specimen_collection`"
  dimensions:
    - name: "Collection Status"
      display_name: "Collection Status"
      expr: collection_status
      comment: "Status of the specimen collection (e.g., completed, pending, cancelled)"
    - name: "Specimen Type"
      display_name: "Specimen Type"
      expr: specimen_type
      comment: "Type of biological specimen collected (e.g., blood, urine, tissue)"
    - name: "Fasting Status"
      display_name: "Fasting Status"
      expr: fasting_status
      comment: "Fasting status of the subject at time of collection"
    - name: "Has Deviation"
      display_name: "Has Deviation"
      expr: has_deviation
      comment: "Whether the collection had a protocol deviation"
    - name: "Recollection Required"
      display_name: "Recollection Required"
      expr: recollection_required
      comment: "Whether the specimen requires recollection"
    - name: "Sample Adequacy"
      display_name: "Sample Adequacy"
      expr: sample_adequacy
      comment: "Assessment of whether the sample is adequate for analysis"
    - name: "Collection Month"
      display_name: "Collection Month"
      expr: DATE_TRUNC('month', collection_timestamp)
      comment: "Month when the specimen was collected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Collections"
      display_name: "Total Collections"
      expr: COUNT(1)
      comment: "Total number of specimen collection events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Collected"
      display_name: "Unique Subjects Collected"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique subjects with specimen collections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Tubes Collected"
      display_name: "Total Tubes Collected"
      expr: SUM(CAST(tube_count AS DOUBLE))
      comment: "Total number of collection tubes across all collections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Volume Collected mL"
      display_name: "Total Volume Collected (mL)"
      expr: SUM(CAST(volume_collected_ml AS DOUBLE))
      comment: "Total volume of specimens collected in milliliters"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Volume Collected mL"
      display_name: "Average Volume Collected (mL)"
      expr: AVG(CAST(volume_collected_ml AS DOUBLE))
      comment: "Average volume collected per specimen in milliliters"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Deviation Rate"
      display_name: "Collection Deviation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN has_deviation = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of specimen collections with protocol deviations"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Recollection Rate"
      display_name: "Recollection Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN recollection_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of specimen collections requiring recollection"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_specimen_processing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Processing efficiency and quality metrics for specimens"
  source: "`clinical_trials_mvm`.`laboratory`.`specimen`"
  joins:
    - name: dim_laboratory_lab_facility
      source: "`clinical_trials_mvm`.`laboratory`.`lab_facility`"
      'on': source.lab_facility_id = dim_laboratory_lab_facility.lab_facility_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "lab_facility_name"
      display_name: "Lab Facility Name"
      expr: dim_laboratory_lab_facility.facility_name
      comment: "Lab facility where specimen was processed"
    - name: "specimen_type"
      display_name: "Specimen Type"
      expr: specimen_type
      comment: "Biological type of the specimen"
    - name: "collection_date"
      display_name: "Collection Date"
      expr: DATE_TRUNC('day', collection_datetime)
      comment: "Date specimen was collected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "fasting_status"
      display_name: "Fasting Status"
      expr: fasting_status
      comment: "Fasting status of the subject at collection"
  measures:
    - name: "total_specimens"
      display_name: "Total Specimens"
      expr: COUNT(1)
      comment: "Total number of specimens processed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "rejected_specimens"
      display_name: "Rejected Specimens"
      expr: COUNT(CASE WHEN rejection_reason IS NOT NULL THEN 1 END)
      comment: "Specimens that were rejected during processing"
      format:
        type: number
        decimal_places:
          type: all
    - name: "rejection_rate"
      display_name: "Rejection Rate"
      expr: (AGG(`rejected_specimens`) / NULLIF(AGG(`total_specimens`),0))
      comment: "Proportion of specimens rejected"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_freeze_thaw_cycles"
      display_name: "Average Freeze‑Thaw Cycles"
      expr: AVG(CAST(freeze_thaw_cycles AS DOUBLE))
      comment: "Average number of freeze‑thaw cycles per specimen"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`laboratory_specimen_shipment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Specimen shipment logistics with temperature excursion monitoring, receipt compliance, and turnaround time tracking for supply chain quality"
  source: "`clinical_trials_mvm`.`laboratory`.`specimen_shipment`"
  dimensions:
    - name: "Shipment Status"
      display_name: "Shipment Status"
      expr: shipment_status
      comment: "Current status of the specimen shipment (e.g., in transit, received, rejected)"
    - name: "Shipment Type"
      display_name: "Shipment Type"
      expr: shipment_type
      comment: "Type of specimen shipment (e.g., routine, urgent, international)"
    - name: "Temperature Excursion Flag"
      display_name: "Temperature Excursion Flag"
      expr: temperature_excursion_flag
      comment: "Whether the shipment experienced temperature excursion outside acceptable range"
    - name: "Hazardous Material Flag"
      display_name: "Hazardous Material Flag"
      expr: hazardous_material_flag
      comment: "Whether the shipment contains hazardous materials"
    - name: "Temperature Condition"
      display_name: "Temperature Condition"
      expr: temperature_condition
      comment: "Required temperature condition for the shipment (e.g., frozen, refrigerated, ambient)"
    - name: "Courier Service Level"
      display_name: "Courier Service Level"
      expr: courier_service_level
      comment: "Service level of the courier (e.g., overnight, 2-day, standard)"
    - name: "Shipment Month"
      display_name: "Shipment Month"
      expr: DATE_TRUNC('month', shipment_date)
      comment: "Month when the shipment was sent"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Shipments"
      display_name: "Total Shipments"
      expr: COUNT(1)
      comment: "Total number of specimen shipments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Specimens Shipped"
      display_name: "Total Specimens Shipped"
      expr: SUM(CAST(specimen_count AS DOUBLE))
      comment: "Total number of specimens shipped across all shipments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Shipped"
      display_name: "Total Subjects Shipped"
      expr: SUM(CAST(subject_count AS DOUBLE))
      comment: "Total number of subjects represented in shipments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Specimens Per Shipment"
      display_name: "Average Specimens Per Shipment"
      expr: AVG(CAST(specimen_count AS DOUBLE))
      comment: "Average number of specimens per shipment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Dry Ice Weight kg"
      display_name: "Total Dry Ice Weight (kg)"
      expr: SUM(CAST(dry_ice_weight_kg AS DOUBLE))
      comment: "Total weight of dry ice used across all shipments in kilograms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Temperature Excursion Rate"
      display_name: "Temperature Excursion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN temperature_excursion_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of shipments experiencing temperature excursion outside acceptable range"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Excursion Duration Minutes"
      display_name: "Average Excursion Duration (Minutes)"
      expr: AVG(CAST(excursion_duration_minutes AS DOUBLE))
      comment: "Average duration of temperature excursions in minutes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;
