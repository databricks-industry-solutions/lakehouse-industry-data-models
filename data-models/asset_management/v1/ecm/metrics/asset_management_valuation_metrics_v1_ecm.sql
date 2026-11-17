-- Metric views for domain: valuation | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_adjustment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Governance layer over valuation adjustments (manual overrides, fair-value corrections, audit-driven changes). Steers valuation control quality, approval discipline and the magnitude of adjustments applied to the book."
  source: "`asset_management`.`valuation`.`adjustment`"
  dimensions:
    - name: "adjustment_type"
      display_name: "Adjustment Type"
      expr: adjustment_type
      comment: "Type of valuation adjustment applied."
    - name: "adjustment_status"
      display_name: "Adjustment Status"
      expr: adjustment_status
      comment: "Lifecycle status of the adjustment (e.g. draft, approved, rejected)."
    - name: "currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency of the adjustment amount."
    - name: "cycle_frequency"
      display_name: "Cycle Frequency"
      expr: cycle_frequency
      comment: "Frequency of the valuation cycle the adjustment belongs to."
    - name: "is_approved"
      display_name: "Is Approved"
      expr: is_approved
      comment: "Whether the adjustment has been approved."
    - name: "adjustment_month"
      display_name: "Adjustment Month"
      expr: DATE_TRUNC('month', adjustment_date)
      comment: "Month bucket of the adjustment for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "adjustment_quarter"
      display_name: "Adjustment Quarter"
      expr: DATE_TRUNC('quarter', adjustment_date)
      comment: "Quarter bucket of the adjustment for QoQ analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Adjustment Count"
      display_name: "Adjustments"
      expr: COUNT(1)
      comment: "Number of valuation adjustments. Tracks control activity and manual intervention volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Adjustment Amount"
      display_name: "Total Adjustment Amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total monetary value of valuation adjustments applied to the book."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Adjustment Amount"
      display_name: "Avg Adjustment Amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average size of a valuation adjustment, flags unusually large manual corrections."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Approved Adjustment Amount"
      display_name: "Approved Adjustment Amount"
      expr: SUM(CASE WHEN is_approved = TRUE THEN CAST(amount AS DOUBLE) ELSE 0 END)
      comment: "Total adjustment value that has passed approval controls."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unapproved Adjustment Count"
      display_name: "Unapproved Adjustments"
      expr: COUNT(CASE WHEN is_approved = FALSE THEN 1 END)
      comment: "Count of adjustments still pending approval. Governance backlog/control-gap indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: COUNT(CASE WHEN is_approved = TRUE THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "Share of adjustments that are approved. Key valuation-control discipline KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_asset_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core semantic layer over asset-level valuations. Supports NAV, GAV, fair value and book-value analytics across asset class, portfolio, currency and valuation cycle. Primary steering layer for portfolio valuation quality, mark-to-market exposure and fair-value vs book-value variance."
  source: "`asset_management`.`valuation`.`valuation_asset_valuation`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Broad asset class (e.g. public equity, private equity, real estate, infrastructure, credit) of the valued asset."
    - name: "asset_category"
      display_name: "Asset Category"
      expr: asset_category
      comment: "Finer asset category classification used for diversified allocation analysis."
    - name: "asset_sector"
      display_name: "Asset Sector"
      expr: asset_sector
      comment: "Economic sector of the underlying asset, used for sector-concentration and ESG analysis."
    - name: "asset_currency"
      display_name: "Asset Currency"
      expr: asset_currency
      comment: "Currency in which the asset is denominated."
    - name: "portfolio_type"
      display_name: "Portfolio Type"
      expr: portfolio_type
      comment: "Type of portfolio holding the asset (e.g. direct, co-investment, external fund)."
    - name: "valuation_status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Workflow/lifecycle status of the valuation record (e.g. draft, approved, finalized)."
    - name: "valuation_method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Valuation methodology applied (e.g. market, DCF, comparable transaction)."
    - name: "valuation_cycle_frequency"
      display_name: "Cycle Frequency"
      expr: valuation_cycle_frequency
      comment: "Frequency of the valuation cycle (e.g. monthly, quarterly, annual)."
    - name: "valuation_date"
      display_name: "Valuation Date"
      expr: valuation_date
      comment: "Date the asset valuation is effective as of."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "valuation_month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation month bucket for time-intelligence (MoM) analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "valuation_quarter"
      display_name: "Valuation Quarter"
      expr: DATE_TRUNC('quarter', valuation_date)
      comment: "Valuation quarter bucket for time-intelligence (QoQ) analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "valuation_year"
      display_name: "Valuation Year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "Valuation year bucket for time-intelligence (YoY) analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Valuation Record Count"
      display_name: "Valuation Records"
      expr: COUNT(1)
      comment: "Number of asset valuation records. Baseline volume for completeness and coverage monitoring."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Assets Valued"
      display_name: "Distinct Assets Valued"
      expr: COUNT(DISTINCT asset_id)
      comment: "Count of unique assets with at least one valuation, used to track valuation coverage across the book."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Asset Value"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Total NAV across valued assets. Headline measure of managed portfolio value."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Asset Value"
      display_name: "Total GAV"
      expr: SUM(CAST(gav AS DOUBLE))
      comment: "Total gross asset value before liabilities, used to analyse leverage against NAV."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fair Value"
      display_name: "Total Fair Value"
      expr: SUM(CAST(fair_value AS DOUBLE))
      comment: "Total fair value (mark-to-market) across valued assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Book Value"
      display_name: "Total Book Value"
      expr: SUM(CAST(book_value AS DOUBLE))
      comment: "Total carrying/book value across valued assets, baseline for fair-value variance analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Fair Value to Book Value Ratio"
      display_name: "Fair Value / Book Value"
      expr: SUM(CAST(fair_value AS DOUBLE)) / NULLIF(SUM(CAST(book_value AS DOUBLE)), 0)
      comment: "Ratio of fair value to book value. Signals unrealised gains (>1) or impairment risk (<1) across the book."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Average Fair Value per Asset"
      display_name: "Avg Fair Value"
      expr: AVG(CAST(fair_value AS DOUBLE))
      comment: "Average fair value per valuation record, used to spot outsized single-asset exposures."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV CM"
      display_name: "Total NAV (Current Month)"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Total NAV for the current month bucket (time-intelligence base)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: valuation_month
          range: current
          semiadditive: last
    - name: "Total NAV PM"
      display_name: "Total NAV (Prior Month)"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Total NAV for the prior month bucket (time-intelligence base)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: valuation_month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "NAV MoM Growth"
      display_name: "NAV MoM Growth"
      expr: (AGG(`Total NAV CM`) - AGG(`Total NAV PM`)) / NULLIF(AGG(`Total NAV PM`), 0)
      comment: "Month-over-month percent change in total NAV. Key steering signal for portfolio value movement."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_credit_instrument_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fixed-income/credit valuation analytics layer. Steers credit book pricing, spread/duration risk, and yield positioning across instruments, currencies and valuation cycles. Supports credit portfolio risk-return decisions."
  source: "`asset_management`.`valuation`.`credit_instrument_valuation`"
  dimensions:
    - name: "instrument_type"
      display_name: "Instrument Type"
      expr: instrument_type
      comment: "Type of credit instrument (e.g. corporate bond, govt bond, loan)."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the credit instrument valuation."
    - name: "valuation_method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Valuation methodology applied to the instrument."
    - name: "valuation_status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Status of the instrument valuation."
    - name: "valuation_month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Credit Valuation Count"
      display_name: "Credit Valuations"
      expr: COUNT(1)
      comment: "Number of credit instrument valuations. Coverage baseline for the credit book."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Market Value"
      display_name: "Total Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Total market value of valued credit instruments. Headline credit exposure measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Accrued Interest"
      display_name: "Total Accrued Interest"
      expr: SUM(CAST(accrued_interest AS DOUBLE))
      comment: "Total accrued interest carried on the credit book, relevant to dirty-price and income analysis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Yield to Maturity"
      display_name: "Avg YTM"
      expr: AVG(CAST(ytm AS DOUBLE))
      comment: "Average yield to maturity across credit instruments. Core income/return steering metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Average Duration"
      display_name: "Avg Duration"
      expr: AVG(CAST(risk_metric_duration AS DOUBLE))
      comment: "Average interest-rate duration of the credit book. Key rate-risk positioning metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Average Credit Spread"
      display_name: "Avg Credit Spread"
      expr: AVG(CAST(risk_metric_credit_spread AS DOUBLE))
      comment: "Average credit spread across the book, signalling compensation for credit risk."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Fair Value to Book Value Ratio"
      display_name: "Fair Value / Book Value"
      expr: SUM(CAST(fair_value AS DOUBLE)) / NULLIF(SUM(CAST(book_value AS DOUBLE)), 0)
      comment: "Fair value vs book value for the credit book, flagging unrealised gains or impairment."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_nav_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund-level NAV reporting layer. Supports GIPS/IFRS/Beneficiary reporting with total NAV, NAV per unit, gross asset value and liabilities by fund and valuation cycle. Steering layer for official fund valuations."
  source: "`asset_management`.`valuation`.`valuation_nav_record`"
  dimensions:
    - name: "fund_name"
      display_name: "Fund Name"
      expr: fund_name
      comment: "Name of the fund the NAV record applies to."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Reporting currency of the NAV record."
    - name: "valuation_status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Status of the NAV calculation (e.g. draft, final, published)."
    - name: "valuation_cycle_frequency"
      display_name: "Cycle Frequency"
      expr: valuation_cycle_frequency
      comment: "Frequency of the NAV valuation cycle."
    - name: "valuation_month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the NAV valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "valuation_quarter"
      display_name: "Valuation Quarter"
      expr: DATE_TRUNC('quarter', valuation_date)
      comment: "Quarter bucket of the NAV valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "NAV Record Count"
      display_name: "NAV Records"
      expr: COUNT(1)
      comment: "Number of fund NAV records produced. Reporting completeness baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Asset Value"
      display_name: "Total NAV"
      expr: SUM(CAST(net_asset_value AS DOUBLE))
      comment: "Total fund net asset value across records. Headline AUM-style measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Asset Value"
      display_name: "Total GAV"
      expr: SUM(CAST(total_gross_asset_value AS DOUBLE))
      comment: "Total gross asset value across fund NAV records."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liabilities"
      display_name: "Total Liabilities"
      expr: SUM(CAST(total_liabilities AS DOUBLE))
      comment: "Total liabilities deducted in the NAV calculation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average NAV per Unit"
      display_name: "Avg NAV per Unit"
      expr: AVG(CAST(nav_per_unit AS DOUBLE))
      comment: "Average NAV per fund unit, tracked for per-unit value movements driving beneficiary statements."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Liability to GAV Ratio"
      display_name: "Liability / GAV"
      expr: SUM(CAST(total_liabilities AS DOUBLE)) / NULLIF(SUM(CAST(total_gross_asset_value AS DOUBLE)), 0)
      comment: "Liabilities as a share of gross asset value. Leverage/gearing indicator for fund valuations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV CM"
      display_name: "Total NAV (Current Month)"
      expr: SUM(CAST(net_asset_value AS DOUBLE))
      comment: "Total fund NAV for current month bucket (time-intelligence base)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: valuation_month
          range: current
          semiadditive: last
    - name: "Total NAV PM"
      display_name: "Total NAV (Prior Month)"
      expr: SUM(CAST(net_asset_value AS DOUBLE))
      comment: "Total fund NAV for prior month bucket (time-intelligence base)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: valuation_month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Fund NAV MoM Growth"
      display_name: "Fund NAV MoM Growth"
      expr: (AGG(`Total NAV CM`) - AGG(`Total NAV PM`)) / NULLIF(AGG(`Total NAV PM`), 0)
      comment: "Month-over-month change in total fund NAV. Core fund performance steering signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_price_exception`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Price-exception monitoring layer. Steers pricing data quality by quantifying exceptions raised against valuation prices, their severity, and the magnitude of threshold breaches. Drives data-vendor remediation and control escalation."
  source: "`asset_management`.`valuation`.`price_exception`"
  dimensions:
    - name: "exception_type"
      display_name: "Exception Type"
      expr: exception_type
      comment: "Category of the price exception raised."
    - name: "exception_severity"
      display_name: "Exception Severity"
      expr: exception_severity
      comment: "Severity classification of the exception (e.g. low, medium, high, critical)."
    - name: "exception_status"
      display_name: "Exception Status"
      expr: exception_status
      comment: "Workflow status of the exception (e.g. open, resolved, waived)."
    - name: "exception_source_system"
      display_name: "Source System"
      expr: exception_source_system
      comment: "Source system that generated the exception."
    - name: "exception_month"
      display_name: "Exception Month"
      expr: DATE_TRUNC('month', exception_timestamp)
      comment: "Month bucket of the exception for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Price Exception Count"
      display_name: "Price Exceptions"
      expr: COUNT(1)
      comment: "Number of price exceptions raised. Core pricing data-quality signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Exception Count"
      display_name: "Open Exceptions"
      expr: COUNT(CASE WHEN exception_status = 'OPEN' THEN 1 END)
      comment: "Count of unresolved price exceptions. Operational backlog and control-risk indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Exception Count"
      display_name: "Critical Exceptions"
      expr: COUNT(CASE WHEN exception_severity = 'CRITICAL' THEN 1 END)
      comment: "Count of critical-severity exceptions requiring immediate escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Threshold Breach Value"
      display_name: "Avg Breach Value"
      expr: AVG(CAST(exception_value AS DOUBLE))
      comment: "Average breach value of raised exceptions, indicating magnitude of pricing deviations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Open Exception Rate"
      display_name: "Open Exception Rate"
      expr: COUNT(CASE WHEN exception_status = 'OPEN' THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "Share of exceptions still open. Key pricing-control responsiveness KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_private_asset_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private-markets (PE/direct) valuation analytics layer. Steers private asset marks, WACC/discount assumptions and fair-value vs book-value variance across asset class, currency and valuation cycle."
  source: "`asset_management`.`valuation`.`private_asset_valuation`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the private asset (e.g. buyout, growth, infrastructure)."
    - name: "asset_type"
      display_name: "Asset Type"
      expr: asset_type
      comment: "Type of private asset valued."
    - name: "asset_currency"
      display_name: "Currency"
      expr: asset_currency
      comment: "Currency of the private asset valuation."
    - name: "valuation_method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Valuation methodology applied (e.g. DCF, comparable transaction)."
    - name: "valuation_status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Status of the private asset valuation."
    - name: "valuation_cycle_frequency"
      display_name: "Cycle Frequency"
      expr: valuation_cycle_frequency
      comment: "Frequency of the valuation cycle."
    - name: "valuation_month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month bucket of the valuation date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Private Valuation Count"
      display_name: "Private Valuations"
      expr: COUNT(1)
      comment: "Number of private asset valuations. Coverage baseline for private markets."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fair Value"
      display_name: "Total Fair Value"
      expr: SUM(CAST(fair_value AS DOUBLE))
      comment: "Total fair value of private assets. Headline private-markets exposure measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Asset Value"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Total NAV of private assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average WACC"
      display_name: "Avg WACC"
      expr: AVG(CAST(wacc_rate AS DOUBLE))
      comment: "Average weighted-average-cost-of-capital assumption used in private valuations. Key assumption-governance metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Fair Value to Book Value Ratio"
      display_name: "Fair Value / Book Value"
      expr: SUM(CAST(fair_value AS DOUBLE)) / NULLIF(SUM(CAST(book_value AS DOUBLE)), 0)
      comment: "Fair value vs book value for private assets, signalling unrealised value creation or markdowns."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_real_estate_appraisal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Real-estate appraisal analytics layer. Steers property valuation across type, geography and appraiser, including appraised value and value-per-sqft benchmarking for the real-estate allocation."
  source: "`asset_management`.`valuation`.`real_estate_appraisal`"
  dimensions:
    - name: "property_type"
      display_name: "Property Type"
      expr: property_type
      comment: "Type of property appraised (e.g. office, retail, industrial, residential)."
    - name: "property_country"
      display_name: "Country"
      expr: property_country
      comment: "Country where the property is located."
    - name: "property_city"
      display_name: "City"
      expr: property_city
      comment: "City where the property is located."
    - name: "appraisal_method"
      display_name: "Appraisal Method"
      expr: appraisal_method
      comment: "Appraisal methodology applied (e.g. income, comparable sales, cost)."
    - name: "appraiser_firm"
      display_name: "Appraiser Firm"
      expr: appraiser_firm
      comment: "Independent appraiser firm that produced the appraisal."
    - name: "appraisal_currency"
      display_name: "Currency"
      expr: appraisal_currency
      comment: "Currency of the appraised value."
    - name: "appraisal_month"
      display_name: "Appraisal Month"
      expr: DATE_TRUNC('month', appraisal_date)
      comment: "Month bucket of the appraisal date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Appraisal Count"
      display_name: "Appraisals"
      expr: COUNT(1)
      comment: "Number of property appraisals. Coverage baseline for the real-estate book."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Appraised Value"
      display_name: "Total Appraised Value"
      expr: SUM(CAST(appraised_value AS DOUBLE))
      comment: "Total appraised value of the real-estate portfolio. Headline property allocation measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Appraised Value"
      display_name: "Avg Appraised Value"
      expr: AVG(CAST(appraised_value AS DOUBLE))
      comment: "Average appraised value per property, flags outsized single-property exposures."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Appraised Area"
      display_name: "Total Area (sqft)"
      expr: SUM(CAST(property_area_sqft AS DOUBLE))
      comment: "Total appraised floor area in square feet, denominator for value-per-sqft benchmarking."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Value per Square Foot"
      display_name: "Value per Sqft"
      expr: SUM(CAST(appraised_value AS DOUBLE)) / NULLIF(SUM(CAST(property_area_sqft AS DOUBLE)), 0)
      comment: "Blended appraised value per square foot. Key property pricing benchmark across markets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`valuation_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Valuation governance and review-cycle layer. Steers approval throughput, review coverage and control effectiveness over the valuation process. Supports SOX internal-controls attestation."
  source: "`asset_management`.`valuation`.`valuation_review`"
  dimensions:
    - name: "review_type"
      display_name: "Review Type"
      expr: review_type
      comment: "Type of valuation review performed."
    - name: "review_status"
      display_name: "Review Status"
      expr: review_status
      comment: "Status of the review (e.g. in-progress, completed)."
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval outcome of the review (e.g. approved, rejected, pending)."
    - name: "outcome"
      display_name: "Outcome"
      expr: outcome
      comment: "Resulting outcome of the valuation review."
    - name: "review_month"
      display_name: "Review Month"
      expr: DATE_TRUNC('month', review_date)
      comment: "Month bucket of the review date."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Review Count"
      display_name: "Reviews"
      expr: COUNT(1)
      comment: "Number of valuation reviews performed. Control-activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Review Count"
      display_name: "Approved Reviews"
      expr: COUNT(CASE WHEN approval_status = 'APPROVED' THEN 1 END)
      comment: "Count of reviews that reached approval."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rejected Review Count"
      display_name: "Rejected Reviews"
      expr: COUNT(CASE WHEN approval_status = 'REJECTED' THEN 1 END)
      comment: "Count of reviews rejected, signalling valuation quality or control issues."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: COUNT(CASE WHEN approval_status = 'APPROVED' THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "Share of reviews approved. Key valuation-governance throughput and quality KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Valuations Reviewed"
      display_name: "Valuations Reviewed"
      expr: COUNT(DISTINCT valuation_asset_valuation_id)
      comment: "Count of unique asset valuations subject to review, measuring review coverage."
      format:
        type: number
        decimal_places:
          type: all
$$;
