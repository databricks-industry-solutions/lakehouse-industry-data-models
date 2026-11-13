-- Metric views for domain: risk | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_strategy_backtest_result`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over strategy backtest simulation results. Provides risk managers and CIOs with actionable views of simulated drawdown, P&L, and return performance across strategies, sample types, and time periods — enabling capital allocation, risk limit calibration, and strategy selection decisions."
  source: "`asset_management`.`risk`.`strategy_backtest_result`"
  parameters:
    - name: p_drawdown_alert_threshold
      data_type: DOUBLE
      default: -15.0
    - name: p_return_hurdle_rate
      data_type: DOUBLE
      default: 7.0
  dimensions:
    - name: "Strategy Name"
      display_name: "Strategy Name"
      expr: strategy_name
      comment: "Name of the investment strategy being backtested — primary slicer for strategy-level performance comparison."
    - name: "Sample Type"
      display_name: "Sample Type"
      expr: sample_type
      comment: "Classification of the backtest sample (e.g., in-sample, out-of-sample, walk-forward) — critical for assessing overfitting risk."
    - name: "Period End Year"
      display_name: "Period End Year"
      expr: DATE_TRUNC('year', period_end_date)
      comment: "Year bucket of the backtest period end date — used for annual trend analysis and YoY comparisons."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Quarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', period_end_date)
      comment: "Quarter bucket of the backtest period end date — used for quarterly performance reviews."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Month bucket of the backtest period end date — used for monthly trend analysis and MoM comparisons."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: DATE_TRUNC('year', vintage_date)
      comment: "Year bucket of the strategy vintage date — enables cohort analysis of strategies by inception year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Avg Simulated Return Pct"
      display_name: "Avg Simulated Return (%)"
      expr: AVG(CAST(simulated_return_percent AS DOUBLE))
      comment: "Average simulated return percentage across backtest observations. Core KPI for evaluating whether a strategy meets the pension fund's long-term return hurdle rate."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Simulated Drawdown Pct"
      display_name: "Avg Simulated Drawdown (%)"
      expr: AVG(CAST(simulated_drawdown_percent AS DOUBLE))
      comment: "Average simulated drawdown percentage — measures typical peak-to-trough loss. Critical for risk limit calibration and capital preservation mandates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Worst Simulated Drawdown Pct"
      display_name: "Worst Simulated Drawdown (%)"
      expr: MIN(CAST(simulated_drawdown_percent AS DOUBLE))
      comment: "Worst (most negative) simulated drawdown percentage across all backtest observations. Tail-risk indicator used in stress testing and risk limit setting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Best Simulated Return Pct"
      display_name: "Best Simulated Return (%)"
      expr: MAX(CAST(simulated_return_percent AS DOUBLE))
      comment: "Maximum simulated return percentage — captures upside potential of the strategy across all backtest periods."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Simulated PnL"
      display_name: "Total Simulated P&L ($)"
      expr: SUM(CAST(simulated_pnl_amount AS DOUBLE))
      comment: "Aggregate simulated profit and loss across all backtest observations. Provides a dollar-denominated view of strategy value generation for capital allocation decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Simulated PnL"
      display_name: "Avg Simulated P&L ($)"
      expr: AVG(CAST(simulated_pnl_amount AS DOUBLE))
      comment: "Average simulated P&L per backtest observation — normalizes for observation count to enable fair cross-strategy comparison."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Backtest Observation Count"
      display_name: "Backtest Observation Count"
      expr: COUNT(1)
      comment: "Number of backtest simulation observations. Used to assess statistical significance of return and drawdown estimates — low counts signal unreliable backtests."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Strategy Count"
      display_name: "Distinct Strategy Count"
      expr: COUNT(DISTINCT strategy_name)
      comment: "Number of distinct strategies represented in the backtest dataset. Tracks breadth of strategy coverage under evaluation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Return Hurdle Breach Count"
      display_name: "Return Hurdle Breach Count"
      expr: COUNT(CASE WHEN CAST(simulated_return_percent AS DOUBLE) < p_return_hurdle_rate THEN 1 END)
      comment: "Number of backtest observations where simulated return fell below the configured hurdle rate (default 7%). Directly informs strategy viability assessment against pension liability benchmarks."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Drawdown Alert Breach Count"
      display_name: "Drawdown Alert Breach Count"
      expr: COUNT(CASE WHEN CAST(simulated_drawdown_percent AS DOUBLE) < p_drawdown_alert_threshold THEN 1 END)
      comment: "Number of backtest observations where simulated drawdown exceeded the configured alert threshold (default -15%). Flags strategies with unacceptable tail-risk profiles."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Return CM"
      display_name: "Avg Simulated Return (Current Month)"
      expr: AVG(CAST(simulated_return_percent AS DOUBLE))
      comment: "Average simulated return for the current month bucket — base measure for MoM return trend analysis."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Period End Month
          range: current
          semiadditive: last
    - name: "Avg Return PM"
      display_name: "Avg Simulated Return (Prior Month)"
      expr: AVG(CAST(simulated_return_percent AS DOUBLE))
      comment: "Average simulated return for the prior month bucket — used as denominator in MoM return growth calculation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Period End Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Return MoM Growth"
      display_name: "Return MoM Growth (%)"
      expr: (AGG(`Avg Return CM`) - AGG(`Avg Return PM`)) / NULLIF(AGG(`Avg Return PM`), 0)
      comment: "Month-over-month change in average simulated return — tracks momentum and regime shifts in strategy performance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Return CY"
      display_name: "Avg Simulated Return (Current Year)"
      expr: AVG(CAST(simulated_return_percent AS DOUBLE))
      comment: "Average simulated return for the current year bucket — base measure for YoY return trend analysis."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Period End Year
          range: current
          semiadditive: last
    - name: "Avg Return PY"
      display_name: "Avg Simulated Return (Prior Year)"
      expr: AVG(CAST(simulated_return_percent AS DOUBLE))
      comment: "Average simulated return for the prior year bucket — used as denominator in YoY return growth calculation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Period End Year
          range: current
          semiadditive: last
          offset: -1 year
    - name: "Return YoY Growth"
      display_name: "Return YoY Growth (%)"
      expr: (AGG(`Avg Return CY`) - AGG(`Avg Return PY`)) / NULLIF(AGG(`Avg Return PY`), 0)
      comment: "Year-over-year change in average simulated return — key strategic KPI for assessing whether strategy performance is improving or deteriorating over annual cycles."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rolling 3M Avg Return"
      display_name: "Rolling 3-Month Avg Simulated Return"
      expr: AGG(`Avg Simulated Return Pct`)
      comment: "3-month rolling average of simulated return — smooths short-term noise to reveal medium-term strategy performance trends."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Period End Month
          range: trailing 3 month inclusive
          semiadditive: last
    - name: "Strategy PnL by Sample Type"
      display_name: "Strategy P&L by Sample Type ($)"
      expr: SUM(CAST(simulated_pnl_amount AS DOUBLE))
      comment: "Total simulated P&L segmented by sample type — enables comparison of in-sample vs out-of-sample P&L to detect overfitting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      partition:
        include: [Sample Type]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_factor_ic_correlation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over factor information coefficient (IC) correlation data. Enables risk managers and quantitative analysts to monitor factor redundancy, diversification quality, and correlation regime shifts — directly informing factor model construction, risk decomposition, and portfolio hedging decisions."
  source: "`asset_management`.`risk`.`factor_ic_correlation`"
  parameters:
    - name: p_high_correlation_threshold
      data_type: DOUBLE
      default: 0.7
    - name: p_lookback_days_filter
      data_type: BIGINT
      default: 252
  dimensions:
    - name: "Lookback Period Days"
      display_name: "Lookback Period (Days)"
      expr: lookback_period_days
      comment: "Number of calendar days in the lookback window used to compute the IC correlation — enables comparison across short, medium, and long-horizon factor relationships."
    - name: "Period End Year"
      display_name: "Period End Year"
      expr: DATE_TRUNC('year', period_end_date)
      comment: "Year bucket of the correlation observation period end date — used for annual trend analysis of factor correlation regimes."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Quarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', period_end_date)
      comment: "Quarter bucket of the correlation observation period end date — used for quarterly factor model reviews."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Month bucket of the correlation observation period end date — used for monthly correlation regime monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Avg Factor IC Correlation"
      display_name: "Avg Factor IC Correlation"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average pairwise IC correlation across all factor pairs. Measures overall factor redundancy in the model — high values signal that factors are not providing independent risk signals, reducing diversification."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Max Factor IC Correlation"
      display_name: "Max Factor IC Correlation"
      expr: MAX(CAST(correlation_value AS DOUBLE))
      comment: "Maximum pairwise IC correlation observed. Identifies the most redundant factor pair — a value near 1.0 signals a candidate for factor consolidation or removal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Min Factor IC Correlation"
      display_name: "Min Factor IC Correlation"
      expr: MIN(CAST(correlation_value AS DOUBLE))
      comment: "Minimum pairwise IC correlation observed. Identifies the most orthogonal factor pair — near -1.0 values may indicate natural hedging opportunities."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "High Correlation Pair Count"
      display_name: "High Correlation Pair Count"
      expr: COUNT(CASE WHEN ABS(CAST(correlation_value AS DOUBLE)) >= p_high_correlation_threshold THEN 1 END)
      comment: "Number of factor pairs with absolute IC correlation at or above the configured high-correlation threshold (default 0.7). Directly measures factor model redundancy — high counts trigger factor pruning reviews."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Factor Pair Observations"
      display_name: "Total Factor Pair Observations"
      expr: COUNT(1)
      comment: "Total number of factor pair correlation observations. Used to assess statistical coverage of the factor correlation matrix — low counts signal incomplete factor model monitoring."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Factor Pair Count"
      display_name: "Distinct Factor Pairs Monitored"
      expr: COUNT(DISTINCT CONCAT(CAST(factor_id AS STRING), '_', CAST(paired_factor_id AS STRING)))
      comment: "Number of distinct factor pairs being monitored for IC correlation. Tracks breadth of factor interaction coverage in the risk model."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg IC Correlation CM"
      display_name: "Avg IC Correlation (Current Month)"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average IC correlation for the current month bucket — base measure for MoM correlation regime change analysis."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Month
          range: current
          semiadditive: last
    - name: "Avg IC Correlation PM"
      display_name: "Avg IC Correlation (Prior Month)"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average IC correlation for the prior month bucket — used as denominator in MoM correlation change calculation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "IC Correlation MoM Change"
      display_name: "IC Correlation MoM Change"
      expr: AGG(`Avg IC Correlation CM`) - AGG(`Avg IC Correlation PM`)
      comment: "Month-over-month absolute change in average IC correlation — detects correlation regime shifts that may require factor model rebalancing or hedging adjustments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg IC Correlation CY"
      display_name: "Avg IC Correlation (Current Year)"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average IC correlation for the current year bucket — base measure for YoY correlation regime analysis."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Year
          range: current
          semiadditive: last
    - name: "Avg IC Correlation PY"
      display_name: "Avg IC Correlation (Prior Year)"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average IC correlation for the prior year bucket — used as denominator in YoY correlation change calculation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Year
          range: current
          semiadditive: last
          offset: -1 year
    - name: "IC Correlation YoY Change"
      display_name: "IC Correlation YoY Change"
      expr: AGG(`Avg IC Correlation CY`) - AGG(`Avg IC Correlation PY`)
      comment: "Year-over-year absolute change in average IC correlation — strategic KPI for detecting structural shifts in factor relationships across market cycles."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Rolling 3M Avg IC Correlation"
      display_name: "Rolling 3-Month Avg IC Correlation"
      expr: AGG(`Avg Factor IC Correlation`)
      comment: "3-month rolling average IC correlation — smooths monthly noise to reveal medium-term factor redundancy trends used in quarterly risk model reviews."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Month
          range: trailing 3 month inclusive
          semiadditive: last
    - name: "High Corr Pair Pct"
      display_name: "High Correlation Pair Rate (%)"
      expr: 100.0 * COUNT(CASE WHEN ABS(CAST(correlation_value AS DOUBLE)) >= p_high_correlation_threshold THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "Percentage of factor pairs with absolute IC correlation at or above the high-correlation threshold. Normalizes for observation count — the primary factor model health KPI for risk governance reporting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "IC Correlation by Lookback Segment"
      display_name: "Avg IC Correlation by Lookback Segment"
      expr: AVG(CAST(correlation_value AS DOUBLE))
      comment: "Average IC correlation segmented by lookback period — enables comparison of short-horizon vs long-horizon factor relationships to detect horizon-dependent redundancy."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      partition:
        include: [Lookback Period Days]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_concentration_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Concentration exposure KPIs — exposure magnitude, limit utilization, breaches and tail-risk contributions. Single-source over risk.concentration_exposure."
  source: "`asset_management`.`risk`.`concentration_exposure`"
  dimensions:
    - name: "Measurement Month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month bucket of measurement date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the exposure."
    - name: "Concentration Dimension"
      display_name: "Concentration Dimension"
      expr: concentration_dimension
      comment: "Dimension along which concentration is measured (issuer, sector, region, etc.)."
    - name: "Breach Status"
      display_name: "Breach Status"
      expr: breach_status
      comment: "Breach status of the concentration limit."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the exposure."
    - name: "Sector Classification"
      display_name: "Sector Classification"
      expr: sector_classification
      comment: "Sector classification of the exposure."
  measures:
    - name: "Exposure Record Count"
      display_name: "Exposure Record Count"
      expr: COUNT(1)
      comment: "Number of concentration exposure rows; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Exposure Amount"
      display_name: "Total Exposure Amount"
      expr: SUM(CAST(exposure_amount AS DOUBLE))
      comment: "Aggregate concentration exposure; headline position-risk KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Exposure Percentage"
      display_name: "Avg Exposure Percentage"
      expr: AVG(CAST(exposure_percentage AS DOUBLE))
      comment: "Average exposure as percent of NAV; normalized concentration indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Breach Amount"
      display_name: "Total Breach Amount"
      expr: SUM(CAST(breach_amount AS DOUBLE))
      comment: "Aggregate amount over concentration limits; sizing of concentration failures."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Required Count"
      display_name: "Escalation Required Count"
      expr: COUNT(CASE WHEN escalation_required_flag = TRUE THEN 1 END)
      comment: "Exposures requiring escalation; governance action KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total VaR Contribution"
      display_name: "Total VaR Contribution"
      expr: SUM(CAST(var_contribution AS DOUBLE))
      comment: "Aggregate VaR contribution of concentrated exposures; tail-risk steering."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Limit Threshold"
      display_name: "Avg Limit Threshold"
      expr: AVG(CAST(limit_threshold AS DOUBLE))
      comment: "Average concentration limit threshold; policy calibration reference."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_counterparty_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Counterparty credit exposure KPIs — net/gross exposure, CVA, expected loss, collateral coverage and wrong-way risk. Supports EMIR and AML oversight. Single-source over risk.risk_counterparty_exposure."
  source: "`asset_management`.`risk`.`risk_counterparty_exposure`"
  dimensions:
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the counterparty exposure."
    - name: "Counterparty Credit Rating"
      display_name: "Counterparty Credit Rating"
      expr: counterparty_credit_rating
      comment: "Credit rating of the counterparty."
    - name: "Clearing Status"
      display_name: "Clearing Status"
      expr: clearing_status
      comment: "Clearing status (cleared vs bilateral)."
    - name: "Exposure Type"
      display_name: "Exposure Type"
      expr: exposure_type
      comment: "Type of counterparty exposure."
  measures:
    - name: "Exposure Record Count"
      display_name: "Exposure Record Count"
      expr: COUNT(1)
      comment: "Number of counterparty exposure rows; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Exposure"
      display_name: "Total Net Exposure"
      expr: SUM(CAST(net_exposure_amount AS DOUBLE))
      comment: "Aggregate net counterparty exposure; headline credit-risk KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Exposure"
      display_name: "Total Gross Exposure"
      expr: SUM(CAST(gross_exposure_amount AS DOUBLE))
      comment: "Aggregate gross counterparty exposure before netting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Credit Valuation Adjustment"
      display_name: "Total Credit Valuation Adjustment"
      expr: SUM(CAST(credit_valuation_adjustment AS DOUBLE))
      comment: "Aggregate CVA; counterparty credit cost steering KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Expected Credit Loss"
      display_name: "Total Expected Credit Loss"
      expr: SUM(CAST(expected_credit_loss AS DOUBLE))
      comment: "Aggregate expected credit loss; provisioning and risk reserve input."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Collateral Held"
      display_name: "Total Collateral Held"
      expr: SUM(CAST(collateral_held_amount AS DOUBLE))
      comment: "Aggregate collateral held against exposures; coverage numerator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Wrong Way Risk Count"
      display_name: "Wrong Way Risk Count"
      expr: COUNT(CASE WHEN wrong_way_risk_flag = TRUE THEN 1 END)
      comment: "Count of exposures flagged for wrong-way risk; high-priority credit concern."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Counterparties"
      display_name: "Distinct Counterparties"
      expr: COUNT(DISTINCT counterparty_id)
      comment: "Number of distinct counterparties with exposure; concentration breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Probability Of Default"
      display_name: "Avg Probability Of Default"
      expr: AVG(CAST(probability_of_default AS DOUBLE))
      comment: "Average PD across counterparty exposures; portfolio credit quality indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_factor_ic_observation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over factor information-coefficient observations. Tracks the predictive quality of quantitative factor signals across holding periods, sectors, and time — a core input to quant research governance and factor allocation decisions."
  source: "`asset_management`.`risk`.`factor_ic_observation`"
  parameters:
    - name: p_min_universe_size
      data_type: BIGINT
      default: 100
    - name: p_ic_significance_threshold
      data_type: DOUBLE
      default: 0.05
  dimensions:
    - name: "Factor"
      display_name: "Factor ID"
      expr: factor_id
      comment: "The quantitative factor whose IC is being measured. Used to slice IC quality by individual factor."
    - name: "HoldingPeriodDays"
      display_name: "Holding Period (Days)"
      expr: holding_period_days
      comment: "Investment horizon for which the IC is computed: 1 (daily), 5 (weekly), 21 (monthly), or 63 (quarterly). Drives horizon-specific factor evaluation."
    - name: "SectorName"
      display_name: "Sector (GICS)"
      expr: sector_name
      comment: "GICS sector for which the IC is computed, or ALL for cross-sector aggregate. Enables sector-level factor efficacy analysis."
    - name: "PeriodEndDate"
      display_name: "Period End Date"
      expr: period_end_date
      comment: "The exact date on which the IC observation period ends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndYear"
      display_name: "Period End Year"
      expr: DATE_TRUNC('year', period_end_date)
      comment: "Year bucket of the IC observation period end date. Supports annual trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndQuarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', period_end_date)
      comment: "Quarter bucket of the IC observation period end date. Supports quarterly IC trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndMonth"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Month bucket of the IC observation period end date. Supports monthly IC trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "ICSignificant"
      display_name: "IC Significant (vs Threshold)"
      expr: CASE WHEN ABS(information_coefficient) >= p_ic_significance_threshold THEN 'Significant' ELSE 'Noise' END
      comment: "Classifies each IC observation as Significant or Noise relative to the p_ic_significance_threshold parameter. Supports filtering to actionable signals."
    - name: "ICDirection"
      display_name: "IC Direction"
      expr: CASE WHEN information_coefficient > 0 THEN 'Positive' WHEN information_coefficient < 0 THEN 'Negative' ELSE 'Zero' END
      comment: "Directional classification of the IC value. Positive IC means the factor signal correctly ranks securities; negative IC indicates inverse predictive power."
    - name: "UniverseSizeBand"
      display_name: "Universe Size Band"
      expr: CASE WHEN universe_size < 100 THEN 'Small (<100)' WHEN universe_size < 500 THEN 'Mid (100-499)' WHEN universe_size < 1000 THEN 'Large (500-999)' ELSE 'XLarge (1000+)' END
      comment: "Categorises the security universe size into bands. Larger universes generally produce more statistically reliable IC estimates."
  measures:
    - name: "ObservationCount"
      display_name: "IC Observation Count"
      expr: COUNT(1)
      comment: "Total number of IC observations. Baseline measure indicating data coverage across factors, periods, and sectors."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "AvgIC"
      display_name: "Average Information Coefficient"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Mean IC across selected observations. The primary measure of factor predictive quality; IC > 0.05 is generally considered economically meaningful for institutional quant strategies."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "ICIR"
      display_name: "IC Information Ratio (IC / StdDev IC)"
      expr: AVG(CAST(information_coefficient AS DOUBLE)) / NULLIF(STDDEV(CAST(information_coefficient AS DOUBLE)), 0)
      comment: "Information Coefficient Information Ratio: mean IC divided by its standard deviation. A key measure of factor signal consistency; ICIR > 0.5 indicates a reliable, persistent factor."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "ICStdDev"
      display_name: "IC Standard Deviation"
      expr: STDDEV(CAST(information_coefficient AS DOUBLE))
      comment: "Standard deviation of IC observations. High volatility in IC signals an unstable factor that may not be suitable for live deployment."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "MaxIC"
      display_name: "Maximum IC"
      expr: MAX(CAST(information_coefficient AS DOUBLE))
      comment: "Highest IC value observed. Indicates the best-case predictive performance of the factor under selected conditions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "MinIC"
      display_name: "Minimum IC"
      expr: MIN(CAST(information_coefficient AS DOUBLE))
      comment: "Lowest IC value observed. Indicates worst-case predictive performance; large negative values signal periods of factor reversal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "PositiveICRate"
      display_name: "Positive IC Hit Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN information_coefficient > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of IC observations that are positive. A hit rate above 50% indicates the factor more often predicts returns correctly than not — a key signal quality gate for quant PMs."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SignificantICRate"
      display_name: "Significant IC Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN ABS(information_coefficient) >= p_ic_significance_threshold THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of IC observations exceeding the significance threshold (p_ic_significance_threshold). Measures how frequently the factor produces actionable signals above the noise floor."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "AvgUniverseSize"
      display_name: "Average Universe Size"
      expr: AVG(CAST(universe_size AS DOUBLE))
      comment: "Mean number of securities in the evaluation universe. Larger universes improve IC statistical reliability; used to weight IC quality assessments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DistinctFactorCount"
      display_name: "Distinct Factor Count"
      expr: COUNT(DISTINCT factor_id)
      comment: "Number of unique factors with IC observations in the selected slice. Indicates breadth of the quant factor library being evaluated."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "AvgICCurrentMonth"
      display_name: "Avg IC — Current Month"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Average IC for the current calendar month. Used as the baseline for month-over-month IC trend analysis."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: PeriodEndMonth
          range: current
          semiadditive: last
    - name: "AvgICPriorMonth"
      display_name: "Avg IC — Prior Month"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Average IC for the prior calendar month. Paired with AvgICCurrentMonth to compute month-over-month IC change."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: PeriodEndMonth
          range: current
          semiadditive: last
          offset: -1 month
    - name: "AvgICMoMChange"
      display_name: "Avg IC MoM Change"
      expr: AGG(`AvgICCurrentMonth`) - AGG(`AvgICPriorMonth`)
      comment: "Absolute month-over-month change in average IC. A declining IC trend signals factor decay and may trigger a factor review or reweighting decision."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "AvgICCurrentQuarter"
      display_name: "Avg IC — Current Quarter"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Average IC for the current quarter. Baseline for quarterly IC trend analysis used in quant research governance reviews."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: PeriodEndQuarter
          range: current
          semiadditive: last
    - name: "AvgICPriorQuarter"
      display_name: "Avg IC — Prior Quarter"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Average IC for the prior quarter. Paired with AvgICCurrentQuarter to compute quarter-over-quarter IC change."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: PeriodEndQuarter
          range: current
          semiadditive: last
          offset: -3 months
    - name: "AvgICQoQChange"
      display_name: "Avg IC QoQ Change"
      expr: AGG(`AvgICCurrentQuarter`) - AGG(`AvgICPriorQuarter`)
      comment: "Absolute quarter-over-quarter change in average IC. Persistent QoQ decline is a leading indicator of factor obsolescence requiring quant research intervention."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Rolling3MAvgIC"
      display_name: "Rolling 3-Month Avg IC"
      expr: AGG(`AvgIC`)
      comment: "Three-month rolling average IC. Smooths short-term noise to reveal the underlying trend in factor predictive quality — the standard quant research monitoring metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      window:
        - order: PeriodEndMonth
          range: trailing 3 month inclusive
          semiadditive: last
    - name: "ICByHoldingPeriod"
      display_name: "Avg IC by Holding Period (Partition)"
      expr: AVG(CAST(information_coefficient AS DOUBLE))
      comment: "Average IC partitioned by holding period. Enables comparison of a factor's IC across 1/5/21/63-day horizons within the same query context — critical for horizon-specific factor allocation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
      partition:
        include: [HoldingPeriodDays]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_factor_signal_prediction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over factor signal directional predictions. Measures the real-world accuracy and return impact of quant factor signals at the security level — a critical input to factor model validation, signal decay analysis, and portfolio construction governance."
  source: "`asset_management`.`risk`.`factor_signal_prediction`"
  parameters:
    - name: p_min_signal_value
      data_type: DOUBLE
      default: 0.0
    - name: p_holding_period_filter
      data_type: BIGINT
      default: 21
  dimensions:
    - name: "Factor"
      display_name: "Factor ID"
      expr: factor_id
      comment: "The quantitative factor generating the directional prediction. Primary grouping key for factor-level accuracy analysis."
    - name: "Portfolio"
      display_name: "Portfolio ID"
      expr: portfolio_id
      comment: "The portfolio for which the signal prediction was generated. Enables portfolio-level signal quality attribution."
    - name: "PredictedDirection"
      display_name: "Predicted Direction"
      expr: predicted_direction
      comment: "The directional call made by the factor signal: long or short. Used to segment accuracy and return metrics by signal direction."
    - name: "DirectionCorrectFlag"
      display_name: "Direction Correct"
      expr: direction_correct_flag
      comment: "Boolean indicating whether the predicted direction matched the realized return direction. The primary accuracy dimension for signal validation."
    - name: "HoldingPeriodDays"
      display_name: "Holding Period (Days)"
      expr: holding_period_days
      comment: "Investment horizon for the prediction: 1, 5, 21, or 63 days. Accuracy and return metrics vary materially by horizon."
    - name: "PredictionDate"
      display_name: "Prediction Date"
      expr: prediction_date
      comment: "The exact date on which the directional prediction was made."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PredictionYear"
      display_name: "Prediction Year"
      expr: DATE_TRUNC('year', prediction_date)
      comment: "Year bucket of the prediction date. Supports annual signal accuracy trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PredictionQuarter"
      display_name: "Prediction Quarter"
      expr: DATE_TRUNC('quarter', prediction_date)
      comment: "Quarter bucket of the prediction date. Supports quarterly signal accuracy trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PredictionMonth"
      display_name: "Prediction Month"
      expr: DATE_TRUNC('month', prediction_date)
      comment: "Month bucket of the prediction date. Supports monthly signal accuracy trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "ReturnQuintile"
      display_name: "Realized Return Quintile"
      expr: CASE WHEN realized_return_percent <= -2.0 THEN 'Q1 (Worst)' WHEN realized_return_percent <= -0.5 THEN 'Q2' WHEN realized_return_percent <= 0.5 THEN 'Q3 (Flat)' WHEN realized_return_percent <= 2.0 THEN 'Q4' ELSE 'Q5 (Best)' END
      comment: "Quintile classification of realized return. Enables analysis of signal accuracy and value across the return distribution — key for understanding tail performance."
    - name: "SignalStrengthBand"
      display_name: "Signal Strength Band"
      expr: CASE WHEN ABS(signal_value) < 0.5 THEN 'Weak (<0.5)' WHEN ABS(signal_value) < 1.0 THEN 'Moderate (0.5-1.0)' WHEN ABS(signal_value) < 2.0 THEN 'Strong (1.0-2.0)' ELSE 'Very Strong (2.0+)' END
      comment: "Categorises signal magnitude into strength bands. Stronger signals should exhibit higher directional accuracy — this dimension validates that relationship."
  measures:
    - name: "PredictionCount"
      display_name: "Total Predictions"
      expr: COUNT(1)
      comment: "Total number of directional predictions. Baseline measure of signal coverage and data completeness."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DirectionalAccuracyRate"
      display_name: "Directional Accuracy Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of predictions where the directional call was correct. The primary signal quality KPI; rates above 55% are considered economically significant for institutional quant strategies."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "AvgRealizedReturn"
      display_name: "Average Realized Return (%)"
      expr: AVG(CAST(realized_return_percent AS DOUBLE))
      comment: "Mean realized return across all predictions in the selected slice. Measures the average economic outcome of the factor signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "AvgRealizedReturnCorrect"
      display_name: "Avg Realized Return — Correct Predictions (%)"
      expr: AVG(CASE WHEN direction_correct_flag = TRUE THEN CAST(realized_return_percent AS DOUBLE) END)
      comment: "Mean realized return for predictions where the direction was correct. Measures the economic value captured when the signal is right — a key input to signal value-at-risk models."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "AvgRealizedReturnIncorrect"
      display_name: "Avg Realized Return — Incorrect Predictions (%)"
      expr: AVG(CASE WHEN direction_correct_flag = FALSE THEN CAST(realized_return_percent AS DOUBLE) END)
      comment: "Mean realized return for predictions where the direction was wrong. Measures the economic cost of signal errors — critical for assessing net signal value after losses."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "AvgSignalValue"
      display_name: "Average Signal Value"
      expr: AVG(CAST(signal_value AS DOUBLE))
      comment: "Mean signal value (z-score or standardised score) across predictions. Tracks signal magnitude over time; declining average signal strength may indicate factor crowding or decay."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "LongPredictionRate"
      display_name: "Long Prediction Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN predicted_direction = 'long' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of predictions that are long-directional. Significant imbalance between long and short rates may indicate factor bias or market regime effects."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ShortPredictionAccuracyRate"
      display_name: "Short Prediction Accuracy Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN predicted_direction = 'short' AND direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN predicted_direction = 'short' THEN 1 ELSE 0 END), 0), 2)
      comment: "Directional accuracy rate for short-only predictions. Short-side accuracy is often lower in bull markets; monitoring this separately informs long/short factor weighting decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "LongPredictionAccuracyRate"
      display_name: "Long Prediction Accuracy Rate (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN predicted_direction = 'long' AND direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN predicted_direction = 'long' THEN 1 ELSE 0 END), 0), 2)
      comment: "Directional accuracy rate for long-only predictions. Compared against short accuracy to detect asymmetric signal quality across market directions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "DistinctSecurityCount"
      display_name: "Distinct Securities Covered"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Number of unique securities for which predictions were generated. Measures signal breadth; broader coverage reduces idiosyncratic risk in factor-based portfolios."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DistinctFactorCount"
      display_name: "Distinct Factors Active"
      expr: COUNT(DISTINCT factor_id)
      comment: "Number of unique factors generating predictions in the selected slice. Tracks factor library utilisation and diversification across the quant model."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "TotalRealizedReturn"
      display_name: "Total Realized Return (%)"
      expr: SUM(CAST(realized_return_percent AS DOUBLE))
      comment: "Sum of all realized returns across predictions. Used as the numerator in average return calculations and for aggregated P&L attribution at the factor level."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "SignalValueStdDev"
      display_name: "Signal Value Std Dev"
      expr: STDDEV(CAST(signal_value AS DOUBLE))
      comment: "Standard deviation of signal values. High dispersion indicates the factor is generating strongly differentiated views across securities — a prerequisite for effective long/short construction."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "DirectionalAccuracyCurrentMonth"
      display_name: "Directional Accuracy — Current Month (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Directional accuracy rate for the current calendar month. Baseline for month-over-month accuracy trend monitoring."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PredictionMonth
          range: current
          semiadditive: last
    - name: "DirectionalAccuracyPriorMonth"
      display_name: "Directional Accuracy — Prior Month (%)"
      expr: ROUND(100.0 * SUM(CASE WHEN direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Directional accuracy rate for the prior calendar month. Paired with DirectionalAccuracyCurrentMonth to compute MoM accuracy change."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PredictionMonth
          range: current
          semiadditive: last
          offset: -1 month
    - name: "DirectionalAccuracyMoMChange"
      display_name: "Directional Accuracy MoM Change (pp)"
      expr: AGG(`DirectionalAccuracyCurrentMonth`) - AGG(`DirectionalAccuracyPriorMonth`)
      comment: "Month-over-month change in directional accuracy in percentage points. A sustained decline triggers factor review; a sharp drop may indicate regime change or factor crowding."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Rolling3MDirectionalAccuracy"
      display_name: "Rolling 3-Month Directional Accuracy (%)"
      expr: AGG(`DirectionalAccuracyRate`)
      comment: "Three-month rolling directional accuracy rate. Smooths monthly noise to reveal the underlying trend in signal quality — the standard metric for quant factor governance reviews."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PredictionMonth
          range: trailing 3 month inclusive
          semiadditive: last
    - name: "AccuracyByFactor"
      display_name: "Directional Accuracy by Factor (Partition)"
      expr: ROUND(100.0 * SUM(CASE WHEN direction_correct_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Directional accuracy partitioned by factor. Enables within-query comparison of each factor's accuracy against the portfolio-level aggregate — critical for factor ranking and reweighting decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      partition:
        include: [Factor]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_limit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk limit governance KPIs — utilization, breach counts and active-limit coverage across portfolios and asset classes. Single-source over risk.limit."
  source: "`asset_management`.`risk`.`limit`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class the limit applies to."
    - name: "Limit Type"
      display_name: "Limit Type"
      expr: limit_type
      comment: "Type of risk limit."
    - name: "Limit Status"
      display_name: "Limit Status"
      expr: limit_status
      comment: "Status of the limit (active, suspended, expired)."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region scope of the limit."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Sector scope of the limit."
  measures:
    - name: "Limit Count"
      display_name: "Limit Count"
      expr: COUNT(1)
      comment: "Number of defined risk limits; governance coverage baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Utilization Percentage"
      display_name: "Avg Utilization Percentage"
      expr: AVG(CAST(utilization_percentage AS DOUBLE))
      comment: "Average limit utilization; headline risk-headroom KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Max Utilization Percentage"
      display_name: "Max Utilization Percentage"
      expr: MAX(CAST(utilization_percentage AS DOUBLE))
      comment: "Peak limit utilization; hotspot detection for the CRO."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Breaches YTD"
      display_name: "Total Breaches YTD"
      expr: SUM(CAST(breach_count_ytd AS DOUBLE))
      comment: "Aggregate year-to-date breaches across limits; control-effectiveness KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Limit Count"
      display_name: "Regulatory Limit Count"
      expr: COUNT(CASE WHEN regulatory_requirement_flag = TRUE THEN 1 END)
      comment: "Limits that are regulatory requirements; compliance-coverage KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Near Breach Limit Count"
      display_name: "Near Breach Limit Count"
      expr: COUNT(CASE WHEN utilization_percentage >= 90 THEN 1 END)
      comment: "Limits above 90% utilization; proactive intervention trigger."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_limit_breach`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Limit breach KPIs for risk governance — frequency, severity, regulatory breaches and remediation timeliness. Single-source over risk.limit_breach."
  source: "`asset_management`.`risk`.`limit_breach`"
  dimensions:
    - name: "Breach Month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_timestamp)
      comment: "Month bucket of breach occurrence."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Breach Severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity classification of the breach."
    - name: "Breach Status"
      display_name: "Breach Status"
      expr: breach_status
      comment: "Lifecycle status of the breach (open, remediated, etc.)."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class associated with the breach."
    - name: "Risk Metric Type"
      display_name: "Risk Metric Type"
      expr: risk_metric_type
      comment: "The risk metric type that was breached."
    - name: "Escalation Level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level assigned to the breach."
  measures:
    - name: "Breach Count"
      display_name: "Breach Count"
      expr: COUNT(1)
      comment: "Total number of limit breaches; core risk-governance volume KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Breach Count"
      display_name: "Regulatory Breach Count"
      expr: COUNT(CASE WHEN regulatory_breach_flag = TRUE THEN 1 END)
      comment: "Count of breaches flagged as regulatory; drives mandatory reporting and remediation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Intraday Breach Count"
      display_name: "Intraday Breach Count"
      expr: COUNT(CASE WHEN intraday_breach_flag = TRUE THEN 1 END)
      comment: "Breaches detected intraday; indicator of real-time control effectiveness."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Breach Percentage"
      display_name: "Avg Breach Percentage"
      expr: AVG(CAST(breach_percentage AS DOUBLE))
      comment: "Average percentage by which limits were exceeded; sizing of control failures."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Breach Magnitude"
      display_name: "Total Breach Magnitude"
      expr: SUM(CAST(breach_magnitude AS DOUBLE))
      comment: "Aggregate magnitude of limit excesses; exposure impact of breaches."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Breach Duration Minutes"
      display_name: "Avg Breach Duration Minutes"
      expr: AVG(CAST(breach_duration_minutes AS DOUBLE))
      comment: "Average time a breach remained open; remediation responsiveness KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "IC Review Required Count"
      display_name: "IC Review Required Count"
      expr: COUNT(CASE WHEN ic_review_required_flag = TRUE THEN 1 END)
      comment: "Breaches requiring Investment Committee review; governance workload indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Breach Count CM"
      display_name: "Breach Count CM"
      expr: COUNT(1)
      comment: "Current-month breach count for trend analysis."
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Breach Month
          range: current
          semiadditive: last
    - name: "Breach Count PM"
      display_name: "Breach Count PM"
      expr: COUNT(1)
      comment: "Prior-month breach count for trend analysis."
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Breach Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Breach Count MoM"
      display_name: "Breach Count MoM"
      expr: (AGG(`Breach Count CM`) - AGG(`Breach Count PM`)) / NULLIF(AGG(`Breach Count PM`), 0)
      comment: "Month-over-month change in breach frequency; control-trend steering KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_liquidity_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Liquidity risk KPIs — coverage ratios, days-to-liquidate, illiquid asset proportion and market impact cost. Critical for a long-duration pension liability profile. Single-source over risk.liquidity_risk_assessment."
  source: "`asset_management`.`risk`.`liquidity_risk_assessment`"
  dimensions:
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month bucket of assessment date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class under liquidity assessment."
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Status of the liquidity assessment."
    - name: "Breach Severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity of any liquidity limit breach."
    - name: "Liquidation Scenario"
      display_name: "Liquidation Scenario"
      expr: liquidation_scenario
      comment: "Liquidation scenario applied in the assessment."
  measures:
    - name: "Assessment Count"
      display_name: "Assessment Count"
      expr: COUNT(1)
      comment: "Number of liquidity assessments; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Liquidity Coverage Ratio"
      display_name: "Avg Liquidity Coverage Ratio"
      expr: AVG(CAST(liquidity_coverage_ratio AS DOUBLE))
      comment: "Average liquidity coverage ratio; core funding-resilience KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Days To Liquidate"
      display_name: "Avg Days To Liquidate"
      expr: AVG(CAST(days_to_liquidate AS DOUBLE))
      comment: "Average days required to liquidate; horizon-risk steering metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Illiquid Assets Value"
      display_name: "Total Illiquid Assets Value"
      expr: SUM(CAST(illiquid_assets_value AS DOUBLE))
      comment: "Aggregate illiquid asset value; liquidity-profile exposure KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liquid Assets Value"
      display_name: "Total Liquid Assets Value"
      expr: SUM(CAST(liquid_assets_value AS DOUBLE))
      comment: "Aggregate liquid asset value; cash-raising capacity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Market Impact Cost Bps"
      display_name: "Avg Market Impact Cost Bps"
      expr: AVG(CAST(market_impact_cost_bps AS DOUBLE))
      comment: "Average market impact cost of liquidation in bps; execution-risk indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Limit Breach Count"
      display_name: "Limit Breach Count"
      expr: COUNT(CASE WHEN limit_breach_flag = TRUE THEN 1 END)
      comment: "Count of liquidity limit breaches; governance trigger."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Required Count"
      display_name: "Escalation Required Count"
      expr: COUNT(CASE WHEN escalation_required_flag = TRUE THEN 1 END)
      comment: "Assessments requiring escalation; action KPI."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_stress_test_result`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stress testing outcome KPIs — stressed P&L, NAV impact, breaches under scenarios. Supports TCFD climate and regulatory stress reporting. Single-source over risk.stress_test_result."
  source: "`asset_management`.`risk`.`stress_test_result`"
  dimensions:
    - name: "Calculation Month"
      display_name: "Calculation Month"
      expr: DATE_TRUNC('month', calculation_date)
      comment: "Month bucket of the stress test calculation."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the stressed position."
    - name: "Breach Severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity of any breach triggered under the scenario."
    - name: "Test Status"
      display_name: "Test Status"
      expr: test_status
      comment: "Status of the stress test result."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the stressed exposure."
  measures:
    - name: "Stress Result Count"
      display_name: "Stress Result Count"
      expr: COUNT(1)
      comment: "Number of stress test result rows; coverage/volume baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Stressed PnL"
      display_name: "Total Stressed PnL"
      expr: SUM(CAST(stressed_pnl AS DOUBLE))
      comment: "Aggregate stressed profit/loss; headline scenario impact for the IC."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Stressed PnL Percentage"
      display_name: "Avg Stressed PnL Percentage"
      expr: AVG(CAST(stressed_pnl_percentage AS DOUBLE))
      comment: "Average stressed P&L as percent of value; normalized scenario severity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Base NAV"
      display_name: "Total Base NAV"
      expr: SUM(CAST(base_nav AS DOUBLE))
      comment: "Sum of base NAV pre-stress; denominator for NAV impact analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Stressed NAV"
      display_name: "Total Stressed NAV"
      expr: SUM(CAST(stressed_nav AS DOUBLE))
      comment: "Sum of NAV under stress; capital-preservation steering metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Breach Result Count"
      display_name: "Breach Result Count"
      expr: COUNT(CASE WHEN breach_flag = TRUE THEN 1 END)
      comment: "Count of stress results that breach limits; triggers rebalancing decisions."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rebalance Trigger Count"
      display_name: "Rebalance Trigger Count"
      expr: COUNT(CASE WHEN rebalance_trigger_flag = TRUE THEN 1 END)
      comment: "Stress results triggering rebalancing action; direct action KPI."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Concentration Risk Score"
      display_name: "Avg Concentration Risk Score"
      expr: AVG(CAST(concentration_risk_score AS DOUBLE))
      comment: "Average concentration risk score under stress; diversification oversight."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`risk_var_calculation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Value-at-Risk and CVaR KPIs used by the CRO and Investment Committee to monitor portfolio tail risk, diversification benefit, and regulatory capital. Single-source over risk.var_calculation."
  source: "`asset_management`.`risk`.`var_calculation`"
  parameters:
    - name: p_var_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "Calculation Month"
      display_name: "Calculation Month"
      expr: DATE_TRUNC('month', calculation_date)
      comment: "Month bucket of the VaR calculation date for time-intelligence."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Calculation Year"
      display_name: "Calculation Year"
      expr: DATE_TRUNC('year', calculation_date)
      comment: "Year bucket of VaR calculation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Asset Class Scope"
      display_name: "Asset Class Scope"
      expr: asset_class_scope
      comment: "Asset class scope the VaR run covers."
    - name: "Methodology"
      display_name: "Methodology"
      expr: methodology
      comment: "VaR methodology (e.g. historical, parametric, Monte Carlo)."
    - name: "Calculation Status"
      display_name: "Calculation Status"
      expr: calculation_status
      comment: "Processing status of the VaR calculation."
  measures:
    - name: "VaR Calculation Count"
      display_name: "VaR Calculation Count"
      expr: COUNT(1)
      comment: "Number of VaR calculation records; baseline volume measure."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total VaR Amount"
      display_name: "Total VaR Amount"
      expr: SUM(CAST(var_amount AS DOUBLE))
      comment: "Sum of VaR exposure; drives capital planning and limit setting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total CVaR Amount"
      display_name: "Total CVaR Amount"
      expr: SUM(CAST(cvar_amount AS DOUBLE))
      comment: "Sum of conditional VaR (expected tail loss); key for tail-risk governance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg VaR Percentage"
      display_name: "Avg VaR Percentage"
      expr: AVG(CAST(var_percentage AS DOUBLE))
      comment: "Average VaR as a percentage of portfolio value; normalized tail-risk indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Diversification Benefit"
      display_name: "Total Diversification Benefit"
      expr: SUM(CAST(diversification_benefit AS DOUBLE))
      comment: "Aggregate diversification benefit captured; informs portfolio construction value-add."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Stress VaR Amount"
      display_name: "Total Stress VaR Amount"
      expr: SUM(CAST(stress_var_amount AS DOUBLE))
      comment: "Sum of stressed VaR; feeds regulatory capital and tail-risk oversight."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Backtesting Exceptions"
      display_name: "Total Backtesting Exceptions"
      expr: SUM(CAST(backtesting_exceptions AS DOUBLE))
      comment: "Total backtesting exceptions; model-adequacy signal (Basel traffic light)."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Data Quality Score"
      display_name: "Avg Data Quality Score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average data quality score of VaR inputs; governance/trust indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total VaR CM"
      display_name: "Total VaR CM"
      expr: SUM(CAST(var_amount AS DOUBLE))
      comment: "Current-month VaR for month-over-month trend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Calculation Month
          range: current
          semiadditive: last
    - name: "Total VaR PM"
      display_name: "Total VaR PM"
      expr: SUM(CAST(var_amount AS DOUBLE))
      comment: "Prior-month VaR for month-over-month trend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Calculation Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "VaR MoM"
      display_name: "VaR MoM"
      expr: (AGG(`Total VaR CM`) - AGG(`Total VaR PM`)) / NULLIF(AGG(`Total VaR PM`), 0)
      comment: "Month-over-month change in VaR; escalation trigger when rising sharply."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
