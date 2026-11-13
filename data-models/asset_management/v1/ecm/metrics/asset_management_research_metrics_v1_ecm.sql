-- Metric views for domain: research | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_asset_class_outlook`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over asset class outlooks produced by the research team. Supports strategic asset allocation steering: comparing expected returns, risk, Sharpe ratios, and allocation deltas across asset classes, horizons, and ESG posture."
  source: "`asset_management`.`research`.`asset_class_outlook`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Primary asset class the outlook covers (e.g. public equity, private equity, real estate, infrastructure, credit)."
    - name: "Sub Asset Class"
      display_name: "Sub Asset Class"
      expr: sub_asset_class
      comment: "More granular sub-asset-class classification within the asset class."
    - name: "Investment View"
      display_name: "Investment View"
      expr: investment_view
      comment: "Directional investment stance of the outlook (e.g. overweight, neutral, underweight)."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic region the outlook is focused on."
    - name: "Outlook Status"
      display_name: "Outlook Status"
      expr: outlook_status
      comment: "Lifecycle status of the outlook (e.g. draft, approved, superseded)."
    - name: "ESG Integration Flag"
      display_name: "ESG Integrated"
      expr: esg_integration_flag
      comment: "Whether ESG factors were integrated into the outlook."
    - name: "Publication Month"
      display_name: "Publication Month"
      expr: DATE_TRUNC('month', publication_date)
      comment: "Month in which the outlook was published, for time-series trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Publication Year"
      display_name: "Publication Year"
      expr: DATE_TRUNC('year', publication_date)
      comment: "Year in which the outlook was published."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Outlook Count"
      display_name: "Outlook Count"
      expr: COUNT(1)
      comment: "Number of asset class outlooks, baseline volume of research coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Expected Return Pct"
      display_name: "Avg Expected Return %"
      expr: AVG(CAST(expected_return_percentage AS DOUBLE))
      comment: "Average forward-looking expected return across outlooks; core input to strategic asset allocation decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Volatility Pct"
      display_name: "Avg Expected Volatility %"
      expr: AVG(CAST(expected_volatility_percentage AS DOUBLE))
      comment: "Average expected volatility across outlooks; risk dimension of the risk/return trade-off."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Sharpe Ratio"
      display_name: "Avg Sharpe Ratio"
      expr: AVG(CAST(sharpe_ratio AS DOUBLE))
      comment: "Average expected risk-adjusted return (Sharpe) across outlooks; key driver of capital allocation prioritization."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allocation Delta Pct"
      display_name: "Avg Allocation Delta %"
      expr: AVG(CAST(allocation_delta_percentage AS DOUBLE))
      comment: "Average recommended shift (target minus current) in allocation; signals where the fund intends to reallocate capital."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target Allocation Pct"
      display_name: "Avg Target Allocation %"
      expr: AVG(CAST(target_allocation_percentage AS DOUBLE))
      comment: "Average target allocation recommended across outlooks; forward allocation posture."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_capital_market_assumption`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over capital market assumptions (CMAs) that underpin strategic asset allocation and ALM. Tracks expected returns, volatility, Sharpe, risk premia and inflation assumptions across asset classes and horizons."
  source: "`asset_management`.`research`.`capital_market_assumption`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class the CMA applies to."
    - name: "Assumption Type"
      display_name: "Assumption Type"
      expr: assumption_type
      comment: "Type of assumption (e.g. return, volatility, correlation)."
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Governance approval status of the assumption."
    - name: "Geographic Scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the assumption."
    - name: "Currency Code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency the assumption is expressed in."
    - name: "Effective Month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month the assumption became effective."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assumption Count"
      display_name: "Assumption Count"
      expr: COUNT(1)
      comment: "Number of capital market assumptions maintained; governance coverage of the CMA set."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Expected Return Pct"
      display_name: "Avg Expected Return %"
      expr: AVG(CAST(expected_return_percentage AS DOUBLE))
      comment: "Average expected return assumption; core SAA input."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Volatility Pct"
      display_name: "Avg Expected Volatility %"
      expr: AVG(CAST(expected_volatility_percentage AS DOUBLE))
      comment: "Average expected volatility assumption; risk input to allocation optimization."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Sharpe Ratio"
      display_name: "Avg Sharpe Ratio"
      expr: AVG(CAST(sharpe_ratio AS DOUBLE))
      comment: "Average assumed Sharpe ratio; risk-adjusted-return expectation per asset class."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Real Return Pct"
      display_name: "Avg Real Return %"
      expr: AVG(CAST(real_return_percentage AS DOUBLE))
      comment: "Average real (inflation-adjusted) return assumption; critical for long-duration pension liability matching."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Inflation Assumption Pct"
      display_name: "Avg Inflation Assumption %"
      expr: AVG(CAST(inflation_assumption_percentage AS DOUBLE))
      comment: "Average inflation assumption; drives real-return and liability discounting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_country_outlook`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over sovereign / country outlooks. Supports country-allocation and macro risk steering: projected growth, inflation, fiscal and debt metrics, political risk and ESG scores across regions and recommendations."
  source: "`asset_management`.`research`.`country_outlook`"
  dimensions:
    - name: "Country Name"
      display_name: "Country"
      expr: country_name
      comment: "Name of the country assessed."
    - name: "Region"
      display_name: "Region"
      expr: region
      comment: "Region grouping of the country."
    - name: "Investment Recommendation"
      display_name: "Investment Recommendation"
      expr: investment_recommendation
      comment: "Investment recommendation for the country (e.g. overweight, neutral, avoid)."
    - name: "Sovereign Credit Rating"
      display_name: "Sovereign Credit Rating"
      expr: sovereign_credit_rating
      comment: "Sovereign credit rating assigned."
    - name: "Political Risk Category"
      display_name: "Political Risk Category"
      expr: political_risk_category
      comment: "Qualitative political-risk bucket."
    - name: "Climate Risk Category"
      display_name: "Climate Risk Category"
      expr: climate_risk_category
      comment: "Qualitative climate-risk bucket for the country."
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month the country assessment was made, for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Country Outlook Count"
      display_name: "Country Outlook Count"
      expr: COUNT(1)
      comment: "Number of country outlooks; breadth of sovereign coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Projected GDP Growth Rate"
      display_name: "Avg Projected GDP Growth %"
      expr: AVG(CAST(projected_gdp_growth_rate AS DOUBLE))
      comment: "Average projected GDP growth across country outlooks; macro-allocation driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Projected Inflation Rate"
      display_name: "Avg Projected Inflation %"
      expr: AVG(CAST(projected_inflation_rate AS DOUBLE))
      comment: "Average projected inflation; real-return and rate-sensitivity input."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Public Debt To GDP"
      display_name: "Avg Public Debt / GDP %"
      expr: AVG(CAST(public_debt_gdp_pct AS DOUBLE))
      comment: "Average public-debt-to-GDP; sovereign solvency / credit-risk gauge."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Political Risk Score"
      display_name: "Avg Political Risk Score"
      expr: AVG(CAST(political_risk_score AS DOUBLE))
      comment: "Average political-risk score; geopolitical risk exposure gauge."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Country Score"
      display_name: "Avg ESG Country Score"
      expr: AVG(CAST(esg_country_score AS DOUBLE))
      comment: "Average ESG country score; ESG-integration input to sovereign allocation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_coverage_universe`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over the research coverage universe. Measures breadth and quality of analyst coverage, investable vs restricted exposure, and target returns across asset classes, tiers, and geographies to steer research resourcing."
  source: "`asset_management`.`research`.`coverage_universe`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the covered entity."
    - name: "Coverage Tier"
      display_name: "Coverage Tier"
      expr: coverage_tier
      comment: "Priority tier of coverage (e.g. tier 1 core, tier 2 watch)."
    - name: "Coverage Status"
      display_name: "Coverage Status"
      expr: coverage_status
      comment: "Current status of coverage (e.g. active, suspended, dropped)."
    - name: "Geography"
      display_name: "Geography"
      expr: geography
      comment: "Geographic location of the covered entity."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "GICS-style sector of the covered entity."
    - name: "Investment Grade Flag"
      display_name: "Investment Grade"
      expr: investment_grade_flag
      comment: "Whether the entity is rated investment grade."
    - name: "Restricted Flag"
      display_name: "Restricted"
      expr: restricted_flag
      comment: "Whether the entity is on the restricted list."
    - name: "Liquidity Classification"
      display_name: "Liquidity Classification"
      expr: liquidity_classification
      comment: "Liquidity classification of the covered entity."
  measures:
    - name: "Covered Entity Count"
      display_name: "Covered Entity Count"
      expr: COUNT(DISTINCT coverage_universe_id)
      comment: "Number of distinct entities under research coverage; breadth of the analyst universe."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Coverage AUM"
      display_name: "Total Coverage AUM"
      expr: SUM(CAST(aum_usd AS DOUBLE))
      comment: "Total assets under management represented by covered entities; scale of monitored capital."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Market Cap"
      display_name: "Total Market Cap"
      expr: SUM(CAST(market_cap_usd AS DOUBLE))
      comment: "Total market capitalization of covered entities; opportunity-set sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr_percent AS DOUBLE))
      comment: "Average target IRR across the coverage universe; expected return profile of the opportunity set."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Investable Entity Count"
      display_name: "Investable Entity Count"
      expr: COUNT(CASE WHEN investable_flag = TRUE THEN 1 END)
      comment: "Number of entities currently flagged investable; actionable portion of coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Restricted Entity Count"
      display_name: "Restricted Entity Count"
      expr: COUNT(CASE WHEN restricted_flag = TRUE THEN 1 END)
      comment: "Number of restricted entities; compliance constraint on the investable set."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_data_vendor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over research data vendors. Supports vendor spend management and SLA governance: total annual cost, SLA attainment, and vendor performance across criticality tiers and types."
  source: "`asset_management`.`research`.`data_vendor`"
  dimensions:
    - name: "Vendor Type"
      display_name: "Vendor Type"
      expr: vendor_type
      comment: "Type of data vendor (e.g. market data, ESG, alternative data)."
    - name: "Vendor Criticality"
      display_name: "Vendor Criticality"
      expr: vendor_criticality
      comment: "Business criticality of the vendor."
    - name: "Vendor Status"
      display_name: "Vendor Status"
      expr: vendor_status
      comment: "Current status of the vendor relationship (e.g. active, under review, terminated)."
    - name: "Vendor Support Tier"
      display_name: "Support Tier"
      expr: vendor_support_tier
      comment: "Support tier contracted with the vendor."
    - name: "Cost Currency"
      display_name: "Cost Currency"
      expr: cost_currency
      comment: "Currency in which the vendor contract is denominated."
  measures:
    - name: "Vendor Count"
      display_name: "Vendor Count"
      expr: COUNT(DISTINCT data_vendor_id)
      comment: "Number of distinct data vendors; vendor footprint for consolidation decisions."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Annual Cost"
      display_name: "Total Annual Cost"
      expr: SUM(CAST(annual_cost AS DOUBLE))
      comment: "Total annual spend across data vendors; primary cost-management KPI."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Annual Cost"
      display_name: "Avg Annual Cost"
      expr: AVG(CAST(annual_cost AS DOUBLE))
      comment: "Average annual cost per vendor; benchmarking of contract sizing."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Uptime SLA Pct"
      display_name: "Avg Uptime SLA %"
      expr: AVG(CAST(uptime_sla_pct AS DOUBLE))
      comment: "Average contracted uptime SLA; service-reliability expectation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Data Quality SLA Pct"
      display_name: "Avg Data Quality SLA %"
      expr: AVG(CAST(data_quality_sla_pct AS DOUBLE))
      comment: "Average contracted data-quality SLA; data-integrity expectation across vendors."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Vendor Performance Score"
      display_name: "Avg Vendor Performance Score"
      expr: AVG(CAST(vendor_performance_score AS DOUBLE))
      comment: "Average vendor performance score; input to renewal and replacement decisions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_ic_research_pack`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over Investment Committee research packs. Tracks deal pipeline quality, recommended commitment sizing, target returns, and IC decision outcomes to steer capital deployment and due diligence throughput."
  source: "`asset_management`.`research`.`ic_research_pack`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the opportunity presented to the Investment Committee."
    - name: "IC Decision"
      display_name: "IC Decision"
      expr: ic_decision
      comment: "Outcome of the IC decision (e.g. approved, declined, deferred)."
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Risk rating assigned to the opportunity in the research pack."
    - name: "Due Diligence Status"
      display_name: "Due Diligence Status"
      expr: due_diligence_status
      comment: "Status of due diligence at pack submission."
    - name: "Submission Status"
      display_name: "Submission Status"
      expr: submission_status
      comment: "Submission lifecycle status of the pack."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the opportunity."
    - name: "IC Meeting Month"
      display_name: "IC Meeting Month"
      expr: DATE_TRUNC('month', ic_meeting_date)
      comment: "Month of the IC meeting, for decision-throughput trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Pack Count"
      display_name: "Pack Count"
      expr: COUNT(1)
      comment: "Number of IC research packs; measures deal pipeline volume reaching the committee."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Recommended Commitment"
      display_name: "Total Recommended Commitment"
      expr: SUM(CAST(recommended_commitment_amount AS DOUBLE))
      comment: "Total capital recommended for commitment across packs; sizing of the investment pipeline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Recommended Commitment"
      display_name: "Avg Recommended Commitment"
      expr: AVG(CAST(recommended_commitment_amount AS DOUBLE))
      comment: "Average recommended commitment per pack; typical deal size entering the committee."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr AS DOUBLE))
      comment: "Average target internal rate of return across packs; return expectation of the pipeline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target MOIC"
      display_name: "Avg Target MOIC"
      expr: AVG(CAST(target_moic AS DOUBLE))
      comment: "Average target multiple on invested capital across packs; return-multiple expectation of the pipeline."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Approved Pack Count"
      display_name: "Approved Pack Count"
      expr: COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END)
      comment: "Number of packs approved by the IC; numerator for approval-rate analysis."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_macro_model_run`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over macroeconomic model runs. Tracks model throughput, convergence reliability, and projected macro / risk outputs (VaR, CVaR, WACC, risk-free rate) that feed valuation and stress-testing decisions."
  source: "`asset_management`.`research`.`macro_model_run`"
  dimensions:
    - name: "Run Type"
      display_name: "Run Type"
      expr: run_type
      comment: "Type of model run (e.g. baseline, stress, scenario)."
    - name: "Run Status"
      display_name: "Run Status"
      expr: run_status
      comment: "Execution status of the run (e.g. completed, failed, running)."
    - name: "Run Purpose"
      display_name: "Run Purpose"
      expr: run_purpose
      comment: "Business purpose of the run."
    - name: "Stress Test Severity"
      display_name: "Stress Test Severity"
      expr: stress_test_severity
      comment: "Severity of the stress scenario applied in the run."
    - name: "Validation Status"
      display_name: "Validation Status"
      expr: validation_status
      comment: "Model-validation status of the run output."
    - name: "Run Month"
      display_name: "Run Month"
      expr: DATE_TRUNC('month', run_timestamp)
      comment: "Month the model run executed, for throughput trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Run Count"
      display_name: "Run Count"
      expr: COUNT(1)
      comment: "Number of macro model runs; research compute throughput."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Converged Run Count"
      display_name: "Converged Run Count"
      expr: COUNT(CASE WHEN convergence_achieved = TRUE THEN 1 END)
      comment: "Number of runs that achieved convergence; numerator for model-reliability rate."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Execution Duration Seconds"
      display_name: "Avg Execution Duration (s)"
      expr: AVG(CAST(execution_duration_seconds AS DOUBLE))
      comment: "Average run execution time; signals compute efficiency and bottlenecks."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Projected GDP Growth Rate"
      display_name: "Avg Projected GDP Growth"
      expr: AVG(CAST(projected_gdp_growth_rate AS DOUBLE))
      comment: "Average projected GDP growth across runs; macro backdrop for allocation decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Projected WACC"
      display_name: "Avg Projected WACC"
      expr: AVG(CAST(projected_wacc AS DOUBLE))
      comment: "Average projected weighted average cost of capital; key valuation discount-rate input."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg VaR Estimate"
      display_name: "Avg VaR Estimate"
      expr: AVG(CAST(var_estimate AS DOUBLE))
      comment: "Average Value-at-Risk estimate across runs; tail-risk gauge for the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg CVaR Estimate"
      display_name: "Avg CVaR Estimate"
      expr: AVG(CAST(cvar_estimate AS DOUBLE))
      comment: "Average Conditional VaR estimate across runs; expected loss in the tail beyond VaR."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_market_consensus`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over sell-side / street consensus estimates aggregated for coverage names. Supports relative-value decisions by tracking consensus dispersion, analyst breadth, and recommendation skew versus the fund's proprietary view."
  source: "`asset_management`.`research`.`market_consensus`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the consensus estimate."
    - name: "Consensus Rating"
      display_name: "Consensus Rating"
      expr: consensus_rating
      comment: "Aggregate street rating (e.g. buy, hold, sell)."
    - name: "Estimate Type"
      display_name: "Estimate Type"
      expr: estimate_type
      comment: "Type of estimate (e.g. EPS, revenue, price target)."
    - name: "Sector Classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector classification of the estimate."
    - name: "Revision Direction"
      display_name: "Revision Direction"
      expr: revision_direction
      comment: "Direction of the most recent consensus revision (up/down/flat)."
    - name: "Effective Month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month the consensus became effective, for revision-trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Consensus Record Count"
      display_name: "Consensus Record Count"
      expr: COUNT(1)
      comment: "Number of consensus records; coverage breadth of street estimates."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Analyst Count"
      display_name: "Avg Analyst Count"
      expr: AVG(CAST(analyst_count AS DOUBLE))
      comment: "Average number of contributing analysts per estimate; measures estimate robustness."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Mean Estimate"
      display_name: "Avg Mean Estimate"
      expr: AVG(CAST(mean_estimate AS DOUBLE))
      comment: "Average mean consensus estimate; central tendency of the street."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Estimate Dispersion"
      display_name: "Avg Estimate Dispersion"
      expr: AVG(CAST(standard_deviation AS DOUBLE))
      comment: "Average standard deviation of estimates; dispersion signals disagreement and uncertainty."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Buy Ratings"
      display_name: "Total Buy Ratings"
      expr: SUM(CAST(buy_count AS DOUBLE))
      comment: "Total buy ratings across records; positive sentiment weight."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Sell Ratings"
      display_name: "Total Sell Ratings"
      expr: SUM(CAST(sell_count AS DOUBLE))
      comment: "Total sell ratings across records; negative sentiment weight."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`research_thematic_research`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KPI layer over thematic research. Tracks the fund's thematic investment agenda: portfolio exposure tied to themes, ESG alignment, target allocation and related deal counts across theme categories and horizons."
  source: "`asset_management`.`research`.`thematic_research`"
  dimensions:
    - name: "Theme Category"
      display_name: "Theme Category"
      expr: theme_category
      comment: "Category of the investment theme (e.g. energy transition, demographics, digitalization)."
    - name: "Research Status"
      display_name: "Research Status"
      expr: research_status
      comment: "Lifecycle status of the thematic research."
    - name: "Climate Relevance"
      display_name: "Climate Relevance"
      expr: climate_relevance
      comment: "Degree of climate relevance of the theme."
    - name: "Confidence Level"
      display_name: "Confidence Level"
      expr: confidence_level
      comment: "Analyst confidence level in the thematic view."
    - name: "Geographic Scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the theme."
    - name: "Publication Month"
      display_name: "Publication Month"
      expr: DATE_TRUNC('month', publication_date)
      comment: "Month the thematic research was published."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Thematic Research Count"
      display_name: "Thematic Research Count"
      expr: COUNT(1)
      comment: "Number of thematic research pieces; breadth of the thematic agenda."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Related Portfolio Exposure AUM"
      display_name: "Total Thematic Exposure AUM"
      expr: SUM(CAST(related_portfolio_exposure_aum AS DOUBLE))
      comment: "Total portfolio AUM exposed to researched themes; materiality of thematic bets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target Allocation Pct"
      display_name: "Avg Target Allocation %"
      expr: AVG(CAST(target_allocation_percentage AS DOUBLE))
      comment: "Average target allocation tied to themes; forward intent for thematic positioning."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Alignment Score"
      display_name: "Avg ESG Alignment Score"
      expr: AVG(CAST(esg_alignment_score AS DOUBLE))
      comment: "Average ESG alignment score of themes; measures ESG integration in the research agenda."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Related Deal Count"
      display_name: "Total Related Deal Count"
      expr: SUM(CAST(related_deal_count AS DOUBLE))
      comment: "Total deals linked to themes; conversion of research into actionable pipeline."
      format:
        type: number
        decimal_places:
          type: all
$$;
