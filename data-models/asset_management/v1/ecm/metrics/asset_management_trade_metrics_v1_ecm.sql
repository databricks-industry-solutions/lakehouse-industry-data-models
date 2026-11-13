-- Metric views for domain: trade | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_algo_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Algorithmic execution quality KPIs: implementation shortfall, slippage, and participation discipline. Drives algo-strategy selection and venue/provider governance."
  source: "`asset_management`.`trade`.`order`"
  dimensions:
    - name: "created_month"
      display_name: "Created Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Creation month bucket for algo-activity trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "algo_order_count"
      display_name: "Algo Order Count"
      expr: COUNT(1)
      comment: "Number of algorithmic orders — algo adoption baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_notional_value"
      display_name: "Total Notional Value"
      expr: SUM(CAST(notional_value AS DOUBLE))
      comment: "Total notional routed through algos — algo coverage of trade flow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_broker_commission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Broker commission economics KPIs: total commissions, soft-dollar usage, and effective rates. Supports broker allocation, CSA governance, and research-payment transparency."
  source: "`asset_management`.`trade`.`broker_commission`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the commissioned trade."
    - name: "commission_type"
      display_name: "Commission Type"
      expr: commission_type
      comment: "Type of commission (execution, research, CSA) for spend decomposition."
    - name: "payment_status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Payment status of the commission for AP tracking."
    - name: "execution_quality_tier"
      display_name: "Execution Quality Tier"
      expr: execution_quality_tier
      comment: "Broker execution-quality tier for value-for-cost analysis."
    - name: "accrual_month"
      display_name: "Accrual Month"
      expr: DATE_TRUNC('month', accrual_date)
      comment: "Commission accrual month for spend trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_commission_amount"
      display_name: "Total Commission Amount"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total broker commission spend — primary trading-cost line to manage."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_commission_rate_bps"
      display_name: "Avg Commission Rate (bps)"
      expr: AVG(CAST(commission_rate_bps AS DOUBLE))
      comment: "Average commission rate in bps — effective pricing benchmark across brokers."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_trade_notional"
      display_name: "Total Trade Notional"
      expr: SUM(CAST(trade_notional_value AS DOUBLE))
      comment: "Total notional value underlying commissioned trades — basis for blended rate analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "soft_dollar_share_pct"
      display_name: "Soft Dollar Share %"
      expr: ROUND(100.0 * COUNT(CASE WHEN soft_dollar_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of commissions involving soft-dollar arrangements — governance/transparency metric for research payments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_settlement_amount"
      display_name: "Total Settlement Amount"
      expr: SUM(CAST(settlement_amount AS DOUBLE))
      comment: "Total settled commission amount — cash actually disbursed to brokers."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_check`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pre-trade compliance-check KPIs: check volume, pass/fail rates, and override usage. Supports SOX internal-controls attestation and compliance-breach monitoring."
  source: "`asset_management`.`trade`.`trade_check`"
  dimensions:
    - name: "result"
      display_name: "Check Result"
      expr: result
      comment: "Outcome of the compliance check (pass, fail, warning) for control-health analysis."
    - name: "check_month"
      display_name: "Check Month"
      expr: DATE_TRUNC('month', timestamp)
      comment: "Check month bucket for compliance-trend monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "check_count"
      display_name: "Check Count"
      expr: COUNT(1)
      comment: "Total compliance checks performed — control-coverage baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "fail_rate_pct"
      display_name: "Fail Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN result = 'FAIL' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of checks that failed — compliance-breach rate, key SOX control-effectiveness indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "override_rate_pct"
      display_name: "Override Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN override_reason IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of checks with a manual override — governance-risk indicator for breach bypasses."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_execution`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Execution quality and trade cost KPIs over the execution fact table. Supports best-execution monitoring, commission/slippage control, and settlement timeliness — core to EMIR trade reporting and trading-desk oversight."
  source: "`asset_management`.`trade`.`execution`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the executed instrument (equities, fixed income, FX, etc.) for desk-level segmentation."
    - name: "execution_status"
      display_name: "Execution Status"
      expr: execution_status
      comment: "Lifecycle status of the execution (filled, partial, rejected) used to isolate completed vs failed trades."
    - name: "side"
      display_name: "Side"
      expr: side
      comment: "Buy/sell direction of the execution for flow analysis."
    - name: "venue"
      display_name: "Venue"
      expr: venue
      comment: "Execution venue name for venue-level best-execution comparison."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Trade currency for multi-currency cost normalization."
    - name: "liquidity_indicator"
      display_name: "Liquidity Indicator"
      expr: liquidity_indicator
      comment: "Maker/taker liquidity flag informing venue economics and rebate analysis."
    - name: "trade_month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', timestamp)
      comment: "Execution month bucket for time-intelligence trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "trade_year"
      display_name: "Trade Year"
      expr: DATE_TRUNC('year', timestamp)
      comment: "Execution year bucket for annual trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "execution_count"
      display_name: "Execution Count"
      expr: COUNT(1)
      comment: "Total number of executions — baseline trade activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_traded_value"
      display_name: "Total Traded Value"
      expr: SUM(CAST(value AS DOUBLE))
      comment: "Total gross traded notional value — measures trading throughput and market footprint."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_commission"
      display_name: "Total Commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total broker commission paid — direct explicit trading cost to control."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_price_deviation_bps"
      display_name: "Avg Price Deviation (bps)"
      expr: AVG(CAST(price_deviation_bps AS DOUBLE))
      comment: "Average execution price deviation from benchmark in bps — key best-execution quality indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_settlement"
      display_name: "Total Net Settlement"
      expr: SUM(CAST(net_settlement_amount AS DOUBLE))
      comment: "Total net settlement amount across executions — settlement cash exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_accrued_interest"
      display_name: "Total Accrued Interest"
      expr: SUM(CAST(accrued_interest AS DOUBLE))
      comment: "Total accrued interest on fixed-income executions — affects true settlement cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_fx_trade`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FX trading KPIs: traded notional, execution spread, and hedge activity. Supports currency-overlay management and FX execution-cost control for a global multi-currency book."
  source: "`asset_management`.`trade`.`fx_trade`"
  dimensions:
    - name: "base_currency"
      display_name: "Base Currency"
      expr: base_currency
      comment: "Base currency of the FX pair for flow analysis."
    - name: "quote_currency"
      display_name: "Quote Currency"
      expr: quote_currency
      comment: "Quote currency of the FX pair."
    - name: "transaction_type"
      display_name: "Transaction Type"
      expr: transaction_type
      comment: "FX transaction type (spot, forward, swap, NDF) for product-mix analysis."
    - name: "trade_purpose"
      display_name: "Trade Purpose"
      expr: trade_purpose
      comment: "Purpose of the trade (hedge vs investment) for overlay vs active distinction."
    - name: "execution_method"
      display_name: "Execution Method"
      expr: execution_method
      comment: "Execution channel (voice, electronic) for execution-quality comparison."
    - name: "trade_month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_date)
      comment: "Trade month bucket for FX activity trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "fx_trade_count"
      display_name: "FX Trade Count"
      expr: COUNT(1)
      comment: "Number of FX trades — activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_notional_usd"
      display_name: "Total Notional USD"
      expr: SUM(CAST(notional_amount_usd AS DOUBLE))
      comment: "Total USD-equivalent FX notional traded — currency-exposure throughput."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_spread_bps"
      display_name: "Avg Spread (bps)"
      expr: AVG(CAST(spread_bps AS DOUBLE))
      comment: "Average FX execution spread in bps versus benchmark — core FX execution-cost KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_commission"
      display_name: "Total Commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total FX commission paid — explicit FX trading cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "hedge_share_pct"
      display_name: "Hedge Share %"
      expr: ROUND(100.0 * COUNT(CASE WHEN trade_purpose = 'HEDGE' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of FX trades executed for hedging — currency-overlay activity indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Order lifecycle and fill-quality KPIs. Tracks fill rates, order flow, and compliance approval — central to trading-desk throughput and pre-trade control oversight."
  source: "`asset_management`.`trade`.`order`"
  dimensions:
    - name: "order_status"
      display_name: "Order Status"
      expr: order_status
      comment: "Order lifecycle status (new, filled, cancelled, rejected) for pipeline analysis."
    - name: "order_type"
      display_name: "Order Type"
      expr: order_type
      comment: "Order type (market, limit, stop) for execution-strategy segmentation."
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the ordered instrument."
    - name: "side"
      display_name: "Side"
      expr: side
      comment: "Buy/sell direction of the order."
    - name: "execution_strategy"
      display_name: "Execution Strategy"
      expr: execution_strategy
      comment: "Execution strategy applied to the order (VWAP, TWAP, etc.)."
    - name: "order_month"
      display_name: "Order Month"
      expr: DATE_TRUNC('month', order_date)
      comment: "Order month bucket for order-flow trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "order_count"
      display_name: "Order Count"
      expr: COUNT(1)
      comment: "Total number of orders — baseline order-flow volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_order_notional"
      display_name: "Total Order Notional"
      expr: SUM(CAST(notional_value AS DOUBLE))
      comment: "Total order notional value — demand pipeline sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_ordered_quantity"
      display_name: "Total Ordered Quantity"
      expr: SUM(CAST(quantity AS DOUBLE))
      comment: "Total quantity ordered — gross intended trade size."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_filled_quantity"
      display_name: "Total Filled Quantity"
      expr: SUM(CAST(filled_quantity AS DOUBLE))
      comment: "Total quantity filled across orders — basis for fill-rate computation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "fill_rate_pct"
      display_name: "Fill Rate %"
      expr: ROUND(100.0 * SUM(CAST(filled_quantity AS DOUBLE)) / NULLIF(SUM(CAST(quantity AS DOUBLE)), 0), 2)
      comment: "Percentage of ordered quantity actually filled — core execution-effectiveness KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "compliance_approval_rate_pct"
      display_name: "Compliance Approval Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN compliance_approved_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of orders passing pre-trade compliance approval — control-health indicator for SOX attestation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_commission"
      display_name: "Total Commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total order-level commission accrual."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_otc_derivative`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "OTC derivative exposure and collateral KPIs: mark-to-market, notional, clearing status, and collateralization. Central to counterparty-risk management, EMIR clearing, and CSA collateral oversight."
  source: "`asset_management`.`trade`.`otc_derivative`"
  dimensions:
    - name: "derivative_type"
      display_name: "Derivative Type"
      expr: derivative_type
      comment: "Derivative instrument type (swap, option, forward) for exposure segmentation."
    - name: "clearing_status"
      display_name: "Clearing Status"
      expr: clearing_status
      comment: "Clearing status (cleared vs bilateral) for EMIR clearing-obligation monitoring."
    - name: "trade_status"
      display_name: "Trade Status"
      expr: trade_status
      comment: "Lifecycle status of the derivative trade (live, terminated)."
    - name: "underlying_asset_class"
      display_name: "Underlying Asset Class"
      expr: underlying_asset_class
      comment: "Underlying asset class driving the derivative exposure."
    - name: "notional_currency"
      display_name: "Notional Currency"
      expr: notional_currency
      comment: "Notional currency for currency-exposure analysis."
    - name: "trade_month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_date)
      comment: "Trade month bucket for exposure trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "derivative_count"
      display_name: "Derivative Count"
      expr: COUNT(1)
      comment: "Number of OTC derivative positions — book-size baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_notional"
      display_name: "Total Notional"
      expr: SUM(CAST(notional_amount AS DOUBLE))
      comment: "Total notional outstanding — gross derivative exposure to monitor against limits."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_mtm_value"
      display_name: "Total MTM Value"
      expr: SUM(CAST(mark_to_market_value AS DOUBLE))
      comment: "Total mark-to-market value — net replacement-cost exposure, key counterparty-risk driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_collateral_posted"
      display_name: "Total Collateral Posted"
      expr: SUM(CAST(collateral_posted AS DOUBLE))
      comment: "Total collateral posted to counterparties — liquidity usage under CSAs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_collateral_received"
      display_name: "Total Collateral Received"
      expr: SUM(CAST(collateral_received AS DOUBLE))
      comment: "Total collateral received from counterparties — mitigant against counterparty default."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "cleared_share_pct"
      display_name: "Cleared Share %"
      expr: ROUND(100.0 * COUNT(CASE WHEN clearing_status = 'CLEARED' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of derivatives centrally cleared — EMIR clearing-obligation compliance indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_settlement_fail`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Settlement-failure risk KPIs: fail volume, aging, penalties, and buy-in risk. Drives operational-risk mitigation and CSDR/EMIR penalty management."
  source: "`asset_management`.`trade`.`settlement_fail`"
  dimensions:
    - name: "fail_status"
      display_name: "Fail Status"
      expr: fail_status
      comment: "Current status of the settlement fail (open, resolved) for workflow tracking."
    - name: "fail_reason_code"
      display_name: "Fail Reason Code"
      expr: fail_reason_code
      comment: "Standardized fail reason code for root-cause analysis."
    - name: "fail_party_type"
      display_name: "Fail Party Type"
      expr: fail_party_type
      comment: "Party responsible for the fail (us vs counterparty) for accountability."
    - name: "escalation_level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation tier of the fail for operational prioritization."
    - name: "fail_month"
      display_name: "Fail Month"
      expr: DATE_TRUNC('month', fail_date)
      comment: "Fail month bucket for trend monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "fail_count"
      display_name: "Fail Count"
      expr: COUNT(1)
      comment: "Total number of settlement fails — operational-risk volume baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_fail_amount"
      display_name: "Total Fail Amount"
      expr: SUM(CAST(fail_amount AS DOUBLE))
      comment: "Total value of failed settlements — size of settlement risk exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_penalty_amount"
      display_name: "Total Penalty Amount"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total regulatory/counterparty penalties incurred on fails — direct cost of settlement failure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_fail_duration_days"
      display_name: "Avg Fail Duration (days)"
      expr: AVG(CAST(fail_duration_days AS DOUBLE))
      comment: "Average days a settlement remains failed — aging/efficiency indicator for resolution teams."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "buy_in_risk_rate_pct"
      display_name: "Buy-In Risk Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN buy_in_risk_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of fails flagged for buy-in risk — early-warning for forced buy-in cost."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`trade_transaction_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Transaction Cost Analysis (TCA) KPIs covering explicit and implicit costs: market impact, slippage, timing, and opportunity cost. Drives broker/venue selection and execution-strategy optimization."
  source: "`asset_management`.`trade`.`transaction_cost`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class for TCA segmentation across the book."
    - name: "cost_category"
      display_name: "Cost Category"
      expr: cost_category
      comment: "High-level cost category (explicit vs implicit) for cost decomposition."
    - name: "cost_type"
      display_name: "Cost Type"
      expr: cost_type
      comment: "Specific cost type (commission, market impact, spread, etc.)."
    - name: "execution_venue"
      display_name: "Execution Venue"
      expr: execution_venue
      comment: "Venue where the cost was incurred for venue-cost benchmarking."
    - name: "side"
      display_name: "Side"
      expr: side
      comment: "Buy/sell side for directional cost analysis."
    - name: "trade_month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_date)
      comment: "Trade month bucket for cost trending over time."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_cost_amount"
      display_name: "Total Cost Amount"
      expr: SUM(CAST(cost_amount AS DOUBLE))
      comment: "Total transaction cost in currency — aggregate drag on returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_cost_bps"
      display_name: "Avg Cost (bps)"
      expr: AVG(CAST(cost_bps AS DOUBLE))
      comment: "Average transaction cost in bps of notional — normalized efficiency metric for cross-trade comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_market_impact"
      display_name: "Total Market Impact"
      expr: SUM(CAST(market_impact_amount AS DOUBLE))
      comment: "Total market impact cost — implicit cost of moving the market, key to sizing execution strategies."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_slippage"
      display_name: "Total Slippage"
      expr: SUM(CAST(slippage_amount AS DOUBLE))
      comment: "Total slippage vs benchmark — execution shortfall to minimize."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_opportunity_cost"
      display_name: "Total Opportunity Cost"
      expr: SUM(CAST(opportunity_cost_amount AS DOUBLE))
      comment: "Total opportunity cost from unfilled/delayed trades — informs urgency calibration."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_timing_cost"
      display_name: "Total Timing Cost"
      expr: SUM(CAST(timing_cost_amount AS DOUBLE))
      comment: "Total timing cost component of implementation shortfall."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;
