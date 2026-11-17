-- Metric views for domain: fee | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_calculation_run`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee calculation engine outputs — gross/net fee amounts, offsets and adjustments by period and fee type; the authoritative view of fees actually computed against AUM/NAV."
  source: "`asset_management`.`fee`.`fee_calculation_run`"
  dimensions:
    - name: "Fee Type"
      display_name: "Fee Type"
      expr: fee_type
      comment: "Type of fee computed in the run (management, performance, etc.)."
    - name: "Run Status"
      display_name: "Run Status"
      expr: run_status
      comment: "Processing status of the calculation run."
    - name: "Calculation Methodology"
      display_name: "Calculation Methodology"
      expr: calculation_methodology
      comment: "Methodology applied in the calculation run."
    - name: "Fee Currency"
      display_name: "Fee Currency"
      expr: fee_currency_code
      comment: "Currency the fee amount is denominated in."
    - name: "Calculation Month"
      display_name: "Calculation Month"
      expr: DATE_TRUNC('month', calculation_date)
      comment: "Month bucket of the fee calculation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Calculation Year"
      display_name: "Calculation Year"
      expr: DATE_TRUNC('year', calculation_date)
      comment: "Year bucket of the fee calculation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Gross Fee Amount"
      display_name: "Gross Fee Amount"
      expr: SUM(CAST(gross_fee_amount AS DOUBLE))
      comment: "Total gross fees computed — top-line cost before offsets, key to total expense ratio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Fee Amount"
      display_name: "Net Fee Amount"
      expr: SUM(CAST(net_fee_amount AS DOUBLE))
      comment: "Total net fees after offsets/adjustments — the amount actually payable, drives fund cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Offset Amount"
      display_name: "Offset Amount"
      expr: SUM(CAST(offset_amount AS DOUBLE))
      comment: "Total fee offsets applied — measures value recaptured from transaction/monitoring fees."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Adjustment Amount"
      display_name: "Adjustment Amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total manual adjustments to computed fees — flags recurring calculation corrections."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg AUM Basis"
      display_name: "Avg AUM Basis"
      expr: AVG(CAST(aum_basis_amount AS DOUBLE))
      comment: "Average AUM basis used for fee calculation — denominator context for effective fee rate."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Hurdle Met Count"
      display_name: "Hurdle met count"
      expr: COUNT(CASE WHEN hurdle_met_flag = TRUE THEN 1 END)
      comment: "Runs where the performance hurdle was met — triggers performance-fee accrual."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Net Fee CM"
      display_name: "Net Fee (Current Month)"
      expr: SUM(CAST(net_fee_amount AS DOUBLE))
      comment: "Net fee for the current month bucket."
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
    - name: "Net Fee PM"
      display_name: "Net Fee (Prior Month)"
      expr: SUM(CAST(net_fee_amount AS DOUBLE))
      comment: "Net fee for the prior month bucket."
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
    - name: "Net Fee MoM"
      display_name: "Net Fee MoM"
      expr: (AGG(`Net Fee CM`) - AGG(`Net Fee PM`)) / NULLIF(AGG(`Net Fee PM`), 0)
      comment: "Month-over-month growth in net fees — tracks fee cost trajectory for steering reviews."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_carry_distribution`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Carried-interest distributions to GPs — gross/net carry, preferred return, catch-up and tax withholding tied to realization events and waterfall tiers."
  source: "`asset_management`.`fee`.`carry_distribution`"
  dimensions:
    - name: "Distribution Status"
      display_name: "Distribution Status"
      expr: distribution_status
      comment: "Status of the carry distribution."
    - name: "Waterfall Tier"
      display_name: "Waterfall Tier"
      expr: waterfall_tier
      comment: "Distribution waterfall tier the carry falls in."
    - name: "Realization Event Type"
      display_name: "Realization Event Type"
      expr: realization_event_type
      comment: "Type of realization event triggering the distribution."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Distribution currency."
    - name: "Distribution Year"
      display_name: "Distribution Year"
      expr: DATE_TRUNC('year', distribution_date)
      comment: "Year bucket of the distribution date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Carry Net Amount"
      display_name: "Carry Net Amount"
      expr: SUM(CAST(carry_net_amount AS DOUBLE))
      comment: "Total net carried interest distributed to GPs — key economic-sharing cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Carry Gross Amount"
      display_name: "Carry Gross Amount"
      expr: SUM(CAST(carry_gross_amount AS DOUBLE))
      comment: "Total gross carry before withholding and reserves."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Preferred Return Amount"
      display_name: "Preferred Return Amount"
      expr: SUM(CAST(preferred_return_amount AS DOUBLE))
      comment: "Total preferred return paid to LPs ahead of carry — hurdle economics."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Clawback Reserve Amount"
      display_name: "Clawback Reserve Amount"
      expr: SUM(CAST(clawback_reserve_amount AS DOUBLE))
      comment: "Total clawback reserve withheld against distributions — protects LPs from GP overdistribution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Tax Withholding Amount"
      display_name: "Tax Withholding Amount"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withheld on carry distributions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Fund MOIC"
      display_name: "Avg Fund MOIC"
      expr: AVG(CAST(fund_moic AS DOUBLE))
      comment: "Average fund MOIC at distribution — performance context for carry paid."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Fund IRR"
      display_name: "Avg Fund IRR"
      expr: AVG(CAST(fund_irr_percent AS DOUBLE))
      comment: "Average fund IRR at distribution — performance context for carry paid."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_clawback_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GP carried-interest clawback events — recoverable overpayments, settlement status and disputes critical to LP capital protection and recovery governance."
  source: "`asset_management`.`fee`.`clawback_event`"
  dimensions:
    - name: "Event Status"
      display_name: "Event Status"
      expr: event_status
      comment: "Status of the clawback event."
    - name: "Trigger Reason"
      display_name: "Trigger Reason"
      expr: trigger_reason
      comment: "Reason the clawback was triggered."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Settlement method for the clawback recovery."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Clawback currency."
    - name: "Trigger Year"
      display_name: "Trigger Year"
      expr: DATE_TRUNC('year', trigger_date)
      comment: "Year bucket of the clawback trigger date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Clawback Net Amount"
      display_name: "Clawback Net Amount"
      expr: SUM(CAST(clawback_net_amount AS DOUBLE))
      comment: "Total net clawback recoverable from GPs — direct LP capital protection value."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Clawback Gross Amount"
      display_name: "Clawback Gross Amount"
      expr: SUM(CAST(clawback_gross_amount AS DOUBLE))
      comment: "Total gross clawback liability before offsets and caps."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Offset Amount"
      display_name: "Offset Amount"
      expr: SUM(CAST(offset_amount AS DOUBLE))
      comment: "Total offsets reducing clawback liability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Event Count"
      display_name: "Disputed event count"
      expr: COUNT(CASE WHEN dispute_flag = TRUE THEN 1 END)
      comment: "Clawback events in dispute — recovery risk and legal exposure signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waived Event Count"
      display_name: "Waived event count"
      expr: COUNT(CASE WHEN waiver_flag = TRUE THEN 1 END)
      comment: "Clawback events waived — forgone recovery requiring governance scrutiny."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Event Count"
      display_name: "Event count"
      expr: COUNT(1)
      comment: "Total clawback events — volume baseline for recovery program."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_dispute`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee disputes with managers — disputed vs resolved amounts, refunds and escalation to drive overcharge recovery and manager governance."
  source: "`asset_management`.`fee`.`dispute`"
  dimensions:
    - name: "Dispute Status"
      display_name: "Dispute Status"
      expr: dispute_status
      comment: "Current status of the dispute."
    - name: "Dispute Type"
      display_name: "Dispute Type"
      expr: dispute_type
      comment: "Type/classification of the fee dispute."
    - name: "Category"
      display_name: "Category"
      expr: dispute_category
      comment: "Dispute dispute_category."
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority assigned to the dispute."
    - name: "Resolution Outcome"
      display_name: "Resolution Outcome"
      expr: resolution_outcome
      comment: "Outcome of the dispute resolution."
    - name: "Raised Year"
      display_name: "Raised Year"
      expr: DATE_TRUNC('year', raised_date)
      comment: "Year bucket the dispute was raised."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Disputed Amount"
      display_name: "Disputed Amount"
      expr: SUM(CAST(disputed_amount AS DOUBLE))
      comment: "Total amount under dispute — overcharge exposure being contested."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Resolved Amount"
      display_name: "Resolved Amount"
      expr: SUM(CAST(resolved_amount AS DOUBLE))
      comment: "Total amount resolved — recovery realized through dispute process."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Refund Amount"
      display_name: "Refund Amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total refunds secured from managers — direct cost recovery."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Variance Amount"
      display_name: "Variance Amount"
      expr: SUM(CAST(variance_amount AS DOUBLE))
      comment: "Total variance between claimed and correct amounts — fee accuracy gap."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Escalated Count"
      display_name: "Escalated count"
      expr: COUNT(CASE WHEN escalation_flag = TRUE THEN 1 END)
      comment: "Disputes escalated — governance intensity and unresolved-risk signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "NAV Impacting Count"
      display_name: "Nav impacting count"
      expr: COUNT(CASE WHEN impact_on_nav_flag = TRUE THEN 1 END)
      comment: "Disputes with NAV impact — material to valuation integrity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Dispute Count"
      display_name: "Dispute count"
      expr: COUNT(1)
      comment: "Total number of fee disputes — baseline volume."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_gp_fee_rebate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GP fee rebates and management-fee offsets — value recaptured from transaction/monitoring fees, central to fee transparency and LP net-cost reduction."
  source: "`asset_management`.`fee`.`gp_fee_rebate`"
  dimensions:
    - name: "Rebate Type"
      display_name: "Rebate Type"
      expr: rebate_type
      comment: "Type of fee rebate."
    - name: "Rebate Status"
      display_name: "Rebate Status"
      expr: rebate_status
      comment: "Status of the rebate."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Rebate currency."
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_date)
      comment: "Year bucket the rebate became effective."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Rebate Net Amount"
      display_name: "Rebate Net Amount"
      expr: SUM(CAST(rebate_net_amount AS DOUBLE))
      comment: "Total net rebate value recaptured — direct reduction of net fee cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Management Fee Offset"
      display_name: "Management Fee Offset"
      expr: SUM(CAST(management_fee_offset_amount AS DOUBLE))
      comment: "Total management-fee offset credited to the fund — key LP economic benefit."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Cumulative Rebate Amount"
      display_name: "Cumulative Rebate Amount"
      expr: SUM(CAST(cumulative_rebate_amount AS DOUBLE))
      comment: "Total cumulative rebate captured across the lifecycle."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Rebate Count"
      display_name: "Disputed rebate count"
      expr: COUNT(CASE WHEN dispute_flag = TRUE THEN 1 END)
      comment: "Rebates in dispute — unrealized recapture risk."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Rebate Percentage"
      display_name: "Avg Rebate Percentage"
      expr: AVG(CAST(rebate_percentage AS DOUBLE))
      comment: "Average contractual rebate percentage — negotiation benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_high_water_mark`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "High-water-mark tracking for performance fees — accrued vs paid performance fees and underperformance carryforward governing incentive-fee crystallization."
  source: "`asset_management`.`fee`.`high_water_mark`"
  dimensions:
    - name: "HWM Status"
      display_name: "HWM Status"
      expr: hwm_status
      comment: "Status of the high-water-mark record."
    - name: "HWM Type"
      display_name: "HWM Type"
      expr: hwm_type
      comment: "Type of high-water-mark arrangement."
    - name: "Hurdle Type"
      display_name: "Hurdle Type"
      expr: hurdle_type
      comment: "Hurdle type applied to performance fee."
    - name: "Crystallization Frequency"
      display_name: "Crystallization Frequency"
      expr: crystallization_frequency
      comment: "Frequency of performance-fee crystallization."
    - name: "Currency"
      display_name: "HWM Currency"
      expr: hwm_currency_code
      comment: "Currency of the HWM NAV values."
  measures:
    - name: "Cumulative Perf Fee Accrued"
      display_name: "Cumulative Perf Fee Accrued"
      expr: SUM(CAST(cumulative_performance_fee_accrued_amount AS DOUBLE))
      comment: "Total performance fee accrued to date — liability for incentive fees."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Cumulative Perf Fee Paid"
      display_name: "Cumulative Perf Fee Paid"
      expr: SUM(CAST(cumulative_performance_fee_paid_amount AS DOUBLE))
      comment: "Total performance fee paid to date — realized incentive cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Cumulative Underperformance"
      display_name: "Cumulative Underperformance"
      expr: SUM(CAST(cumulative_underperformance_amount AS DOUBLE))
      comment: "Total underperformance carryforward below HWM — fees not yet payable."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Performance Fee Rate"
      display_name: "Avg Performance Fee Rate"
      expr: AVG(CAST(performance_fee_rate_percent AS DOUBLE))
      comment: "Average contractual performance-fee rate across HWM arrangements."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "HWM Exceeded Count"
      display_name: "Hwm exceeded count"
      expr: COUNT(CASE WHEN hwm_exceeded_flag = TRUE THEN 1 END)
      comment: "Arrangements where NAV exceeded the HWM — triggers performance-fee crystallization."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee invoicing and payment lifecycle — billed gross/net amounts, tax, rebates and payment status for cash-flow and payable management."
  source: "`asset_management`.`fee`.`invoice`"
  dimensions:
    - name: "Fee Type"
      display_name: "Fee Type"
      expr: fee_type
      comment: "Type of fee being invoiced."
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Current payment status of the invoice."
    - name: "Fee Basis"
      display_name: "Fee Basis"
      expr: fee_basis
      comment: "Basis the invoiced fee was calculated on."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Invoice currency."
    - name: "Invoice Month"
      display_name: "Invoice Month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Month bucket of the invoice date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Invoice Count"
      display_name: "Invoice count"
      expr: COUNT(1)
      comment: "Number of fee invoices — billing volume baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Gross Fee Billed"
      display_name: "Gross Fee Billed"
      expr: SUM(CAST(gross_fee_amount AS DOUBLE))
      comment: "Total gross fee amount billed — payable exposure before deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Fee Billed"
      display_name: "Net Fee Billed"
      expr: SUM(CAST(net_fee_amount AS DOUBLE))
      comment: "Total net fee amount billed after rebate/tax adjustments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Rebate Amount"
      display_name: "Rebate Amount"
      expr: SUM(CAST(rebate_amount AS DOUBLE))
      comment: "Total rebates applied to invoices — value recaptured from managers."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Tax Amount"
      display_name: "Tax Amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax billed on invoices — tax leakage to monitor for recovery."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Invoice Count"
      display_name: "Disputed invoice count"
      expr: COUNT(CASE WHEN dispute_date IS NOT NULL THEN 1 END)
      comment: "Invoices flagged with a dispute — operational and recovery risk indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Fee Variance Bps"
      display_name: "Avg Fee Variance (bps)"
      expr: AVG(CAST(fee_variance_bps AS DOUBLE))
      comment: "Average variance (bps) between billed and benchmark fee rate — overcharge detection."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_management_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Management fee arrangement economics — base/post-investment rates, tiering prevalence and MFN exposure used to steer manager fee negotiation and cost control."
  source: "`asset_management`.`fee`.`management_fee`"
  dimensions:
    - name: "Asset Class"
      display_name: "Fee Arrangement Code"
      expr: fee_arrangement_code
      comment: "Fee arrangement code grouping distinct management-fee structures."
    - name: "Fee Basis"
      display_name: "Fee Basis"
      expr: fee_basis
      comment: "Basis the fee is charged on (e.g. committed vs invested capital)."
    - name: "Fee Type"
      display_name: "Fee Type"
      expr: fee_type
      comment: "Type of management fee arrangement."
    - name: "Fee Arrangement Status"
      display_name: "Fee Arrangement Status"
      expr: fee_arrangement_status
      comment: "Lifecycle status of the fee arrangement."
    - name: "Regulatory Category"
      display_name: "Regulatory Reporting Category"
      expr: regulatory_reporting_category
      comment: "Regulatory reporting classification of the fee arrangement."
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_start_date)
      comment: "Year the fee arrangement became effective."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Arrangement Count"
      display_name: "Arrangement count"
      expr: COUNT(1)
      comment: "Number of management-fee arrangements — baseline volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Base Fee Rate"
      display_name: "Avg Base Fee Rate"
      expr: AVG(CAST(base_fee_rate AS DOUBLE))
      comment: "Average contractual base management-fee rate — core cost benchmark for manager negotiation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Post Investment Rate"
      display_name: "Avg Post-Investment Rate"
      expr: AVG(CAST(post_investment_period_rate AS DOUBLE))
      comment: "Average post-investment-period fee rate — governs fee step-downs after the investment period."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Hurdle Rate"
      display_name: "Avg Hurdle Rate"
      expr: AVG(CAST(hurdle_rate AS DOUBLE))
      comment: "Average contractual hurdle rate across management-fee arrangements."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "MFN Clause Count"
      display_name: "Mfn clause count"
      expr: COUNT(CASE WHEN most_favored_nation_clause = TRUE THEN 1 END)
      comment: "Arrangements carrying a Most-Favored-Nation clause — material for ensuring the fund receives best available terms."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Tiered Schedule Count"
      display_name: "Tiered schedule count"
      expr: COUNT(CASE WHEN tiered_schedule_flag = TRUE THEN 1 END)
      comment: "Arrangements using a tiered fee schedule — drives scale-based fee savings."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Offset Percentage"
      display_name: "Avg Offset Percentage"
      expr: AVG(CAST(offset_percentage AS DOUBLE))
      comment: "Average fee-offset percentage reducing management fees for other fee income."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee payment settlement — net cash outflows, withholding tax, late-payment penalties and reconciliation status for treasury and controls."
  source: "`asset_management`.`fee`.`payment`"
  dimensions:
    - name: "Fee Type"
      display_name: "Fee Type"
      expr: fee_type
      comment: "Type of fee paid."
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Current status of the payment."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: method
      comment: "Settlement method used for the payment."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation state of the payment."
    - name: "Payment Month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Month bucket of the payment date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Net Payment Amount"
      display_name: "Net Payment Amount"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Total net cash paid for fees — core treasury outflow metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Gross Payment Amount"
      display_name: "Gross Payment Amount"
      expr: SUM(CAST(gross_payment_amount AS DOUBLE))
      comment: "Total gross fee payments before deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Withholding Tax Paid"
      display_name: "Withholding Tax Paid"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Total withholding tax on fee payments — tax-reclaim opportunity tracking."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Late Payment Penalty"
      display_name: "Late Payment Penalty"
      expr: SUM(CAST(late_payment_penalty_amount AS DOUBLE))
      comment: "Total late-payment penalties incurred — avoidable cost signalling process failures."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Late Payment Count"
      display_name: "Late payment count"
      expr: COUNT(CASE WHEN is_late_payment = TRUE THEN 1 END)
      comment: "Count of late fee payments — operational SLA breach indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Clawback Applied Amount"
      display_name: "Clawback Applied Amount"
      expr: SUM(CAST(clawback_amount AS DOUBLE))
      comment: "Total clawback amounts netted against payments — GP overpayment recovery."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_transparency_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee transparency reporting — total fees paid by asset class, carried interest, peer-median benchmarking and GIPS compliance for board and regulatory oversight."
  source: "`asset_management`.`fee`.`transparency_report`"
  dimensions:
    - name: "Report Type"
      display_name: "Report Type"
      expr: report_type
      comment: "Type of transparency report."
    - name: "Report Status"
      display_name: "Report Status"
      expr: report_status
      comment: "Status of the transparency report."
    - name: "Recipient Category"
      display_name: "Recipient Category"
      expr: recipient_category
      comment: "Audience/recipient category for the report."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Reporting currency."
    - name: "Reporting Period End Year"
      display_name: "Reporting Period End Year"
      expr: DATE_TRUNC('year', reporting_period_end_date)
      comment: "Year bucket of the reporting period end."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Fees Paid"
      display_name: "Total Fees Paid"
      expr: SUM(CAST(total_fees_paid_amount AS DOUBLE))
      comment: "Total fees paid across all categories — headline cost-of-management disclosure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Management Fees Paid"
      display_name: "Total Management Fees Paid"
      expr: SUM(CAST(total_management_fees_paid_amount AS DOUBLE))
      comment: "Total management fees paid — recurring base cost component."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carried Interest Paid"
      display_name: "Total Carried Interest Paid"
      expr: SUM(CAST(total_carried_interest_paid_amount AS DOUBLE))
      comment: "Total carried interest paid — performance-linked cost to the fund."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Performance Fees Paid"
      display_name: "Total Performance Fees Paid"
      expr: SUM(CAST(total_performance_fees_paid_amount AS DOUBLE))
      comment: "Total performance fees paid across mandates."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Total Fee Rate Bps"
      display_name: "Avg Total Fee Rate (bps)"
      expr: AVG(CAST(total_fee_rate_bps AS DOUBLE))
      comment: "Average all-in fee rate (bps) — effective cost ratio for benchmarking."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Variance To Peer Median Bps"
      display_name: "Avg Variance to Peer Median (bps)"
      expr: AVG(CAST(variance_to_peer_median_bps AS DOUBLE))
      comment: "Average variance to peer-median fee (bps) — competitiveness of fees paid."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "GIPS Compliant Count"
      display_name: "Gips compliant count"
      expr: COUNT(CASE WHEN gips_compliant_flag = TRUE THEN 1 END)
      comment: "Reports flagged GIPS-compliant — regulatory compliance posture."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`fee_waiver`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee waivers granted — cumulative waived amounts, rate reductions and MFN/side-letter linkage, used to track concessions and net effective fee rates."
  source: "`asset_management`.`fee`.`waiver`"
  dimensions:
    - name: "Waiver Type"
      display_name: "Waiver Type"
      expr: waiver_type
      comment: "Type of fee waiver."
    - name: "Waiver Status"
      display_name: "Waiver Status"
      expr: waiver_status
      comment: "Status of the waiver."
    - name: "Regulatory Category"
      display_name: "Regulatory Reporting Category"
      expr: regulatory_reporting_category
      comment: "Regulatory reporting classification of the waiver."
    - name: "Currency"
      display_name: "Currency Code"
      expr: currency_code
      comment: "Waiver currency."
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_start_date)
      comment: "Year bucket the waiver became effective."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Cumulative Waiver Amount"
      display_name: "Cumulative Waiver Amount"
      expr: SUM(CAST(cumulative_waiver_amount AS DOUBLE))
      comment: "Total cumulative fees waived — concession value and net-cost reduction."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Waiver Rate"
      display_name: "Avg Waiver Rate"
      expr: AVG(CAST(rate_percent AS DOUBLE))
      comment: "Average waived fee rate — magnitude of concession per arrangement."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Net Fee Rate"
      display_name: "Avg Net Fee Rate"
      expr: AVG(CAST(net_fee_rate_percent AS DOUBLE))
      comment: "Average net fee rate after waiver — effective fee benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "MFN Linked Count"
      display_name: "Mfn linked count"
      expr: COUNT(CASE WHEN most_favored_nation_clause_flag = TRUE THEN 1 END)
      comment: "Waivers linked to an MFN clause — best-terms assurance tracking."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waiver Count"
      display_name: "Waiver count"
      expr: COUNT(1)
      comment: "Total number of fee waivers — concession volume baseline."
      format:
        type: number
        decimal_places:
          type: all
$$;
