-- Metric views for domain: performance | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_portfolio_return`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio-level time-weighted and money-weighted return KPIs with excess return, risk-adjusted ratios, and fee drag — the core performance steering layer for the fund's buy-side allocators."
  source: "`asset_management`.`performance`.`portfolio_return`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the portfolio return record (public equity, PE, real estate, etc.)"
    - name: "Return Frequency"
      display_name: "Return Frequency"
      expr: return_frequency
      comment: "Frequency at which the return was calculated (daily, monthly, quarterly)"
    - name: "Return Status"
      display_name: "Return Status"
      expr: return_status
      comment: "Lifecycle status of the return record (e.g. draft, approved, published)"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Reporting currency of the return record"
    - name: "GIPS Compliant"
      display_name: "GIPS Compliant"
      expr: gips_compliant
      comment: "Whether the return record is GIPS compliant"
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Measurement period end bucketed to month for time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Quarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', period_end_date)
      comment: "Measurement period end bucketed to quarter"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Year"
      display_name: "Period End Year"
      expr: DATE_TRUNC('year', period_end_date)
      comment: "Measurement period end bucketed to year"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Return Records"
      display_name: "Return Records"
      expr: COUNT(1)
      comment: "Count of portfolio return records — baseline volume measure"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Net TWR"
      display_name: "Avg Net TWR"
      expr: AVG(CAST(twr_net AS DOUBLE))
      comment: "Average net-of-fee time-weighted return — the headline performance measure for GIPS reporting and board review"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Gross TWR"
      display_name: "Avg Gross TWR"
      expr: AVG(CAST(twr_gross AS DOUBLE))
      comment: "Average gross-of-fee time-weighted return — used to assess manager skill before fee drag"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Net Excess Return"
      display_name: "Avg Net Excess Return"
      expr: AVG(CAST(excess_return_net AS DOUBLE))
      comment: "Average net excess return over benchmark — core measure of value-add vs passive benchmark"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Information Ratio"
      display_name: "Avg Information Ratio"
      expr: AVG(CAST(information_ratio AS DOUBLE))
      comment: "Average information ratio — risk-adjusted active return quality signal for manager retention decisions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Sharpe Ratio"
      display_name: "Avg Sharpe Ratio"
      expr: AVG(CAST(sharpe_ratio AS DOUBLE))
      comment: "Average Sharpe ratio — risk-adjusted absolute return per unit of total volatility"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Tracking Error"
      display_name: "Avg Tracking Error"
      expr: AVG(CAST(tracking_error AS DOUBLE))
      comment: "Average tracking error — active risk taken vs benchmark, monitored against mandate limits"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Management Fees"
      display_name: "Total Management Fees"
      expr: SUM(CAST(management_fee AS DOUBLE))
      comment: "Total management fees charged across return records — fee cost monitoring"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Performance Fees"
      display_name: "Total Performance Fees"
      expr: SUM(CAST(performance_fee AS DOUBLE))
      comment: "Total performance fees charged — incentive fee cost monitoring"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Ending Market Value"
      display_name: "Total Ending Market Value"
      expr: SUM(CAST(ending_market_value AS DOUBLE))
      comment: "Total ending market value across portfolios — AUM scale measure"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "GIPS Compliant Returns"
      display_name: "GIPS Compliant Returns"
      expr: COUNT(CASE WHEN gips_compliant = TRUE THEN 1 END)
      comment: "Count of GIPS-compliant return records — regulatory compliance coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Net TWR CM"
      display_name: "Avg Net TWR (Current Month)"
      expr: AVG(CAST(twr_net AS DOUBLE))
      comment: "Average net TWR for the current month bucket"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Month
          range: current
          semiadditive: last
    - name: "Avg Net TWR PM"
      display_name: "Avg Net TWR (Prior Month)"
      expr: AVG(CAST(twr_net AS DOUBLE))
      comment: "Average net TWR for the prior month bucket"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
      window:
        - order: Period End Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Net TWR MoM"
      display_name: "Net TWR MoM"
      expr: (AGG(`Avg Net TWR CM`) - AGG(`Avg Net TWR PM`)) / NULLIF(AGG(`Avg Net TWR PM`), 0)
      comment: "Month-over-month change in average net TWR — momentum signal for performance review"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_active_return_attribution`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over Barra-style active return attribution records. Decomposes active return into factor, sector allocation, and security selection components — the primary tool for the investment team to understand the sources of alpha and risk-adjusted outperformance at the portfolio, sector, and factor level."
  source: "`asset_management`.`performance`.`active_return_attribution`"
  parameters:
    - name: p_min_factor_return_bps
      data_type: DOUBLE
      default: -10000.0
  dimensions:
    - name: "Portfolio"
      display_name: "Portfolio ID"
      expr: portfolio_id
      comment: "Foreign key to the portfolio entity; primary slicer for attribution analysis by portfolio."
    - name: "Factor"
      display_name: "Factor ID"
      expr: factor_id
      comment: "Foreign key to the risk factor entity; used to slice attribution by systematic risk factor (e.g. value, momentum, quality)."
    - name: "AttributionModel"
      display_name: "Attribution Model ID"
      expr: attribution_model_id
      comment: "Foreign key to the attribution model; allows comparison of results across different Barra model versions or custom factor models."
    - name: "SectorName"
      display_name: "Sector"
      expr: sector_name
      comment: "GICS sector name; used to decompose attribution by sector for sector rotation and allocation analysis."
    - name: "PeriodEndDate"
      display_name: "Period End Date"
      expr: period_end_date
      comment: "Exact period end date of the attribution record; used for point-in-time filtering."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndMonth"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Month bucket of the attribution period end date; primary time-intelligence dimension for MoM attribution analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndQuarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', period_end_date)
      comment: "Quarter bucket of the attribution period end date; used for quarterly investment committee attribution reviews."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodEndYear"
      display_name: "Period End Year"
      expr: DATE_TRUNC('year', period_end_date)
      comment: "Year bucket of the attribution period end date; used for annual board-level attribution reporting."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "PeriodStartDate"
      display_name: "Period Start Date"
      expr: period_start_date
      comment: "Start date of the attribution period; used alongside period end date to define the measurement window."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "TotalFactorReturnBps"
      display_name: "Total Factor Return (bps)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE))
      comment: "Total factor return contribution in basis points across selected portfolios, factors, and periods. Quantifies how much of active return is explained by systematic factor exposures (e.g. value tilt, momentum)."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "TotalSectorAllocationReturnBps"
      display_name: "Total Sector Allocation Return (bps)"
      expr: SUM(CAST(sector_allocation_return_bps AS DOUBLE))
      comment: "Total sector allocation return contribution in basis points. Measures the value added (or destroyed) by overweighting or underweighting sectors relative to the benchmark."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "TotalSecuritySelectionReturnBps"
      display_name: "Total Security Selection Return (bps)"
      expr: SUM(CAST(security_selection_return_bps AS DOUBLE))
      comment: "Total security selection return contribution in basis points. Measures the value added by picking individual securities within each sector; the purest measure of fundamental research quality."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "AvgFactorReturnBps"
      display_name: "Avg Factor Return (bps)"
      expr: AVG(CAST(factor_return_bps AS DOUBLE))
      comment: "Average factor return contribution per attribution record. Used to compare factor effectiveness across different portfolios and time periods on a normalized basis."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "AvgSectorAllocationReturnBps"
      display_name: "Avg Sector Allocation Return (bps)"
      expr: AVG(CAST(sector_allocation_return_bps AS DOUBLE))
      comment: "Average sector allocation return per attribution record. Normalized view of sector allocation skill across portfolios and periods."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "AvgSecuritySelectionReturnBps"
      display_name: "Avg Security Selection Return (bps)"
      expr: AVG(CAST(security_selection_return_bps AS DOUBLE))
      comment: "Average security selection return per attribution record. Normalized measure of stock-picking skill; used to evaluate individual portfolio managers."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "TotalActiveReturnBps"
      display_name: "Total Active Return (bps)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE) + CAST(sector_allocation_return_bps AS DOUBLE) + CAST(security_selection_return_bps AS DOUBLE))
      comment: "Total active return (sum of all three attribution components) in basis points. The headline active return figure used in board and client reporting."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "SecuritySelectionShareOfActiveReturn"
      display_name: "Security Selection Share of Active Return (%)"
      expr: SUM(CAST(security_selection_return_bps AS DOUBLE)) / NULLIF(SUM(CAST(factor_return_bps AS DOUBLE) + CAST(sector_allocation_return_bps AS DOUBLE) + CAST(security_selection_return_bps AS DOUBLE)), 0) * 100
      comment: "Proportion of total active return attributable to security selection. High values indicate the portfolio is driven by fundamental stock-picking rather than factor or sector bets; used to validate active management mandate."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "FactorReturnShareOfActiveReturn"
      display_name: "Factor Return Share of Active Return (%)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE)) / NULLIF(SUM(CAST(factor_return_bps AS DOUBLE) + CAST(sector_allocation_return_bps AS DOUBLE) + CAST(security_selection_return_bps AS DOUBLE)), 0) * 100
      comment: "Proportion of total active return attributable to systematic factor exposures. High values may indicate the portfolio is taking unintended factor bets; triggers factor exposure review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "AttributionRecordCount"
      display_name: "Attribution Record Count"
      expr: COUNT(1)
      comment: "Total number of attribution records in the selection. Used to validate attribution model coverage and data completeness."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DistinctPortfolioCount"
      display_name: "Distinct Portfolio Count"
      expr: COUNT(DISTINCT portfolio_id)
      comment: "Number of distinct portfolios with attribution data in the selection. Used to assess attribution model coverage breadth."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DistinctFactorCount"
      display_name: "Distinct Factor Count"
      expr: COUNT(DISTINCT factor_id)
      comment: "Number of distinct risk factors contributing to attribution in the selection. Indicates the dimensionality of the factor model being applied."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "TotalFactorReturnBpsCM"
      display_name: "Total Factor Return Current Month (bps)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE))
      comment: "Total factor return in basis points for the current month. Base measure for MoM factor attribution time-intelligence."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PeriodEndMonth
          range: current
          semiadditive: last
    - name: "TotalFactorReturnBpsPM"
      display_name: "Total Factor Return Prior Month (bps)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE))
      comment: "Total factor return in basis points for the prior month. Used to compute MoM factor attribution change."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PeriodEndMonth
          range: current
          semiadditive: last
          offset: -1 month
    - name: "FactorReturnMoMChange"
      display_name: "Factor Return MoM Change (bps)"
      expr: AGG(`TotalFactorReturnBpsCM`) - AGG(`TotalFactorReturnBpsPM`)
      comment: "Month-over-month change in total factor return contribution in basis points. Tracks whether factor exposures are becoming more or less beneficial; triggers factor model review when materially negative."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "TotalSecuritySelectionReturnBpsCQ"
      display_name: "Total Security Selection Return Current Quarter (bps)"
      expr: SUM(CAST(security_selection_return_bps AS DOUBLE))
      comment: "Total security selection return in basis points for the current quarter. Base measure for QoQ stock-picking performance time-intelligence."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PeriodEndQuarter
          range: current
          semiadditive: last
    - name: "TotalSecuritySelectionReturnBpsPQ"
      display_name: "Total Security Selection Return Prior Quarter (bps)"
      expr: SUM(CAST(security_selection_return_bps AS DOUBLE))
      comment: "Total security selection return in basis points for the prior quarter. Used to compute QoQ stock-picking performance change."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PeriodEndQuarter
          range: current
          semiadditive: last
          offset: -3 months
    - name: "SecuritySelectionQoQChange"
      display_name: "Security Selection QoQ Change (bps)"
      expr: AGG(`TotalSecuritySelectionReturnBpsCQ`) - AGG(`TotalSecuritySelectionReturnBpsPQ`)
      comment: "Quarter-over-quarter change in security selection return in basis points. Primary metric for quarterly investment committee review of fundamental research quality."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "TotalActiveReturnYTD"
      display_name: "Total Active Return YTD (bps)"
      expr: SUM(CAST(factor_return_bps AS DOUBLE) + CAST(sector_allocation_return_bps AS DOUBLE) + CAST(security_selection_return_bps AS DOUBLE))
      comment: "Year-to-date cumulative active return in basis points. Tracks progress toward annual alpha targets; used in monthly investment committee reporting."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: PeriodEndDate
          range: cumulative
          semiadditive: last
        - order: PeriodEndYear
          range: current
          semiadditive: last
    - name: "TotalSecuritySelectionBpsBySector"
      display_name: "Total Security Selection Return by Sector (bps)"
      expr: SUM(CAST(security_selection_return_bps AS DOUBLE))
      comment: "Total security selection return partitioned by sector. Enables the CIO to identify which sectors are driving or detracting from stock-picking alpha simultaneously across all sectors."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      partition:
        include: [SectorName]
        outer_aggregate: sum
    - name: "TotalSectorAllocationBpsBySector"
      display_name: "Total Sector Allocation Return by Sector (bps)"
      expr: SUM(CAST(sector_allocation_return_bps AS DOUBLE))
      comment: "Total sector allocation return partitioned by sector. Identifies which sector overweight/underweight decisions are adding or destroying value; drives tactical asset allocation decisions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      partition:
        include: [SectorName]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_attribution_result`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Brinson-style performance attribution KPIs decomposing active return into allocation, selection, interaction and currency effects by segment — drives where alpha is sourced and where to reallocate risk."
  source: "`asset_management`.`performance`.`attribution_result`"
  dimensions:
    - name: "Attribution Level"
      display_name: "Attribution Level"
      expr: attribution_level
      comment: "Level at which attribution was computed (total, asset class, sector, security)"
    - name: "Segment Name"
      display_name: "Segment Name"
      expr: segment_name
      comment: "Name of the attribution segment"
    - name: "Calculation Status"
      display_name: "Calculation Status"
      expr: calculation_status
      comment: "Calculation status of the attribution result"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the attribution result"
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Attribution period end bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Attribution Records"
      display_name: "Attribution Records"
      expr: COUNT(1)
      comment: "Count of attribution result records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Active Return"
      display_name: "Avg Active Return"
      expr: AVG(CAST(active_return_pct AS DOUBLE))
      comment: "Average active return being decomposed by attribution"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Allocation Effect"
      display_name: "Total Allocation Effect"
      expr: SUM(CAST(allocation_effect_pct AS DOUBLE))
      comment: "Total allocation effect — value added from over/under-weighting segments, informs asset allocation decisions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Selection Effect"
      display_name: "Total Selection Effect"
      expr: SUM(CAST(selection_effect_pct AS DOUBLE))
      comment: "Total selection effect — value added from security selection within segments, informs manager skill assessment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Interaction Effect"
      display_name: "Total Interaction Effect"
      expr: SUM(CAST(interaction_effect_pct AS DOUBLE))
      comment: "Total interaction effect between allocation and selection"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Currency Effect"
      display_name: "Total Currency Effect"
      expr: SUM(CAST(currency_effect_pct AS DOUBLE))
      comment: "Total currency effect — value impact of FX exposure, informs hedging decisions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Reconciliation Difference"
      display_name: "Avg Reconciliation Difference"
      expr: AVG(CAST(reconciliation_difference AS DOUBLE))
      comment: "Average reconciliation difference — attribution data quality / residual signal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 6
    - name: "Total Average Market Value"
      display_name: "Total Average Market Value"
      expr: SUM(CAST(average_market_value AS DOUBLE))
      comment: "Total average market value across attribution segments — exposure scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_dispersion`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Composite return dispersion KPIs measuring consistency of returns across member portfolios — a GIPS quality and manager-consistency steering signal."
  source: "`asset_management`.`performance`.`dispersion`"
  dimensions:
    - name: "Measure Type"
      display_name: "Measure Type"
      expr: measure_type
      comment: "Dispersion measure type (standard deviation, high-low, etc.)"
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the dispersion measure"
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Strategy type"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the dispersion calc"
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', measurement_period_end_date)
      comment: "Measurement period end bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Dispersion Records"
      display_name: "Dispersion Records"
      expr: COUNT(1)
      comment: "Count of dispersion records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Dispersion Value"
      display_name: "Avg Dispersion Value"
      expr: AVG(CAST(value AS DOUBLE))
      comment: "Average dispersion value — spread of member portfolio returns, a consistency quality signal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 6
    - name: "Avg Mean Portfolio Return"
      display_name: "Avg Mean Portfolio Return"
      expr: AVG(CAST(mean_portfolio_return AS DOUBLE))
      comment: "Average of mean portfolio returns across composites"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Composite Return"
      display_name: "Avg Composite Return"
      expr: AVG(CAST(composite_return AS DOUBLE))
      comment: "Average composite return"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Return Range"
      display_name: "Avg Return Range"
      expr: AVG(CAST(maximum_portfolio_return AS DOUBLE) - CAST(minimum_portfolio_return AS DOUBLE))
      comment: "Average max-minus-min portfolio return range within composites — breadth of dispersion"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Composite AUM End"
      display_name: "Total Composite AUM End"
      expr: SUM(CAST(composite_aum_end AS DOUBLE))
      comment: "Total ending composite AUM represented in dispersion calcs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_excess_return`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Active return and risk-adjusted excess return KPIs vs benchmark across asset classes and sectors — drives manager evaluation and active risk budgeting decisions."
  source: "`asset_management`.`performance`.`excess_return`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the excess return record"
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Sector classification"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region"
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Investment strategy type"
    - name: "Benchmark Type"
      display_name: "Benchmark Type"
      expr: benchmark_type
      comment: "Type of benchmark used for excess return"
    - name: "Period Type"
      display_name: "Period Type"
      expr: period_type
      comment: "Measurement period type"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the calculation"
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', measurement_period_end_date)
      comment: "Measurement period end bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Excess Return Records"
      display_name: "Excess Return Records"
      expr: COUNT(1)
      comment: "Count of excess return records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Active Return"
      display_name: "Avg Active Return"
      expr: AVG(CAST(active_return AS DOUBLE))
      comment: "Average active return (portfolio minus benchmark) — core value-add measure"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Net Excess Return"
      display_name: "Avg Net Excess Return"
      expr: AVG(CAST(net_excess_return AS DOUBLE))
      comment: "Average net-of-fee excess return — true value delivered to beneficiaries"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Annualized Excess Return"
      display_name: "Avg Annualized Excess Return"
      expr: AVG(CAST(annualized_excess_return AS DOUBLE))
      comment: "Average annualized excess return — standardized long-horizon value-add"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Information Ratio"
      display_name: "Avg Information Ratio"
      expr: AVG(CAST(information_ratio AS DOUBLE))
      comment: "Average information ratio — consistency of active return per unit of active risk"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Sharpe Ratio"
      display_name: "Avg Sharpe Ratio"
      expr: AVG(CAST(sharpe_ratio AS DOUBLE))
      comment: "Average Sharpe ratio — risk-adjusted absolute return"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Tracking Error"
      display_name: "Avg Tracking Error"
      expr: AVG(CAST(tracking_error AS DOUBLE))
      comment: "Average tracking error — active risk exposure vs benchmark"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Underperforming Segments"
      display_name: "Underperforming Segments"
      expr: COUNT(CASE WHEN net_excess_return < 0 THEN 1 END)
      comment: "Count of segments with negative net excess return — underperformance flag for intervention"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_gips_composite_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GIPS composite reporting KPIs covering gross/net returns, composite dispersion, 3-year volatility and firm asset coverage — the regulatory composite performance disclosure layer."
  source: "`asset_management`.`performance`.`gips_composite_report`"
  dimensions:
    - name: "Composite Strategy Type"
      display_name: "Composite Strategy Type"
      expr: composite_strategy_type
      comment: "Strategy type of the GIPS composite"
    - name: "Report Status"
      display_name: "Report Status"
      expr: report_status
      comment: "Status of the GIPS composite report"
    - name: "Verification Status"
      display_name: "Verification Status"
      expr: verification_status
      comment: "Third-party verification status of the composite"
    - name: "Composite Currency"
      display_name: "Composite Currency"
      expr: composite_currency_code
      comment: "Reporting currency of the composite"
    - name: "Reporting Year"
      display_name: "Reporting Year"
      expr: reporting_year
      comment: "Reporting year of the GIPS composite report"
  measures:
    - name: "Composite Reports"
      display_name: "Composite Reports"
      expr: COUNT(1)
      comment: "Count of GIPS composite report records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Net of Fees Return"
      display_name: "Avg Net of Fees Return"
      expr: AVG(CAST(net_of_fees_return_pct AS DOUBLE))
      comment: "Average net-of-fees composite return — the GIPS headline return reported to clients/beneficiaries"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Gross of Fees Return"
      display_name: "Avg Gross of Fees Return"
      expr: AVG(CAST(gross_of_fees_return_pct AS DOUBLE))
      comment: "Average gross-of-fees composite return — pre-fee skill measure"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Benchmark Return"
      display_name: "Avg Benchmark Return"
      expr: AVG(CAST(benchmark_annual_return_pct AS DOUBLE))
      comment: "Average composite benchmark annual return — the comparison baseline"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Composite Dispersion"
      display_name: "Avg Composite Dispersion"
      expr: AVG(CAST(composite_dispersion_pct AS DOUBLE))
      comment: "Average intra-composite dispersion — consistency of returns across member portfolios, a GIPS quality signal"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg 3Y Std Dev"
      display_name: "Avg 3Y Std Dev"
      expr: AVG(CAST(composite_three_year_std_dev_pct AS DOUBLE))
      comment: "Average 3-year composite standard deviation — required GIPS risk disclosure"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Pct of Firm Assets"
      display_name: "Avg % of Firm Assets"
      expr: AVG(CAST(percentage_of_firm_assets_pct AS DOUBLE))
      comment: "Average percentage of firm assets represented by the composite — materiality/coverage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total Composite AUM"
      display_name: "Total Composite AUM"
      expr: SUM(CAST(composite_aum_end_of_year AS DOUBLE))
      comment: "Total end-of-year composite AUM — composite scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Verified Composite Reports"
      display_name: "Verified Composite Reports"
      expr: COUNT(CASE WHEN verification_status = 'Verified' THEN 1 END)
      comment: "Count of verified composite reports — GIPS verification coverage for compliance assurance"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_ldi_return`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Liability-driven investing performance KPIs comparing asset returns to liability returns, funded ratio evolution, hedging effectiveness and surplus returns — the core pension solvency steering layer."
  source: "`asset_management`.`performance`.`ldi_return`"
  dimensions:
    - name: "Period Type"
      display_name: "Period Type"
      expr: period_type
      comment: "Measurement period type"
    - name: "Calculation Method"
      display_name: "Calculation Method"
      expr: calculation_method
      comment: "Calculation method used for LDI returns"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the LDI calculation"
    - name: "Period End Month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', measurement_period_end_date)
      comment: "Measurement period end bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Period End Quarter"
      display_name: "Period End Quarter"
      expr: DATE_TRUNC('quarter', measurement_period_end_date)
      comment: "Measurement period end bucketed to quarter"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "LDI Records"
      display_name: "LDI Records"
      expr: COUNT(1)
      comment: "Count of LDI return records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Asset Return Pct"
      display_name: "Avg Asset Return %"
      expr: AVG(CAST(asset_return_percent AS DOUBLE))
      comment: "Average asset-side return — growth on pension assets"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Liability Return Pct"
      display_name: "Avg Liability Return %"
      expr: AVG(CAST(liability_return_percent AS DOUBLE))
      comment: "Average liability return — movement in present value of pension obligations"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Surplus Return Pct"
      display_name: "Avg Surplus Return %"
      expr: AVG(CAST(surplus_return_percent AS DOUBLE))
      comment: "Average surplus return — net asset-over-liability performance, the key solvency metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Ending Funded Ratio"
      display_name: "Avg Ending Funded Ratio"
      expr: AVG(CAST(funded_ratio_end AS DOUBLE))
      comment: "Average ending funded ratio — core pension solvency position monitored by trustees"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Funded Ratio Change"
      display_name: "Avg Funded Ratio Change"
      expr: AVG(CAST(funded_ratio_change AS DOUBLE))
      comment: "Average change in funded ratio over the period — solvency momentum"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Hedging Effectiveness"
      display_name: "Avg Hedging Effectiveness"
      expr: AVG(CAST(hedging_effectiveness AS DOUBLE))
      comment: "Average hedging effectiveness — how well liability risk is neutralized by the hedge portfolio"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Duration Mismatch"
      display_name: "Avg Duration Mismatch"
      expr: AVG(CAST(duration_mismatch AS DOUBLE))
      comment: "Average duration mismatch between assets and liabilities — interest rate risk signal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total Asset Value End"
      display_name: "Total Asset Value End"
      expr: SUM(CAST(asset_value_end AS DOUBLE))
      comment: "Total ending asset value across LDI records — asset scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liability Value End"
      display_name: "Total Liability Value End"
      expr: SUM(CAST(liability_value_end AS DOUBLE))
      comment: "Total ending liability value — obligation scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Underfunded Records"
      display_name: "Underfunded Records"
      expr: COUNT(CASE WHEN funded_ratio_end < 1 THEN 1 END)
      comment: "Count of records in an underfunded position — solvency risk flag for trustee action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_notice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manager mandate performance notice KPIs tracking underperformance breaches, tracking error limit breaches, remediation and termination signals — drives manager oversight and retention decisions."
  source: "`asset_management`.`performance`.`notice`"
  dimensions:
    - name: "Notice Type"
      display_name: "Notice Type"
      expr: notice_type
      comment: "Type of performance notice issued"
    - name: "Notice Status"
      display_name: "Notice Status"
      expr: notice_status
      comment: "Current status of the notice"
    - name: "Escalation Level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level of the notice"
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the mandate under notice"
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Strategy type of the mandate"
    - name: "Issue Month"
      display_name: "Issue Month"
      expr: DATE_TRUNC('month', issue_date)
      comment: "Notice issue date bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Notices Issued"
      display_name: "Notices Issued"
      expr: COUNT(1)
      comment: "Count of performance notices — baseline oversight volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Excess Return"
      display_name: "Avg Excess Return"
      expr: AVG(CAST(excess_return AS DOUBLE))
      comment: "Average excess return at notice — severity of underperformance triggering the notice"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Information Ratio"
      display_name: "Avg Information Ratio"
      expr: AVG(CAST(information_ratio AS DOUBLE))
      comment: "Average information ratio at notice — risk-adjusted underperformance signal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Actual Tracking Error"
      display_name: "Avg Actual Tracking Error"
      expr: AVG(CAST(tracking_error_actual AS DOUBLE))
      comment: "Average actual tracking error at notice — active risk relative to mandate limit"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Total AUM At Notice"
      display_name: "Total AUM At Notice"
      expr: SUM(CAST(aum_at_notice_date AS DOUBLE))
      comment: "Total AUM under notice — capital at risk from manager underperformance"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Termination Flagged Notices"
      display_name: "Termination Flagged Notices"
      expr: COUNT(CASE WHEN mandate_termination_flag = TRUE THEN 1 END)
      comment: "Count of notices flagged for mandate termination — most severe manager action signal"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Remediation Required Notices"
      display_name: "Remediation Required Notices"
      expr: COUNT(CASE WHEN remediation_required_flag = TRUE THEN 1 END)
      comment: "Count of notices requiring remediation — open manager corrective actions to monitor"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_pbor_snapshot`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Performance book-of-record snapshot KPIs covering NAV, GAV, fee load, realized/unrealized P&L, leverage and liquidity — the authoritative portfolio economics steering layer."
  source: "`asset_management`.`performance`.`pbor_snapshot`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the snapshot"
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Strategy type of the snapshot"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the snapshot"
    - name: "Snapshot Status"
      display_name: "Snapshot Status"
      expr: snapshot_status
      comment: "Status of the PBOR snapshot"
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency
      comment: "Base currency of the snapshot"
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Snapshots"
      display_name: "Snapshots"
      expr: COUNT(1)
      comment: "Count of PBOR snapshots — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total NAV"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Total net asset value across snapshots — fund scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total GAV"
      display_name: "Total GAV"
      expr: SUM(CAST(gav AS DOUBLE))
      comment: "Total gross asset value — gross exposure scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fees"
      display_name: "Total Fees"
      expr: SUM(CAST(total_fees AS DOUBLE))
      comment: "Total fee load across snapshots — cost monitoring"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Gain Loss"
      display_name: "Total Realized Gain/Loss"
      expr: SUM(CAST(realized_gain_loss AS DOUBLE))
      comment: "Total realized P&L — booked gains/losses"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unrealized Gain Loss"
      display_name: "Total Unrealized Gain/Loss"
      expr: SUM(CAST(unrealized_gain_loss AS DOUBLE))
      comment: "Total unrealized P&L — mark-to-market exposure"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TWR"
      display_name: "Avg TWR"
      expr: AVG(CAST(twr AS DOUBLE))
      comment: "Average time-weighted return in the snapshot"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Leverage Ratio"
      display_name: "Avg Leverage Ratio"
      expr: AVG(CAST(leverage_ratio AS DOUBLE))
      comment: "Average leverage ratio — balance-sheet risk monitored against policy limits"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Liquidity Ratio"
      display_name: "Avg Liquidity Ratio"
      expr: AVG(CAST(liquidity_ratio AS DOUBLE))
      comment: "Average liquidity ratio — ability to meet capital calls and benefit payments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total NAV Closing"
      display_name: "Total NAV (Closing)"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Closing total NAV — semi-additive balance, take last value within period"
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
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_private_asset_irr`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private market investment performance KPIs (IRR, MOIC, TVPI, DPI, RVPI) across PE, real estate, infrastructure and credit — the core private-asset value-creation steering layer."
  source: "`asset_management`.`performance`.`private_asset_irr`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Private asset class (private equity, real estate, infrastructure, natural resources, credit)"
    - name: "Investment Strategy"
      display_name: "Investment Strategy"
      expr: investment_strategy
      comment: "Investment strategy classification"
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the private asset"
    - name: "J Curve Status"
      display_name: "J-Curve Status"
      expr: j_curve_status
      comment: "Position on the J-curve (early/trough/recovery/mature)"
    - name: "Performance Status"
      display_name: "Performance Status"
      expr: performance_status
      comment: "Performance classification status of the investment"
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year of the fund/investment"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the IRR calculation"
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "IRR Records"
      display_name: "IRR Records"
      expr: COUNT(1)
      comment: "Count of private asset IRR records — baseline volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg IRR Since Inception"
      display_name: "Avg IRR Since Inception"
      expr: AVG(CAST(irr_since_inception AS DOUBLE))
      comment: "Average since-inception IRR — headline private-asset return measure for board and investment committee"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Excess IRR"
      display_name: "Avg Excess IRR"
      expr: AVG(CAST(excess_irr AS DOUBLE))
      comment: "Average excess IRR over private-market benchmark — manager/strategy value-add"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total value to paid-in multiple — total value created per dollar invested"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: AVG(CAST(moic AS DOUBLE))
      comment: "Average multiple on invested capital — gross value multiple"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI"
      display_name: "Avg DPI"
      expr: AVG(CAST(dpi AS DOUBLE))
      comment: "Average distributions to paid-in — realized cash return multiple, liquidity signal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg RVPI"
      display_name: "Avg RVPI"
      expr: AVG(CAST(rvpi AS DOUBLE))
      comment: "Average residual value to paid-in — unrealized value multiple still at risk"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid In Capital"
      display_name: "Total Paid-In Capital"
      expr: SUM(CAST(paid_in_capital AS DOUBLE))
      comment: "Total capital drawn into private investments — deployment scale"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cumulative Distributions"
      display_name: "Total Cumulative Distributions"
      expr: SUM(CAST(cumulative_distributions AS DOUBLE))
      comment: "Total cash returned to the fund from private investments — realized liquidity"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Residual Value"
      display_name: "Total Residual Value"
      expr: SUM(CAST(residual_value AS DOUBLE))
      comment: "Total unrealized value still held in private investments"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV Value"
      display_name: "Total NAV Value"
      expr: SUM(CAST(total_value AS DOUBLE))
      comment: "Total value (distributions + residual) of private investments — overall private book value"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`performance_significant_cash_flow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Significant cash flow monitoring KPIs for GIPS sub-period revaluation triggers — tracks large flows, exclusions and NAV impact that distort performance measurement."
  source: "`asset_management`.`performance`.`significant_cash_flow`"
  dimensions:
    - name: "Cash Flow Direction"
      display_name: "Cash Flow Direction"
      expr: cash_flow_direction
      comment: "Direction of the cash flow (inflow/outflow)"
    - name: "Cash Flow Type"
      display_name: "Cash Flow Type"
      expr: cash_flow_type
      comment: "Type of cash flow (contribution, distribution, etc.)"
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class affected by the cash flow"
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the significant cash flow event"
    - name: "Strategy Type"
      display_name: "Strategy Type"
      expr: strategy_type
      comment: "Strategy type affected"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency of the cash flow"
    - name: "Cash Flow Month"
      display_name: "Cash Flow Month"
      expr: DATE_TRUNC('month', cash_flow_date)
      comment: "Cash flow date bucketed to month"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Significant Cash Flow Events"
      display_name: "Significant Cash Flow Events"
      expr: COUNT(1)
      comment: "Count of significant cash flow events — baseline volume of performance-distorting flows"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Cash Flow Amount"
      display_name: "Total Cash Flow Amount"
      expr: SUM(CAST(cash_flow_amount AS DOUBLE))
      comment: "Total value of significant cash flows — magnitude of flows requiring sub-period treatment"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Actual Impact Pct"
      display_name: "Avg Actual Impact %"
      expr: AVG(CAST(actual_impact_percent AS DOUBLE))
      comment: "Average actual NAV impact percentage of the flow — severity of distortion"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Exclusion Required Events"
      display_name: "Exclusion Required Events"
      expr: COUNT(CASE WHEN exclusion_required_flag = TRUE THEN 1 END)
      comment: "Count of flows requiring portfolio exclusion from composite — GIPS compliance action trigger"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Sub Period Calc Required Events"
      display_name: "Sub-Period Calc Required Events"
      expr: COUNT(CASE WHEN sub_period_calculation_required_flag = TRUE THEN 1 END)
      comment: "Count of flows requiring sub-period revaluation — operational workload and accuracy driver"
      format:
        type: number
        decimal_places:
          type: all
$$;
