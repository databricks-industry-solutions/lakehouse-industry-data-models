-- Metric views for domain: subject | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_disposition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject disposition and study completion metrics for regulatory reporting and trial outcome analysis"
  source: "`clinical_trials_ecm`.`subject`.`disposition`"
  dimensions:
    - name: "Disposition Status"
      display_name: "Disposition Status"
      expr: disposition_status
      comment: "Current disposition status of the subject"
    - name: "Event"
      display_name: "Event"
      expr: event
      comment: "Disposition event type"
    - name: "Milestone Category"
      display_name: "Milestone Category"
      expr: milestone_category
      comment: "Category of disposition milestone"
    - name: "Milestone Subcategory"
      display_name: "Milestone Subcategory"
      expr: milestone_subcategory
      comment: "Subcategory of disposition milestone"
    - name: "Early Termination Flag"
      display_name: "Early Termination"
      expr: early_termination_flag
      comment: "Whether subject terminated early"
    - name: "Study Completion Flag"
      display_name: "Study Completed"
      expr: study_completion_flag
      comment: "Whether subject completed the study"
    - name: "AE Related Discontinuation"
      display_name: "AE Related Discontinuation"
      expr: ae_related_discontinuation
      comment: "Whether discontinuation was related to adverse event"
    - name: "Safety Followup Required"
      display_name: "Safety Followup Required"
      expr: safety_followup_required
      comment: "Whether safety follow-up is required"
    - name: "Screen Failure Reason"
      display_name: "Screen Failure Reason"
      expr: screen_failure_reason
      comment: "Reason for screening failure"
    - name: "ITT Population"
      display_name: "ITT Population"
      expr: analysis_population_itt
      comment: "Intent-to-Treat population flag"
    - name: "Safety Population"
      display_name: "Safety Population"
      expr: analysis_population_safety
      comment: "Safety analysis population flag"
    - name: "PP Population"
      display_name: "PP Population"
      expr: analysis_population_pp
      comment: "Per-Protocol population flag"
    - name: "Disposition Year"
      display_name: "Disposition Year"
      expr: DATE_TRUNC('year', disposition_date)
      comment: "Year of disposition event"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Disposition Quarter"
      display_name: "Disposition Quarter"
      expr: DATE_TRUNC('quarter', disposition_date)
      comment: "Quarter of disposition event"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Disposition Month"
      display_name: "Disposition Month"
      expr: DATE_TRUNC('month', disposition_date)
      comment: "Month of disposition event"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Disposition Events"
      display_name: "Total Disposition Events"
      expr: COUNT(DISTINCT disposition_id)
      comment: "Total number of disposition events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Subjects"
      display_name: "Completed Subjects"
      expr: COUNT(DISTINCT CASE WHEN study_completion_flag = TRUE THEN disposition_id END)
      comment: "Number of subjects who completed the study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Early Terminations"
      display_name: "Early Terminations"
      expr: COUNT(DISTINCT CASE WHEN early_termination_flag = TRUE THEN disposition_id END)
      comment: "Number of subjects who terminated early"
      format:
        type: number
        decimal_places:
          type: all
    - name: "AE Related Discontinuations"
      display_name: "AE Discontinuations"
      expr: COUNT(DISTINCT CASE WHEN ae_related_discontinuation = TRUE THEN disposition_id END)
      comment: "Number of discontinuations related to adverse events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screen Failures"
      display_name: "Screen Failures"
      expr: COUNT(DISTINCT CASE WHEN screen_failure_reason IS NOT NULL THEN disposition_id END)
      comment: "Number of screening failures"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deaths"
      display_name: "Deaths"
      expr: COUNT(DISTINCT CASE WHEN death_date IS NOT NULL THEN disposition_id END)
      comment: "Number of subject deaths"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Followup Required Count"
      display_name: "Safety Followup Required"
      expr: COUNT(DISTINCT CASE WHEN safety_followup_required = TRUE THEN disposition_id END)
      comment: "Number of subjects requiring safety follow-up"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_enrollment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject enrollment funnel and conversion metrics for site performance and recruitment tracking"
  source: "`clinical_trials_ecm`.`subject`.`enrollment`"
  dimensions:
    - name: "Enrollment Status"
      display_name: "Enrollment Status"
      expr: enrollment_status
      comment: "Current enrollment status"
    - name: "Enrollment Type"
      display_name: "Enrollment Type"
      expr: enrollment_type
      comment: "Type of enrollment (e.g., initial, re-enrollment)"
    - name: "ITT Flag"
      display_name: "ITT Population"
      expr: itt_flag
      comment: "Intent-to-Treat population flag"
    - name: "Safety Population Flag"
      display_name: "Safety Population"
      expr: safety_population_flag
      comment: "Safety analysis population flag"
    - name: "PP Flag"
      display_name: "PP Population"
      expr: pp_flag
      comment: "Per-Protocol population flag"
    - name: "Eligibility Confirmed"
      display_name: "Eligibility Confirmed"
      expr: eligibility_confirmed
      comment: "Whether subject eligibility was confirmed"
    - name: "Randomization Eligible"
      display_name: "Randomization Eligible"
      expr: randomization_eligible
      comment: "Whether subject is eligible for randomization"
    - name: "Screen Failure Reason"
      display_name: "Screen Failure Reason"
      expr: screen_failure_reason
      comment: "Reason for screening failure"
    - name: "Withdrawal Reason"
      display_name: "Withdrawal Reason"
      expr: withdrawal_reason
      comment: "Reason for withdrawal from study"
    - name: "Blinding Status"
      display_name: "Blinding Status"
      expr: blinding_status
      comment: "Blinding status of the subject"
    - name: "Cohort Code"
      display_name: "Cohort"
      expr: cohort_code
      comment: "Cohort assignment code"
    - name: "Enrollment Year"
      display_name: "Enrollment Year"
      expr: DATE_TRUNC('year', enrollment_date)
      comment: "Year of enrollment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Quarter"
      display_name: "Enrollment Quarter"
      expr: DATE_TRUNC('quarter', enrollment_date)
      comment: "Quarter of enrollment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Enrollment Month"
      display_name: "Enrollment Month"
      expr: DATE_TRUNC('month', enrollment_date)
      comment: "Month of enrollment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Enrollments"
      display_name: "Total Enrollments"
      expr: COUNT(DISTINCT enrollment_id)
      comment: "Total number of enrollment records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screened Subjects"
      display_name: "Screened Subjects"
      expr: COUNT(DISTINCT CASE WHEN screening_date IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who completed screening"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enrolled Subjects"
      display_name: "Enrolled Subjects"
      expr: COUNT(DISTINCT CASE WHEN enrollment_date IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who enrolled"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Randomized Subjects"
      display_name: "Randomized Subjects"
      expr: COUNT(DISTINCT CASE WHEN randomization_date IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who were randomized"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Subjects"
      display_name: "Completed Subjects"
      expr: COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who completed the study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Withdrawn Subjects"
      display_name: "Withdrawn Subjects"
      expr: COUNT(DISTINCT CASE WHEN withdrawal_date IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who withdrew"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Screen Failed Subjects"
      display_name: "Screen Failed Subjects"
      expr: COUNT(DISTINCT CASE WHEN screen_failure_reason IS NOT NULL THEN enrollment_id END)
      comment: "Number of subjects who failed screening"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Visit Compliance Pct"
      display_name: "Avg Visit Compliance %"
      expr: AVG(CAST(visit_compliance_pct AS DOUBLE))
      comment: "Average visit compliance percentage across enrolled subjects"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Screening to Enrollment Days"
      display_name: "Avg Screen-to-Enroll Days"
      expr: AVG(CAST(DATEDIFF(enrollment_date, screening_date) AS DOUBLE))
      comment: "Average number of days from screening to enrollment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Enrollment to Randomization Days"
      display_name: "Avg Enroll-to-Rand Days"
      expr: AVG(CAST(DATEDIFF(randomization_date, enrollment_date) AS DOUBLE))
      comment: "Average number of days from enrollment to randomization"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Study Duration Days"
      display_name: "Avg Study Duration Days"
      expr: AVG(CAST(DATEDIFF(completion_date, enrollment_date) AS DOUBLE))
      comment: "Average number of days from enrollment to completion"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_medical_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject medical history and baseline condition metrics for eligibility assessment and safety analysis"
  source: "`clinical_trials_ecm`.`subject`.`medical_history`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Protocol deviation tracking and impact assessment metrics for quality and compliance oversight"
  source: "`clinical_trials_ecm`.`subject`.`subject_deviation`"
  dimensions:
    - name: "Deviation Status"
      display_name: "Deviation Status"
      expr: deviation_status
      comment: "Current status of the protocol deviation"
    - name: "Deviation Category"
      display_name: "Deviation Category"
      expr: deviation_category
      comment: "Category of protocol deviation"
    - name: "Type Code"
      display_name: "Type Code"
      expr: type_code
      comment: "Type code of the deviation"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root cause category of the deviation"
    - name: "Subject Safety Impact"
      display_name: "Safety Impact"
      expr: subject_safety_impact
      comment: "Impact of deviation on subject safety"
    - name: "Subject Rights Impact"
      display_name: "Rights Impact"
      expr: subject_rights_impact
      comment: "Impact of deviation on subject rights"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Impact of deviation on data integrity"
    - name: "IRB IEC Reportable Flag"
      display_name: "IRB Reportable"
      expr: irb_iec_reportable_flag
      comment: "Whether deviation is reportable to IRB/IEC"
    - name: "Regulatory Reportable Flag"
      display_name: "Regulatory Reportable"
      expr: regulatory_reportable_flag
      comment: "Whether deviation is reportable to regulatory authority"
    - name: "Sponsor Notified Flag"
      display_name: "Sponsor Notified"
      expr: sponsor_notified_flag
      comment: "Whether sponsor was notified of deviation"
    - name: "PI Aware Flag"
      display_name: "PI Aware"
      expr: pi_aware_flag
      comment: "Whether principal investigator is aware of deviation"
    - name: "Subject Continuation Decision"
      display_name: "Continuation Decision"
      expr: subject_continuation_decision
      comment: "Decision on subject continuation after deviation"
    - name: "Occurrence Year"
      display_name: "Occurrence Year"
      expr: DATE_TRUNC('year', occurrence_date)
      comment: "Year of deviation occurrence"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Occurrence Quarter"
      display_name: "Occurrence Quarter"
      expr: DATE_TRUNC('quarter', occurrence_date)
      comment: "Quarter of deviation occurrence"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Occurrence Month"
      display_name: "Occurrence Month"
      expr: DATE_TRUNC('month', occurrence_date)
      comment: "Month of deviation occurrence"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Deviations"
      display_name: "Total Deviations"
      expr: COUNT(DISTINCT subject_deviation_id)
      comment: "Total number of protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Deviations"
      display_name: "Open Deviations"
      expr: COUNT(DISTINCT CASE WHEN deviation_status = 'Open' THEN subject_deviation_id END)
      comment: "Number of open protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Closed Deviations"
      display_name: "Closed Deviations"
      expr: COUNT(DISTINCT CASE WHEN deviation_status = 'Closed' THEN subject_deviation_id END)
      comment: "Number of closed protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Reportable Deviations"
      display_name: "IRB Reportable Deviations"
      expr: COUNT(DISTINCT CASE WHEN irb_iec_reportable_flag = TRUE THEN subject_deviation_id END)
      comment: "Number of deviations reportable to IRB/IEC"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Reportable Deviations"
      display_name: "Regulatory Reportable Deviations"
      expr: COUNT(DISTINCT CASE WHEN regulatory_reportable_flag = TRUE THEN subject_deviation_id END)
      comment: "Number of deviations reportable to regulatory authority"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deviations with Safety Impact"
      display_name: "Deviations with Safety Impact"
      expr: COUNT(DISTINCT CASE WHEN subject_safety_impact IS NOT NULL AND subject_safety_impact != 'None' THEN subject_deviation_id END)
      comment: "Number of deviations with impact on subject safety"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deviations with Data Integrity Impact"
      display_name: "Deviations with Data Impact"
      expr: COUNT(DISTINCT CASE WHEN data_integrity_impact IS NOT NULL AND data_integrity_impact != 'None' THEN subject_deviation_id END)
      comment: "Number of deviations with impact on data integrity"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days to Resolution"
      display_name: "Avg Days to Resolution"
      expr: AVG(CAST(DATEDIFF(resolution_date, occurrence_date) AS DOUBLE))
      comment: "Average number of days from deviation occurrence to resolution"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to Sponsor Notification"
      display_name: "Avg Days to Sponsor Notification"
      expr: AVG(CAST(DATEDIFF(sponsor_notified_date, occurrence_date) AS DOUBLE))
      comment: "Average number of days from deviation occurrence to sponsor notification"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to PI Awareness"
      display_name: "Avg Days to PI Awareness"
      expr: AVG(CAST(DATEDIFF(pi_aware_date, occurrence_date) AS DOUBLE))
      comment: "Average number of days from deviation occurrence to PI awareness"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_visit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject visit compliance and protocol adherence metrics for operational monitoring and quality oversight"
  source: "`clinical_trials_ecm`.`subject`.`subject_visit`"
  dimensions:
    - name: "Visit Status"
      display_name: "Visit Status"
      expr: visit_status
      comment: "Status of the visit (Scheduled, Completed, Missed, Cancelled)"
    - name: "Visit Type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of visit (Screening, Baseline, Treatment, Follow-up, Unscheduled)"
    - name: "Visit Code"
      display_name: "Visit Code"
      expr: visit_code
      comment: "Protocol-defined visit code"
    - name: "Window Compliance Status"
      display_name: "Window Compliance"
      expr: window_compliance_status
      comment: "Whether visit occurred within protocol-defined window"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation"
      expr: protocol_deviation_flag
      comment: "Whether visit had a protocol deviation"
    - name: "Data Entry Status"
      display_name: "Data Entry Status"
      expr: data_entry_status
      comment: "Status of data entry for the visit"
    - name: "Is Scheduled"
      display_name: "Scheduled Visit"
      expr: is_scheduled
      comment: "Whether visit was scheduled or unscheduled"
    - name: "Missed Reason"
      display_name: "Missed Reason"
      expr: missed_reason
      comment: "Reason for missed visit if applicable"
    - name: "Early Termination Reason"
      display_name: "Early Termination Reason"
      expr: early_termination_reason
      comment: "Reason for early termination if applicable"
    - name: "Visit Year"
      display_name: "Visit Year"
      expr: DATE_TRUNC('year', actual_visit_date)
      comment: "Year of actual visit"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Visit Quarter"
      display_name: "Visit Quarter"
      expr: DATE_TRUNC('quarter', actual_visit_date)
      comment: "Quarter of actual visit"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Visit Month"
      display_name: "Visit Month"
      expr: DATE_TRUNC('month', actual_visit_date)
      comment: "Month of actual visit"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Visits"
      display_name: "Total Visits"
      expr: COUNT(DISTINCT subject_visit_id)
      comment: "Total number of subject visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Visits"
      display_name: "Completed Visits"
      expr: COUNT(DISTINCT CASE WHEN visit_status = 'Completed' THEN subject_visit_id END)
      comment: "Number of completed visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Missed Visits"
      display_name: "Missed Visits"
      expr: COUNT(DISTINCT CASE WHEN visit_status = 'Missed' THEN subject_visit_id END)
      comment: "Number of missed visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Cancelled Visits"
      display_name: "Cancelled Visits"
      expr: COUNT(DISTINCT CASE WHEN visit_status = 'Cancelled' THEN subject_visit_id END)
      comment: "Number of cancelled visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Within Window Visits"
      display_name: "Within Window Visits"
      expr: COUNT(DISTINCT CASE WHEN window_compliance_status = 'Within Window' THEN subject_visit_id END)
      comment: "Number of visits completed within protocol window"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Out of Window Visits"
      display_name: "Out of Window Visits"
      expr: COUNT(DISTINCT CASE WHEN window_compliance_status = 'Out of Window' THEN subject_visit_id END)
      comment: "Number of visits completed outside protocol window"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Visits with Protocol Deviation"
      display_name: "Visits with Deviation"
      expr: COUNT(DISTINCT CASE WHEN protocol_deviation_flag = TRUE THEN subject_visit_id END)
      comment: "Number of visits with protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Visit Duration Minutes"
      display_name: "Avg Visit Duration (min)"
      expr: AVG(CAST(duration_minutes AS DOUBLE))
      comment: "Average visit duration in minutes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days from Planned"
      display_name: "Avg Days from Planned"
      expr: AVG(CAST(days_from_planned AS DOUBLE))
      comment: "Average number of days actual visit deviated from planned date (positive = late, negative = early)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Query Count per Visit"
      display_name: "Avg Queries per Visit"
      expr: AVG(CAST(query_count AS DOUBLE))
      comment: "Average number of data queries per visit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Query Count"
      display_name: "Total Queries"
      expr: SUM(CAST(query_count AS DOUBLE))
      comment: "Total number of data queries across all visits"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`subject_trial_subject`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core subject enrollment and population metrics for clinical trial oversight and regulatory reporting"
  source: "`clinical_trials_ecm`.`subject`.`trial_subject`"
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
