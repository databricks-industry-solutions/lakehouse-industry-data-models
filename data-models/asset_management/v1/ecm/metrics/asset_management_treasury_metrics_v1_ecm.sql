-- Metric views for domain: treasury | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_capital_call_funding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private market capital call funding executions. Used to steer drawdown pacing, funding timeliness and FX hedging coverage of calls."
  source: "`asset_management`.`treasury`.`capital_call_funding`"
  dimensions:
    - name: "Funding Status"
      display_name: "Funding status"
      expr: funding_status
      comment: "Status of the capital call funding (e.g. funded, pending, rejected)."
    - name: "Call Type"
      display_name: "Call type"
      expr: call_type
      comment: "Type/purpose classification of the capital call."
    - name: "Funding Priority"
      display_name: "Funding priority"
      expr: funding_priority
      comment: "Operational priority assigned to the funding."
    - name: "Call Currency"
      display_name: "Call currency"
      expr: call_currency_code
      comment: "Currency in which the capital call was issued."
    - name: "Reconciliation Status"
      display_name: "Reconciliation status"
      expr: reconciliation_status
      comment: "Reconciliation state of the funding."
    - name: "FX Hedge Applied"
      display_name: "Fx hedge applied"
      expr: fx_hedge_applied_flag
      comment: "Whether an FX hedge was applied to the funding."
    - name: "Call Due Month"
      display_name: "Call due month"
      expr: DATE_TRUNC('month', call_due_date)
      comment: "Capital call due date bucketed to month for pacing analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Funding Count"
      display_name: "Funding count"
      expr: COUNT(1)
      comment: "Number of capital call funding records; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Requested Amount"
      display_name: "Total requested amount"
      expr: SUM(CAST(call_amount_requested AS DOUBLE))
      comment: "Total capital called/requested by GPs; drawdown demand."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Funded Amount (Base)"
      display_name: "Total funded amount (base)"
      expr: SUM(CAST(funding_amount_base_currency AS DOUBLE))
      comment: "Total funded amount in base currency; actual capital deployed to private markets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Late Payment Penalties"
      display_name: "Total late payment penalties"
      expr: SUM(CAST(late_payment_penalty_amount AS DOUBLE))
      comment: "Total late payment penalties; measures funding timeliness failures and avoidable cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Commitment Pct Called"
      display_name: "Avg commitment pct called"
      expr: AVG(CAST(commitment_percentage_called AS DOUBLE))
      comment: "Average share of commitment drawn per call; pacing intensity indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "FX Hedged Funding Count"
      display_name: "Fx hedged funding count"
      expr: COUNT(CASE WHEN fx_hedge_applied_flag = TRUE THEN 1 END)
      comment: "Number of fundings with an FX hedge applied; input to hedge coverage ratio."
      format:
        type: number
        decimal_places:
          type: all
    - name: "FX Hedge Coverage Rate"
      display_name: "Fx hedge coverage rate"
      expr: AGG(`FX Hedged Funding Count`) / NULLIF(AGG(`Funding Count`), 0)
      comment: "Share of capital call fundings that were FX hedged; currency risk discipline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_cash_flow_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Treasury cash flow events (inflows/outflows) across portfolios, capital calls, distributions, settlements and hedge settlements. Core fact for liquidity and cash management steering."
  source: "`asset_management`.`treasury`.`cash_flow_event`"
  dimensions:
    - name: "Event Type"
      display_name: "Event Type"
      expr: event_type
      comment: "Type of cash flow event (e.g. capital call, distribution, settlement, fee)."
    - name: "Flow Direction"
      display_name: "Flow direction"
      expr: flow_direction
      comment: "Direction of the cash flow (inflow vs outflow)."
    - name: "Event Status"
      display_name: "Event status"
      expr: event_status
      comment: "Processing/lifecycle status of the cash flow event."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Settlement currency of the cash flow event."
    - name: "Reconciliation Status"
      display_name: "Reconciliation status"
      expr: reconciliation_status
      comment: "Reconciliation state of the event against custodian/IBOR records."
    - name: "Event Month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', event_date)
      comment: "Event date bucketed to month for liquidity trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Event Quarter"
      display_name: "Event quarter"
      expr: DATE_TRUNC('quarter', event_date)
      comment: "Event date bucketed to quarter."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Event Count"
      display_name: "Event count"
      expr: COUNT(1)
      comment: "Number of cash flow events; baseline volume measure."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Cash Flow (Base)"
      display_name: "Total net cash flow (base)"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Total net cash movement in base currency; headline liquidity measure for treasury steering."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Amount"
      display_name: "Total gross amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross transacted amount before fees."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fees"
      display_name: "Total fees"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fees incurred on cash flow events; cost control measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Forecast Variance"
      display_name: "Total forecast variance"
      expr: SUM(CAST(variance_amount AS DOUBLE))
      comment: "Total variance between forecast and actual cash flows; forecast accuracy signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Cash Flow CM"
      display_name: "Net cash flow cm"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Net cash flow in the current month bucket."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Event Month
          range: current
          semiadditive: last
    - name: "Net Cash Flow PM"
      display_name: "Net cash flow pm"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Net cash flow in the prior month bucket."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Event Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Net Cash Flow MoM"
      display_name: "Net cash flow mom"
      expr: (AGG(`Net Cash Flow CM`) - AGG(`Net Cash Flow PM`)) / NULLIF(AGG(`Net Cash Flow PM`), 0)
      comment: "Month-over-month growth in net cash flow; liquidity momentum."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_cash_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Point-in-time cash positions across accounts and custodians. Semi-additive balances for liquidity monitoring and reserve adequacy."
  source: "`asset_management`.`treasury`.`cash_position`"
  dimensions:
    - name: "Position Status"
      display_name: "Position status"
      expr: position_status
      comment: "Status of the cash position snapshot."
    - name: "Liquidity Tier"
      display_name: "Liquidity tier"
      expr: liquidity_tier
      comment: "Liquidity tier classification of the cash position."
    - name: "Reconciliation Status"
      display_name: "Reconciliation status"
      expr: reconciliation_status
      comment: "Reconciliation state of the position."
    - name: "Is Current"
      display_name: "Is current"
      expr: is_current
      comment: "Flag indicating whether this is the current/latest position snapshot."
    - name: "Position Month"
      display_name: "Position month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Position date bucketed to month for balance trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Position Day"
      display_name: "Position day"
      expr: DATE_TRUNC('day', position_date)
      comment: "Position date at day granularity for closing-balance semi-additive measures."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Available Balance"
      display_name: "Total available balance"
      expr: SUM(CAST(available_balance AS DOUBLE))
      comment: "Total available cash balance; headline liquidity measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Ledger Balance"
      display_name: "Total ledger balance"
      expr: SUM(CAST(ledger_balance AS DOUBLE))
      comment: "Total ledger (book) cash balance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reserved Amount"
      display_name: "Total reserved amount"
      expr: SUM(CAST(reserved_amount AS DOUBLE))
      comment: "Total cash reserved/earmarked; constrains free liquidity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Call Pending"
      display_name: "Total capital call pending"
      expr: SUM(CAST(capital_call_pending AS DOUBLE))
      comment: "Total pending capital calls against cash; upcoming outflow pressure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reconciliation Difference"
      display_name: "Total reconciliation difference"
      expr: SUM(CAST(reconciliation_difference AS DOUBLE))
      comment: "Total unreconciled cash difference; operational data-quality risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Closing Available Balance"
      display_name: "Closing available balance"
      expr: SUM(CAST(available_balance AS DOUBLE))
      comment: "Closing available balance for the period (semi-additive, last snapshot)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Position Day
          range: current
          semiadditive: last
    - name: "Opening Available Balance"
      display_name: "Opening available balance"
      expr: SUM(CAST(available_balance AS DOUBLE))
      comment: "Opening available balance for the period (semi-additive, first snapshot)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Position Day
          range: current
          semiadditive: first
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_cash_reconciliation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cash reconciliation runs between IBOR and custodian records. Steers operational control quality, variance resolution and escalation volume."
  source: "`asset_management`.`treasury`.`cash_reconciliation`"
  dimensions:
    - name: "Reconciliation Status"
      display_name: "Reconciliation status"
      expr: reconciliation_status
      comment: "Outcome status of the reconciliation run."
    - name: "Reconciliation Type"
      display_name: "Reconciliation type"
      expr: reconciliation_type
      comment: "Type of reconciliation performed."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the reconciled account."
    - name: "Within Tolerance"
      display_name: "Within tolerance"
      expr: within_tolerance_flag
      comment: "Whether the reconciliation variance was within tolerance."
    - name: "Escalation Required"
      display_name: "Escalation required"
      expr: escalation_required_flag
      comment: "Whether escalation was required for this reconciliation."
    - name: "Reconciliation Month"
      display_name: "Reconciliation month"
      expr: DATE_TRUNC('month', reconciliation_date)
      comment: "Reconciliation date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Reconciliation Count"
      display_name: "Reconciliation count"
      expr: COUNT(1)
      comment: "Number of reconciliation runs; baseline operational volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Within Tolerance Count"
      display_name: "Within tolerance count"
      expr: COUNT(CASE WHEN within_tolerance_flag = TRUE THEN 1 END)
      comment: "Number of reconciliations within tolerance; numerator for straight-through rate."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Within Tolerance Rate"
      display_name: "Within tolerance rate"
      expr: AGG(`Within Tolerance Count`) / NULLIF(AGG(`Reconciliation Count`), 0)
      comment: "Share of reconciliations within tolerance; operational control quality KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unexplained Variance"
      display_name: "Total unexplained variance"
      expr: SUM(CAST(unexplained_variance_amount AS DOUBLE))
      comment: "Total unexplained cash variance; residual control risk requiring investigation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Closing Balance Variance"
      display_name: "Total closing balance variance"
      expr: SUM(CAST(closing_balance_variance_amount AS DOUBLE))
      comment: "Total closing balance variance between IBOR and custodian."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Count"
      display_name: "Escalation count"
      expr: COUNT(CASE WHEN escalation_required_flag = TRUE THEN 1 END)
      comment: "Number of reconciliations requiring escalation; exception workload."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Unmatched IBOR Amount"
      display_name: "Total unmatched ibor amount"
      expr: SUM(CAST(unmatched_ibor_transaction_amount AS DOUBLE))
      comment: "Total value of unmatched IBOR transactions; matching gap exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_cash_transfer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Outbound/inbound cash transfers across accounts and custodians. Steers payment throughput, failure rates and transfer cost."
  source: "`asset_management`.`treasury`.`cash_transfer`"
  dimensions:
    - name: "Transfer Status"
      display_name: "Transfer status"
      expr: transfer_status
      comment: "Lifecycle status of the transfer (e.g. settled, pending, failed)."
    - name: "Transfer Type"
      display_name: "Transfer type"
      expr: transfer_type
      comment: "Type/purpose classification of the transfer."
    - name: "Payment Method"
      display_name: "Payment method"
      expr: payment_method
      comment: "Payment method used for the transfer."
    - name: "Priority Level"
      display_name: "Priority level"
      expr: priority_level
      comment: "Priority level assigned to the transfer."
    - name: "Transfer Currency"
      display_name: "Transfer currency"
      expr: transfer_currency_code
      comment: "Currency of the transfer."
    - name: "Settlement Month"
      display_name: "Settlement month"
      expr: DATE_TRUNC('month', settlement_date)
      comment: "Settlement date bucketed to month for throughput trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Transfer Count"
      display_name: "Transfer count"
      expr: COUNT(1)
      comment: "Number of cash transfers; baseline payment volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Transfer Amount"
      display_name: "Total transfer amount"
      expr: SUM(CAST(transfer_amount AS DOUBLE))
      comment: "Total gross value transferred; payment throughput."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Transfer Amount"
      display_name: "Total net transfer amount"
      expr: SUM(CAST(net_transfer_amount AS DOUBLE))
      comment: "Total net value transferred after fees."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Transfer Fees"
      display_name: "Total transfer fees"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fees paid on transfers; payment cost control."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Failed Transfer Count"
      display_name: "Failed transfer count"
      expr: COUNT(CASE WHEN transfer_status = 'FAILED' THEN 1 END)
      comment: "Number of failed transfers; operational reliability signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Transfer Failure Rate"
      display_name: "Transfer failure rate"
      expr: AGG(`Failed Transfer Count`) / NULLIF(AGG(`Transfer Count`), 0)
      comment: "Share of transfers that failed; payment operations quality KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_counterparty_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Counterparty credit exposure across FX and short-term treasury activity. Steers limit utilization, netting benefit and wrong-way/settlement risk."
  source: "`asset_management`.`treasury`.`treasury_counterparty_exposure`"
  dimensions:
    - name: "Counterparty Type"
      display_name: "Counterparty type"
      expr: counterparty_type
      comment: "Type/classification of the counterparty."
    - name: "Counterparty Credit Rating"
      display_name: "Counterparty credit rating"
      expr: counterparty_credit_rating
      comment: "Credit rating of the counterparty; credit quality segmentation."
    - name: "Exposure Status"
      display_name: "Exposure status"
      expr: exposure_status
      comment: "Status of the exposure record."
    - name: "Limit Breach"
      display_name: "Limit breach"
      expr: limit_breach_flag
      comment: "Whether the exposure breaches the counterparty limit."
    - name: "Wrong Way Risk"
      display_name: "Wrong way risk"
      expr: wrong_way_risk_flag
      comment: "Whether wrong-way risk is flagged for the counterparty."
    - name: "Exposure Month"
      display_name: "Exposure month"
      expr: DATE_TRUNC('month', exposure_date)
      comment: "Exposure date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Exposure Count"
      display_name: "Exposure count"
      expr: COUNT(1)
      comment: "Number of counterparty exposure records; baseline coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Credit Exposure"
      display_name: "Total net credit exposure"
      expr: SUM(CAST(net_credit_exposure_amount AS DOUBLE))
      comment: "Total net credit exposure after netting/collateral; headline counterparty risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross MTM Exposure"
      display_name: "Total gross mtm exposure"
      expr: SUM(CAST(gross_mtm_exposure_amount AS DOUBLE))
      comment: "Total gross mark-to-market exposure before netting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Netting Benefit"
      display_name: "Total netting benefit"
      expr: SUM(CAST(netting_benefit_amount AS DOUBLE))
      comment: "Total exposure reduction from netting agreements; capital efficiency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Potential Future Exposure"
      display_name: "Total potential future exposure"
      expr: SUM(CAST(potential_future_exposure_amount AS DOUBLE))
      comment: "Total potential future exposure; forward-looking credit risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Limit Utilization"
      display_name: "Avg limit utilization"
      expr: AVG(CAST(limit_utilization_percentage AS DOUBLE))
      comment: "Average counterparty limit utilization; concentration/headroom signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Limit Breach Count"
      display_name: "Limit breach count"
      expr: COUNT(CASE WHEN limit_breach_flag = TRUE THEN 1 END)
      comment: "Number of counterparty limit breaches; actionable risk escalations."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_distribution_receipt`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private market distribution receipts from GPs. Steers realized returns, DPI realization and withholding tax leakage."
  source: "`asset_management`.`treasury`.`distribution_receipt`"
  dimensions:
    - name: "Distribution Status"
      display_name: "Distribution status"
      expr: distribution_status
      comment: "Status of the distribution receipt."
    - name: "Distribution Type"
      display_name: "Distribution type"
      expr: distribution_type
      comment: "Type of distribution (e.g. income, return of capital, realized gain)."
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class of the distributing investment."
    - name: "Base Currency"
      display_name: "Base currency"
      expr: base_currency_code
      comment: "Base currency of the receipt."
    - name: "Recallable"
      display_name: "Recallable"
      expr: recallable_flag
      comment: "Whether the distribution is recallable by the GP."
    - name: "Payment Month"
      display_name: "Payment month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Payment date bucketed to month for realization trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Receipt Count"
      display_name: "Receipt count"
      expr: COUNT(1)
      comment: "Number of distribution receipts; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Distribution (Base)"
      display_name: "Total distribution (base)"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Total distributions received in base currency; realized cash returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Distribution"
      display_name: "Total net distribution"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Total net distribution after tax/withholding."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Gain"
      display_name: "Total realized gain"
      expr: SUM(CAST(realized_gain_amount AS DOUBLE))
      comment: "Total realized gains distributed; performance realization."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total withholding tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Total withholding tax deducted; tax leakage to manage via treaties/reclaims."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Return of Capital"
      display_name: "Total return of capital"
      expr: SUM(CAST(return_of_capital_amount AS DOUBLE))
      comment: "Total return of capital component of distributions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Distribution Base CM"
      display_name: "Distribution base cm"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Distributions received in the current month."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Payment Month
          range: current
          semiadditive: last
    - name: "Distribution Base PM"
      display_name: "Distribution base pm"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Distributions received in the prior month."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Payment Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Distribution MoM"
      display_name: "Distribution mom"
      expr: (AGG(`Distribution Base CM`) - AGG(`Distribution Base PM`)) / NULLIF(AGG(`Distribution Base PM`), 0)
      comment: "Month-over-month growth in distributions received; realization momentum."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_fx_forward`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FX forward contracts used for currency hedging. Steers hedge notional, mark-to-market exposure and realized/unrealized hedging P&L."
  source: "`asset_management`.`treasury`.`fx_forward`"
  dimensions:
    - name: "Contract Status"
      display_name: "Contract status"
      expr: contract_status
      comment: "Lifecycle status of the FX forward contract."
    - name: "Hedge Designation"
      display_name: "Hedge designation"
      expr: hedge_designation
      comment: "Hedge accounting designation of the forward."
    - name: "Buy Currency"
      display_name: "Buy currency"
      expr: buy_currency
      comment: "Currency bought under the forward."
    - name: "Sell Currency"
      display_name: "Sell currency"
      expr: sell_currency
      comment: "Currency sold under the forward."
    - name: "Clearing Status"
      display_name: "Clearing status"
      expr: clearing_status
      comment: "Clearing status of the forward (cleared vs bilateral)."
    - name: "Maturity Month"
      display_name: "Maturity month"
      expr: DATE_TRUNC('month', maturity_date)
      comment: "Maturity date bucketed to month for roll/maturity profiling."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Forward Count"
      display_name: "Forward count"
      expr: COUNT(1)
      comment: "Number of FX forward contracts; baseline hedge book size."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Buy Notional"
      display_name: "Total buy notional"
      expr: SUM(CAST(buy_amount AS DOUBLE))
      comment: "Total notional bought across forwards; hedge coverage scale."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Mark To Market"
      display_name: "Total mark to market"
      expr: SUM(CAST(mark_to_market_value AS DOUBLE))
      comment: "Total mark-to-market value of the forward book; current hedge exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total unrealized gain loss"
      expr: SUM(CAST(unrealized_gain_loss AS DOUBLE))
      comment: "Total unrealized P&L on open forwards; hedge valuation impact."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Gain Loss"
      display_name: "Total realized gain loss"
      expr: SUM(CAST(realized_gain_loss AS DOUBLE))
      comment: "Total realized P&L on settled/terminated forwards; hedging cost/benefit."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Ratio"
      display_name: "Avg hedge ratio"
      expr: AVG(CAST(hedge_ratio AS DOUBLE))
      comment: "Average hedge ratio across forwards; hedging coverage discipline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_fx_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Aggregated FX exposure positions by currency pair. Steers net open exposure, hedge ratio adherence and 1-day VaR."
  source: "`asset_management`.`treasury`.`fx_position`"
  dimensions:
    - name: "Currency Pair"
      display_name: "Currency pair"
      expr: currency_pair
      comment: "Currency pair of the FX position."
    - name: "Position Status"
      display_name: "Position status"
      expr: position_status
      comment: "Status of the FX position."
    - name: "Hedge Designation"
      display_name: "Hedge designation"
      expr: hedge_designation
      comment: "Hedge accounting designation of the position."
    - name: "Rebalance Required"
      display_name: "Rebalance required"
      expr: rebalance_required_flag
      comment: "Whether the position breaches rebalance thresholds."
    - name: "Position Month"
      display_name: "Position month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Position date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Net Open Exposure"
      display_name: "Total net open exposure"
      expr: SUM(CAST(net_open_exposure_base AS DOUBLE))
      comment: "Total unhedged net FX exposure in base currency; currency risk headline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Hedge Notional"
      display_name: "Total hedge notional"
      expr: SUM(CAST(total_hedge_notional_base AS DOUBLE))
      comment: "Total hedge notional across positions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Spot Exposure"
      display_name: "Total spot exposure"
      expr: SUM(CAST(spot_exposure_base AS DOUBLE))
      comment: "Total spot FX exposure in base currency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total 1D VaR 95pct"
      display_name: "Total 1d var 95pct"
      expr: SUM(CAST(var_1day_95pct_base AS DOUBLE))
      comment: "Total 1-day 95% Value-at-Risk across FX positions; risk-budget consumption."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Ratio Variance"
      display_name: "Avg hedge ratio variance"
      expr: AVG(CAST(hedge_ratio_variance AS DOUBLE))
      comment: "Average deviation of actual vs target hedge ratio; hedging discipline gap."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rebalance Required Count"
      display_name: "Rebalance required count"
      expr: COUNT(CASE WHEN rebalance_required_flag = TRUE THEN 1 END)
      comment: "Number of positions flagged for rebalancing; actionable hedging workload."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_hedge_effectiveness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Hedge accounting effectiveness assessments. Steers hedge accounting qualification, ineffectiveness P&L and discontinuation risk under IFRS."
  source: "`asset_management`.`treasury`.`hedge_effectiveness`"
  dimensions:
    - name: "Assessment Type"
      display_name: "Assessment type"
      expr: assessment_type
      comment: "Type of effectiveness assessment (prospective/retrospective)."
    - name: "Assessment Status"
      display_name: "Assessment status"
      expr: assessment_status
      comment: "Status of the assessment."
    - name: "Hedge Accounting Model"
      display_name: "Hedge accounting model"
      expr: hedge_accounting_model
      comment: "Hedge accounting model applied."
    - name: "Discontinuation Flag"
      display_name: "Discontinuation flag"
      expr: discontinuation_flag
      comment: "Whether the hedge relationship was discontinued."
    - name: "Assessment Month"
      display_name: "Assessment month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Assessment date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessment Count"
      display_name: "Assessment count"
      expr: COUNT(1)
      comment: "Number of effectiveness assessments; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Effectiveness Ratio"
      display_name: "Avg effectiveness ratio"
      expr: AVG(CAST(effectiveness_ratio AS DOUBLE))
      comment: "Average hedge effectiveness ratio; qualification quality KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Regression R Squared"
      display_name: "Avg regression r squared"
      expr: AVG(CAST(regression_r_squared AS DOUBLE))
      comment: "Average regression R-squared of effectiveness tests; statistical hedge quality."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total Ineffectiveness Amount"
      display_name: "Total ineffectiveness amount"
      expr: SUM(CAST(ineffectiveness_amount AS DOUBLE))
      comment: "Total hedge ineffectiveness recognized in P&L; accounting leakage."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Discontinuation Count"
      display_name: "Discontinuation count"
      expr: COUNT(CASE WHEN discontinuation_flag = TRUE THEN 1 END)
      comment: "Number of discontinued hedge relationships; hedge program stability risk."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_liquidity_forecast`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Forward-looking liquidity forecasts combining capital calls, distributions, contributions and hedge settlements. Steers liquidity surplus/deficit management against thresholds."
  source: "`asset_management`.`treasury`.`liquidity_forecast`"
  dimensions:
    - name: "Forecast Status"
      display_name: "Forecast status"
      expr: forecast_status
      comment: "Status of the liquidity forecast."
    - name: "Forecast Type"
      display_name: "Forecast type"
      expr: forecast_type
      comment: "Type of forecast (e.g. base, stress)."
    - name: "Forecast Scenario"
      display_name: "Forecast scenario"
      expr: forecast_scenario
      comment: "Scenario assumptions underlying the forecast."
    - name: "Confidence Level"
      display_name: "Confidence level"
      expr: forecast_confidence_level
      comment: "Confidence level attached to the forecast."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the forecast."
    - name: "Forecast Month"
      display_name: "Forecast month"
      expr: DATE_TRUNC('month', forecast_date)
      comment: "Forecast date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Liquidity Surplus Deficit"
      display_name: "Total liquidity surplus deficit"
      expr: SUM(CAST(liquidity_surplus_deficit_amount AS DOUBLE))
      comment: "Total forecast liquidity surplus/deficit; core liquidity adequacy signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Closing Cash Position"
      display_name: "Total closing cash position"
      expr: SUM(CAST(closing_cash_position_amount AS DOUBLE))
      comment: "Total forecast closing cash position across horizons."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Call Funding Outflow"
      display_name: "Total capital call funding outflow"
      expr: SUM(CAST(capital_call_funding_amount AS DOUBLE))
      comment: "Total forecast capital call funding outflows; drawdown pressure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distribution Inflow"
      display_name: "Total distribution inflow"
      expr: SUM(CAST(distribution_inflow_amount AS DOUBLE))
      comment: "Total forecast distribution inflows."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Contribution Inflow"
      display_name: "Total net contribution inflow"
      expr: SUM(CAST(net_contribution_inflow_amount AS DOUBLE))
      comment: "Total forecast net member contribution inflows; pension funding liquidity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Deficit Forecast Count"
      display_name: "Deficit forecast count"
      expr: COUNT(CASE WHEN liquidity_surplus_deficit_amount < 0 THEN 1 END)
      comment: "Number of forecasts projecting a liquidity deficit; early warning count."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_net_contribution_inflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Net member/employer pension contributions flowing into the fund. Steers permanent-capital inflow, deduction leakage and member coverage."
  source: "`asset_management`.`treasury`.`net_contribution_inflow`"
  dimensions:
    - name: "Contribution Status"
      display_name: "Contribution status"
      expr: contribution_status
      comment: "Status of the contribution inflow."
    - name: "Contribution Type"
      display_name: "Contribution type"
      expr: contribution_type
      comment: "Type of contribution (e.g. regular, special)."
    - name: "Allocation Status"
      display_name: "Allocation status"
      expr: allocation_status
      comment: "Allocation state of the contribution."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the contribution."
    - name: "Reserve Flag"
      display_name: "Reserve flag"
      expr: liquidity_reserve_flag
      comment: "Whether part of the contribution was routed to liquidity reserve."
    - name: "Contribution Month"
      display_name: "Contribution month"
      expr: DATE_TRUNC('month', contribution_date)
      comment: "Contribution date bucketed to month for inflow trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Contribution Count"
      display_name: "Contribution count"
      expr: COUNT(1)
      comment: "Number of contribution inflow records; baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Contribution (Base)"
      display_name: "Total net contribution (base)"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Total net contributions in base currency; headline permanent-capital inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Contribution"
      display_name: "Total gross contribution"
      expr: SUM(CAST(gross_contribution_amount AS DOUBLE))
      comment: "Total gross contributions before deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Deductions"
      display_name: "Total deductions"
      expr: SUM(CAST(deduction_amount AS DOUBLE))
      comment: "Total deductions from contributions; leakage to monitor."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liquidity Reserve Allocated"
      display_name: "Total liquidity reserve allocated"
      expr: SUM(CAST(liquidity_reserve_amount AS DOUBLE))
      comment: "Total contributions routed to liquidity reserve; reserve build pace."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Members Covered"
      display_name: "Total members covered"
      expr: SUM(CAST(member_count AS DOUBLE))
      comment: "Total members represented in contributions; beneficiary coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Net Contribution CM"
      display_name: "Net contribution cm"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Net contributions in the current month."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Contribution Month
          range: current
          semiadditive: last
    - name: "Net Contribution PY Month"
      display_name: "Net contribution py month"
      expr: SUM(CAST(base_currency_amount AS DOUBLE))
      comment: "Net contributions in the same month prior year."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Contribution Month
          range: current
          semiadditive: last
          offset: -1 year
    - name: "Net Contribution YoY"
      display_name: "Net contribution yoy"
      expr: (AGG(`Net Contribution CM`) - AGG(`Net Contribution PY Month`)) / NULLIF(AGG(`Net Contribution PY Month`), 0)
      comment: "Year-over-year growth in net contributions; funding inflow momentum."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`treasury_short_term_instrument`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Short-term liquidity instruments (money market, T-bills, CP). Steers short-book yield, market value, ESG compliance and maturity profile."
  source: "`asset_management`.`treasury`.`short_term_instrument`"
  dimensions:
    - name: "Instrument Type"
      display_name: "Instrument type"
      expr: instrument_type
      comment: "Type of short-term instrument."
    - name: "Instrument Status"
      display_name: "Instrument status"
      expr: instrument_status
      comment: "Status of the instrument."
    - name: "Liquidity Tier"
      display_name: "Liquidity tier"
      expr: liquidity_tier
      comment: "Liquidity tier of the instrument."
    - name: "Issuer Credit Rating"
      display_name: "Issuer credit rating"
      expr: issuer_credit_rating
      comment: "Credit rating of the issuer; credit quality segmentation."
    - name: "ESG Compliant"
      display_name: "Esg compliant"
      expr: esg_compliant_flag
      comment: "Whether the instrument meets ESG criteria."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the instrument."
    - name: "Maturity Month"
      display_name: "Maturity month"
      expr: DATE_TRUNC('month', maturity_date)
      comment: "Maturity date bucketed to month for maturity laddering."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Instrument Count"
      display_name: "Instrument count"
      expr: COUNT(1)
      comment: "Number of short-term instruments held; baseline book size."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Market Value"
      display_name: "Total market value"
      expr: SUM(CAST(current_market_value_amount AS DOUBLE))
      comment: "Total current market value of the short-term book; liquid asset base."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Face Value"
      display_name: "Total face value"
      expr: SUM(CAST(face_value_amount AS DOUBLE))
      comment: "Total face value of short-term holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total unrealized gain loss"
      expr: SUM(CAST(unrealized_gain_loss_amount AS DOUBLE))
      comment: "Total unrealized P&L on the short-term book."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Yield To Maturity"
      display_name: "Avg yield to maturity"
      expr: AVG(CAST(yield_to_maturity_percent AS DOUBLE))
      comment: "Average yield-to-maturity of the short-term book; cash return performance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days To Maturity"
      display_name: "Avg days to maturity"
      expr: AVG(CAST(days_to_maturity AS DOUBLE))
      comment: "Average days to maturity; liquidity/rollover profile."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "ESG Compliant Count"
      display_name: "Esg compliant count"
      expr: COUNT(CASE WHEN esg_compliant_flag = TRUE THEN 1 END)
      comment: "Number of ESG-compliant instruments; input to ESG coverage rate."
      format:
        type: number
        decimal_places:
          type: all
    - name: "ESG Compliance Rate"
      display_name: "Esg compliance rate"
      expr: AGG(`ESG Compliant Count`) / NULLIF(AGG(`Instrument Count`), 0)
      comment: "Share of short-term holdings that are ESG compliant; SFDR alignment KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
