-- Metric views for domain: datamanagement | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`datamanagement_codelist_term_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Measures the completeness of CDISC controlled terminology implementation by codelist, tracking how many terms have NCI concept codes, submission values, and definitions populated."
  source: "`clinical_trials_mvm`.`datamanagement`.`codelist_term`"
  joins:
    - name: dim_codelist
      source: "`clinical_trials_mvm`.`datamanagement`.`codelist`"
      'on': source.codelist_id = dim_codelist.codelist_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "Codelist Name"
      display_name: "Codelist name"
      expr: dim_codelist.codelist_name
      comment: "Name of the CDISC codelist"
    - name: "NCI Codelist Code"
      display_name: "Nci codelist code"
      expr: dim_codelist.nci_codelist_code
      comment: "NCI C-code for the codelist"
    - name: "Package Version"
      display_name: "Package version"
      expr: dim_codelist.package_version
      comment: "CDISC CT package version"
  measures:
    - name: "Total Terms"
      display_name: "Total terms"
      expr: COUNT(DISTINCT codelist_term_id)
      comment: "Total terms in the codelist"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Terms with NCI Code %"
      display_name: "Terms with nci code %"
      expr: ROUND(100.0 * SUM(CASE WHEN nci_concept_code IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(codelist_term_id), 0), 2)
      comment: "Percentage of terms with NCI concept code populated"
    - name: "Terms with Definition %"
      display_name: "Terms with definition %"
      expr: ROUND(100.0 * SUM(CASE WHEN definition IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(codelist_term_id), 0), 2)
      comment: "Percentage of terms with CDISC definition populated"
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`datamanagement_coding_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key coding assignment KPIs for monitoring coding quality and throughput"
  source: "`clinical_trials_mvm`.`datamanagement`.`coding_assignment`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Identifier of the study linked to the coding assignment"
    - name: "coding_method"
      display_name: "Coding Method"
      expr: coding_method
      comment: "Method used for coding (e.g., manual, auto)"
    - name: "coding_status"
      display_name: "Coding Status"
      expr: coding_status
      comment: "Current status of the coding process"
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Regulatory approval status of the coded record"
    - name: "approval_month"
      display_name: "Approval Month"
      expr: DATE_TRUNC('month', approval_date)
      comment: "Month of approval date for time‑based analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_coded_records"
      display_name: "Total Coded Records"
      expr: COUNT(1)
      comment: "Total number of coding assignment records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_coding_confidence"
      display_name: "Average Coding Confidence"
      expr: AVG(CAST(autocoding_confidence_score AS DOUBLE))
      comment: "Mean confidence score for automated coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "coded_flag_true"
      display_name: "Coded Flag True Count"
      expr: SUM(CASE WHEN coding_flag THEN 1 ELSE 0 END)
      comment: "Count of records where coding_flag is true"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`datamanagement_discrepancy_query`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational KPI view for discrepancy query management and safety monitoring"
  source: "`clinical_trials_mvm`.`datamanagement`.`discrepancy_query`"
  dimensions:
    - name: "query_status"
      display_name: "Query Status"
      expr: query_status
      comment: "Current lifecycle status of the query"
    - name: "priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level assigned to the query"
    - name: "is_safety_related"
      display_name: "Is Safety Related"
      expr: is_safety_related
      comment: "Flag indicating if the query is safety related"
    - name: "query_type"
      display_name: "Query Type"
      expr: query_type
      comment: "Classification of the query (e.g., data, protocol)"
    - name: "created_month"
      display_name: "Created Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Month when the query was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_queries"
      display_name: "Total Queries"
      expr: COUNT(1)
      comment: "Total number of discrepancy queries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_open"
      display_name: "Average Days Open"
      expr: AVG(CAST(days_open AS DOUBLE))
      comment: "Mean duration (in days) that queries remain open"
      format:
        type: number
        decimal_places:
          type: all
    - name: "escalated_queries"
      display_name: "Escalated Queries"
      expr: SUM(CASE WHEN is_escalated THEN 1 ELSE 0 END)
      comment: "Count of queries that have been escalated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_priority_queries"
      display_name: "High Priority Queries"
      expr: SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END)
      comment: "Count of queries marked as high priority"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`datamanagement_subject_visit_data`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Visit‑level KPIs to assess data capture quality and query load"
  source: "`clinical_trials_mvm`.`datamanagement`.`subject_visit_data`"
  dimensions:
    - name: "visit_id"
      display_name: "Visit Id"
      expr: visit_id
      comment: "Visit identifier within the study"
    - name: "visit_month"
      display_name: "Visit Month"
      expr: DATE_TRUNC('month', visit_date)
      comment: "Month of the visit date for time‑based trends"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "completion_status"
      display_name: "Completion Status"
      expr: completion_status
      comment: "Overall completion status of the visit record"
  measures:
    - name: "total_visits"
      display_name: "Total Visits"
      expr: COUNT(1)
      comment: "Number of subject visit records captured"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_data_completeness_pct"
      display_name: "Average Data Completeness %"
      expr: AVG(CAST(data_completeness_pct AS DOUBLE))
      comment: "Mean data completeness percentage across visits"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_open_queries"
      display_name: "Total Open Queries"
      expr: SUM(CAST(open_query_count AS DOUBLE))
      comment: "Sum of open queries linked to visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_missing_fields"
      display_name: "Total Missing Fields"
      expr: SUM(CAST(missing_field_count AS DOUBLE))
      comment: "Aggregate count of missing data fields across visits"
      format:
        type: number
        decimal_places:
          type: all
$$;
