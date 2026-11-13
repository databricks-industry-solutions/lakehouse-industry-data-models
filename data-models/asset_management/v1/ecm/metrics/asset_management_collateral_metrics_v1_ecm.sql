-- Metric views for domain: collateral | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_counterparty`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Counterparty credit-quality KPIs: default probability, recovery, ESG, credit/exposure limits and blacklist exposure. Used by Risk/CRO to steer counterparty concentration and credit discipline."
  source: "`asset_management`.`collateral`.`counterparty`"
  dimensions:
    - name: "Classification"
      display_name: "Classification"
      expr: classification
      comment: "Counterparty classification (bank, broker, CCP, fund)."
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Internal risk rating of the counterparty."
    - name: "Counterparty Status"
      display_name: "Counterparty Status"
      expr: counterparty_status
      comment: "Current status of the counterparty relationship."
    - name: "Jurisdiction"
      display_name: "Jurisdiction"
      expr: jurisdiction
      comment: "Legal jurisdiction of the counterparty."
    - name: "Entity Type"
      display_name: "Entity Type"
      expr: entity_type
      comment: "Entity type of the counterparty."
  measures:
    - name: "Counterparty Count"
      display_name: "Counterparty Count"
      expr: COUNT(1)
      comment: "Total counterparties — relationship-book size for concentration analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Default Probability"
      display_name: "Avg Default Probability"
      expr: AVG(CAST(default_probability AS DOUBLE))
      comment: "Average probability of default across counterparties — portfolio credit-quality gauge."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Recovery Rate"
      display_name: "Avg Recovery Rate"
      expr: AVG(CAST(recovery_rate AS DOUBLE))
      comment: "Average expected recovery rate — loss-given-default input for credit steering."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score of counterparties — ESG-integration compliance and SFDR steering."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Exposure Limit"
      display_name: "Total Exposure Limit"
      expr: SUM(CAST(exposure_limit AS DOUBLE))
      comment: "Aggregate approved exposure limits — total credit appetite granted."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Blacklisted Rate"
      display_name: "Blacklisted Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_blacklisted = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counterparties blacklisted — AML/KYC and credit-exclusion risk indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Collateral Eligible Rate"
      display_name: "Collateral Eligible Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN collateral_eligible_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of counterparties eligible to post/receive collateral — collateral-relationship coverage."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_counterparty_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Current and stressed counterparty exposure for OTC derivative risk management."
  source: "`asset_management`.`collateral`.`exposure`"
  dimensions:
    - name: "Exposure Type"
      display_name: "Exposure type"
      expr: exposure_type
      comment: "Type"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Counterparties"
      display_name: "Counterparties"
      expr: COUNT(DISTINCT counterparty_id)
      comment: "Counterparties"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_counterparty_rating_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Credit quality distribution of counterparties for concentration risk oversight."
  source: "`asset_management`.`collateral`.`counterparty_rating`"
  dimensions:
    - name: "Rating Agency"
      display_name: "Rating agency"
      expr: rating_agency
      comment: "Agency"
  measures:
    - name: "Rated Counterparties"
      display_name: "Rated counterparties"
      expr: COUNT(1)
      comment: "Ratings"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_counterparty_stress_impact`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stress-scenario loss impact on counterparty exposures for resilience assessment."
  source: "`asset_management`.`collateral`.`counterparty_stress_result`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Stress Results"
      display_name: "Stress results"
      expr: COUNT(1)
      comment: "Results"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_credit_limit_breach`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Credit-limit breach KPIs: breach volume, severity, resolution timeliness and magnitude. Used by Risk and Compliance to steer counterparty limit discipline and SOX control attestation."
  source: "`asset_management`.`collateral`.`credit_limit_breach`"
  dimensions:
    - name: "Breach Severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity classification of the breach (low/medium/high/critical)."
    - name: "Credit Limit Breach Status"
      display_name: "Breach Status"
      expr: credit_limit_breach_status
      comment: "Current status of the breach record."
    - name: "Currency Code"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Currency of the breach amount."
    - name: "Breach Month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_timestamp)
      comment: "Month bucket of the breach event for trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Breach Count"
      display_name: "Breach Count"
      expr: COUNT(1)
      comment: "Total number of credit-limit breaches — core risk-control KPI tracked on steering dashboards."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Breach Amount"
      display_name: "Total Breach Amount"
      expr: SUM(CAST(breach_amount AS DOUBLE))
      comment: "Aggregate monetary amount exceeding limits — magnitude of limit excess requiring remediation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Breach Percentage"
      display_name: "Avg Breach %"
      expr: AVG(CAST(breach_percentage AS DOUBLE))
      comment: "Average percentage by which limits were breached — severity gauge independent of absolute size."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Resolved Breach Rate"
      display_name: "Resolved Breach Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN breach_resolved_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of breaches resolved — remediation effectiveness and control health for SOX."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Open Breach Count"
      display_name: "Open Breach Count"
      expr: COUNT(CASE WHEN breach_resolved_flag = FALSE THEN 1 END)
      comment: "Number of unresolved breaches — open-risk backlog requiring leadership intervention."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_credit_limit_breach_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Counterparty credit-limit breaches and exceedance amounts."
  source: "`asset_management`.`collateral`.`credit_limit_breach`"
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
    - name: "Total Exceedance"
      display_name: "Total exceedance"
      expr: SUM(CAST(breach_amount AS DOUBLE))
      comment: "Exceedance"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_credit_limit_utilization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Utilization of approved counterparty credit limits for exposure governance."
  source: "`asset_management`.`collateral`.`credit_limit`"
  dimensions:
    - name: "Limit Type"
      display_name: "Limit type"
      expr: limit_type
      comment: "Type"
  measures:
    - name: "Total Limit"
      display_name: "Total limit"
      expr: SUM(CAST(limit_amount AS DOUBLE))
      comment: "Limit"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Limits"
      display_name: "Limits"
      expr: COUNT(1)
      comment: "Limits"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_emir_trade_reporting`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "EMIR derivative trade reporting volume and submission status for regulatory compliance."
  source: "`asset_management`.`collateral`.`emir_trade_report`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: report_status
      comment: "Status"
  measures:
    - name: "Reports"
      display_name: "Reports"
      expr: COUNT(1)
      comment: "Reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reported %"
      display_name: "Reported %"
      expr: ROUND(100.0 * SUM(CASE WHEN report_status = 'SUBMITTED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Submitted share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Counterparty credit-exposure KPIs: gross/net exposure, collateralization, residual exposure after collateral, and risk metrics (VaR/CVaR/DV01). Used by Risk and CRO to monitor counterparty credit risk and collateral efficiency."
  source: "`asset_management`.`collateral`.`exposure`"
  dimensions:
    - name: "Exposure Type"
      display_name: "Exposure Type"
      expr: exposure_type
      comment: "Type of exposure (derivative, repo, securities lending, etc.)."
    - name: "Exposure Status"
      display_name: "Exposure Status"
      expr: exposure_status
      comment: "Lifecycle status of the exposure record."
    - name: "Currency Code"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Reporting currency of the exposure."
    - name: "Risk Factor"
      display_name: "Risk Factor"
      expr: risk_factor
      comment: "Primary risk factor driving the exposure."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the exposure valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Gross Exposure USD"
      display_name: "Total Gross Exposure (USD)"
      expr: SUM(CAST(gross_exposure_usd AS DOUBLE))
      comment: "Aggregate gross counterparty exposure in USD before netting/collateral — headline credit-risk magnitude."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Exposure USD"
      display_name: "Total Net Exposure (USD)"
      expr: SUM(CAST(net_exposure_usd AS DOUBLE))
      comment: "Aggregate net exposure in USD after netting — post-agreement credit exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Collateral Held USD"
      display_name: "Total Collateral Held (USD)"
      expr: SUM(CAST(collateral_usd AS DOUBLE))
      comment: "Aggregate collateral held in USD against exposures — mitigant coverage."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Residual Exposure After Collateral"
      display_name: "Residual Exposure After Collateral"
      expr: SUM(CAST(net_exposure_after_collateral AS DOUBLE))
      comment: "Aggregate uncollateralized residual exposure — the true unsecured credit risk requiring action."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Collateralization Ratio"
      display_name: "Collateralization Ratio"
      expr: ROUND(100.0 * SUM(CAST(collateral_usd AS DOUBLE)) / NULLIF(SUM(CAST(gross_positive_exposure AS DOUBLE)), 0), 2)
      comment: "Collateral held as a percentage of gross positive exposure — collateral coverage efficiency; low values trigger margin calls."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total VaR"
      display_name: "Total VaR"
      expr: SUM(CAST(var AS DOUBLE))
      comment: "Aggregate value-at-risk across exposures — tail risk indicator for limit management."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total CVaR"
      display_name: "Total CVaR"
      expr: SUM(CAST(cvar AS DOUBLE))
      comment: "Aggregate conditional value-at-risk (expected shortfall) — severe-tail risk steering metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total DV01"
      display_name: "Total DV01"
      expr: SUM(CAST(dv01 AS DOUBLE))
      comment: "Aggregate interest-rate sensitivity (DV01) of exposures — rate-risk steering metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Margin Call Flag Rate"
      display_name: "Margin Call Flag Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN margin_call_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of exposures currently flagged for margin call — early-warning liquidity-demand indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_margin_call`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Margin call lifecycle KPIs: call volume, exposure amounts, settlement timeliness and dispute-prone activity. Used by Collateral Operations and Treasury to steer liquidity and operational SLA performance."
  source: "`asset_management`.`collateral`.`margin_call`"
  dimensions:
    - name: "Call Direction"
      display_name: "Call Direction"
      expr: call_direction
      comment: "Direction of the margin call (Call / Return) indicating whether collateral is received or posted."
    - name: "Margin Type"
      display_name: "Margin Type"
      expr: margin_type
      comment: "Type of margin (initial / variation) driving the call."
    - name: "Margin Call Status"
      display_name: "Margin Call Status"
      expr: margin_call_status
      comment: "Processing status of the margin call (open, settled, disputed, cancelled)."
    - name: "Collateral Currency"
      display_name: "Collateral Currency"
      expr: collateral_currency
      comment: "Currency in which collateral for the call is denominated."
    - name: "Call Month"
      display_name: "Call Month"
      expr: DATE_TRUNC('month', call_date)
      comment: "Month bucket of the margin call date for time-intelligence trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Call Year"
      display_name: "Call Year"
      expr: DATE_TRUNC('year', call_date)
      comment: "Year bucket of the margin call date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Margin Call Count"
      display_name: "Margin Call Count"
      expr: COUNT(1)
      comment: "Total number of margin calls — baseline activity volume for ops capacity planning."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Call Amount"
      display_name: "Total Call Amount"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Aggregate gross margin call amount demanded — key liquidity-demand indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Call Amount"
      display_name: "Total Net Call Amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Aggregate net (post-offset) margin call amount — true net collateral movement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Call Amount"
      display_name: "Avg Call Amount"
      expr: AVG(CAST(call_amount AS DOUBLE))
      comment: "Average size of a margin call — detects outsized exposure events."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Collateral Amount"
      display_name: "Total Collateral Amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral delivered against calls — measures coverage of demanded margin."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Processed Call Count"
      display_name: "Processed Call Count"
      expr: COUNT(CASE WHEN call_processed_flag = TRUE THEN 1 END)
      comment: "Number of margin calls successfully processed — basis for settlement-rate SLA."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Processed Call Rate"
      display_name: "Processed Call Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN call_processed_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of margin calls processed — operational throughput and SLA health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Call Amount CM"
      display_name: "Total Call Amount (Current Month)"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Current-month total margin call amount for MoM trending."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Call Month
          range: current
          semiadditive: last
    - name: "Total Call Amount PM"
      display_name: "Total Call Amount (Prior Month)"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Prior-month total margin call amount for MoM trending."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Call Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Call Amount MoM"
      display_name: "Call Amount MoM %"
      expr: (AGG(`Total Call Amount CM`) - AGG(`Total Call Amount PM`)) / NULLIF(AGG(`Total Call Amount PM`), 0)
      comment: "Month-over-month growth in margin call demand — liquidity trend signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_margin_call_settlement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Margin call volume, amounts, and settlement timeliness in collateral operations."
  source: "`asset_management`.`collateral`.`margin_call`"
  dimensions:
    - name: "Call Direction"
      display_name: "Call direction"
      expr: call_direction
      comment: "Direction"
  measures:
    - name: "Total Call Amount"
      display_name: "Total call amount"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Call amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Calls"
      display_name: "Calls"
      expr: COUNT(1)
      comment: "Calls"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_margin_dispute`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Margin-dispute KPIs: disputed amount, resolution magnitude and resolution efficiency. Used by Collateral Ops to steer dispute reduction and counterparty valuation alignment."
  source: "`asset_management`.`collateral`.`margin_dispute`"
  dimensions:
    - name: "Dispute Reason"
      display_name: "Dispute Reason"
      expr: dispute_reason
      comment: "Reason category for the margin dispute."
    - name: "Margin Dispute Status"
      display_name: "Dispute Status"
      expr: margin_dispute_status
      comment: "Current status of the dispute."
    - name: "Resolution Status"
      display_name: "Resolution Status"
      expr: resolution_status
      comment: "Resolution outcome status of the dispute."
    - name: "Dispute Month"
      display_name: "Dispute Month"
      expr: DATE_TRUNC('month', dispute_date)
      comment: "Month bucket of the dispute date for trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Dispute Count"
      display_name: "Dispute Count"
      expr: COUNT(1)
      comment: "Total margin disputes — operational-friction and counterparty-alignment KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Disputed Amount"
      display_name: "Total Disputed Amount"
      expr: SUM(CAST(disputed_amount AS DOUBLE))
      comment: "Aggregate value in dispute — magnitude of collateral uncertainty requiring resolution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Resolution Amount"
      display_name: "Total Resolution Amount"
      expr: SUM(CAST(resolution_amount AS DOUBLE))
      comment: "Aggregate agreed resolution amount — settled portion of disputed collateral."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Haircut Dispute Rate"
      display_name: "Haircut Dispute Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN haircut_dispute_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of disputes driven by haircut disagreements — collateral-schedule alignment indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_margin_dispute_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Collateral margin disputes and amounts in dispute for operational risk tracking."
  source: "`asset_management`.`collateral`.`margin_dispute`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Disputes"
      display_name: "Disputes"
      expr: COUNT(1)
      comment: "Disputes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Disputed Amount"
      display_name: "Total disputed amount"
      expr: SUM(CAST(disputed_amount AS DOUBLE))
      comment: "Disputed"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Collateral inventory and valuation KPIs: market value, haircut-adjusted net value, eligibility and haircut severity by asset type. Used by Collateral Management to optimize collateral quality and funding cost."
  source: "`asset_management`.`collateral`.`collateral_position`"
  dimensions:
    - name: "Asset Type"
      display_name: "Asset Type"
      expr: asset_type
      comment: "Asset class of the collateral position (govvie, corporate, equity, cash)."
    - name: "Collateral Type"
      display_name: "Collateral Type"
      expr: collateral_type
      comment: "Collateral classification of the position."
    - name: "Collateral Position Status"
      display_name: "Collateral Position Status"
      expr: collateral_position_status
      comment: "Lifecycle status of the collateral position."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency denomination of the collateral position."
    - name: "Position Month"
      display_name: "Position Month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Month bucket of the position date for balance trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Market Value"
      display_name: "Total Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Aggregate gross market value of collateral positions — headline collateral inventory."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Market Value"
      display_name: "Total Net Market Value"
      expr: SUM(CAST(net_market_value AS DOUBLE))
      comment: "Aggregate haircut-adjusted net collateral value — usable collateral after risk discounts."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Haircut Percent"
      display_name: "Avg Haircut %"
      expr: AVG(CAST(haircut_percent AS DOUBLE))
      comment: "Average haircut applied across positions — collateral quality and funding-cost indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Eligible Collateral Rate"
      display_name: "Eligible Collateral Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN eligible_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of positions that are eligible collateral — collateral-pool quality indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN regulatory_reportable_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of positions that are regulatory-reportable — compliance coverage monitoring."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Closing Net Market Value"
      display_name: "Closing Net Market Value"
      expr: SUM(CAST(net_market_value AS DOUBLE))
      comment: "Closing (period-end) net collateral value — semi-additive balance, never summed across time."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Position Month
          range: current
          semiadditive: last
    - name: "Opening Net Market Value"
      display_name: "Opening Net Market Value"
      expr: SUM(CAST(net_market_value AS DOUBLE))
      comment: "Opening (period-start) net collateral value — semi-additive balance for period change."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Position Month
          range: current
          semiadditive: first
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_posting`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Collateral postings supporting CSA obligations across counterparties."
  source: "`asset_management`.`collateral`.`posting`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Postings"
      display_name: "Postings"
      expr: COUNT(1)
      comment: "Postings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_recall_volume`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Collateral recall activity volume and value for collateral optimization."
  source: "`asset_management`.`collateral`.`recall`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: recall_status
      comment: "Status"
  measures:
    - name: "Recalls"
      display_name: "Recalls"
      expr: COUNT(1)
      comment: "Recalls"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_repo_financing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Repo and reverse-repo activity used for liquidity and leverage management."
  source: "`asset_management`.`collateral`.`repo_transaction`"
  dimensions:
    - name: "Repo Type"
      display_name: "Repo type"
      expr: repo_type
      comment: "Type"
  measures:
    - name: "Principal"
      display_name: "Principal"
      expr: SUM(CAST(principal_amount AS DOUBLE))
      comment: "Principal"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Transactions"
      display_name: "Transactions"
      expr: COUNT(1)
      comment: "Trades"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_repo_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Repo financing KPIs: principal/collateral value, haircut, repo rate and margin amounts. Used by Treasury/Funding to steer secured-financing cost and collateral utilization."
  source: "`asset_management`.`collateral`.`repo_transaction`"
  dimensions:
    - name: "Repo Type"
      display_name: "Repo Type"
      expr: repo_type
      comment: "Type of repo (classic repo, reverse repo, tri-party)."
    - name: "Collateral Type"
      display_name: "Collateral Type"
      expr: collateral_type
      comment: "Collateral class backing the repo."
    - name: "Repo Transaction Status"
      display_name: "Repo Status"
      expr: repo_transaction_status
      comment: "Lifecycle status of the repo transaction."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Transaction currency of the repo."
    - name: "Trade Month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_date)
      comment: "Month bucket of the repo trade date for trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Principal Amount"
      display_name: "Total Principal Amount"
      expr: SUM(CAST(principal_amount AS DOUBLE))
      comment: "Aggregate repo principal financed — secured-funding book size."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Collateral Value"
      display_name: "Total Collateral Value"
      expr: SUM(CAST(collateral_value AS DOUBLE))
      comment: "Aggregate collateral pledged against repos — collateral consumption."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Repo Rate"
      display_name: "Avg Repo Rate"
      expr: AVG(CAST(repo_rate AS DOUBLE))
      comment: "Average repo financing rate — cost-of-funding steering metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Haircut Percent"
      display_name: "Avg Haircut %"
      expr: AVG(CAST(haircut_percent AS DOUBLE))
      comment: "Average haircut applied to repo collateral — over-collateralization and funding efficiency."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Overcollateralization Ratio"
      display_name: "Overcollateralization Ratio"
      expr: ROUND(100.0 * SUM(CAST(collateral_value AS DOUBLE)) / NULLIF(SUM(CAST(principal_amount AS DOUBLE)), 0), 2)
      comment: "Collateral value as a percentage of principal — secured-financing coverage efficiency."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Variation Margin"
      display_name: "Total Variation Margin"
      expr: SUM(CAST(variation_margin_amount AS DOUBLE))
      comment: "Aggregate variation margin on repos — daily collateral movement driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Open Repo Count"
      display_name: "Open Repo Count"
      expr: COUNT(CASE WHEN is_open = TRUE THEN 1 END)
      comment: "Number of currently open repo transactions — active funding exposure count."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_securities_lending_income`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view: no designed measure survived the column checks"
  source: "`asset_management`.`collateral`.`securities_lending`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Row Count"
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_simm_calculation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SIMM initial-margin KPIs: initial margin posted, net margin, margin factor and call-required share by risk class and regulatory framework. Used by Risk/Collateral to steer IM funding under EMIR/UMR."
  source: "`asset_management`.`collateral`.`simm_calculation`"
  dimensions:
    - name: "Risk Class"
      display_name: "Risk Class"
      expr: risk_class
      comment: "SIMM risk class (rates, credit, equity, commodity, FX)."
    - name: "Margin Type"
      display_name: "Margin Type"
      expr: margin_type
      comment: "Margin type for the calculation."
    - name: "Regulatory Framework"
      display_name: "Regulatory Framework"
      expr: regulatory_framework
      comment: "Regulatory framework governing the SIMM calculation."
    - name: "Margin Currency"
      display_name: "Margin Currency"
      expr: margin_currency
      comment: "Currency of the initial margin amount."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the SIMM valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Initial Margin"
      display_name: "Total Initial Margin"
      expr: SUM(CAST(initial_margin_amount AS DOUBLE))
      comment: "Aggregate SIMM initial margin — uncleared-margin funding requirement under UMR."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Margin"
      display_name: "Total Net Margin"
      expr: SUM(CAST(net_margin_amount AS DOUBLE))
      comment: "Aggregate net margin after adjustments — net collateral funding impact."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Margin Factor"
      display_name: "Avg Margin Factor"
      expr: AVG(CAST(margin_factor AS DOUBLE))
      comment: "Average margin scaling factor applied — model-conservatism indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Margin Call Required Rate"
      display_name: "Margin Call Required Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN margin_call_required = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of SIMM calculations triggering a margin call — forward liquidity-demand signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Override Rate"
      display_name: "Override Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_override = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of SIMM calculations manually overridden — model-governance and control indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`collateral_simm_initial_margin`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ISDA SIMM initial margin requirements for non-cleared derivatives."
  source: "`asset_management`.`collateral`.`simm_calculation`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Total Initial Margin"
      display_name: "Total initial margin"
      expr: SUM(CAST(initial_margin_amount AS DOUBLE))
      comment: "IM"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Calculations"
      display_name: "Calculations"
      expr: COUNT(1)
      comment: "Calcs"
      format:
        type: number
        decimal_places:
          type: all
$$;
