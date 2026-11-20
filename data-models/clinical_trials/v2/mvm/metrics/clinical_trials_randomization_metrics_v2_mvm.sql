-- Metric views for domain: randomization | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`randomization_kit_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPIs for kit assignment and dispensing efficiency."
  source: "`clinical_trials_mvm`.`randomization`.`kit_assignment`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "treatment_arm_id"
      display_name: "Treatment Arm Id"
      expr: treatment_arm_id
      comment: "Treatment arm identifier"
    - name: "kit_type"
      display_name: "Kit Type"
      expr: kit_type
      comment: "Type of kit"
    - name: "assignment_status"
      display_name: "Assignment Status"
      expr: assignment_status
      comment: "Current status of kit assignment"
    - name: "dispensing_year"
      display_name: "Dispensing Year"
      expr: DATE_TRUNC('year', dispensing_date)
      comment: "Year of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "dispensing_month"
      display_name: "Dispensing Month"
      expr: DATE_TRUNC('month', dispensing_date)
      comment: "Month of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Kit Assignments"
      display_name: "Total kit assignments"
      expr: COUNT(1)
      comment: "Total number of kit assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Kits Dispensed"
      display_name: "Kits dispensed"
      expr: SUM(CASE WHEN dispensing_date IS NOT NULL THEN 1 ELSE 0 END)
      comment: "Number of kits that have been dispensed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Dispensing Rate"
      display_name: "Dispensing rate"
      expr: (AGG(`Kits Dispensed`) / NULLIF(AGG(`Total Kit Assignments`),0))
      comment: "Proportion of assigned kits that were dispensed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Quantity Dispensed"
      display_name: "Average quantity dispensed"
      expr: AVG(CAST(quantity_dispensed AS DOUBLE))
      comment: "Average quantity of product dispensed per kit"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`randomization_rand_scheme`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Randomization scheme design and configuration KPIs tracking scheme complexity, stratification, allocation methods, and scheme lifecycle."
  source: "`clinical_trials_mvm`.`randomization`.`rand_scheme`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`randomization_subject_randomization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key KPIs for subject randomization including total subjects, blinding rate, and unblinding rate."
  source: "`clinical_trials_mvm`.`randomization`.`subject_randomization`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "treatment_arm_id"
      display_name: "Treatment Arm Id"
      expr: treatment_arm_id
      comment: "Treatment arm identifier"
    - name: "randomization_method"
      display_name: "Randomization Method"
      expr: randomization_method
      comment: "Method used for randomization"
    - name: "randomization_status"
      display_name: "Randomization Status"
      expr: randomization_status
      comment: "Current status of randomization"
    - name: "randomization_year"
      display_name: "Randomization Year"
      expr: DATE_TRUNC('year', randomization_date)
      comment: "Year of randomization"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "randomization_month"
      display_name: "Randomization Month"
      expr: DATE_TRUNC('month', randomization_date)
      comment: "Month of randomization"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Subjects"
      display_name: "Total subjects"
      expr: COUNT(1)
      comment: "Total number of subject randomizations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinded Subjects"
      display_name: "Blinded subjects"
      expr: SUM(CASE WHEN blinding_type = 'blinded' THEN 1 ELSE 0 END)
      comment: "Number of subjects where blinding type is 'blinded'"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinding Rate"
      display_name: "Blinding rate"
      expr: (AGG(`Blinded Subjects`) / NULLIF(AGG(`Total Subjects`),0))
      comment: "Proportion of subjects that are blinded"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unblinded Subjects"
      display_name: "Unblinded subjects"
      expr: SUM(CASE WHEN is_unblinded THEN 1 ELSE 0 END)
      comment: "Number of subjects that have been unblinded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unblinding Rate"
      display_name: "Unblinding rate"
      expr: (AGG(`Unblinded Subjects`) / NULLIF(AGG(`Total Subjects`),0))
      comment: "Proportion of subjects that have been unblinded"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`randomization_treatment_arm`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Treatment arm allocation and balance KPIs tracking planned vs actual enrollment, allocation ratios, and arm-level performance across studies."
  source: "`clinical_trials_mvm`.`randomization`.`treatment_arm`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`randomization_unblinding_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Metrics around unblinding requests, approvals and response times."
  source: "`clinical_trials_mvm`.`randomization`.`unblinding_request`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "request_status"
      display_name: "Request Status"
      expr: request_status
      comment: "Current status of the unblinding request"
    - name: "requestor_role"
      display_name: "Requestor Role"
      expr: requestor_role
      comment: "Role of the person who submitted the request"
    - name: "created_year"
      display_name: "Created Year"
      expr: DATE_TRUNC('year', created_timestamp)
      comment: "Year request created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "created_month"
      display_name: "Created Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Month request created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Unblinding Requests"
      display_name: "Total unblinding requests"
      expr: COUNT(1)
      comment: "Total number of unblinding requests submitted"
      format:
        type: number
        decimal_places:
          type: all
$$;
