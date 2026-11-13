-- Metric views for domain: compliance | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_audit_finding_remediation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Internal audit findings and remediation status for SOX control attestation."
  source: "`asset_management`.`compliance`.`audit_finding`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Findings"
      display_name: "Findings"
      expr: COUNT(1)
      comment: "Findings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_beneficiary_disclosure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Beneficiary annual statement / disclosure issuance volume and status."
  source: "`asset_management`.`compliance`.`beneficiary_disclosure`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Disclosures"
      display_name: "Disclosures"
      expr: COUNT(1)
      comment: "Disclosures"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_breach_remediation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Breach remediation performance KPIs tracking remediation cost, effectiveness, penalty risk, and timeliness to ensure the fund closes regulatory gaps efficiently."
  source: "`asset_management`.`compliance`.`breach_remediation`"
  dimensions:
    - name: "remediation_status"
      display_name: "Remediation Status"
      expr: remediation_status
      comment: "Current status of the remediation effort for pipeline and SLA monitoring."
    - name: "breach_severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity of the underlying breach driving the remediation."
    - name: "risk_level"
      display_name: "Risk Level"
      expr: risk_level
      comment: "Assessed risk level of the remediation case for prioritization."
    - name: "remediation_action_type"
      display_name: "Remediation Action Type"
      expr: remediation_action_type
      comment: "Type of remediation action taken for categorizing response strategies."
    - name: "jurisdiction"
      display_name: "Jurisdiction"
      expr: jurisdiction
      comment: "Regulatory jurisdiction of the remediation case."
    - name: "detection_month"
      display_name: "Detection Month"
      expr: DATE_TRUNC('month', breach_detection_timestamp)
      comment: "Month bucket of breach detection for remediation trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "remediation_case_count"
      display_name: "Remediation Case Count"
      expr: COUNT(1)
      comment: "Total remediation cases — volume baseline for compliance remediation workload management."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_remediation_cost"
      display_name: "Total Remediation Cost"
      expr: SUM(CAST(remediation_cost_amount AS DOUBLE))
      comment: "Total cost of remediation actions — direct operational expense leadership tracks for budget control."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_remediation_effectiveness"
      display_name: "Avg Remediation Effectiveness"
      expr: AVG(CAST(remediation_effectiveness_score AS DOUBLE))
      comment: "Average remediation effectiveness score — quality measure of whether fixes actually resolve breaches."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "avg_penalty_risk_estimate"
      display_name: "Avg Penalty Risk Estimate"
      expr: AVG(CAST(penalty_risk_estimate AS DOUBLE))
      comment: "Average estimated penalty risk across remediation cases — forward-looking regulatory financial risk indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "overdue_remediation_count"
      display_name: "Overdue Remediation Count"
      expr: COUNT(CASE WHEN actual_completion_date IS NULL AND target_remediation_date < CURRENT_DATE THEN 1 END)
      comment: "Count of remediations past target date and not completed — SLA breach indicator triggering escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_remediation_rate"
      display_name: "Overdue Remediation Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN actual_completion_date IS NULL AND target_remediation_date < CURRENT_DATE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of remediations overdue — operational timeliness KPI for compliance steering dashboards."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "waiver_request_rate"
      display_name: "Waiver Request Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_waiver_requested = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of cases where a waiver was requested — governance signal of policy exception pressure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_breach_remediation_sla`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Remediation progress and timeliness on compliance rule breaches."
  source: "`asset_management`.`compliance`.`breach_remediation`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: remediation_status
      comment: "Status"
  measures:
    - name: "Remediations"
      display_name: "Remediations"
      expr: COUNT(1)
      comment: "Remediations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed %"
      display_name: "Completed %"
      expr: ROUND(100.0 * SUM(CASE WHEN remediation_status = 'COMPLETED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Completed share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_certification`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Employee compliance certification and training KPIs tracking completion, pass rates, and active certification coverage to ensure regulatory competency across staff."
  source: "`asset_management`.`compliance`.`certification`"
  dimensions:
    - name: "certification_status"
      display_name: "Certification Status"
      expr: certification_status
      comment: "Status of the certification (active, expired, pending)."
    - name: "certification_type"
      display_name: "Certification Type"
      expr: certification_type
      comment: "Type of compliance certification for categorization."
    - name: "compliance_area"
      display_name: "Compliance Area"
      expr: compliance_area
      comment: "Compliance domain the certification covers."
    - name: "staff_department"
      display_name: "Staff Department"
      expr: staff_department
      comment: "Department of the certified staff member for coverage analysis."
    - name: "completion_month"
      display_name: "Completion Month"
      expr: DATE_TRUNC('month', completion_date)
      comment: "Month bucket of certification completion for trend tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "certification_count"
      display_name: "Certification Count"
      expr: COUNT(1)
      comment: "Total certification records — baseline training/competency population."
      format:
        type: number
        decimal_places:
          type: all
    - name: "active_certification_rate"
      display_name: "Active Certification Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_active = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of certifications currently active — regulatory competency coverage KPI for compliance leadership."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "training_pass_rate"
      display_name: "Training Pass Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN training_passed = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of training modules passed — staff competency quality indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_training_score"
      display_name: "Avg Training Score"
      expr: AVG(CAST(training_score AS DOUBLE))
      comment: "Average training score across staff — competency depth measure for training program steering."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_certified_employees"
      display_name: "Distinct Certified Employees"
      expr: COUNT(DISTINCT employee_id)
      comment: "Distinct employees holding certifications — workforce compliance coverage measure."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_certification_compliance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Employee regulatory certification completion status for licensing oversight."
  source: "`asset_management`.`compliance`.`certification`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: certification_status
      comment: "Status"
  measures:
    - name: "Certifications"
      display_name: "Certifications"
      expr: COUNT(1)
      comment: "Certifications"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Valid %"
      display_name: "Valid %"
      expr: ROUND(100.0 * SUM(CASE WHEN certification_status = 'VALID' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Valid share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_conflict_of_interest`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Conflict of interest KPIs tracking declaration volume, risk scores, resolution status, and mandatory disclosure compliance to protect pension beneficiary interests."
  source: "`asset_management`.`compliance`.`conflict_of_interest`"
  dimensions:
    - name: "conflict_status"
      display_name: "Conflict Status"
      expr: conflict_of_interest_status
      comment: "Current status of the conflict of interest declaration."
    - name: "conflict_category"
      display_name: "Conflict Category"
      expr: conflict_category
      comment: "Category of the declared conflict for thematic analysis."
    - name: "conflict_type"
      display_name: "Conflict Type"
      expr: conflict_type
      comment: "Type of conflict of interest for segmentation."
    - name: "severity_level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity level of the conflict for prioritization."
    - name: "disclosure_month"
      display_name: "Disclosure Month"
      expr: DATE_TRUNC('month', disclosure_date)
      comment: "Month bucket of conflict disclosure for trend monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "conflict_count"
      display_name: "Conflict Count"
      expr: COUNT(1)
      comment: "Total conflict of interest declarations — baseline governance disclosure volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "unresolved_conflict_count"
      display_name: "Unresolved Conflict Count"
      expr: COUNT(CASE WHEN resolution_date IS NULL THEN 1 END)
      comment: "Count of unresolved conflicts — open governance risk requiring mitigation action."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_conflict_risk_score"
      display_name: "Avg Conflict Risk Score"
      expr: AVG(CAST(conflict_risk_score AS DOUBLE))
      comment: "Average conflict risk score — composite governance risk intensity across declarations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "resolution_rate"
      display_name: "Resolution Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN resolution_date IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of conflicts resolved — governance effectiveness KPI for board oversight."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "mandatory_disclosure_rate"
      display_name: "Mandatory Disclosure Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_mandatory = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of conflicts that are mandatory disclosures — compliance obligation coverage indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_exam_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory exam finding KPIs tracking finding severity, penalty exposure, resolution timeliness, and waiver pressure to manage regulator relationships and exam outcomes."
  source: "`asset_management`.`compliance`.`exam_finding`"
  dimensions:
    - name: "finding_status"
      display_name: "Finding Status"
      expr: exam_finding_status
      comment: "Current status of the exam finding (open, resolved, escalated)."
    - name: "severity"
      display_name: "Severity"
      expr: severity
      comment: "Severity classification of the exam finding for triage."
    - name: "finding_category"
      display_name: "Finding Category"
      expr: exam_finding_category
      comment: "Category of the exam finding for thematic analysis."
    - name: "jurisdiction"
      display_name: "Jurisdiction"
      expr: jurisdiction
      comment: "Regulatory jurisdiction of the exam finding."
    - name: "reported_month"
      display_name: "Reported Month"
      expr: DATE_TRUNC('month', reported_timestamp)
      comment: "Month bucket of when the finding was reported for trend tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "finding_count"
      display_name: "Finding Count"
      expr: COUNT(1)
      comment: "Total exam findings — baseline indicator of regulatory exam exposure."
      format:
        type: number
        decimal_places:
          type: all
    - name: "open_finding_count"
      display_name: "Open Finding Count"
      expr: COUNT(CASE WHEN resolved_timestamp IS NULL THEN 1 END)
      comment: "Count of unresolved exam findings — open regulatory risk requiring remediation focus."
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_finding_count"
      display_name: "Overdue Finding Count"
      expr: COUNT(CASE WHEN resolved_timestamp IS NULL AND due_date < CURRENT_DATE THEN 1 END)
      comment: "Count of findings past due date and unresolved — SLA breach triggering executive escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_penalty_amount"
      display_name: "Total Penalty Amount"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total penalty amount from exam findings — direct financial consequence of regulatory exams."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_finding_risk_score"
      display_name: "Avg Finding Risk Score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score of exam findings — severity intensity gauge for remediation prioritization."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "resolution_rate"
      display_name: "Resolution Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN resolved_timestamp IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of exam findings resolved — remediation effectiveness KPI for regulator relationship management."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_exam_finding_volume`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Findings raised during regulatory examinations and resolution status."
  source: "`asset_management`.`compliance`.`exam_finding`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Findings"
      display_name: "Findings"
      expr: COUNT(1)
      comment: "Findings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_gips_compliance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GIPS composite compliance verification status for performance reporting standards."
  source: "`asset_management`.`compliance`.`gips_compliance_record`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: compliance_status
      comment: "Status"
  measures:
    - name: "Records"
      display_name: "Records"
      expr: COUNT(1)
      comment: "Records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Compliant %"
      display_name: "Compliant %"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_status = 'COMPLIANT' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Compliant share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_ic_decision_governance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Investment committee decisions and outcome mix for governance reporting."
  source: "`asset_management`.`compliance`.`ic_decision`"
  dimensions:
    - name: "Decision Status"
      display_name: "Decision status"
      expr: decision_status
      comment: "Status"
  measures:
    - name: "Decisions"
      display_name: "Decisions"
      expr: COUNT(1)
      comment: "Decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved %"
      display_name: "Approved %"
      expr: ROUND(100.0 * SUM(CASE WHEN decision_status = 'APPROVED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Approved share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_kyc_completion`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC record completeness and risk rating distribution for AML oversight."
  source: "`asset_management`.`compliance`.`kyc_record`"
  dimensions:
    - name: "KYC Status"
      display_name: "Kyc status"
      expr: kyc_status
      comment: "Status"
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk"
  measures:
    - name: "KYC Records"
      display_name: "Kyc records"
      expr: COUNT(1)
      comment: "Records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed %"
      display_name: "Completed %"
      expr: ROUND(100.0 * SUM(CASE WHEN kyc_status = 'COMPLETED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Completed share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_kyc_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC/AML onboarding and screening KPIs monitoring counterparty due diligence quality, expiry pipeline, and sanctions/PEP risk for AML/KYC regulatory compliance."
  source: "`asset_management`.`compliance`.`kyc_record`"
  dimensions:
    - name: "kyc_status"
      display_name: "KYC Status"
      expr: kyc_status
      comment: "Overall KYC status of the counterparty record."
    - name: "aml_check_status"
      display_name: "AML Check Status"
      expr: aml_check_status
      comment: "AML check outcome status for the counterparty."
    - name: "sanctions_screening_status"
      display_name: "Sanctions Screening Status"
      expr: sanctions_screening_status
      comment: "Sanctions screening status used to flag prohibited counterparties."
    - name: "risk_rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Assigned counterparty risk rating for risk-based due diligence."
    - name: "party_type"
      display_name: "Party Type"
      expr: party_type
      comment: "Type of counterparty party (entity/individual) for segmentation."
    - name: "country_code"
      display_name: "Country Code"
      expr: country_code
      comment: "Country of the counterparty for geographic AML risk analysis."
  measures:
    - name: "kyc_record_count"
      display_name: "KYC Record Count"
      expr: COUNT(1)
      comment: "Total KYC records — baseline counterparty due diligence population."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pep_counterparty_count"
      display_name: "PEP Counterparty Count"
      expr: COUNT(CASE WHEN pep_status = 'Yes' THEN 1 END)
      comment: "Count of politically exposed person counterparties — enhanced due diligence population leadership monitors."
      format:
        type: number
        decimal_places:
          type: all
    - name: "expired_kyc_count"
      display_name: "Expired KYC Count"
      expr: COUNT(CASE WHEN kyc_expiry_date < CURRENT_DATE THEN 1 END)
      comment: "Count of counterparties with expired KYC — compliance gap requiring immediate re-verification."
      format:
        type: number
        decimal_places:
          type: all
    - name: "expired_kyc_rate"
      display_name: "Expired KYC Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN kyc_expiry_date < CURRENT_DATE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of KYC records expired — AML compliance health KPI for quarterly risk review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_counterparty_risk_score"
      display_name: "Avg Counterparty Risk Score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average counterparty risk score — portfolio-wide AML risk intensity for steering screening resources."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_counterparties_screened"
      display_name: "Distinct Counterparties Screened"
      expr: COUNT(DISTINCT counterparty_id)
      comment: "Distinct counterparties with KYC records — coverage measure of onboarding completeness."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_obligation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory obligation KPIs tracking compliance status, overdue obligations, and penalty risk exposure to ensure the fund meets all mandated filing and review deadlines."
  source: "`asset_management`.`compliance`.`obligation`"
  dimensions:
    - name: "obligation_status"
      display_name: "Obligation Status"
      expr: obligation_status
      comment: "Lifecycle status of the regulatory obligation."
    - name: "compliance_status"
      display_name: "Compliance Status"
      expr: compliance_status
      comment: "Compliance standing of the obligation (compliant, breached, pending)."
    - name: "obligation_type"
      display_name: "Obligation Type"
      expr: obligation_type
      comment: "Type of obligation for categorization across regulatory regimes."
    - name: "filing_frequency"
      display_name: "Filing Frequency"
      expr: filing_frequency
      comment: "Required filing cadence of the obligation."
    - name: "penalty_risk_level"
      display_name: "Penalty Risk Level"
      expr: penalty_risk_level
      comment: "Assessed penalty risk level of the obligation for prioritization."
  measures:
    - name: "obligation_count"
      display_name: "Obligation Count"
      expr: COUNT(1)
      comment: "Total regulatory obligations tracked — baseline compliance inventory."
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_obligation_count"
      display_name: "Overdue Obligation Count"
      expr: COUNT(CASE WHEN next_due_date < CURRENT_DATE AND is_reported = FALSE THEN 1 END)
      comment: "Count of obligations past due and not yet reported — regulatory breach risk requiring immediate action."
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_obligation_rate"
      display_name: "Overdue Obligation Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN next_due_date < CURRENT_DATE AND is_reported = FALSE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of obligations overdue — compliance timeliness KPI for steering review dashboards."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_penalty_exposure"
      display_name: "Total Penalty Exposure"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total potential penalty amount across obligations — aggregate regulatory financial risk to provision for."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_obligation_risk_score"
      display_name: "Avg Obligation Risk Score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across obligations — composite compliance risk intensity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_remediation_cost"
      display_name: "Total Remediation Cost"
      expr: SUM(CAST(remediation_cost_amount AS DOUBLE))
      comment: "Total remediation cost tied to obligations — compliance expense leadership budgets against."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_obligation_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Inventory of mapped regulatory obligations and their status across the control framework."
  source: "`asset_management`.`compliance`.`obligation`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: obligation_status
      comment: "Status"
  measures:
    - name: "Obligations"
      display_name: "Obligations"
      expr: COUNT(1)
      comment: "Obligations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active %"
      display_name: "Active %"
      expr: ROUND(100.0 * SUM(CASE WHEN obligation_status = 'ACTIVE' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Active share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_personal_account_dealing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Personal account dealing (PAD) KPIs monitoring employee trading pre-clearance compliance, waiver pressure, and review backlog to prevent insider trading and conflicts."
  source: "`asset_management`.`compliance`.`personal_account_dealing`"
  dimensions:
    - name: "preclearance_status"
      display_name: "Pre-clearance Status"
      expr: preclearance_status
      comment: "Pre-clearance approval status of the personal trade request."
    - name: "review_status"
      display_name: "Review Status"
      expr: compliance_review_status
      comment: "Compliance review status of the personal account dealing record."
    - name: "transaction_type"
      display_name: "Transaction Type"
      expr: transaction_type
      comment: "Type of personal transaction (buy/sell) for monitoring."
    - name: "risk_rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating assigned to the personal dealing request."
    - name: "dealing_month"
      display_name: "Dealing Month"
      expr: DATE_TRUNC('month', business_event_timestamp)
      comment: "Month bucket of the dealing event for trend monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "dealing_request_count"
      display_name: "Dealing Request Count"
      expr: COUNT(1)
      comment: "Total personal account dealing requests — baseline employee trading activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "approved_preclearance_rate"
      display_name: "Approved Pre-clearance Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN preclearance_status = 'Approved' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pre-clearance requests approved — governance indicator of employee trading conformity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "waiver_request_rate"
      display_name: "Waiver Request Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_waiver_requested = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of dealing requests seeking a waiver — policy exception pressure signal for compliance governance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_dealing_gross_amount"
      display_name: "Total Dealing Gross Amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross value of personal trades — scale of employee trading exposure to monitor."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "pending_review_count"
      display_name: "Pending Review Count"
      expr: COUNT(CASE WHEN compliance_review_timestamp IS NULL THEN 1 END)
      comment: "Count of dealing records awaiting compliance review — backlog indicator for surveillance resourcing."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_policy_exception_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Approved policy exceptions and their status for governance exception tracking."
  source: "`asset_management`.`compliance`.`policy_exception`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Exceptions"
      display_name: "Exceptions"
      expr: COUNT(1)
      comment: "Exceptions"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_regulatory_exam_activity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume and status of regulatory examinations the fund is subject to."
  source: "`asset_management`.`compliance`.`regulatory_exam`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Exams"
      display_name: "Exams"
      expr: COUNT(1)
      comment: "Exams"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_regulatory_filing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory filing KPIs tracking on-time submission, rejection rates, and filing fee burden across GIPS, SFDR, TCFD, IFRS and other mandated regulatory reports."
  source: "`asset_management`.`compliance`.`regulatory_filing`"
  dimensions:
    - name: "filing_status"
      display_name: "Filing Status"
      expr: filing_status
      comment: "Current status of the regulatory filing (submitted, accepted, rejected)."
    - name: "filing_type"
      display_name: "Filing Type"
      expr: filing_type
      comment: "Type of regulatory filing for categorization across regimes."
    - name: "submission_method"
      display_name: "Submission Method"
      expr: submission_method
      comment: "Channel used to submit the filing (portal, API, manual)."
    - name: "filing_period_month"
      display_name: "Filing Period Month"
      expr: DATE_TRUNC('month', reporting_period_end)
      comment: "Month bucket of the filing reporting period end for calendar analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "filing_count"
      display_name: "Filing Count"
      expr: COUNT(1)
      comment: "Total regulatory filings — baseline regulatory reporting workload."
      format:
        type: number
        decimal_places:
          type: all
    - name: "rejected_filing_count"
      display_name: "Rejected Filing Count"
      expr: COUNT(CASE WHEN rejection_date IS NOT NULL THEN 1 END)
      comment: "Count of rejected filings — quality failure signal requiring remediation and resubmission."
      format:
        type: number
        decimal_places:
          type: all
    - name: "late_filing_count"
      display_name: "Late Filing Count"
      expr: COUNT(CASE WHEN submission_date > filing_deadline THEN 1 END)
      comment: "Count of filings submitted after the deadline — regulatory timeliness breach triggering escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "on_time_filing_rate"
      display_name: "On-Time Filing Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN submission_date <= filing_deadline THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of filings submitted on or before deadline — core regulatory compliance KPI for board reporting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "rejection_rate"
      display_name: "Rejection Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN rejection_date IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of filings rejected — filing quality indicator driving process improvement decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_filing_fees"
      display_name: "Total Filing Fees"
      expr: SUM(CAST(filing_fee_amount AS DOUBLE))
      comment: "Total regulatory filing fees paid — direct compliance cost line executives track."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_regulatory_filing_timeliness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "On-time submission rate of regulatory filings across jurisdictions."
  source: "`asset_management`.`compliance`.`filing_submission`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Submissions"
      display_name: "Submissions"
      expr: COUNT(1)
      comment: "Filings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_rule_breach`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Compliance rule breach KPIs for monitoring regulatory risk exposure, penalty liability, and remediation effectiveness across the pension fund's investment and trading activities."
  source: "`asset_management`.`compliance`.`rule_breach`"
  dimensions:
    - name: "breach_status"
      display_name: "Breach Status"
      expr: rule_breach_status
      comment: "Lifecycle status of the breach (open, resolved, escalated) used to track remediation pipeline."
    - name: "severity_level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity classification of the breach for triage and escalation prioritization."
    - name: "compliance_area"
      display_name: "Compliance Area"
      expr: compliance_area
      comment: "Functional compliance domain the breach relates to (trading, ESG, mandate, etc.)."
    - name: "detection_method"
      display_name: "Detection Method"
      expr: detection_method
      comment: "How the breach was detected (automated surveillance vs manual review)."
    - name: "breach_month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_timestamp)
      comment: "Month bucket of breach occurrence for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "breach_year"
      display_name: "Breach Year"
      expr: DATE_TRUNC('year', breach_timestamp)
      comment: "Year bucket of breach occurrence for annual trend reporting."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "breach_count"
      display_name: "Breach Count"
      expr: COUNT(1)
      comment: "Total number of compliance rule breaches — baseline volume indicator for compliance risk steering."
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_breach_count"
      display_name: "Critical Breach Count"
      expr: COUNT(CASE WHEN is_critical = TRUE THEN 1 END)
      comment: "Number of breaches flagged critical — drives immediate executive escalation and board reporting."
      format:
        type: number
        decimal_places:
          type: all
    - name: "repeat_breach_count"
      display_name: "Repeat Breach Count"
      expr: COUNT(CASE WHEN is_repeat = TRUE THEN 1 END)
      comment: "Number of repeat breaches indicating systemic control weaknesses requiring remediation investment."
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_breach_rate"
      display_name: "Critical Breach Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_critical = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of breaches classified critical — a quality/risk ratio executives monitor to gauge control health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "repeat_breach_rate"
      display_name: "Repeat Breach Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_repeat = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of breaches that are repeats — a leading indicator of ineffective remediation and systemic control failure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_penalty_exposure"
      display_name: "Total Penalty Exposure"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Aggregate monetary penalty exposure from breaches — direct financial risk leadership must provision against."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_breach_risk_score"
      display_name: "Avg Breach Risk Score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across breaches — composite risk intensity metric for steering compliance resources."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "reported_breach_rate"
      display_name: "Reported Breach Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_reported = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of breaches reported to regulators — measures regulatory disclosure compliance obligation adherence."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_rule_breach_volume`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume and severity of compliance rule breaches across the control framework."
  source: "`asset_management`.`compliance`.`rule_breach`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Breaches"
      display_name: "Breaches"
      expr: COUNT(1)
      comment: "Breaches"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_sanctions_screening`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sanctions screening KPIs tracking match hit rates, false positive burden, and remediation of true matches to support AML/KYC suspicious activity reporting."
  source: "`asset_management`.`compliance`.`sanctions_screening`"
  dimensions:
    - name: "screening_result"
      display_name: "Screening Result"
      expr: screening_result
      comment: "Outcome of the sanctions screening (match/no-match/pending)."
    - name: "screening_list"
      display_name: "Screening List"
      expr: screening_list
      comment: "Sanctions/watchlist used for screening (OFAC, EU, UN, etc.)."
    - name: "screened_entity_type"
      display_name: "Screened Entity Type"
      expr: screened_entity_type
      comment: "Type of entity screened for segmentation."
    - name: "record_status"
      display_name: "Record Status"
      expr: record_status
      comment: "Processing status of the screening record."
    - name: "screening_month"
      display_name: "Screening Month"
      expr: DATE_TRUNC('month', screening_timestamp)
      comment: "Month bucket of screening event for volume and hit-rate trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "screening_count"
      display_name: "Screening Count"
      expr: COUNT(1)
      comment: "Total sanctions screenings performed — operational throughput baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "match_count"
      display_name: "Match Count"
      expr: COUNT(CASE WHEN screening_result = 'Match' THEN 1 END)
      comment: "Count of positive sanctions matches — direct regulatory and reputational risk events."
      format:
        type: number
        decimal_places:
          type: all
    - name: "false_positive_count"
      display_name: "False Positive Count"
      expr: COUNT(CASE WHEN is_false_positive = TRUE THEN 1 END)
      comment: "Count of false-positive matches — drives screening tuning and operational efficiency decisions."
      format:
        type: number
        decimal_places:
          type: all
    - name: "false_positive_rate"
      display_name: "False Positive Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_false_positive = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of screenings that are false positives — efficiency KPI for calibrating screening thresholds."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "true_match_rate"
      display_name: "True Match Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN screening_result = 'Match' AND is_false_positive = FALSE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of screenings resulting in true sanctions matches — core AML risk exposure indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_screening_risk_score"
      display_name: "Avg Screening Risk Score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score of screened entities — risk intensity gauge for AML resourcing."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`compliance_trade_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory trade reporting KPIs (EMIR/MiFID) tracking reportable trade volume, reporting completeness, and penalty risk to ensure transaction reporting compliance."
  source: "`asset_management`.`compliance`.`trade_report`"
  dimensions:
    - name: "compliance_status"
      display_name: "Compliance Status"
      expr: compliance_status
      comment: "Compliance status of the trade report."
    - name: "reporting_regime"
      display_name: "Reporting Regime"
      expr: reporting_regime
      comment: "Regulatory reporting regime (EMIR, MiFID, etc.)."
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the reported trade for segmentation."
    - name: "penalty_risk_level"
      display_name: "Penalty Risk Level"
      expr: penalty_risk_level
      comment: "Penalty risk level associated with the trade report."
    - name: "trade_month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_timestamp)
      comment: "Month bucket of the trade for reporting volume trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "trade_report_count"
      display_name: "Trade Report Count"
      expr: COUNT(1)
      comment: "Total trade reports — baseline transaction reporting volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "emir_reportable_rate"
      display_name: "EMIR Reportable Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN emir_reportable = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of trades EMIR-reportable — scope indicator for regulatory reporting obligation sizing."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_trade_notional"
      display_name: "Total Trade Notional"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross notional of reported trades — scale of reportable trading activity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_commission"
      display_name: "Total Commission"
      expr: SUM(CAST(commission AS DOUBLE))
      comment: "Total commission on reported trades — transaction cost line for trade cost analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "non_compliant_report_rate"
      display_name: "Non-Compliant Report Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN compliance_status <> 'Compliant' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of trade reports not compliant — reporting quality KPI driving remediation of reporting gaps."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
