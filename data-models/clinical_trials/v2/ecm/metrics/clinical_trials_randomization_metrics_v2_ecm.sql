-- Metric views for domain: randomization | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_rand_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Randomization deviation and protocol compliance KPIs tracking deviations, root causes, severity, and impact on study integrity."
  source: "`clinical_trials_ecm`.`randomization`.`rand_deviation`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Study Site ID"
      display_name: "Study Site ID"
      expr: investigational_site_id
      comment: "Unique identifier for the investigational site where deviation occurred"
    - name: "Deviation Type"
      display_name: "Deviation Type"
      expr: deviation_type
      comment: "Type of randomization deviation (allocation error, eligibility violation, blinding breach)"
    - name: "Deviation Status"
      display_name: "Deviation Status"
      expr: deviation_status
      comment: "Current status of the deviation (open, under review, resolved, closed)"
    - name: "Severity"
      display_name: "Severity"
      expr: severity
      comment: "Severity classification of the deviation (minor, major, critical)"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root cause category for the deviation (system error, human error, protocol ambiguity)"
    - name: "Blinding Impact"
      display_name: "Blinding Impact"
      expr: blinding_impact
      comment: "Impact of the deviation on study blinding (none, partial, complete breach)"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Impact of the deviation on data integrity (none, minor, major)"
    - name: "Subject Safety Impact"
      display_name: "Subject Safety Impact"
      expr: subject_safety_impact
      comment: "Impact of the deviation on subject safety (none, potential, actual)"
    - name: "Population Impact"
      display_name: "Population Impact"
      expr: population_impact
      comment: "Impact of the deviation on analysis populations (none, ITT only, PP exclusion)"
    - name: "IRB IEC Reportable"
      display_name: "IRB/IEC Reportable"
      expr: irb_iec_reportable
      comment: "Flag indicating whether deviation is reportable to IRB/IEC"
    - name: "Regulatory Reportable"
      display_name: "Regulatory Reportable"
      expr: regulatory_reportable
      comment: "Flag indicating whether deviation is reportable to regulatory authorities"
    - name: "Subject Continued in Study"
      display_name: "Subject Continued"
      expr: subject_continued_in_study
      comment: "Flag indicating whether subject continued in study after deviation"
    - name: "Discovery Date"
      display_name: "Discovery Date"
      expr: discovery_date
      comment: "Date when the deviation was discovered"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Discovery Month"
      display_name: "Discovery Month"
      expr: DATE_TRUNC('month', discovery_date)
      comment: "Month when deviation was discovered for trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Occurrence Date"
      display_name: "Occurrence Date"
      expr: occurrence_date
      comment: "Date when the deviation actually occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Deviations"
      display_name: "Total Deviations"
      expr: COUNT(1)
      comment: "Total number of randomization deviations across all studies and sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Deviations"
      display_name: "Open Deviations"
      expr: COUNT(CASE WHEN deviation_status = 'open' THEN 1 END)
      comment: "Count of deviations currently open and requiring action"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Resolved Deviations"
      display_name: "Resolved Deviations"
      expr: COUNT(CASE WHEN deviation_status = 'resolved' THEN 1 END)
      comment: "Count of deviations that have been resolved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Deviations"
      display_name: "Critical Deviations"
      expr: COUNT(CASE WHEN severity = 'critical' THEN 1 END)
      comment: "Count of critical severity deviations requiring immediate escalation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Major Deviations"
      display_name: "Major Deviations"
      expr: COUNT(CASE WHEN severity = 'major' THEN 1 END)
      comment: "Count of major severity deviations with significant impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Minor Deviations"
      display_name: "Minor Deviations"
      expr: COUNT(CASE WHEN severity = 'minor' THEN 1 END)
      comment: "Count of minor severity deviations with limited impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Deviation Rate"
      display_name: "Critical Deviation Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN severity = 'critical' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of deviations classified as critical, a key quality and risk indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "IRB IEC Reportable Count"
      display_name: "IRB/IEC Reportable Count"
      expr: COUNT(CASE WHEN irb_iec_reportable = TRUE THEN 1 END)
      comment: "Count of deviations requiring IRB/IEC reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Reportable Count"
      display_name: "Regulatory Reportable Count"
      expr: COUNT(CASE WHEN regulatory_reportable = TRUE THEN 1 END)
      comment: "Count of deviations requiring regulatory authority reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN regulatory_reportable = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of deviations requiring regulatory reporting, a compliance risk metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Blinding Breach Count"
      display_name: "Blinding Breach Count"
      expr: COUNT(CASE WHEN blinding_impact IN ('partial', 'complete breach') THEN 1 END)
      comment: "Count of deviations that resulted in blinding breaches"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinding Breach Rate"
      display_name: "Blinding Breach Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN blinding_impact IN ('partial', 'complete breach') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of deviations causing blinding breaches, a study integrity metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Safety Impact Count"
      display_name: "Subject Safety Impact Count"
      expr: COUNT(CASE WHEN subject_safety_impact IN ('potential', 'actual') THEN 1 END)
      comment: "Count of deviations with potential or actual subject safety impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subject Discontinuation Count"
      display_name: "Subject Discontinuation Count"
      expr: COUNT(CASE WHEN subject_continued_in_study = FALSE THEN 1 END)
      comment: "Count of deviations resulting in subject discontinuation from study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subject Discontinuation Rate"
      display_name: "Subject Discontinuation Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN subject_continued_in_study = FALSE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of deviations leading to subject discontinuation, an enrollment impact metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sponsor Notified Count"
      display_name: "Sponsor Notified Count"
      expr: COUNT(CASE WHEN sponsor_notified = TRUE THEN 1 END)
      comment: "Count of deviations where sponsor was notified"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_rand_scheme`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Randomization scheme design and configuration KPIs tracking scheme complexity, stratification, allocation methods, and scheme lifecycle."
  source: "`clinical_trials_ecm`.`randomization`.`rand_scheme`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Rand Scheme ID"
      display_name: "Rand Scheme ID"
      expr: rand_scheme_id
      comment: "Unique identifier for the randomization scheme"
    - name: "Scheme Status"
      display_name: "Scheme Status"
      expr: scheme_status
      comment: "Current status of the randomization scheme (draft, approved, active, retired)"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Type of blinding implemented in the scheme (single-blind, double-blind, open-label)"
    - name: "Allocation Algorithm"
      display_name: "Allocation Algorithm"
      expr: allocation_algorithm
      comment: "Algorithm used for treatment allocation (block, stratified, minimization, adaptive)"
    - name: "Generation Method Description"
      display_name: "Generation Method"
      expr: generation_method_description
      comment: "Description of the randomization list generation method"
    - name: "Generation Software"
      display_name: "Generation Software"
      expr: generation_software
      comment: "Software used to generate the randomization scheme"
    - name: "Is Centralized"
      display_name: "Centralized"
      expr: is_centralized
      comment: "Flag indicating whether randomization is centralized (IRT/IWRS)"
    - name: "Is Stratified By Site"
      display_name: "Stratified By Site"
      expr: is_stratified_by_site
      comment: "Flag indicating whether randomization is stratified by site"
    - name: "Is Variable Block"
      display_name: "Variable Block"
      expr: is_variable_block
      comment: "Flag indicating whether variable block sizes are used"
    - name: "IRB IEC Approval Required"
      display_name: "IRB/IEC Approval Required"
      expr: irb_iec_approval_required
      comment: "Flag indicating whether IRB/IEC approval is required for the scheme"
    - name: "Regulatory Submission Flag"
      display_name: "Regulatory Submission"
      expr: regulatory_submission_flag
      comment: "Flag indicating whether scheme is included in regulatory submissions"
    - name: "Geographic Scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the randomization scheme (global, regional, country-specific)"
  measures:
    - name: "Total Rand Schemes"
      display_name: "Total Rand Schemes"
      expr: COUNT(1)
      comment: "Total number of randomization schemes defined across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Rand Schemes"
      display_name: "Active Rand Schemes"
      expr: COUNT(CASE WHEN scheme_status = 'active' THEN 1 END)
      comment: "Count of randomization schemes currently active"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Rand Schemes"
      display_name: "Approved Rand Schemes"
      expr: COUNT(CASE WHEN scheme_status = 'approved' THEN 1 END)
      comment: "Count of randomization schemes approved but not yet active"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Retired Rand Schemes"
      display_name: "Retired Rand Schemes"
      expr: COUNT(CASE WHEN scheme_status = 'retired' THEN 1 END)
      comment: "Count of randomization schemes retired from use"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Randomization Slots"
      display_name: "Total Randomization Slots"
      expr: SUM(CAST(total_randomization_slots AS DOUBLE))
      comment: "Sum of total randomization slots across all schemes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Randomization Slots Per Scheme"
      display_name: "Avg Randomization Slots Per Scheme"
      expr: AVG(CAST(total_randomization_slots AS DOUBLE))
      comment: "Average number of randomization slots per scheme, indicating study size"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Treatment Arms Per Scheme"
      display_name: "Avg Treatment Arms Per Scheme"
      expr: AVG(CAST(treatment_arm_count AS DOUBLE))
      comment: "Average number of treatment arms per scheme, indicating study complexity"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Strata Per Scheme"
      display_name: "Avg Strata Per Scheme"
      expr: AVG(CAST(strata_count AS DOUBLE))
      comment: "Average number of stratification strata per scheme, indicating design complexity"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Centralized Schemes Count"
      display_name: "Centralized Schemes Count"
      expr: COUNT(CASE WHEN is_centralized = TRUE THEN 1 END)
      comment: "Count of schemes using centralized randomization (IRT/IWRS)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Centralized Schemes Rate"
      display_name: "Centralized Schemes Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_centralized = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of schemes using centralized randomization, a technology adoption metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Site Stratified Schemes Count"
      display_name: "Site-Stratified Schemes Count"
      expr: COUNT(CASE WHEN is_stratified_by_site = TRUE THEN 1 END)
      comment: "Count of schemes stratified by site"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Variable Block Schemes Count"
      display_name: "Variable Block Schemes Count"
      expr: COUNT(CASE WHEN is_variable_block = TRUE THEN 1 END)
      comment: "Count of schemes using variable block sizes for allocation concealment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB IEC Approval Required Count"
      display_name: "IRB/IEC Approval Required Count"
      expr: COUNT(CASE WHEN irb_iec_approval_required = TRUE THEN 1 END)
      comment: "Count of schemes requiring IRB/IEC approval"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Submission Count"
      display_name: "Regulatory Submission Count"
      expr: COUNT(CASE WHEN regulatory_submission_flag = TRUE THEN 1 END)
      comment: "Count of schemes included in regulatory submissions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Minimization Probability"
      display_name: "Avg Minimization Probability"
      expr: AVG(CAST(minimization_probability AS DOUBLE))
      comment: "Average minimization probability across schemes using minimization algorithms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_stratification_cell`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stratification cell balance and enrollment KPIs tracking actual vs target enrollment, allocation balance, and cell-level operational status to ensure randomization integrity."
  source: "`clinical_trials_ecm`.`randomization`.`stratification_cell`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Stratification Cell ID"
      display_name: "Stratification Cell ID"
      expr: stratification_cell_id
      comment: "Unique identifier for the stratification cell"
    - name: "Cell Status"
      display_name: "Cell Status"
      expr: cell_status
      comment: "Current operational status of the stratification cell (active, suspended, closed)"
    - name: "Cell Balance Status"
      display_name: "Cell Balance Status"
      expr: cell_balance_status
      comment: "Balance status of the cell relative to allocation targets (balanced, imbalanced, critical)"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region associated with the stratification cell"
    - name: "Is Active for Enrollment"
      display_name: "Active for Enrollment"
      expr: is_active_for_enrollment
      comment: "Flag indicating whether the cell is currently active for enrollment"
    - name: "Is Blinded"
      display_name: "Is Blinded"
      expr: is_blinded
      comment: "Flag indicating whether the cell allocation is blinded"
    - name: "Randomization Method"
      display_name: "Randomization Method"
      expr: randomization_method
      comment: "Randomization method used for the cell (block, adaptive, minimization)"
  measures:
    - name: "Total Stratification Cells"
      display_name: "Total Stratification Cells"
      expr: COUNT(1)
      comment: "Total number of stratification cells defined across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Cells"
      display_name: "Active Cells"
      expr: COUNT(CASE WHEN cell_status = 'active' THEN 1 END)
      comment: "Count of stratification cells currently active for enrollment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Closed Cells"
      display_name: "Closed Cells"
      expr: COUNT(CASE WHEN cell_status = 'closed' THEN 1 END)
      comment: "Count of stratification cells closed to enrollment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Imbalanced Cells"
      display_name: "Imbalanced Cells"
      expr: COUNT(CASE WHEN cell_balance_status IN ('imbalanced', 'critical') THEN 1 END)
      comment: "Count of stratification cells with allocation imbalance"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Imbalanced Cell Rate"
      display_name: "Imbalanced Cell Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN cell_balance_status IN ('imbalanced', 'critical') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stratification cells with allocation imbalance, indicating randomization quality"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Target Enrollment"
      display_name: "Total Target Enrollment"
      expr: SUM(CAST(target_enrollment_count AS DOUBLE))
      comment: "Sum of target enrollment counts across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Enrollment"
      display_name: "Total Actual Enrollment"
      expr: SUM(CAST(actual_enrolled_count AS DOUBLE))
      comment: "Sum of actual enrolled subjects across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Randomized"
      display_name: "Total Randomized"
      expr: SUM(CAST(randomized_count AS DOUBLE))
      comment: "Sum of randomized subjects across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Screened"
      display_name: "Total Screened"
      expr: SUM(CAST(screened_count AS DOUBLE))
      comment: "Sum of screened subjects across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Withdrawn"
      display_name: "Total Withdrawn"
      expr: SUM(CAST(withdrawn_count AS DOUBLE))
      comment: "Sum of withdrawn subjects across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Minimum Enrollment"
      display_name: "Total Minimum Enrollment"
      expr: SUM(CAST(minimum_enrollment_count AS DOUBLE))
      comment: "Sum of minimum enrollment thresholds across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Maximum Enrollment"
      display_name: "Total Maximum Enrollment"
      expr: SUM(CAST(maximum_enrollment_count AS DOUBLE))
      comment: "Sum of maximum enrollment caps across all stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Block Size"
      display_name: "Avg Block Size"
      expr: AVG(CAST(block_size AS DOUBLE))
      comment: "Average block size used across stratification cells"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Balance Tolerance Pct"
      display_name: "Avg Balance Tolerance %"
      expr: AVG(CAST(balance_tolerance_pct AS DOUBLE))
      comment: "Average balance tolerance percentage across stratification cells"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unique Studies"
      display_name: "Unique Studies"
      expr: COUNT(DISTINCT study_id)
      comment: "Distinct count of studies with defined stratification cells"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Treatment Arms"
      display_name: "Unique Treatment Arms"
      expr: COUNT(DISTINCT treatment_arm_id)
      comment: "Distinct count of treatment arms associated with stratification cells"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_subject_randomization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core randomization KPIs tracking subject enrollment, randomization velocity, treatment allocation balance, and protocol compliance across studies and sites."
  source: "`clinical_trials_ecm`.`randomization`.`subject_randomization`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Study Site ID"
      display_name: "Study Site ID"
      expr: study_site_id
      comment: "Unique identifier for the study site where randomization occurred"
    - name: "Treatment Arm ID"
      display_name: "Treatment Arm ID"
      expr: treatment_arm_id
      comment: "Unique identifier for the assigned treatment arm"
    - name: "Randomization Status"
      display_name: "Randomization Status"
      expr: randomization_status
      comment: "Current status of the randomization record (active, cancelled, completed)"
    - name: "Randomization Type"
      display_name: "Randomization Type"
      expr: randomization_type
      comment: "Type of randomization performed (initial, re-randomization, emergency)"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Type of blinding applied (single-blind, double-blind, open-label)"
    - name: "Country Code"
      display_name: "Country"
      expr: country_code
      comment: "ISO country code where randomization occurred"
    - name: "Randomization Date"
      display_name: "Randomization Date"
      expr: randomization_date
      comment: "Date when subject was randomized"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Randomization Year"
      display_name: "Randomization Year"
      expr: DATE_TRUNC('year', randomization_date)
      comment: "Year of randomization for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Randomization Quarter"
      display_name: "Randomization Quarter"
      expr: DATE_TRUNC('quarter', randomization_date)
      comment: "Quarter of randomization for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Randomization Month"
      display_name: "Randomization Month"
      expr: DATE_TRUNC('month', randomization_date)
      comment: "Month of randomization for monthly trending and time-intelligence"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Randomization Week"
      display_name: "Randomization Week"
      expr: DATE_TRUNC('week', randomization_date)
      comment: "Week of randomization for weekly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Unblinded"
      display_name: "Unblinded Flag"
      expr: is_unblinded
      comment: "Flag indicating whether the randomization has been unblinded"
    - name: "Eligibility Confirmed"
      display_name: "Eligibility Confirmed"
      expr: eligibility_confirmed
      comment: "Flag indicating whether subject eligibility was confirmed prior to randomization"
    - name: "Block Number"
      display_name: "Block Number"
      expr: block_number
      comment: "Randomization block number for stratified designs"
  measures:
    - name: "Total Randomizations"
      display_name: "Total Randomizations"
      expr: COUNT(1)
      comment: "Total number of subject randomization events across all studies and sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Randomized"
      display_name: "Unique Subjects Randomized"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Distinct count of subjects who have been randomized, excluding re-randomizations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Randomizations"
      display_name: "Active Randomizations"
      expr: COUNT(CASE WHEN randomization_status = 'active' THEN 1 END)
      comment: "Count of randomizations currently in active status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Cancelled Randomizations"
      display_name: "Cancelled Randomizations"
      expr: COUNT(CASE WHEN randomization_status = 'cancelled' THEN 1 END)
      comment: "Count of randomizations that were cancelled after assignment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Cancellation Rate"
      display_name: "Cancellation Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN randomization_status = 'cancelled' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of randomizations that were cancelled, indicating protocol deviations or enrollment issues"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Re-Randomizations"
      display_name: "Re-Randomizations"
      expr: COUNT(CASE WHEN rerandomization_reason IS NOT NULL THEN 1 END)
      comment: "Count of subjects who required re-randomization due to protocol deviations or other issues"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Re-Randomization Rate"
      display_name: "Re-Randomization Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN rerandomization_reason IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of randomizations requiring re-randomization, a quality indicator for protocol execution"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unblinded Randomizations"
      display_name: "Unblinded Randomizations"
      expr: COUNT(CASE WHEN is_unblinded = TRUE THEN 1 END)
      comment: "Count of randomizations that have been unblinded for safety or other reasons"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unblinding Rate"
      display_name: "Unblinding Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_unblinded = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of randomizations unblinded, a critical safety and protocol compliance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Eligibility Confirmed Count"
      display_name: "Eligibility Confirmed Count"
      expr: COUNT(CASE WHEN eligibility_confirmed = TRUE THEN 1 END)
      comment: "Count of randomizations where subject eligibility was confirmed prior to randomization"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Eligibility Confirmation Rate"
      display_name: "Eligibility Confirmation Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN eligibility_confirmed = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of randomizations with confirmed eligibility, a protocol compliance quality metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Randomizations CM"
      display_name: "Randomizations (Current Month)"
      expr: COUNT(1)
      comment: "Current month randomizations for time-intelligence comparison"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Randomization Month
          range: current
          semiadditive: last
    - name: "Randomizations PM"
      display_name: "Randomizations (Prior Month)"
      expr: COUNT(1)
      comment: "Prior month randomizations for month-over-month growth calculation"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Randomization Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Randomizations MoM Growth"
      display_name: "Randomizations MoM Growth (%)"
      expr: SUM(CAST((ROUND(100.0 * (AGG(Randomizations CM) - AGG(Randomizations PM)) / NULLIF(AGG(Randomizations PM), 0), 2)) AS DOUBLE))
      comment: "Month-over-month growth rate in randomizations, a key enrollment velocity indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Randomizations MTD"
      display_name: "Randomizations (MTD)"
      expr: COUNT(1)
      comment: "Month-to-date cumulative randomizations for in-month tracking"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Randomization Date
          range: cumulative
          semiadditive: last
        - order: Randomization Month
          range: current
          semiadditive: last
    - name: "Randomizations 7D Rolling"
      display_name: "Randomizations (7-Day Rolling)"
      expr: COUNT(1)
      comment: "7-day rolling sum of randomizations for short-term velocity tracking"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Randomization Date
          range: trailing 7 day inclusive
          semiadditive: last
    - name: "Randomizations 30D Rolling"
      display_name: "Randomizations (30-Day Rolling)"
      expr: COUNT(1)
      comment: "30-day rolling sum of randomizations for medium-term velocity trending"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Randomization Date
          range: trailing 30 day inclusive
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_treatment_arm`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Treatment arm allocation and balance KPIs tracking planned vs actual enrollment, allocation ratios, and arm-level performance across studies."
  source: "`clinical_trials_ecm`.`randomization`.`treatment_arm`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Treatment Arm ID"
      display_name: "Treatment Arm ID"
      expr: treatment_arm_id
      comment: "Unique identifier for the treatment arm"
    - name: "Arm Type"
      display_name: "Arm Type"
      expr: arm_type
      comment: "Type of treatment arm (experimental, control, placebo, active comparator)"
    - name: "Arm Status"
      display_name: "Arm Status"
      expr: arm_status
      comment: "Current status of the treatment arm (active, suspended, closed)"
    - name: "Is Control Arm"
      display_name: "Control Arm Flag"
      expr: is_control_arm
      comment: "Flag indicating whether this is the control arm"
    - name: "Blinding Role"
      display_name: "Blinding Role"
      expr: blinding_role
      comment: "Blinding role for this treatment arm (blinded, unblinded, open-label)"
    - name: "Randomization Method"
      display_name: "Randomization Method"
      expr: randomization_method
      comment: "Randomization method used for this arm (block, stratified, adaptive)"
    - name: "Route of Administration"
      display_name: "Route of Administration"
      expr: route_of_administration
      comment: "Route of administration for the treatment (oral, IV, subcutaneous)"
    - name: "Dose Level"
      display_name: "Dose Level"
      expr: dose_level
      comment: "Dose level for this treatment arm"
    - name: "Analysis Population"
      display_name: "Analysis Population"
      expr: analysis_population
      comment: "Analysis population designation for this arm (ITT, PP, safety)"
  measures:
    - name: "Total Treatment Arms"
      display_name: "Total Treatment Arms"
      expr: COUNT(1)
      comment: "Total number of treatment arms defined across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Treatment Arms"
      display_name: "Active Treatment Arms"
      expr: COUNT(CASE WHEN arm_status = 'active' THEN 1 END)
      comment: "Count of treatment arms currently active for enrollment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Suspended Treatment Arms"
      display_name: "Suspended Treatment Arms"
      expr: COUNT(CASE WHEN arm_status = 'suspended' THEN 1 END)
      comment: "Count of treatment arms temporarily suspended from enrollment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Enrollment"
      display_name: "Total Planned Enrollment"
      expr: SUM(CAST(planned_subject_count AS DOUBLE))
      comment: "Sum of planned subject counts across all treatment arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Min Enrollment"
      display_name: "Total Min Enrollment"
      expr: SUM(CAST(min_subject_count AS DOUBLE))
      comment: "Sum of minimum required subject counts across all treatment arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Max Enrollment"
      display_name: "Total Max Enrollment"
      expr: SUM(CAST(max_subject_count AS DOUBLE))
      comment: "Sum of maximum allowed subject counts across all treatment arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Planned Enrollment Per Arm"
      display_name: "Avg Planned Enrollment Per Arm"
      expr: AVG(CAST(planned_subject_count AS DOUBLE))
      comment: "Average planned enrollment per treatment arm, indicating study size and complexity"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Target Allocation Pct"
      display_name: "Avg Target Allocation (%)"
      expr: AVG(CAST(target_allocation_pct AS DOUBLE))
      comment: "Average target allocation percentage across treatment arms, should balance to 100% within study"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allocation Ratio Numerator"
      display_name: "Avg Allocation Ratio Numerator"
      expr: AVG(CAST(allocation_ratio_numerator AS DOUBLE))
      comment: "Average allocation ratio numerator across treatment arms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allocation Ratio Denominator"
      display_name: "Avg Allocation Ratio Denominator"
      expr: AVG(CAST(allocation_ratio_denominator AS DOUBLE))
      comment: "Average allocation ratio denominator across treatment arms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Control Arms Count"
      display_name: "Control Arms Count"
      expr: COUNT(CASE WHEN is_control_arm = TRUE THEN 1 END)
      comment: "Count of control arms across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Experimental Arms Count"
      display_name: "Experimental Arms Count"
      expr: COUNT(CASE WHEN is_control_arm = FALSE THEN 1 END)
      comment: "Count of experimental (non-control) arms across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Washout Period Days"
      display_name: "Avg Washout Period (Days)"
      expr: AVG(CAST(washout_period_days AS DOUBLE))
      comment: "Average washout period in days across treatment arms with crossover designs"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`randomization_unblinding_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Unblinding request and emergency unblinding KPIs tracking request volume, approval rates, turnaround time, and reasons for unblinding."
  source: "`clinical_trials_ecm`.`randomization`.`unblinding_request`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Study Site ID"
      display_name: "Study Site ID"
      expr: study_site_id
      comment: "Unique identifier for the study site submitting the request"
    - name: "Request Status"
      display_name: "Request Status"
      expr: request_status
      comment: "Current status of the unblinding request (submitted, under review, approved, denied)"
    - name: "Unblinding Reason"
      display_name: "Unblinding Reason"
      expr: unblinding_reason
      comment: "Primary reason for the unblinding request (SAE, medical emergency, protocol deviation)"
    - name: "Unblinding Scope"
      display_name: "Unblinding Scope"
      expr: unblinding_scope
      comment: "Scope of unblinding requested (subject-level, site-level, study-level)"
    - name: "Urgency Level"
      display_name: "Urgency Level"
      expr: urgency_level
      comment: "Urgency classification of the request (routine, urgent, emergency)"
    - name: "Final Outcome"
      display_name: "Final Outcome"
      expr: final_outcome
      comment: "Final outcome of the unblinding request (approved, denied, withdrawn)"
    - name: "Requestor Role"
      display_name: "Requestor Role"
      expr: requestor_role
      comment: "Role of the person requesting unblinding (investigator, CRA, medical monitor)"
    - name: "Approver 1 Decision"
      display_name: "Approver 1 Decision"
      expr: approver_1_decision
      comment: "Decision of the first approver (approved, denied, escalated)"
    - name: "Approver 2 Decision"
      display_name: "Approver 2 Decision"
      expr: approver_2_decision
      comment: "Decision of the second approver if escalation required"
    - name: "Blinding Broken Flag"
      display_name: "Blinding Broken"
      expr: blinding_broken_flag
      comment: "Flag indicating whether blinding was actually broken"
    - name: "Protocol Deviation Raised"
      display_name: "Protocol Deviation Raised"
      expr: protocol_deviation_raised
      comment: "Flag indicating whether a protocol deviation was raised as a result"
    - name: "IRB IEC Notification Required"
      display_name: "IRB/IEC Notification Required"
      expr: irb_iec_notification_required
      comment: "Flag indicating whether IRB/IEC notification is required"
    - name: "DSMB DMC Referral Flag"
      display_name: "DSMB/DMC Referral"
      expr: dsmb_dmc_referral_flag
      comment: "Flag indicating whether case was referred to DSMB/DMC"
    - name: "Submitted Date"
      display_name: "Submitted Date"
      expr: submitted_timestamp
      comment: "Timestamp when the unblinding request was submitted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submitted Month"
      display_name: "Submitted Month"
      expr: DATE_TRUNC('month', submitted_timestamp)
      comment: "Month when request was submitted for trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Unblinding Requests"
      display_name: "Total Unblinding Requests"
      expr: COUNT(1)
      comment: "Total number of unblinding requests submitted across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Requests"
      display_name: "Approved Requests"
      expr: COUNT(CASE WHEN final_outcome = 'approved' THEN 1 END)
      comment: "Count of unblinding requests that were approved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Denied Requests"
      display_name: "Denied Requests"
      expr: COUNT(CASE WHEN final_outcome = 'denied' THEN 1 END)
      comment: "Count of unblinding requests that were denied"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN final_outcome = 'approved' THEN 1 END) / NULLIF(COUNT(CASE WHEN final_outcome IN ('approved', 'denied') THEN 1 END), 0), 2)
      comment: "Percentage of unblinding requests approved, indicating appropriateness of requests"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Emergency Requests"
      display_name: "Emergency Requests"
      expr: COUNT(CASE WHEN urgency_level = 'emergency' THEN 1 END)
      comment: "Count of emergency unblinding requests requiring immediate action"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Emergency Request Rate"
      display_name: "Emergency Request Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN urgency_level = 'emergency' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests classified as emergency, a safety signal metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SAE Related Requests"
      display_name: "SAE-Related Requests"
      expr: COUNT(CASE WHEN unblinding_reason LIKE '%SAE%' OR unblinding_reason LIKE '%adverse%' THEN 1 END)
      comment: "Count of unblinding requests related to serious adverse events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinding Actually Broken Count"
      display_name: "Blinding Broken Count"
      expr: COUNT(CASE WHEN blinding_broken_flag = TRUE THEN 1 END)
      comment: "Count of requests where blinding was actually broken"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinding Broken Rate"
      display_name: "Blinding Broken Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN blinding_broken_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests resulting in actual blinding breach, a study integrity metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Deviation Raised Count"
      display_name: "Protocol Deviation Raised Count"
      expr: COUNT(CASE WHEN protocol_deviation_raised = TRUE THEN 1 END)
      comment: "Count of unblinding requests that triggered protocol deviation reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB IEC Notification Count"
      display_name: "IRB/IEC Notification Count"
      expr: COUNT(CASE WHEN irb_iec_notification_required = TRUE THEN 1 END)
      comment: "Count of requests requiring IRB/IEC notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB DMC Referral Count"
      display_name: "DSMB/DMC Referral Count"
      expr: COUNT(CASE WHEN dsmb_dmc_referral_flag = TRUE THEN 1 END)
      comment: "Count of requests referred to DSMB/DMC for review"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Multi Level Approval Count"
      display_name: "Multi-Level Approval Count"
      expr: COUNT(CASE WHEN approval_level_count > 1 THEN 1 END)
      comment: "Count of requests requiring multiple approval levels"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Withdrawn Requests"
      display_name: "Withdrawn Requests"
      expr: COUNT(CASE WHEN final_outcome = 'withdrawn' THEN 1 END)
      comment: "Count of unblinding requests withdrawn before decision"
      format:
        type: number
        decimal_places:
          type: all
$$;
