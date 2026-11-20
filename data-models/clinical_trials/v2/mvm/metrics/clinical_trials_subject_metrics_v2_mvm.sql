-- Metric views for domain: subject | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`subject_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Protocol deviation metrics to monitor compliance and risk"
  source: "`clinical_trials_mvm`.`subject`.`deviation`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "category"
      display_name: "Category"
      expr: category
      comment: "High‑level category of the deviation (e.g., Process, Data)"
  measures:
    - name: "total_deviations"
      display_name: "Total Deviations"
      expr: COUNT(1)
      comment: "Total number of protocol deviations recorded"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`subject_disposition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Disposition outcomes, focusing on safety‑related discontinuations that impact trial integrity"
  source: "`clinical_trials_mvm`.`subject`.`disposition`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "disposition_status"
      display_name: "Disposition Status"
      expr: disposition_status
      comment: "Current status of the disposition (e.g., Completed, Pending)"
  measures:
    - name: "total_dispositions"
      display_name: "Total Dispositions"
      expr: COUNT(1)
      comment: "Total number of disposition events recorded for subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ae_related_discontinuations"
      display_name: "Discontinuations (AE Related)"
      expr: SUM(CASE WHEN ae_related_discontinuation THEN 1 ELSE 0 END)
      comment: "Count of dispositions where the discontinuation is related to an adverse event"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`subject_enrollment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core enrollment volume metrics for trial monitoring and capacity planning"
  source: "`clinical_trials_mvm`.`subject`.`enrollment`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Identifier of the clinical study"
  measures:
    - name: "total_enrollments"
      display_name: "Total Enrollments"
      expr: COUNT(1)
      comment: "Count of enrollment records representing subjects who have been enrolled in a study"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`subject_medical_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject medical history and baseline condition metrics for eligibility assessment and safety analysis"
  source: "`clinical_trials_mvm`.`subject`.`medical_history`"
  dimensions:
    - name: "Condition Category"
      display_name: "Condition Category"
      expr: condition_category
      comment: "Category of medical history condition"
    - name: "Condition Subcategory"
      display_name: "Condition Subcategory"
      expr: condition_subcategory
      comment: "Subcategory of medical history condition"
    - name: "Condition Status"
      display_name: "Condition Status"
      expr: condition_status
      comment: "Status of the medical condition (Active, Resolved, Chronic)"
    - name: "Severity"
      display_name: "Severity"
      expr: severity
      comment: "Severity of the medical condition"
    - name: "Pre-existing Flag"
      display_name: "Pre-existing"
      expr: pre_existing_flag
      comment: "Whether condition pre-existed study enrollment"
    - name: "Ongoing Flag"
      display_name: "Ongoing"
      expr: ongoing_flag
      comment: "Whether condition is ongoing"
    - name: "AE Related Flag"
      display_name: "AE Related"
      expr: ae_related_flag
      comment: "Whether condition is related to an adverse event"
    - name: "Eligibility Relevant Flag"
      display_name: "Eligibility Relevant"
      expr: eligibility_relevant_flag
      comment: "Whether condition is relevant to eligibility criteria"
    - name: "Concomitant Medication Flag"
      display_name: "Requires Concomitant Med"
      expr: concomitant_medication_flag
      comment: "Whether condition requires concomitant medication"
    - name: "MedDRA SOC"
      display_name: "MedDRA SOC"
      expr: meddra_soc
      comment: "MedDRA System Organ Class"
    - name: "MedDRA PT"
      display_name: "MedDRA PT"
      expr: meddra_pt
      comment: "MedDRA Preferred Term"
    - name: "Coding Status"
      display_name: "Coding Status"
      expr: coding_status
      comment: "Status of medical coding"
    - name: "Onset Year"
      display_name: "Onset Year"
      expr: DATE_TRUNC('year', onset_date)
      comment: "Year of condition onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Onset Quarter"
      display_name: "Onset Quarter"
      expr: DATE_TRUNC('quarter', onset_date)
      comment: "Quarter of condition onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Onset Month"
      display_name: "Onset Month"
      expr: DATE_TRUNC('month', onset_date)
      comment: "Month of condition onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Medical History Records"
      display_name: "Total Medical History Records"
      expr: COUNT(DISTINCT medical_history_id)
      comment: "Total number of medical history records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects with Medical History"
      display_name: "Subjects with Medical History"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique subjects with medical history"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Pre-existing Conditions"
      display_name: "Pre-existing Conditions"
      expr: COUNT(DISTINCT CASE WHEN pre_existing_flag = TRUE THEN medical_history_id END)
      comment: "Number of pre-existing medical conditions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Ongoing Conditions"
      display_name: "Ongoing Conditions"
      expr: COUNT(DISTINCT CASE WHEN ongoing_flag = TRUE THEN medical_history_id END)
      comment: "Number of ongoing medical conditions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Eligibility Relevant Conditions"
      display_name: "Eligibility Relevant Conditions"
      expr: COUNT(DISTINCT CASE WHEN eligibility_relevant_flag = TRUE THEN medical_history_id END)
      comment: "Number of conditions relevant to eligibility criteria"
      format:
        type: number
        decimal_places:
          type: all
    - name: "AE Related Conditions"
      display_name: "AE Related Conditions"
      expr: COUNT(DISTINCT CASE WHEN ae_related_flag = TRUE THEN medical_history_id END)
      comment: "Number of conditions related to adverse events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Conditions per Subject"
      display_name: "Avg Conditions per Subject"
      expr: COUNT(DISTINCT medical_history_id) / NULLIF(COUNT(DISTINCT trial_subject_id), 0)
      comment: "Average number of medical history conditions per subject"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Condition Duration Days"
      display_name: "Avg Condition Duration Days"
      expr: AVG(CAST(DATEDIFF(resolution_date, onset_date) AS DOUBLE))
      comment: "Average duration of medical conditions in days (for resolved conditions)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`subject_trial_subject`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core subject enrollment and population metrics for clinical trial oversight and regulatory reporting"
  source: "`clinical_trials_mvm`.`subject`.`trial_subject`"
  dimensions:
    - name: "Enrollment Status"
      display_name: "Enrollment Status"
      expr: enrollment_status
      comment: "Current enrollment status of the subject (Screened, Enrolled, Completed, Withdrawn, Screen Failed)"
    - name: "Country"
      display_name: "Country"
      expr: country
      comment: "Country where the subject is enrolled"
    - name: "Sex"
      display_name: "Sex"
      expr: sex
      comment: "Biological sex of the subject"
    - name: "Race"
      display_name: "Race"
      expr: race
      comment: "Race of the subject (GDPR Article 9 special category data)"
    - name: "Ethnicity"
      display_name: "Ethnicity"
      expr: ethnicity
      comment: "Ethnicity of the subject (GDPR Article 9 special category data)"
    - name: "ITT Population Flag"
      display_name: "ITT Population"
      expr: itt_flag
      comment: "Whether subject is included in Intent-to-Treat analysis population"
    - name: "Safety Population Flag"
      display_name: "Safety Population"
      expr: safety_population_flag
      comment: "Whether subject is included in Safety analysis population"
    - name: "PP Population Flag"
      display_name: "PP Population"
      expr: pp_flag
      comment: "Whether subject is included in Per-Protocol analysis population"
    - name: "Serious AE Flag"
      display_name: "Serious AE Flag"
      expr: serious_adverse_event_flag
      comment: "Whether subject experienced a serious adverse event"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation"
      expr: protocol_deviation_flag
      comment: "Whether subject has any protocol deviations"
    - name: "Enrollment Year"
      display_name: "Enrollment Year"
      expr: DATE_TRUNC('year', enrollment_date)
      comment: "Year of subject enrollment for temporal analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Quarter"
      display_name: "Enrollment Quarter"
      expr: DATE_TRUNC('quarter', enrollment_date)
      comment: "Quarter of subject enrollment for temporal analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Month"
      display_name: "Enrollment Month"
      expr: DATE_TRUNC('month', enrollment_date)
      comment: "Month of subject enrollment for temporal analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Screen Failure Reason"
      display_name: "Screen Failure Reason"
      expr: screen_failure_reason
      comment: "Reason for screening failure if applicable"
    - name: "Withdrawal Reason"
      display_name: "Withdrawal Reason"
      expr: withdrawal_reason
      comment: "Reason for subject withdrawal if applicable"
  measures:
    - name: "Total Subjects"
      display_name: "Total Subjects"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Total number of unique trial subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enrolled Subjects"
      display_name: "Enrolled Subjects"
      expr: COUNT(DISTINCT CASE WHEN enrollment_status = 'Enrolled' THEN trial_subject_id END)
      comment: "Number of subjects currently enrolled in the trial"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Subjects"
      display_name: "Completed Subjects"
      expr: COUNT(DISTINCT CASE WHEN enrollment_status = 'Completed' THEN trial_subject_id END)
      comment: "Number of subjects who completed the trial"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Withdrawn Subjects"
      display_name: "Withdrawn Subjects"
      expr: COUNT(DISTINCT CASE WHEN enrollment_status = 'Withdrawn' THEN trial_subject_id END)
      comment: "Number of subjects who withdrew from the trial"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screen Failed Subjects"
      display_name: "Screen Failed Subjects"
      expr: COUNT(DISTINCT CASE WHEN enrollment_status = 'Screen Failed' THEN trial_subject_id END)
      comment: "Number of subjects who failed screening"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ITT Population Count"
      display_name: "ITT Population"
      expr: COUNT(DISTINCT CASE WHEN itt_flag = TRUE THEN trial_subject_id END)
      comment: "Number of subjects in Intent-to-Treat analysis population"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Population Count"
      display_name: "Safety Population"
      expr: COUNT(DISTINCT CASE WHEN safety_population_flag = TRUE THEN trial_subject_id END)
      comment: "Number of subjects in Safety analysis population"
      format:
        type: number
        decimal_places:
          type: all
    - name: "PP Population Count"
      display_name: "PP Population"
      expr: COUNT(DISTINCT CASE WHEN pp_flag = TRUE THEN trial_subject_id END)
      comment: "Number of subjects in Per-Protocol analysis population"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subjects with SAE"
      display_name: "Subjects with SAE"
      expr: COUNT(DISTINCT CASE WHEN serious_adverse_event_flag = TRUE THEN trial_subject_id END)
      comment: "Number of subjects who experienced at least one serious adverse event"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subjects with Protocol Deviation"
      display_name: "Subjects with Deviation"
      expr: COUNT(DISTINCT CASE WHEN protocol_deviation_flag = TRUE THEN trial_subject_id END)
      comment: "Number of subjects with at least one protocol deviation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Age at Enrollment"
      display_name: "Avg Age at Enrollment"
      expr: AVG(CAST(age_at_enrollment AS DOUBLE))
      comment: "Average age of subjects at enrollment in years"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Median Age at Enrollment"
      display_name: "Median Age at Enrollment"
      expr: PERCENTILE(CAST(age_at_enrollment AS DOUBLE), 0.5)
      comment: "Median age of subjects at enrollment in years"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;
