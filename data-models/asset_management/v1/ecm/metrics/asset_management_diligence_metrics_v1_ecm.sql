-- Metric views for domain: diligence | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_dd_advisor_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Third-party advisor cost KPIs for diligence — budget vs actual, payment leakage, and cost efficiency by category. Steers diligence spend governance."
  source: "`asset_management`.`diligence`.`dd_advisor_cost`"
  dimensions:
    - name: "Cost Category"
      display_name: "Cost Category"
      expr: cost_category
      comment: "Category of the advisor cost (legal, financial, commercial, ESG, technical)."
    - name: "Cost Type"
      display_name: "Cost Type"
      expr: cost_type
      comment: "Type of cost incurred."
    - name: "Cost Approval Status"
      display_name: "Cost Approval Status"
      expr: cost_approval_status
      comment: "Approval status of the advisor cost."
    - name: "Cost Payment Status"
      display_name: "Cost Payment Status"
      expr: cost_payment_status
      comment: "Payment status of the advisor cost."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency of the cost record."
    - name: "Cost Month"
      display_name: "Cost Month"
      expr: DATE_TRUNC('month', cost_date)
      comment: "Month the cost was incurred."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Budgeted Cost"
      display_name: "Total Budgeted Cost"
      expr: SUM(CAST(budgeted_amount AS DOUBLE))
      comment: "Aggregate budgeted advisor cost — planned diligence spend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Invoiced Cost"
      display_name: "Total Invoiced Cost"
      expr: SUM(CAST(invoiced_amount AS DOUBLE))
      comment: "Aggregate invoiced advisor cost — incurred diligence spend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid Cost"
      display_name: "Total Paid Cost"
      expr: SUM(CAST(paid_amount AS DOUBLE))
      comment: "Aggregate paid advisor cost — cash outflow for diligence advisors."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Accrued Cost"
      display_name: "Total Accrued Cost"
      expr: SUM(CAST(accrued_amount AS DOUBLE))
      comment: "Aggregate accrued but unpaid advisor cost — outstanding liability for diligence spend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Invoiced Cost"
      display_name: "Avg Invoiced Cost"
      expr: AVG(CAST(invoiced_amount AS DOUBLE))
      comment: "Average invoiced cost per record — unit cost benchmark for advisor engagements."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Cost Record Count"
      display_name: "Cost Record Count"
      expr: COUNT(1)
      comment: "Number of advisor cost records — baseline spend transaction volume."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_dd_engagement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Due diligence engagement KPIs covering pipeline throughput, commitment sizing, IC conversion, and risk posture across asset classes. Core steering layer for the diligence function."
  source: "`asset_management`.`diligence`.`dd_engagement`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class under diligence (public equity, private equity, real estate, infrastructure, natural resources, credit)."
    - name: "DD Type"
      display_name: "DD Type"
      expr: dd_type
      comment: "Type of due diligence engagement (commercial, financial, legal, operational, ESG)."
    - name: "Engagement Status"
      display_name: "Engagement Status"
      expr: engagement_status
      comment: "Current lifecycle status of the diligence engagement."
    - name: "Overall DD Rating"
      display_name: "Overall DD Rating"
      expr: overall_dd_rating
      comment: "Overall diligence rating assigned to the engagement."
    - name: "IC Decision"
      display_name: "IC Decision"
      expr: ic_decision
      comment: "Investment Committee decision outcome for the engagement."
    - name: "Target Geography"
      display_name: "Target Geography"
      expr: target_geography
      comment: "Geography of the target entity under diligence."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Investment vintage year associated with the engagement."
    - name: "Initiation Month"
      display_name: "Initiation Month"
      expr: DATE_TRUNC('month', initiation_date)
      comment: "Month the diligence engagement was initiated, for pipeline trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Initiation Year"
      display_name: "Initiation Year"
      expr: DATE_TRUNC('year', initiation_date)
      comment: "Year the diligence engagement was initiated."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Engagement Count"
      display_name: "Engagement Count"
      expr: COUNT(1)
      comment: "Total number of diligence engagements in scope — baseline pipeline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Proposed Commitment"
      display_name: "Total Proposed Commitment"
      expr: SUM(CAST(proposed_commitment_amount AS DOUBLE))
      comment: "Aggregate proposed commitment capital flowing through diligence — measures capital-at-stake in the pipeline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Proposed Commitment"
      display_name: "Avg Proposed Commitment"
      expr: AVG(CAST(proposed_commitment_amount AS DOUBLE))
      comment: "Average proposed commitment per engagement — indicates typical deal size reaching diligence."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "IC Approved Engagements"
      display_name: "IC Approved Engagements"
      expr: COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END)
      comment: "Count of engagements that received IC approval — numerator for IC conversion analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Decided Engagements"
      display_name: "IC Decided Engagements"
      expr: COUNT(CASE WHEN ic_decision IS NOT NULL THEN 1 END)
      comment: "Count of engagements with an IC decision recorded — denominator for IC conversion rate."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Approval Rate"
      display_name: "IC Approval Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END) / NULLIF(COUNT(CASE WHEN ic_decision IS NOT NULL THEN 1 END), 0), 2)
      comment: "Share of IC-decided engagements that were approved — key conversion KPI for deal selectivity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "KYC AML Cleared Rate"
      display_name: "KYC/AML Cleared %"
      expr: ROUND(100.0 * COUNT(CASE WHEN kyc_aml_cleared = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of engagements with KYC/AML cleared — compliance readiness indicator for onboarding deals."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Completed Engagements"
      display_name: "Completed Engagements"
      expr: COUNT(CASE WHEN actual_completion_date IS NOT NULL THEN 1 END)
      comment: "Count of engagements with an actual completion date — throughput of finished diligence."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Diligence Cycle Days"
      display_name: "Avg Diligence Cycle (Days)"
      expr: AVG(DATEDIFF(actual_completion_date, initiation_date))
      comment: "Average days from initiation to completion — measures diligence cycle efficiency and resourcing."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_dd_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Diligence findings KPIs quantifying risk severity, financial impact, price/indemnity negotiation leverage, and remediation backlog. Steers deal risk posture and value protection."
  source: "`asset_management`.`diligence`.`dd_finding`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class the finding relates to."
    - name: "Finding Category"
      display_name: "Finding Category"
      expr: finding_category
      comment: "Category of the diligence finding."
    - name: "Severity Rating"
      display_name: "Severity Rating"
      expr: severity_rating
      comment: "Severity classification of the finding (e.g. critical, high, medium, low)."
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating assigned to the finding."
    - name: "Finding Status"
      display_name: "Finding Status"
      expr: finding_status
      comment: "Current status of the finding (open, remediated, closed)."
    - name: "ESG Theme"
      display_name: "ESG Theme"
      expr: esg_theme
      comment: "ESG theme associated with the finding, where applicable."
    - name: "Deal Impact Type"
      display_name: "Deal Impact Type"
      expr: deal_impact_type
      comment: "Nature of the deal impact (price adjustment, indemnity, condition, walk-away)."
    - name: "Identified Month"
      display_name: "Identified Month"
      expr: DATE_TRUNC('month', identified_date)
      comment: "Month the finding was identified, for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Finding Count"
      display_name: "Finding Count"
      expr: COUNT(1)
      comment: "Total number of diligence findings — baseline risk discovery volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Potential Financial Impact"
      display_name: "Total Potential Financial Impact"
      expr: SUM(CAST(potential_financial_impact_amount AS DOUBLE))
      comment: "Aggregate estimated financial exposure from findings — quantifies total deal risk at stake."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Price Adjustment"
      display_name: "Total Price Adjustment"
      expr: SUM(CAST(price_adjustment_amount AS DOUBLE))
      comment: "Aggregate price reduction negotiated from findings — direct value protected for the fund."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Indemnity Secured"
      display_name: "Total Indemnity Secured"
      expr: SUM(CAST(indemnity_amount AS DOUBLE))
      comment: "Aggregate indemnity protection secured from findings — risk transfer value negotiated."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Open Findings"
      display_name: "Open Findings"
      expr: COUNT(CASE WHEN finding_status = 'Open' THEN 1 END)
      comment: "Count of unresolved findings — remediation backlog requiring leadership attention."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Finding Rate"
      display_name: "Open Finding Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN finding_status = 'Open' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of findings still open — measures remediation effectiveness and residual risk."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Breach Findings"
      display_name: "Regulatory Breach Findings"
      expr: COUNT(CASE WHEN regulatory_breach_flag = TRUE THEN 1 END)
      comment: "Count of findings flagged as regulatory breaches — compliance escalation driver."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Reportable Findings"
      display_name: "IC Reportable Findings"
      expr: COUNT(CASE WHEN is_ic_reportable = TRUE THEN 1 END)
      comment: "Count of findings escalated to IC — material issues shaping the investment decision."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_dd_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Multi-dimensional diligence risk scoring KPIs (financial, ESG, legal, market, operational) and target return expectations. Steers portfolio risk-adjusted return decisions."
  source: "`asset_management`.`diligence`.`dd_risk_assessment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the assessed opportunity."
    - name: "Overall Risk Rating"
      display_name: "Overall Risk Rating"
      expr: overall_risk_rating
      comment: "Overall risk rating assigned by the assessment."
    - name: "IC Recommendation"
      display_name: "IC Recommendation"
      expr: ic_recommendation
      comment: "IC recommendation emerging from the risk assessment."
    - name: "Investment Strategy"
      display_name: "Investment Strategy"
      expr: investment_strategy
      comment: "Investment strategy classification of the opportunity."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year of the assessed investment."
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month the risk assessment was performed."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessment Count"
      display_name: "Assessment Count"
      expr: COUNT(1)
      comment: "Total number of risk assessments — baseline coverage of the diligence pipeline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Risk Score"
      display_name: "Avg Overall Risk Score"
      expr: AVG(CAST(overall_risk_score AS DOUBLE))
      comment: "Average composite risk score — portfolio-level risk posture indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Risk Score"
      display_name: "Avg ESG Risk Score"
      expr: AVG(CAST(esg_risk_score AS DOUBLE))
      comment: "Average ESG risk score — measures sustainability risk concentration across deals."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Financial Risk Score"
      display_name: "Avg Financial Risk Score"
      expr: AVG(CAST(financial_risk_score AS DOUBLE))
      comment: "Average financial risk score — balance-sheet and cash-flow risk indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr_pct AS DOUBLE))
      comment: "Average target IRR across assessed deals — expected return benchmark for the pipeline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target MOIC"
      display_name: "Avg Target MOIC"
      expr: AVG(CAST(target_moic AS DOUBLE))
      comment: "Average target multiple on invested capital — expected value-creation multiple."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Commitment Under Assessment"
      display_name: "Total Commitment Under Assessment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate commitment capital under risk assessment — capital-at-risk being evaluated."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "High Risk Rate"
      display_name: "High Risk Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN overall_risk_rating IN ('High','Critical') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of assessments rated high/critical overall — concentration of elevated-risk deals."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_dd_workstream`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Diligence workstream execution KPIs covering completion progress, finding backlog, advisor fees, and ESG/regulatory flags. Steers operational delivery of diligence engagements."
  source: "`asset_management`.`diligence`.`dd_workstream`"
  dimensions:
    - name: "Workstream Type"
      display_name: "Workstream Type"
      expr: workstream_type
      comment: "Type of diligence workstream (financial, legal, commercial, ESG, operational)."
    - name: "Workstream Status"
      display_name: "Workstream Status"
      expr: workstream_status
      comment: "Current status of the workstream."
    - name: "Overall Risk Rating"
      display_name: "Overall Risk Rating"
      expr: overall_risk_rating
      comment: "Overall risk rating emerging from the workstream."
    - name: "Priority Level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level of the workstream."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class the workstream supports."
    - name: "Planned Start Month"
      display_name: "Planned Start Month"
      expr: DATE_TRUNC('month', planned_start_date)
      comment: "Month the workstream was planned to start."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Workstream Count"
      display_name: "Workstream Count"
      expr: COUNT(1)
      comment: "Total number of diligence workstreams — baseline delivery volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Checklist Completion"
      display_name: "Avg Checklist Completion %"
      expr: AVG(CAST(checklist_completion_pct AS DOUBLE))
      comment: "Average checklist completion percentage — progress against diligence scope."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Open Findings"
      display_name: "Total Open Findings"
      expr: SUM(CAST(open_finding_count AS DOUBLE))
      comment: "Aggregate open findings across workstreams — remediation backlog driving sign-off risk."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Critical Findings"
      display_name: "Total Critical Findings"
      expr: SUM(CAST(critical_finding_count AS DOUBLE))
      comment: "Aggregate critical findings across workstreams — high-severity issues at deal level."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Advisor Fees"
      display_name: "Total Advisor Fees"
      expr: SUM(CAST(advisor_fee_amount AS DOUBLE))
      comment: "Aggregate advisor fees across workstreams — third-party diligence spend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Materiality Rate"
      display_name: "ESG Materiality Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN esg_materiality_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of workstreams flagging ESG materiality — ESG integration depth indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Concern Rate"
      display_name: "Regulatory Concern Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN regulatory_concern_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of workstreams raising regulatory concerns — compliance escalation driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_esg_dd_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG due diligence KPIs covering ESG scoring, carbon intensity, controversy incidence, and SFDR/net-zero alignment. Steers sustainable investment decisions and SFDR disclosure readiness."
  source: "`asset_management`.`diligence`.`esg_dd_assessment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the assessed target."
    - name: "Overall ESG Rating"
      display_name: "Overall ESG Rating"
      expr: overall_esg_rating
      comment: "Overall ESG rating assigned to the target."
    - name: "SFDR Article Classification"
      display_name: "SFDR Article"
      expr: sfdr_article_classification
      comment: "SFDR article classification (6, 8, 9) of the investment."
    - name: "Net Zero Alignment"
      display_name: "Net Zero Alignment"
      expr: net_zero_alignment
      comment: "Net-zero alignment classification of the target."
    - name: "Target Sector"
      display_name: "Target Sector"
      expr: target_sector
      comment: "Sector of the assessed target."
    - name: "Climate Transition Risk Rating"
      display_name: "Climate Transition Risk"
      expr: climate_transition_risk_rating
      comment: "Climate transition risk rating of the target."
    - name: "Assessment Completion Month"
      display_name: "Completion Month"
      expr: DATE_TRUNC('month', actual_completion_date)
      comment: "Month the ESG assessment completed."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessment Count"
      display_name: "Assessment Count"
      expr: COUNT(1)
      comment: "Total ESG assessments — baseline coverage of ESG diligence."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across targets — portfolio sustainability quality indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Intensity"
      display_name: "Avg Carbon Intensity"
      expr: AVG(CAST(carbon_intensity AS DOUBLE))
      comment: "Average carbon intensity of assessed targets — TCFD climate exposure metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Scope 1 Emissions"
      display_name: "Total Scope 1 Emissions"
      expr: SUM(CAST(ghg_scope1_emissions AS DOUBLE))
      comment: "Aggregate Scope 1 GHG emissions across targets — direct emissions exposure."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Scope 2 Emissions"
      display_name: "Total Scope 2 Emissions"
      expr: SUM(CAST(ghg_scope2_emissions AS DOUBLE))
      comment: "Aggregate Scope 2 GHG emissions across targets — indirect energy emissions exposure."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Controversy Rate"
      display_name: "Controversy Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN controversy_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of targets with an ESG controversy flag — reputational/ESG risk incidence."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Exclusion List Hit Rate"
      display_name: "Exclusion List Check %"
      expr: ROUND(100.0 * COUNT(CASE WHEN exclusion_list_check = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of targets subject to exclusion-list checks — screening coverage indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Human Rights Risk Rate"
      display_name: "Human Rights Risk %"
      expr: ROUND(100.0 * COUNT(CASE WHEN human_rights_risk_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of targets flagged for human-rights risk — social (S) dimension escalation driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_fdd_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial due diligence KPIs covering EBITDA normalization, margin quality, leverage, and quality-of-earnings. Steers valuation and financial-risk decisions on direct deals."
  source: "`asset_management`.`diligence`.`fdd_assessment`"
  dimensions:
    - name: "Overall FDD Rating"
      display_name: "Overall FDD Rating"
      expr: overall_fdd_rating
      comment: "Overall financial due diligence rating."
    - name: "QoE Rating"
      display_name: "QoE Rating"
      expr: qoe_rating
      comment: "Quality-of-earnings rating from the FDD."
    - name: "Financial Controls Rating"
      display_name: "Financial Controls Rating"
      expr: financial_controls_rating
      comment: "Rating of the target's financial controls environment."
    - name: "Accounting Standard"
      display_name: "Accounting Standard"
      expr: accounting_standard
      comment: "Accounting standard used by the target (IFRS, US GAAP, etc.)."
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month the FDD assessment was performed."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessment Count"
      display_name: "Assessment Count"
      expr: COUNT(1)
      comment: "Total FDD assessments — baseline financial diligence coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Normalized EBITDA"
      display_name: "Total Normalized EBITDA"
      expr: SUM(CAST(normalized_ebitda AS DOUBLE))
      comment: "Aggregate normalized EBITDA across targets — adjusted earnings power under diligence."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total EBITDA Normalization Adjustment"
      display_name: "Total EBITDA Normalization"
      expr: SUM(CAST(ebitda_normalization_total AS DOUBLE))
      comment: "Aggregate EBITDA normalization adjustments — magnitude of earnings quality corrections."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg EBITDA Margin"
      display_name: "Avg EBITDA Margin %"
      expr: AVG(CAST(ebitda_margin_pct AS DOUBLE))
      comment: "Average EBITDA margin of assessed targets — profitability quality benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Revenue CAGR"
      display_name: "Avg Revenue CAGR %"
      expr: AVG(CAST(revenue_cagr_pct AS DOUBLE))
      comment: "Average historical revenue CAGR of targets — growth quality indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Adjusted Net Debt"
      display_name: "Total Adjusted Net Debt"
      expr: SUM(CAST(adjusted_net_debt AS DOUBLE))
      comment: "Aggregate adjusted net debt across targets — leverage exposure at acquisition."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Pension Deficit"
      display_name: "Total Pension Deficit"
      expr: SUM(CAST(pension_deficit AS DOUBLE))
      comment: "Aggregate pension deficit identified in targets — hidden liability exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Contingent Liability Rate"
      display_name: "Contingent Liability Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN contingent_liabilities_identified = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of targets with identified contingent liabilities — off-balance-sheet risk incidence."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_ic_condition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "IC condition and conditions-precedent KPIs covering resolution backlog, overdue items, and waiver incidence. Steers deal-closing readiness and post-IC risk closure."
  source: "`asset_management`.`diligence`.`diligence_ic_condition`"
  dimensions:
    - name: "Condition Category"
      display_name: "Condition Category"
      expr: condition_category
      comment: "Category of the IC condition."
    - name: "Condition Status"
      display_name: "Condition Status"
      expr: condition_status
      comment: "Current status of the condition (open, resolved, waived)."
    - name: "Condition Type"
      display_name: "Condition Type"
      expr: condition_type
      comment: "Type of condition (conditions precedent, conditions subsequent, ongoing)."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class the condition relates to."
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the condition."
    - name: "Target Resolution Month"
      display_name: "Target Resolution Month"
      expr: DATE_TRUNC('month', target_resolution_date)
      comment: "Month the condition is targeted for resolution."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Condition Count"
      display_name: "Condition Count"
      expr: COUNT(1)
      comment: "Total number of IC conditions — baseline closing-obligation volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Conditions"
      display_name: "Open Conditions"
      expr: COUNT(CASE WHEN condition_status = 'Open' THEN 1 END)
      comment: "Count of unresolved IC conditions — closing-readiness backlog."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Resolution Rate"
      display_name: "Resolution Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN actual_resolution_date IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of conditions resolved — condition-closure effectiveness KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Overdue Conditions"
      display_name: "Overdue Conditions"
      expr: COUNT(CASE WHEN actual_resolution_date IS NULL AND target_resolution_date < CURRENT_DATE THEN 1 END)
      comment: "Count of unresolved conditions past their target date — at-risk closing items needing escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Blocking Conditions"
      display_name: "IC Blocking Conditions"
      expr: COUNT(CASE WHEN is_ic_blocking = TRUE THEN 1 END)
      comment: "Count of conditions that are IC-blocking — gating items for deal approval."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waiver Rate"
      display_name: "Waiver Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN waiver_approved = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of conditions resolved by waiver — governance signal on condition rigor."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_ic_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Investment Committee submission KPIs covering recommended vs approved commitment, deal economics, and approval conversion. Steers capital allocation governance."
  source: "`asset_management`.`diligence`.`diligence_ic_submission`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the submitted opportunity."
    - name: "Investment Type"
      display_name: "Investment Type"
      expr: investment_type
      comment: "Type of investment (direct, co-investment, fund commitment)."
    - name: "IC Decision"
      display_name: "IC Decision"
      expr: ic_decision
      comment: "Investment Committee decision on the submission."
    - name: "Overall DD Rating"
      display_name: "Overall DD Rating"
      expr: overall_dd_rating
      comment: "Overall diligence rating carried into the IC submission."
    - name: "Target Geography"
      display_name: "Target Geography"
      expr: target_geography
      comment: "Geography of the target entity."
    - name: "SAA Bucket"
      display_name: "SAA Bucket"
      expr: saa_asset_class_bucket
      comment: "Strategic asset allocation bucket the submission maps to."
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month the submission was presented to IC."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Submission Count"
      display_name: "Submission Count"
      expr: COUNT(1)
      comment: "Total number of IC submissions — baseline volume of deals reaching committee."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Recommended Commitment"
      display_name: "Total Recommended Commitment"
      expr: SUM(CAST(recommended_commitment_amount AS DOUBLE))
      comment: "Aggregate commitment recommended to IC — proposed capital deployment."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Approved Commitment"
      display_name: "Total Approved Commitment"
      expr: SUM(CAST(approved_commitment_amount AS DOUBLE))
      comment: "Aggregate commitment approved by IC — actual capital allocated through diligence."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Approved Submissions"
      display_name: "Approved Submissions"
      expr: COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END)
      comment: "Count of IC-approved submissions — numerator for approval conversion."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Approval Rate"
      display_name: "IC Approval Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of submissions approved by IC — governance selectivity and deal quality KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr_pct AS DOUBLE))
      comment: "Average target IRR on submissions — expected return of the IC pipeline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hurdle Rate"
      display_name: "Avg Hurdle Rate %"
      expr: AVG(CAST(hurdle_rate_pct AS DOUBLE))
      comment: "Average hurdle rate applied — return threshold discipline across submissions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Material Submissions"
      display_name: "ESG Material Submissions"
      expr: COUNT(CASE WHEN esg_materiality_flag = TRUE THEN 1 END)
      comment: "Count of submissions flagged ESG-material — SFDR/ESG integration coverage indicator."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`diligence_kyc_aml_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC/AML screening KPIs covering sanctions/PEP incidence, enhanced due diligence burden, and clearance outcomes. Steers financial-crime risk and AML/KYC regulatory compliance."
  source: "`asset_management`.`diligence`.`kyc_aml_record`"
  dimensions:
    - name: "AML Risk Rating"
      display_name: "AML Risk Rating"
      expr: aml_risk_rating
      comment: "AML risk rating assigned to the subject."
    - name: "Screening Status"
      display_name: "Screening Status"
      expr: screening_status
      comment: "Status of the screening process."
    - name: "Overall Outcome"
      display_name: "Overall Outcome"
      expr: overall_kyc_aml_outcome
      comment: "Overall KYC/AML outcome for the subject."
    - name: "Subject Type"
      display_name: "Subject Type"
      expr: subject_type
      comment: "Type of the screened subject (entity, individual, UBO)."
    - name: "Subject Domicile Country"
      display_name: "Subject Domicile"
      expr: subject_domicile_country
      comment: "Domicile country of the screened subject."
    - name: "Screening Completed Month"
      display_name: "Screening Completed Month"
      expr: DATE_TRUNC('month', screening_completed_date)
      comment: "Month screening was completed."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Screening Count"
      display_name: "Screening Count"
      expr: COUNT(1)
      comment: "Total KYC/AML screening records — baseline financial-crime screening volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg AML Risk Score"
      display_name: "Avg AML Risk Score"
      expr: AVG(CAST(aml_risk_score AS DOUBLE))
      comment: "Average AML risk score across subjects — aggregate financial-crime risk posture."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Sanctions Hit Rate"
      display_name: "Sanctions Hit Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN sanctions_hit_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of subjects with a sanctions hit — critical escalation and reporting driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "PEP Rate"
      display_name: "PEP Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN pep_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of subjects identified as politically exposed persons — enhanced scrutiny driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Enhanced DD Rate"
      display_name: "Enhanced DD Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN enhanced_due_diligence_required = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of subjects requiring enhanced due diligence — compliance workload and risk burden."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Adverse Media Rate"
      display_name: "Adverse Media Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN adverse_media_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of subjects with adverse media findings — reputational risk screening signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
