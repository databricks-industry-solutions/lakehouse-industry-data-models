-- Metric views for domain: credit | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_cds_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Credit default swap position semantic layer: notional exposure, mark-to-market, spread risk (DV01, market spread), collateral posting, and clearing status. Used by derivatives and credit hedging desks to monitor protection exposure and counterparty/collateral posture."
  source: "`asset_management`.`credit`.`cds_position`"
  dimensions:
    - name: "Protection Direction"
      display_name: "Protection Direction"
      expr: protection_direction
      comment: "Whether the position buys or sells protection."
    - name: "Position Status"
      display_name: "Position Status"
      expr: position_status
      comment: "Lifecycle status of the CDS position."
    - name: "Clearing Status"
      display_name: "Clearing Status"
      expr: clearing_status
      comment: "Whether the CDS is cleared and its clearing state."
    - name: "Seniority"
      display_name: "Seniority"
      expr: seniority
      comment: "Seniority of the reference obligation."
    - name: "Index Flag"
      display_name: "Index CDS"
      expr: index_flag
      comment: "Whether the position is a CDS index vs single-name."
    - name: "Reference Entity Name"
      display_name: "Index Name"
      expr: index_name
      comment: "CDS index name for index-based positions."
    - name: "Notional Currency"
      display_name: "Notional Currency"
      expr: notional_currency
      comment: "Currency of the notional amount."
    - name: "Trade Month"
      display_name: "Trade Month"
      expr: DATE_TRUNC('month', trade_date)
      comment: "Month the CDS was traded."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Notional"
      display_name: "Total Notional"
      expr: SUM(CAST(notional_amount AS DOUBLE))
      comment: "Total CDS notional exposure — gross protection size."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Market Value"
      display_name: "Total Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Total mark-to-market value of CDS positions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total DV01"
      display_name: "Total DV01"
      expr: SUM(CAST(dv01 AS DOUBLE))
      comment: "Aggregate spread DV01 — sensitivity to a 1bp credit-spread move."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Collateral Posted"
      display_name: "Net Collateral Posted"
      expr: SUM(CAST(collateral_posted AS DOUBLE) - CAST(collateral_received AS DOUBLE))
      comment: "Net collateral posted less received — counterparty collateral exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Notional Weighted Avg Market Spread"
      display_name: "Wtd Avg Market Spread (bps)"
      expr: SUM(CAST(market_spread_bps AS DOUBLE) * CAST(notional_amount AS DOUBLE)) / NULLIF(SUM(CAST(notional_amount AS DOUBLE)), 0)
      comment: "Notional-weighted market spread in bps — blended credit-spread level of the CDS book."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Credit Event Count"
      display_name: "Credit Event Count"
      expr: SUM(CASE WHEN credit_event_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Number of CDS positions that experienced a credit event — trigger/settlement workload."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Position Count"
      display_name: "Position Count"
      expr: COUNT(1)
      comment: "Baseline count of CDS positions."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_coupon_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coupon income semantic layer: gross and net coupon income, withholding tax drag, and tax reclaim eligibility across fixed income holdings. Used by income/treasury teams to forecast cash yield and manage tax leakage."
  source: "`asset_management`.`credit`.`coupon_payment`"
  dimensions:
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Status of the coupon payment."
    - name: "Payment Type"
      display_name: "Payment Type"
      expr: payment_type
      comment: "Type of coupon payment."
    - name: "Payment Frequency"
      display_name: "Payment Frequency"
      expr: payment_frequency
      comment: "Coupon payment frequency."
    - name: "Income Classification"
      display_name: "Income Classification"
      expr: income_classification
      comment: "Income classification for reporting."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status of the coupon payment."
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Base reporting currency."
    - name: "Payment Month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Month of coupon payment for income trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Gross Coupon Income"
      display_name: "Total Gross Coupon Income"
      expr: SUM(CAST(coupon_amount_base AS DOUBLE))
      comment: "Total gross coupon income in base currency — core income measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Coupon Income"
      display_name: "Total Net Coupon Income"
      expr: SUM(CAST(net_coupon_amount_base AS DOUBLE))
      comment: "Total net coupon income after withholding tax — realized cash income."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total Withholding Tax"
      expr: SUM(CAST(withholding_tax_amount_local AS DOUBLE))
      comment: "Total withholding tax deducted (local) — tax leakage on income."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Tax Reclaim"
      display_name: "Total Tax Reclaim"
      expr: SUM(CAST(tax_reclaim_amount_local AS DOUBLE))
      comment: "Total tax reclaim amount (local) — recoverable tax to pursue."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Tax Reclaim Eligible Count"
      display_name: "Tax Reclaim Eligible Count"
      expr: SUM(CASE WHEN tax_reclaim_eligible_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of payments eligible for tax reclaim — operational reclaim pipeline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Coupon Payment Count"
      display_name: "Coupon Payment Count"
      expr: COUNT(1)
      comment: "Baseline count of coupon payments."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_covenant_monitoring`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Covenant compliance monitoring semantic layer: breach incidence, breach severity, cushion headroom, and waiver activity for private credit covenants. Used by risk and workout teams to detect deteriorating borrowers early and drive remediation."
  source: "`asset_management`.`credit`.`covenant_monitoring`"
  dimensions:
    - name: "Covenant Type"
      display_name: "Covenant Type"
      expr: covenant_type
      comment: "Type of covenant monitored (financial, incurrence, maintenance)."
    - name: "Covenant Category"
      display_name: "Covenant Category"
      expr: covenant_category
      comment: "Category classification of the covenant."
    - name: "Compliance Status"
      display_name: "Compliance Status"
      expr: compliance_status
      comment: "Current compliance status of the covenant test."
    - name: "Breach Severity"
      display_name: "Breach Severity"
      expr: breach_severity
      comment: "Severity classification of a covenant breach."
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating assigned following the covenant assessment."
    - name: "Trend Direction"
      display_name: "Trend Direction"
      expr: trend_direction
      comment: "Trend of the covenant metric (improving/deteriorating)."
    - name: "Borrower Name"
      display_name: "Borrower Name"
      expr: borrower_name
      comment: "Borrower under covenant monitoring."
    - name: "Measurement Month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month of covenant measurement for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Covenant Test Count"
      display_name: "Covenant Test Count"
      expr: COUNT(1)
      comment: "Total covenant tests performed — monitoring coverage baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Breach Count"
      display_name: "Breach Count"
      expr: SUM(CASE WHEN breach_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Number of covenant breaches — primary early-warning credit risk signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Breach Rate"
      display_name: "Breach Rate"
      expr: SUM(CASE WHEN breach_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0)
      comment: "Share of covenant tests that resulted in a breach — portfolio health KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Count"
      display_name: "Waiver Count"
      expr: SUM(CASE WHEN waiver_granted_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Number of covenant waivers granted — lender accommodation indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Cushion Percentage"
      display_name: "Avg Cushion %"
      expr: AVG(CAST(cushion_percentage AS DOUBLE))
      comment: "Average covenant cushion headroom percent — buffer against future breaches."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Borrowers Monitored"
      display_name: "Distinct Borrowers"
      expr: COUNT(DISTINCT borrower_lei)
      comment: "Number of distinct borrowers under covenant monitoring."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_default_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Credit default and loss event semantic layer: exposure at default, realized and estimated losses, recovery and LGD. Used by CRO and credit committee to quantify realized credit losses, recovery performance, and contagion risk."
  source: "`asset_management`.`credit`.`default_event`"
  dimensions:
    - name: "Event Type"
      display_name: "Event Type"
      expr: event_type
      comment: "Type of credit event (default, bankruptcy, restructuring)."
    - name: "Event Status"
      display_name: "Event Status"
      expr: event_status
      comment: "Current status of the credit event workflow."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Sector of the defaulting entity for concentration of losses."
    - name: "Seniority"
      display_name: "Seniority"
      expr: seniority
      comment: "Seniority of the defaulted instrument affecting recovery."
    - name: "Country Of Risk"
      display_name: "Country Of Risk"
      expr: country_of_risk
      comment: "Country of risk of the defaulting entity."
    - name: "Sovereign Flag"
      display_name: "Sovereign"
      expr: sovereign_flag
      comment: "Whether the default involves a sovereign entity."
    - name: "Restructuring Type"
      display_name: "Restructuring Type"
      expr: restructuring_type
      comment: "Type of restructuring associated with the event."
    - name: "Event Month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', event_date)
      comment: "Month of the default event for loss trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Default Event Count"
      display_name: "Default Event Count"
      expr: COUNT(1)
      comment: "Number of credit default events — core default incidence measure."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Exposure At Default"
      display_name: "Total EAD"
      expr: SUM(CAST(exposure_at_default AS DOUBLE))
      comment: "Total exposure at default across events — gross loss exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Loss"
      display_name: "Total Realized Loss"
      expr: SUM(CAST(realized_loss_amount AS DOUBLE))
      comment: "Total realized credit losses — actual loss impact on the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Loss"
      display_name: "Total Estimated Loss"
      expr: SUM(CAST(estimated_loss_amount AS DOUBLE))
      comment: "Total estimated credit losses for provisioning and forward loss expectation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Recovery Rate"
      display_name: "Avg Recovery Rate"
      expr: AVG(CAST(recovery_rate AS DOUBLE))
      comment: "Average recovery rate across default events — recovery performance KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Loss Given Default"
      display_name: "Avg LGD"
      expr: AVG(CAST(loss_given_default AS DOUBLE))
      comment: "Average loss given default across events — severity benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Realized Loss Rate"
      display_name: "Realized Loss Rate"
      expr: SUM(CAST(realized_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(exposure_at_default AS DOUBLE)), 0)
      comment: "Realized loss as a share of exposure at default — effective loss severity on the book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core credit portfolio holdings semantic layer: market value, unrealized P&L, risk analytics (duration, DV01, OAS, convexity), and yield exposure for fixed income credit positions. Used by CIO and fixed income PMs to steer portfolio allocation, interest-rate risk, and credit-quality posture."
  source: "`asset_management`.`credit`.`credit_position`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Broad asset class of the credit position (e.g., corporate, sovereign, structured)."
    - name: "Credit Rating"
      display_name: "Credit Rating"
      expr: credit_rating
      comment: "External credit rating bucket of the position used for credit-quality segmentation."
    - name: "Internal Credit Rating"
      display_name: "Internal Credit Rating"
      expr: internal_credit_rating
      comment: "Internally assigned credit rating for the position."
    - name: "Instrument Type"
      display_name: "Instrument Type"
      expr: instrument_type
      comment: "Type of credit instrument held."
    - name: "Seniority"
      display_name: "Seniority"
      expr: seniority
      comment: "Seniority of the position in the issuer capital structure."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Position currency used for FX and exposure segmentation."
    - name: "Position Status"
      display_name: "Position Status"
      expr: position_status
      comment: "Lifecycle status of the position (open, closed, settled)."
    - name: "Issuer Name"
      display_name: "Issuer Name"
      expr: issuer_name
      comment: "Issuer of the credit instrument, used for concentration analysis."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the valuation date for time-series analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Year"
      display_name: "Valuation Year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "Year bucket of the valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Market Value"
      display_name: "Total Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Total market value of credit positions. Core exposure measure for allocation and limit monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Book Cost"
      display_name: "Total Book Cost"
      expr: SUM(CAST(book_cost AS DOUBLE))
      comment: "Total acquisition book cost of positions, denominator for cost-vs-market analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total Unrealized G/L"
      expr: SUM(CAST(unrealized_gain_loss AS DOUBLE))
      comment: "Total unrealized gain/loss across positions. Key P&L signal for rebalancing decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Accrued Interest"
      display_name: "Total Accrued Interest"
      expr: SUM(CAST(accrued_interest AS DOUBLE))
      comment: "Total accrued interest receivable across positions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total DV01"
      display_name: "Total DV01"
      expr: SUM(CAST(dv01 AS DOUBLE))
      comment: "Aggregate dollar value of a 1bp move — core interest-rate risk exposure for the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Market Value Weighted Avg YTM"
      display_name: "MV-Weighted Avg YTM"
      expr: SUM(CAST(ytm AS DOUBLE) * CAST(market_value AS DOUBLE)) / NULLIF(SUM(CAST(market_value AS DOUBLE)), 0)
      comment: "Market-value-weighted yield to maturity of the credit book — portfolio income/return signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Market Value Weighted Avg Duration"
      display_name: "MV-Weighted Avg Duration"
      expr: SUM(CAST(duration AS DOUBLE) * CAST(market_value AS DOUBLE)) / NULLIF(SUM(CAST(market_value AS DOUBLE)), 0)
      comment: "Market-value-weighted duration — primary interest-rate sensitivity metric for the portfolio."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Market Value Weighted Avg OAS"
      display_name: "MV-Weighted Avg OAS"
      expr: SUM(CAST(oas AS DOUBLE) * CAST(market_value AS DOUBLE)) / NULLIF(SUM(CAST(market_value AS DOUBLE)), 0)
      comment: "Market-value-weighted option-adjusted spread — credit spread exposure of the book."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Issuers"
      display_name: "Distinct Issuers"
      expr: COUNT(DISTINCT issuer_lei)
      comment: "Number of distinct issuers held — diversification/concentration indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Position Count"
      display_name: "Position Count"
      expr: COUNT(1)
      comment: "Baseline count of credit positions."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across positions supporting SFDR/ESG integration steering."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_private_credit_drawdown`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private credit drawdown semantic layer: capital deployed per drawdown, cumulative drawn balances, available commitment, pricing at drawdown, and LTV/collateral posture. Used by deployment and treasury teams to pace funding and monitor leverage."
  source: "`asset_management`.`credit`.`private_credit_drawdown`"
  dimensions:
    - name: "Drawdown Status"
      display_name: "Drawdown Status"
      expr: drawdown_status
      comment: "Status of the drawdown request."
    - name: "Drawdown Purpose"
      display_name: "Drawdown Purpose"
      expr: drawdown_purpose
      comment: "Purpose of the drawdown."
    - name: "Settlement Status"
      display_name: "Settlement Status"
      expr: settlement_status
      comment: "Settlement status of the drawdown funding."
    - name: "Industry Sector"
      display_name: "Industry Sector"
      expr: industry_sector
      comment: "Borrower industry sector."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the borrower."
    - name: "Covenant Compliance Status"
      display_name: "Covenant Compliance Status"
      expr: covenant_compliance_status
      comment: "Covenant compliance status at drawdown."
    - name: "Drawdown Currency"
      display_name: "Drawdown Currency"
      expr: drawdown_currency
      comment: "Currency of the drawdown."
    - name: "Drawdown Month"
      display_name: "Drawdown Month"
      expr: DATE_TRUNC('month', drawdown_date)
      comment: "Month of the drawdown for deployment pacing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Drawdown Amount"
      display_name: "Total Drawdown Amount"
      expr: SUM(CAST(drawdown_amount AS DOUBLE))
      comment: "Total capital drawn across drawdowns — deployment volume KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Available Commitment"
      display_name: "Total Available Commitment"
      expr: SUM(CAST(available_commitment AS DOUBLE))
      comment: "Total remaining available commitment — undrawn capacity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Collateral Value"
      display_name: "Total Collateral Value"
      expr: SUM(CAST(collateral_value AS DOUBLE))
      comment: "Total collateral value pledged against drawdowns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Drawdown Weighted Avg Interest Rate"
      display_name: "Wtd Avg Interest Rate"
      expr: SUM(CAST(interest_rate_at_drawdown AS DOUBLE) * CAST(drawdown_amount AS DOUBLE)) / NULLIF(SUM(CAST(drawdown_amount AS DOUBLE)), 0)
      comment: "Drawdown-amount-weighted interest rate at funding — blended cost/yield at deployment."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 5
    - name: "Avg Loan To Value Ratio"
      display_name: "Avg LTV Ratio"
      expr: AVG(CAST(loan_to_value_ratio AS DOUBLE))
      comment: "Average loan-to-value ratio across drawdowns — leverage/credit-risk posture."
      format:
        type: number
        decimal_places:
          type: exact
          places: 5
    - name: "Drawdown Count"
      display_name: "Drawdown Count"
      expr: COUNT(1)
      comment: "Baseline count of drawdown events."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_private_credit_facility`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private credit direct-lending facility semantic layer: committed vs funded capital, unfunded dry powder, pricing (spread, all-in rate), credit risk (PD, LGD, internal rating), and fair value. Used by private credit heads to steer origination pace, deployment, and risk-adjusted pricing."
  source: "`asset_management`.`credit`.`private_credit_facility`"
  dimensions:
    - name: "Facility Type"
      display_name: "Facility Type"
      expr: facility_type
      comment: "Type of private credit facility (term loan, revolver, etc.)."
    - name: "Facility Status"
      display_name: "Facility Status"
      expr: facility_status
      comment: "Lifecycle status of the facility."
    - name: "Industry Sector"
      display_name: "Industry Sector"
      expr: industry_sector
      comment: "Borrower industry sector for sector concentration analysis."
    - name: "Seniority Rank"
      display_name: "Seniority Rank"
      expr: seniority_rank
      comment: "Seniority ranking of the facility in the capital structure."
    - name: "Internal Risk Rating"
      display_name: "Internal Risk Rating"
      expr: internal_risk_rating
      comment: "Internal risk rating of the facility."
    - name: "Interest Rate Type"
      display_name: "Interest Rate Type"
      expr: interest_rate_type
      comment: "Fixed vs floating interest rate structure."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Facility currency."
    - name: "Covenant Lite Flag"
      display_name: "Covenant Lite"
      expr: is_covenant_lite
      comment: "Whether the facility is covenant-lite, a key credit-risk posture dimension."
    - name: "Origination Month"
      display_name: "Origination Month"
      expr: DATE_TRUNC('month', origination_date)
      comment: "Month of facility origination for vintage/deployment analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Commitment"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Total committed capital across facilities — core deployment capacity measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Funded"
      display_name: "Total Funded"
      expr: SUM(CAST(funded_amount AS DOUBLE))
      comment: "Total funded capital drawn across facilities."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Total undrawn dry powder outstanding — liquidity/deployment planning signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fair Value"
      display_name: "Total Fair Value"
      expr: SUM(CAST(fair_value AS DOUBLE))
      comment: "Total fair value of private credit facilities for NAV and IFRS reporting."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Funded Ratio"
      display_name: "Funded Ratio"
      expr: SUM(CAST(funded_amount AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0)
      comment: "Share of committed capital that has been funded — deployment efficiency KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Commitment Weighted Avg All-In Rate"
      display_name: "Wtd Avg All-In Rate"
      expr: SUM(CAST(all_in_rate_percent AS DOUBLE) * CAST(commitment_amount AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0)
      comment: "Commitment-weighted all-in rate — blended yield of the private credit book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Commitment Weighted Avg Spread BPS"
      display_name: "Wtd Avg Spread (bps)"
      expr: SUM(CAST(spread_bps AS DOUBLE) * CAST(commitment_amount AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0)
      comment: "Commitment-weighted credit spread in bps — pricing discipline indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Commitment Weighted Avg PD"
      display_name: "Wtd Avg PD"
      expr: SUM(CAST(probability_of_default_percent AS DOUBLE) * CAST(commitment_amount AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0)
      comment: "Commitment-weighted probability of default — aggregate credit risk of the book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Commitment Weighted Avg LGD"
      display_name: "Wtd Avg LGD"
      expr: SUM(CAST(loss_given_default_percent AS DOUBLE) * CAST(commitment_amount AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0)
      comment: "Commitment-weighted loss given default — expected severity if borrowers default."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Facility Count"
      display_name: "Facility Count"
      expr: COUNT(1)
      comment: "Baseline count of private credit facilities."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across facilities for ESG integration monitoring."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_private_credit_repayment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private credit repayment semantic layer: principal and interest repaid, prepayment premiums, early-repayment incidence, and repayment variance. Used by portfolio finance to track cash returns, prepayment behavior, and reinvestment needs."
  source: "`asset_management`.`credit`.`private_credit_repayment`"
  dimensions:
    - name: "Repayment Type"
      display_name: "Repayment Type"
      expr: repayment_type
      comment: "Type of repayment (scheduled, prepayment, amortization)."
    - name: "Repayment Status"
      display_name: "Repayment Status"
      expr: repayment_status
      comment: "Status of the repayment transaction."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation state of the repayment."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method used to effect the repayment."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Repayment currency."
    - name: "Early Repayment Flag"
      display_name: "Early Repayment"
      expr: is_early_repayment
      comment: "Whether the repayment was early (prepayment)."
    - name: "Repayment Month"
      display_name: "Repayment Month"
      expr: DATE_TRUNC('month', repayment_date)
      comment: "Month of repayment for cash-flow trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Principal Repaid"
      display_name: "Total Principal Repaid"
      expr: SUM(CAST(principal_amount_repaid AS DOUBLE))
      comment: "Total principal repaid — capital returned to the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Interest Repaid"
      display_name: "Total Interest Repaid"
      expr: SUM(CAST(interest_amount_repaid AS DOUBLE))
      comment: "Total interest repaid — income generated by the private credit book."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Prepayment Premium"
      display_name: "Total Prepayment Premium"
      expr: SUM(CAST(prepayment_premium AS DOUBLE))
      comment: "Total prepayment premiums collected — incremental return from early repayments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Repayment Amount"
      display_name: "Total Repayment Amount"
      expr: SUM(CAST(total_repayment_amount AS DOUBLE))
      comment: "Total cash repaid including principal, interest and premiums."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Early Repayment Count"
      display_name: "Early Repayment Count"
      expr: SUM(CASE WHEN is_early_repayment = TRUE THEN 1 ELSE 0 END)
      comment: "Count of early repayments — prepayment behavior and reinvestment-risk signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Repayment Variance"
      display_name: "Total Repayment Variance"
      expr: SUM(CAST(variance_amount AS DOUBLE))
      comment: "Total variance between scheduled and actual repayment amounts — servicing accuracy signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_rating_action`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rating migration semantic layer: upgrades, downgrades, notch changes, spread impact, and policy breaches from credit rating actions. Used by credit research and risk to track portfolio credit-quality drift and policy breach incidence."
  source: "`asset_management`.`credit`.`rating_action`"
  dimensions:
    - name: "Action Type"
      display_name: "Action Type"
      expr: action_type
      comment: "Type of rating action (upgrade, downgrade, affirm, watch)."
    - name: "Rating Category"
      display_name: "Rating Category"
      expr: rating_category
      comment: "Resulting rating category of the action."
    - name: "Rating Type"
      display_name: "Rating Type"
      expr: rating_type
      comment: "Type of rating (issuer, issue, outlook)."
    - name: "Watch Status"
      display_name: "Watch Status"
      expr: watch_status
      comment: "Credit watch status following the action."
    - name: "Sector Classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector of the rated entity."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the rated entity."
    - name: "Effective Month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month the rating action became effective for migration trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Rating Action Count"
      display_name: "Rating Action Count"
      expr: COUNT(1)
      comment: "Total rating actions — monitoring volume baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Downgrade Count"
      display_name: "Downgrade Count"
      expr: SUM(CASE WHEN notch_change < 0 THEN 1 ELSE 0 END)
      comment: "Number of downgrade actions — credit-quality deterioration signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Upgrade Count"
      display_name: "Upgrade Count"
      expr: SUM(CASE WHEN notch_change > 0 THEN 1 ELSE 0 END)
      comment: "Number of upgrade actions — credit-quality improvement signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Net Notch Change"
      display_name: "Net Notch Change"
      expr: SUM(CAST(notch_change AS DOUBLE))
      comment: "Net sum of notch changes — aggregate direction of credit migration."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Policy Breach Count"
      display_name: "Policy Breach Count"
      expr: SUM(CASE WHEN investment_policy_breach_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of rating actions triggering investment policy breaches — compliance escalation signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Credit Spread Impact BPS"
      display_name: "Avg Spread Impact (bps)"
      expr: AVG(CAST(credit_spread_impact_bps AS DOUBLE))
      comment: "Average credit spread impact in bps from rating actions — valuation impact indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`credit_sovereign_debt_holding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sovereign debt holdings semantic layer: market value, cost basis, unrealized P&L, duration risk, and yield for government bond exposure. Used by rates/sovereign PMs to steer duration positioning, country exposure, and inflation-linked allocation."
  source: "`asset_management`.`credit`.`sovereign_debt_holding`"
  dimensions:
    - name: "Issuer Country"
      display_name: "Issuer Country"
      expr: issuer_country
      comment: "Sovereign issuer country — primary country-exposure dimension."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the sovereign holding."
    - name: "Accounting Classification"
      display_name: "Accounting Classification"
      expr: accounting_classification
      comment: "Accounting classification (HTM, AFS, trading)."
    - name: "Holding Status"
      display_name: "Holding Status"
      expr: holding_status
      comment: "Status of the holding."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the sovereign holding."
    - name: "Inflation Linked Flag"
      display_name: "Inflation Linked"
      expr: inflation_linked_flag
      comment: "Whether the bond is inflation-linked."
    - name: "Investment Grade Flag"
      display_name: "Investment Grade"
      expr: investment_grade_flag
      comment: "Whether the holding is investment grade."
    - name: "Maturity Year"
      display_name: "Maturity Year"
      expr: DATE_TRUNC('year', maturity_date)
      comment: "Maturity year bucket for maturity-ladder analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Market Value"
      display_name: "Total Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Total market value of sovereign holdings — core exposure measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cost Basis"
      display_name: "Total Cost Basis"
      expr: SUM(CAST(cost_basis AS DOUBLE))
      comment: "Total cost basis of sovereign holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total Unrealized G/L"
      expr: SUM(CAST(unrealized_gain_loss AS DOUBLE))
      comment: "Total unrealized gain/loss on sovereign holdings — P&L signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total DV01"
      display_name: "Total DV01"
      expr: SUM(CAST(dv01 AS DOUBLE))
      comment: "Aggregate DV01 of sovereign holdings — rate-risk exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Market Value Weighted Avg Duration"
      display_name: "MV-Weighted Avg Duration"
      expr: SUM(CAST(duration AS DOUBLE) * CAST(market_value AS DOUBLE)) / NULLIF(SUM(CAST(market_value AS DOUBLE)), 0)
      comment: "MV-weighted duration of sovereign book — primary rate-sensitivity metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Market Value Weighted Avg YTM"
      display_name: "MV-Weighted Avg YTM"
      expr: SUM(CAST(ytm AS DOUBLE) * CAST(market_value AS DOUBLE)) / NULLIF(SUM(CAST(market_value AS DOUBLE)), 0)
      comment: "MV-weighted yield to maturity — income/return signal of the sovereign book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Distinct Issuer Countries"
      display_name: "Distinct Issuer Countries"
      expr: COUNT(DISTINCT issuer_country)
      comment: "Number of distinct sovereign countries held — geographic diversification."
      format:
        type: number
        decimal_places:
          type: all
$$;
