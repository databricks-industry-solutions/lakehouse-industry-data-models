-- Metric views for domain: study | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_arm`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study arm performance metrics tracking planned vs actual enrollment, allocation ratios, and arm-level operational KPIs for study design optimization and enrollment forecasting."
  source: "`clinical_trials_ecm`.`study`.`arm`"
  dimensions:
    - name: "Arm Name"
      display_name: "Arm Name"
      expr: arm_name
      comment: "Name of the study arm"
    - name: "Arm Type"
      display_name: "Arm Type"
      expr: arm_type
      comment: "Type of study arm"
    - name: "Arm Status"
      display_name: "Arm Status"
      expr: arm_status
      comment: "Current status of the study arm"
    - name: "Is Control Arm"
      display_name: "Control Arm"
      expr: is_control_arm
      comment: "Whether this is a control arm"
    - name: "Is Blinded"
      display_name: "Blinded"
      expr: is_blinded
      comment: "Whether the arm is blinded"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Type of blinding applied to the arm"
    - name: "Adaptive Design Flag"
      display_name: "Adaptive Design"
      expr: adaptive_design_flag
      comment: "Whether the arm uses adaptive design"
    - name: "ITT Population Flag"
      display_name: "ITT Population"
      expr: itt_population_flag
      comment: "Whether the arm is included in intent-to-treat population"
    - name: "Safety Population Flag"
      display_name: "Safety Population"
      expr: safety_population_flag
      comment: "Whether the arm is included in safety population"
  measures:
    - name: "Arm Count"
      display_name: "Arm Count"
      expr: COUNT(1)
      comment: "Total number of study arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Subjects"
      display_name: "Total Planned Subjects"
      expr: SUM(CAST(planned_subjects_count AS DOUBLE))
      comment: "Sum of planned subjects across all arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Min Subjects"
      display_name: "Total Min Subjects"
      expr: SUM(CAST(min_subjects_count AS DOUBLE))
      comment: "Sum of minimum subjects required across all arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Max Subjects"
      display_name: "Total Max Subjects"
      expr: SUM(CAST(max_subjects_count AS DOUBLE))
      comment: "Sum of maximum subjects allowed across all arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Planned Subjects Per Arm"
      display_name: "Avg Planned Subjects"
      expr: AVG(CAST(planned_subjects_count AS DOUBLE))
      comment: "Average planned subjects per arm"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Allocation Ratio"
      display_name: "Avg Allocation Ratio"
      expr: AVG(CAST(allocation_ratio AS DOUBLE))
      comment: "Average allocation ratio across arms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Treatment Duration Days"
      display_name: "Avg Treatment Duration (Days)"
      expr: AVG(CAST(treatment_duration_days AS DOUBLE))
      comment: "Average treatment duration in days across arms"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Control Arm Count"
      display_name: "Control Arms"
      expr: COUNT(DISTINCT CASE WHEN is_control_arm = TRUE THEN arm_id END)
      comment: "Number of control arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Blinded Arm Count"
      display_name: "Blinded Arms"
      expr: COUNT(DISTINCT CASE WHEN is_blinded = TRUE THEN arm_id END)
      comment: "Number of blinded arms"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Adaptive Design Arm Count"
      display_name: "Adaptive Arms"
      expr: COUNT(DISTINCT CASE WHEN adaptive_design_flag = TRUE THEN arm_id END)
      comment: "Number of arms using adaptive design"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_country`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Country-level study performance metrics tracking site activation, enrollment, and regulatory milestones for geographic portfolio management and resource allocation decisions."
  source: "`clinical_trials_ecm`.`study`.`country`"
  dimensions:
    - name: "Country Code"
      display_name: "Country Code"
      expr: country_code
      comment: "ISO country code"
    - name: "Country Name"
      display_name: "Country Name"
      expr: country_name
      comment: "Full country name"
    - name: "Activation Status"
      display_name: "Activation Status"
      expr: activation_status
      comment: "Country activation status"
    - name: "Enrollment Status"
      display_name: "Enrollment Status"
      expr: enrollment_status
      comment: "Country enrollment status"
    - name: "CTA Approval Status"
      display_name: "CTA Approval Status"
      expr: cta_approval_status
      comment: "Clinical trial application approval status"
    - name: "Regulatory Hold Flag"
      display_name: "Regulatory Hold"
      expr: regulatory_hold_flag
      comment: "Whether the country is under regulatory hold"
    - name: "CTA Approval Year"
      display_name: "CTA Approval Year"
      expr: DATE_TRUNC('year', cta_approval_date)
      comment: "Year of CTA approval"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CTA Approval Month"
      display_name: "CTA Approval Month"
      expr: DATE_TRUNC('month', cta_approval_date)
      comment: "Month of CTA approval"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "First Subject Enrolled Year"
      display_name: "First Subject Year"
      expr: DATE_TRUNC('year', first_subject_enrolled_date)
      comment: "Year of first subject enrollment in country"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "First Subject Enrolled Month"
      display_name: "First Subject Month"
      expr: DATE_TRUNC('month', first_subject_enrolled_date)
      comment: "Month of first subject enrollment in country"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Country Count"
      display_name: "Country Count"
      expr: COUNT(1)
      comment: "Total number of country records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Enrollment"
      display_name: "Total Planned Enrollment"
      expr: SUM(CAST(planned_enrollment_target AS DOUBLE))
      comment: "Sum of planned enrollment targets across countries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Enrolled"
      display_name: "Total Actual Enrolled"
      expr: SUM(CAST(actual_enrolled_count AS DOUBLE))
      comment: "Sum of actual enrolled subjects across countries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Country Enrollment Achievement Rate"
      display_name: "Enrollment Achievement %"
      expr: ROUND(100.0 * SUM(CAST(actual_enrolled_count AS DOUBLE)) / NULLIF(SUM(CAST(planned_enrollment_target AS DOUBLE)), 0), 2)
      comment: "Percentage of planned enrollment achieved across countries"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Screened"
      display_name: "Total Screened"
      expr: SUM(CAST(actual_screened_count AS DOUBLE))
      comment: "Sum of actual screened subjects across countries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screen to Enrollment Conversion Rate"
      display_name: "Screen-to-Enroll %"
      expr: ROUND(100.0 * SUM(CAST(actual_enrolled_count AS DOUBLE)) / NULLIF(SUM(CAST(actual_screened_count AS DOUBLE)), 0), 2)
      comment: "Percentage of screened subjects who were enrolled"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Activated Sites"
      display_name: "Total Activated Sites"
      expr: SUM(CAST(activated_site_count AS DOUBLE))
      comment: "Sum of activated sites across countries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Sites"
      display_name: "Total Planned Sites"
      expr: SUM(CAST(planned_site_count AS DOUBLE))
      comment: "Sum of planned sites across countries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Site Activation Rate"
      display_name: "Site Activation %"
      expr: ROUND(100.0 * SUM(CAST(activated_site_count AS DOUBLE)) / NULLIF(SUM(CAST(planned_site_count AS DOUBLE)), 0), 2)
      comment: "Percentage of planned sites that have been activated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Feasibility Score"
      display_name: "Avg Feasibility Score"
      expr: AVG(CAST(feasibility_score AS DOUBLE))
      comment: "Average feasibility score across countries"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Countries Under Regulatory Hold"
      display_name: "Countries on Hold"
      expr: COUNT(DISTINCT CASE WHEN regulatory_hold_flag = TRUE THEN country_id END)
      comment: "Number of countries currently under regulatory hold"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Budget Amount"
      display_name: "Total Budget"
      expr: SUM(CAST(budget_amount AS DOUBLE))
      comment: "Sum of budget amounts across countries"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_eligibility_criterion`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Eligibility criteria metrics tracking inclusion/exclusion complexity, critical criteria distribution, and waiver rates for protocol feasibility assessment and enrollment optimization."
  source: "`clinical_trials_ecm`.`study`.`eligibility_criterion`"
  dimensions:
    - name: "Criterion Type"
      display_name: "Criterion Type"
      expr: criterion_type
      comment: "Type of eligibility criterion (inclusion or exclusion)"
    - name: "Criterion Category"
      display_name: "Criterion Category"
      expr: criterion_category
      comment: "Category of the eligibility criterion"
    - name: "Criterion Status"
      display_name: "Criterion Status"
      expr: criterion_status
      comment: "Current status of the criterion"
    - name: "Is Critical Criterion"
      display_name: "Critical Criterion"
      expr: is_critical_criterion
      comment: "Whether this is a critical eligibility criterion"
    - name: "Waiver Allowed"
      display_name: "Waiver Allowed"
      expr: waiver_allowed
      comment: "Whether waivers are allowed for this criterion"
    - name: "IRB IEC Approval Required"
      display_name: "IRB Approval Required"
      expr: irb_iec_approval_required
      comment: "Whether IRB/IEC approval is required for changes"
    - name: "Is Amendment Driven"
      display_name: "Amendment Driven"
      expr: is_amendment_driven
      comment: "Whether the criterion was introduced via amendment"
    - name: "Requires Source Doc Verification"
      display_name: "Source Doc Required"
      expr: requires_source_doc_verification
      comment: "Whether source document verification is required"
  measures:
    - name: "Criterion Count"
      display_name: "Criterion Count"
      expr: COUNT(1)
      comment: "Total number of eligibility criteria"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Studies With Criteria"
      display_name: "Studies With Criteria"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of distinct studies with eligibility criteria"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Criterion Count"
      display_name: "Critical Criteria"
      expr: COUNT(DISTINCT CASE WHEN is_critical_criterion = TRUE THEN eligibility_criterion_id END)
      comment: "Number of critical eligibility criteria"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Criterion Rate"
      display_name: "Critical Criterion %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_critical_criterion = TRUE THEN eligibility_criterion_id END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of criteria that are critical"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Allowed Criterion Count"
      display_name: "Waiver Allowed Criteria"
      expr: COUNT(DISTINCT CASE WHEN waiver_allowed = TRUE THEN eligibility_criterion_id END)
      comment: "Number of criteria allowing waivers"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waiver Allowed Rate"
      display_name: "Waiver Allowed %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN waiver_allowed = TRUE THEN eligibility_criterion_id END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of criteria allowing waivers"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Amendment Driven Criterion Count"
      display_name: "Amendment Criteria"
      expr: COUNT(DISTINCT CASE WHEN is_amendment_driven = TRUE THEN eligibility_criterion_id END)
      comment: "Number of criteria introduced via protocol amendment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Approval Required Criterion Count"
      display_name: "IRB Approval Criteria"
      expr: COUNT(DISTINCT CASE WHEN irb_iec_approval_required = TRUE THEN eligibility_criterion_id END)
      comment: "Number of criteria requiring IRB/IEC approval for changes"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_endpoint`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study endpoint design and analysis metrics tracking endpoint count by type, multiplicity adjustment requirements, and estimand strategy for statistical planning and regulatory alignment"
  source: "`clinical_trials_ecm`.`study`.`endpoint`"
  dimensions:
    - name: "Endpoint Type"
      display_name: "Endpoint Type"
      expr: endpoint_type
      comment: "Type of endpoint (Primary, Secondary, Exploratory)"
    - name: "Endpoint Category"
      display_name: "Endpoint Category"
      expr: endpoint_category
      comment: "Category of endpoint (Efficacy, Safety, Pharmacokinetic)"
    - name: "Endpoint Status"
      display_name: "Endpoint Status"
      expr: endpoint_status
      comment: "Current status of the endpoint (Active, Retired, Amended)"
    - name: "Objective Type"
      display_name: "Objective Type"
      expr: objective_type
      comment: "Type of objective the endpoint supports (Primary, Secondary)"
    - name: "Multiplicity Adjustment Flag"
      display_name: "Multiplicity Adjustment Flag"
      expr: CASE WHEN multiplicity_adjustment_flag THEN 'Yes' ELSE 'No' END
      comment: "Whether multiplicity adjustment is required for this endpoint"
    - name: "Statistical Hypothesis"
      display_name: "Statistical Hypothesis"
      expr: statistical_hypothesis
      comment: "Statistical hypothesis type (Superiority, Non-inferiority, Equivalence)"
    - name: "Estimand Strategy"
      display_name: "Estimand Strategy"
      expr: estimand_intercurrent_event_strategy
      comment: "Strategy for handling intercurrent events in the estimand"
  measures:
    - name: "Endpoint Count"
      display_name: "Endpoint Count"
      expr: COUNT(1)
      comment: "Total number of study endpoints"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Primary Endpoint Count"
      display_name: "Primary Endpoint Count"
      expr: COUNT(CASE WHEN endpoint_type = 'Primary' THEN 1 END)
      comment: "Number of primary endpoints"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Secondary Endpoint Count"
      display_name: "Secondary Endpoint Count"
      expr: COUNT(CASE WHEN endpoint_type = 'Secondary' THEN 1 END)
      comment: "Number of secondary endpoints"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Exploratory Endpoint Count"
      display_name: "Exploratory Endpoint Count"
      expr: COUNT(CASE WHEN endpoint_type = 'Exploratory' THEN 1 END)
      comment: "Number of exploratory endpoints"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Multiplicity Adjustment Required Count"
      display_name: "Multiplicity Adjustment Required Count"
      expr: COUNT(CASE WHEN multiplicity_adjustment_flag THEN 1 END)
      comment: "Number of endpoints requiring multiplicity adjustment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Multiplicity Adjustment Rate"
      display_name: "Multiplicity Adjustment Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN multiplicity_adjustment_flag THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of endpoints requiring multiplicity adjustment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core study performance metrics tracking enrollment, site activation, and study lifecycle KPIs for portfolio steering and operational decision-making."
  source: "`clinical_trials_ecm`.`study`.`study`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: development_phase
      comment: "Development phase of the study (Phase I, II, III, IV)"
    - name: "Study Status"
      display_name: "Study Status"
      expr: study_status
      comment: "Current operational status of the study"
    - name: "Study Type"
      display_name: "Study Type"
      expr: study_type
      comment: "Type of clinical study (interventional, observational, etc.)"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Blinding methodology (open-label, single-blind, double-blind)"
    - name: "Is Randomized"
      display_name: "Randomized Study"
      expr: is_randomized
      comment: "Whether the study uses randomization"
    - name: "Primary Regulatory Region"
      display_name: "Primary Region"
      expr: primary_regulatory_region
      comment: "Primary regulatory region for the study"
    - name: "Actual Start Year"
      display_name: "Start Year"
      expr: DATE_TRUNC('year', actual_start_date)
      comment: "Year the study actually started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Start Quarter"
      display_name: "Start Quarter"
      expr: DATE_TRUNC('quarter', actual_start_date)
      comment: "Quarter the study actually started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Start Month"
      display_name: "Start Month"
      expr: DATE_TRUNC('month', actual_start_date)
      comment: "Month the study actually started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Study Count"
      display_name: "Study Count"
      expr: COUNT(1)
      comment: "Total number of studies in the portfolio"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Target Enrollment"
      display_name: "Total Target Enrollment"
      expr: SUM(CAST(target_enrollment AS DOUBLE))
      comment: "Sum of target enrollment across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Enrollment"
      display_name: "Total Actual Enrollment"
      expr: SUM(CAST(actual_enrollment AS DOUBLE))
      comment: "Sum of actual enrollment achieved across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enrollment Achievement Rate"
      display_name: "Enrollment Achievement %"
      expr: ROUND(100.0 * SUM(CAST(actual_enrollment AS DOUBLE)) / NULLIF(SUM(CAST(target_enrollment AS DOUBLE)), 0), 2)
      comment: "Percentage of target enrollment achieved across the portfolio"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Planned Sites"
      display_name: "Total Planned Sites"
      expr: SUM(CAST(planned_site_count AS DOUBLE))
      comment: "Sum of planned site count across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Countries"
      display_name: "Total Planned Countries"
      expr: SUM(CAST(planned_country_count AS DOUBLE))
      comment: "Sum of planned country count across all studies"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Sites Per Study"
      display_name: "Avg Sites Per Study"
      expr: AVG(CAST(planned_site_count AS DOUBLE))
      comment: "Average number of planned sites per study"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Target Enrollment Per Study"
      display_name: "Avg Target Enrollment"
      expr: AVG(CAST(target_enrollment AS DOUBLE))
      comment: "Average target enrollment per study"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Studies With Actual Start"
      display_name: "Studies Started"
      expr: COUNT(DISTINCT CASE WHEN actual_start_date IS NOT NULL THEN study_id END)
      comment: "Number of studies that have actually started"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Studies With Actual End"
      display_name: "Studies Completed"
      expr: COUNT(DISTINCT CASE WHEN actual_end_date IS NOT NULL THEN study_id END)
      comment: "Number of studies that have completed"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study milestone tracking metrics measuring planned vs actual achievement, milestone status distribution, and timeline adherence for program management and forecasting."
  source: "`clinical_trials_ecm`.`study`.`study_milestone`"
  dimensions:
    - name: "Milestone Name"
      display_name: "Milestone Name"
      expr: milestone_name
      comment: "Name of the study milestone"
    - name: "Milestone Status"
      display_name: "Milestone Status"
      expr: milestone_status
      comment: "Current status of the milestone"
    - name: "Study Milestone Status"
      display_name: "Study Milestone Status"
      expr: study_milestone_status
      comment: "Study-specific milestone status"
    - name: "Planned Date Year"
      display_name: "Planned Year"
      expr: DATE_TRUNC('year', planned_date)
      comment: "Year of planned milestone date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Planned Date Quarter"
      display_name: "Planned Quarter"
      expr: DATE_TRUNC('quarter', planned_date)
      comment: "Quarter of planned milestone date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Planned Date Month"
      display_name: "Planned Month"
      expr: DATE_TRUNC('month', planned_date)
      comment: "Month of planned milestone date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Date Year"
      display_name: "Actual Year"
      expr: DATE_TRUNC('year', actual_date)
      comment: "Year of actual milestone achievement"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Date Quarter"
      display_name: "Actual Quarter"
      expr: DATE_TRUNC('quarter', actual_date)
      comment: "Quarter of actual milestone achievement"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Date Month"
      display_name: "Actual Month"
      expr: DATE_TRUNC('month', actual_date)
      comment: "Month of actual milestone achievement"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Milestone Count"
      display_name: "Milestone Count"
      expr: COUNT(1)
      comment: "Total number of study milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Studies With Milestones"
      display_name: "Studies With Milestones"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of distinct studies with milestones tracked"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Milestones With Actual Date"
      display_name: "Achieved Milestones"
      expr: COUNT(DISTINCT CASE WHEN actual_date IS NOT NULL THEN study_milestone_id END)
      comment: "Number of milestones that have been achieved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Milestone Achievement Rate"
      display_name: "Achievement Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN actual_date IS NOT NULL THEN study_milestone_id END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of milestones that have been achieved"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Milestones With Planned Date"
      display_name: "Planned Milestones"
      expr: COUNT(DISTINCT CASE WHEN planned_date IS NOT NULL THEN study_milestone_id END)
      comment: "Number of milestones with a planned date set"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_protocol_amendment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Protocol amendment metrics tracking change velocity, regulatory impact, and implementation timelines for study risk management and compliance steering."
  source: "`clinical_trials_ecm`.`study`.`study_protocol_amendment`"
  dimensions:
    - name: "Amendment Status"
      display_name: "Amendment Status"
      expr: amendment_status
      comment: "Current status of the protocol amendment"
    - name: "Amendment Type"
      display_name: "Amendment Type"
      expr: amendment_type
      comment: "Type of protocol amendment"
    - name: "Change Category"
      display_name: "Change Category"
      expr: change_category
      comment: "Category of change introduced by amendment"
    - name: "Safety Driven Flag"
      display_name: "Safety Driven"
      expr: safety_driven_flag
      comment: "Whether the amendment was driven by safety concerns"
    - name: "Subject Impact Flag"
      display_name: "Subject Impact"
      expr: subject_impact_flag
      comment: "Whether the amendment impacts enrolled subjects"
    - name: "Reconsent Required Flag"
      display_name: "Reconsent Required"
      expr: reconsent_required_flag
      comment: "Whether the amendment requires subject reconsent"
    - name: "ICF Version Updated Flag"
      display_name: "ICF Updated"
      expr: icf_version_updated_flag
      comment: "Whether the informed consent form was updated"
    - name: "EDC Configuration Updated Flag"
      display_name: "EDC Updated"
      expr: edc_configuration_updated_flag
      comment: "Whether the EDC configuration was updated"
    - name: "Amendment Date Year"
      display_name: "Amendment Year"
      expr: DATE_TRUNC('year', amendment_date)
      comment: "Year of amendment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Amendment Date Quarter"
      display_name: "Amendment Quarter"
      expr: DATE_TRUNC('quarter', amendment_date)
      comment: "Quarter of amendment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Amendment Date Month"
      display_name: "Amendment Month"
      expr: DATE_TRUNC('month', amendment_date)
      comment: "Month of amendment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Amendment Count"
      display_name: "Amendment Count"
      expr: COUNT(1)
      comment: "Total number of protocol amendments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Studies Amended"
      display_name: "Studies Amended"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of distinct studies with amendments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Driven Amendment Count"
      display_name: "Safety Amendments"
      expr: COUNT(DISTINCT CASE WHEN safety_driven_flag = TRUE THEN study_protocol_amendment_id END)
      comment: "Number of amendments driven by safety concerns"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Amendment Rate"
      display_name: "Safety Amendment %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN safety_driven_flag = TRUE THEN study_protocol_amendment_id END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of amendments that are safety-driven"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Reconsent Required Amendment Count"
      display_name: "Reconsent Amendments"
      expr: COUNT(DISTINCT CASE WHEN reconsent_required_flag = TRUE THEN study_protocol_amendment_id END)
      comment: "Number of amendments requiring subject reconsent"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reconsent Amendment Rate"
      display_name: "Reconsent Amendment %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN reconsent_required_flag = TRUE THEN study_protocol_amendment_id END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of amendments requiring reconsent"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Impact Amendment Count"
      display_name: "Subject Impact Amendments"
      expr: COUNT(DISTINCT CASE WHEN subject_impact_flag = TRUE THEN study_protocol_amendment_id END)
      comment: "Number of amendments impacting enrolled subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ICF Updated Amendment Count"
      display_name: "ICF Updated Amendments"
      expr: COUNT(DISTINCT CASE WHEN icf_version_updated_flag = TRUE THEN study_protocol_amendment_id END)
      comment: "Number of amendments updating the informed consent form"
      format:
        type: number
        decimal_places:
          type: all
    - name: "EDC Updated Amendment Count"
      display_name: "EDC Updated Amendments"
      expr: COUNT(DISTINCT CASE WHEN edc_configuration_updated_flag = TRUE THEN study_protocol_amendment_id END)
      comment: "Number of amendments updating EDC configuration"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_protocol_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study milestone performance metrics tracking on-time delivery, variance, and critical path execution for program management and risk mitigation"
  source: "`clinical_trials_ecm`.`study`.`study_protocol_milestone`"
  dimensions:
    - name: "Milestone Type"
      display_name: "Milestone Type"
      expr: milestone_type
      comment: "Type of milestone (e.g., Regulatory, Enrollment, Database Lock)"
    - name: "Milestone Category"
      display_name: "Milestone Category"
      expr: milestone_category
      comment: "Category of milestone for grouping"
    - name: "Milestone Status"
      display_name: "Milestone Status"
      expr: milestone_status
      comment: "Current status of the milestone (Planned, Achieved, Delayed, Cancelled)"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: study_phase
      comment: "Clinical development phase associated with the milestone"
    - name: "Is Critical Path"
      display_name: "Is Critical Path"
      expr: CASE WHEN is_critical_path THEN 'Yes' ELSE 'No' END
      comment: "Whether the milestone is on the critical path"
    - name: "Is Regulatory Milestone"
      display_name: "Is Regulatory Milestone"
      expr: CASE WHEN is_regulatory_milestone THEN 'Yes' ELSE 'No' END
      comment: "Whether the milestone is a regulatory commitment"
    - name: "Planned Month"
      display_name: "Planned Month"
      expr: DATE_TRUNC('month', planned_date)
      comment: "Month bucket of planned milestone date for time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Month"
      display_name: "Actual Month"
      expr: DATE_TRUNC('month', actual_date)
      comment: "Month bucket of actual milestone achievement date for time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Milestone Count"
      display_name: "Milestone Count"
      expr: COUNT(1)
      comment: "Total number of milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Achieved Milestone Count"
      display_name: "Achieved Milestone Count"
      expr: COUNT(CASE WHEN actual_date IS NOT NULL THEN 1 END)
      comment: "Number of milestones with actual achievement date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Milestone Achievement Rate"
      display_name: "Milestone Achievement Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN actual_date IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of milestones achieved (with actual date recorded)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Variance Days"
      display_name: "Avg Variance Days"
      expr: AVG(CAST(variance_days AS DOUBLE))
      comment: "Average variance in days between planned and actual milestone dates (positive = delay)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Variance Days"
      display_name: "Total Variance Days"
      expr: SUM(CAST(variance_days AS DOUBLE))
      comment: "Total cumulative variance days across all milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Milestone Count"
      display_name: "On-Time Milestone Count"
      expr: COUNT(CASE WHEN variance_days <= 0 THEN 1 END)
      comment: "Number of milestones achieved on or before planned date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Delivery Rate"
      display_name: "On-Time Delivery Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN variance_days <= 0 THEN 1 END) / NULLIF(COUNT(CASE WHEN actual_date IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of achieved milestones delivered on or before planned date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Path Milestone Count"
      display_name: "Critical Path Milestone Count"
      expr: COUNT(CASE WHEN is_critical_path THEN 1 END)
      comment: "Number of milestones on the critical path"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Milestone Count"
      display_name: "Regulatory Milestone Count"
      expr: COUNT(CASE WHEN is_regulatory_milestone THEN 1 END)
      comment: "Number of regulatory commitment milestones"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`study_visit_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study visit schedule complexity and burden metrics for protocol design assessment, site workload planning, and subject burden analysis"
  source: "`clinical_trials_ecm`.`study`.`study_visit_schedule`"
  dimensions:
    - name: "Visit Type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of visit (Screening, Treatment, Follow-up, etc.) for schedule segmentation"
    - name: "Visit Status"
      display_name: "Visit Status"
      expr: visit_status
      comment: "Current status of visit (Active, Retired, Amended) for change tracking"
    - name: "Is Mandatory"
      display_name: "Is Mandatory"
      expr: is_mandatory
      comment: "Indicator of mandatory visit for protocol compliance assessment"
    - name: "Is Unscheduled"
      display_name: "Is Unscheduled"
      expr: is_unscheduled
      comment: "Indicator of unscheduled visit for protocol flexibility assessment"
    - name: "Is Randomization Visit"
      display_name: "Is Randomization"
      expr: is_randomization_visit
      comment: "Indicator of randomization visit for protocol milestone tracking"
    - name: "Is Primary Endpoint Visit"
      display_name: "Is Primary Endpoint"
      expr: is_primary_endpoint_visit
      comment: "Indicator of primary endpoint visit for protocol design and analysis planning"
    - name: "Fasting Required"
      display_name: "Fasting Required"
      expr: fasting_required
      comment: "Indicator of fasting requirement for subject burden assessment"
    - name: "Requires Central Lab"
      display_name: "Central Lab Required"
      expr: requires_central_lab
      comment: "Indicator of central lab requirement for operational planning"
  measures:
    - name: "Total Visit Count"
      display_name: "Total Visits"
      expr: COUNT(DISTINCT study_visit_schedule_id)
      comment: "Total number of scheduled visits for protocol complexity and subject burden assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Mandatory Visit Count"
      display_name: "Mandatory Visits"
      expr: COUNT(DISTINCT CASE WHEN is_mandatory = TRUE THEN study_visit_schedule_id END)
      comment: "Number of mandatory visits for protocol compliance and subject burden assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Mandatory Visit Rate"
      display_name: "Mandatory Visit %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_mandatory = TRUE THEN study_visit_schedule_id END) / NULLIF(COUNT(DISTINCT study_visit_schedule_id), 0), 2)
      comment: "Percentage of visits that are mandatory for protocol flexibility assessment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Visit Duration Minutes"
      display_name: "Avg Visit Duration (Min)"
      expr: AVG(CAST(visit_duration_minutes AS DOUBLE))
      comment: "Average visit duration in minutes for site workload and subject burden assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Visit Duration Minutes"
      display_name: "Total Visit Duration (Min)"
      expr: SUM(CAST(visit_duration_minutes AS DOUBLE))
      comment: "Sum of visit durations across schedule for total subject burden quantification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fasting Visit Count"
      display_name: "Fasting Visits"
      expr: COUNT(DISTINCT CASE WHEN fasting_required = TRUE THEN study_visit_schedule_id END)
      comment: "Number of visits requiring fasting for subject burden assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Central Lab Visit Count"
      display_name: "Central Lab Visits"
      expr: COUNT(DISTINCT CASE WHEN requires_central_lab = TRUE THEN study_visit_schedule_id END)
      comment: "Number of visits requiring central lab for operational planning and cost assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "PK Sampling Visit Count"
      display_name: "PK Sampling Visits"
      expr: COUNT(DISTINCT CASE WHEN is_pk_sampling_visit = TRUE THEN study_visit_schedule_id END)
      comment: "Number of visits with PK sampling for pharmacokinetic study complexity assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Window Before Days"
      display_name: "Avg Window Before (Days)"
      expr: AVG(CAST(window_before_days AS DOUBLE))
      comment: "Average visit window before nominal date for protocol flexibility assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Window After Days"
      display_name: "Avg Window After (Days)"
      expr: AVG(CAST(window_after_days AS DOUBLE))
      comment: "Average visit window after nominal date for protocol flexibility assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;
