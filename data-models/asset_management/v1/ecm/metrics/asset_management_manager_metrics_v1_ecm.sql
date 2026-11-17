-- Metric views for domain: manager | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_co_invest_right`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Co-investment right utilisation KPIs tracking deployed capital, remaining capacity and opportunity conversion to steer capital deployment and off-market deal origination."
  source: "`asset_management`.`manager`.`co_invest_right`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the co-investment right."
    - name: "Right Type"
      display_name: "Right Type"
      expr: right_type
      comment: "Type of co-investment right."
    - name: "Right Status"
      display_name: "Right Status"
      expr: right_status
      comment: "Current status of the right."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the right."
    - name: "Fee Structure Type"
      display_name: "Fee Structure Type"
      expr: fee_structure_type
      comment: "Fee structure type for the co-investment right."
  measures:
    - name: "Rights Count"
      display_name: "Rights Count"
      expr: COUNT(1)
      comment: "Total number of co-investment rights."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Deployed Amount"
      display_name: "Total Deployed Amount"
      expr: SUM(CAST(total_deployed_amount AS DOUBLE))
      comment: "Total capital deployed through co-investment rights."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Right Cap Amount"
      display_name: "Total Right Cap Amount"
      expr: SUM(CAST(total_right_cap_amount AS DOUBLE))
      comment: "Total cap amount across co-investment rights."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Remaining Capacity"
      display_name: "Total Remaining Capacity"
      expr: SUM(CAST(remaining_capacity_amount AS DOUBLE))
      comment: "Total remaining co-investment capacity — dry optionality for off-market deals."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Opportunities Offered"
      display_name: "Opportunities Offered"
      expr: SUM(CAST(opportunities_offered_count AS DOUBLE))
      comment: "Total co-investment opportunities offered by GPs."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Opportunities Accepted"
      display_name: "Opportunities Accepted"
      expr: SUM(CAST(opportunities_accepted_count AS DOUBLE))
      comment: "Total co-investment opportunities accepted."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Opportunity Acceptance Rate"
      display_name: "Opportunity Acceptance Rate"
      expr: ROUND(100.0 * SUM(CAST(opportunities_accepted_count AS DOUBLE)) / NULLIF(SUM(CAST(opportunities_offered_count AS DOUBLE)), 0), 2)
      comment: "Percent of offered co-investment opportunities accepted — selectivity / origination conversion."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Capacity Utilization Rate"
      display_name: "Capacity Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(total_deployed_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_right_cap_amount AS DOUBLE)), 0), 2)
      comment: "Percent of total co-investment capacity deployed — utilisation of negotiated rights."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carry Rate"
      display_name: "Avg Carry Rate"
      expr: AVG(CAST(carry_rate AS DOUBLE))
      comment: "Average carry rate on co-investment rights."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_evaluation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manager evaluation KPIs covering conviction scores, ESG integration, reported performance and watch-list signals used by the manager research committee to steer re-up and redemption decisions."
  source: "`asset_management`.`manager`.`evaluation`"
  dimensions:
    - name: "Evaluation Type"
      display_name: "Evaluation Type"
      expr: evaluation_type
      comment: "Type of evaluation (annual review, ODD, initial screen, etc.)."
    - name: "Evaluation Status"
      display_name: "Evaluation Status"
      expr: evaluation_status
      comment: "Workflow status of the evaluation."
    - name: "Overall Conviction Rating"
      display_name: "Conviction Rating"
      expr: overall_conviction_rating
      comment: "Analyst overall conviction rating on the manager."
    - name: "ESG Maturity Level"
      display_name: "ESG Maturity Level"
      expr: esg_maturity_level
      comment: "Qualitative ESG maturity classification of the manager."
    - name: "Recommended Action"
      display_name: "Recommended Action"
      expr: recommended_action
      comment: "Recommended action coming out of the evaluation."
    - name: "Evaluation Month"
      display_name: "Evaluation Month"
      expr: DATE_TRUNC('month', evaluation_date)
      comment: "Evaluation date bucketed to month for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Evaluation Year"
      display_name: "Evaluation Year"
      expr: DATE_TRUNC('year', evaluation_date)
      comment: "Evaluation date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Evaluations Count"
      display_name: "Evaluations Count"
      expr: COUNT(1)
      comment: "Total number of manager evaluations performed."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Managers Evaluated"
      display_name: "Managers Evaluated"
      expr: COUNT(DISTINCT gp_profile_id)
      comment: "Distinct managers (GP profiles) evaluated — breadth of coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Score"
      display_name: "Avg Overall Score"
      expr: AVG(CAST(overall_score AS DOUBLE))
      comment: "Average overall evaluation score — manager quality signal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Integration Score"
      display_name: "Avg ESG Integration Score"
      expr: AVG(CAST(esg_integration_score AS DOUBLE))
      comment: "Average ESG integration score across evaluations — SFDR/stewardship steering metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Reported IRR Pct"
      display_name: "Avg Reported IRR %"
      expr: AVG(CAST(reported_irr_pct AS DOUBLE))
      comment: "Average reported IRR across evaluated managers."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Reported MOIC"
      display_name: "Avg Reported MOIC"
      expr: AVG(CAST(reported_moic AS DOUBLE))
      comment: "Average reported MOIC across evaluated managers."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Watch List Rate"
      display_name: "Watch List Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN watch_list_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of evaluations flagging the manager for the watch list — early-warning risk signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Compliance Breach Rate"
      display_name: "Compliance Breach Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_breach_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of evaluations surfacing a compliance breach."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rating Downgrade Count"
      display_name: "Rating Change Count"
      expr: SUM(CASE WHEN rating_change_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Number of evaluations with a conviction rating change — governance attention trigger."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_gp_profile`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "General Partner / manager master KPIs covering assets under management, dry powder, relationship maturity and ESG/compliance posture used to size the external manager book."
  source: "`asset_management`.`manager`.`gp_profile`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Primary asset class of the manager."
    - name: "Manager Type"
      display_name: "Manager Type"
      expr: manager_type
      comment: "Type of manager (GP, external fund, direct, etc.)."
    - name: "Manager Status"
      display_name: "Manager Status"
      expr: manager_status
      comment: "Current relationship status of the manager."
    - name: "Manager Risk Rating"
      display_name: "Manager Risk Rating"
      expr: manager_risk_rating
      comment: "Overall manager risk rating."
    - name: "Domicile Country"
      display_name: "Domicile Country"
      expr: domicile_country
      comment: "Country of domicile of the manager."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Primary geographic investment focus."
    - name: "KYC Status"
      display_name: "KYC Status"
      expr: kyc_status
      comment: "Current KYC status of the manager."
  measures:
    - name: "Managers Count"
      display_name: "Managers Count"
      expr: COUNT(1)
      comment: "Total number of managers in the book."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total AUM"
      display_name: "Total AUM"
      expr: SUM(CAST(aum_usd AS DOUBLE))
      comment: "Total manager AUM across the book — scale of external relationships."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Dry Powder"
      display_name: "Total Dry Powder"
      expr: SUM(CAST(dry_powder_usd AS DOUBLE))
      comment: "Total undeployed capital across managers — future deployment capacity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Rate"
      display_name: "Avg Management Fee Rate"
      expr: AVG(CAST(management_fee_rate AS DOUBLE))
      comment: "Average management fee rate across managers — fee negotiation benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Carried Interest Rate"
      display_name: "Avg Carried Interest Rate"
      expr: AVG(CAST(carried_interest_rate AS DOUBLE))
      comment: "Average carried interest rate across managers."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Track Record Years"
      display_name: "Avg Track Record Years"
      expr: AVG(CAST(track_record_years AS DOUBLE))
      comment: "Average manager track record length — experience quality signal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "PRI Signatory Rate"
      display_name: "PRI Signatory Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN pri_signatory_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of managers that are PRI signatories — responsible-investment coverage."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "TCFD Aligned Rate"
      display_name: "TCFD Aligned Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN tcfd_aligned_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of managers aligned to TCFD — climate-disclosure readiness."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Policy Rate"
      display_name: "ESG Policy Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_policy_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of managers with a formal ESG policy in place."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_mandate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Mandate-level KPIs covering committed and target capital, fee economics and ESG integration used to steer allocation planning and mandate governance."
  source: "`asset_management`.`manager`.`manager_mandate`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the mandate."
    - name: "Mandate Type"
      display_name: "Mandate Type"
      expr: mandate_type
      comment: "Type of mandate."
    - name: "Mandate Status"
      display_name: "Mandate Status"
      expr: mandate_status
      comment: "Current status of the mandate."
    - name: "ESG Integration Level"
      display_name: "ESG Integration Level"
      expr: esg_integration_level
      comment: "ESG integration level for the mandate."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the mandate."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year of the mandate."
  measures:
    - name: "Mandates Count"
      display_name: "Mandates Count"
      expr: COUNT(1)
      comment: "Total number of mandates."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Commitment"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Total committed capital across mandates."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Target Allocation"
      display_name: "Total Target Allocation"
      expr: SUM(CAST(target_allocation_amount AS DOUBLE))
      comment: "Total target allocation across mandates — allocation plan sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Rate"
      display_name: "Avg Management Fee Rate"
      expr: AVG(CAST(management_fee_rate AS DOUBLE))
      comment: "Average management fee rate across mandates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Carried Interest Rate"
      display_name: "Avg Carried Interest Rate"
      expr: AVG(CAST(carried_interest_rate AS DOUBLE))
      comment: "Average carried interest rate across mandates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Target Allocation Pct"
      display_name: "Avg Target Allocation %"
      expr: AVG(CAST(target_allocation_pct AS DOUBLE))
      comment: "Average target allocation percent across mandates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "SLA Reporting Breach Rate"
      display_name: "SLA Reporting Breach Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sla_reporting_breach_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of mandates flagged for SLA reporting breaches."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Co-Investment Rights Rate"
      display_name: "Co-Investment Rights Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN co_investment_rights = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of mandates carrying co-investment rights — deal-flow optionality."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_reporting_obligation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manager reporting obligation KPIs tracking SLA compliance, delivery timeliness and penalty exposure to steer manager oversight and regulatory reporting readiness."
  source: "`asset_management`.`manager`.`reporting_obligation`"
  dimensions:
    - name: "Obligation Type"
      display_name: "Obligation Type"
      expr: obligation_type
      comment: "Type of reporting obligation."
    - name: "Frequency"
      display_name: "Frequency"
      expr: frequency
      comment: "Reporting frequency."
    - name: "Obligation Status"
      display_name: "Obligation Status"
      expr: reporting_obligation_status
      comment: "Current status of the reporting obligation."
    - name: "SLA Status"
      display_name: "SLA Status"
      expr: sla_status
      comment: "SLA status for the obligation."
    - name: "Delivery Channel"
      display_name: "Delivery Channel"
      expr: delivery_channel
      comment: "Delivery channel for the report."
    - name: "Due Month"
      display_name: "Due Month"
      expr: DATE_TRUNC('month', next_due_date)
      comment: "Next due date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Obligations Count"
      display_name: "Obligations Count"
      expr: COUNT(1)
      comment: "Total number of reporting obligations tracked."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Compliance Rate"
      display_name: "Compliance Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of obligations in compliance — manager reporting discipline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Penalty Applicable Rate"
      display_name: "Penalty Applicable Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN penalty_clause_applicable = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of obligations carrying an applicable penalty clause."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Penalty Exposure"
      display_name: "Total Penalty Exposure"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total potential penalty exposure across obligations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Delivery Deadline Days"
      display_name: "Avg Delivery Deadline Days"
      expr: AVG(CAST(data_delivery_deadline_days AS DOUBLE))
      comment: "Average contractual delivery deadline in days."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_rfp_response`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "RFP response evaluation KPIs covering proposed economics, evaluation scores and shortlisting to steer manager selection and mandate award decisions."
  source: "`asset_management`.`manager`.`rfp_response`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the RFP response."
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Strategy type proposed in the response."
    - name: "Submission Status"
      display_name: "Submission Status"
      expr: submission_status
      comment: "Submission status of the response."
    - name: "Target Geography"
      display_name: "Target Geography"
      expr: target_geography
      comment: "Target geography of the proposed strategy."
    - name: "Fee Basis"
      display_name: "Fee Basis"
      expr: fee_basis
      comment: "Fee basis quoted in the response."
  measures:
    - name: "Responses Count"
      display_name: "Responses Count"
      expr: COUNT(1)
      comment: "Total number of RFP responses received."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Evaluation Score"
      display_name: "Avg Overall Evaluation Score"
      expr: AVG(CAST(overall_evaluation_score AS DOUBLE))
      comment: "Average overall evaluation score across responses — manager-selection quality."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Fee Competitiveness Score"
      display_name: "Avg Fee Competitiveness Score"
      expr: AVG(CAST(fee_competitiveness_score AS DOUBLE))
      comment: "Average fee competitiveness score."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score of RFP responses."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Rate Bps"
      display_name: "Avg Mgmt Fee (bps)"
      expr: AVG(CAST(management_fee_rate_bps AS DOUBLE))
      comment: "Average proposed management fee in basis points — fee benchmarking."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Target IRR Pct"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr_pct AS DOUBLE))
      comment: "Average proposed target IRR across responses."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Proposed Commitment"
      display_name: "Total Proposed Commitment"
      expr: SUM(CAST(proposed_commitment_usd AS DOUBLE))
      comment: "Total proposed commitment across responses."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Shortlist Rate"
      display_name: "Shortlist Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN shortlist_recommendation = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of responses recommended for shortlist — RFP conversion funnel."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Key Person Risk Rate"
      display_name: "Key Person Risk Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN key_person_risk_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of responses flagged for key-person risk."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manager risk assessment KPIs across operational, counterparty, liquidity, ESG and regulatory risk dimensions used to prioritise ODD remediation and concentration management."
  source: "`asset_management`.`manager`.`risk_assessment`"
  dimensions:
    - name: "Assessment Type"
      display_name: "Assessment Type"
      expr: assessment_type
      comment: "Type of risk assessment."
    - name: "Overall Risk Rating"
      display_name: "Overall Risk Rating"
      expr: overall_risk_rating
      comment: "Overall manager risk rating classification."
    - name: "Operational Risk Rating"
      display_name: "Operational Risk Rating"
      expr: operational_risk_rating
      comment: "Operational risk rating classification."
    - name: "ESG Risk Rating"
      display_name: "ESG Risk Rating"
      expr: esg_risk_rating
      comment: "ESG risk rating classification."
    - name: "Regulatory Status"
      display_name: "Regulatory Status"
      expr: regulatory_status
      comment: "Regulatory standing of the manager at assessment."
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Assessment date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessments Count"
      display_name: "Assessments Count"
      expr: COUNT(1)
      comment: "Total number of risk assessments."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Risk Score"
      display_name: "Avg Overall Risk Score"
      expr: AVG(CAST(overall_risk_score AS DOUBLE))
      comment: "Average overall risk score — portfolio manager-risk posture."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Operational Risk Score"
      display_name: "Avg Operational Risk Score"
      expr: AVG(CAST(operational_risk_score AS DOUBLE))
      comment: "Average operational risk score."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Liquidity Risk Score"
      display_name: "Avg Liquidity Risk Score"
      expr: AVG(CAST(liquidity_risk_score AS DOUBLE))
      comment: "Average liquidity risk score — redemption/duration planning signal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Risk Score"
      display_name: "Avg ESG Risk Score"
      expr: AVG(CAST(esg_risk_score AS DOUBLE))
      comment: "Average ESG risk score across assessments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Critical Findings"
      display_name: "Total Critical Findings"
      expr: SUM(CAST(critical_findings_count AS DOUBLE))
      comment: "Total critical findings identified across assessments — remediation workload driver."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Open Findings"
      display_name: "Total Open Findings"
      expr: SUM(CAST(open_findings_count AS DOUBLE))
      comment: "Total currently open findings pending remediation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Watch List Rate"
      display_name: "Watch List Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN watch_list_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of assessments resulting in a watch-list flag."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Enforcement Action Rate"
      display_name: "Enforcement Action Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN enforcement_action_exists = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of assessments where a regulatory enforcement action exists — reputational risk escalation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Pension Fund AUM Pct"
      display_name: "Avg Pension Fund AUM %"
      expr: AVG(CAST(pension_fund_aum_pct AS DOUBLE))
      comment: "Average share of manager AUM represented by this pension fund — concentration-risk gauge."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`manager_sla_breach`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manager SLA breach KPIs tracking reporting/operational service failures, financial impact, resolution speed and regulatory reportability to steer manager accountability and penalty enforcement."
  source: "`asset_management`.`manager`.`sla_breach`"
  dimensions:
    - name: "Breach Category"
      display_name: "Breach Category"
      expr: breach_category
      comment: "Category of the SLA breach."
    - name: "Severity Classification"
      display_name: "Severity"
      expr: severity_classification
      comment: "Severity classification of the breach."
    - name: "Breach Status"
      display_name: "Breach Status"
      expr: breach_status
      comment: "Current status of the breach (open, resolved, waived)."
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root-cause classification of the breach."
    - name: "Affected Asset Class"
      display_name: "Affected Asset Class"
      expr: affected_asset_class
      comment: "Asset class affected by the breach."
    - name: "Breach Month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_date)
      comment: "Breach date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Breaches Count"
      display_name: "Breaches Count"
      expr: COUNT(1)
      comment: "Total number of SLA breaches."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Managers Breaching"
      display_name: "Managers Breaching"
      expr: COUNT(DISTINCT gp_profile_id)
      comment: "Distinct managers responsible for SLA breaches."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Financial Impact"
      display_name: "Total Financial Impact"
      expr: SUM(CAST(financial_impact_amount AS DOUBLE))
      comment: "Total financial impact of SLA breaches — cost quantification for escalation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Penalty Amount"
      display_name: "Total Penalty Amount"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total contractual penalties triggered by breaches."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days To Resolution"
      display_name: "Avg Days To Resolution"
      expr: AVG(CAST(days_to_resolution AS DOUBLE))
      comment: "Average days to resolve a breach — manager responsiveness KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days Overdue"
      display_name: "Avg Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average days overdue for breached obligations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_regulatory_reportable = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of breaches that are regulatory reportable — compliance exposure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Repeat Breach Rate"
      display_name: "Repeat Breach Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_repeat_breach = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of breaches that are repeat occurrences — systemic manager issue indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Penalty Triggered Rate"
      display_name: "Penalty Triggered Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_contractual_penalty_triggered = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of breaches that triggered a contractual penalty."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
