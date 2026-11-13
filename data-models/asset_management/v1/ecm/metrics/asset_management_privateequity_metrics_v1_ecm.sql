-- Metric views for domain: privateequity | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_capital_account`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "LP capital account semantic layer: tracks commitments, contributions, distributions, NAV and performance multiples (TVPI/DPI/RVPI/IRR) per LP position. Core for GIPS/IFRS reporting and LP relationship steering."
  source: "`asset_management`.`privateequity`.`capital_account`"
  dimensions:
    - name: "Account Status"
      display_name: "Account Status"
      expr: account_status
      comment: "Lifecycle status of the LP capital account (active, closed, etc.) for portfolio segmentation."
    - name: "Reporting Currency"
      display_name: "Reporting Currency"
      expr: reporting_currency
      comment: "Currency the capital account statement is reported in."
    - name: "Is Final Statement"
      display_name: "Is Final Statement"
      expr: is_final_statement
      comment: "Flag indicating whether this is the final statement for the account (fund wind-down tracking)."
    - name: "Statement Month"
      display_name: "Statement Month"
      expr: DATE_TRUNC('month', statement_date)
      comment: "Statement date bucketed to month for time-series trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Statement Year"
      display_name: "Statement Year"
      expr: DATE_TRUNC('year', statement_date)
      comment: "Statement date bucketed to year for annual performance reporting."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Commitment"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate committed capital across LP accounts — drives fundraising and pacing decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid In Capital"
      display_name: "Total Paid In Capital"
      expr: SUM(CAST(paid_in_capital AS DOUBLE))
      comment: "Aggregate capital actually drawn/paid-in — denominator for TVPI/DPI performance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Dry powder outstanding — critical for liquidity planning and capital-call pacing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cumulative Distributions"
      display_name: "Total Cumulative Distributions"
      expr: SUM(CAST(cumulative_distributions AS DOUBLE))
      comment: "Lifetime cash returned to LPs — feeds DPI realization monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Closing NAV"
      display_name: "Closing NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Net asset value closing balance across accounts (semi-additive — take latest per period)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Statement Month
          range: current
          semiadditive: last
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total-value-to-paid-in multiple — headline PE performance KPI for LP returns."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg DPI"
      display_name: "Avg DPI"
      expr: AVG(CAST(dpi AS DOUBLE))
      comment: "Average distributions-to-paid-in — measures realized cash returns to LPs."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Net IRR"
      display_name: "Avg Net IRR"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average internal rate of return across accounts — primary risk-adjusted return steering metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carried Interest Allocation"
      display_name: "Total Carried Interest"
      expr: SUM(CAST(carried_interest_allocation AS DOUBLE))
      comment: "Carried interest allocated to GP — monitors fee drag on LP net returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Clawback Obligation"
      display_name: "Total Clawback Obligation"
      expr: SUM(CAST(clawback_obligation AS DOUBLE))
      comment: "Outstanding GP clawback owed back to LPs — risk/recovery exposure flag."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Active LP Account Count"
      display_name: "LP Account Count"
      expr: COUNT(DISTINCT capital_account_id)
      comment: "Number of distinct LP capital accounts — relationship footprint sizing."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_capital_call`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital call drawdown layer: called, funded and unfunded amounts, fees and default interest. Drives capital-call pacing, LP funding compliance and liquidity forecasting."
  source: "`asset_management`.`privateequity`.`privateequity_capital_call`"
  dimensions:
    - name: "Call Status"
      display_name: "Call Status"
      expr: call_status
      comment: "Status of the capital call (issued, funded, cancelled)."
    - name: "Call Type"
      display_name: "Call Type"
      expr: call_type
      comment: "Type/purpose classification of the capital call."
    - name: "Call Currency"
      display_name: "Call Currency"
      expr: call_currency
      comment: "Currency of the capital call."
    - name: "Cancelled Flag"
      display_name: "Cancelled"
      expr: cancelled_flag
      comment: "Whether the call was cancelled."
    - name: "Call Notice Month"
      display_name: "Call Notice Month"
      expr: DATE_TRUNC('month', call_notice_date)
      comment: "Call notice date bucketed to month for pacing trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Call Amount"
      display_name: "Total Call Amount"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Aggregate capital called — drawdown pacing / LP cash demand."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Funded Amount"
      display_name: "Total Funded Amount"
      expr: SUM(CAST(funded_amount AS DOUBLE))
      comment: "Aggregate capital actually funded — settlement completion."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Amount"
      display_name: "Total Unfunded Amount"
      expr: SUM(CAST(unfunded_amount AS DOUBLE))
      comment: "Capital called but not yet funded — LP funding-risk exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fee Amount"
      display_name: "Total Management Fee Amount"
      expr: SUM(CAST(management_fee_amount AS DOUBLE))
      comment: "Management fee component of calls — fee pacing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Default Interest Accrued"
      display_name: "Total Default Interest"
      expr: SUM(CAST(default_interest_accrued AS DOUBLE))
      comment: "Default interest accrued on late LP funding — compliance/penalty exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Funding Ratio"
      display_name: "Avg Funding Ratio"
      expr: AVG(CAST(funded_amount AS DOUBLE) / NULLIF(CAST(call_amount AS DOUBLE), 0))
      comment: "Average ratio of funded to called amount — LP funding reliability KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Capital Call Count"
      display_name: "Capital Call Count"
      expr: COUNT(DISTINCT privateequity_capital_call_id)
      comment: "Number of distinct capital calls — operational volume."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_capital_call_funding_sla`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of capital calls funded on time, an operational treasury SLA for PE drawdowns."
  source: "`asset_management`.`privateequity`.`privateequity_capital_call`"
  dimensions:
    - name: "Call Status"
      display_name: "Call status"
      expr: call_status
      comment: "Status"
    - name: "Currency"
      display_name: "Currency"
      expr: call_currency
      comment: "Currency"
  measures:
    - name: "Funded On Time %"
      display_name: "Funded on time %"
      expr: ROUND(100.0 * SUM(CASE WHEN call_status = 'FUNDED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "On-time funded share"
    - name: "Total Called"
      display_name: "Total called"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Called"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_cash_flow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "PE cash-flow movement layer: capital calls, distributions, fees, carry and preferred return flows with time-intelligence. Drives liquidity management, pacing and net-return analysis."
  source: "`asset_management`.`privateequity`.`privateequity_cash_flow`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "Cash Flow Type"
      display_name: "Cash Flow Type"
      expr: cash_flow_type
      comment: "Type of cash flow (capital call, distribution, fee, etc.)."
    - name: "Cash Flow Status"
      display_name: "Cash Flow Status"
      expr: cash_flow_status
      comment: "Processing status of the cash flow event."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Transaction currency."
    - name: "Recallable Flag"
      display_name: "Recallable"
      expr: recallable_flag
      comment: "Whether the distribution is recallable — affects true liquidity available."
    - name: "Effective Month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Effective date bucketed to month for cash-flow trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_date)
      comment: "Effective date bucketed to year for annual pacing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Net Amount"
      display_name: "Total Net Amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Net cash-flow amount across events — core liquidity flow metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Amount"
      display_name: "Total Gross Amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Gross cash-flow amount before deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Investment Amount"
      display_name: "Total Investment Amount"
      expr: SUM(CAST(investment_amount AS DOUBLE))
      comment: "Capital deployed into investments via these flows — deployment pacing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fees"
      display_name: "Total Management Fees"
      expr: SUM(CAST(management_fee_amount AS DOUBLE))
      comment: "Management fees paid — fee drag monitoring on net returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carried Interest"
      display_name: "Total Carried Interest"
      expr: SUM(CAST(carried_interest_amount AS DOUBLE))
      comment: "Carried interest paid to GP via cash flows — cost-of-performance monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Preferred Return"
      display_name: "Total Preferred Return"
      expr: SUM(CAST(preferred_return_amount AS DOUBLE))
      comment: "Preferred return (hurdle) amounts in flows — waterfall tracking."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Recallable Amount"
      display_name: "Total Recallable Amount"
      expr: SUM(CAST(recallable_amount AS DOUBLE))
      comment: "Recallable distribution amount — contingent liquidity exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Amount CM"
      display_name: "Net Amount (Current Month)"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Net cash flow for the current month bucket."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Effective Month
          range: current
          semiadditive: last
    - name: "Net Amount PM"
      display_name: "Net Amount (Prior Month)"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Net cash flow for the prior month bucket (one month offset)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Effective Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Net Amount MoM"
      display_name: "Net Amount MoM"
      expr: (AGG(`Net Amount CM`) - AGG(`Net Amount PM`)) / NULLIF(AGG(`Net Amount PM`), 0)
      comment: "Month-over-month growth in net cash flow — pacing trend signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Cash Flow Event Count"
      display_name: "Event Count"
      expr: COUNT(DISTINCT privateequity_cash_flow_id)
      comment: "Number of distinct cash-flow events — operational throughput."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_coinvestment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Co-investment layer: commitments, NAV, exit proceeds, return multiples and entry multiples by sector, geography and ESG level. Drives co-invest selection and direct-deal performance steering."
  source: "`asset_management`.`privateequity`.`investment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the co-investment."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Industry sector of the co-investment."
    - name: "Geography"
      display_name: "Geography"
      expr: geography
      comment: "Geographic region for regional allocation analysis."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year cohort."
  measures:
    - name: "Total Commitment Amount"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate co-investment commitment — direct deal exposure sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Aggregate current NAV of co-investments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions Received"
      display_name: "Total Distributions"
      expr: SUM(CAST(distributions_received AS DOUBLE))
      comment: "Cash returned from co-investments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average co-investment multiple-on-invested-capital."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg IRR"
      display_name: "Avg IRR"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average co-investment IRR versus target IRR."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_distribution`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "LP distribution layer: amounts, withholding tax, recallable flags and realization ratios with time-intelligence. Drives realization monitoring, tax planning and LP reporting."
  source: "`asset_management`.`privateequity`.`distribution`"
  dimensions:
    - name: "Distribution Type"
      display_name: "Distribution Type"
      expr: distribution_type
      comment: "Type of distribution (return of capital, gain, income)."
    - name: "Distribution Status"
      display_name: "Distribution Status"
      expr: distribution_status
      comment: "Processing status of the distribution."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Distribution currency."
    - name: "Recallable Flag"
      display_name: "Recallable"
      expr: recallable_flag
      comment: "Whether the distribution is recallable."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year cohort of the distribution source."
    - name: "Payment Month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Payment date bucketed to month for realization trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Payment Year"
      display_name: "Payment Year"
      expr: DATE_TRUNC('year', payment_date)
      comment: "Payment date bucketed to year for annual realization reporting."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Distribution Amount"
      display_name: "Total Distribution Amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Gross distribution amount — realized cash to LPs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Distribution Amount"
      display_name: "Total Net Distribution"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Net distribution after deductions — actual cash received by LPs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total Withholding Tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Withholding tax deducted — tax leakage monitoring and treaty optimization."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Distribution Amount CM"
      display_name: "Distribution (Current Month)"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Net distribution for the current month bucket."
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
    - name: "Distribution Amount PM"
      display_name: "Distribution (Prior Month)"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Net distribution for the prior month bucket (one month offset)."
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
      display_name: "Distribution MoM"
      expr: (AGG(`Distribution Amount CM`) - AGG(`Distribution Amount PM`)) / NULLIF(AGG(`Distribution Amount PM`), 0)
      comment: "Month-over-month growth in net distributions — realization momentum."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distribution Count"
      display_name: "Distribution Count"
      expr: COUNT(DISTINCT distribution_id)
      comment: "Number of distinct distribution events — operational throughput."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_fund_commitment_pacing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commitment pacing across vintage years to monitor diversification and J-curve exposure."
  source: "`asset_management`.`privateequity`.`fund_commitment`"
  dimensions:
    - name: "Vintage"
      display_name: "Vintage"
      expr: vintage_year
      comment: "Vintage"
    - name: "Strategy"
      display_name: "Strategy"
      expr: fund_strategy
      comment: "Strategy"
  measures:
    - name: "Committed"
      display_name: "Committed"
      expr: SUM(CAST(committed_capital_amount AS DOUBLE))
      comment: "Committed"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Commitments"
      display_name: "Commitments"
      expr: COUNT(1)
      comment: "Commitments"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_fund_master_terms`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Carried interest, catch-up, and hurdle terms across the PE fund universe."
  source: "`asset_management`.`privateequity`.`fund`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency"
  measures:
    - name: "Funds"
      display_name: "Funds"
      expr: COUNT(1)
      comment: "Funds"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Carried Interest %"
      display_name: "Avg carried interest %"
      expr: ROUND(AVG(CAST(carried_interest_rate AS DOUBLE)),2)
      comment: "Carry"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Catch-up %"
      display_name: "Avg catch-up %"
      expr: ROUND(AVG(CAST(catch_up_rate AS DOUBLE)),2)
      comment: "Catch-up"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_investment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Direct fund/portfolio investment performance layer: commitments, NAV, realized distributions and return multiples (MOIC/IRR/TVPI) by sector, geography and strategy. Drives portfolio construction and manager-selection decisions."
  source: "`asset_management`.`privateequity`.`investment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the investment (buyout, growth, venture, etc.)."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Industry sector of the investment for concentration analysis."
    - name: "Geography"
      display_name: "Geography"
      expr: geography
      comment: "Geographic region of the investment for regional allocation steering."
    - name: "Strategy"
      display_name: "Strategy"
      expr: strategy
      comment: "Investment strategy classification."
    - name: "Investment Status"
      display_name: "Investment Status"
      expr: investment_status
      comment: "Lifecycle status (active, realized, written-off) of the investment."
    - name: "ESG Integration Flag"
      display_name: "ESG Integrated"
      expr: esg_integration_flag
      comment: "Whether ESG integration applies — supports SFDR sustainability disclosure."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year cohort of the investment for benchmark comparison."
    - name: "Investment Month"
      display_name: "Investment Month"
      expr: DATE_TRUNC('month', investment_date)
      comment: "Investment date bucketed to month for deployment pacing trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Commitment Amount"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate capital committed across investments — portfolio exposure sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid In Capital"
      display_name: "Total Paid In Capital"
      expr: SUM(CAST(paid_in_capital AS DOUBLE))
      comment: "Capital deployed — base for performance multiples."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Aggregate unrealized net asset value — current portfolio carrying value."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions Received"
      display_name: "Total Distributions"
      expr: SUM(CAST(distributions_received AS DOUBLE))
      comment: "Realized cash returned from investments — realization progress."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Value"
      display_name: "Total Value"
      expr: SUM(CAST(total_value AS DOUBLE))
      comment: "Total value (NAV + distributions) across investments — basis for TVPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Remaining undrawn commitment — dry powder for liquidity planning."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average multiple-on-invested-capital — headline absolute return KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg IRR"
      display_name: "Avg IRR"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average internal rate of return — time-weighted return steering metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total-value-to-paid-in multiple across investments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Active Investment Count"
      display_name: "Investment Count"
      expr: COUNT(DISTINCT investment_id)
      comment: "Number of distinct investments — portfolio breadth / diversification."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_management_fee_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Management fee invoicing layer: gross/net fees, offsets, dispute flags and payment status. Drives fee-cost control, dispute monitoring and GP relationship management."
  source: "`asset_management`.`privateequity`.`management_fee_invoice`"
  dimensions:
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Payment status of the fee invoice."
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the invoice."
    - name: "Dispute Flag"
      display_name: "Disputed"
      expr: dispute_flag
      comment: "Whether the invoice is under dispute — fee governance monitoring."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Invoice currency."
    - name: "Invoice Month"
      display_name: "Invoice Month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Invoice date bucketed to month for fee trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Gross Fee"
      display_name: "Total Gross Fee"
      expr: SUM(CAST(gross_fee_amount AS DOUBLE))
      comment: "Gross management fees invoiced — total fee burden before offsets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Fee"
      display_name: "Total Net Fee"
      expr: SUM(CAST(net_fee_amount AS DOUBLE))
      comment: "Net management fees after offsets — actual fee cost to LPs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fee Offset"
      display_name: "Total Fee Offset"
      expr: SUM(CAST(total_fee_offset AS DOUBLE))
      comment: "Total fee offsets (monitoring, transaction) — fee recovery for LPs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Monitoring Fee Offset"
      display_name: "Total Monitoring Offset"
      expr: SUM(CAST(monitoring_fee_offset AS DOUBLE))
      comment: "Monitoring fee offsets credited back — LP offset benefit."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Fee Rate"
      display_name: "Avg Fee Rate"
      expr: AVG(CAST(fee_rate AS DOUBLE))
      comment: "Average effective management fee rate — cost benchmarking across GPs."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Invoice Count"
      display_name: "Invoice Count"
      expr: COUNT(DISTINCT management_fee_invoice_id)
      comment: "Number of distinct fee invoices — operational volume."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_nav`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund NAV / valuation layer: GAV, NAV, realized/unrealized value, fees accrued and performance multiples by valuation method and audit status. Drives IFRS valuation reporting and J-curve monitoring (semi-additive balances)."
  source: "`asset_management`.`privateequity`.`nav`"
  dimensions:
    - name: "NAV Status"
      display_name: "NAV Status"
      expr: nav_status
      comment: "Status of the NAV record (draft, final)."
    - name: "Valuation Method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Valuation methodology used (market, income, cost)."
    - name: "Fair Value Hierarchy Level"
      display_name: "FV Hierarchy Level"
      expr: fair_value_hierarchy_level
      comment: "IFRS/ASC fair-value hierarchy level (1/2/3) — valuation reliability disclosure."
    - name: "Audited Flag"
      display_name: "Audited"
      expr: audited_flag
      comment: "Whether the NAV figure is audited."
    - name: "J Curve Phase"
      display_name: "J-Curve Phase"
      expr: j_curve_phase
      comment: "J-curve lifecycle phase of the fund."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year cohort for benchmarking."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month for NAV trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Closing NAV"
      display_name: "Closing NAV"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Closing net asset value (semi-additive — take latest within period)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Valuation Month
          range: current
          semiadditive: last
    - name: "Opening NAV"
      display_name: "Opening NAV"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Opening net asset value (semi-additive — take first within period)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Valuation Month
          range: current
          semiadditive: first
    - name: "Total GAV"
      display_name: "Total GAV"
      expr: SUM(CAST(gav_amount AS DOUBLE))
      comment: "Gross asset value — pre-liability valuation base."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Value"
      display_name: "Total Unrealized Value"
      expr: SUM(CAST(unrealized_value AS DOUBLE))
      comment: "Unrealized portfolio value — mark-to-market exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Value"
      display_name: "Total Realized Value"
      expr: SUM(CAST(realized_value AS DOUBLE))
      comment: "Realized portfolio value — cumulative exits."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fee Accrued"
      display_name: "Total Mgmt Fee Accrued"
      expr: SUM(CAST(management_fee_accrued AS DOUBLE))
      comment: "Accrued management fees in NAV — fee drag disclosure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carried Interest Accrued"
      display_name: "Total Carry Accrued"
      expr: SUM(CAST(carried_interest_accrued AS DOUBLE))
      comment: "Accrued carried interest in NAV — GP performance liability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Since-Inception IRR"
      display_name: "Avg SI IRR"
      expr: AVG(CAST(irr_since_inception AS DOUBLE))
      comment: "Average since-inception IRR across NAV records — long-run return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total-value-to-paid-in multiple from NAV records."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_capital_calls`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital called by GPs, call status mix, and default interest accrued."
  source: "`asset_management`.`privateequity`.`privateequity_capital_call`"
  dimensions:
    - name: "Call Type"
      display_name: "Call type"
      expr: call_type
      comment: "Type"
    - name: "Call Status"
      display_name: "Call status"
      expr: call_status
      comment: "Status"
    - name: "Call Purpose"
      display_name: "Call purpose"
      expr: call_purpose
      comment: "Purpose"
    - name: "Currency"
      display_name: "Currency"
      expr: call_currency
      comment: "Currency"
  measures:
    - name: "Total Called"
      display_name: "Total called"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Called amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Calls"
      display_name: "Calls"
      expr: COUNT(1)
      comment: "Call notices"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Default Interest"
      display_name: "Default interest"
      expr: SUM(CAST(default_interest_accrued AS DOUBLE))
      comment: "Default interest"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_distribution_currency_fx`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Distributions normalized to a reporting currency via FX for cross-fund comparison."
  source: "`asset_management`.`privateequity`.`distribution`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "Distribution Type"
      display_name: "Distribution type"
      expr: distribution_type
      comment: "Type"
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Local currency"
  measures:
    - name: "FX-Normalized Distributions"
      display_name: "Fx-normalized distributions"
      expr: ROUND(SUM(CAST(amount AS DOUBLE) * CAST(fx_rate AS DOUBLE)),2)
      comment: "Distributions scaled by FX to target currency param p_target_currency"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg FX Rate"
      display_name: "Avg fx rate"
      expr: ROUND(AVG(CAST(fx_rate AS DOUBLE)),4)
      comment: "Average FX"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_distributions`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cash and in-kind distributions received from PE funds with cumulative DPI."
  source: "`asset_management`.`privateequity`.`distribution`"
  dimensions:
    - name: "Distribution Type"
      display_name: "Distribution type"
      expr: distribution_type
      comment: "Type"
    - name: "Status"
      display_name: "Status"
      expr: distribution_status
      comment: "Status"
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency"
  measures:
    - name: "Total Distributions"
      display_name: "Total distributions"
      expr: SUM(CAST(amount_base_currency AS DOUBLE))
      comment: "Distribution base ccy"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI Ratio"
      display_name: "Avg dpi ratio"
      expr: ROUND(AVG(CAST(dpi_ratio AS DOUBLE)),2)
      comment: "DPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distributions"
      display_name: "Distributions"
      expr: COUNT(1)
      comment: "Distributions"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_dry_powder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Unfunded PE commitments plus realized DPI and IRR across LP commitments."
  source: "`asset_management`.`privateequity`.`fund_commitment`"
  dimensions:
    - name: "Fund Strategy"
      display_name: "Fund strategy"
      expr: fund_strategy
      comment: "Strategy"
    - name: "Geographic Focus"
      display_name: "Geographic focus"
      expr: geographic_focus
      comment: "Geography"
    - name: "Vintage"
      display_name: "Vintage"
      expr: vintage_year
      comment: "Vintage"
    - name: "Currency"
      display_name: "Currency"
      expr: commitment_currency
      comment: "Currency"
  measures:
    - name: "Committed Capital"
      display_name: "Committed capital"
      expr: SUM(CAST(committed_capital_amount AS DOUBLE))
      comment: "Committed"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI"
      display_name: "Avg dpi"
      expr: ROUND(AVG(CAST(dpi_multiple AS DOUBLE)),2)
      comment: "DPI"
    - name: "Avg IRR %"
      display_name: "Avg irr %"
      expr: ROUND(AVG(CAST(irr_percent AS DOUBLE)),2)
      comment: "IRR"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_investment_exit_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of PE investments that have exited, a realization-pacing KPI."
  source: "`asset_management`.`privateequity`.`investment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
  measures:
    - name: "Investments"
      display_name: "Investments"
      expr: COUNT(1)
      comment: "Investments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Exited %"
      display_name: "Exited %"
      expr: ROUND(100.0 * SUM(CASE WHEN exit_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Exited share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_pe_investment_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Direct PE and co-investment performance: DPI, distributions, and commitment deployed."
  source: "`asset_management`.`privateequity`.`investment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Currency"
      display_name: "Currency"
      expr: commitment_currency
      comment: "Currency"
  measures:
    - name: "Total Commitment"
      display_name: "Total commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Commitment"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Distributions Received"
      display_name: "Distributions received"
      expr: SUM(CAST(distributions_received AS DOUBLE))
      comment: "Distributions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg DPI"
      display_name: "Avg dpi"
      expr: ROUND(AVG(CAST(dpi AS DOUBLE)),2)
      comment: "DPI"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_portfolio_company`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio company operating & value-creation layer: enterprise value, EBITDA, revenue, ownership, ESG scores and carbon footprint. Drives post-acquisition value creation and TCFD climate disclosure."
  source: "`asset_management`.`privateequity`.`portfolio_company`"
  dimensions:
    - name: "Investment Stage"
      display_name: "Investment Stage"
      expr: investment_stage
      comment: "Stage of the portfolio company investment (early, growth, mature)."
    - name: "Investment Status"
      display_name: "Investment Status"
      expr: investment_status
      comment: "Current holding status (active, exited) of the company."
    - name: "Headquarters Country"
      display_name: "HQ Country"
      expr: headquarters_country
      comment: "Country of HQ for geographic concentration analysis."
    - name: "GICS Sector Code"
      display_name: "GICS Sector"
      expr: gics_sector_code
      comment: "GICS sector classification for industry exposure reporting."
    - name: "ESG Rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "ESG rating of the company — supports SFDR and ESG integration steering."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year cohort for performance benchmarking."
  measures:
    - name: "Total Enterprise Value"
      display_name: "Total Enterprise Value"
      expr: SUM(CAST(enterprise_value AS DOUBLE))
      comment: "Aggregate enterprise value of portfolio companies — total portfolio scale."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Current Fair Value"
      display_name: "Total Fair Value"
      expr: SUM(CAST(current_fair_value AS DOUBLE))
      comment: "Aggregate current fair value of holdings — carrying value for NAV / IFRS valuation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Invested Capital"
      display_name: "Total Invested Capital"
      expr: SUM(CAST(total_invested_capital AS DOUBLE))
      comment: "Cumulative capital invested into companies — cost basis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions Received"
      display_name: "Total Distributions"
      expr: SUM(CAST(total_distributions_received AS DOUBLE))
      comment: "Realized proceeds from portfolio companies — realization tracking."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Latest EBITDA"
      display_name: "Total EBITDA"
      expr: SUM(CAST(ebitda_latest AS DOUBLE))
      comment: "Aggregate latest EBITDA — operating performance of the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Latest Revenue"
      display_name: "Total Revenue"
      expr: SUM(CAST(revenue_latest AS DOUBLE))
      comment: "Aggregate latest revenue across portfolio companies — top-line growth monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carbon Footprint"
      display_name: "Total Carbon Footprint (t)"
      expr: SUM(CAST(carbon_footprint_tonnes AS DOUBLE))
      comment: "Aggregate financed carbon emissions (tonnes) — core TCFD climate-risk disclosure metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score — portfolio-level sustainability quality steering."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average multiple-on-invested-capital at company level."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg IRR"
      display_name: "Avg IRR"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average company-level IRR — value creation return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Portfolio Company Count"
      display_name: "Company Count"
      expr: COUNT(DISTINCT portfolio_company_id)
      comment: "Number of distinct portfolio companies — diversification footprint."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`privateequity_value_creation_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio value-creation layer: target vs actual EBITDA improvement, revenue growth and cost reduction with progress tracking. Drives post-acquisition operational value realization — a core differentiator for this permanent-capital allocator."
  source: "`asset_management`.`privateequity`.`value_creation_plan`"
  dimensions:
    - name: "Plan Status"
      display_name: "Plan Status"
      expr: plan_status
      comment: "Status of the value-creation plan (active, completed, at-risk)."
    - name: "Value Creation Theme"
      display_name: "Value Creation Theme"
      expr: value_creation_theme
      comment: "Theme of value creation (operational, buy-and-build, margin)."
    - name: "ESG Impact Flag"
      display_name: "ESG Impact"
      expr: esg_impact_flag
      comment: "Whether the plan has an ESG impact dimension."
    - name: "Plan Start Month"
      display_name: "Plan Start Month"
      expr: DATE_TRUNC('month', plan_start_date)
      comment: "Plan start date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Target EBITDA Improvement"
      display_name: "Target EBITDA Improvement"
      expr: SUM(CAST(target_ebitda_improvement_amount AS DOUBLE))
      comment: "Targeted EBITDA uplift across plans — value-creation ambition."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual EBITDA Improvement"
      display_name: "Actual EBITDA Improvement"
      expr: SUM(CAST(actual_ebitda_improvement_amount AS DOUBLE))
      comment: "Delivered EBITDA uplift — actual operational value realized."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Target Revenue Growth"
      display_name: "Target Revenue Growth"
      expr: SUM(CAST(target_revenue_growth_amount AS DOUBLE))
      comment: "Targeted revenue growth across plans."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Revenue Growth"
      display_name: "Actual Revenue Growth"
      expr: SUM(CAST(actual_revenue_growth_amount AS DOUBLE))
      comment: "Delivered revenue growth — realized top-line value."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Cost Reduction"
      display_name: "Actual Cost Reduction"
      expr: SUM(CAST(actual_cost_reduction_amount AS DOUBLE))
      comment: "Delivered cost reductions — operational efficiency gains."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Plan Progress"
      display_name: "Avg Progress %"
      expr: AVG(CAST(progress_percent AS DOUBLE))
      comment: "Average completion progress across value-creation plans — execution health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR"
      expr: AVG(CAST(target_irr_percent AS DOUBLE))
      comment: "Average target IRR embedded in value-creation plans."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Plan Count"
      display_name: "Plan Count"
      expr: COUNT(DISTINCT value_creation_plan_id)
      comment: "Number of distinct value-creation plans — active transformation footprint."
      format:
        type: number
        decimal_places:
          type: all
$$;
