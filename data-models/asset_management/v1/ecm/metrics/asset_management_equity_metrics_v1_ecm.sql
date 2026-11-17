-- Metric views for domain: equity | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_price_target_evaluation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over price target evaluations, measuring analyst forecast accuracy, price target hit rates, and return attribution for equity research notes. Supports investment committee review of research quality and analyst performance."
  source: "`asset_management`.`equity`.`price_target_evaluation`"
  parameters:
    - name: p_min_horizon_days
      data_type: INT
      default: 0
    - name: p_max_horizon_days
      data_type: INT
      default: 365
  dimensions:
    - name: "EvaluationYear"
      display_name: "Evaluation Year"
      expr: DATE_TRUNC('year', evaluation_date)
      comment: "Year in which the price target was evaluated, used for annual performance bucketing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "EvaluationQuarter"
      display_name: "Evaluation Quarter"
      expr: DATE_TRUNC('quarter', evaluation_date)
      comment: "Quarter in which the price target was evaluated, used for quarterly performance bucketing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "EvaluationMonth"
      display_name: "Evaluation Month"
      expr: DATE_TRUNC('month', evaluation_date)
      comment: "Month in which the price target was evaluated, used for monthly trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "EvaluationDate"
      display_name: "Evaluation Date"
      expr: evaluation_date
      comment: "Exact date on which the price target evaluation was recorded."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "HorizonBucket"
      display_name: "Horizon Bucket"
      expr: CASE WHEN horizon_days <= 30 THEN '0-30 Days' WHEN horizon_days <= 90 THEN '31-90 Days' WHEN horizon_days <= 180 THEN '91-180 Days' WHEN horizon_days <= 365 THEN '181-365 Days' ELSE '365+ Days' END
      comment: "Categorises the evaluation horizon into standard investment time buckets (short, medium, long) to compare forecast accuracy across different holding periods."
    - name: "PriceTargetOutcome"
      display_name: "Price Target Outcome"
      expr: CASE WHEN realized_price >= issue_price THEN 'Target Met or Exceeded' ELSE 'Target Missed' END
      comment: "Binary classification of whether the realized price met or exceeded the issue price target, enabling hit-rate analysis across research notes."
    - name: "ReturnDirectionBucket"
      display_name: "Return Direction"
      expr: CASE WHEN realized_price > issue_price THEN 'Positive Return' WHEN realized_price < issue_price THEN 'Negative Return' ELSE 'Flat' END
      comment: "Classifies each evaluation by whether the realized price moved above, below, or equal to the issue price, supporting directional accuracy analysis."
    - name: "ResearchNoteId"
      display_name: "Research Note ID"
      expr: research_note_id
      comment: "Foreign key to the originating research note, enabling slicing of metrics by individual analyst notes."
  measures:
    - name: "TotalEvaluations"
      display_name: "Total Evaluations"
      expr: COUNT(1)
      comment: "Total number of price target evaluations recorded. Baseline volume metric for assessing research coverage breadth."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "DistinctResearchNotes"
      display_name: "Distinct Research Notes Evaluated"
      expr: COUNT(DISTINCT research_note_id)
      comment: "Number of unique research notes that have been evaluated. Measures the breadth of analyst coverage subject to performance review."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "TargetMetCount"
      display_name: "Targets Met or Exceeded"
      expr: COUNT(CASE WHEN realized_price >= issue_price THEN 1 END)
      comment: "Number of evaluations where the realized price met or exceeded the issue price target. Numerator for analyst hit-rate calculation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "PriceTargetHitRate"
      display_name: "Price Target Hit Rate (%)"
      expr: ROUND(100.0 * COUNT(CASE WHEN realized_price >= issue_price THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of price target evaluations where the realized price met or exceeded the issue price. Core KPI for assessing research quality and analyst forecast accuracy — directly informs investment committee confidence in research outputs."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "TotalIssuePrice"
      display_name: "Total Issue Price"
      expr: SUM(CAST(issue_price AS DOUBLE))
      comment: "Sum of all issue prices across evaluations. Used as denominator component for blended return calculations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "TotalRealizedPrice"
      display_name: "Total Realized Price"
      expr: SUM(CAST(realized_price AS DOUBLE))
      comment: "Sum of all realized prices across evaluations. Used as numerator component for blended return calculations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "AvgIssuePrice"
      display_name: "Average Issue Price"
      expr: AVG(CAST(issue_price AS DOUBLE))
      comment: "Average issue price across all evaluated price targets. Provides a sense of the price level at which research targets are set."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "AvgRealizedPrice"
      display_name: "Average Realized Price"
      expr: AVG(CAST(realized_price AS DOUBLE))
      comment: "Average realized price across all evaluated price targets. Compared against average issue price to assess overall directional accuracy of research."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "AvgAbsolutePriceReturn"
      display_name: "Avg Absolute Price Return"
      expr: AVG(CAST(realized_price AS DOUBLE) - CAST(issue_price AS DOUBLE))
      comment: "Average absolute difference between realized and issue price per evaluation. Measures the average dollar magnitude of forecast error or gain, informing position sizing and research calibration."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "AvgReturnPct"
      display_name: "Avg Return vs Issue Price (%)"
      expr: AVG(100.0 * (CAST(realized_price AS DOUBLE) - CAST(issue_price AS DOUBLE)) / NULLIF(CAST(issue_price AS DOUBLE), 0))
      comment: "Average percentage return of realized price relative to issue price across all evaluations. Core measure of research-driven return generation — used by the investment committee to assess whether analyst price targets translate into actual portfolio alpha."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "MaxReturnPct"
      display_name: "Max Return vs Issue Price (%)"
      expr: MAX(100.0 * (CAST(realized_price AS DOUBLE) - CAST(issue_price AS DOUBLE)) / NULLIF(CAST(issue_price AS DOUBLE), 0))
      comment: "Maximum percentage return achieved relative to issue price across all evaluations. Identifies best-performing research calls and informs upside capture analysis."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "MinReturnPct"
      display_name: "Min Return vs Issue Price (%)"
      expr: MIN(100.0 * (CAST(realized_price AS DOUBLE) - CAST(issue_price AS DOUBLE)) / NULLIF(CAST(issue_price AS DOUBLE), 0))
      comment: "Minimum (worst) percentage return achieved relative to issue price. Identifies worst-performing research calls and informs downside risk from analyst recommendations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "AvgHorizonDays"
      display_name: "Avg Evaluation Horizon (Days)"
      expr: AVG(CAST(horizon_days AS DOUBLE))
      comment: "Average number of days over which price targets are evaluated. Informs whether the research team is predominantly short- or long-horizon in its forecasting, which has implications for portfolio turnover and strategy alignment."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "MaxHorizonDays"
      display_name: "Max Evaluation Horizon (Days)"
      expr: MAX(horizon_days)
      comment: "Longest evaluation horizon in the dataset. Used to understand the outer bound of research coverage periods."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "EvaluationsCurrentMonth"
      display_name: "Evaluations (Current Month)"
      expr: COUNT(1)
      comment: "Number of price target evaluations in the current calendar month. Used for monthly research activity monitoring."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: EvaluationMonth
          range: current
          semiadditive: last
    - name: "EvaluationsPriorMonth"
      display_name: "Evaluations (Prior Month)"
      expr: COUNT(1)
      comment: "Number of price target evaluations in the prior calendar month. Paired with current month count for MoM volume comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: EvaluationMonth
          range: current
          semiadditive: last
          offset: -1 month
    - name: "EvaluationsMoMGrowth"
      display_name: "Evaluations MoM Growth (%)"
      expr: (AGG(`EvaluationsCurrentMonth`) - AGG(`EvaluationsPriorMonth`)) / NULLIF(AGG(`EvaluationsPriorMonth`), 0)
      comment: "Month-over-month percentage change in the number of price target evaluations. Tracks research activity momentum and pipeline health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "HitRateCurrentQuarter"
      display_name: "Target Hit Rate (Current Quarter)"
      expr: ROUND(100.0 * COUNT(CASE WHEN realized_price >= issue_price THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Price target hit rate for the current quarter. Enables quarterly investment committee review of research accuracy trends."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: EvaluationQuarter
          range: current
          semiadditive: last
    - name: "HitRatePriorQuarter"
      display_name: "Target Hit Rate (Prior Quarter)"
      expr: ROUND(100.0 * COUNT(CASE WHEN realized_price >= issue_price THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Price target hit rate for the prior quarter. Used as the baseline for QoQ hit rate comparison."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: EvaluationQuarter
          range: current
          semiadditive: last
          offset: -3 months
    - name: "HitRateQoQChange"
      display_name: "Hit Rate QoQ Change (%)"
      expr: AGG(`HitRateCurrentQuarter`) - AGG(`HitRatePriorQuarter`)
      comment: "Quarter-over-quarter change in price target hit rate (percentage points). Directly informs investment committee decisions on research team performance and analyst credibility."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "EvaluationsYTD"
      display_name: "Evaluations YTD"
      expr: COUNT(1)
      comment: "Cumulative number of price target evaluations from the start of the year to the current date. Tracks annual research coverage progress."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: EvaluationDate
          range: cumulative
          semiadditive: last
        - order: EvaluationYear
          range: current
          semiadditive: last
    - name: "EvaluationsPYTD"
      display_name: "Evaluations PYTD"
      expr: COUNT(1)
      comment: "Cumulative number of price target evaluations from the start of the prior year to the equivalent date. Used as the baseline for YoY volume comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: EvaluationDate
          range: cumulative
          semiadditive: last
          offset: -1 year
        - order: EvaluationYear
          range: current
          semiadditive: last
          offset: -1 year
    - name: "EvaluationsYoYGrowth"
      display_name: "Evaluations YoY Growth (%)"
      expr: (AGG(`EvaluationsYTD`) - AGG(`EvaluationsPYTD`)) / NULLIF(AGG(`EvaluationsPYTD`), 0)
      comment: "Year-over-year percentage growth in price target evaluations. Tracks whether research coverage is expanding or contracting relative to the prior year."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rolling90DayEvaluations"
      display_name: "Evaluations (Rolling 90 Days)"
      expr: AGG(`TotalEvaluations`)
      comment: "Rolling 90-day count of price target evaluations. Smooths out monthly volatility and provides a stable view of research activity for operational monitoring."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: EvaluationDate
          range: trailing 3 month inclusive
          semiadditive: last
    - name: "EvaluationsPerResearchNote"
      display_name: "Avg Evaluations per Research Note"
      expr: ROUND(CAST(COUNT(1) AS DOUBLE) / NULLIF(COUNT(DISTINCT research_note_id), 0), 2)
      comment: "Average number of price target evaluations per research note. Indicates how thoroughly each research note is being tracked and evaluated over time."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "EvaluationsInHorizonRange"
      display_name: "Evaluations in Horizon Range"
      expr: COUNT(CASE WHEN horizon_days >= p_min_horizon_days AND horizon_days <= p_max_horizon_days THEN 1 END)
      comment: "Number of evaluations falling within the user-specified horizon range (p_min_horizon_days to p_max_horizon_days). Enables dynamic filtering of research quality metrics by investment horizon, supporting strategy-specific performance reviews."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_benchmark_constituent_weight`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Constituent weight concentration within equity benchmarks for active-risk context."
  source: "`asset_management`.`equity`.`equity_benchmark_constituent`"
  filter: constituent_status = 'ACTIVE'
  dimensions:
    - name: "GICS Sector"
      display_name: "Gics sector"
      expr: gics_sector_code
      comment: "Sector"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
  measures:
    - name: "Constituents"
      display_name: "Constituents"
      expr: COUNT(1)
      comment: "Constituents"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Weight %"
      display_name: "Avg weight %"
      expr: ROUND(AVG(CAST(constituent_weight_percent AS DOUBLE)),4)
      comment: "Weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Max Weight %"
      display_name: "Max weight %"
      expr: ROUND(MAX(constituent_weight_percent),4)
      comment: "Max weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_benchmark_registry`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Registry of equity benchmark indices with ESG integration coverage."
  source: "`asset_management`.`equity`.`equity_benchmark`"
  filter: benchmark_status = 'ACTIVE'
  dimensions:
    - name: "Benchmark Type"
      display_name: "Benchmark type"
      expr: benchmark_type
      comment: "Type"
    - name: "Geographic Scope"
      display_name: "Geographic scope"
      expr: geographic_scope
      comment: "Scope"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Benchmarks"
      display_name: "Benchmarks"
      expr: COUNT(1)
      comment: "Benchmarks"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ESG Integrated %"
      display_name: "Esg integrated %"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_integration = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "ESG integrated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_corporate_action_election`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Corporate action election processing analytics: elected quantities, cash/stock proceeds, proration and approval/election status. Steers corporate-action operations and cash capture."
  source: "`asset_management`.`equity`.`corporate_action_election`"
  dimensions:
    - name: "election_status"
      display_name: "Election Status"
      expr: election_status
      comment: "Status of the corporate action election."
    - name: "election_type"
      display_name: "Election Type"
      expr: election_type
      comment: "Type of election made."
    - name: "consideration_type"
      display_name: "Consideration Type"
      expr: consideration_type
      comment: "Consideration type (cash/stock/mixed)."
    - name: "cash_consideration_currency"
      display_name: "Cash Consideration Currency"
      expr: cash_consideration_currency
      comment: "Currency of cash consideration."
    - name: "execution_month"
      display_name: "Execution Month"
      expr: DATE_TRUNC('month', execution_date)
      comment: "Execution month of the election."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_elections"
      display_name: "Total Elections"
      expr: COUNT(1)
      comment: "Total elections processed — corporate-action operations volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_cash_consideration"
      display_name: "Total Cash Consideration"
      expr: SUM(CAST(cash_consideration_amount AS DOUBLE))
      comment: "Total cash consideration from elections — cash captured via corporate actions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_cash_proceeds"
      display_name: "Total Net Cash Proceeds"
      expr: SUM(CAST(net_cash_proceeds AS DOUBLE))
      comment: "Total net cash proceeds after tax — realizable cash impact."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_elected_quantity"
      display_name: "Total Elected Quantity"
      expr: SUM(CAST(elected_quantity AS DOUBLE))
      comment: "Total elected quantity — scale of action participation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_ic_approval_required"
      display_name: "% IC Approval Required"
      expr: ROUND(100.0 * SUM(CASE WHEN investment_committee_approval_required = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of elections requiring IC approval — governance workload indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_proration_factor"
      display_name: "Avg Proration Factor"
      expr: AVG(CAST(proration_factor AS DOUBLE))
      comment: "Average proration factor applied — oversubscription impact indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_corporate_action_election_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Voluntary corporate action elections and cash consideration captured."
  source: "`asset_management`.`equity`.`corporate_action_election`"
  dimensions:
    - name: "Consideration Type"
      display_name: "Consideration type"
      expr: consideration_type
      comment: "Type"
    - name: "Currency"
      display_name: "Currency"
      expr: cash_consideration_currency
      comment: "Currency"
  measures:
    - name: "Elections"
      display_name: "Elections"
      expr: COUNT(1)
      comment: "Elections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Cash Consideration"
      display_name: "Total cash consideration"
      expr: SUM(CAST(cash_consideration_amount AS DOUBLE))
      comment: "Cash"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Quantity Elected"
      display_name: "Quantity elected"
      expr: SUM(CAST(elected_quantity AS DOUBLE))
      comment: "Quantity"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_corporate_action_volume`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Corporate action events by type and status including NAV-impacting events."
  source: "`asset_management`.`equity`.`corporate_action`"
  dimensions:
    - name: "Action Type"
      display_name: "Action type"
      expr: action_type
      comment: "Type"
    - name: "Status"
      display_name: "Status"
      expr: action_status
      comment: "Status"
    - name: "Country of Issue"
      display_name: "Country of issue"
      expr: country_of_issue
      comment: "Country"
  measures:
    - name: "Events"
      display_name: "Events"
      expr: COUNT(1)
      comment: "Actions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "NAV Impacting %"
      display_name: "Nav impacting %"
      expr: ROUND(100.0 * SUM(CASE WHEN impact_on_nav_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "NAV impacting"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Research coverage analytics: coverage breadth, conviction, rating distribution and target-price upside. Steers research resource allocation and idea pipeline."
  source: "`asset_management`.`equity`.`equity_coverage`"
  dimensions:
    - name: "investment_rating"
      display_name: "Investment Rating"
      expr: investment_rating
      comment: "Analyst investment rating (buy/hold/sell)."
    - name: "conviction_level"
      display_name: "Conviction Level"
      expr: conviction_level
      comment: "Analyst conviction level on the name."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector of the covered security."
    - name: "geographic_region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of coverage."
    - name: "equity_coverage_status"
      display_name: "Coverage Status"
      expr: equity_coverage_status
      comment: "Status of the coverage relationship."
    - name: "research_priority"
      display_name: "Research Priority"
      expr: research_priority
      comment: "Research priority tier."
    - name: "initiation_month"
      display_name: "Initiation Month"
      expr: DATE_TRUNC('month', initiation_date)
      comment: "Coverage initiation month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "distinct_securities_covered"
      display_name: "Distinct Securities Covered"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Distinct securities under coverage — research breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "active_coverage_count"
      display_name: "Active Coverage Count"
      expr: SUM(CASE WHEN active_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of active coverage records — live research universe."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_target_price"
      display_name: "Avg Target Price"
      expr: AVG(CAST(target_price AS DOUBLE))
      comment: "Average analyst target price — aggregate valuation view."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "pct_esg_covered"
      display_name: "% ESG Covered"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_coverage_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of coverage with ESG analysis — ESG-integration coverage ratio."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "pct_held_positions_covered"
      display_name: "% Held Positions Covered"
      expr: ROUND(100.0 * SUM(CASE WHEN position_held_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of covered names held in portfolio — research-to-portfolio conversion."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_coverage_review_overdue`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of covered names overdue for review, a research-process quality KPI."
  source: "`asset_management`.`equity`.`equity_coverage`"
  filter: active_flag = TRUE
  dimensions:
    - name: "Region"
      display_name: "Region"
      expr: geographic_region
      comment: "Region"
    - name: "Market Cap Tier"
      display_name: "Market cap tier"
      expr: market_cap_tier
      comment: "Tier"
  measures:
    - name: "Covered Names"
      display_name: "Covered names"
      expr: COUNT(1)
      comment: "Names"
      format:
        type: number
        decimal_places:
          type: all
    - name: "With Next Review Set %"
      display_name: "With next review set %"
      expr: ROUND(100.0 * SUM(CASE WHEN next_review_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Scheduled review share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_coverage_universe`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Internal buy-side coverage universe by conviction, rating, and ESG coverage share."
  source: "`asset_management`.`equity`.`equity_coverage`"
  filter: active_flag = TRUE
  dimensions:
    - name: "Conviction"
      display_name: "Conviction"
      expr: conviction_level
      comment: "Conviction"
    - name: "Investment Rating"
      display_name: "Investment rating"
      expr: investment_rating
      comment: "Rating"
    - name: "Region"
      display_name: "Region"
      expr: geographic_region
      comment: "Region"
    - name: "Market Cap Tier"
      display_name: "Market cap tier"
      expr: market_cap_tier
      comment: "Cap tier"
  measures:
    - name: "Covered Names"
      display_name: "Covered names"
      expr: COUNT(1)
      comment: "Covered securities"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ESG Coverage %"
      display_name: "Esg coverage %"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_coverage_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "ESG coverage"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_dividend_fx_translation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Difference between local and base dividend amounts highlighting FX translation effect."
  source: "`asset_management`.`equity`.`dividend_record`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: dividend_currency_code
      comment: "Currency"
  measures:
    - name: "Gross Base"
      display_name: "Gross base"
      expr: SUM(CAST(gross_dividend_amount_base AS DOUBLE))
      comment: "Base"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Gross Local"
      display_name: "Gross local"
      expr: SUM(CAST(gross_dividend_amount_local AS DOUBLE))
      comment: "Local"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg FX Rate"
      display_name: "Avg fx rate"
      expr: ROUND(AVG(CAST(fx_rate AS DOUBLE)),4)
      comment: "FX"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_dividend_income`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Gross dividend income earned on the equity book by currency and dividend type."
  source: "`asset_management`.`equity`.`dividend_record`"
  dimensions:
    - name: "Dividend Type"
      display_name: "Dividend type"
      expr: dividend_type
      comment: "Type"
    - name: "Currency"
      display_name: "Currency"
      expr: dividend_currency_code
      comment: "Currency"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
  measures:
    - name: "Gross Dividend (Base)"
      display_name: "Gross dividend (base)"
      expr: SUM(CAST(gross_dividend_amount_base AS DOUBLE))
      comment: "Gross dividend base ccy"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Rate Per Share"
      display_name: "Avg rate per share"
      expr: ROUND(AVG(CAST(dividend_rate_per_share AS DOUBLE)),4)
      comment: "Rate per share"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_dividend_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Dividend income analytics: gross/net income, withholding tax drag, tax-reclaim recovery and reinvestment behaviour. Supports income forecasting and tax-efficiency steering for pension cash flows."
  source: "`asset_management`.`equity`.`dividend_record`"
  dimensions:
    - name: "dividend_status"
      display_name: "Dividend Status"
      expr: dividend_status
      comment: "Status of the dividend event (announced/paid/etc)."
    - name: "dividend_type"
      display_name: "Dividend Type"
      expr: dividend_type
      comment: "Type of dividend (ordinary/special/etc)."
    - name: "country_of_risk"
      display_name: "Country of Risk"
      expr: country_of_risk
      comment: "Country of risk for geographic income/tax analysis."
    - name: "tax_reclaim_status"
      display_name: "Tax Reclaim Status"
      expr: tax_reclaim_status
      comment: "Status of withholding-tax reclaim process."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector of the dividend-paying issuer."
    - name: "payment_month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Dividend payment month for income time series."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "payment_year"
      display_name: "Payment Year"
      expr: DATE_TRUNC('year', payment_date)
      comment: "Dividend payment year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "gross_dividend_income_base"
      display_name: "Gross Dividend Income (Base)"
      expr: SUM(CAST(gross_dividend_amount_base AS DOUBLE))
      comment: "Total gross dividend income in base currency — pension income generation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "net_dividend_income_base"
      display_name: "Net Dividend Income (Base)"
      expr: SUM(CAST(net_dividend_amount_base AS DOUBLE))
      comment: "Total net dividend income after withholding tax in base currency — realizable cash income."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "withholding_tax_base"
      display_name: "Withholding Tax (Base)"
      expr: SUM(CAST(withholding_tax_amount_base AS DOUBLE))
      comment: "Total withholding tax in base currency — tax drag on dividend income."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "tax_reclaim_recoverable_local"
      display_name: "Tax Reclaim Recoverable (Local)"
      expr: SUM(CAST(tax_reclaim_amount_local AS DOUBLE))
      comment: "Total reclaimable tax (local) — value recoverable via tax-treaty reclaim; drives recovery operations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_withholding_tax_rate_pct"
      display_name: "Avg Withholding Tax Rate %"
      expr: AVG(CAST(withholding_tax_rate_percent AS DOUBLE))
      comment: "Average withholding tax rate — tax-efficiency indicator across jurisdictions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "reinvested_dividend_income_base"
      display_name: "Reinvested Dividend Income (Base)"
      expr: SUM(CASE WHEN reinvestment_flag = TRUE THEN CAST(net_dividend_amount_base AS DOUBLE) ELSE 0 END)
      comment: "Net dividend income flagged for reinvestment — compounding/DRIP monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "reclaim_eligible_income_base"
      display_name: "Reclaim-Eligible Income (Base)"
      expr: SUM(CASE WHEN tax_reclaim_eligible_flag = TRUE THEN CAST(gross_dividend_amount_base AS DOUBLE) ELSE 0 END)
      comment: "Gross income eligible for tax reclaim — targets recovery pipeline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_dividend_payers"
      display_name: "Distinct Dividend Payers"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Number of distinct dividend-paying securities — income diversification."
      format:
        type: number
        decimal_places:
          type: all
    - name: "gross_dividend_income_cm"
      display_name: "Gross Dividend Income CM"
      expr: SUM(CAST(gross_dividend_amount_base AS DOUBLE))
      comment: "Current-month gross dividend income for MoM time intelligence."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: payment_month
          range: current
          semiadditive: last
    - name: "gross_dividend_income_pm"
      display_name: "Gross Dividend Income PM"
      expr: SUM(CAST(gross_dividend_amount_base AS DOUBLE))
      comment: "Prior-month gross dividend income for MoM comparison."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: payment_month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "gross_dividend_income_mom"
      display_name: "Gross Dividend Income MoM %"
      expr: (AGG(`gross_dividend_income_cm`) - AGG(`gross_dividend_income_pm`)) / NULLIF(AGG(`gross_dividend_income_pm`), 0)
      comment: "Month-over-month growth in gross dividend income — income trend signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_dividend_yield_on_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Average dividend yield relative to average cost basis across the equity book."
  source: "`asset_management`.`equity`.`equity_position`"
  dimensions:
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
  measures:
    - name: "Avg Dividend Yield %"
      display_name: "Avg dividend yield %"
      expr: ROUND(AVG(CAST(dividend_yield_percent AS DOUBLE)),2)
      comment: "Yield"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Cost Per Share"
      display_name: "Avg cost per share"
      expr: ROUND(AVG(CAST(average_cost_per_share AS DOUBLE)),2)
      comment: "Cost basis"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_earnings_announcement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over earnings announcements for listed securities. Tracks EPS surprise, consensus accuracy, and earnings cadence to support fundamental equity research, portfolio positioning decisions, and earnings season monitoring for the pension fund's public equity book."
  source: "`asset_management`.`equity`.`earnings_announcement`"
  parameters:
    - name: p_eps_basis_filter
      data_type: STRING
      default: "'gaap'"
    - name: p_surprise_threshold_pct
      data_type: DOUBLE
      default: 5.0
  dimensions:
    - name: "EPS Basis"
      display_name: "EPS Basis"
      expr: eps_basis
      comment: "Accounting basis for EPS figures — GAAP or adjusted. Allows analysts to compare like-for-like earnings across securities."
    - name: "Fiscal Year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of the earnings announcement. Used to group and trend annual earnings performance."
    - name: "Fiscal Quarter"
      display_name: "Fiscal Quarter"
      expr: fiscal_quarter
      comment: "Fiscal quarter (1–4) of the earnings announcement. Enables quarterly earnings cadence analysis."
    - name: "Announcement Date"
      display_name: "Announcement Date"
      expr: announcement_date
      comment: "Exact date the earnings were publicly announced. Used for event-driven analysis and earnings calendar tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Announcement Month"
      display_name: "Announcement Month"
      expr: DATE_TRUNC('month', announcement_date)
      comment: "Month bucket of the announcement date. Supports monthly aggregation of earnings events and surprise trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Announcement Quarter"
      display_name: "Announcement Quarter"
      expr: DATE_TRUNC('quarter', announcement_date)
      comment: "Quarter bucket of the announcement date. Supports quarterly earnings season analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Announcement Year"
      display_name: "Announcement Year"
      expr: DATE_TRUNC('year', announcement_date)
      comment: "Year bucket of the announcement date. Supports annual earnings trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "EPS Beat Flag"
      display_name: "EPS Beat / Miss"
      expr: CASE WHEN actual_eps > consensus_eps THEN 'Beat' WHEN actual_eps < consensus_eps THEN 'Miss' ELSE 'In-Line' END
      comment: "Categorical label indicating whether the company beat, missed, or met consensus EPS expectations. Core dimension for earnings quality segmentation."
    - name: "Significant Surprise Flag"
      display_name: "Significant Surprise (>Threshold%)"
      expr: CASE WHEN ABS(100.0 * (actual_eps - consensus_eps) / NULLIF(ABS(consensus_eps), 0)) >= p_surprise_threshold_pct THEN 'Significant' ELSE 'Normal' END
      comment: "Flags announcements where the EPS surprise magnitude exceeds the analyst-defined threshold parameter (default 5%). Useful for screening high-conviction earnings events."
  measures:
    - name: "Total Announcements"
      display_name: "Total Earnings Announcements"
      expr: COUNT(1)
      comment: "Total number of earnings announcements in the selected period and filters. Baseline volume metric for earnings calendar coverage."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Distinct Securities Reporting"
      display_name: "Distinct Securities Reporting"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Number of unique listed securities with at least one earnings announcement. Measures breadth of earnings coverage in the portfolio universe."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Avg Actual EPS"
      display_name: "Average Actual EPS"
      expr: AVG(CAST(actual_eps AS DOUBLE))
      comment: "Average actual earnings per share across all announcements in scope. Tracks the central tendency of realized earnings for the covered universe."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Consensus EPS"
      display_name: "Average Consensus EPS"
      expr: AVG(CAST(consensus_eps AS DOUBLE))
      comment: "Average consensus (analyst estimate) EPS across all announcements in scope. Benchmarks analyst expectations against realized outcomes."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total Actual EPS"
      display_name: "Total Actual EPS (Sum)"
      expr: SUM(CAST(actual_eps AS DOUBLE))
      comment: "Sum of actual EPS across all announcements. Used as the numerator in portfolio-level EPS aggregation and YoY growth calculations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total Consensus EPS"
      display_name: "Total Consensus EPS (Sum)"
      expr: SUM(CAST(consensus_eps AS DOUBLE))
      comment: "Sum of consensus EPS across all announcements. Used as the denominator baseline for aggregate surprise calculations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg EPS Surprise Pct"
      display_name: "Average EPS Surprise %"
      expr: AVG(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0))
      comment: "Average percentage by which actual EPS exceeded or missed consensus estimates. Positive values indicate beats; negative values indicate misses. Core metric for assessing analyst forecast accuracy and earnings quality across the equity universe."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Absolute EPS Surprise Pct"
      display_name: "Average Absolute EPS Surprise %"
      expr: AVG(ABS(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0)))
      comment: "Average magnitude of EPS surprise regardless of direction. Measures overall forecast dispersion and analyst uncertainty. High values signal volatile or hard-to-predict earnings."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "EPS Beat Count"
      display_name: "EPS Beat Count"
      expr: COUNT(CASE WHEN actual_eps > consensus_eps THEN 1 END)
      comment: "Number of announcements where actual EPS exceeded consensus. Used to compute beat rate and assess systematic analyst conservatism or optimism."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "EPS Miss Count"
      display_name: "EPS Miss Count"
      expr: COUNT(CASE WHEN actual_eps < consensus_eps THEN 1 END)
      comment: "Number of announcements where actual EPS fell short of consensus. Tracks downside earnings risk and analyst over-optimism."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "EPS Beat Rate"
      display_name: "EPS Beat Rate %"
      expr: 100.0 * COUNT(CASE WHEN actual_eps > consensus_eps THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "Percentage of earnings announcements where actual EPS beat consensus. A key signal of portfolio quality and analyst forecast bias. Executives use this to assess the earnings reliability of held positions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Max EPS Surprise Pct"
      display_name: "Max EPS Surprise %"
      expr: MAX(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0))
      comment: "Largest positive EPS surprise in the selected universe and period. Identifies the most significant upside earnings event — relevant for post-earnings attribution and position sizing review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Min EPS Surprise Pct"
      display_name: "Min EPS Surprise % (Worst Miss)"
      expr: MIN(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0))
      comment: "Largest negative EPS surprise (worst miss) in the selected universe and period. Flags the most severe downside earnings shock — critical for risk review and stop-loss evaluation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Announcements This Month"
      display_name: "Announcements (Current Month)"
      expr: COUNT(1)
      comment: "Count of earnings announcements in the current calendar month. Supports real-time earnings season monitoring."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: Announcement Month
          range: current
          semiadditive: last
    - name: "Announcements Prior Month"
      display_name: "Announcements (Prior Month)"
      expr: COUNT(1)
      comment: "Count of earnings announcements in the prior calendar month. Used as the baseline for MoM earnings volume comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: Announcement Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Announcements MoM Growth"
      display_name: "Announcements MoM Growth %"
      expr: (AGG(`Announcements This Month`) - AGG(`Announcements Prior Month`)) / NULLIF(AGG(`Announcements Prior Month`), 0)
      comment: "Month-over-month percentage change in earnings announcement volume. Tracks earnings season acceleration or deceleration."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg EPS Surprise Pct This Quarter"
      display_name: "Avg EPS Surprise % (Current Quarter)"
      expr: AVG(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0))
      comment: "Average EPS surprise percentage for the current earnings quarter. Provides a real-time read on how the current earnings season is tracking versus analyst expectations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Announcement Quarter
          range: current
          semiadditive: last
    - name: "Avg EPS Surprise Pct Prior Quarter"
      display_name: "Avg EPS Surprise % (Prior Quarter)"
      expr: AVG(100.0 * (CAST(actual_eps AS DOUBLE) - CAST(consensus_eps AS DOUBLE)) / NULLIF(ABS(CAST(consensus_eps AS DOUBLE)), 0))
      comment: "Average EPS surprise percentage for the prior earnings quarter. Baseline for QoQ earnings quality comparison."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Announcement Quarter
          range: current
          semiadditive: last
          offset: -3 months
    - name: "EPS Surprise QoQ Change"
      display_name: "EPS Surprise QoQ Change (pp)"
      expr: AGG(`Avg EPS Surprise Pct This Quarter`) - AGG(`Avg EPS Surprise Pct Prior Quarter`)
      comment: "Quarter-over-quarter change in average EPS surprise percentage (in percentage points). Signals whether earnings quality is improving or deteriorating across the covered universe."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Beat Rate This Year"
      display_name: "EPS Beat Rate % (Current Year)"
      expr: 100.0 * COUNT(CASE WHEN actual_eps > consensus_eps THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "EPS beat rate for the current calendar year. Tracks the annual earnings quality trend for the covered equity universe."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Announcement Year
          range: current
          semiadditive: last
    - name: "Beat Rate Prior Year"
      display_name: "EPS Beat Rate % (Prior Year)"
      expr: 100.0 * COUNT(CASE WHEN actual_eps > consensus_eps THEN 1 END) / NULLIF(COUNT(1), 0)
      comment: "EPS beat rate for the prior calendar year. Baseline for YoY earnings quality comparison."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Announcement Year
          range: current
          semiadditive: last
          offset: -1 year
    - name: "Beat Rate YoY Change"
      display_name: "EPS Beat Rate YoY Change (pp)"
      expr: AGG(`Beat Rate This Year`) - AGG(`Beat Rate Prior Year`)
      comment: "Year-over-year change in EPS beat rate (in percentage points). A key strategic signal: sustained improvement indicates rising earnings quality; deterioration may prompt portfolio review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Announcements YTD"
      display_name: "Announcements Year-to-Date"
      expr: COUNT(1)
      comment: "Cumulative count of earnings announcements from the start of the current year to the current date. Tracks earnings season progress against the full-year calendar."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      window:
        - order: Announcement Date
          range: cumulative
          semiadditive: last
        - order: Announcement Year
          range: current
          semiadditive: last
    - name: "Securities Reporting in Segment"
      display_name: "Securities Reporting per EPS Basis"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Count of distinct securities reporting within each EPS basis segment (GAAP vs adjusted). Supports cross-basis coverage analysis and ensures the pension fund's equity universe is consistently tracked under both reporting standards."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      partition:
        include: [EPS Basis]
        outer_aggregate: sum
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_engagement_log`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Issuer engagement and active-ownership analytics: engagement volume, escalation, outcomes and follow-up discipline across ESG pillars. Supports stewardship effectiveness reporting."
  source: "`asset_management`.`equity`.`engagement_log`"
  dimensions:
    - name: "engagement_type"
      display_name: "Engagement Type"
      expr: engagement_type
      comment: "Type of engagement conducted."
    - name: "engagement_status"
      display_name: "Engagement Status"
      expr: engagement_status
      comment: "Current status of the engagement."
    - name: "esg_pillar"
      display_name: "ESG Pillar"
      expr: esg_pillar
      comment: "ESG pillar (E/S/G) addressed by the engagement."
    - name: "topic_category"
      display_name: "Topic Category"
      expr: topic_category
      comment: "Engagement topic category."
    - name: "escalation_level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level reached in the engagement."
    - name: "engagement_month"
      display_name: "Engagement Month"
      expr: DATE_TRUNC('month', engagement_date)
      comment: "Engagement month for activity time series."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "engagement_year"
      display_name: "Engagement Year"
      expr: DATE_TRUNC('year', engagement_date)
      comment: "Engagement year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_engagements"
      display_name: "Total Engagements"
      expr: COUNT(1)
      comment: "Total engagements logged — active-ownership activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "distinct_issuers_engaged"
      display_name: "Distinct Issuers Engaged"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Distinct issuers engaged — stewardship reach."
      format:
        type: number
        decimal_places:
          type: all
    - name: "escalated_engagements"
      display_name: "Escalated Engagements"
      expr: SUM(CASE WHEN escalation_level IS NOT NULL AND escalation_level <> 'None' THEN 1 ELSE 0 END)
      comment: "Engagements that were escalated — signals unresolved/high-priority issues."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_milestone_achieved"
      display_name: "% Milestone Achieved"
      expr: ROUND(100.0 * SUM(CASE WHEN milestone_achieved IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of engagements achieving a milestone — stewardship effectiveness."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "pct_follow_up_required"
      display_name: "% Follow-Up Required"
      expr: ROUND(100.0 * SUM(CASE WHEN follow_up_required_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of engagements needing follow-up — open stewardship workload."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_engagement_duration_minutes"
      display_name: "Avg Engagement Duration (min)"
      expr: AVG(CAST(engagement_duration_minutes AS DOUBLE))
      comment: "Average engagement duration — engagement depth/resource intensity."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "collaborative_engagements"
      display_name: "Collaborative Engagements"
      expr: SUM(CASE WHEN collaborative_partner_names IS NOT NULL THEN 1 ELSE 0 END)
      comment: "Engagements conducted collaboratively with partners — collective-influence indicator."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_engagement_stewardship`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Active ownership engagement volume by ESG pillar, mode, and escalation level."
  source: "`asset_management`.`equity`.`engagement_log`"
  filter: active_flag = TRUE
  dimensions:
    - name: "ESG Pillar"
      display_name: "Esg pillar"
      expr: esg_pillar
      comment: "Pillar"
    - name: "Engagement Type"
      display_name: "Engagement type"
      expr: engagement_type
      comment: "Type"
    - name: "Status"
      display_name: "Status"
      expr: engagement_status
      comment: "Status"
  measures:
    - name: "Engagements"
      display_name: "Engagements"
      expr: COUNT(1)
      comment: "Engagements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Duration (min)"
      display_name: "Avg duration (min)"
      expr: ROUND(AVG(CAST(engagement_duration_minutes AS DOUBLE)),2)
      comment: "Duration"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalated %"
      display_name: "Escalated %"
      expr: ROUND(100.0 * SUM(CASE WHEN escalation_level IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Escalated share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_factor_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Barra/CAPM factor exposures and contribution to risk across the equity book."
  source: "`asset_management`.`equity`.`equity_factor_exposure`"
  dimensions:
    - name: "Factor Category"
      display_name: "Factor category"
      expr: factor_category
      comment: "Category"
    - name: "Factor Name"
      display_name: "Factor name"
      expr: factor_name
      comment: "Factor"
  measures:
    - name: "Avg Exposure"
      display_name: "Avg exposure"
      expr: ROUND(AVG(CAST(exposure_value AS DOUBLE)),4)
      comment: "Exposure"
    - name: "Avg Active Exposure"
      display_name: "Avg active exposure"
      expr: ROUND(AVG(CAST(active_exposure AS DOUBLE)),4)
      comment: "Active exposure"
    - name: "Avg Contribution to Risk"
      display_name: "Avg contribution to risk"
      expr: ROUND(AVG(CAST(contribution_to_risk AS DOUBLE)),4)
      comment: "Risk contribution"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_index_rebalance_turnover`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Estimated turnover and trading volume driven by benchmark index rebalancing."
  source: "`asset_management`.`equity`.`index_rebalance_event`"
  dimensions:
    - name: "Index Provider"
      display_name: "Index provider"
      expr: index_provider
      comment: "Provider"
    - name: "Benchmark"
      display_name: "Benchmark"
      expr: benchmark_name
      comment: "Benchmark"
  measures:
    - name: "Rebalance Events"
      display_name: "Rebalance events"
      expr: COUNT(1)
      comment: "Events"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Turnover %"
      display_name: "Avg turnover %"
      expr: ROUND(AVG(CAST(estimated_turnover_percent AS DOUBLE)),2)
      comment: "Turnover"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Est Trading Volume"
      display_name: "Total est trading volume"
      expr: SUM(CAST(estimated_trading_volume AS DOUBLE))
      comment: "Volume"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_issuer_credit_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Issuer credit ratings and carbon intensity across the covered corporate universe."
  source: "`asset_management`.`equity`.`equity_issuer`"
  dimensions:
    - name: "HQ Country"
      display_name: "Hq country"
      expr: headquarters_country_code
      comment: "Country"
    - name: "Fitch Rating"
      display_name: "Fitch rating"
      expr: credit_rating_fitch
      comment: "Fitch"
  measures:
    - name: "Issuers"
      display_name: "Issuers"
      expr: COUNT(1)
      comment: "Issuers"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Carbon Intensity"
      display_name: "Avg carbon intensity"
      expr: ROUND(AVG(CAST(carbon_intensity AS DOUBLE)),2)
      comment: "Carbon"
    - name: "Avg Employee Count"
      display_name: "Avg employee count"
      expr: ROUND(AVG(CAST(employee_count AS DOUBLE)),0)
      comment: "Employees"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_issuer_financials`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Issuer fundamental analytics: revenue, profitability, cash flow and leverage inputs used in fundamental buy-side analysis and valuation."
  source: "`asset_management`.`equity`.`issuer_financials`"
  dimensions:
    - name: "fiscal_period_type"
      display_name: "Fiscal Period Type"
      expr: fiscal_period_type
      comment: "Fiscal period type (annual/quarterly)."
    - name: "reporting_currency_code"
      display_name: "Reporting Currency"
      expr: reporting_currency_code
      comment: "Reporting currency of the financial statement."
    - name: "data_provider"
      display_name: "Data Provider"
      expr: data_provider
      comment: "Source data provider of the financials."
    - name: "period_end_month"
      display_name: "Period End Month"
      expr: DATE_TRUNC('month', period_end_date)
      comment: "Fiscal period end month for fundamentals time series."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_revenue"
      display_name: "Total Revenue"
      expr: SUM(CAST(revenue AS DOUBLE))
      comment: "Aggregate issuer revenue — top-line scale of the universe."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_income"
      display_name: "Total Net Income"
      expr: SUM(CAST(net_income AS DOUBLE))
      comment: "Aggregate net income — bottom-line profitability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_ebitda"
      display_name: "Total EBITDA"
      expr: SUM(CAST(ebitda AS DOUBLE))
      comment: "Aggregate EBITDA — operating cash profitability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_free_cash_flow"
      display_name: "Total Free Cash Flow"
      expr: SUM(CAST(free_cash_flow AS DOUBLE))
      comment: "Aggregate free cash flow — cash-generation quality."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_eps_diluted"
      display_name: "Avg Diluted EPS"
      expr: AVG(CAST(eps_diluted AS DOUBLE))
      comment: "Average diluted EPS — per-share earnings indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "total_debt_sum"
      display_name: "Total Debt"
      expr: SUM(CAST(total_debt AS DOUBLE))
      comment: "Aggregate total debt — leverage exposure of the universe."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_issuers_reporting"
      display_name: "Distinct Issuers Reporting"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Distinct issuers with reported financials — fundamentals coverage."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_issuer_fundamentals`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fundamental health of covered issuers: EBITDA margin proxy, FCF, and EPS trends."
  source: "`asset_management`.`equity`.`issuer_financials`"
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Year"
    - name: "Period Type"
      display_name: "Period type"
      expr: fiscal_period_type
      comment: "Period"
  measures:
    - name: "Total EBITDA"
      display_name: "Total ebitda"
      expr: SUM(CAST(ebitda AS DOUBLE))
      comment: "EBITDA"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Free Cash Flow"
      display_name: "Total free cash flow"
      expr: SUM(CAST(free_cash_flow AS DOUBLE))
      comment: "FCF"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Diluted EPS"
      display_name: "Avg diluted eps"
      expr: ROUND(AVG(CAST(eps_diluted AS DOUBLE)),2)
      comment: "EPS"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_listed_security_esg`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG rating distribution and sector composition of the listed security universe."
  source: "`asset_management`.`equity`.`listed_security`"
  filter: listing_status = 'ACTIVE'
  dimensions:
    - name: "GICS Sector"
      display_name: "Gics sector"
      expr: gics_sector
      comment: "Sector"
    - name: "Listing Country"
      display_name: "Listing country"
      expr: listing_country
      comment: "Country"
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG"
  measures:
    - name: "Securities"
      display_name: "Securities"
      expr: COUNT(1)
      comment: "Securities"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Restricted %"
      display_name: "Restricted %"
      expr: ROUND(100.0 * SUM(CASE WHEN investment_restriction_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Restricted share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio equity holdings analytics: market value, active weight, unrealized P&L, valuation and risk characteristics. Core view for monitoring public-equity exposure and active positioning against benchmark."
  source: "`asset_management`.`equity`.`equity_position`"
  dimensions:
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "GICS sector of the holding for sector exposure analysis."
    - name: "country_of_risk"
      display_name: "Country of Risk"
      expr: country_of_risk
      comment: "Country of economic risk for geographic exposure analysis."
    - name: "market_cap_tier"
      display_name: "Market Cap Tier"
      expr: market_capitalization_tier
      comment: "Market-cap tier (large/mid/small) for size-factor analysis."
    - name: "position_status"
      display_name: "Position Status"
      expr: position_status
      comment: "Lifecycle status of the position."
    - name: "base_currency_code"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Reporting base currency of the position."
    - name: "position_month"
      display_name: "Position Month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Position snapshot month for time-series exposure tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "position_year"
      display_name: "Position Year"
      expr: DATE_TRUNC('year', position_date)
      comment: "Position snapshot year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_market_value_base"
      display_name: "Total Market Value (Base)"
      expr: SUM(CAST(market_value_base_currency AS DOUBLE))
      comment: "Total portfolio market value in base currency — primary exposure/AUM measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_unrealized_gain_loss_base"
      display_name: "Total Unrealized P&L (Base)"
      expr: SUM(CAST(unrealized_gain_loss_base_currency AS DOUBLE))
      comment: "Total unrealized gain/loss in base currency — signals mark-to-market performance of open positions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_book_cost_base"
      display_name: "Total Book Cost (Base)"
      expr: SUM(CAST(book_cost_base_currency AS DOUBLE))
      comment: "Total book cost in base currency; combine with market value for cost-basis return."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_active_weight_pct"
      display_name: "Avg Active Weight %"
      expr: AVG(CAST(active_weight_percent AS DOUBLE))
      comment: "Average active weight vs benchmark — measures conviction/off-benchmark tilt."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_portfolio_weight_pct"
      display_name: "Avg Portfolio Weight %"
      expr: AVG(CAST(portfolio_weight_percent AS DOUBLE))
      comment: "Average portfolio weight of positions for concentration analysis."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "weighted_avg_beta"
      display_name: "Avg Beta"
      expr: AVG(CAST(beta AS DOUBLE))
      comment: "Average beta of positions — portfolio systematic-risk indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "avg_esg_score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across holdings — ESG integration monitoring (SFDR)."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "avg_dividend_yield_pct"
      display_name: "Avg Dividend Yield %"
      expr: AVG(CAST(dividend_yield_percent AS DOUBLE))
      comment: "Average dividend yield — income-generation characteristic of holdings."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_pe_ratio"
      display_name: "Avg P/E Ratio"
      expr: AVG(CAST(price_to_earnings_ratio AS DOUBLE))
      comment: "Average P/E ratio — valuation richness indicator of the book."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_securities_held"
      display_name: "Distinct Securities Held"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Number of distinct securities held — breadth/diversification indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "restricted_market_value_base"
      display_name: "Restricted Market Value (Base)"
      expr: SUM(CASE WHEN restricted_flag = TRUE THEN CAST(market_value_base_currency AS DOUBLE) ELSE 0 END)
      comment: "Market value of restricted positions — compliance exposure monitoring."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "closing_market_value_base"
      display_name: "Closing Market Value (Base)"
      expr: SUM(CAST(market_value_base_currency AS DOUBLE))
      comment: "Semi-additive closing market value — last snapshot in period (balance, never summed across time)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: position_month
          range: current
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_position_concentration`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Largest single-name equity exposures for concentration-risk anomaly detection."
  source: "`asset_management`.`equity`.`equity_position`"
  dimensions:
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
    - name: "Exchange"
      display_name: "Exchange"
      expr: exchange_code
      comment: "Exchange"
  measures:
    - name: "Max Active Weight %"
      display_name: "Max active weight %"
      expr: ROUND(MAX(active_weight_percent),2)
      comment: "Max active weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Benchmark Weight %"
      display_name: "Avg benchmark weight %"
      expr: ROUND(AVG(CAST(benchmark_weight_percent AS DOUBLE)),2)
      comment: "Benchmark weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Positions"
      display_name: "Positions"
      expr: COUNT(1)
      comment: "Positions"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_position_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Active and benchmark-relative equity exposure with beta and ESG profile by country."
  source: "`asset_management`.`equity`.`equity_position`"
  dimensions:
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
    - name: "Exchange"
      display_name: "Exchange"
      expr: exchange_code
      comment: "Exchange"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
  measures:
    - name: "Avg Active Weight %"
      display_name: "Avg active weight %"
      expr: ROUND(AVG(CAST(active_weight_percent AS DOUBLE)),2)
      comment: "Active weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Beta"
      display_name: "Avg beta"
      expr: ROUND(AVG(CAST(beta AS DOUBLE)),2)
      comment: "Beta"
    - name: "Avg ESG Score"
      display_name: "Avg esg score"
      expr: ROUND(AVG(CAST(esg_score AS DOUBLE)),2)
      comment: "ESG"
    - name: "Avg Dividend Yield %"
      display_name: "Avg dividend yield %"
      expr: ROUND(AVG(CAST(dividend_yield_percent AS DOUBLE)),2)
      comment: "Yield"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_position_shorts`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Borrowing cost intensity on short positions for cost-of-carry monitoring."
  source: "`asset_management`.`equity`.`short_interest`"
  filter: activity_type = 'SHORT'
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
  measures:
    - name: "Avg Borrow Cost bps"
      display_name: "Avg borrow cost bps"
      expr: ROUND(AVG(CAST(borrowing_cost_rate_bps AS DOUBLE)),2)
      comment: "Borrow cost"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Borrow Cost"
      display_name: "Total borrow cost"
      expr: SUM(CAST(borrowing_cost_accrued AS DOUBLE))
      comment: "Accrued cost"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_price_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Market price and liquidity analytics: traded value, volume, volatility and bid-ask spread by security. Supports trading cost, liquidity and market-impact assessment."
  source: "`asset_management`.`equity`.`price_history`"
  dimensions:
    - name: "exchange_code"
      display_name: "Exchange"
      expr: exchange_code
      comment: "Exchange on which price was observed."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Price quotation currency."
    - name: "trading_status"
      display_name: "Trading Status"
      expr: trading_status
      comment: "Trading status of the security on the price date."
    - name: "price_month"
      display_name: "Price Month"
      expr: DATE_TRUNC('month', price_date)
      comment: "Price observation month for time-series/liquidity trend."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "price_year"
      display_name: "Price Year"
      expr: DATE_TRUNC('year', price_date)
      comment: "Price observation year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_turnover_value"
      display_name: "Total Turnover Value"
      expr: SUM(CAST(turnover_value AS DOUBLE))
      comment: "Total traded turnover value — market liquidity magnitude."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_volume"
      display_name: "Total Volume"
      expr: SUM(CAST(volume AS DOUBLE))
      comment: "Total traded share volume — liquidity depth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_bid_ask_spread"
      display_name: "Avg Bid-Ask Spread"
      expr: AVG(CAST(bid_ask_spread AS DOUBLE))
      comment: "Average bid-ask spread — transaction-cost / liquidity-cost indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "avg_daily_price_change_pct"
      display_name: "Avg Daily Price Change %"
      expr: AVG(CAST(price_change_percent AS DOUBLE))
      comment: "Average daily price change percent — directional move indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "price_change_volatility"
      display_name: "Price Change Volatility"
      expr: STDDEV(CAST(price_change_percent AS DOUBLE))
      comment: "Standard deviation of daily price change — realized volatility / risk indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_vwap"
      display_name: "Avg VWAP"
      expr: AVG(CAST(vwap AS DOUBLE))
      comment: "Average VWAP — execution benchmark reference."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "distinct_securities_priced"
      display_name: "Distinct Securities Priced"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Distinct securities with price observations — pricing coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "turnover_value_30d"
      display_name: "Turnover Value 30d"
      expr: SUM(CAST(turnover_value AS DOUBLE))
      comment: "Rolling 30-day trailing turnover value — recent liquidity trend."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: price_month
          range: trailing 1 month inclusive
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_price_volatility`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Daily price change dispersion across the covered equity universe, an anomaly signal."
  source: "`asset_management`.`equity`.`price_history`"
  filter: is_trading_day = TRUE
  dimensions:
    - name: "Exchange"
      display_name: "Exchange"
      expr: exchange_code
      comment: "Exchange"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Avg Price Change %"
      display_name: "Avg price change %"
      expr: ROUND(AVG(CAST(price_change_percent AS DOUBLE)),2)
      comment: "Avg change"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Max Price Change %"
      display_name: "Max price change %"
      expr: ROUND(MAX(price_change_percent),2)
      comment: "Max change"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Bid-Ask Spread"
      display_name: "Avg bid-ask spread"
      expr: ROUND(AVG(CAST(bid_ask_spread AS DOUBLE)),4)
      comment: "Spread"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_proxy_voting_alignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Active ownership: votes cast and alignment with internal policy / against management."
  source: "`asset_management`.`equity`.`proxy_voting_record`"
  dimensions:
    - name: "Meeting Type"
      display_name: "Meeting type"
      expr: meeting_type
      comment: "Meeting type"
    - name: "Vote Decision"
      display_name: "Vote decision"
      expr: fund_vote_decision
      comment: "Decision"
    - name: "ESG Theme"
      display_name: "Esg theme"
      expr: esg_theme
      comment: "ESG theme"
  measures:
    - name: "Votes"
      display_name: "Votes"
      expr: COUNT(1)
      comment: "Ballots"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Policy Aligned %"
      display_name: "Policy aligned %"
      expr: ROUND(100.0 * SUM(CASE WHEN policy_alignment_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Policy aligned"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_proxy_voting_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Proxy voting and stewardship analytics: voting activity, alignment with policy/management, ESG-relevant votes and disclosure obligations. Steers responsible-investment and stewardship reporting."
  source: "`asset_management`.`equity`.`proxy_voting_record`"
  dimensions:
    - name: "resolution_category"
      display_name: "Resolution Category"
      expr: resolution_category
      comment: "Category of the resolution voted on."
    - name: "fund_vote_decision"
      display_name: "Fund Vote Decision"
      expr: fund_vote_decision
      comment: "The fund's vote decision (for/against/abstain)."
    - name: "esg_theme"
      display_name: "ESG Theme"
      expr: esg_theme
      comment: "ESG theme tied to the resolution."
    - name: "meeting_country_code"
      display_name: "Meeting Country"
      expr: meeting_country_code
      comment: "Country of the shareholder meeting."
    - name: "vote_review_status"
      display_name: "Vote Review Status"
      expr: vote_review_status
      comment: "Review workflow status of the vote."
    - name: "meeting_month"
      display_name: "Meeting Month"
      expr: DATE_TRUNC('month', meeting_date)
      comment: "Meeting month for voting activity time series."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "meeting_year"
      display_name: "Meeting Year"
      expr: DATE_TRUNC('year', meeting_date)
      comment: "Meeting year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_resolutions_voted"
      display_name: "Total Resolutions Voted"
      expr: COUNT(1)
      comment: "Total resolutions voted — stewardship activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "votes_against_management"
      display_name: "Votes Against Management"
      expr: SUM(CASE WHEN fund_vote_decision <> management_recommendation THEN 1 ELSE 0 END)
      comment: "Votes cast against management recommendation — stewardship assertiveness indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_votes_against_management"
      display_name: "% Votes Against Management"
      expr: ROUND(100.0 * SUM(CASE WHEN fund_vote_decision <> management_recommendation THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of votes against management — active-ownership engagement level."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "esg_relevant_votes"
      display_name: "ESG-Relevant Votes"
      expr: SUM(CASE WHEN esg_relevance_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of ESG-relevant votes — ESG stewardship focus."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pct_policy_aligned_votes"
      display_name: "% Policy-Aligned Votes"
      expr: ROUND(100.0 * SUM(CASE WHEN policy_alignment_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of votes aligned with voting policy — governance-consistency indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_voting_power_pct"
      display_name: "Avg Voting Power %"
      expr: AVG(CAST(voting_power_percent AS DOUBLE))
      comment: "Average voting power exercised — influence/footprint indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "distinct_issuers_voted"
      display_name: "Distinct Issuers Voted"
      expr: COUNT(DISTINCT listed_security_id)
      comment: "Distinct issuers voted on — stewardship coverage breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "disclosure_required_votes"
      display_name: "Disclosure-Required Votes"
      expr: SUM(CASE WHEN disclosure_required_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Votes requiring public disclosure — regulatory reporting obligation tracker."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_research_note_peer_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of research notes passing compliance and peer review, a research quality control."
  source: "`asset_management`.`equity`.`research_note`"
  dimensions:
    - name: "Conviction"
      display_name: "Conviction"
      expr: conviction_level
      comment: "Conviction"
  measures:
    - name: "Notes"
      display_name: "Notes"
      expr: COUNT(1)
      comment: "Notes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Compliance Reviewed %"
      display_name: "Compliance reviewed %"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_review_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Reviewed share"
    - name: "Archived %"
      display_name: "Archived %"
      expr: ROUND(100.0 * SUM(CASE WHEN archived_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Archived share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_research_note_productivity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Research output volume and valuation assumptions (WACC, terminal growth) across notes."
  source: "`asset_management`.`equity`.`research_note`"
  dimensions:
    - name: "Conviction"
      display_name: "Conviction"
      expr: conviction_level
      comment: "Conviction"
    - name: "Distribution Scope"
      display_name: "Distribution scope"
      expr: distribution_scope
      comment: "Scope"
  measures:
    - name: "Notes"
      display_name: "Notes"
      expr: COUNT(1)
      comment: "Research notes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg WACC %"
      display_name: "Avg wacc %"
      expr: ROUND(AVG(CAST(dcf_wacc_percent AS DOUBLE)),2)
      comment: "WACC assumption"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Terminal Growth %"
      display_name: "Avg terminal growth %"
      expr: ROUND(AVG(CAST(dcf_terminal_growth_rate_percent AS DOUBLE)),2)
      comment: "Terminal growth"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_restriction_inventory`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Active equity investment restrictions by type for compliance monitoring."
  source: "`asset_management`.`equity`.`restriction`"
  filter: active_flag = TRUE
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Level"
      display_name: "Level"
      expr: override_approval_level
      comment: "Level"
    - name: "Country"
      display_name: "Country"
      expr: country_iso_code
      comment: "Country"
  measures:
    - name: "Restrictions"
      display_name: "Restrictions"
      expr: COUNT(1)
      comment: "Restrictions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Breach Tolerance %"
      display_name: "Avg breach tolerance %"
      expr: ROUND(AVG(CAST(breach_tolerance_percent AS DOUBLE)),2)
      comment: "Tolerance"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_sector_classification_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Classification confidence and analyst override rate across the sector taxonomy."
  source: "`asset_management`.`equity`.`equity_sector_classification`"
  filter: classification_status = 'ACTIVE'
  dimensions:
    - name: "Scheme"
      display_name: "Scheme"
      expr: classification_scheme
      comment: "Scheme"
    - name: "Industry Group"
      display_name: "Industry group"
      expr: industry_group_name
      comment: "Industry group"
  measures:
    - name: "Classifications"
      display_name: "Classifications"
      expr: COUNT(1)
      comment: "Classifications"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Confidence"
      display_name: "Avg confidence"
      expr: ROUND(AVG(CAST(classification_confidence_score AS DOUBLE)),2)
      comment: "Confidence"
    - name: "Override %"
      display_name: "Override %"
      expr: ROUND(100.0 * SUM(CASE WHEN analyst_override_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Override share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_security_sector_mapping_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sector mapping coverage and benchmark alignment for classification governance."
  source: "`asset_management`.`equity`.`security_sector_mapping`"
  dimensions:
    - name: "Scheme"
      display_name: "Scheme"
      expr: classification_scheme
      comment: "Scheme"
    - name: "Internal Sector"
      display_name: "Internal sector"
      expr: internal_sector_name
      comment: "Sector"
  measures:
    - name: "Mappings"
      display_name: "Mappings"
      expr: COUNT(1)
      comment: "Mappings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Benchmark Aligned %"
      display_name: "Benchmark aligned %"
      expr: ROUND(100.0 * SUM(CASE WHEN benchmark_alignment_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Aligned share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_short_interest`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Securities lending and short-position analytics: lent value, lending fee income, borrowing cost and unrealized P&L on shorts. Steers securities-lending revenue and short-book risk."
  source: "`asset_management`.`equity`.`short_interest`"
  dimensions:
    - name: "activity_type"
      display_name: "Activity Type"
      expr: activity_type
      comment: "Type of lending/short activity."
    - name: "settlement_status"
      display_name: "Settlement Status"
      expr: settlement_status
      comment: "Settlement status of the lending/short record."
    - name: "collateral_type"
      display_name: "Collateral Type"
      expr: collateral_type
      comment: "Type of collateral received."
    - name: "base_currency_code"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Reporting base currency."
    - name: "position_month"
      display_name: "Position Month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Position snapshot month for lending/short trend."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_lent_market_value_base"
      display_name: "Total Lent Market Value (Base)"
      expr: SUM(CAST(lent_market_value_base AS DOUBLE))
      comment: "Total lent market value in base currency — securities-lending book size."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_lending_fee_income"
      display_name: "Total Lending Fee Income"
      expr: SUM(CAST(lending_fee_accrued AS DOUBLE))
      comment: "Total accrued lending fee income — incremental revenue from lending program."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_borrowing_cost"
      display_name: "Total Borrowing Cost"
      expr: SUM(CAST(borrowing_cost_accrued AS DOUBLE))
      comment: "Total accrued borrowing cost — cost of maintaining short positions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_short_position_market_value_base"
      display_name: "Total Short Market Value (Base)"
      expr: SUM(CAST(short_position_market_value_base AS DOUBLE))
      comment: "Total short position market value in base currency — short-book exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_unrealized_gain_loss_short"
      display_name: "Total Unrealized P&L (Short)"
      expr: SUM(CAST(unrealized_gain_loss_short AS DOUBLE))
      comment: "Total unrealized P&L on short positions — short-book performance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_lending_fee_rate_bps"
      display_name: "Avg Lending Fee Rate (bps)"
      expr: AVG(CAST(lending_fee_rate_bps AS DOUBLE))
      comment: "Average lending fee rate (bps) — lending-program pricing indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "compliance_breaches"
      display_name: "Compliance Breaches"
      expr: SUM(CASE WHEN compliance_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of records flagged for compliance breach — lending-program risk control."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_short_interest_lending`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stock-lending fee income and borrowing cost on the equity book."
  source: "`asset_management`.`equity`.`short_interest`"
  dimensions:
    - name: "Activity Type"
      display_name: "Activity type"
      expr: activity_type
      comment: "Activity"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
  measures:
    - name: "Lending Fee Accrued"
      display_name: "Lending fee accrued"
      expr: SUM(CAST(lending_fee_accrued AS DOUBLE))
      comment: "Lending fee"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Borrowing Cost Accrued"
      display_name: "Borrowing cost accrued"
      expr: SUM(CAST(borrowing_cost_accrued AS DOUBLE))
      comment: "Borrow cost"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Lent Market Value"
      display_name: "Lent market value"
      expr: SUM(CAST(lent_market_value_base AS DOUBLE))
      comment: "Lent value"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Lending Fee bps"
      display_name: "Avg lending fee bps"
      expr: ROUND(AVG(CAST(lending_fee_rate_bps AS DOUBLE)),2)
      comment: "Lending fee bps"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_stock_selection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stock selection and active positioning analytics: expected return, upside/downside, active weight and conviction. Steers alpha idea generation and portfolio construction decisions."
  source: "`asset_management`.`equity`.`stock_selection`"
  dimensions:
    - name: "recommendation"
      display_name: "Recommendation"
      expr: recommendation
      comment: "Selection recommendation (buy/sell/hold)."
    - name: "conviction_level"
      display_name: "Conviction Level"
      expr: conviction_level
      comment: "Conviction level of the selection."
    - name: "selection_status"
      display_name: "Selection Status"
      expr: selection_status
      comment: "Status of the stock selection decision."
    - name: "implementation_status"
      display_name: "Implementation Status"
      expr: implementation_status
      comment: "Implementation status of the selection."
    - name: "style_factor"
      display_name: "Style Factor"
      expr: style_factor
      comment: "Style factor tilt of the selection."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector of the selected security."
    - name: "decision_month"
      display_name: "Decision Month"
      expr: DATE_TRUNC('month', decision_date)
      comment: "Decision month for idea-flow time series."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_selections"
      display_name: "Total Selections"
      expr: COUNT(1)
      comment: "Total stock selections — idea-generation volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_expected_return_pct"
      display_name: "Avg Expected Return %"
      expr: AVG(CAST(expected_return_percent AS DOUBLE))
      comment: "Average expected return of selections — forward alpha expectation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_upside_downside_pct"
      display_name: "Avg Upside/Downside %"
      expr: AVG(CAST(upside_downside_percent AS DOUBLE))
      comment: "Average upside/downside vs target — risk-reward skew of ideas."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_target_position_value_base"
      display_name: "Total Target Position Value (Base)"
      expr: SUM(CAST(target_position_value_base_currency AS DOUBLE))
      comment: "Total target position value — intended capital deployment from selections."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_active_weight_pct"
      display_name: "Avg Active Weight %"
      expr: AVG(CAST(active_weight_percent AS DOUBLE))
      comment: "Average active weight of selections — off-benchmark positioning intent."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "pct_ic_approved"
      display_name: "% IC Approved"
      expr: ROUND(100.0 * SUM(CASE WHEN ic_approval_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of selections with IC approval — governance throughput of the pipeline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "pct_esg_integrated"
      display_name: "% ESG Integrated"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_integration_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percent of selections with ESG integration — ESG-in-decision discipline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_stock_selection_conviction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio-construction selection decisions with expected return and active weight."
  source: "`asset_management`.`equity`.`stock_selection`"
  dimensions:
    - name: "Conviction"
      display_name: "Conviction"
      expr: conviction_level
      comment: "Conviction"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
  measures:
    - name: "Selections"
      display_name: "Selections"
      expr: COUNT(1)
      comment: "Selections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Expected Return %"
      display_name: "Avg expected return %"
      expr: ROUND(AVG(CAST(expected_return_percent AS DOUBLE)),2)
      comment: "Expected return"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Active Weight %"
      display_name: "Avg active weight %"
      expr: ROUND(AVG(CAST(active_weight_percent AS DOUBLE)),2)
      comment: "Active weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "IC Required %"
      display_name: "Ic required %"
      expr: ROUND(100.0 * SUM(CASE WHEN ic_approval_required_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "IC required share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`equity_valuation_model_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage of proprietary valuation models and intrinsic value estimates."
  source: "`asset_management`.`equity`.`valuation_model`"
  dimensions:
    - name: "Model Confidence"
      display_name: "Model confidence"
      expr: model_confidence_level
      comment: "Confidence"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Models"
      display_name: "Models"
      expr: COUNT(1)
      comment: "Models"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Intrinsic Value"
      display_name: "Avg intrinsic value"
      expr: ROUND(AVG(CAST(intrinsic_value_estimate AS DOUBLE)),2)
      comment: "Intrinsic value"
    - name: "Avg Discount Rate %"
      display_name: "Avg discount rate %"
      expr: ROUND(AVG(CAST(discount_rate_percent AS DOUBLE)),2)
      comment: "Discount rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
