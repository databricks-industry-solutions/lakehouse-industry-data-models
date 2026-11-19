-- Metric views for domain: workforce | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_employee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core workforce metrics tracking employee headcount, tenure, turnover, and GCP compliance rates for clinical trial staffing oversight."
  source: "`clinical_trials_ecm`.`workforce`.`employee`"
  dimensions:
    - name: "Employment Status"
      display_name: "Employment Status"
      expr: employment_status
      comment: "Current employment status (Active, Terminated, On Leave, etc.)"
    - name: "Employment Type"
      display_name: "Employment Type"
      expr: employment_type
      comment: "Type of employment (Full-Time, Part-Time, Contractor, etc.)"
    - name: "Department"
      display_name: "Department"
      expr: department_name
      comment: "Department name for organizational segmentation"
    - name: "Job Title"
      display_name: "Job Title"
      expr: job_title
      comment: "Employee job title"
    - name: "GCP Role"
      display_name: "GCP Role"
      expr: gcp_role
      comment: "Good Clinical Practice role designation"
    - name: "Region Assignment"
      display_name: "Region"
      expr: region_assignment
      comment: "Geographic region assignment"
    - name: "Therapeutic Area Expertise"
      display_name: "Therapeutic Area"
      expr: therapeutic_area_expertise
      comment: "Primary therapeutic area expertise"
    - name: "Hire Year"
      display_name: "Hire Year"
      expr: DATE_TRUNC('year', hire_date)
      comment: "Year employee was hired"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Hire Month"
      display_name: "Hire Month"
      expr: DATE_TRUNC('month', hire_date)
      comment: "Month employee was hired"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "GCP Certification Status"
      display_name: "GCP Certification Status"
      expr: CASE WHEN gcp_certified = TRUE AND gcp_certification_expiry_date >= CURRENT_DATE THEN 'Current' WHEN gcp_certified = TRUE AND gcp_certification_expiry_date < CURRENT_DATE THEN 'Expired' ELSE 'Not Certified' END
      comment: "Current GCP certification status (Current, Expired, Not Certified)"
  measures:
    - name: "Total Employees"
      display_name: "Total Employees"
      expr: COUNT(DISTINCT employee_id)
      comment: "Distinct count of employees"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Employees"
      display_name: "Active Employees"
      expr: COUNT(DISTINCT CASE WHEN employment_status = 'Active' THEN employee_id END)
      comment: "Count of employees with Active employment status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Certified Employees"
      display_name: "GCP Certified Employees"
      expr: COUNT(DISTINCT CASE WHEN gcp_certified = TRUE AND gcp_certification_expiry_date >= CURRENT_DATE THEN employee_id END)
      comment: "Count of employees with current GCP certification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Compliance Rate"
      display_name: "GCP Compliance Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN gcp_certified = TRUE AND gcp_certification_expiry_date >= CURRENT_DATE THEN employee_id END) / NULLIF(COUNT(DISTINCT CASE WHEN employment_status = 'Active' THEN employee_id END), 0), 2)
      comment: "Percentage of active employees with current GCP certification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Years of Experience"
      display_name: "Avg Years of Experience"
      expr: AVG(CAST(years_of_experience AS DOUBLE))
      comment: "Average years of experience across employees"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average FTE Percentage"
      display_name: "Avg FTE %"
      expr: AVG(CAST(fte_percentage AS DOUBLE))
      comment: "Average full-time equivalent percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
    - name: "Total Billing Rate USD"
      display_name: "Total Billing Rate (USD)"
      expr: SUM(CAST(billing_rate_usd AS DOUBLE))
      comment: "Sum of employee billing rates in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Billing Rate USD"
      display_name: "Avg Billing Rate (USD)"
      expr: AVG(CAST(billing_rate_usd AS DOUBLE))
      comment: "Average employee billing rate in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Terminated Employees"
      display_name: "Terminated Employees"
      expr: COUNT(DISTINCT CASE WHEN employment_status = 'Terminated' THEN employee_id END)
      comment: "Count of terminated employees"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_gcp_training_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GCP training compliance metrics tracking completion rates, pass rates, certification currency, and regulatory readiness for Good Clinical Practice training."
  source: "`clinical_trials_ecm`.`workforce`.`gcp_training_record`"
  dimensions:
    - name: "Training Status"
      display_name: "Training Status"
      expr: training_status
      comment: "Status of GCP training (Assigned, In Progress, Completed, Expired, Waived)"
    - name: "Training Type"
      display_name: "Training Type"
      expr: training_type
      comment: "Type of GCP training (Initial, Refresher, Recertification, etc.)"
    - name: "Training Delivery Method"
      display_name: "Delivery Method"
      expr: training_delivery_method
      comment: "Method of training delivery (Online, Classroom, Blended, etc.)"
    - name: "Pass Fail Status"
      display_name: "Pass/Fail Status"
      expr: pass_fail_status
      comment: "Assessment outcome (Pass, Fail, Not Assessed)"
    - name: "Training Provider"
      display_name: "Training Provider"
      expr: training_provider
      comment: "Organization providing the GCP training"
    - name: "Training Provider Type"
      display_name: "Provider Type"
      expr: training_provider_type
      comment: "Type of training provider (Internal, External Vendor, Academic, etc.)"
    - name: "GCP Guideline Version"
      display_name: "GCP Guideline Version"
      expr: gcp_guideline_version
      comment: "Version of GCP guidelines covered (ICH E6 R2, etc.)"
    - name: "Role at Training"
      display_name: "Role at Training"
      expr: role_at_training
      comment: "Employee role at time of training"
    - name: "Completion Year"
      display_name: "Completion Year"
      expr: DATE_TRUNC('year', completion_date)
      comment: "Year GCP training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completion Month"
      display_name: "Completion Month"
      expr: DATE_TRUNC('month', completion_date)
      comment: "Month GCP training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "GCP Currency Status"
      display_name: "GCP Currency Status"
      expr: CASE WHEN is_gcp_current = TRUE THEN 'Current' ELSE 'Not Current' END
      comment: "Whether GCP certification is current"
  measures:
    - name: "Total GCP Training Records"
      display_name: "Total GCP Training Records"
      expr: COUNT(DISTINCT gcp_training_record_id)
      comment: "Distinct count of GCP training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed GCP Training"
      display_name: "Completed GCP Training"
      expr: COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN gcp_training_record_id END)
      comment: "Count of completed GCP training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Current GCP Certifications"
      display_name: "Current GCP Certifications"
      expr: COUNT(DISTINCT CASE WHEN is_gcp_current = TRUE THEN gcp_training_record_id END)
      comment: "Count of current GCP certifications"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Completion Rate"
      display_name: "GCP Completion Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN gcp_training_record_id END) / NULLIF(COUNT(DISTINCT gcp_training_record_id), 0), 2)
      comment: "Percentage of GCP training records completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "GCP Currency Rate"
      display_name: "GCP Currency Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_gcp_current = TRUE THEN gcp_training_record_id END) / NULLIF(COUNT(DISTINCT gcp_training_record_id), 0), 2)
      comment: "Percentage of GCP training records with current certification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "GCP Pass Rate"
      display_name: "GCP Pass Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN pass_fail_status = 'Pass' THEN gcp_training_record_id END) / NULLIF(COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN gcp_training_record_id END), 0), 2)
      comment: "Percentage of completed GCP training that passed assessment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average GCP Assessment Score"
      display_name: "Avg GCP Assessment Score"
      expr: AVG(CAST(assessment_score AS DOUBLE))
      comment: "Average assessment score for GCP training"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Training Duration Hours"
      display_name: "Avg Training Duration (Hours)"
      expr: AVG(CAST(training_duration_hours AS DOUBLE))
      comment: "Average duration of GCP training in hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Unique Employees GCP Trained"
      display_name: "Unique Employees GCP Trained"
      expr: COUNT(DISTINCT employee_id)
      comment: "Distinct count of employees with GCP training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Number of Attempts"
      display_name: "Avg Number of Attempts"
      expr: AVG(CAST(number_of_attempts AS DOUBLE))
      comment: "Average number of attempts to pass GCP training"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Submission Ready"
      display_name: "Regulatory Submission Ready"
      expr: COUNT(DISTINCT CASE WHEN regulatory_submission_flag = TRUE THEN gcp_training_record_id END)
      comment: "Count of GCP training records flagged for regulatory submission"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_payroll_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payroll and labor cost metrics tracking gross pay, net pay, tax withholding, benefits, overtime, and study cost allocation for financial planning and compliance."
  source: "`clinical_trials_ecm`.`workforce`.`payroll_record`"
  dimensions:
    - name: "Pay Period Start Month"
      display_name: "Pay Period Month"
      expr: DATE_TRUNC('month', pay_period_start_date)
      comment: "Month of pay period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Pay Period Start Year"
      display_name: "Pay Period Year"
      expr: DATE_TRUNC('year', pay_period_start_date)
      comment: "Year of pay period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Employment Type"
      display_name: "Employment Type"
      expr: employment_type
      comment: "Type of employment (Full-Time, Part-Time, Contractor, etc.)"
    - name: "Department"
      display_name: "Department"
      expr: department
      comment: "Department for payroll allocation"
    - name: "Job Title"
      display_name: "Job Title"
      expr: job_title
      comment: "Job title of employee"
    - name: "Pay Frequency"
      display_name: "Pay Frequency"
      expr: pay_frequency
      comment: "Frequency of pay (Weekly, Bi-Weekly, Monthly, etc.)"
    - name: "Pay Group"
      display_name: "Pay Group"
      expr: pay_group
      comment: "Pay group classification"
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method of payment (Direct Deposit, Check, Wire, etc.)"
    - name: "Run Status"
      display_name: "Run Status"
      expr: run_status
      comment: "Status of payroll run (Draft, Approved, Posted, Reversed)"
    - name: "Payroll Run Type"
      display_name: "Payroll Run Type"
      expr: payroll_run_type
      comment: "Type of payroll run (Regular, Off-Cycle, Bonus, Correction)"
    - name: "Work Country"
      display_name: "Work Country"
      expr: work_country_code
      comment: "Country code where work is performed"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency code for payroll amounts"
  measures:
    - name: "Total Payroll Records"
      display_name: "Total Payroll Records"
      expr: COUNT(DISTINCT payroll_record_id)
      comment: "Distinct count of payroll records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Employees Paid"
      display_name: "Unique Employees Paid"
      expr: COUNT(DISTINCT employee_id)
      comment: "Distinct count of employees with payroll records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Pay"
      display_name: "Total Gross Pay"
      expr: SUM(CAST(gross_pay AS DOUBLE))
      comment: "Sum of gross pay across all payroll records"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Pay"
      display_name: "Total Net Pay"
      expr: SUM(CAST(net_pay AS DOUBLE))
      comment: "Sum of net pay across all payroll records"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Base Salary"
      display_name: "Total Base Salary"
      expr: SUM(CAST(base_salary_amount AS DOUBLE))
      comment: "Sum of base salary amounts"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Overtime Pay"
      display_name: "Total Overtime Pay"
      expr: SUM(CAST(overtime_amount AS DOUBLE))
      comment: "Sum of overtime pay"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Bonus Pay"
      display_name: "Total Bonus Pay"
      expr: SUM(CAST(bonus_amount AS DOUBLE))
      comment: "Sum of bonus amounts"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Tax Withholding"
      display_name: "Total Tax Withholding"
      expr: SUM(CAST(total_tax_deduction AS DOUBLE))
      comment: "Sum of total tax deductions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Benefits Deduction"
      display_name: "Total Benefits Deduction"
      expr: SUM(CAST(benefits_deduction AS DOUBLE))
      comment: "Sum of employee benefits deductions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employer Benefits Contribution"
      display_name: "Total Employer Benefits Contribution"
      expr: SUM(CAST(employer_benefits_contribution AS DOUBLE))
      comment: "Sum of employer benefits contributions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employer Tax Contribution"
      display_name: "Total Employer Tax Contribution"
      expr: SUM(CAST(employer_tax_contribution AS DOUBLE))
      comment: "Sum of employer tax contributions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Labor Cost"
      display_name: "Total Labor Cost"
      expr: SUM((CAST(gross_pay AS DOUBLE)) + (CAST(employer_benefits_contribution AS DOUBLE)) + (CAST(employer_tax_contribution AS DOUBLE)))
      comment: "Sum of gross pay plus employer contributions (total cost to employer)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Hours Worked"
      display_name: "Total Hours Worked"
      expr: SUM(CAST(hours_worked AS DOUBLE))
      comment: "Sum of hours worked"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Overtime Hours"
      display_name: "Total Overtime Hours"
      expr: SUM(CAST(overtime_hours AS DOUBLE))
      comment: "Sum of overtime hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Gross Pay"
      display_name: "Avg Gross Pay"
      expr: AVG(CAST(gross_pay AS DOUBLE))
      comment: "Average gross pay per payroll record"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Overtime Percentage"
      display_name: "Overtime %"
      expr: ROUND(100.0 * SUM(CAST(overtime_hours AS DOUBLE)) / NULLIF(SUM(CAST(hours_worked AS DOUBLE)), 0), 2)
      comment: "Percentage of total hours that are overtime"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_study_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study assignment metrics tracking workforce allocation, utilization, GCP compliance, and billing rates across clinical trials."
  source: "`clinical_trials_ecm`.`workforce`.`study_assignment`"
  dimensions:
    - name: "Assigned Role"
      display_name: "Assigned Role"
      expr: assigned_role
      comment: "Role assigned to employee on study (CRA, PM, Data Manager, etc.)"
    - name: "Assignment Status"
      display_name: "Assignment Status"
      expr: assignment_status
      comment: "Current status of study assignment (Active, Completed, On Hold, etc.)"
    - name: "Assignment Type"
      display_name: "Assignment Type"
      expr: assignment_type
      comment: "Type of assignment (Primary, Backup, Temporary, etc.)"
    - name: "Employment Type"
      display_name: "Employment Type"
      expr: employment_type
      comment: "Employment type for this assignment (FTE, Contractor, etc.)"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: phase
      comment: "Clinical trial phase (Phase I, Phase II, Phase III, Phase IV)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area of the study"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region for the assignment"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country code for the assignment"
    - name: "Start Year"
      display_name: "Start Year"
      expr: DATE_TRUNC('year', start_date)
      comment: "Year assignment started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Start Month"
      display_name: "Start Month"
      expr: DATE_TRUNC('month', start_date)
      comment: "Month assignment started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "GCP Compliance Status"
      display_name: "GCP Compliance Status"
      expr: CASE WHEN gcp_certified = TRUE AND (gcp_certification_expiry_date IS NULL OR gcp_certification_expiry_date >= CURRENT_DATE) THEN 'Compliant' WHEN gcp_certified = TRUE AND gcp_certification_expiry_date < CURRENT_DATE THEN 'Expired' ELSE 'Non-Compliant' END
      comment: "GCP certification compliance status for assignment"
  measures:
    - name: "Total Assignments"
      display_name: "Total Assignments"
      expr: COUNT(DISTINCT study_assignment_id)
      comment: "Distinct count of study assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Assignments"
      display_name: "Active Assignments"
      expr: COUNT(DISTINCT CASE WHEN assignment_status = 'Active' THEN study_assignment_id END)
      comment: "Count of active study assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Employees Assigned"
      display_name: "Unique Employees"
      expr: COUNT(DISTINCT primary_study_employee_id)
      comment: "Distinct count of employees with study assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Studies"
      display_name: "Unique Studies"
      expr: COUNT(DISTINCT study_id)
      comment: "Distinct count of studies with workforce assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average FTE Allocation"
      display_name: "Avg FTE Allocation %"
      expr: AVG(CAST(fte_allocation_pct AS DOUBLE))
      comment: "Average FTE allocation percentage across assignments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
    - name: "Total Planned FTE"
      display_name: "Total Planned FTE"
      expr: SUM(CAST(planned_fte_allocation_pct AS DOUBLE)) / 100.0
      comment: "Sum of planned FTE allocation (converted from percentage)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual FTE"
      display_name: "Total Actual FTE"
      expr: SUM(CAST(fte_allocation_pct AS DOUBLE)) / 100.0
      comment: "Sum of actual FTE allocation (converted from percentage)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "GCP Compliant Assignments"
      display_name: "GCP Compliant Assignments"
      expr: COUNT(DISTINCT CASE WHEN gcp_certified = TRUE AND (gcp_certification_expiry_date IS NULL OR gcp_certification_expiry_date >= CURRENT_DATE) THEN study_assignment_id END)
      comment: "Count of assignments with current GCP certification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Compliance Rate"
      display_name: "GCP Compliance Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN gcp_certified = TRUE AND (gcp_certification_expiry_date IS NULL OR gcp_certification_expiry_date >= CURRENT_DATE) THEN study_assignment_id END) / NULLIF(COUNT(DISTINCT study_assignment_id), 0), 2)
      comment: "Percentage of assignments with current GCP certification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Billing Rate"
      display_name: "Avg Billing Rate"
      expr: AVG(CAST(billing_rate AS DOUBLE))
      comment: "Average billing rate across assignments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Billing Value"
      display_name: "Total Billing Value"
      expr: SUM(CAST(billing_rate AS DOUBLE) * CAST(fte_allocation_pct AS DOUBLE) / 100.0)
      comment: "Sum of billing rate weighted by FTE allocation"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_training_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Training compliance metrics tracking completion rates, overdue training, pass/fail rates, and training effectiveness across the workforce."
  source: "`clinical_trials_ecm`.`workforce`.`training_record`"
  dimensions:
    - name: "Training Category"
      display_name: "Training Category"
      expr: training_category
      comment: "Category of training (GCP, Protocol, SOP, System, etc.)"
    - name: "Training Method"
      display_name: "Training Method"
      expr: training_method
      comment: "Method of training delivery (Online, Classroom, On-the-Job, etc.)"
    - name: "Assignment Status"
      display_name: "Assignment Status"
      expr: assignment_status
      comment: "Status of training assignment (Assigned, In Progress, Completed, Overdue, Waived)"
    - name: "Pass Fail Status"
      display_name: "Pass/Fail Status"
      expr: pass_fail_status
      comment: "Assessment outcome (Pass, Fail, Not Assessed)"
    - name: "Department"
      display_name: "Department"
      expr: department
      comment: "Department of trainee"
    - name: "Job Role"
      display_name: "Job Role"
      expr: job_role
      comment: "Job role of trainee"
    - name: "Assignment Year"
      display_name: "Assignment Year"
      expr: DATE_TRUNC('year', assignment_date)
      comment: "Year training was assigned"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assignment Month"
      display_name: "Assignment Month"
      expr: DATE_TRUNC('month', assignment_date)
      comment: "Month training was assigned"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completion Year"
      display_name: "Completion Year"
      expr: DATE_TRUNC('year', completion_date)
      comment: "Year training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completion Month"
      display_name: "Completion Month"
      expr: DATE_TRUNC('month', completion_date)
      comment: "Month training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Overdue Status"
      display_name: "Overdue Status"
      expr: CASE WHEN due_date < CURRENT_DATE AND completion_date IS NULL THEN 'Overdue' WHEN completion_date IS NOT NULL THEN 'Completed' ELSE 'On Time' END
      comment: "Whether training is overdue, completed, or on time"
  measures:
    - name: "Total Training Records"
      display_name: "Total Training Records"
      expr: COUNT(DISTINCT training_record_id)
      comment: "Distinct count of training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Training Records"
      display_name: "Completed Training"
      expr: COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN training_record_id END)
      comment: "Count of completed training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Overdue Training Records"
      display_name: "Overdue Training"
      expr: COUNT(DISTINCT CASE WHEN due_date < CURRENT_DATE AND completion_date IS NULL THEN training_record_id END)
      comment: "Count of overdue training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Training Completion Rate"
      display_name: "Completion Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN training_record_id END) / NULLIF(COUNT(DISTINCT training_record_id), 0), 2)
      comment: "Percentage of training records completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "On Time Completion Rate"
      display_name: "On-Time Completion Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL AND completion_date <= due_date THEN training_record_id END) / NULLIF(COUNT(DISTINCT CASE WHEN completion_date IS NOT NULL THEN training_record_id END), 0), 2)
      comment: "Percentage of completed training finished by due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Pass Rate"
      display_name: "Pass Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN pass_fail_status = 'Pass' THEN training_record_id END) / NULLIF(COUNT(DISTINCT CASE WHEN assessment_required = TRUE AND completion_date IS NOT NULL THEN training_record_id END), 0), 2)
      comment: "Percentage of assessed training records that passed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Assessment Score"
      display_name: "Avg Assessment Score"
      expr: AVG(CAST(assessment_score AS DOUBLE))
      comment: "Average assessment score across completed training"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Days Overdue"
      display_name: "Avg Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average number of days training is overdue"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Unique Employees Trained"
      display_name: "Unique Employees Trained"
      expr: COUNT(DISTINCT primary_training_employee_id)
      comment: "Distinct count of employees with training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waived Training Records"
      display_name: "Waived Training"
      expr: COUNT(DISTINCT CASE WHEN waiver_date IS NOT NULL THEN training_record_id END)
      comment: "Count of training records with waivers"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`workforce_resource_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Workforce planning metrics tracking FTE demand vs supply, labor cost variance, capacity utilization, and hiring gaps across studies and programs."
  source: "`clinical_trials_ecm`.`workforce`.`workforce_resource_plan`"
  dimensions:
    - name: "Plan Status"
      display_name: "Plan Status"
      expr: plan_status
      comment: "Status of resource plan (Draft, Approved, Active, Closed)"
    - name: "Plan Type"
      display_name: "Plan Type"
      expr: plan_type
      comment: "Type of resource plan (Study, Program, Portfolio, etc.)"
    - name: "Fiscal Year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year for the resource plan"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fiscal Quarter"
      display_name: "Fiscal Quarter"
      expr: fiscal_quarter
      comment: "Fiscal quarter for the resource plan"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: study_phase
      comment: "Clinical trial phase (Phase I, Phase II, Phase III, Phase IV)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area focus"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region for resource planning"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country code for resource planning"
    - name: "Planning Horizon"
      display_name: "Planning Horizon"
      expr: planning_horizon
      comment: "Time horizon for planning (Short-term, Mid-term, Long-term)"
    - name: "Hiring Urgency"
      display_name: "Hiring Urgency"
      expr: hiring_urgency
      comment: "Urgency level for hiring (Critical, High, Medium, Low)"
  measures:
    - name: "Total Resource Plans"
      display_name: "Total Resource Plans"
      expr: COUNT(DISTINCT workforce_resource_plan_id)
      comment: "Distinct count of workforce resource plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned FTE Demand"
      display_name: "Total Planned FTE Demand"
      expr: SUM(CAST(planned_fte_demand AS DOUBLE))
      comment: "Sum of planned FTE demand across resource plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual FTE"
      display_name: "Total Actual FTE"
      expr: SUM(CAST(actual_fte AS DOUBLE))
      comment: "Sum of actual FTE allocated"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total FTE Gap"
      display_name: "Total FTE Gap"
      expr: SUM(CAST(fte_gap AS DOUBLE))
      comment: "Sum of FTE gap (demand minus supply)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "FTE Fill Rate"
      display_name: "FTE Fill Rate"
      expr: ROUND(100.0 * SUM(CAST(actual_fte AS DOUBLE)) / NULLIF(SUM(CAST(planned_fte_demand AS DOUBLE)), 0), 2)
      comment: "Percentage of planned FTE demand filled by actual FTE"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Planned Headcount"
      display_name: "Total Planned Headcount"
      expr: SUM(CAST(planned_headcount AS DOUBLE))
      comment: "Sum of planned headcount"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actual Headcount"
      display_name: "Total Actual Headcount"
      expr: SUM(CAST(actual_headcount AS DOUBLE))
      comment: "Sum of actual headcount"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Open Positions"
      display_name: "Total Open Positions"
      expr: SUM(CAST(open_position_count AS DOUBLE))
      comment: "Sum of open position count"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Labor Cost"
      display_name: "Total Planned Labor Cost"
      expr: SUM(CAST(planned_labor_cost AS DOUBLE))
      comment: "Sum of planned labor cost"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Labor Cost"
      display_name: "Total Actual Labor Cost"
      expr: SUM(CAST(actual_labor_cost AS DOUBLE))
      comment: "Sum of actual labor cost"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Labor Cost Variance"
      display_name: "Labor Cost Variance"
      expr: SUM((CAST(actual_labor_cost AS DOUBLE)) - (CAST(planned_labor_cost AS DOUBLE)))
      comment: "Difference between actual and planned labor cost"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Labor Cost Variance Percent"
      display_name: "Labor Cost Variance %"
      expr: ROUND(100.0 * (SUM(CAST(actual_labor_cost AS DOUBLE)) - SUM(CAST(planned_labor_cost AS DOUBLE))) / NULLIF(SUM(CAST(planned_labor_cost AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and planned labor cost"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Capacity Utilization Target"
      display_name: "Avg Capacity Utilization Target %"
      expr: AVG(CAST(capacity_utilization_target_pct AS DOUBLE))
      comment: "Average capacity utilization target percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
    - name: "Total Internal FTE Planned"
      display_name: "Total Internal FTE Planned"
      expr: SUM(CAST(internal_fte_planned AS DOUBLE))
      comment: "Sum of planned internal FTE"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Contractor FTE Planned"
      display_name: "Total Contractor FTE Planned"
      expr: SUM(CAST(contractor_fte_planned AS DOUBLE))
      comment: "Sum of planned contractor FTE"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;
