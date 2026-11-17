-- Metric views for domain: infrastructure | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_asset_disposition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Exit/disposition KPIs: gross/net proceeds, realized gains, exit returns (gross/net IRR, MOIC), holding periods and tax/transaction drag. Used to evaluate realization quality and inform future entry/exit strategy."
  source: "`asset_management`.`infrastructure`.`asset_disposition`"
  dimensions:
    - name: "Disposition Type"
      display_name: "Disposition Type"
      expr: disposition_type
      comment: "Type of disposition (full sale, partial, refinancing)."
    - name: "Disposition Status"
      display_name: "Disposition Status"
      expr: disposition_status
      comment: "Status of the disposition (signed, closed, pending)."
    - name: "Sale Structure"
      display_name: "Sale Structure"
      expr: sale_structure
      comment: "Structure of the sale (asset vs share deal)."
    - name: "Buyer Type"
      display_name: "Buyer Type"
      expr: buyer_type
      comment: "Type of buyer (strategic, financial, GP)."
    - name: "Tax Jurisdiction"
      display_name: "Tax Jurisdiction"
      expr: tax_jurisdiction
      comment: "Tax jurisdiction of the disposition for tax-efficiency analysis."
    - name: "Proceeds Currency Code"
      display_name: "Proceeds Currency"
      expr: proceeds_currency_code
      comment: "Currency of disposition proceeds."
    - name: "Disposition Year"
      display_name: "Disposition Year"
      expr: DATE_TRUNC('year', disposition_date)
      comment: "Year the disposition closed for realization-trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Disposition Count"
      display_name: "Disposition Count"
      expr: COUNT(1)
      comment: "Number of dispositions in scope. Baseline realization activity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Proceeds"
      display_name: "Total Gross Proceeds"
      expr: SUM(CAST(gross_proceeds_amount AS DOUBLE))
      comment: "Aggregate gross exit proceeds. Core realization value measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Proceeds"
      display_name: "Total Net Proceeds"
      expr: SUM(CAST(net_proceeds_amount AS DOUBLE))
      comment: "Aggregate net proceeds after costs and tax. True cash realized from exits."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Gain Loss"
      display_name: "Total Realized Gain/Loss"
      expr: SUM(CAST(realized_gain_loss_amount AS DOUBLE))
      comment: "Aggregate realized gain or loss on exits. Direct P&L outcome of the realization program."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Transaction Costs"
      display_name: "Total Transaction Costs"
      expr: SUM(CAST(transaction_costs_amount AS DOUBLE))
      comment: "Aggregate transaction costs on dispositions. Cost-drag KPI on exit execution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Gains Tax"
      display_name: "Total Capital Gains Tax"
      expr: SUM(CAST(capital_gains_tax_amount AS DOUBLE))
      comment: "Aggregate capital gains tax on exits. Tax efficiency KPI for structuring decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Gross IRR"
      display_name: "Avg Gross IRR"
      expr: AVG(CAST(gross_irr_percent AS DOUBLE))
      comment: "Average gross IRR achieved on exits. Primary realization-return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Net IRR"
      display_name: "Avg Net IRR"
      expr: AVG(CAST(net_irr_percent AS DOUBLE))
      comment: "Average net IRR achieved on exits after fees/carry. Beneficiary-level return outcome."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average realized multiple on invested capital. Value-multiple outcome of exits."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Holding Period Years"
      display_name: "Avg Holding Period (Years)"
      expr: AVG(CAST(holding_period_years AS DOUBLE))
      comment: "Average holding period in years. Informs velocity of capital and turnover strategy."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_asset_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Valuation governance KPIs: fair value, valuation change amounts/percentages, discount rate and EBITDA multiple assumptions. Used by the valuation committee and IFRS reporting to monitor mark movements and assumption discipline."
  source: "`asset_management`.`infrastructure`.`infrastructure_asset_valuation`"
  dimensions:
    - name: "Valuation Method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Valuation methodology applied (DCF, comparable, RAB)."
    - name: "Valuation Type"
      display_name: "Valuation Type"
      expr: valuation_type
      comment: "Type of valuation (interim, annual, independent)."
    - name: "Valuation Status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Status of the valuation (draft, approved)."
    - name: "Fair Value Hierarchy Level"
      display_name: "Fair Value Hierarchy Level"
      expr: fair_value_hierarchy_level
      comment: "IFRS 13 fair value hierarchy level (1/2/3) for disclosure quality."
    - name: "Valuation Confidence Level"
      display_name: "Valuation Confidence Level"
      expr: valuation_confidence_level
      comment: "Confidence level assigned to the valuation estimate."
    - name: "Regulatory Framework"
      display_name: "Regulatory Framework"
      expr: regulatory_framework
      comment: "Regulatory framework relevant to the valuation."
    - name: "Fair Value Currency"
      display_name: "Fair Value Currency"
      expr: fair_value_currency
      comment: "Currency of the fair value measurement."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the valuation date for mark-movement trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Valuation Count"
      display_name: "Valuation Count"
      expr: COUNT(1)
      comment: "Number of valuations in scope. Baseline for valuation coverage monitoring."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fair Value"
      display_name: "Total Fair Value"
      expr: SUM(CAST(fair_value_amount AS DOUBLE))
      comment: "Aggregate fair value measured. Core IFRS NAV input."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Prior Valuation"
      display_name: "Total Prior Valuation"
      expr: SUM(CAST(prior_valuation_amount AS DOUBLE))
      comment: "Aggregate prior-period valuation. Compared against current fair value to quantify mark movement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Valuation Change Amount"
      display_name: "Total Valuation Change"
      expr: SUM(CAST(valuation_change_amount AS DOUBLE))
      comment: "Aggregate change in valuation vs prior. Quantifies unrealized gains/losses driving NAV."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Valuation Change Percentage"
      display_name: "Avg Valuation Change %"
      expr: AVG(CAST(valuation_change_percentage AS DOUBLE))
      comment: "Average percentage change in valuation. Flags large marks for committee review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Discount Rate"
      display_name: "Avg Discount Rate"
      expr: AVG(CAST(discount_rate AS DOUBLE))
      comment: "Average discount rate assumption. Monitors assumption discipline across DCF valuations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg EBITDA Multiple"
      display_name: "Avg EBITDA Multiple"
      expr: AVG(CAST(ebitda_multiple AS DOUBLE))
      comment: "Average EBITDA multiple assumption. Market-calibration check for comparable-based valuations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Terminal Growth Rate"
      display_name: "Avg Terminal Growth Rate"
      expr: AVG(CAST(terminal_growth_rate AS DOUBLE))
      comment: "Average terminal growth rate assumption. Sensitivity driver of long-duration valuations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_availability_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Availability-based revenue KPIs for PPP/concession assets: contracted vs actual payments, availability performance and deductions, dispute incidence. Used to monitor revenue quality, operator performance and cash leakage."
  source: "`asset_management`.`infrastructure`.`availability_payment`"
  dimensions:
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Status of the availability payment (due, received, disputed)."
    - name: "Payment Type"
      display_name: "Payment Type"
      expr: payment_type
      comment: "Type of availability payment."
    - name: "Payment Frequency"
      display_name: "Payment Frequency"
      expr: payment_frequency
      comment: "Frequency of the availability payment."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status for controls monitoring."
    - name: "Dispute Flag"
      display_name: "Dispute"
      expr: dispute_flag
      comment: "Whether the payment is under dispute (True/False)."
    - name: "Payment Currency Code"
      display_name: "Payment Currency"
      expr: payment_currency_code
      comment: "Currency of the payment."
    - name: "Payment Due Month"
      display_name: "Payment Due Month"
      expr: DATE_TRUNC('month', payment_due_date)
      comment: "Month bucket of the payment due date for revenue trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Payment Count"
      display_name: "Payment Count"
      expr: COUNT(1)
      comment: "Number of availability payments in scope. Baseline revenue event volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Contracted Payment"
      display_name: "Total Contracted Payment"
      expr: SUM(CAST(contracted_payment_amount AS DOUBLE))
      comment: "Aggregate contracted payment entitlement. Revenue baseline against which actuals are compared."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Payment"
      display_name: "Total Actual Payment"
      expr: SUM(CAST(actual_payment_amount AS DOUBLE))
      comment: "Aggregate actual payment received. Core realized availability revenue."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Payment"
      display_name: "Total Net Payment"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Aggregate net payment after deductions and withholdings. True cash collected."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Availability Deduction"
      display_name: "Total Availability Deduction"
      expr: SUM(CAST(availability_deduction_amount AS DOUBLE))
      comment: "Aggregate deductions for unavailability. Cash-leakage KPI driving operator performance action."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Performance Deduction"
      display_name: "Total Performance Deduction"
      expr: SUM(CAST(performance_deduction_amount AS DOUBLE))
      comment: "Aggregate deductions for performance failures. Quality-penalty KPI for SLA enforcement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Availability Actual Percentage"
      display_name: "Avg Actual Availability %"
      expr: AVG(CAST(availability_actual_percentage AS DOUBLE))
      comment: "Average actual availability achieved. Core operational performance KPI vs contracted target."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Availability Target Percentage"
      display_name: "Avg Target Availability %"
      expr: AVG(CAST(availability_target_percentage AS DOUBLE))
      comment: "Average contracted availability target. Benchmark for performance assessment."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Payment Count"
      display_name: "Disputed Payment Count"
      expr: COUNT(DISTINCT CASE WHEN dispute_flag = TRUE THEN availability_payment_id END)
      comment: "Number of disputed payments. Revenue-risk indicator requiring commercial/legal attention."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_capital_call`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital call execution KPIs: amounts called/funded, management fee and expense breakdown, late payment penalties and emergency calls. Used by treasury and operations to manage liquidity, funding timeliness and operational risk."
  source: "`asset_management`.`infrastructure`.`infrastructure_capital_call`"
  dimensions:
    - name: "Call Status"
      display_name: "Call Status"
      expr: call_status
      comment: "Status of the capital call (issued, funded, overdue)."
    - name: "Call Type"
      display_name: "Call Type"
      expr: call_type
      comment: "Type of capital call (investment, fees, expenses)."
    - name: "Call Purpose"
      display_name: "Call Purpose"
      expr: call_purpose
      comment: "Business purpose of the call."
    - name: "Internal Approval Status"
      display_name: "Internal Approval Status"
      expr: internal_approval_status
      comment: "Internal approval state of the call for controls monitoring."
    - name: "Call Currency Code"
      display_name: "Call Currency"
      expr: call_currency_code
      comment: "Currency the call is denominated in."
    - name: "Is Emergency Call"
      display_name: "Emergency Call"
      expr: is_emergency_call
      comment: "Whether the call was an emergency/short-notice call (True/False)."
    - name: "Call Notice Month"
      display_name: "Call Notice Month"
      expr: DATE_TRUNC('month', call_notice_date)
      comment: "Month bucket of the call notice date for liquidity trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Capital Call Count"
      display_name: "Capital Call Count"
      expr: COUNT(1)
      comment: "Number of capital calls in scope. Baseline activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Called Amount"
      display_name: "Total Called Amount"
      expr: SUM(CAST(call_amount AS DOUBLE))
      comment: "Aggregate amount called from the fund. Core cash outflow commitment measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Funded Amount"
      display_name: "Total Funded Amount"
      expr: SUM(CAST(funded_amount AS DOUBLE))
      comment: "Aggregate amount actually funded. Compared against called amount to detect shortfalls."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Investment Amount"
      display_name: "Total Investment Amount"
      expr: SUM(CAST(investment_amount AS DOUBLE))
      comment: "Aggregate portion of calls applied to investment deployment."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fee"
      display_name: "Total Management Fee"
      expr: SUM(CAST(management_fee_amount AS DOUBLE))
      comment: "Aggregate management fees called. Cost transparency KPI for fee oversight."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Late Payment Penalty"
      display_name: "Total Late Payment Penalty"
      expr: SUM(CAST(late_payment_penalty AS DOUBLE))
      comment: "Aggregate late payment penalties incurred. Operational-risk indicator that triggers process review."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Emergency Call Count"
      display_name: "Emergency Call Count"
      expr: COUNT(DISTINCT CASE WHEN is_emergency_call = TRUE THEN infrastructure_capital_call_id END)
      comment: "Number of emergency capital calls. Signals unplanned liquidity demands requiring treasury attention."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Notice Period Days"
      display_name: "Avg Notice Period (Days)"
      expr: AVG(CAST(notice_period_days AS DOUBLE))
      comment: "Average notice period in days. Measures how much lead time treasury receives for funding."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_debt_facility`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project/asset-level debt KPIs: facility size, drawn/undrawn amounts, cost of debt (all-in rate/spread), covenant headroom and expected credit loss. Used by treasury and risk to manage refinancing, leverage and credit exposure."
  source: "`asset_management`.`infrastructure`.`infrastructure_debt_facility`"
  dimensions:
    - name: "Facility Type"
      display_name: "Facility Type"
      expr: facility_type
      comment: "Type of debt facility (term loan, revolver, bond)."
    - name: "Facility Status"
      display_name: "Facility Status"
      expr: facility_status
      comment: "Status of the facility (drawn, undrawn, repaid)."
    - name: "Interest Rate Type"
      display_name: "Interest Rate Type"
      expr: interest_rate_type
      comment: "Fixed vs floating interest rate type for rate-risk analysis."
    - name: "Credit Rating"
      display_name: "Credit Rating"
      expr: credit_rating
      comment: "Credit rating of the facility."
    - name: "Impairment Stage"
      display_name: "Impairment Stage"
      expr: impairment_stage
      comment: "IFRS 9 impairment stage (1/2/3) for credit-risk monitoring."
    - name: "Facility Currency"
      display_name: "Facility Currency"
      expr: facility_currency
      comment: "Currency of the facility."
    - name: "ESG Linked Pricing"
      display_name: "ESG Linked Pricing"
      expr: esg_linked_pricing
      comment: "Whether the facility has ESG-linked pricing (True/False)."
    - name: "Green Bond Certified"
      display_name: "Green Bond Certified"
      expr: green_bond_certified
      comment: "Whether the facility is green-bond certified (True/False)."
    - name: "Maturity Year"
      display_name: "Maturity Year"
      expr: DATE_TRUNC('year', maturity_date)
      comment: "Year of facility maturity for refinancing-wall analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Facility Count"
      display_name: "Facility Count"
      expr: COUNT(1)
      comment: "Number of debt facilities in scope. Baseline debt-book sizing."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Facility Amount"
      display_name: "Total Facility Amount"
      expr: SUM(CAST(facility_amount AS DOUBLE))
      comment: "Aggregate committed facility size. Total debt capacity measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Drawn Amount"
      display_name: "Total Drawn Amount"
      expr: SUM(CAST(drawn_amount AS DOUBLE))
      comment: "Aggregate drawn debt. Core leverage exposure measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Undrawn Amount"
      display_name: "Total Undrawn Amount"
      expr: SUM(CAST(undrawn_amount AS DOUBLE))
      comment: "Aggregate undrawn committed debt. Available liquidity headroom."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Expected Credit Loss"
      display_name: "Total Expected Credit Loss"
      expr: SUM(CAST(expected_credit_loss_amount AS DOUBLE))
      comment: "Aggregate IFRS 9 expected credit loss. Credit-risk provision KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg All In Rate"
      display_name: "Avg All-In Rate"
      expr: AVG(CAST(all_in_rate_percent AS DOUBLE))
      comment: "Average all-in cost of debt. Cost-of-capital KPI informing refinancing decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Spread Bps"
      display_name: "Avg Spread (bps)"
      expr: AVG(CAST(spread_bps AS DOUBLE))
      comment: "Average credit spread in basis points. Pricing/credit-quality indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg DSCR Covenant"
      display_name: "Avg DSCR Covenant"
      expr: AVG(CAST(dscr_covenant AS DOUBLE))
      comment: "Average DSCR covenant threshold. Headroom context for covenant-breach monitoring."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Tenor Years"
      display_name: "Avg Tenor (Years)"
      expr: AVG(CAST(tenor_years AS DOUBLE))
      comment: "Average facility tenor in years. Duration/refinancing profile indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_distribution_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Distribution (cash return) KPIs for infrastructure investments: gross/net distribution amounts, withholding tax drag and realized-return multiples (DPI/TVPI). Used to track cash-back to the pension fund and tax efficiency of exits."
  source: "`asset_management`.`infrastructure`.`distribution_event`"
  dimensions:
    - name: "Distribution Type"
      display_name: "Distribution Type"
      expr: distribution_type
      comment: "Type of distribution (income, return of capital, capital gain)."
    - name: "Distribution Status"
      display_name: "Distribution Status"
      expr: distribution_status
      comment: "Status of the distribution (announced, paid, reconciled)."
    - name: "Distribution Source"
      display_name: "Distribution Source"
      expr: distribution_source
      comment: "Source of the distribution."
    - name: "Distribution Currency"
      display_name: "Distribution Currency"
      expr: distribution_currency
      comment: "Currency of the distribution."
    - name: "ESG Classification"
      display_name: "ESG Classification"
      expr: esg_classification
      comment: "ESG classification of the underlying distribution."
    - name: "Tax Jurisdiction"
      display_name: "Tax Jurisdiction"
      expr: tax_jurisdiction
      comment: "Tax jurisdiction applied to the distribution for tax-efficiency analysis."
    - name: "Recallable Flag"
      display_name: "Recallable"
      expr: recallable_flag
      comment: "Whether the distribution is recallable by the GP (True/False)."
    - name: "Distribution Month"
      display_name: "Distribution Month"
      expr: DATE_TRUNC('month', distribution_date)
      comment: "Month bucket of the distribution date for cash-return trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Distribution Count"
      display_name: "Distribution Count"
      expr: COUNT(1)
      comment: "Number of distribution events in scope. Baseline activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Distribution Amount"
      display_name: "Total Distribution Amount"
      expr: SUM(CAST(distribution_amount AS DOUBLE))
      comment: "Aggregate gross distribution amount received. Core cash-back KPI for beneficiary reporting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Distribution Amount"
      display_name: "Total Net Distribution Amount"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Aggregate net distribution after deductions. True cash realized by the fund."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total Withholding Tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Aggregate withholding tax on distributions. Tax-drag KPI informing treaty/structuring decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liability Matching Allocation"
      display_name: "Total Liability Matching Allocation"
      expr: SUM(CAST(liability_matching_allocation AS DOUBLE))
      comment: "Aggregate distribution amount allocated to liability matching. Links cash returns to pension liability funding."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI"
      display_name: "Avg DPI"
      expr: AVG(CAST(dpi AS DOUBLE))
      comment: "Average distributions to paid-in multiple at distribution. Realized-return indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total value to paid-in multiple at distribution. Total-return indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_fund_nav_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GP-reported fund NAV KPIs: closing NAV, capital called/distributed, unrealized/realized gains and performance multiples (DPI/RVPI/TVPI, since-inception IRR). Used for GP reconciliation, GIPS/IFRS reporting and fund performance oversight."
  source: "`asset_management`.`infrastructure`.`fund_nav_report`"
  dimensions:
    - name: "Report Type"
      display_name: "Report Type"
      expr: report_type
      comment: "Type of NAV report (quarterly, annual)."
    - name: "Report Status"
      display_name: "Report Status"
      expr: report_status
      comment: "Status of the report (received, reconciled)."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status against internal records."
    - name: "Valuation Methodology"
      display_name: "Valuation Methodology"
      expr: valuation_methodology
      comment: "Valuation methodology used by the GP."
    - name: "NAV Currency Code"
      display_name: "NAV Currency"
      expr: nav_currency_code
      comment: "Currency of the reported NAV."
    - name: "Audited Flag"
      display_name: "Audited"
      expr: audited_flag
      comment: "Whether the report is audited (True/False)."
    - name: "Reporting Period End Month"
      display_name: "Reporting Period End Month"
      expr: DATE_TRUNC('month', reporting_period_end_date)
      comment: "Month bucket of the reporting period end for NAV trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "NAV Report Count"
      display_name: "NAV Report Count"
      expr: COUNT(1)
      comment: "Number of NAV reports in scope. Baseline reporting coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Closing NAV"
      display_name: "Total Closing NAV"
      expr: SUM(CAST(closing_nav AS DOUBLE))
      comment: "Aggregate closing NAV reported. Core fund value measure for IFRS/GIPS reporting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Called"
      display_name: "Total Capital Called"
      expr: SUM(CAST(capital_called_amount AS DOUBLE))
      comment: "Aggregate capital called within the period. Deployment measure for reconciliation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Distribution"
      display_name: "Total Capital Distribution"
      expr: SUM(CAST(capital_distribution_amount AS DOUBLE))
      comment: "Aggregate capital distributions in the period. Realized cash-return measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total Unrealized Gain/Loss"
      expr: SUM(CAST(unrealized_gain_loss AS DOUBLE))
      comment: "Aggregate unrealized gain/loss. Mark-movement driver of NAV."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fee Accrued"
      display_name: "Total Management Fee Accrued"
      expr: SUM(CAST(management_fee_accrued AS DOUBLE))
      comment: "Aggregate management fees accrued. Fee-transparency KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carried Interest Accrued"
      display_name: "Total Carried Interest Accrued"
      expr: SUM(CAST(carried_interest_accrued AS DOUBLE))
      comment: "Aggregate carried interest accrued. Measures GP economics drag on net returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Since Inception IRR"
      display_name: "Avg Since-Inception IRR"
      expr: AVG(CAST(irr_since_inception_percent AS DOUBLE))
      comment: "Average since-inception IRR reported by GPs. Primary long-term performance KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI Ratio"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi_ratio AS DOUBLE))
      comment: "Average total value to paid-in ratio. Total-return KPI for fund oversight."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI Ratio"
      display_name: "Avg DPI"
      expr: AVG(CAST(dpi_ratio AS DOUBLE))
      comment: "Average distributions to paid-in ratio. Realized-return KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_infra_asset`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio-level KPIs over direct infrastructure assets: valuation, returns (IRR/MOIC), leverage, revenue quality and ESG/carbon exposure. Used by the CIO and infrastructure investment committee to steer capital allocation, leverage risk and decarbonization targets."
  source: "`asset_management`.`infrastructure`.`infra_asset`"
  dimensions:
    - name: "Asset Type"
      display_name: "Asset Type"
      expr: asset_type
      comment: "Primary infrastructure asset type (e.g. transport, energy, social) for sector allocation analysis."
    - name: "Asset Sub Type"
      display_name: "Asset Sub Type"
      expr: asset_sub_type
      comment: "Finer asset classification within a type."
    - name: "Asset Status"
      display_name: "Asset Status"
      expr: asset_status
      comment: "Lifecycle status of the asset (operational, construction, disposed, etc.)."
    - name: "Investment Stage"
      display_name: "Investment Stage"
      expr: investment_stage
      comment: "Investment stage classification (greenfield, brownfield, operational)."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the asset for geographic concentration analysis."
    - name: "Country Code"
      display_name: "Country"
      expr: country_code
      comment: "ISO country code of the asset location."
    - name: "ESG Rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "ESG rating assigned to the asset, used for SFDR sustainability steering."
    - name: "Regulated Asset Flag"
      display_name: "Regulated Asset"
      expr: regulated_asset_flag
      comment: "Whether the asset operates under a regulated return framework (True/False)."
    - name: "Renewable Energy Flag"
      display_name: "Renewable Energy"
      expr: renewable_energy_flag
      comment: "Whether the asset is a renewable energy asset (True/False)."
    - name: "Acquisition Year"
      display_name: "Acquisition Year"
      expr: DATE_TRUNC('year', acquisition_date)
      comment: "Year of asset acquisition for vintage cohort analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the most recent valuation date for time-intelligence."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Asset Count"
      display_name: "Asset Count"
      expr: COUNT(1)
      comment: "Number of infrastructure assets in scope. Baseline count for portfolio sizing."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Current Valuation"
      display_name: "Total Current Valuation"
      expr: SUM(CAST(current_valuation AS DOUBLE))
      comment: "Aggregate fair value of assets in scope. Core measure of deployed infrastructure NAV."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Acquisition Cost"
      display_name: "Total Acquisition Cost"
      expr: SUM(CAST(acquisition_cost AS DOUBLE))
      comment: "Aggregate original acquisition cost basis. Compared against current valuation to gauge value creation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Debt Outstanding"
      display_name: "Total Debt Outstanding"
      expr: SUM(CAST(debt_outstanding AS DOUBLE))
      comment: "Aggregate outstanding debt across assets. Key input to portfolio leverage monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Annual Revenue"
      display_name: "Total Annual Revenue"
      expr: SUM(CAST(annual_revenue AS DOUBLE))
      comment: "Aggregate annual revenue generated by assets. Measures income-generating capacity of the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total EBITDA"
      display_name: "Total EBITDA"
      expr: SUM(CAST(ebitda AS DOUBLE))
      comment: "Aggregate EBITDA across assets. Core operating profitability measure for infrastructure holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg IRR"
      display_name: "Avg IRR %"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average internal rate of return across assets. Primary return KPI for the investment committee."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average multiple on invested capital. Measures value multiple created per asset."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DSCR"
      display_name: "Avg DSCR"
      expr: AVG(CAST(dscr AS DOUBLE))
      comment: "Average debt service coverage ratio. Early-warning indicator of debt sustainability across the portfolio."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg LTV Ratio"
      display_name: "Avg LTV Ratio"
      expr: AVG(CAST(ltv_ratio AS DOUBLE))
      comment: "Average loan-to-value ratio. Portfolio leverage risk indicator used to trigger de-risking actions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Utilization Rate"
      display_name: "Avg Utilization Rate"
      expr: AVG(CAST(utilization_rate AS DOUBLE))
      comment: "Average operational utilization rate. Signals demand strength and asset productivity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carbon Emissions"
      display_name: "Total Annual Carbon Emissions"
      expr: SUM(CAST(carbon_emissions_annual AS DOUBLE))
      comment: "Aggregate annual carbon emissions across assets. Drives TCFD climate reporting and decarbonization targets."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Renewable Asset Count"
      display_name: "Renewable Asset Count"
      expr: COUNT(DISTINCT CASE WHEN renewable_energy_flag = TRUE THEN infra_asset_id END)
      comment: "Count of renewable energy assets. Tracks green transition progress of the portfolio."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulated Asset Count"
      display_name: "Regulated Asset Count"
      expr: COUNT(DISTINCT CASE WHEN regulated_asset_flag = TRUE THEN infra_asset_id END)
      comment: "Count of regulated-return assets. Measures exposure to inflation-linked, lower-volatility cash flows suited to liability matching."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_infra_fund_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund commitment KPIs for infrastructure LP exposures: committed vs called vs distributed capital, dry powder (unfunded), and performance multiples (DPI/RVPI/TVPI, net IRR vs target). Used for J-curve management, pacing and GP performance oversight."
  source: "`asset_management`.`infrastructure`.`infra_fund_commitment`"
  dimensions:
    - name: "Fund Strategy"
      display_name: "Fund Strategy"
      expr: fund_strategy
      comment: "Fund investment strategy for strategy allocation analysis."
    - name: "Fund Type"
      display_name: "Fund Type"
      expr: fund_type
      comment: "Type of fund vehicle."
    - name: "Commitment Status"
      display_name: "Commitment Status"
      expr: commitment_status
      comment: "Status of the commitment (active, closed, etc.)."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the fund for regional pacing."
    - name: "Sector Focus"
      display_name: "Sector Focus"
      expr: sector_focus
      comment: "Sector focus of the fund."
    - name: "ESG Classification"
      display_name: "ESG Classification"
      expr: esg_classification
      comment: "ESG classification (e.g. SFDR Article 6/8/9) for sustainability reporting."
    - name: "Internal Asset Class"
      display_name: "Internal Asset Class"
      expr: internal_asset_class
      comment: "Internal asset class mapping for the commitment."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Fund vintage year for cohort/J-curve analysis."
    - name: "Commitment Year"
      display_name: "Commitment Year"
      expr: DATE_TRUNC('year', commitment_date)
      comment: "Year the commitment was made for pacing analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Commitment Count"
      display_name: "Commitment Count"
      expr: COUNT(1)
      comment: "Number of fund commitments in scope. Baseline sizing for the LP program."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Committed Capital"
      display_name: "Total Committed Capital"
      expr: SUM(CAST(committed_capital_amount AS DOUBLE))
      comment: "Aggregate committed capital across fund commitments. Core measure of program size."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid In Capital"
      display_name: "Total Paid-In Capital"
      expr: SUM(CAST(paid_in_capital_amount AS DOUBLE))
      comment: "Aggregate capital called and funded. Measures deployment progress."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributed Capital"
      display_name: "Total Distributed Capital"
      expr: SUM(CAST(distributed_capital_amount AS DOUBLE))
      comment: "Aggregate capital distributed back to the fund. Measures realized returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment_amount AS DOUBLE))
      comment: "Aggregate undrawn commitment (dry powder). Drives liquidity planning and pacing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV"
      display_name: "Total NAV"
      expr: SUM(CAST(nav_amount AS DOUBLE))
      comment: "Aggregate current net asset value of commitments. Core unrealized value measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Net IRR"
      display_name: "Avg Net IRR"
      expr: AVG(CAST(actual_net_irr AS DOUBLE))
      comment: "Average realized net IRR across commitments. Primary GP performance KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target Net IRR"
      display_name: "Avg Target Net IRR"
      expr: AVG(CAST(target_net_irr AS DOUBLE))
      comment: "Average target net IRR underwritten at commitment. Benchmark for performance-vs-plan assessment."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI Multiple"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi_multiple AS DOUBLE))
      comment: "Average total value to paid-in multiple. Key total-return KPI for fund oversight."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI Multiple"
      display_name: "Avg DPI"
      expr: AVG(CAST(dpi_multiple AS DOUBLE))
      comment: "Average distributions to paid-in multiple. Measures realized cash return."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg RVPI Multiple"
      display_name: "Avg RVPI"
      expr: AVG(CAST(rvpi_multiple AS DOUBLE))
      comment: "Average residual value to paid-in multiple. Measures remaining unrealized value."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Rate"
      display_name: "Avg Management Fee Rate"
      expr: AVG(CAST(management_fee_rate AS DOUBLE))
      comment: "Average management fee rate across commitments. Cost-of-access KPI for fee negotiation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_project_investment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Greenfield/brownfield project investment KPIs: equity commitment/deployment, project NAV, construction completion, leverage (DSCR/leverage ratio), contracted revenue share and target-vs-actual IRR. Used to steer development-stage risk and capital deployment."
  source: "`asset_management`.`infrastructure`.`project_investment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the project."
    - name: "Sub Sector"
      display_name: "Sub Sector"
      expr: sub_sector
      comment: "Sub-sector classification of the project."
    - name: "Development Stage"
      display_name: "Development Stage"
      expr: development_stage
      comment: "Development stage of the project for construction-risk analysis."
    - name: "Investment Status"
      display_name: "Investment Status"
      expr: investment_status
      comment: "Status of the project investment."
    - name: "Project Type"
      display_name: "Project Type"
      expr: project_type
      comment: "Type of project."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the project."
    - name: "ESG Rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "ESG rating of the project."
    - name: "Greenfield Brownfield Flag"
      display_name: "Greenfield/Brownfield"
      expr: greenfield_brownfield_flag
      comment: "Whether the project is greenfield vs brownfield (True/False)."
    - name: "Investment Year"
      display_name: "Investment Year"
      expr: DATE_TRUNC('year', investment_date)
      comment: "Year of the project investment for vintage analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Project Count"
      display_name: "Project Count"
      expr: COUNT(1)
      comment: "Number of project investments in scope. Baseline portfolio sizing."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Equity Commitment"
      display_name: "Total Equity Commitment"
      expr: SUM(CAST(equity_commitment AS DOUBLE))
      comment: "Aggregate equity committed to projects. Core deployment commitment measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Equity Deployed"
      display_name: "Total Equity Deployed"
      expr: SUM(CAST(equity_deployed AS DOUBLE))
      comment: "Aggregate equity actually deployed. Measures funding progress against commitment."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Project Cost"
      display_name: "Total Project Cost"
      expr: SUM(CAST(total_project_cost AS DOUBLE))
      comment: "Aggregate total project cost. Overall capital intensity of the development pipeline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Current NAV"
      display_name: "Total Current NAV"
      expr: SUM(CAST(current_nav AS DOUBLE))
      comment: "Aggregate current NAV of project investments. Core unrealized value measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Debt Financing"
      display_name: "Total Debt Financing"
      expr: SUM(CAST(debt_financing_amount AS DOUBLE))
      comment: "Aggregate debt financing raised at the project level. Leverage input for risk monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Construction Completion"
      display_name: "Avg Construction Completion %"
      expr: AVG(CAST(construction_completion_percentage AS DOUBLE))
      comment: "Average construction completion percentage. Development-progress KPI driving construction-risk oversight."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DSCR"
      display_name: "Avg DSCR"
      expr: AVG(CAST(dscr AS DOUBLE))
      comment: "Average debt service coverage ratio. Debt-sustainability indicator at project level."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Leverage Ratio"
      display_name: "Avg Leverage Ratio"
      expr: AVG(CAST(leverage_ratio AS DOUBLE))
      comment: "Average leverage ratio across projects. Leverage-risk KPI for development portfolio."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Contracted Revenue Percentage"
      display_name: "Avg Contracted Revenue %"
      expr: AVG(CAST(contracted_revenue_percentage AS DOUBLE))
      comment: "Average share of contracted (vs merchant) revenue. Revenue-certainty KPI for liability matching suitability."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR"
      expr: AVG(CAST(target_irr AS DOUBLE))
      comment: "Average underwritten target IRR. Benchmark for performance-vs-plan assessment."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Actual IRR"
      display_name: "Avg Actual IRR"
      expr: AVG(CAST(actual_irr AS DOUBLE))
      comment: "Average realized actual IRR. Core project return outcome vs target."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`infrastructure_regulated_return_model`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulated-asset return KPIs: allowed return and WACC, regulatory asset base (RAB) movement, cost of debt/equity and gearing. Used to monitor regulated cash-flow economics that underpin inflation-linked, liability-matching returns."
  source: "`asset_management`.`infrastructure`.`regulated_return_model`"
  dimensions:
    - name: "Regulatory Framework"
      display_name: "Regulatory Framework"
      expr: regulatory_framework
      comment: "Regulatory framework governing the model (e.g. RAB-based price control)."
    - name: "Jurisdiction"
      display_name: "Jurisdiction"
      expr: jurisdiction
      comment: "Regulatory jurisdiction of the asset."
    - name: "Model Status"
      display_name: "Model Status"
      expr: model_status
      comment: "Status of the regulated return model (active, superseded)."
    - name: "Regulator Name"
      display_name: "Regulator"
      expr: regulator_name
      comment: "Name of the regulator setting the determination."
    - name: "Incentive Mechanism Type"
      display_name: "Incentive Mechanism Type"
      expr: incentive_mechanism_type
      comment: "Type of regulatory incentive mechanism."
    - name: "RAB Currency Code"
      display_name: "RAB Currency"
      expr: rab_currency_code
      comment: "Currency of the regulatory asset base."
    - name: "Effective From Year"
      display_name: "Effective From Year"
      expr: DATE_TRUNC('year', effective_from_date)
      comment: "Year the determination becomes effective for regulatory-period analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Model Count"
      display_name: "Model Count"
      expr: COUNT(1)
      comment: "Number of regulated return models in scope. Baseline coverage of regulated assets."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total RAB Closing Value"
      display_name: "Total RAB Closing Value"
      expr: SUM(CAST(rab_closing_value AS DOUBLE))
      comment: "Aggregate closing regulatory asset base. Core value driver of regulated returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total RAB Opening Value"
      display_name: "Total RAB Opening Value"
      expr: SUM(CAST(rab_opening_value AS DOUBLE))
      comment: "Aggregate opening regulatory asset base. Compared with closing to measure RAB growth."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Revenue Cap"
      display_name: "Total Revenue Cap"
      expr: SUM(CAST(revenue_cap_amount AS DOUBLE))
      comment: "Aggregate allowed revenue cap. Ceiling on regulated revenue entitlement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allowed Return Rate"
      display_name: "Avg Allowed Return Rate"
      expr: AVG(CAST(allowed_return_rate_percent AS DOUBLE))
      comment: "Average regulator-allowed return rate. Key economics KPI for regulated asset valuation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg WACC"
      display_name: "Avg WACC"
      expr: AVG(CAST(wacc_percent AS DOUBLE))
      comment: "Average allowed WACC. Discount-rate benchmark for regulated cash flows."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Cost Of Equity"
      display_name: "Avg Cost of Equity"
      expr: AVG(CAST(cost_of_equity_percent AS DOUBLE))
      comment: "Average allowed cost of equity. Return expectation for the equity-funded portion of RAB."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Gearing Ratio"
      display_name: "Avg Gearing Ratio"
      expr: AVG(CAST(gearing_ratio_percent AS DOUBLE))
      comment: "Average notional gearing assumption. Leverage context for regulated return structure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
